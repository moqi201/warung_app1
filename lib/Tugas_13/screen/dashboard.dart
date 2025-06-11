import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Product> products = [];
  final DbHelper dbHelper = DbHelper();
  // Using a ValueNotifier to update the image in the dialog without rebuilding the whole dialog
  // This is a more efficient way than using setState inside showDialog
  final ValueNotifier<File?> _localImageNotifier = ValueNotifier<File?>(null);

  @override
  void initState() {
    super.initState();
    refreshProducts();
  }

  @override
  void dispose() {
    _localImageNotifier
        .dispose(); // Dispose the notifier when the state is removed
    super.dispose();
  }

  void refreshProducts() async {
    final data = await dbHelper.getAllProducts();
    setState(() => products = data);
  }

  void showForm([Product? product]) {
    final nameController = TextEditingController(text: product?.name);
    final brandController = TextEditingController(text: product?.brand);
    final priceController = TextEditingController(
      text: product?.price != null ? product!.price.toString() : '',
    );
    final stockController = TextEditingController(
      text: product?.stock != null ? product!.stock.toString() : '',
    );

    // Initialize the notifier with the existing product image or null
    _localImageNotifier.value =
        product?.image != null ? File(product!.image!) : null;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              product == null ? 'Add New Product' : 'Edit Product',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make column wrap its content
                children: [
                  // Image Picker Area
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality:
                            70, // Compress image for better performance
                      );
                      if (picked != null) {
                        _localImageNotifier.value = File(
                          picked.path,
                        ); // Update notifier's value
                      }
                    },
                    child: ValueListenableBuilder<File?>(
                      valueListenable: _localImageNotifier,
                      builder: (context, currentImage, child) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Rounded corners for image area
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          child:
                              currentImage != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      13,
                                    ), // Slightly smaller for inner image
                                    child: Image.file(
                                      currentImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                  )
                                  : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap to add image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing after image
                  // Text Fields
                  _buildTextField(
                    nameController,
                    'Product Name',
                    Icons.label_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(brandController, 'Brand', Icons.copyright),
                  const SizedBox(height: 10),
                  _buildTextField(
                    priceController,
                    'Price (Rp)',
                    Icons.attach_money,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    stockController,
                    'Stock',
                    Icons.inventory_2_outlined,
                    TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(product == null ? 'Add Product' : 'Save Changes'),
                onPressed: () async {
                  try {
                    final prod = Product(
                      id: product?.id,
                      name: nameController.text.trim(), // Trim whitespace
                      brand: brandController.text.trim(),
                      price: int.tryParse(priceController.text.trim()) ?? 0,
                      stock: int.tryParse(stockController.text.trim()) ?? 0,
                      image:
                          _localImageNotifier
                              .value
                              ?.path, // Get path from notifier
                    );

                    if (prod.name.isEmpty ||
                        prod.brand.isEmpty ||
                        prod.price <= 0) {
                      // Show a simple snackbar for validation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all required fields (Name, Brand, Price) correctly.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (product == null) {
                      await dbHelper.insertProduct(prod);
                      // Show success feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product added successfully!'),
                        ),
                      );
                    } else {
                      await dbHelper.updateProduct(prod);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product updated successfully!'),
                        ),
                      );
                    }

                    Navigator.pop(context);
                    refreshProducts();
                  } catch (e) {
                    print("Failed to save product: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'An error occurred while saving the product.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Helper widget for consistent TextField styling
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // Function to show a confirmation dialog for deletion
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                deleteProduct(id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully!'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
    refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Management', // Clearer title for a dashboard
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Admin Panel', // More fitting for a dashboard drawer
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your products',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store_outlined), // Changed icon
              title: const Text('Home'), // More descriptive
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: Colors.blue),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined), // Changed icon
              title: const Text('Laporam'), // More descriptive
              onTap: () => Navigator.pushReplacementNamed(context, '/laporan'),
            ),
            const Divider(),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Stretch children horizontally
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Products: ${products.length}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center, // Center the text
            ),
          ),
          products.isEmpty
              ? Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No products managed yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const Text(
                        'Tap the "+" button to add your first product!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners for cards
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Brand : ${p.brand}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp',
                                      decimalDigits: 0,
                                    ).format(p.price),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons (Edit & Delete)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.lightBlue,
                                  ),
                                  tooltip: 'Edit Product',
                                  onPressed: () => showForm(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Delete Product',
                                  onPressed:
                                      () => _confirmDelete(
                                        p.id!,
                                      ), // Use confirmation dialog
                                ),
                              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showForm(),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent, // Vibrant color
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape for FAB
        ),
        elevation: 6, // More prominent shadow
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }
}
