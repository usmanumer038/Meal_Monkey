// Not used with Supabase reset-link flow. Keep stub or remove from navigation.
import 'package:flutter/material.dart';

class OTPView extends StatelessWidget {
  const OTPView({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Password reset is handled via email link.")),
    );
  }
}