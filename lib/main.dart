import 'package:flutter/material.dart';
import 'package:inventory_frontend/providers/BindingProvider.dart';
import 'package:inventory_frontend/providers/DepartmentProvider.dart';
import 'package:inventory_frontend/providers/EmployeeProvider.dart';
import 'package:inventory_frontend/providers/SkedProvider.dart';
import 'package:inventory_frontend/screens/create_sked_screen.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_screen.dart';
import 'package:provider/provider.dart';

import 'screens/reference_screen/reference_screen.dart';

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
        ChangeNotifierProxyProvider<DepartmentProvider, SkedProvider>(
          create: (context) => SkedProvider(
            departmentProvider: Provider.of<DepartmentProvider>(context, listen: false),
          ),
          update: (context, departmentProvider, skedProvider) =>
          skedProvider ?? SkedProvider(departmentProvider: departmentProvider),
        ),
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
      home: SkedsScreen(), // теперь это главный экран
    );
  }
}