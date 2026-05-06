import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting(String? name) {
    if (name != null) {
      return 'Halo, $name!';
    }
    return 'Halo!';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Future<bool?> _confirmLogout() {
      return showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Logout'),
              ),
            ],
          );
        },
      );
    }

    if (auth.isAdmin) {
      final counts = auth.focusCounts;
      final total = auth.totalUsers;
      final topFocus = auth.topFocus;
      final maxCount = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel KuyDonasi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async {
                final shouldLogout = await _confirmLogout();
                if (shouldLogout != true) return;
                await context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final content = SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat datang, ${auth.name ?? 'Admin'}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Panel Admin Eksklusif untuk memantau minat donasi dan daftar pengguna.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _AdminStatCard(
                        title: 'Total User',
                        value: total.toString(),
                        color: Colors.blueAccent,
                      ),
                      _AdminStatCard(
                        title: 'Minat Tertinggi',
                        value: topFocus,
                        color: Colors.green,
                      ),
                      _AdminStatCard(
                        title: 'Status Sistem',
                        value: total > 0 ? 'Aktif' : 'Menunggu data',
                        color: total > 0 ? Colors.teal : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Analisis Minat',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ...counts.entries.map((entry) {
                            final percent = maxCount == 0 ? 0.0 : entry.value / maxCount;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('${entry.value} pendaftar', style: const TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 12,
                                    color: const Color(0xFF0D6E63),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Daftar Pengguna Terdaftar',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Nama')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Minat')),
                              ],
                              rows: auth.registeredUsers.map(
                                (user) {
                                  return DataRow(cells: [
                                    DataCell(Text(user['name'] ?? '')),
                                    DataCell(Text(user['email'] ?? '')),
                                    DataCell(Text(user['focus'] ?? '-')),
                                  ]);
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Admin Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 16),
                        Text('• Ringkasan', style: TextStyle(fontSize: 15)),
                        SizedBox(height: 8),
                        Text('• Analitik', style: TextStyle(fontSize: 15)),
                        SizedBox(height: 8),
                        Text('• Pengguna', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                  Expanded(child: content),
                ],
              );
            }

            return content;
          },
        ),
      );
    }

    final selectedFocus = auth.focus ?? 'Pendidikan';
    final focusCampaigns = {
      'Pendidikan': ['Beasiswa Anak Bangsa', 'Buku untuk Sekolah'],
      'Kesehatan': ['Klinik Gratis', 'Vaksinasi Massal'],
      'Kemanusiaan': ['Bantuan Bencana', 'Rumah Aman'],
      'Lingkungan': ['Tanam Pohon', 'Pantai Bersih'],
    };
    final campaigns = focusCampaigns[selectedFocus] ?? ['Program Donasi Umum'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard KuyDonasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final authProvider = context.read<AuthProvider>();
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout != true) return;
              await authProvider.logout();
              navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _getGreeting(auth.name),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth.name != null
                          ? 'Selamat datang di Dashboard KuyDonasi.'
                          : 'Akun admin / donatur',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Fokus donasi Anda: $selectedFocus',
                      style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Berikut adalah campaign yang sesuai dengan fokus Anda.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Campaign pilihan berdasarkan fokus Anda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: campaigns
                  .map(
                    (campaign) => _DashboardCard(
                      title: campaign,
                      subtitle: 'Campaign donasi $selectedFocus',
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AdminStatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DashboardCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
