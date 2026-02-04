import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../view_models/progress_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Progress', style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          if (vm.isLoading)
            SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(color: colors.primary)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProgressSummary(colors),
                  const SizedBox(height: 32),
                  Text(
                    'TRENDS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(colors, 'Weight Log', 'No recent weight data'),
                  _buildPlaceholderCard(colors, 'Macro Consistency', '75% accuracy over last 7 days'),
                  _buildPlaceholderCard(colors, 'Photo Streak', '12 days strong'),
                ]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Completion',
            style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            '85%',
            style: TextStyle(color: CupertinoColors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(AppColors colors, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.primary.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: Icon(CupertinoIcons.graph_square, color: colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
