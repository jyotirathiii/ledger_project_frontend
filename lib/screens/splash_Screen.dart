import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/screens/HomeScreen.dart';
import 'package:ledger_project/screens/login_screen.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/services/session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final minWait = Future.delayed(Duration(milliseconds: 900));

    await Session.load();
    Widget next = LoginScreen();

    if (Session.token != null) {
      try {
        print('TOKEN: ${Session.token}');
        print('EMAIL: ${Session.email}');
        final data = await ApiService.getBalance();

        print('BALANCE RESPONSE: $data');
        if (data['balance'] != null) {
          print('TOKEN VALID - HOME SCREEN');
          next = Homescreen();
        } else {
          await Session.clear();
          print('Balance missing. Clearing session.');
        }
      } catch (e) {
        print('BALANCE API ERROR: $e');
        next = Homescreen();
      }
    }
    await minWait;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KhataPay',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
