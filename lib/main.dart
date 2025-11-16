import 'package:flutter/material.dart';
import 'package:inventory_frontend/providers/binding_provider.dart';
import 'package:inventory_frontend/providers/department_provider.dart';
import 'package:inventory_frontend/providers/employee_provider.dart';
import 'package:inventory_frontend/providers/sked_provider.dart';
import 'package:inventory_frontend/providers/user_provider.dart';
import 'package:inventory_frontend/screens/login_screen.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_screen.dart';
import 'package:inventory_frontend/services/api_service.dart';
import 'package:inventory_frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.autoLogin(); // Проверяем сохраненный токен
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),  // Один экземпляр с токеном

        ProxyProvider<AuthService, ApiService>(
          update: (_, authService, __) => ApiService(authService.dioInstance, authService),
        ),
        ChangeNotifierProxyProvider<ApiService, UserProvider>(
          create: (_) => UserProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, userProvider) => userProvider ?? UserProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, DepartmentProvider>(
          create: (_) => DepartmentProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, departmentProvider) => departmentProvider ?? DepartmentProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, BindingProvider>(
          create: (_) => BindingProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => BindingProvider(apiService),
        ),
        // ChangeNotifierProxyProvider<ApiService, DepartmentProvider>(
        //   create: (_) => DepartmentProvider(ApiService(authService.dioInstance, authService)),
        //   update: (_, apiService, __) => DepartmentProvider(apiService),
        // ),
        ChangeNotifierProxyProvider<ApiService, EmployeeProvider>(
          create: (_) => EmployeeProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => EmployeeProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, SkedProvider>(
          create: (_) => SkedProvider(
            departmentProvider: DepartmentProvider(ApiService(authService.dioInstance, authService)),
            apiService: ApiService(authService.dioInstance, authService),
            authService: authService,
          ),
          update: (_, apiService, skedProvider) => skedProvider ?? SkedProvider(
            departmentProvider: Provider.of<DepartmentProvider>(_, listen: false),
            apiService: apiService,
            authService: Provider.of<AuthService>(_, listen: false),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Инвентаризация',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => Scaffold(
          appBar: AppBar(
            title: Text('Инвентаризация'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  // ПОЛНОЕ ВЫХОД ИЗ СИСТЕМЫ
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final skedProvider = Provider.of<SkedProvider>(context, listen: false);

                  // 1. Выход из системы
                  await authService.logout();

                  // 2. Сброс состояния SkedProvider
                  skedProvider.resetState();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SkedsScreen(), // твой основной контент
        ),
      },
    );
  }
}