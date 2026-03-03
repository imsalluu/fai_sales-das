import 'package:fai_dashboard_sales/features/admin/presentation/providers/admin_provider.dart';
import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:fai_dashboard_sales/models/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformancePage extends ConsumerWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(performanceProvider);

    return performanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text("Error loading performance: $err", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(performanceProvider),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
      data: (performance) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIndividualMemberPerformanceTable(performance),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndividualMemberPerformanceTable(List<IndividualPerformance> performance) {
    return _buildSection(
      "Individual Members Performance Detail",
      Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _TableHeader("Name")),
                Expanded(flex: 2, child: _TableHeader("Total Queries")),
                Expanded(flex: 2, child: _TableHeader("Converted Queries")),
                Expanded(flex: 2, child: _TableHeader("Conversion Rate (%)")),
              ],
            ),
          ),
          // Rows
          ...performance.map((p) => Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(p.name, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("${p.totalQueries}", style: const TextStyle(color: AppTheme.textColor)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("${p.convertedQueries}", style: const TextStyle(color: AppTheme.textColor)),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("${p.conversionRate}%", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
      scrollable: false,
    );
  }

  Widget _buildSection(String title, Widget content, {bool scrollable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: scrollable 
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              )
            : content,
        ),
      ],
    );
  }
}


class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.mutedTextColor));
}


