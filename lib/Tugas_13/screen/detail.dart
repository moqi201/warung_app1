import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warung_app1/Tugas_13/model/cart_state.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  String generateLorem(String base) {
    final seed = base.codeUnits.fold(0, (sum, char) => sum + char);
    final samples = [
      "Experience seamless performance with the new [Product Name]. Its powerful processor handles all your tasks with ease, from gaming to multitasking. The vibrant display brings your content to life, offering stunning visuals and immersive viewing.",
      "Capture every moment in breathtaking detail with the advanced camera system of the [Product Name]. Equipped with intelligent features, it lets you shoot professional-grade photos and videos effortlessly. Long-lasting battery ensures you stay connected all day.",
      "Designed for the modern user, the [Product Name] combines elegant aesthetics with robust functionality. Enjoy crystal-clear audio and a comfortable grip, making it a joy to hold and use. Stay productive and entertained wherever you go.",
      "Unleash your creativity with the [Product Name]'s intuitive interface and expansive storage. Download your favorite apps, store countless photos, and enjoy high-definition media without compromise. A truly smart companion for your daily adventures.",
      "The [Product Name] redefines mobile technology with its innovative features and superior craftsmanship. From its edge-to-edge display to its lightning-fast connectivity, every aspect is engineered for an unparalleled user experience. Embrace the future of communication.",
    ];
    return samples[seed % samples.length].replaceAll(
      '[Product Name]',
      product.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loremDescription = generateLorem(product.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share_outlined, color: Colors.blueAccent),
        //     onPressed: () {
        //       // Tambahkan fungsi share jika dibutuhkan
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Produk
            Hero(
              tag: 'image_${product.id}',
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[100],
                child:
                    product.image != null && File(product.image!).existsSync()
                        ? Image.file(
                          File(product.image!),
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No image uploaded',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
              ),
            ),

            // Detail Produk
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(product.price),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: Colors.blueGrey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${product.stock} units',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _buildStockStatusChip(product.stock),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loremDescription,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      // Tombol Bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showQuantityDialog(
                    context,
                    product,
                  ); // Panggil dialog kuantitas
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 5,
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // InkWell(
            //   onTap: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Added to Favorites!')),
            //     );
            //   },
            //   customBorder: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: Colors.grey.shade300),
            //       color: Colors.white,
            //     ),
            //     child: const Icon(
            //       Icons.favorite_border,
            //       color: Colors.redAccent,
            //       size: 28,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusChip(int stock) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    if (stock <= 0) {
      chipColor = Colors.grey;
      statusText = 'Out of Stock';
      statusIcon = Icons.cancel;
    } else if (stock <= 10) {
      chipColor = Colors.redAccent;
      statusText = 'Low Stock';
      statusIcon = Icons.warning_amber;
    } else if (stock <= 50) {
      chipColor = Colors.orangeAccent;
      statusText = 'Medium Stock';
      statusIcon = Icons.info_outline;
    } else {
      chipColor = Colors.green;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle_outline;
    }

    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 18),
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Fungsi untuk menampilkan dialog pemilihan kuantitas
  void _showQuantityDialog(BuildContext context, Product product) {
    int selectedQuantity = 1; // Kuantitas awal

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih Kuantitas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Produk: ${product.name}'),
                  Text(
                    NumberFormat.currency(
                      locale:
                          'id_ID', // Untuk format Indonesia (Rp, pemisah titik)
                      symbol: 'Rp',
                      decimalDigits: 0, // Tidak ada digit desimal
                    ).format(product.price),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setState(() {
                              selectedQuantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        selectedQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (selectedQuantity < product.stock) {
                            // Batasi hingga stok yang tersedia
                            setState(() {
                              selectedQuantity++;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stok tidak mencukupi!'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Text(
                  //   'Total: Rp${(product.price * selectedQuantity).toStringAsFixed(0)}',
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  Text(
                    NumberFormat.currency(
                      locale:
                          'id_ID', // Untuk format Indonesia (Rp, pemisah titik)
                      symbol: 'Rp',
                      decimalDigits: 0, // Tidak ada digit desimal
                    ).format(product.price * selectedQuantity),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan ke keranjang dengan kuantitas yang dipilih
                    Provider.of<CartState>(
                      context,
                      listen: false,
                    ).addToCart(product, selectedQuantity);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} (${selectedQuantity}x) ditambahkan ke keranjang!',
                        ),
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Tambah ke Keranjang'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Widget _buildCurrencyText(double amount, {TextStyle? style}) {
  return Text(
    NumberFormat.currency(
      locale: 'id_ID', // Untuk format Indonesia (Rp, pemisah titik)
      symbol: 'Rp',
      decimalDigits: 0, // Tidak ada digit desimal
    ).format(amount),
    style:
        style ??
        TextStyle(
          color: Colors.green[700],
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ), // Default style jika tidak diberikan
  );
}
