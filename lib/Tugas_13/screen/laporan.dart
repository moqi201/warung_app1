import 'package:flutter/material.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import '../Database/db_helper.dart';

class LaporanScreen extends StatefulWidget {
  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  List<Product> products = [];
  final DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getAllProducts();
    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan Produk')),
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
              onTap:
                  () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Laporan'),
              onTap: () => Navigator.pushReplacementNamed(context, '/laporan'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Harga')),
            DataColumn(label: Text('Stok')),
          ],
          rows:
              products
                  .map(
                    (product) => DataRow(
                      cells: [
                        DataCell(Text(product.name)),
                        DataCell(Text('Rp${product.price}')),
                        DataCell(Text('${product.stock}')),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
