import 'package:flutter/material.dart' hide Feedback;
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'feature';
  String _selectedPriority = 'medium';
  bool _isLoading = false;

  final Map<String, String> _typeLabels = {
    'feature': 'Saran Fitur Baru',
    'improvement': 'Saran Perbaikan',
    'bug': 'Laporan Bug',
  };

  final Map<String, String> _priorityLabels = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
  };

  final Map<String, IconData> _typeIcons = {
    'feature': Icons.lightbulb_outline,
    'improvement': Icons.tune,
    'bug': Icons.bug_report_outlined,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final donation = context.read<DonationProvider>();
    final success = await donation.submitFeedback(
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Feedback Anda telah dikirim.'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _selectedType = 'feature');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Bangun Bersama',
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
                    'Bantu kami mengembangkan KuyDonasi menjadi lebih baik',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color(0xFF0D6E63).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '💡 Ide Anda Sangat Berharga',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D6E63),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Umpan balik Anda membantu kami membuat KuyDonasi lebih baik untuk semua orang. Jangan ragu untuk berbagi saran, laporan bug, atau ide fitur baru Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Feedback',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _typeLabels.entries.map((entry) {
                            final isSelected = _selectedType == entry.key;
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _typeIcons[entry.key],
                                    size: 16,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(entry.value),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = entry.key;
                                });
                              },
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: const Color(0xFF0D6E63),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Tingkat Prioritas',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: _priorityLabels.entries.map((entry) {
                            final isSelected = _selectedPriority == entry.key;
                            return ChoiceChip(
                              label: Text(entry.value),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPriority = entry.key;
                                });
                              },
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: const Color(0xFF0D6E63),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Judul Feedback',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Ringkas masalah atau saran Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Judul tidak boleh kosong';
                            }
                            if (value.length < 5) {
                              return 'Judul minimal 5 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Deskripsi Detail',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Jelaskan feedback Anda secara detail...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi tidak boleh kosong';
                            }
                            if (value.length < 10) {
                              return 'Deskripsi minimal 10 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitFeedback,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isLoading ? 'Mengirim...' : 'Kirim Feedback'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6E63),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Feedback
                  const Text(
                    'Feedback Terbaru Anda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Consumer<DonationProvider>(
                    builder: (context, donation, _) {
                      if (donation.feedbackList.isEmpty) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada feedback',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: donation.feedbackList.map((feedback) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FeedbackCard(feedback: feedback),
                          );
                        }).toList(),
                      );
                    },
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

class _FeedbackCard extends StatelessWidget {
  final Feedback feedback;

  const _FeedbackCard({required this.feedback});

  Color _getStatusColor() {
    switch (feedback.status) {
      case 'Baru':
        return Colors.blue;
      case 'Ditinjau':
        return Colors.orange;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (feedback.type) {
      case 'feature':
        return Icons.lightbulb_outline;
      case 'improvement':
        return Icons.tune;
      case 'bug':
        return Icons.bug_report_outlined;
      default:
        return Icons.mail_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getTypeIcon(), color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feedback.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(feedback.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    feedback.status,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
