import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../models/analytics.dart';

class PerformanceChart extends StatelessWidget {
  final List<PerformanceData> data;

  const PerformanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Text(data[value.toInt()].memberName, style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          int index = entry.key;
          PerformanceData d = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                // toY: d.queries.toDouble(), 
                color: AppTheme.primaryColor.withOpacity(0.2), 
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), toY: double.infinity,
              ),
              BarChartRodData(
                toY: double.infinity,
                color: AppTheme.primaryColor, 
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
