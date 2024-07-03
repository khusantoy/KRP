import 'package:flutter/material.dart';
import 'package:krp/views/screens/components/motivation_screen.dart';
import 'package:krp/views/screens/components/pomodoro_screen.dart';
import 'package:krp/views/screens/components/todo_screen.dart';

class HomeScreen extends StatefulWidget {
  int currentIndex = 0;
  HomeScreen({super.key, required this.currentIndex});

  static const navigation = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.format_quote),
      label: "Quote",
    ),
    NavigationDestination(
      icon: Icon(Icons.check_circle_outline),
      label: "Todo",
    ),
    NavigationDestination(
      icon: Icon(Icons.timer),
      label: "Pomodoro",
    )
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int drawerIndex = 0;

  final page = [
    const MotivationScreen(),
    const TodoScreen(),
    const PomodoroScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeScreen.navigation[widget.currentIndex].label),
      ),
      body: page[widget.currentIndex],
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: widget.currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            widget.currentIndex = index;
          });
        },
        destinations: HomeScreen.navigation,
      ),
    );
  }
}
