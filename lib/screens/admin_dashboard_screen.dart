import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donation = context.watch<DonationProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard KuyDonasi'),
          backgroundColor: const Color(0xFF17A2B8),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context, auth),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Verifikasi', icon: Icon(Icons.fact_check)),
              Tab(text: 'Pengguna', icon: Icon(Icons.people)),
              Tab(text: 'Audit', icon: Icon(Icons.analytics)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VerificationTab(auth: auth, donation: donation),
            _UsersTab(auth: auth, donation: donation),
            _AuditTab(donation: donation),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari Admin Panel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VerificationTab extends StatelessWidget {
  final AuthProvider auth;
  final DonationProvider donation;

  const _VerificationTab({required this.auth, required this.donation});

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final pending = donation.pendingTransactions;

    if (pending.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada donasi yang menunggu verifikasi saat ini.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final tx = pending[index];
        return _VerificationCard(tx: tx, auth: auth, donation: donation, formatDate: _formatDate);
      },
    );
  }
}

class _VerificationCard extends StatefulWidget {
  final Transaction tx;
  final AuthProvider auth;
  final DonationProvider donation;
  final String Function(DateTime) formatDate;

  const _VerificationCard({
    required this.tx,
    required this.auth,
    required this.donation,
    required this.formatDate,
  });

