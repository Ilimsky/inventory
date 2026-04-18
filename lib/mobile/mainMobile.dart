// mainMobile.dart - исправленная версия
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/department_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/sked_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'MobileLoginScreen.dart';
import 'QrScannerScreen.dart';
// import 'QrScannerScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ProxyProvider<AuthService, ApiService>(
          update: (context, authService, previous) => ApiService(authService.dioInstance, authService),
        ),
        ChangeNotifierProxyProvider<ApiService, DepartmentProvider>(
          create: (context) => DepartmentProvider(Provider.of<ApiService>(context, listen: false)),
          update: (context, apiService, departmentProvider) => departmentProvider ?? DepartmentProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, EmployeeProvider>(
          create: (context) => EmployeeProvider(Provider.of<ApiService>(context, listen: false)),
          update: (context, apiService, employeeProvider) => employeeProvider ?? EmployeeProvider(apiService),
        ),
        ChangeNotifierProxyProvider2<ApiService, DepartmentProvider, SkedProvider>(
          create: (context) => SkedProvider(
            departmentProvider: Provider.of<DepartmentProvider>(context, listen: false),
            apiService: Provider.of<ApiService>(context, listen: false),
            authService: Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, apiService, departmentProvider, skedProvider) =>
          skedProvider ?? SkedProvider(
            departmentProvider: departmentProvider!,
            apiService: apiService,
            authService: Provider.of<AuthService>(context, listen: false),
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
      title: 'Инвентаризация Мобильная',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Показываем логин если не аутентифицирован
          if (!authService.isAuthenticated) {
            return MobileLoginScreen();
          }
          // Иначе показываем сканер (будет загружен после инициализации)
          return FutureBuilder(
            future: authService.autoLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return Scaffold(
                appBar: AppBar(
                  title: Text('Инвентаризация Мобильная'),
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

                        // 3. Переход на экран логина с очисткой стека навигации
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                body: QrScannerScreen(),
              );
            },
          );
        },
      ),
    );
  }
}