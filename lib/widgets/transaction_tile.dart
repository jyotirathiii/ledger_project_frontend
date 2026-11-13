import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/models/transaction.dart';
import 'package:ledger_project/widgets/status_badge.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE4EFEA),
        child: Text(
          transaction.name[0],
          style: TextStyle(color: AppColors.green),
        ),
      ),
      title: Text(
        transaction.name,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(transaction.date),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transaction.amount,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          StatusBadge(status: transaction.status),
        ],
      ),
    );
  }
}
