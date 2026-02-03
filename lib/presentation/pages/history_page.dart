import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../view_models/history_view_model.dart';
import '../../core/theme/theme_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('History', style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          if (vm.isLoading)
            SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(color: colors.primary)),
            )
          else if (vm.history.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No records yet', style: TextStyle(color: colors.textMuted)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final day = vm.history[index];
                  return _buildHistoryItem(context, colors, day);
                }, childCount: vm.history.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic colors, dynamic day) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(day.date),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(day.completionPercentage * 100).toInt()}% Completion',
                    style: TextStyle(
                      fontSize: 14,
                      color: day.completionPercentage >= 1.0 ? colors.success : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, size: 20, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
