// lib/Tugas_13/model/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSelected; // Tambahkan properti ini

  CartItem({
    required this.product,
    required this.quantity,
    this.isSelected = true,
  }); // Default true

  double get totalPrice => (product.price * quantity).toDouble();
}
