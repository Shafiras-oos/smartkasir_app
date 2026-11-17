// Mengimpor pustaka antarmuka Flutter dan formatter sistem
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Mengimpor model data Karyawan dan DatabaseHelper
import '../models/karyawan.dart';
import '../helpers/database_helper.dart';

// Halaman Formulir Dwifungsi Karyawan (Tambah Baru & Edit Data Lama)
class FormKaryawanPage extends StatefulWidget {
  // Objek nullable: null = mode Tambah, terisi = mode Edit
  final Karyawan? karyawan;
  const FormKaryawanPage({super.key, this.karyawan});

  @override
  State<FormKaryawanPage> createState() => _FormKaryawanPageState();
}

class _FormKaryawanPageState extends State<FormKaryawanPage> {
  // GlobalKey pengontrol validasi formulir
  final _formKey = GlobalKey<FormState>();

  // Controller kolom input teks
  final _namaController = TextEditingController();
  final _pinController = TextEditingController();

  // Nilai terpilih dropdown peran (termasuk Supervisor dari Tantangan 1)
  String _peranTerpilih = 'Kasir';
  final List<String> _daftarPeran = ['Kasir', 'Admin', 'Manajer', 'Supervisor'];

  // Status visual tombol proses simpan
  bool _sedangMenyimpan = false;

  // Getter pengecekan mode halaman
  bool get _isEditMode => widget.karyawan != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // MODE EDIT: Mengisi nilai awal kolom input dengan data karyawan lama
      _namaController.text = widget.karyawan!.namaKaryawan;
      _pinController.text = widget.karyawan!.pin;
      _peranTerpilih = _daftarPeran.contains(widget.karyawan!.peran)
          ? widget.karyawan!.peran
          : 'Kasir';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // --- LOGIKA SIMPAN DATA KARYAWAN KE SQLITE ---
  Future<void> _simpanKaryawan() async {
    // 1. Eksekusi validasi seluruh kolom form
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sedangMenyimpan = true);

    try {
      // 2. Membungkus input ke dalam objek model Karyawan
      final dataKaryawan = Karyawan(
        id: _isEditMode ? widget.karyawan!.id : null,
        namaKaryawan: _namaController.text.trim(),
        pin: _pinController.text.trim(),
        peran: _peranTerpilih,
      );

      // 3. Eksekusi Kueri SQLite sesuai mode
      if (_isEditMode) {
        await DatabaseHelper.instance.updateKaryawan(dataKaryawan);
      } else {
        await DatabaseHelper.instance.insertKaryawan(dataKaryawan);
      }

      if (!mounted) return;
      // 4. Menampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Data karyawan "${dataKaryawan.namaKaryawan}" berhasil diperbarui!'
                : 'Karyawan baru "${dataKaryawan.namaKaryawan}" berhasil ditambahkan!',
          ),
          backgroundColor: const Color(0xFF0EA5E9),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 5. Kembali ke halaman sebelumnya dengan sinyal true (refresh)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan database: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Data Karyawan' : 'Tambah Staf Kasir Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0EA5E9), // Tema Biru Muda
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BANNER INFORMASI OTORISASI
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.badge_outlined, color: Color(0xFF0EA5E9), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setiap staf kasir memiliki PIN 6 digit untuk login shift penjualan.',
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. INPUT NAMA LENGKAP KARYAWAN
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Karyawan',
                  hintText: 'Contoh: Siti Rahmah',
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0EA5E9)),
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nama karyawan wajib diisi!';
                  if (val.trim().length < 3) return 'Nama karyawan minimal 3 karakter!';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. INPUT PIN KEAMANAN 6 DIGIT (TANTANGAN 2)
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6), // Tantangan 2: 6 digit
                ],
                decoration: InputDecoration(
                  labelText: 'PIN Kasir (6 Digit Angka)',
                  hintText: 'Contoh: 123456',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'PIN kasir wajib diisi!';
                  // Tantangan 2: Tepat 6 digit angka
                  if (val.trim().length != 6) return 'PIN kasir harus tepat 6 digit angka!';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. DROPDOWN PERAN / JABATAN (TERMASUK SUPERVISOR DARI TANTANGAN 1)
              DropdownButtonFormField<String>(
                value: _peranTerpilih,
                decoration: InputDecoration(
                  labelText: 'Peran / Jabatan Toko',
                  prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF0EA5E9)),
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
                items: _daftarPeran.map((peran) {
                  return DropdownMenuItem<String>(
                    value: peran,
                    child: Text(peran),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _peranTerpilih = val);
                },
              ),
              const SizedBox(height: 28),

              // 4. TOMBOL SIMPAN DATA KARYAWAN
              ElevatedButton.icon(
                onPressed: _sedangMenyimpan ? null : _simpanKaryawan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9), // Biru Muda
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: _sedangMenyimpan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(_isEditMode ? Icons.check_circle_outline : Icons.save_outlined),
                label: Text(
                  _sedangMenyimpan
                      ? 'Menyimpan Data...'
                      : (_isEditMode ? 'Perbarui Data Karyawan' : 'Simpan Karyawan Baru'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

