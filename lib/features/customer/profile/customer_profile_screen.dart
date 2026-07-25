import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/user_service.dart';
import '../../../shared/widgets/custom_button.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile(UserModel currentUser) async {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = currentUser.copyWith(
        name: newName,
        phoneNumber: newPhone,
      );

      final userService = UserService();
      await userService.updateUser(updatedUser);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui! Silakan refresh jika perlu.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authProvider.logout();
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Batal Edit' : 'Edit Profil',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing && user != null) {
                  _nameController.text = user.name;
                  _phoneController.text = user.phoneNumber;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Avatar Header Card
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Pemain Padel',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Profile Form Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Akun', style: AppTextStyles.subheading),
                      const SizedBox(height: 16),

                      // Name Field
                      const Text('Nama Lengkap', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      _isEditing
                          ? TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: const Icon(Icons.person_outline, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          : _buildInfoTile(Icons.person_outline, user?.name ?? '-'),

                      const SizedBox(height: 16),

                      // Email Field (Read Only)
                      const Text('Email', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      _buildInfoTile(Icons.email_outlined, user?.email ?? '-'),

                      const SizedBox(height: 16),

                      // Phone Field
                      const Text('Nomor Telepon', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      _isEditing
                          ? TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nomor HP',
                                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          : _buildInfoTile(Icons.phone_outlined, (user?.phoneNumber.isNotEmpty ?? false) ? user!.phoneNumber : 'Belum diisi'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Edit Button
              if (_isEditing && user != null) ...[
                CustomButton(
                  text: 'Simpan Perubahan',
                  icon: Icons.check,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : () => _handleSaveProfile(user),
                ),
                const SizedBox(height: 16),
              ],

              // Logout Button
              CustomButton(
                text: 'Keluar (Logout)',
                icon: Icons.logout,
                type: ButtonType.secondary,
                onPressed: () => _showLogoutDialog(context, authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
