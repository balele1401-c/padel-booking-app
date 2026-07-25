import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/court_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/court_provider.dart';
import '../../../shared/widgets/court_card.dart';
import '../booking/court_detail_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courtProvider = Provider.of<CourtProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_tennis, color: AppColors.primary, size: 28),
            SizedBox(width: 8),
            Text(
              'Padel Booking',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.name ?? "Pemain Padel"}! 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih lapangan favoritmu dan jadwalkan permainan sekarang.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Daftar Lapangan Tersedia',
                style: AppTextStyles.subheading,
              ),
            ),

            // Real-Time Stream List of Active Courts
            Expanded(
              child: StreamBuilder<List<CourtModel>>(
                stream: courtProvider.activeCourtsStream,
                builder: (context, snapshot) {
                  debugPrint('🎨 DEBUG [CustomerHomeScreen]: StreamBuilder connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, hasError=${snapshot.hasError}');

                  // 1. Error State
                  if (snapshot.hasError) {
                    debugPrint('❌ DEBUG [CustomerHomeScreen]: StreamBuilder Error: ${snapshot.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(
                              'Gagal memuat data lapangan:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 2. Loading State (Only if we don't have data yet and connection is waiting)
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Memuat daftar lapangan...',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  }

                  final courts = snapshot.data ?? [];
                  debugPrint('🎨 DEBUG [CustomerHomeScreen]: Rendering courts list, count=${courts.length}');

                  // 3. Empty State
                  if (courts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sports_tennis_outlined,
                                size: 56,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Lapangan Tersedia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Saat ini belum ada data lapangan padel yang didaftarkan oleh admin.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 4. Data Available State (List View)
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      if (index < 0 || index >= courts.length) {
                        return const SizedBox.shrink();
                      }
                      final court = courts[index];
                      return CourtCard(
                        key: ValueKey(court.id),
                        court: court,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourtDetailScreen(court: court),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
