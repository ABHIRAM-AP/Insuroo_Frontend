import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const InSurooApp());
}

class InSurooApp extends StatelessWidget {
  const InSurooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'Insuroo AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ChatScreen(),
      ),
    );
  }
}
