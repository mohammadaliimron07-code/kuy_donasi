import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/providers/campaign_provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';

class TransferDonationScreen extends StatefulWidget {
  final Campaign campaign;

  const TransferDonationScreen({super.key, required this.campaign});

  @override
  State<TransferDonationScreen> createState() => _TransferDonationScreenState();
}

class _TransferDonationScreenState extends State<TransferDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedPaymentMethod = 'Bank BRI';
  bool _proofUploaded = false;
  String? _proofName;
  bool _isSending = false;
  late final int _uniqueCode;

  static const List<Map<String, String>> _bankOptions = [
    {
      'name': 'Bank BRI',
      'subtitle': 'Transfer Bank Manual',
      'details': 'No. Rekening: 1234-01-000000-50-1\na.n. Yayasan KuyDonasi',
    },
    {
      'name': 'Bank Mandiri',
      'subtitle': 'Transfer Bank Manual',
      'details': 'No. Rekening: 1550-22-000000-60-2\na.n. Yayasan KuyDonasi',
    },
    {
      'name': 'Bank BCA',
      'subtitle': 'Transfer Bank Manual',
      'details': 'No. Rekening: 2244-55-000000-77-3\na.n. Yayasan KuyDonasi',
    },
    {
      'name': 'Bank BNI',
      'subtitle': 'Transfer Bank Manual',
      'details': 'No. Rekening: 6464-88-000000-99-4\na.n. Yayasan KuyDonasi',
    },
    {
      'name': 'Bank BSI',
      'subtitle': 'Transfer Bank Manual',
      'details': 'No. Rekening: 3100-11-000000-02-5\na.n. Yayasan KuyDonasi',
    },
  ];

  static const List<Map<String, String>> _instantOptions = [
    {
      'name': 'QRIS',
      'subtitle': 'Pembayaran Instan',
      'details': 'Scan QRIS di aplikasi e-wallet Anda untuk pembayaran instan.',
    },
    {
      'name': 'GoPay',
      'subtitle': 'Dompet Digital',
      'details': 'Bayar langsung menggunakan aplikasi GoPay Anda.',
    },
    {
      'name': 'ShopeePay',
      'subtitle': 'Dompet Digital',
      'details': 'Bayar langsung menggunakan aplikasi ShopeePay Anda.',
    },
    {
      'name': 'Dana',
      'subtitle': 'Dompet Digital',
      'details': 'Bayar langsung menggunakan aplikasi Dana Anda.',
    },
  ];

  Map<String, String> get _selectedPaymentInfo {
    return [..._bankOptions, ..._instantOptions].firstWhere(
      (option) => option['name'] == _selectedPaymentMethod,
      orElse: () => _bankOptions.first,
    );
  }

  bool get _isBankMethod => _selectedPaymentMethod.startsWith('Bank ');

  @override
  void initState() {
    super.initState();
    _uniqueCode = 100 + DateTime.now().millisecond % 900;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  double get _baseAmount {
    final input = _amountController.text.replaceAll(RegExp('[^0-9]'), '');
    return double.tryParse(input) ?? 0.0;
  }

  double get _totalAmount => _baseAmount + _uniqueCode;

  Future<void> _uploadProof() async {
    setState(() {
      _proofUploaded = true;
      _proofName = 'bukti-transfer-2026.png';
    });
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_proofUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah bukti transfer terlebih dahulu.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final donationProvider = context.read<DonationProvider>();
    final email = auth.email ?? 'Donatur Tidak Dikenal';
    final campaignTitle = widget.campaign.title;
    final category = widget.campaign.category;
    final amount = _totalAmount;
    final paymentMethod = _selectedPaymentMethod;

    setState(() {
      _isSending = true;
    });

    final success = await donationProvider.addTransaction(
      campaignTitle: campaignTitle,
      category: category,
      amount: amount,
      userEmail: email,
      paymentMethod: paymentMethod,
      receiptUrl: _proofName,
    );

    setState(() {
      _isSending = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donasi dikirim! Menunggu verifikasi admin.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruksi Transfer'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.teal[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.campaign.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Donasi (Rp)',
                        hintText: 'Masukkan nominal donasi Anda',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final cleaned = value?.replaceAll(RegExp('[^0-9]'), '');
                        if (cleaned == null || cleaned.isEmpty) {
                          return 'Nominal wajib diisi';
                        }
                        final amount = double.tryParse(cleaned);
                        if (amount == null || amount < 1000) {
                          return 'Masukkan nominal minimal Rp 1.000';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total unik: ${_formatCurrency(_totalAmount)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 6),
                    Text('Kode unik: $_uniqueCode', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Silahkan transfer ke rekening berikut:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.account_balance, color: Colors.blue),
                title: Text('Bank BRI (KuyDonasi Yayasan)'),
                subtitle: Text('No. Rekening: 1234-01-000000-50-1\na.n. Yayasan KuyDonasi'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Pilih salah satu metode pembayaran yang paling nyaman untuk Anda.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Transfer Bank Manual', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: _bankOptions.map((option) {
                final selected = option['name'] == _selectedPaymentMethod;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = option['name']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.teal[50] : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? Colors.teal : Colors.grey.shade300,
                        width: selected ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      minLeadingWidth: 0,
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? Colors.teal : Colors.transparent,
                          border: Border.all(
                            color: selected ? Colors.teal : Colors.grey.shade500,
                          ),
                        ),
                        child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                      title: Text(option['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(option['subtitle']!),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Dompet Digital & Pembayaran Instan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: _instantOptions.map((option) {
                final selected = option['name'] == _selectedPaymentMethod;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = option['name']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.teal[50] : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? Colors.teal : Colors.grey.shade300,
                        width: selected ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      minLeadingWidth: 0,
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? Colors.teal : Colors.transparent,
                          border: Border.all(
                            color: selected ? Colors.teal : Colors.grey.shade500,
                          ),
                        ),
                        child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                      title: Text(option['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(option['subtitle']!),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detail Metode Terpilih', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _selectedPaymentInfo['details']!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isBankMethod
                          ? 'Catatan: Pastikan Anda menyimpan dan mengunggah bukti transfer setelah melakukan pembayaran.'
                          : 'Pembayaran instan biasanya diverifikasi lebih cepat. Unggah bukti jika tersedia.',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _proofUploaded ? null : _uploadProof,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                ),
                child: Center(
                  child: _proofUploaded
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              _proofName ?? 'Bukti transfer sudah terunggah',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Upload Bukti Transfer di Sini', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSending ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Saya Sudah Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
