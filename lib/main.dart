import 'package:flutter/material.dart';
import 'package:inventory_frontend/providers/BindingProvider.dart';
import 'package:inventory_frontend/providers/DepartmentProvider.dart';
import 'package:inventory_frontend/providers/EmployeeProvider.dart';
import 'package:inventory_frontend/providers/SkedProvider.dart';
import 'package:inventory_frontend/screens/create_sked_screen.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_screen.dart';
import 'package:provider/provider.dart';

import 'screens/reference_screen/reference_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BindingProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
        ChangeNotifierProvider(create: (_) => SkedProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SkedsScreen(), // Список отчетов
    CreateSkedScreen(), // Создание отчетов
    ReferenceScreen(), // Справочник (филиалы)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Управление отчетами')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Список отчетов'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Создание отчетов'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Справочник'),
        ],
      ),
    );
  }
}