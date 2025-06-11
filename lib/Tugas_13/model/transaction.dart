// lib/Tugas_13/model/transaction_model.dart
import 'product.dart';

class TransactionItem {
  final Product product;
  final int quantity;
  final double itemPrice;

  TransactionItem({
    required this.product,
    required this.quantity,
    required this.itemPrice,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map, Product product) {
    return TransactionItem(
      product: product,
      quantity: (map['quantity'] as num).toInt(), // Pastikan ini ada
      itemPrice: (map['itemPrice'] as num).toDouble(), // Pastikan ini ada
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'itemPrice': itemPrice,
    };
  }

  double get subtotal => quantity * itemPrice;
}

class Transaction {
  int? id;
  final DateTime transactionDate;
  final List<TransactionItem> items;
  final double totalAmount;
  final String status;

  Transaction({
    this.id,
    required this.transactionDate,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  factory Transaction.fromMap(
    Map<String, dynamic> map,
    List<TransactionItem> transactionItems,
  ) {
    return Transaction(
      id: map['id'] as int?,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      items: transactionItems,
      totalAmount: (map['totalAmount'] as num).toDouble(), // Pastikan ini ada
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionDate': transactionDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
