import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/screens/transfer_block_Screen.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class SendMoneyScreen extends StatefulWidget {
  final double availableBalance;
  const SendMoneyScreen({super.key, required this.availableBalance});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  TextEditingController accountIdController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String idmkey = const Uuid().v4();

  bool isLoading = false;
  // final double availableBalance = 700;

  @override
  void dispose() {
    accountIdController.dispose();
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> onPay() async {
    if (isLoading) return;

    final amount = double.tryParse(amountController.text.trim());
    final receiverId = int.tryParse(accountIdController.text.trim());

    if (amount == null || amount <= 0) {
      showMessage('Please enter a valid amount');
      return;
    }
    if (amount > widget.availableBalance) {
      showMessage('Amount is more than balance');
      return;
    }
    if (receiverId == null) {
      showMessage('Please enter the receiver Id');
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      final result = await ApiService.transfer(receiverId, amount, idmkey);
      print('API RESULT: $result');
      if (!mounted) return;

      final code = result['statusCode'];
      final raw = result['detail'];
      final detail = raw is String
          ? raw
          : (raw == null ? '' : 'Please check your input');
      if (code == 200 && result['status'] == 'success') {
        idmkey = Uuid().v4();
        showMessage(
          result['duplicate'] == true
              ? 'This transfer was already done'
              : 'Transfer successful',
        );
        Navigator.pop(context);
      } else if (code == 403 && detail.startsWith('Transfer blocked')) {
        final reason = detail.replaceFirst(
          'Transfer blocked by risk check:',
          '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferBlockScreen(reason: reason),
          ),
        );
      } else if (code == 409) {
        showMessage('This request was already used with different details');
      } else if (code == 401 ||
          detail == 'Not authenticated' ||
          detail.contains('token')) {
        showMessage('Session expired. Please login again');
      } else {
        showMessage(detail.isEmpty ? 'Transfer Failed' : detail);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('could not reach the server');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        title: Text(
          'Send Money',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: height / 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '₹0',
                                border: InputBorder.none,
                              ),
                            ),

                            SizedBox(height: 8),
                            Text(
                              'Available:₹${widget.availableBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Receiver account ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: accountIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Account Id',
                        filled: true,
                        fillColor: AppColors.background,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Note (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Note',
                        filled: true,
                        fillColor: AppColors.background,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: height / 2.5),
                    CustomButton(
                      text: 'Pay ',
                      onPressed: onPay,
                      backgroundColor: AppColors.green,
                      textColor: AppColors.background,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
