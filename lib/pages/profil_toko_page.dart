// Mengimpor antarmuka Flutter dan SharedPreferences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mengimpor halaman kelola karyawan untuk jalan pintas menu
import 'kelola_karyawan_page.dart';
import 'kelola_pelanggan_page.dart';
import '../helpers/database_helper.dart';

// Halaman Pengaturan Profil Toko & Footer Struk Kasir
class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  State<ProfilTokoPage> createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  // Controller formulir pengaturan identitas toko
  final _namaTokoController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noWaController = TextEditingController();
  final _footerController = TextEditingController();
  // Tantangan 3: Controller Akun Instagram Toko
  final _igController = TextEditingController();

  // Status visual tombol simpan
  bool _sedangMenyimpan = false;

  // Nama kasir aktif yang sedang bertugas
  String _activeCashierName = 'Belum Ditentukan';

  // Total pelanggan terdaftar (Tantangan 3)
  int _totalPelanggan = 0;

  @override
  void initState() {
    super.initState();
    _muatProfilToko();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _noWaController.dispose();
    _footerController.dispose();
    _igController.dispose();
    super.dispose();
  }

  // --- MEMBACA PENGATURAN TOKO DARI SHAREDPREFERENCES ---
  Future<void> _muatProfilToko() async {
    final prefs = await SharedPreferences.getInstance();
    final countPelanggan = await DatabaseHelper.instance.countPelanggan();
    setState(() {
      _totalPelanggan = countPelanggan;
      _namaTokoController.text =
          prefs.getString('nama_toko') ?? 'SmartKasir Poliban';
      _alamatController.text =
          prefs.getString('alamat_toko') ??
          'Jl. Brigjend H. Hasan Basry, Banjarmasin';
      _noWaController.text = prefs.getString('no_wa') ?? '081234567890';
      _footerController.text =
          prefs.getString('footer_struk') ??
          'Terima Kasih Atas Kunjungan Anda! Barang yang sudah dibeli tidak dapat ditukar.';
      // Tantangan 3: Membaca 'ig_toko'
      _igController.text = prefs.getString('ig_toko') ?? '@smartkasir.id';

      // Membaca nama kasir aktif
      _activeCashierName =
          prefs.getString('active_cashier_name') ??
          prefs.getString('kasir_nama') ??
          'Belum Ditentukan';
    });
  }

  // --- MENYIMPAN PENGATURAN TOKO KE SHAREDPREFERENCES ---
  Future<void> _simpanProfilToko() async {
    setState(() => _sedangMenyimpan = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_toko', _namaTokoController.text.trim());
    await prefs.setString('alamat_toko', _alamatController.text.trim());
    await prefs.setString('no_wa', _noWaController.text.trim());
    await prefs.setString('footer_struk', _footerController.text.trim());
    // Tantangan 3: Menyimpan key 'ig_toko'
    await prefs.setString('ig_toko', _igController.text.trim());

    setState(() => _sedangMenyimpan = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identitas toko berhasil diperbarui!'),
        backgroundColor: Color(0xFF0EA5E9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0EA5E9), // Biru Muda
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
            tooltip: 'Simpan Profil',
            onPressed: _sedangMenyimpan ? null : _simpanProfilToko,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KARTU RINGKASAN KASIR BERTUGAS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF0EA5E9),
                    child: Icon(Icons.storefront, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KASIR AKTIF SHIFT INI',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeCashierName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0EA5E9),
                      side: const BorderSide(color: Color(0xFF0EA5E9)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelolaKaryawanPage(),
                        ),
                      );
                      _muatProfilToko();
                    },
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // MENU MANAJEMEN DATA PELANGGAN & MEMBER (MODUL M13 + TANTANGAN 3)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF0EA5E9),
                  child: Icon(Icons.people_alt, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Data Pelanggan & Lokasi GPS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  '$_totalPelanggan Member Pelanggan Terdaftar',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0EA5E9),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KelolaPelangganPage(),
                    ),
                  );
                  _muatProfilToko();
                },
              ),
            ),
            const SizedBox(height: 20),

            // FORM IDENTITAS USAHA (SHAREDPREFERENCES)
            const Text(
              'IDENTITAS USAHA & STRUK KASIR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0EA5E9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 1. NAMA TOKO
            TextFormField(
              controller: _namaTokoController,
              decoration: InputDecoration(
                labelText: 'Nama Toko / Usaha',
                prefixIcon: const Icon(Icons.store, color: Color(0xFF0EA5E9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 2. ALAMAT TOKO
            TextFormField(
              controller: _alamatController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat Toko',
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF0EA5E9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 3. KONTAK WHATSAPP / TELEPON
            TextFormField(
              controller: _noWaController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp / Kontak Toko',
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF0EA5E9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // TANTANGAN 3: BIDANG MEDIA SOSIAL / INSTAGRAM TOKO
            TextFormField(
              controller: _igController,
              decoration: InputDecoration(
                labelText: 'Akun Instagram Toko (@nama_toko)',
                hintText: '@warkop_demanda',
                prefixIcon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0EA5E9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // 4. CATATAN KAKI STRUK (FOOTER RECEIPT)
            TextFormField(
              controller: _footerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan Kaki Struk (Footer Nota)',
                hintText: 'Contoh: Terima kasih atas kunjungan Anda!',
                prefixIcon: const Icon(Icons.receipt_outlined, color: Color(0xFF0EA5E9)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // TOMBOL SIMPAN PENGATURAN
            ElevatedButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpanProfilToko,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9), // Biru Muda
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _sedangMenyimpan ? 'Menyimpan Pengaturan...' : 'Simpan Profil Toko',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

