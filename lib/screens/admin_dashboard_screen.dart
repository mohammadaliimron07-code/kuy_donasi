import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';
import 'package:kuydonasi/providers/campaign_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // A. Routing Guard (Penjaga Pintu)
    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Access Denied: Anda tidak memiliki akses ke halaman ini.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      );
    }

    final List<Widget> screens = [
      _buildDashboardView(context),
      _buildDonationManagementView(context),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 for background
      appBar: AppBar(
        title: const Text('Admin Panel KuyDonasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B), // Slate 800 Dark Theme
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E293B), // Slate 800 Dark Theme
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard Pengelola',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Kelola Donasi',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final donation = context.watch<DonationProvider>();
    final campaignProvider = context.watch<CampaignProvider>();
    final numberFormat = NumberFormat('#,##0', 'id_ID');

    final counts = auth.focusCounts;
    final total = auth.totalUsers;
    final topFocus = auth.topFocus;
    final maxCount = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Selamat datang, ${auth.name ?? 'Admin'}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
          // Analisis Minat
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Analisis Minat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                            color: const Color(0xFF1E293B),
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
          // Daftar Pengguna
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Daftar Pengguna Terdaftar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: auth.registeredUsers.length,
                      itemBuilder: (context, index) {
                        final user = auth.registeredUsers[index];
                        final userName = user['name'] ?? 'Unknown';
                        final userEmail = user['email'] ?? '';
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
                          ),
                          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(userEmail),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Member', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text("Konfirmasi Hapus"),
                                      content: Text("Apakah Anda yakin ingin menghapus user $userName?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext), 
                                          child: const Text("Batal")
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(dialogContext);
                                            try {
                                              await context.read<AuthProvider>().deleteUser(
                                                userEmail, 
                                                isAdmin: auth.isAdmin,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('User $userName berhasil dihapus')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }, 
                                          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Pusat Masukan
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pusat Masukan (Feedback Center)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  donation.feedbackList.isEmpty
                      ? const Text('Belum ada feedback dari pengguna.', style: TextStyle(color: Colors.grey))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: donation.feedbackList.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final feedback = donation.feedbackList[index];
                            return ListTile(
                              leading: Icon(
                                feedback.type == 'bug'
                                    ? Icons.bug_report
                                    : (feedback.type == 'feature' ? Icons.lightbulb : Icons.tune),
                                color: const Color(0xFF1E293B),
                              ),
                              title: Text(feedback.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(feedback.description),
                              trailing: DropdownButton<String>(
                                value: ['Baru', 'Ditinjau', 'Disetujui', 'Ditolak'].contains(feedback.status) 
                                    ? feedback.status 
                                    : 'Baru',
                                items: ['Baru', 'Ditinjau', 'Disetujui', 'Ditolak']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status, style: const TextStyle(fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null) {
                                    try {
                                      context.read<DonationProvider>().updateFeedbackStatus(
                                        feedback.id, 
                                        newStatus,
                                        isAdmin: auth.isAdmin,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Manajemen Kampanye
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manajemen Kampanye',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur tambah kampanye akan datang')),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  campaignProvider.campaigns.isEmpty
                      ? const Text('Belum ada kampanye.', style: TextStyle(color: Colors.grey))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: campaignProvider.campaigns.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final campaign = campaignProvider.campaigns[index];
                            return ListTile(
                              title: Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                'Target: Rp ${numberFormat.format(campaign.targetAmount)} - Status: ${campaign.isActive ? 'Aktif' : 'Tutup'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Fitur edit kampanye akan datang')),
                                      );
                                    },
                                  ),
                                  Switch(
                                    value: campaign.isActive,
                                    activeColor: const Color(0xFF1E293B),
                                    onChanged: (val) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Fitur tutup kampanye akan datang')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Super Control Panel
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Super Control (Otoritas Penuh)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Master Switch: Donasi dihentikan sementara untuk Audit.')),
                          );
                        },
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Master Switch (Donasi)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mengekspor data ke PDF/Excel...')),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Data Export (Laporan ISAK 35)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menampilkan Audit Log (Activity history)...')),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Audit Log'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationManagementView(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final numberFormat = NumberFormat('#,##0', 'id_ID');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    final transactions = donationProvider.transactions.reversed.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola Verifikasi Donasi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pantau donasi yang masuk dan verifikasi untuk integrasi laporan keuangan ISAK 35.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text('Belum ada transaksi donasi yang masuk.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isPending = tx.status == 'Menunggu Verifikasi';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tx.campaignTitle,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${numberFormat.format(tx.amount)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormat.format(tx.date),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tx.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isPending) ...[
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        try {
                                          context.read<DonationProvider>().updateTransactionStatus(
                                            tx.id,
                                            'Gagal',
                                            isAdmin: context.read<AuthProvider>().isAdmin,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      },
                                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                      label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        try {
                                          context.read<DonationProvider>().updateTransactionStatus(
                                            tx.id,
                                            'Terverifikasi',
                                            isAdmin: context.read<AuthProvider>().isAdmin,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Donasi berhasil diverifikasi!')),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      },
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Verifikasi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E293B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}
