import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/widgets/custom_button.dart';

class TransferBlockScreen extends StatelessWidget {
  final String reason;
  const TransferBlockScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 100),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Color(0xFFFBE7E7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.block,
                          size: 40,
                          color: Color(0xFFA12626),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Transfer blocked',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This transfer failed the risk check, so no money was deducted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4E5A54),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.green),
                        ),
                        child: Text(
                          'Reason: $reason',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                text: 'Return Home',
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                backgroundColor: AppColors.green,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
