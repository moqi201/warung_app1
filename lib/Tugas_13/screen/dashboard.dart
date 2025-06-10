import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Database/db_helper.dart';
import '../model/product.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Product> products = [];
  final DbHelper dbHelper = DbHelper();
  File? localImage;

  @override
  void initState() {
    super.initState();
    refreshProducts();
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

    localImage = product?.image != null ? File(product!.image!) : null;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked != null) {
                        setState(() {
                          localImage = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child:
                          localImage != null
                              ? Image.file(localImage!, fit: BoxFit.cover)
                              : Center(child: Text('Pilih Gambar')),
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(labelText: 'Brand'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Harga'),
                  ),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Stok'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Simpan'),
                onPressed: () async {
                  try {
                    final prod = Product(
                      id: product?.id,
                      name: nameController.text,
                      brand: brandController.text,
                      price: int.tryParse(priceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      image: localImage?.path,
                    );

                    if (product == null) {
                      await dbHelper.insertProduct(prod);
                    } else {
                      await dbHelper.updateProduct(prod);
                    }

                    Navigator.pop(context);
                    refreshProducts();
                  } catch (e) {
                    print("Gagal menyimpan: $e");
                  }
                },
              ),
            ],
          ),
    );
  }

  void deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
    refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Toko HP',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Laporan'),
              onTap: () => Navigator.pushReplacementNamed(context, '/laporan'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Produk: ${products.length}',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text("Rp${p.price} - Stok: ${p.stock}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showForm(p),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteProduct(p.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
