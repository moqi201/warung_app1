import 'dart:io'; // Required for File operations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import 'package:warung_app1/Tugas_13/screen/detail.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "/cart";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DbHelper dbHelper = DbHelper();
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
    // Listen for changes in the search input
    searchController.addListener(() {
      searchProducts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    final data = await dbHelper.getAllProducts();
    setState(() {
      products = data;
      // Filter immediately after loading, if there's a search query
      searchProducts(searchController.text);
    });
  }

  void searchProducts(String query) {
    final results =
        products.where((product) {
          final nameMatch = product.name.toLowerCase().contains(
            query.toLowerCase(),
          );
          final brandMatch = product.brand.toLowerCase().contains(
            query.toLowerCase(),
          ); // Search by brand too
          final priceMatch = product.price.toString().contains(
            query,
          ); // Price as string contains query
          return nameMatch || brandMatch || priceMatch;
        }).toList();

    setState(() {
      filteredProducts = results;
    });
  }

  // Helper function to get stock status color
  Color getStockColor(int stock) {
    if (stock <= 10) {
      return Colors.red.shade700;
    } else if (stock <= 50) {
      return Colors.orange.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  // Helper function to get stock status background color
  Color getStockBackgroundColor(int stock) {
    if (stock <= 10) {
      return Colors.red.shade100;
    } else if (stock <= 50) {
      return Colors.orange.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Hapus status login
    await prefs.clear(); // atau prefs.remove('isLoggedIn');

    // Arahkan ke login page dan hapus semua halaman sebelumnya
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MobileStore', // More generic e-commerce name
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent, // A more vibrant AppBar color
        elevation: 0, // Remove shadow for a flat design
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Drawer icon color
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.shopping_cart_outlined,
        //     ), // Example action button
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/cart');
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove default padding
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'MobileStore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your One-Stop Shop for Mobiles',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.blueAccent,
              ),
              title: const Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap:
                  () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined), // Changed icon
              title: const Text(
                'Laporan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pushReplacementNamed(context, '/laporan'),
            ),
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ), // Ikon logout
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () async {
                              // Logout logic (contoh dengan SharedPreferences)
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear(); // Hapus semua data login

                              // Kembali ke halaman login, hapus semua route sebelumnya
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/Login',
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
            ), // Add a divider for better separation
          ],
        ),
      ),
      body: Column(
        children: [
          // // 🔍 Search Bar
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: searchController,
          //     decoration: InputDecoration(
          //       hintText: 'Search for phones, brands, or prices...',
          //       prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          //       suffixIcon:
          //           searchController.text.isNotEmpty
          //               ? IconButton(
          //                 icon: const Icon(Icons.clear, color: Colors.grey),
          //                 onPressed: () {
          //                   searchController.clear();
          //                   searchProducts(''); // Clear search results
          //                   FocusScope.of(
          //                     context,
          //                   ).unfocus(); // Dismiss keyboard
          //                 },
          //               )
          //               : null,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(
          //           30,
          //         ), // More rounded corners
          //         borderSide: BorderSide.none, // No border line
          //       ),
          //       filled: true,
          //       fillColor: Colors.grey[100], // Light grey background
          //       contentPadding: const EdgeInsets.symmetric(
          //         vertical: 15,
          //         horizontal: 20,
          //       ),
          //     ),
          //   ),
          // ),
          // Conditional Display: Empty State vs. Product Grid
          Expanded(
            child:
                filteredProducts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phonelink_off_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'No products available yet.'
                                : 'No results found for "${searchController.text}".',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchController.text.isEmpty
                                ? 'Stay tuned for new arrivals!'
                                : 'Try adjusting your search or check back later!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  searchController.clear();
                                  searchProducts('');
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Show All Products'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: loadProducts, // Enable pull-to-refresh
                      color: Colors.blueAccent,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16, // Increased spacing
                              mainAxisSpacing: 16, // Increased spacing
                              childAspectRatio:
                                  0.7, // Adjusted for better card proportion
                            ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DetailScreen(product: product),
                                ),
                              ).then(
                                (_) =>
                                    loadProducts(), // Reload products if returning from detail
                              );
                            },
                            child: Card(
                              elevation: 5, // More prominent shadow for cards
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // Rounded card corners
                              ),
                              clipBehavior:
                                  Clip.antiAlias, // Ensures content respects card shape
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Product Image
                                  Expanded(
                                    flex: 3, // Image takes up more space
                                    child: Hero(
                                      tag: 'image_${product.id}',
                                      child:
                                          product.image != null &&
                                                  File(
                                                    product.image!,
                                                  ).existsSync()
                                              ? Image.file(
                                                File(product.image!),
                                                fit:
                                                    BoxFit
                                                        .cover, // Ensures image fills the space
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Center(
                                                      child: Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 40,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                              )
                                              : Center(
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                    ),
                                  ),
                                  // Product Details (Text)
                                  Expanded(
                                    flex: 2, // Text content takes less space
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10.0,
                                        8.0,
                                        10.0,
                                        4.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            maxLines:
                                                2, // Limit to 2 lines for long names
                                            overflow:
                                                TextOverflow
                                                    .ellipsis, // Add ellipsis if name is too long
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.brand,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                NumberFormat.currency(
                                                  locale:
                                                      'id_ID', // For Indonesia format (Rp, dot separator)
                                                  symbol: 'Rp',
                                                  decimalDigits:
                                                      0, // No decimal digits
                                                ).format(product.price),
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      getStockBackgroundColor(
                                                        product.stock,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  'Stock: ${product.stock}',
                                                  style: TextStyle(
                                                    color: getStockColor(
                                                      product.stock,
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
          ),
        ],
      ),
    );
  }
}
