import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../view_models/today_view_model.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../core/theme/theme_provider.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodayViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final today = vm.today;

    if (vm.isLoading || today == null) {
      return Center(child: CupertinoActivityIndicator(color: colors.primary));
    }

    final completion = today.completionPercentage;

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Today', style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                Text(
                  _getFormattedDate().toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCompletionHeader(context, colors, completion),
                const SizedBox(height: 32),
                Text(
                  'GOALS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...today.activeZones.map((zone) => _buildZoneTaskTile(context, colors, today, zone)),
                const SizedBox(height: 120), // Bottom padding for tab bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionHeader(BuildContext context, dynamic colors, double percentage) {
    final isDark = colors.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: colors.textPrimary.withAlpha(13), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  percentage >= 1.0 ? 'Day Completed!' : 'Daily Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 1.0 ? colors.success : colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomLinearProgressIndicator(
              value: percentage,
              backgroundColor: colors.progressBackground,
              valueColor: percentage >= 1.0 ? colors.success : colors.progressActive,
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneTaskTile(BuildContext context, dynamic colors, dynamic day, ZoneType zone) {
    final isCompleted = day.isZoneCompleted(zone);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            _buildStatusIcon(colors, isCompleted),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getZoneLabel(zone),
                    style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 13,
                      color: isCompleted ? colors.success : colors.textMuted,
                      fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            CNButton(
              onPressed: () {
                // Future: Open Camera or Bottom Sheet
              },
              label: isCompleted ? 'View' : 'Add',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(dynamic colors, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? colors.success.withAlpha(26) : colors.progressBackground,
        border: Border.all(color: isCompleted ? colors.success : colors.border, width: 2),
      ),
      child: isCompleted ? Icon(CupertinoIcons.checkmark, size: 18, color: colors.success) : null,
    );
  }

  String _getZoneLabel(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return 'Face Photo';
      case ZoneType.bodyFront:
        return 'Body Front Photo';
      case ZoneType.bodySide:
        return 'Body Side Photo';
      case ZoneType.bodyBack:
        return 'Body Back Photo';
      case ZoneType.measurements:
        return 'Measurements';
      case ZoneType.macronutrients:
        return 'Macronutrients';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}

class CustomLinearProgressIndicator extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;

  const CustomLinearProgressIndicator({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    required this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: minHeight,
      width: double.infinity,
      color: backgroundColor,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(color: valueColor),
      ),
    );
  }
}
