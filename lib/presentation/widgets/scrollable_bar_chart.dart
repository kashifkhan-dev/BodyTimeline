import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../view_models/stats_view_model.dart';
import '../../core/theme/color_palette.dart';
import '../../domain/value_objects/measurement_type.dart';

class ScrollableBarChart extends StatefulWidget {
  final String metricType;
  final MeasurementType? measurementType;
  final String label;
  final String unit;
  final AppColors colors;

  const ScrollableBarChart({
    super.key,
    required this.metricType,
    this.measurementType,
    required this.label,
    required this.unit,
    required this.colors,
  });

  @override
  State<ScrollableBarChart> createState() => _ScrollableBarChartState();
}

class _ScrollableBarChartState extends State<ScrollableBarChart> {
  final ScrollController _scrollController = ScrollController();
  int _daysToShow = 30; // Still used for internal viewport if needed, but we show all points now

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Current requirement: "Infinite horizontal scrolling still applies"
    // With real data only, we just show everything we have.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatsViewModel>();

    // points is [Oldest, ..., Today]
    final points = vm.getDataPoints(widget.metricType, measurementType: widget.measurementType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              if (points.isNotEmpty && points.last.value > 0)
                Text(
                  'Today: ${points.last.value.toStringAsFixed(1)} ${widget.unit}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.colors.primary),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 240,
          decoration: BoxDecoration(color: widget.colors.card, borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              reverse: true, // Today on the right
              child: SizedBox(
                width: points.length * 60.0 + 20,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(points),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => widget.colors.textPrimary,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        fitInsideVertically: true, // Prevent vertical clipping
                        fitInsideHorizontally: true, // Prevent horizontal clipping
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final point = points[groupIndex];
                          return BarTooltipItem(
                            '${_formatDate(point.date)}\n',
                            TextStyle(color: widget.colors.background, fontWeight: FontWeight.bold, fontSize: 13),
                            children: [
                              TextSpan(
                                text: '${point.value.toStringAsFixed(1)} ${widget.unit}',
                                style: TextStyle(
                                  color: widget.colors.background.withAlpha(200),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) return const SizedBox.shrink();
                            final date = points[index].date;

                            // Show labels every 3 days for readability
                            if (index % 3 != 0 && index != points.length - 1) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatDate(date),
                                style: TextStyle(
                                  color: widget.colors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(points.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: points[index].value,
                            color: widget.colors.primary,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _getMaxY(points),
                              color: widget.colors.surface.withAlpha(80),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY(List<StatsPoint> points) {
    double maxVal = 10;
    for (var p in points) {
      if (p.value > maxVal) maxVal = p.value;
    }
    return maxVal * 1.5; // High headroom for tooltips
  }
}
