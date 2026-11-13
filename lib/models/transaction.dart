String _formatDate(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(1, '0');
  final ampm = d.hour > 12 ? 'PM' : 'AM';
  return '${d.day} ${months[d.month - 1]},$hour:$minute $ampm';
}

class Transaction {
  final int id;
  final String name;
  final String date;
  final String amount;
  final String status;
  final double amountValue;
  final double refundedValue;
  final bool recieved;

  const Transaction({
    required this.id,
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
    this.amountValue = 0,
    this.refundedValue = 0,
    this.recieved = false,
  });
  bool get canRefund =>
      recieved &&
      (status == 'completed' || status == 'partially_refunded') &&
      amountValue - refundedValue > 0;

  factory Transaction.fromJson(Map<String, dynamic> json, String myEmail) {
    final from = json['from'].toString();
    final to = json['to'].toString();
    final received = to.toLowerCase() == myEmail.toLowerCase();
    final value = double.tryParse(json['amount'].toString()) ?? 0;

    return Transaction(
      id: json['transfer_id'] as int,
      name: received ? from : to,
      date: _formatDate(json['date']?.toString()),
      amount: '${received ? '+' : '-'} ₹${value.toStringAsFixed(2)}',
      status: json['status'].toString(),
      amountValue: value,
      refundedValue: double.tryParse(json['refunded'].toString()) ?? 0,
      recieved: received,
    );
  }
}
