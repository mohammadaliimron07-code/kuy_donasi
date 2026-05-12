import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF17A2B8), Color(0xFF0E7A92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Berikan Donasi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bantu mereka yang membutuhkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Search & Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari campaign donasi...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filter Kategori',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(label: 'Semua'),
                      _FilterChip(label: 'Pendidikan'),
                      _FilterChip(label: 'Kesehatan'),
                      _FilterChip(label: 'Kemanusiaan'),
                      _FilterChip(label: 'Lingkungan'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Campaign Tersedia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _DonationCampaignCard(
                    title: 'Beasiswa Pelajar Pelosok Nusantara',
                    category: 'Pendidikan',
                    target: 'Rp85,200,000',
                    collected: 'Rp63,900,000',
                    progress: 0.75,
                    daysLeft: '12 hari',
                  ),
                  const SizedBox(height: 12),
                  _DonationCampaignCard(
                    title: 'Pembangunan Klinik Desa Sukamaju',
                    category: 'Kesehatan',
                    target: 'Rp210,480,000',
                    collected: 'Rp94,716,000',
                    progress: 0.45,
                    daysLeft: '28 hari',
                  ),
                  const SizedBox(height: 12),
                  _DonationCampaignCard(
                    title: 'Program Makanan Bergizi Anak Panti Asuhan',
                    category: 'Kemanusiaan',
                    target: 'Rp45,000,000',
                    collected: 'Rp32,100,000',
                    progress: 0.71,
                    daysLeft: '8 hari',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {},
      backgroundColor: label == 'Semua' ? const Color(0xFF0D6E63) : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: label == 'Semua' ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DonationCampaignCard extends StatelessWidget {
  final String title;
  final String category;
  final String target;
  final String collected;
  final double progress;
  final String daysLeft;

  const _DonationCampaignCard({
    required this.title,
    required this.category,
    required this.target,
    required this.collected,
    required this.progress,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0D6E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFF0D6E63),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collected,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D6E63),
                          ),
                        ),
                        Text(
                          'dari $target',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigasi ke halaman donasi')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6E63),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Donasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  daysLeft,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
