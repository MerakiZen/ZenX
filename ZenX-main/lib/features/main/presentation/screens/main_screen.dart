import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';

/// Main screen with bottom navigation
class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

