// lib/Tugas_13/model/cart_state.dart
import 'package:flutter/material.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';

import 'cart_item.dart';
import 'product.dart';

class CartState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();

  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList();

  CartState() {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    _items = await _dbHelper.getCartItems();
    notifyListeners();
  }

  Future<void> addToCart(Product product, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      _items[index].quantity += quantity;
      _items[index].isSelected = true;
      await _dbHelper.updateCartItem(_items[index]);
    } else {
      final cartItem = CartItem(
        product: product,
        quantity: quantity,
        isSelected: true,
      );
      _items.add(cartItem);
      await _dbHelper.insertCartItem(cartItem);
    }
    notifyListeners(); // Panggil notifyListeners() setelah perubahan data
  }

  Future<void> removeItem(CartItem item) async {
    _items.remove(item);
    await _dbHelper.deleteCartItem(item.product.id!);
    notifyListeners(); // Panggil notifyListeners() setelah perubahan data
  }

  Future<void> updateItemQuantity(CartItem item, int newQuantity) async {
    final index = _items.indexOf(item);
    if (index != -1) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
        // PENTING: Panggil notifyListeners() DI SINI setelah update ke DB
        await _dbHelper.updateCartItem(_items[index]);
      } else {
        // Jika kuantitas menjadi 0 atau kurang, hapus item
        // Fungsi removeItem sudah memanggil notifyListeners()
        await removeItem(item);
      }
      // Pastikan notifyListeners() dipanggil terlepas dari apakah item dihapus atau hanya kuantitas diperbarui
      notifyListeners();
    }
  }

  void toggleItemSelection(CartItem item) {
    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void toggleAllItemsSelection(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _dbHelper.clearCart();
    notifyListeners();
  }

  double get totalSelected {
    return _items.fold(
      0,
      (sum, item) => sum + (item.isSelected ? item.totalPrice : 0),
    );
  }
}
