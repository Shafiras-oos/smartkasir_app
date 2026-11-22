// Mengimpor pustaka deteksi platform Flutter (untuk memeriksa peramban web kIsWeb)
import 'package:flutter/foundation.dart';
// Mengimpor pustaka inti SQLite untuk Flutter
import 'package:sqflite/sqflite.dart';
// Mengimpor pustaka penggabungan path direktori berkas lokal
import 'package:path/path.dart';
// Mengimpor implementasi SQLite FFI khusus peramban Web Google Chrome
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Mengimpor model data produk, karyawan, dan pelanggan
import '../models/produk.dart';
import '../models/karyawan.dart';
import '../models/pelanggan.dart';

// Kelas pengelola koneksi dan operasi basis data SQLite lokal SmartKasir
class DatabaseHelper {
  //--- 1. PENERAPAN DESIGN PATTERN SINGLETON
  // Deklarasi instansi statis tunggal kelas DatabaseHelper yang diakses dari seluruh widget
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Variabel penampung objek koneksi database aktif (Nullable '?' sebelum diinisialisasi)
  static Database? _database;

  // Konstruktor privat: Mengunci kelas agar tidak dapat diinstansiasi dengan 'DatabaseHelper()' secara bebas
  DatabaseHelper._init();

  //--- 2. GETTER DATABASE ASINKRON
  // Mengembalikan koneksi database aktif yang sudah ada, atau menginisialisasi baru jika belum pernah dibuka
  Future<Database> get database async {
    // KONTROL PERCABANGAN LOGIKA: Jika objek database sudah hidup di memori, langsung kembalikan
    if (_database != null) {
      await _seedProdukAwal(_database!);
      return _database!;
    }

    // Jika belum ada, inisialisasi berkas basis data baru
    _database = await _initDB('smartkasir.db');
    await _seedProdukAwal(_database!);
    return _database!;
  }

