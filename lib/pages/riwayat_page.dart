// Mengimpor antarmuka Flutter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Halaman Tab 2: Riwayat Penjualan
class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  String _formatRupiah(double nominal) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> riwayatPenjualan = [
      {
        'kode': 'TRX-001',
        'waktu': '04 Nov 2026, 14:30',
        'items': '2x Kopi Susu Gula Aren, 1x Roti Bakar Cokelat Keju',
        'metode': 'Tunai',
        'total': 51000.0,
      },
      {
        'kode': 'TRX-002',
        'waktu': '04 Nov 2026, 15:15',
        'items': '1x Nasi Goreng Banjar Spesial, 1x Es Teh Manis',
        'metode': 'QRIS',
        'total': 30000.0,
      },
      {
        'kode': 'TRX-003',
        'waktu': '04 Nov 2026, 16:00',
        'items': '3x Keripik Singkong Pedas Manis',
        'metode': 'Tunai',
        'total': 36000.0,
      },
      {
        'kode': 'TRX-004',
        'waktu': '04 Nov 2026, 16:45',
        'items': '2x Matcha Latte Ice, 2x Pisang Goreng Pasir Crispy',
        'metode': 'QRIS',
        'total': 72000.0,
      },
      {
        'kode': 'TRX-005',
        'waktu': '04 Nov 2026, 17:20',
        'items': '1x Kopi Susu Gula Aren, 1x Pisang Goreng Pasir Crispy',
        'metode': 'Transfer',
        'total': 32000.0,
      },
      {
        'kode': 'TRX-006',
        'waktu': '04 Nov 2026, 18:10',
        'items': '2x Nasi Goreng Banjar Spesial, 2x Matcha Latte Ice',
        'metode': 'Tunai',
        'total': 94000.0,
      },
      {
        'kode': 'TRX-007',
        'waktu': '04 Nov 2026, 19:05',
        'items': '1x Roti Bakar Cokelat Keju, 1x Kopi Susu Gula Aren',
        'metode': 'QRIS',
        'total': 33000.0,
      },
      {
        'kode': 'TRX-008',
        'waktu': '04 Nov 2026, 19:40',
        'items': '4x Keripik Singkong Pedas Manis',
        'metode': 'Tunai',
        'total': 48000.0,
      },
      {
        'kode': 'TRX-009',
        'waktu': '04 Nov 2026, 20:15',
        'items': '1x Nasi Goreng Banjar, 1x Roti Bakar, 1x Matcha Latte',
        'metode': 'QRIS',
        'total': 62000.0,
      },
      {
        'kode': 'TRX-010',
        'waktu': '04 Nov 2026, 20:50',
        'items': '3x Kopi Susu Gula Aren, 2x Pisang Goreng Pasir Crispy',
        'metode': 'Debit',
        'total': 82000.0,
      },
      {
        'kode': 'TRX-011',
        'waktu': '04 Nov 2026, 21:15',
        'items': '2x Roti Bakar Cokelat Keju, 2x Keripik Singkong',
        'metode': 'Tunai',
        'total': 54000.0,
      },
      {
        'kode': 'TRX-012',
        'waktu': '04 Nov 2026, 21:45',
        'items': '1x Matcha Latte Ice, 1x Kopi Susu Gula Aren',
        'metode': 'QRIS',
        'total': 40000.0,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Riwayat Penjualan',
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: riwayatPenjualan.length,
        itemBuilder: (context, index) {
          final trx = riwayatPenjualan[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BARIS 1: KODE TRANSAKSI & WAKTU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trx['kode'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      trx['waktu'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // BARIS 2: IKON STRUK & DAFTAR ITEM DIBELI
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.receipt,
                        color: Color(0xFF0EA5E9),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        trx['items'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // BARIS 3: METODE PEMBAYARAN & TOTAL NOMINAL RUPIAH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trx['metode'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatRupiah(trx['total'] as double),
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

