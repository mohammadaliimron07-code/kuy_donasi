import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kuydonasi/providers/campaign_provider.dart';
import 'package:kuydonasi/screens/transfer_donation_screen.dart';

class HalamanBerandaDonatur extends StatefulWidget {
  const HalamanBerandaDonatur({super.key});

  @override
  State<HalamanBerandaDonatur> createState() => _HalamanBerandaDonaturState();
}

class _HalamanBerandaDonaturState extends State<HalamanBerandaDonatur> {
  // 1. STATE: Menyimpan kategori aktif yang sedang ditekan user
  // Secara default, saat aplikasi dibuka kita arahkan ke 'Pendidikan'
  String _kategoriTerpilih = 'Pendidikan';

  // 2. DATA PUSAT: Seluruh program donasi di aplikasi KuyDonasi
  final List<Map<String, dynamic>> daftarProgramKuyDonasi = [
    // --- KATEGORI PENDIDIKAN ---
    {
      'id': 'EDU-01',
      'judul': 'Beasiswa UKT Mahasiswa Teknik UIM',
      'kategori': 'Pendidikan',
      'gambar': Icons.school,
      'terkumpul': 12500000,
      'target': 20000000,
      'sisa_hari': 15,
    },
    {
      'id': 'EDU-02',
      'judul': 'Pengadaan Laptop untuk Laboratorium Komputer Sekolah Desa',
      'kategori': 'Pendidikan',
      'gambar': Icons.laptop_mac,
      'terkumpul': 4500000,
      'target': 30000000,
      'sisa_hari': 30,
    },
    {
      'id': 'EDU-03',
      'judul': 'Donasi Buku Bacaan dan Al-Qur\'an untuk Pasca Bencana',
      'kategori': 'Pendidikan',
      'gambar': Icons.menu_book,
      'terkumpul': 800000,
      'target': 5000000,
      'sisa_hari': 40,
    },

    // --- KATEGORI KESEHATAN ---
    {
      'id': 'HEA-01',
      'judul': 'Bantuan Pengobatan Rawat Jalan Pasien Kanker Dhuafa',
      'kategori': 'Kesehatan',
      'gambar': Icons.local_hospital,
      'terkumpul': 8200000,
      'target': 35000000,
      'sisa_hari': 18,
    },
    {
      'id': 'HEA-02',
      'judul': 'Subsidi Biaya Operasi Mata Katarak Lansia',
      'kategori': 'Kesehatan',
      'gambar': Icons.remove_red_eye,
      'terkumpul': 15000000,
      'target': 15000000,
      'sisa_hari': 2,
    },
    {
      'id': 'HEA-03',
      'judul': 'Pengadaan Alat Tensi dan Timbangan Digital Posyandu',
      'kategori': 'Kesehatan',
      'gambar': Icons.medical_services,
      'terkumpul': 15000000,
      'target': 20000000,
      'sisa_hari': 25,
    },

    // --- KATEGORI KEMANUSIAAN ---
    {
      'id': 'HUM-01',
      'judul': 'Paket Sembako Bulanan untuk Lansia Sebatang Kara',
      'kategori': 'Kemanusiaan',
      'gambar': Icons.volunteer_activism,
      'terkumpul': 2000000,
      'target': 8000000,
      'sisa_hari': 12,
    },
    {
      'id': 'HUM-02',
      'judul': 'Bantuan Logistik dan Tenda Darurat Korban Gempa',
      'kategori': 'Kemanusiaan',
      'gambar': Icons.local_shipping,
      'terkumpul': 5000000,
      'target': 20000000,
      'sisa_hari': 7,
    },

    // --- KATEGORI LINGKUNGAN ---
    {
      'id': 'ENV-01',
      'judul': 'Penanaman Bibit Pohon di Lahan Kritis Lereng Gunung',
      'kategori': 'Lingkungan',
      'gambar': Icons.nature_people,
      'terkumpul': 2100000,
      'target': 5000000,
      'sisa_hari': 20,
    },
    {
      'id': 'ENV-02',
      'judul': 'Gerakan Bersih-Bersih Sampah Plastik di Aliran Sungai',
      'kategori': 'Lingkungan',
      'gambar': Icons.cleaning_services,
      'terkumpul': 600000,
      'target': 3000000,
      'sisa_hari': 45,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 3. LOGIKA FILTER: Menyaring data agar benar-benar HANYA menampilkan yang dipilih
    final numberFormat = NumberFormat('#,##0', 'id_ID');
    final listTersaring = daftarProgramKuyDonasi
      .where((item) => item['kategori'] == _kategoriTerpilih)
      .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KuyDonasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00695C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL SEPERTI DI SCREENSHOT ANDA ---
            const Text(
              "Fokus donasi yang Anda minati:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
            const SizedBox(height: 16),

            // --- DEKLARASI 4 TOMBOL FITUR UTAMA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKategoriButton('Pendidikan', Icons.check),
                _buildKategoriButton('Kesehatan', null),
                _buildKategoriButton('Kemanusiaan', null),
                _buildKategoriButton('Lingkungan', null),
              ],
            ),
            const SizedBox(height: 24),

            // --- TEKS INDIKATOR AKTIF ---
            Text(
              "Menampilkan Program: $_kategoriTerpilih",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // --- DAFTAR PROGRAM YANG SUDAH TERFILTER (TIDAK TERCAMPUR) ---
            Expanded(
              child: listTersaring.isEmpty
                  ? const Center(child: Text("Belum ada program donasi saat ini."))
                  : ListView.builder(
                      itemCount: listTersaring.length,
                      itemBuilder: (context, index) {
                        final program = listTersaring[index];
                        final int terkumpul = program['terkumpul'] as int? ?? 0;
                        final int target = program['target'] as int? ?? 1;
                        final int sisaHari = program['sisa_hari'] as int? ?? 0;
                        final double progress = (target > 0) ? (terkumpul / target).clamp(0, 1) : 0.0;
                        final int persentaseTeks = (progress * 100).toInt();

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              // Build a minimal Campaign instance from the map and navigate to the transfer screen
                              final kampanye = Campaign(
                                id: program['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                title: program['judul'] as String? ?? 'Program Donasi',
                                description: program['judul'] as String? ?? '',
                                category: program['kategori'] as String? ?? 'Pendidikan',
                                imageUrl: '',
                                targetAmount: (program['target'] as int?)?.toDouble() ?? (program['target'] as double?) ?? 0.0,
                                currentAmount: (program['terkumpul'] as int?)?.toDouble() ?? (program['terkumpul'] as double?) ?? 0.0,
                                status: ((program['terkumpul'] as int?) ?? 0) >= ((program['target'] as int?) ?? 1) ? 'completed' : 'active',
                                createdDate: DateTime.now(),
                                targetDate: DateTime.now().add(Duration(days: (program['sisa_hari'] as int?) ?? 0)),
                                organizationName: 'Yayasan KuyDonasi',
                                donorCount: 0,
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TransferDonationScreen(campaign: kampanye),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program['judul'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00695C).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(program['gambar'], color: const Color(0xFF00695C), size: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: progress > 1.0 ? 1.0 : progress,
                                                backgroundColor: Colors.grey.shade200,
                                                valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? Colors.green : const Color(0xFF00695C)),
                                                minHeight: 8,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Terkumpul', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                    Text('Rp ${numberFormat.format(terkumpul)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00695C))),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF00695C).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text('$persentaseTeks%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00695C))),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text('$sisaHari hari tersisa', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL KATEGORI PILIHAN ---
  Widget _buildKategoriButton(String namaKategori, IconData? icon) {
    // Mengecek apakah tombol ini yang sedang aktif dipilih oleh user
    bool isAktif = _kategoriTerpilih == namaKategori;

    return GestureDetector(
      onTap: () {
        // PERINTAH UTAMA: Mengubah filter kategori dan memperbarui UI secara real-time
        setState(() {
          _kategoriTerpilih = namaKategori;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          // Jika aktif: Berwarna hijau penuh (seperti di gambar Anda). Jika tidak: Abu-abu samar.
          color: isAktif ? const Color(0xFF00695C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20), // Membuat tombol melengkung rapi
        ),
        child: Row(
          children: [
            // Jika aktif dan kategori adalah yang dipilih, munculkan icon check kecil
            if (isAktif) ...[
              const Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              namaKategori,
              style: TextStyle(
                color: isAktif ? Colors.white : Colors.black87,
                fontWeight: isAktif ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