  //--- 3. INISIALISASI BERKAS BASIS DATA (DUAL-PLATFORM CHROME & ANDROID)
  Future<Database> _initDB(String filePath) async {
    // KONTROL PERCABANGAN DUAL PLATFORM:
    // Jika aplikasi berjalan di Google Chrome (Flutter Web), gunakan web database factory
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 3, // Ditingkatkan ke Versi 3 untuk tabel pelanggan
          onCreate: _createDB,
          onUpgrade: _onUpgradeDB,
        ),
      );
    } else {
      // Jika berjalan di smartphone Android fisik / emulator:
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 3, // Ditingkatkan ke Versi 3 untuk tabel pelanggan
        onCreate: _createDB,
        onUpgrade: _onUpgradeDB,
      );
    }
  }

  // Seeder Data Produk Awal: Memastikan produk bawaan selalu tersedia
  Future<void> _seedProdukAwal(Database db) async {
    try {
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM produk'),
          ) ??
          0;
      if (count == 0) {
        for (final produk in produkAwalSQLite) {
          await db.insert('produk', produk.toMap());
        }
      }
    } catch (_) {
      // Mengabaikan jika tabel produk belum terbentuk saat migrasi bertahap
    }
  }

  //--- 4. DDL: PEMBUATAN STRUKTUR TABEL & SEEDING DATA AWAL (VERSI 3)
  Future _createDB(Database db, int version) async {
    // 1. Pembuatan Tabel Produk
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // Seeding otomatis data awal produk ke SQLite
    await _seedProdukAwal(db);

    // 2. Pembuatan Tabel Karyawan (Modul Minggu 12)
    await db.execute('''
      CREATE TABLE karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        pin TEXT NOT NULL,
        peran TEXT NOT NULL
      )
    ''');

    // Seeding otomatis data awal karyawan ke SQLite
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Ahmad Kasir', '123456', 'Kasir')
    ''');
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Siti Supervisor', '888888', 'Supervisor')
    ''');

    // 3. Pembuatan Tabel Pelanggan & Koordinat GPS Maps (Modul Minggu 13)
    await db.execute('''
      CREATE TABLE pelanggan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_pelanggan TEXT UNIQUE NOT NULL,
        nama_pelanggan TEXT NOT NULL,
        nomor_wa TEXT NOT NULL,
        alamat TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // Seeding Data Awal: Pelanggan Binaan Awal (Dengan Koordinat GPS Banjarmasin)
    await db.rawInsert('''
      INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
      VALUES ('CUST-001', 'Warung Bu Siti', '081234567890', 'Jl. Hasan Basri No. 12, Banjarmasin', -3.298280, 114.588820, '2026-11-01 09:00:00')
    ''');
    await db.rawInsert('''
      INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
      VALUES ('CUST-002', 'Budi Santoso', '085712345678', 'Jl. Kayu Tangi II No. 45, Banjarmasin', -3.295410, 114.582150, '2026-11-02 10:30:00')
    ''');
  }

  //--- DDL: MIGRASI SKEMA JIKA VERSI BASIS DATA DITINGKATKAN (SCHEMA MIGRATION)
  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    // Memastikan struktur produk selalu ada
    await db.execute('''
      CREATE TABLE IF NOT EXISTS produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
    await _seedProdukAwal(db);

    if (oldVersion < 2) {
      // Membuat tabel karyawan untuk database pengguna yang sudah ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS karyawan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_karyawan TEXT NOT NULL,
          pin TEXT NOT NULL,
          peran TEXT NOT NULL
        )
      ''');
      final countKaryawan =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM karyawan'),
          ) ??
          0;
      if (countKaryawan == 0) {
        await db.rawInsert('''
          INSERT INTO karyawan (nama_karyawan, pin, peran)
          VALUES ('Ahmad Kasir', '123456', 'Kasir')
        ''');
        await db.rawInsert('''
          INSERT INTO karyawan (nama_karyawan, pin, peran)
          VALUES ('Siti Supervisor', '888888', 'Supervisor')
        ''');
      }
    }

    if (oldVersion < 3) {
      // Menambahkan tabel pelanggan jika berpindah dari versi 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pelanggan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kode_pelanggan TEXT UNIQUE NOT NULL,
          nama_pelanggan TEXT NOT NULL,
          nomor_wa TEXT NOT NULL,
          alamat TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          created_at TEXT NOT NULL
        )
      ''');
      final countPelanggan =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM pelanggan'),
          ) ??
          0;
      if (countPelanggan == 0) {
        await db.rawInsert('''
          INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
          VALUES ('CUST-001', 'Warung Bu Siti', '081234567890', 'Jl. Hasan Basri No. 12, Banjarmasin', -3.298280, 114.588820, '2026-11-01 09:00:00')
        ''');
        await db.rawInsert('''
          INSERT INTO pelanggan (kode_pelanggan, nama_pelanggan, nomor_wa, alamat, latitude, longitude, created_at)
          VALUES ('CUST-002', 'Budi Santoso', '085712345678', 'Jl. Kayu Tangi II No. 45, Banjarmasin', -3.295410, 114.582150, '2026-11-02 10:30:00')
        ''');
      }
    }
  }

  // =========================================================================
  // METODE CRUD: TABEL PELANGGAN (MODUL MINGGU 13)
  // =========================================================================

  // 1. CREATE: Menyimpan data pelanggan baru
  Future<int> insertPelanggan(Pelanggan pelanggan) async {
    final db = await instance.database;
    return await db.insert('pelanggan', pelanggan.toMap());
  }

  // 2. READ: Mengambil seluruh daftar pelanggan diurutkan dari yang terbaru
  Future<List<Pelanggan>> getAllPelanggan() async {
    final db = await instance.database;
    final result = await db.query('pelanggan', orderBy: 'id DESC');
    return result.map((json) => Pelanggan.fromMap(json)).toList();
  }

  // 3. READ: Mencari pelanggan berdasarkan nama, nomor WA, atau kode member (SQL LIKE)
  Future<List<Pelanggan>> searchPelanggan(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'pelanggan',
      where:
          'nama_pelanggan LIKE ? OR nomor_wa LIKE ? OR kode_pelanggan LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Pelanggan.fromMap(json)).toList();
  }

  // 4. UPDATE: Memperbarui data profil dan koordinat GPS pelanggan
  Future<int> updatePelanggan(Pelanggan pelanggan) async {
    final db = await instance.database;
    return await db.update(
      'pelanggan',
      pelanggan.toMap(),
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  // 5. DELETE: Menghapus data pelanggan berdasarkan ID
  Future<int> deletePelanggan(int id) async {
    final db = await instance.database;
    return await db.delete('pelanggan', where: 'id = ?', whereArgs: [id]);
  }

  // 6. COUNT: Menghitung total jumlah pelanggan terdaftar untuk ringkasan Dashboard / Profil
  Future<int> countPelanggan() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM pelanggan',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =========================================================================
  // METODE CRUD: TABEL KARYAWAN (MODUL MINGGU 12)
  // =========================================================================

  // 1. CREATE: Menyimpan Karyawan Baru
  Future<int> insertKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.insert('karyawan', karyawan.toMap());
  }

  // 2. READ: Mengambil Seluruh Karyawan
  Future<List<Karyawan>> getAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id ASC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  // 3. UPDATE: Memperbarui Data Karyawan
  Future<int> updateKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.update(
      'karyawan',
      karyawan.toMap(),
      where: 'id = ?',
      whereArgs: [karyawan.id],
    );
  }

  // 4. DELETE: Menghapus Karyawan Berdasarkan ID
  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // METODE CRUD: TABEL PRODUK (DARI MINGGU 11)
  // =========================================================================

  // 5. CREATE: Menambahkan Produk Baru
  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;
    final id = await db.insert(
      'produk',
      produk.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // 6. READ: Mengambil Seluruh Daftar Produk (Urut Harga Termurah)
  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;
    final result = await db.query('produk', orderBy: 'harga_jual ASC');
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 7. READ DENGAN FILTER KATEGORI
  Future<List<Produk>> getProdukByKategori(String kategori) async {
    final db = await instance.database;
    if (kategori == 'Semua') {
      return await getAllProduk();
    }
    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'harga_jual ASC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 8. SEARCH: Pencarian Produk
  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'harga_jual ASC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 9. UPDATE: Memperbarui Data Produk
  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;
    return await db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  // 10. DELETE: Menghapus Produk
  Future<int> deleteProduk(int id) async {
    final db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  // 11. COUNT: Menghitung Total Produk
  Future<int> countProduk() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM produk');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
