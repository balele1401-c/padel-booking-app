import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/court_model.dart';
import '../../../../providers/court_provider.dart';
import '../../../../shared/widgets/custom_button.dart';

class AdminCourtFormDialog extends StatefulWidget {
  final CourtModel? court;

  const AdminCourtFormDialog({
    super.key,
    this.court,
  });

  @override
  State<AdminCourtFormDialog> createState() => _AdminCourtFormDialogState();
}

class _AdminCourtFormDialogState extends State<AdminCourtFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _photoUrlController;
  late TextEditingController _priceController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSubmitting = false;

  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1622163642988-1ea32b0da6b9?q=80&w=1171&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?q=80&w=1170&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=1170&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.court;
    _nameController = TextEditingController(text: c?.name ?? '');
    _photoUrlController = TextEditingController(
      text: c?.imageUrl ?? _presetImages[0],
    );
    _priceController = TextEditingController(
      text: c != null ? c.pricePerHour.toInt().toString() : '150000',
    );
    _openTimeController = TextEditingController(text: c?.openTime ?? '08:00');
    _closeTimeController = TextEditingController(text: c?.closeTime ?? '22:00');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    _priceController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final courtProvider = Provider.of<CourtProvider>(context, listen: false);

    final double price = double.tryParse(_priceController.text.trim()) ?? 150000;

    final newCourt = CourtModel(
      id: widget.court?.id ?? '',
      name: _nameController.text.trim(),
      imageUrl: _photoUrlController.text.trim(),
      pricePerHour: price,
      openTime: _openTimeController.text.trim(),
      closeTime: _closeTimeController.text.trim(),
      isActive: _isActive,
      description: _descriptionController.text.trim(),
    );

    bool success;
    if (widget.court == null) {
      success = await courtProvider.addCourt(newCourt);
    } else {
      success = await courtProvider.updateCourt(newCourt);
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.court == null
                ? 'Lapangan berhasil ditambahkan!'
                : 'Data lapangan berhasil diperbarui!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(courtProvider.errorMessage ?? 'Gagal menyimpan data.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.court != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Data Lapangan' : 'Tambah Lapangan Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Name Field
                const Text('Nama Lapangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Lapangan Padel A',
                    prefixIcon: const Icon(Icons.sports_tennis, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama lapangan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Photo URL Field & Live Preview
                const Text('URL Foto Lapangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _photoUrlController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.image_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'URL foto wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Preset Images Selector
                Row(
                  children: [
                    const Text('Pilihan Preset: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    ...List.generate(_presetImages.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _photoUrlController.text = _presetImages[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Foto ${index + 1}',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Image Live Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Image.network(
                      _photoUrlController.text.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey, size: 36),
                              SizedBox(height: 4),
                              Text('URL gambar tidak valid', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Price Per Hour Field
                const Text('Harga per Jam (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '150000',
                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Harga per jam wajib diisi';
                    }
                    if (double.tryParse(val.trim()) == null) {
                      return 'Masukkan angka nominal yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Operating Hours (Open & Close Time)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Buka', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _openTimeController,
                            decoration: InputDecoration(
                              hintText: '08:00',
                              prefixIcon: const Icon(Icons.access_time, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _closeTimeController,
                            decoration: InputDecoration(
                              hintText: '22:00',
                              prefixIcon: const Icon(Icons.access_time_filled, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status Lapangan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(
                            _isActive ? 'Aktif (Dapat dibooking customer)' : 'Nonaktif (Tersembunyi dari customer)',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isActive ? AppColors.confirmedText : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isActive,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                const Text('Deskripsi (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Fasilitas, tipe rumput sintetis, pencahayaan, dll.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                CustomButton(
                  text: isEdit ? 'Simpan Perubahan' : 'Tambah Lapangan',
                  icon: isEdit ? Icons.save : Icons.add,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
