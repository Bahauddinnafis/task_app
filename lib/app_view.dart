import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/controllers/task_controller.dart';
import 'package:task_app/screens/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Task App",
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF234288),
            secondary: Color(0xFF337ab7)
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