  @override
  State<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<_VerificationCard> {
  bool _isProcessing = false;
  bool _isVerified = false;

  Future<void> _verifyDonation() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    try {
      await widget.donation.updateTransactionStatus(
        widget.tx.id,
        'Terverifikasi',
        isAdmin: widget.auth.isAdmin,
        adminEmail: widget.auth.email,
      );
      if (mounted) {
        setState(() {
          _isVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donasi disetujui.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Program: ${tx.campaignTitle}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Donatur: ${tx.userEmail.isEmpty ? 'Tidak diketahui' : tx.userEmail}'),
            const SizedBox(height: 4),
            Text('Kategori: ${tx.category}'),
            const SizedBox(height: 4),
            Text('Jumlah: Rp ${tx.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            Text('Tanggal: ${widget.formatDate(tx.date)}'),
            const SizedBox(height: 4),
            Text('Status: ${tx.status}'),
            const SizedBox(height: 4),
            Text('Metode: ${tx.paymentMethod}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          try {
                            await widget.donation.updateTransactionStatus(
                              tx.id,
                              'Ditolak',
                              isAdmin: widget.auth.isAdmin,
                              adminEmail: widget.auth.email,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Donasi ditolak.')),
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
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 12),
                _isVerified
                    ? Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _isProcessing ? null : _verifyDonation,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6E63)),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Setujui'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final AuthProvider auth;
  final DonationProvider donation;

  const _UsersTab({required this.auth, required this.donation});

  String _displayRoleLabel(String roleLabel) {
    if (roleLabel == 'Member') {
      return 'Donatur';
    }
    return roleLabel;
  }

  @override
  Widget build(BuildContext context) {
    final users = auth.registeredUsers;
    if (users.isEmpty) {
      return const Center(
        child: Text('Belum ada user terdaftar.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: auth.isSuperAdmin
                ? Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final formKey = GlobalKey<FormState>();
                        String name = '';
                        String email = '';
                        String password = '';
                        UserRole role = UserRole.financeAdmin;

                        await showDialog<void>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Tambah Admin Baru'),
                              content: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(labelText: 'Nama'),
                                        onSaved: (value) => name = value?.trim() ?? '',
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        decoration: const InputDecoration(labelText: 'Email'),
                                        keyboardType: TextInputType.emailAddress,
                                        onSaved: (value) => email = value?.trim() ?? '',
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Email wajib diisi' : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        decoration: const InputDecoration(labelText: 'Password'),
                                        obscureText: true,
                                        onSaved: (value) => password = value?.trim() ?? '',
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Password wajib diisi' : null,
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<UserRole>(
                                        value: role,
                                        items: const [
                                          DropdownMenuItem(value: UserRole.financeAdmin, child: Text('Admin Keuangan')),
                                          DropdownMenuItem(value: UserRole.contentAdmin, child: Text('Admin Konten')),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            role = value;
                                          }
                                        },
                                        decoration: const InputDecoration(labelText: 'Peran'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState?.validate() ?? false) {
                                      formKey.currentState?.save();
                                      try {
                                        final success = await auth.registerAdmin(
                                          name: name,
                                          email: email,
                                          password: password,
                                          role: role,
                                          isAdmin: auth.isSuperAdmin,
                                        );
                                        if (!success) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Email sudah terdaftar.')),
                                            );
                                          }
                                        } else {
                                          await donation.addAuditLogEntry(
                                            '[${DateTime.now().toIso8601String()}] ${auth.name ?? 'Admin'} mendaftarkan Admin baru: $name.',
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Admin baru berhasil ditambahkan.')),
                                            );
                                          }
                                          Navigator.pop(dialogContext);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString())),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('Simpan'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Tambah Admin Baru'),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }

        final user = users[index - 1];
        final email = user['email'] ?? '';
        final donations = donation.totalDonatedBy(email);
        final isBanned = user['banned'] == 'true';
        final roleLabel = _displayRoleLabel(user['roleLabel'] ?? 'Member');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(email),
                const SizedBox(height: 4),
                Text('Peran: $roleLabel'),
                const SizedBox(height: 4),
                Text('Total donasi: Rp ${donations.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Status akun: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      isBanned ? 'Ditangguhkan' : 'Aktif',
                      style: TextStyle(
                        color: isBanned ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: auth.isSuperAdmin
                          ? () async {
                              final chosenRole = await showDialog<UserRole>(
                                context: context,
                                builder: (dialogContext) {
                                  return SimpleDialog(
                                    title: const Text('Ubah Peran'),
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () => Navigator.pop(dialogContext, UserRole.financeAdmin),
                                        child: const Text('Admin Keuangan'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () => Navigator.pop(dialogContext, UserRole.contentAdmin),
                                        child: const Text('Admin Konten'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () => Navigator.pop(dialogContext, UserRole.member),
                                        child: const Text('Donatur'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (chosenRole != null) {
                                try {
                                  await auth.updateUserRole(email, chosenRole, isAdmin: auth.isSuperAdmin);
                                  await donation.addAuditLogEntry(
                                    '[${DateTime.now().toIso8601String()}] ${auth.name ?? 'Admin'} mengubah peran $email menjadi ${chosenRole.label}.',
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Peran user berhasil diubah.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                      child: const Text('Ubah Peran'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: Icon(isBanned ? Icons.lock_open : Icons.block),
                      onPressed: () async {
                        try {
                          await auth.toggleBanUser(email, isAdmin: auth.isAdmin);
                          await donation.addAuditLogEntry(
                            '[${DateTime.now().toIso8601String()}] ${auth.name ?? 'Admin'} mengubah status akun $email menjadi ${isBanned ? 'Aktif' : 'Ditangguhkan'}.',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isBanned ? 'Pengguna diaktifkan kembali.' : 'Pengguna diblokir.')),
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
                      label: Text(isBanned ? 'Buka Blokir' : 'Suspend / Blokir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuditTab extends StatelessWidget {
  final DonationProvider donation;

  const _AuditTab({required this.donation});

  @override
  Widget build(BuildContext context) {
    final logs = donation.auditLogs;
    if (logs.isEmpty) {
      return const Center(
        child: Text('Belum ada catatan audit.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final raw = logs[index];
        final match = RegExp(r'^\[(.*?)\]\s*(.*)').firstMatch(raw);
        final timestampText = match?.group(1) ?? '';
        final message = match?.group(2) ?? raw;
        final timestamp = DateTime.tryParse(timestampText)?.toLocal();
        final subtitle = timestamp != null
            ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(timestamp)
            : '';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(message),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          leading: const Icon(Icons.history, color: Color(0xFF17A2B8)),
        );
      },
    );
  }
}
