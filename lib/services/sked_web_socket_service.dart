import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../providers/sked_provider.dart';

class SkedWebSocketService {
  final String url;
  String? token;  // Добавляем токен как поле (опциональное)
  late StompClient _client;
  final Map<int, Function(bool)> _availabilityCallbacks = {};
  SkedProvider? _skedProvider; // Делаем опциональным



  SkedWebSocketService({
    // this.url = 'ws://10.31.51.206:8060/ws-skeds',
    this.url = 'wss://inventory-3z06.onrender.com/ws-skeds',
    this.token,
    SkedProvider? skedProvider,
  }) {
    // SkedWebSocketService({this.url = 'ws://localhost:8060/ws-skeds'}) {
    // SkedWebSocketService({this.url = 'wss://inventory-3z06.onrender.com/ws-skeds'}) {
    // SkedWebSocketService({this.url = 'ws://10.0.2.2:8060/ws-skeds'}) {
    _initClient();
  }

  void updateSkedProvider(SkedProvider provider) {
    _skedProvider = provider;
  }

  void _initClient() {
    _client = StompClient(
      config: StompConfig(
        url: url,
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},  // Используем токен, если он есть
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        onStompError: (frame) => print('STOMP Error: ${frame.body} ${frame.headers}'),
        onDisconnect: (_) => print('Disconnected'),
        onDebugMessage: (msg) => print('[STOMP DEBUG] $msg'),
      ),
    );
  }

  void connect() => _client.activate();

  void _onConnect(StompFrame frame) {
    print('✅ [WebSocket] Успешно подключен к $url');
    print('✅ [WebSocket] Подписка на /topic/sked-updates');
    print('[WebSocket Connected]');
    _client.subscribe(
      destination: '/topic/sked-updates',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          final skedId = data['skedId'] as int;
          final available = data['available'] as bool;

          _skedProvider?.updateSkedLocally(skedId, available: available);

          _availabilityCallbacks[skedId]?.call(available);
        }
      },
    );
  }

  void listenToAvailability(int skedId, void Function(bool) onUpdate) {
    _availabilityCallbacks[skedId] = onUpdate;
  }

  void pushManualChange(int skedId, bool available) {
    final message = jsonEncode({'skedId': skedId, 'available': available});
    _client.send(
      destination: '/app/skeds/$skedId/availability',
      body: jsonEncode(available),
    );
  }

  // Новый метод для обновления токена и реконнекта (вызывайте после логина)
  void updateTokenAndReconnect(String newToken) {
    token = newToken;
    _client.deactivate();  // Отключаем старый клиент
    _initClient();  // Пересоздаём с новым токеном
    _client.activate();  // Подключаемся заново
  }

  void dispose() {
    _client.deactivate();
    _availabilityCallbacks.clear();
  }
}