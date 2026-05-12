import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kuydonasi/providers/donation_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all'; // all, verified, pending, failed
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final donation = context.watch<DonationProvider>();
    final numberFormat = NumberFormat('#,##0', 'id_ID');
    final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    // Filter transaksi
    var filteredTransactions = donation.transactions;

    if (_selectedFilter != 'all') {
      filteredTransactions = filteredTransactions
          .where((t) {
            if (_selectedFilter == 'verified') return t.status == 'Terverifikasi';
            if (_selectedFilter == 'pending') return t.status == 'Menunggu Verifikasi';
            if (_selectedFilter == 'failed') return t.status == 'Gagal';
            return true;
          })
          .toList();
    }

    if (_selectedCategory != 'all') {
      filteredTransactions = filteredTransactions
          .where((t) => t.category == _selectedCategory)
          .toList();
    }

    // Sort by date (newest first)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Calculate statistics
    final verifiedTotal = donation.transactions
        .where((t) => t.status == 'Terverifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);
    final pendingTotal = donation.transactions
        .where((t) => t.status == 'Menunggu Verifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${numberFormat.format(verifiedTotal.toInt())}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Menunggu Verifikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.schedule,
                                  color: Colors.orange.shade600,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${numberFormat.format(pendingTotal.toInt())}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          isSelected: _selectedFilter == 'all',
                          onTap: () {
                            setState(() => _selectedFilter = 'all');
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Terverifikasi',
                          isSelected: _selectedFilter == 'verified',
                          onTap: () {
                            setState(() => _selectedFilter = 'verified');
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Menunggu',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () {
                            setState(() => _selectedFilter = 'pending');
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Gagal',
                          isSelected: _selectedFilter == 'failed',
                          onTap: () {
                            setState(() => _selectedFilter = 'failed');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Transactions List
            if (filteredTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai berdonasi sekarang untuk melihat riwayat transaksi Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final transaction = filteredTransactions[idx];
                    return _TransactionCard(
                      transaction: transaction,
                      dateFormat: dateFormat,
                      numberFormat: numberFormat,
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.indigo.shade400,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final dynamic transaction;
  final DateFormat dateFormat;
  final NumberFormat numberFormat;

  const _TransactionCard({
    required this.transaction,
    required this.dateFormat,
    required this.numberFormat,
  });

  Color _getStatusColor() {
    if (transaction.status == 'Terverifikasi') return Colors.green;
    if (transaction.status == 'Menunggu Verifikasi') return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (transaction.status == 'Terverifikasi') return Icons.check_circle;
    if (transaction.status == 'Menunggu Verifikasi') return Icons.schedule;
    return Icons.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.volunteer_activism, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.campaignTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              transaction.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: _getStatusColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaction.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${numberFormat.format(transaction.amount.toInt())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
