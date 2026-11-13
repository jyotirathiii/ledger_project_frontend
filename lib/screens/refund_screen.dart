import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class RefundScreen extends StatefulWidget {
  final int transferId;
  final String name;
  final double originalAmount;
  final double alreadyrefunded;
  const RefundScreen({
    super.key,
    required this.transferId,
    required this.name,
    required this.originalAmount,
    required this.alreadyrefunded,
  });

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  TextEditingController amountController = TextEditingController();
  bool isLoading = false;
  String idemKey = Uuid().v4();
  double get remanining => widget.originalAmount - widget.alreadyrefunded;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> onrefund() async {
    if (isLoading) return;
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      showMessage('Please enter a valid amount');
      return;
    }
    if (amount > remanining) {
      showMessage('You can refund at most ₹$remanining');
      return;
    }
    setState(() {
      isLoading = true;
    });
    setState(() {
      isLoading = true;
    });
    try {
      final result = await ApiService.refund(
        widget.transferId,
        amount,
        idemKey,
      );
      if (!mounted) return;
      final code = result['statusCode'];
      final raw = result['detail'];
      final detail = raw is String
          ? raw
          : (raw == null ? '' : 'Please check your input');
      if (code == 200 && result['status'] == 'success') {
        idemKey = const Uuid().v4();
        showMessage(
          result['duplicate'] == true
              ? 'This refund was already done'
              : 'Refund successful',
        );
        Navigator.pop(context);
      } else if (code == 409) {
        showMessage('This request was already used with different details');
      } else if (code == 401 && detail == 'Not authenticated' ||
          detail.contains('token')) {
        showMessage('Session expired. Please login again');
      } else {
        showMessage(detail.isEmpty ? 'Refunded Failed' : detail);
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
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        title: Text(
          'Refund',
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
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Transfer',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Text(
                                  '${widget.transferId}.${widget.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Original Amount',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Text(
                                  ' ${widget.originalAmount}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Already refunded',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Text(
                                  '${widget.alreadyrefunded}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Divider(height: 1),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Refund', style: TextStyle(fontSize: 16)),
                                Spacer(),
                                Text(
                                  '${remanining}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Refund amount', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomButton(
              text: 'Refund',
              onPressed: onrefund,
              backgroundColor: AppColors.green,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
