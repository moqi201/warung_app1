// lib/Tugas_13/screen/laporan_pembayaran.dart (Nama file bisa diubah agar lebih spesifik)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_app1/Tugas_13/database/db_helper.dart';
import 'package:warung_app1/Tugas_13/model/transaction.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = DbHelper().getAllTransactions();
  }

  // --- Widget Helper untuk Format Mata Uang ---
  Widget _buildCurrencyText(double amount, {TextStyle? style}) {
    return Text(
      NumberFormat.currency(
        locale: 'id_ID', // Untuk format Indonesia (Rp, pemisah titik)
        symbol: 'Rp',
        decimalDigits: 0, // Tidak ada digit desimal
      ).format(amount),
      style:
          style ??
          const TextStyle(
            color: Colors.black87, // Default warna jika tidak dispesifikasikan
            fontSize: 15,
          ),
    );
  }
  // --- Akhir Widget Helper ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang umum aplikasi
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi', // Judul yang lebih deskriptif
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Warna teks putih
          ),
        ),
        backgroundColor: Colors.blueAccent, // Warna AppBar yang menarik
        elevation: 0, // Hilangkan bayangan di bawah AppBar
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Warna ikon AppBar
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
            ), // Ikon refresh yang lebih modern
            tooltip: 'Refresh Data', // Tooltip untuk aksesibilitas
            onPressed: () {
              setState(() {
                _loadTransactions(); // Muat ulang transaksi
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                    const SizedBox(height: 10),
                    Text(
                      'Oops! Terjadi kesalahan: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red[700]),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _loadTransactions()),
                      icon: const Icon(Icons.replay),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined, // Ikon lebih relevan untuk riwayat
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada riwayat transaksi.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Lakukan transaksi untuk melihat laporannya di sini!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isSuccess = transaction.status == 'Success';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation:
                      6, // Elevasi yang sedikit lebih tinggi untuk kesan "floating"
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Sudut yang lebih membulat
                  ),
                  clipBehavior:
                      Clip.antiAlias, // Memastikan konten terpotong rapi
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        // Efek gradasi pada background card
                        colors:
                            isSuccess
                                ? [
                                  Colors.teal.shade50,
                                  Colors.teal.shade100,
                                ] // Gradasi hijau-biru untuk sukses
                                : [
                                  Colors.deepOrange.shade50,
                                  Colors.deepOrange.shade100,
                                ], // Gradasi oranye-merah untuk gagal
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        18.0,
                      ), // Padding yang sedikit lebih besar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transaksi ID: ${transaction.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.blueGrey[800], // Warna teks ID
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSuccess
                                          ? Colors.green[500]
                                          : Colors
                                              .red[500], // Warna status yang jelas
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  transaction.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal: ${DateFormat('EEEE, dd MMMM yyyy HH:mm').format(transaction.transactionDate)}', // Format tanggal lebih lengkap
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Detail Item:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 10,
                            thickness: 0.5,
                          ), // Divider lebih halus
                          ...transaction.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} (${item.product.brand})',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  _buildCurrencyText(
                                    item.itemPrice,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ' x ${item.quantity} = ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  _buildCurrencyText(
                                    item.subtotal,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Colors
                                              .blue, // Warna subtotal per item
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 10,
                            thickness: 0.5,
                          ),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total Pembayaran:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                _buildCurrencyText(
                                  transaction.totalAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        22, // Ukuran font lebih besar untuk total
                                    color:
                                        Colors
                                            .deepPurple[700], // Warna yang lebih menonjol
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
