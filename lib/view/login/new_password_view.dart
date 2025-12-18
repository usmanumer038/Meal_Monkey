// Supabase uses the emailed link; in-app manual reset isn’t needed.
// Keep placeholder if navigated accidentally.
import 'package:flutter/material.dart';

class NewPasswordView extends StatelessWidget {
  const NewPasswordView({super.key, required this.nObj});
  final Map nObj;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Use the reset link sent to your email.")),
    );
  }
}