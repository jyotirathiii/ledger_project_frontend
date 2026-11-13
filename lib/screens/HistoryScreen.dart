import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';

import 'package:ledger_project/models/transaction.dart';
import 'package:ledger_project/screens/refund_screen.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/services/session.dart';
import 'package:ledger_project/widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final bool refundOnly;
  const HistoryScreen({super.key, this.refundOnly = false});

  @override
  State<HistoryScreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<HistoryScreen> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  Future loadHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ApiService.getHistory();
      if (!mounted) return;
      if (data is List) {
        final myEmail = Session.email ?? '';
        final all = data
            .map(
              (e) => Transaction.fromJson(e as Map<String, dynamic>, myEmail),
            )
            .toList();

        setState(() {
          transactions = widget.refundOnly
              ? all.where((t) => t.canRefund).toList()
              : all;
        });
      } else {
        setState(() {
          error =
              (data is Map ? data['detail'] : null)?.toString() ??
              'could not load history';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'could not reach the server';
      });
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
          widget.refundOnly ? 'Select a transaction to refund' : 'History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? CircularProgressIndicator()
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, style: TextStyle(color: Color(0xFFA12626))),
                  TextButton(onPressed: loadHistory, child: Text('Retry')),
                ],
              ),
            )
          : transactions.isEmpty
          ? Center(
              child: Text(
                widget.refundOnly
                    ? 'No refundable transactions'
                    : 'No Transactions Yet',
              ),
            )
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return TransactionTile(
                    transaction: transactions[index],
                    onTap: () async {
                      final t = transactions[index];
                      if (!t.canRefund) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This transaction cannot be refunded',
                            ),
                          ),
                        );
                        return;
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RefundScreen(
                            transferId: transactions[index].id,
                            name: transactions[index].name,
                            originalAmount: transactions[index].amountValue,
                            alreadyrefunded: transactions[index].refundedValue,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
