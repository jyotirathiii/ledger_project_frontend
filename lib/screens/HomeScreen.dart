import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/models/transaction.dart';

import 'package:ledger_project/screens/HistoryScreen.dart';
import 'package:ledger_project/screens/login_screen.dart';

import 'package:ledger_project/screens/send_money_screen.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/services/session.dart';

import 'package:ledger_project/widgets/transaction_tile.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Transaction> recent = [];
  @override
  void initState() {
    super.initState();
    loadBalance();
    loadHistory();
  }

  double? balance;
  int? accountId;
  bool loadingBalance = true;
  String? balanceError;
  bool loadingHistory = false;
  String? historyError;

  Future<void> loadHistory() async {
    setState(() {
      loadingHistory = true;
      historyError = null;
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
          recent = all.take(4).toList();
        });
      } else {
        setState(() {
          historyError =
              (data is Map ? data['detail'] : null)?.toString() ??
              'could not load transactions';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        historyError = 'could not reach the server';
      });
    } finally {
      if (mounted) {
        setState(() {
          loadingHistory = false;
        });
      }
    }
  }

  Future<void> loadBalance() async {
    setState(() {
      loadingBalance = true;
      balanceError = null;
    });
    try {
      final data = await ApiService.getBalance();
      if (!mounted) return;
      setState(() {
        if (data['balance'] != null) {
          balance = double.tryParse(data['balance'].toString());
          accountId = data['account_id'];
        } else {
          balanceError = data['detail'] ?? 'could not load the balance';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        balanceError = 'Could not reach the server';
      });
    } finally {
      if (mounted) {
        setState(() {
          loadingBalance = false;
        });
      }
    }
  }

  Future<void> onLogout() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('You will need to login again'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      Session.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.green),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    //final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: Text(
          'Welcome Back!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.screenBackground,
        actions: [
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height / 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.background,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      loadingBalance
                          ? '...'
                          : (balance == null
                                ? '--'
                                : '₹${balance!.toStringAsFixed(2)}'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Account ID: ${accountId ?? '-'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.background,
                      ),
                    ),

                    if (balanceError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                balanceError!,
                                style: const TextStyle(
                                  color: Color(0xFFA12626),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: loadBalance,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.arrow_forward, 'Send', () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SendMoneyScreen(availableBalance: balance ?? 0),
                    ),
                  );

                  if (!mounted) return;
                  await loadBalance();
                  await loadHistory();
                }),
                _actionButton(Icons.history, 'History', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                }),
                _actionButton(Icons.replay, 'Refund', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(refundOnly: true),
                    ),
                  );
                  if (!mounted) true;
                  loadBalance();
                  loadHistory();
                }),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Recent transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: loadingHistory
                  ? CircularProgressIndicator()
                  : historyError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            historyError!,
                            style: const TextStyle(color: Color(0xFFA12626)),
                          ),
                          TextButton(
                            onPressed: loadHistory,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : recent.isEmpty
                  ? const Center(child: Text('No transactions yet'))
                  : ListView.builder(
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(transaction: recent[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
