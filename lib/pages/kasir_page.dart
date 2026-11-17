// Mengimpor antarmuka Flutter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk.dart';
import '../helpers/database_helper.dart';

// Halaman Tab 1: Transaksi Kasir POS
class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  late Future<List<Produk>> _produkFuture;

  String _formatRupiah(double nominal) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(nominal);
  }

  @override
  void initState() {
    super.initState();
    _muatProduk();
  }

  void _muatProduk() {
    setState(() {
      _produkFuture = DatabaseHelper.instance.getAllProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Transaksi Kasir POS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF0EA5E9), // Biru Muda
      ),
      body: FutureBuilder<List<Produk>>(
        future: _produkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan memuat kasir: ${snapshot.error}'),
            );
          }

          final daftarProduk = snapshot.data ?? [];
          if (daftarProduk.isEmpty) {
            return const Center(child: Text('Belum ada produk untuk kasir'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: daftarProduk.length,
            itemBuilder: (context, index) {
              final item = daftarProduk[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF), // Latar biru muda lembut
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.gambarUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 52,
                        height: 52,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Stok: ${item.stok} | ${_formatRupiah(item.hargaJual)}',
                      style: const TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Color(0xFF0EA5E9),
                      size: 24,
                    ),
                    tooltip: 'Tambah ke Keranjang Kasir',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.nama} ditambahkan ke transaksi kasir!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF0EA5E9),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

