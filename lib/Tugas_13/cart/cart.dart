// lib/Tugas_13/screens/cart_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/cart_item.dart';
import 'package:warung_app1/Tugas_13/model/cart_state.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import 'package:warung_app1/Tugas_13/model/transaction.dart';
import 'package:warung_app1/Tugas_13/screen/transaction.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Define a soft color palette
  static const Color primarySoft = Color(0xFF81C784); // Light Green
  static const Color accentSoft = Color(0xFF64B5F6); // Light Blue
  static const Color backgroundSoft = Color(0xFFF0F4F8); // Off-white/Light Grey
  static const Color cardSoft = Color(0xFFFFFFFF); // White
  static const Color textDark = Color(0xFF37474F); // Dark Grey Blue
  static const Color textMedium = Color(0xFF78909C); // Medium Grey Blue
  static const Color successGreen = Color(
    0xFF4CAF50,
  ); // Standard Green for success
  static const Color warningOrange = Color(
    0xFFFFB74D,
  ); // Light Orange for warning
  static const Color errorRed = Color(0xFFEF5350); // Light Red for error

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
          ),
          content: Text(
            'Total yang harus dibayar: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(Provider.of<CartState>(context, listen: false).totalSelected)}',
            style: const TextStyle(fontSize: 16, color: textMedium),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _processCheckout(status: 'Cancelled'); // Process as cancelled
              },
              style: TextButton.styleFrom(
                foregroundColor: errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _processCheckout(status: 'Success'); // Process as success
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySoft,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCheckout({required String status}) async {
    final cartState = Provider.of<CartState>(context, listen: false);
    final selectedItems = List<CartItem>.from(cartState.selectedItems);
    final dbHelper = DbHelper();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada item yang dipilih untuk diproses!'),
          backgroundColor: warningOrange,
        ),
      );
      return;
    }

    if (status == 'Success') {
      bool allStocksAvailable = true;
      for (var item in selectedItems) {
        final currentProductInDB = await dbHelper.getProductById(
          item.product.id!,
        );
        if (currentProductInDB == null ||
            currentProductInDB.stock < item.quantity) {
          allStocksAvailable = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stok ${item.product.name} tidak mencukupi atau tidak tersedia!',
              ),
              backgroundColor: errorRed,
            ),
          );
          break;
        }
      }

      if (!allStocksAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran dibatalkan karena stok tidak mencukupi.'),
            backgroundColor: errorRed,
          ),
        );
        status = 'Cancelled';
      }
    }

    List<TransactionItem> transactionItems =
        selectedItems.map((cartItem) {
          return TransactionItem(
            product: cartItem.product,
            quantity: cartItem.quantity,
            itemPrice: cartItem.product.price.toDouble(),
          );
        }).toList();

    final newTransaction = Transaction(
      transactionDate: DateTime.now(),
      items: transactionItems,
      totalAmount: cartState.totalSelected,
      status: status,
    );

    await dbHelper.insertTransaction(newTransaction);

    if (status == 'Success') {
      for (var item in selectedItems) {
        final newStock = item.product.stock - item.quantity;
        final updatedProduct = Product(
          id: item.product.id,
          name: item.product.name,
          brand: item.product.brand,
          price: item.product.price,
          stock: newStock,
          image: item.product.image,
        );
        await dbHelper.updateProduct(updatedProduct);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembelian item terpilih berhasil!'),
          backgroundColor: successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran dibatalkan.'),
          backgroundColor: warningOrange,
        ),
      );
    }

    for (var item in selectedItems) {
      await cartState.removeItem(item);
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSoft, // Apply soft background color
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textDark, // Darker text for app bar title
          ),
        ),
        backgroundColor: cardSoft, // White app bar for a clean look
        elevation: 1, // Subtle shadow
        iconTheme: const IconThemeData(color: textDark), // Dark icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.history), // Ikon untuk riwayat transaksi
            tooltip: 'Riwayat Transaksi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartState>(
        builder: (context, cartState, child) {
          final items = cartState.items;
          final allItemsSelected =
              items.isNotEmpty && items.every((item) => item.isSelected);

          if (items.isEmpty) {
            return Center(
              child: Text(
                'Keranjang kosong, ayo belanja!',
                style: TextStyle(fontSize: 18, color: textMedium),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: allItemsSelected,
                      onChanged: (bool? newValue) {
                        cartState.toggleAllItemsSelection(newValue ?? false);
                      },
                      activeColor:
                          primarySoft, // Soft primary color for checkbox
                    ),
                    const Text(
                      'Pilih Semua',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.black12,
              ), // Lighter divider
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      elevation: 2, // Subtle elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ), // Rounded corners
                      color: cardSoft, // White card background
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: item.isSelected,
                              onChanged: (bool? newValue) {
                                cartState.toggleItemSelection(item);
                              },
                              activeColor: primarySoft,
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // More rounded image
                                color:
                                    backgroundSoft, // Soft background for image placeholder
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              child:
                                  item.product.image != null &&
                                          File(item.product.image!).existsSync()
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(item.product.image!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Icon(
                                        Icons.image_not_supported,
                                        color: textMedium.withOpacity(
                                          0.5,
                                        ), // Muted icon color
                                        size: 40,
                                      ),
                            ),
                            const SizedBox(width: 15), // Increased spacing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17, // Slightly larger font
                                      color: textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Brand: ${item.product.brand}',
                                    style: const TextStyle(
                                      color: textMedium,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp',
                                      decimalDigits: 0,
                                    ).format(item.product.price),
                                    style: TextStyle(
                                      color:
                                          primarySoft, // Price in primary soft color
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8.0,
                                      top: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color:
                                                    item.isSelected
                                                        ? accentSoft
                                                        : textMedium.withOpacity(
                                                          0.5,
                                                        ), // Muted when not selected
                                              ),
                                              onPressed:
                                                  item.isSelected
                                                      ? () {
                                                        if (item.quantity > 1) {
                                                          cartState
                                                              .updateItemQuantity(
                                                                item,
                                                                item.quantity -
                                                                    1,
                                                              );
                                                        } else {
                                                          cartState.removeItem(
                                                            item,
                                                          );
                                                        }
                                                      }
                                                      : null,
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textDark,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color:
                                                    item.isSelected
                                                        ? accentSoft
                                                        : textMedium
                                                            .withOpacity(0.5),
                                              ),
                                              onPressed:
                                                  item.isSelected
                                                      ? () async {
                                                        // Fetch current stock from DB before adding
                                                        final dbHelper =
                                                            DbHelper();
                                                        final currentProductInDB =
                                                            await dbHelper
                                                                .getProductById(
                                                                  item
                                                                      .product
                                                                      .id!,
                                                                );
                                                        if (currentProductInDB !=
                                                                null &&
                                                            item.quantity <
                                                                currentProductInDB
                                                                    .stock) {
                                                          cartState
                                                              .updateItemQuantity(
                                                                item,
                                                                item.quantity +
                                                                    1,
                                                              );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Stok tidak mencukupi!',
                                                              ),
                                                              backgroundColor:
                                                                  warningOrange,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                      : null,
                                            ),
                                          ],
                                        ),
                                        Flexible(
                                          child: Text(
                                            NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: 'Rp',
                                              decimalDigits: 0,
                                            ).format(item.totalPrice),
                                            style: TextStyle(
                                              color:
                                                  successGreen, // Total price in success green
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: errorRed),
                              onPressed: () {
                                cartState.removeItem(item);
                              },
                              tooltip: 'Hapus dari Keranjang',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardSoft,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ), // Rounded top corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, -3), // Shadow at the top
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL BELANJA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textMedium,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(cartState.totalSelected),
                          style: const TextStyle(
                            color: successGreen,
                            fontSize: 24, // Larger for total amount
                            fontWeight: FontWeight.w800, // Extra bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          cartState.selectedItems.isEmpty
                              ? null
                              : () => _showCheckoutDialog(context),
                      icon: const Icon(
                        Icons.payment_outlined,
                      ), // Outlined icon for modern look
                      label: const Text(
                        'Bayar Sekarang',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primarySoft,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // More rounded button
                        ),
                        elevation: 5, // Add a subtle shadow to the button
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
