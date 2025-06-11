// lib/Tugas_13/screen/laporan.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_app1/Tugas_13/Database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import 'package:warung_app1/Tugas_13/model/transaction.dart';
// Import the transaction model

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  List<Product> products = [];
  List<Transaction> transactions = []; // To store all transactions
  final DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final productData = await dbHelper.getAllProducts();
    final transactionData = await dbHelper.getAllTransactions();
    setState(() {
      products = productData;
      // Explicitly cast transactionData to List<Transaction>
      transactions = List<Transaction>.from(transactionData);
    });
  }

  // Helper function to get color for stock level background
  Color getStockBackgroundColor(int stock) {
    if (stock <= 10) {
      return Colors.red.shade50; // Lighter shade for background
    } else if (stock <= 50) {
      return Colors.orange.shade50;
    } else {
      return Colors.green.shade50;
    }
  }

  // Helper function to get color for stock level text
  Color getStockTextColor(int stock) {
    if (stock <= 10) {
      return Colors.red.shade700; // Darker shade for text
    } else if (stock <= 50) {
      return Colors.orange.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate summary statistics for Products
    int totalProductsCount = products.length; // Total unique products
    int totalCurrentStock = products.fold(
      0,
      (sum, product) => sum + product.stock,
    );
    double totalCurrentStockValue = products.fold(
      0.0,
      (sum, product) => sum + (product.price * product.stock),
    );

    // Calculate summary statistics from Transactions
    int totalProductsSold = 0;
    double totalRevenue = 0.0;

    for (var transaction in transactions) {
      // Only count successful transactions for sales reports
      if (transaction.status == 'Success') {
        for (var item in transaction.items) {
          totalProductsSold += item.quantity;
          totalRevenue += item.subtotal;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Reports', // Clearer title
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent, // Consistent app bar color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Consistent drawer header color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Overview and Analytics',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap:
                  () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.blue,
              ),
              title: const Text('Laporan'),
              onTap: () => Navigator.pop(context), // Already on reports screen
            ),
            const Divider(),
          ],
        ),
      ),
      body:
          products.isEmpty && transactions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No report data available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const Text(
                      'Add products or make transactions to see reports here!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Summary Section
                  Container(
                    padding: const EdgeInsets.all(
                      20.0,
                    ), // Padding yang sedikit lebih besar
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ), // Margin di samping dan vertikal
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .white, // Latar belakang putih agar lebih bersih
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        // Menambahkan bayangan untuk efek elevasi
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(
                            0.1,
                          ), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4), // Posisi bayangan
                        ),
                      ],
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(
                          0.2,
                        ), // Border yang lebih halus
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Products',
                          totalProductsCount.toString(),
                          Icons.category,
                        ),
                        const Divider(
                          height: 20,
                          thickness: 1,
                          color: Colors.grey,
                        ), // Warna divider
                        _buildSummaryRow(
                          'Total Current Stock',
                          totalCurrentStock.toString(),
                          Icons.inventory_2_outlined,
                        ),
                        _buildSummaryRow(
                          'Total Current Stock Value',
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(totalCurrentStockValue),
                          Icons.paid_outlined,
                        ),
                        const Divider(
                          height: 20,
                          thickness: 1,
                          color: Colors.grey,
                        ), // Separator for sales data
                        _buildSummaryRow(
                          'Total Products Sold',
                          totalProductsSold.toString(),
                          Icons.shopping_cart_outlined,
                        ),
                        _buildSummaryRow(
                          'Total Revenue',
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(totalRevenue),
                          Icons.money_outlined,
                        ),
                      ],
                    ),
                  ),
                  // Product List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'Product Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors
                                      .black87, // Warna lebih gelap untuk header
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const Expanded(
                          flex: 1, // Stok flex 1 agar proporsional
                          child: Text(
                            'Stock',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey, // Warna divider header
                  ),
                  // Product List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];
                        return Card(
                          elevation: 2, // Lighter elevation for list items
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center, // Pusatkan secara vertikal
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        product.brand,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp',
                                        decimalDigits: 0,
                                      ).format(product.price),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2, // Stok flex 1 agar proporsional
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStockBackgroundColor(
                                          product.stock,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${product.stock}',
                                        style: TextStyle(
                                          color: getStockTextColor(
                                            product.stock,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  // Helper widget to build summary rows (moved here for better organization and direct use)
  Widget _buildSummaryRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Jarak vertikal antar baris
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blueAccent, // Warna ikon agar seragam
            size: 24,
          ),
          const SizedBox(width: 12), // Jarak antara ikon dan teks
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500, // Sedikit lebih tebal dari normal
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17, // Ukuran font nilai sedikit lebih besar
              fontWeight: FontWeight.bold, // Nilai lebih tebal
              color: Colors.blueAccent, // Warna menonjol untuk nilai
            ),
          ),
        ],
      ),
    );
  }
}
