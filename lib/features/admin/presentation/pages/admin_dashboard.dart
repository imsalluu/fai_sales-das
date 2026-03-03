import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:fai_dashboard_sales/features/admin/presentation/pages/member_management_page.dart';
import 'package:fai_dashboard_sales/features/admin/presentation/pages/performance_page.dart';
import 'package:fai_dashboard_sales/features/admin/presentation/pages/query_management_page.dart';
import 'package:fai_dashboard_sales/shared/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/dashboard_layout.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../widgets/performance_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/admin_provider.dart';
import '../../../../models/executive_stats.dart';
import '../widgets/trend_chart.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);
    final statsAsync = ref.watch(executiveStatsProvider);

    return DashboardLayout(
      title: _getSectionTitle(currentSection),
      child: statsAsync.when(
        data: (stats) => _buildSectionContent(currentSection, stats),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  String _getSectionTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.overview: return "Executive Dashboard";
      case DashboardSection.team: return "Sales Team Management";
      case DashboardSection.queries: return "Sales";
      case DashboardSection.analytics: return "Performance Statistics";
      default: return "Admin Center";
    }
  }

  Widget _buildSectionContent(DashboardSection section, ExecutiveStats stats) {
    switch (section) {
      case DashboardSection.overview: return _buildOverview(stats);
      case DashboardSection.team: return const MemberManagementPage();
      case DashboardSection.queries: return const QueryManagementPage();
      case DashboardSection.analytics: return const PerformancePage();
      default: return _buildOverview(stats);
    }
  }

  Widget _buildOverview(ExecutiveStats stats) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatGrid(stats.summary),
          const SizedBox(height: 48),
          _buildSection(
            "Monthly Sales Trends",
            SizedBox(height: 300, child: TrendChart(
              color: const Color(0xFF6366F1),
              spots: stats.trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.sales.toDouble())).toList(),
              labels: stats.trends.map((t) => t.month).toList(),
            )),
          ),
          const SizedBox(height: 48),
          _buildMarketActivitySection(stats.marketActivity),
          const SizedBox(height: 48),
          _buildIndividualProfilePerformanceTable(stats.profilePerformance),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatGrid(DashboardSummary summary) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 32,
      mainAxisSpacing: 32,
      shrinkWrap: true,
      childAspectRatio: 2.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: "Total Queries",
          value: summary.totalQueries.toString(),
          icon: Icons.question_answer_rounded,
          gradientColors: [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
          subtitle: "Total inquiries received",
          subtitleIcon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Total Briefs",
          value: summary.totalBriefs.toString(),
          icon: Icons.assignment_rounded,
          gradientColors: [const Color(0xFF059669), const Color(0xFF34D399)],
          subtitle: "Project briefs submitted",
          subtitleIcon: const Icon(Icons.description_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Quotes Sent",
          value: summary.quotesSent.toString(),
          icon: Icons.request_quote_rounded,
          gradientColors: [const Color(0xFFDC2626), const Color(0xFFF87171)],
          subtitle: "Pricing proposals active",
          subtitleIcon: const Icon(Icons.send_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Final Converted",
          value: summary.finalConverted.toString(),
          icon: Icons.handshake_rounded,
          gradientColors: [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],
          subtitle: "Successfully closed deals",
          subtitleIcon: const Icon(Icons.verified_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Total Interactions",
          value: summary.totalInteractions.toString(),
          icon: Icons.forum_rounded,
          gradientColors: [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
          subtitle: "Customer messages",
          subtitleIcon: const Icon(Icons.chat_bubble_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Conversion Rate",
          value: summary.conversionRate,
          icon: Icons.analytics_rounded,
          gradientColors: [const Color(0xFFD97706), const Color(0xFFFBBF24)],
          subtitle: "Closing efficiency",
          subtitleIcon: const Icon(Icons.trending_up_rounded, color: Colors.white70, size: 12),
        ),
      ],
    );
  }


  Widget _buildMarketActivitySection(List<MarketActivity> activity) {
    return _buildSection("Market Activity & Performance Breakdown", 
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: _buildActionCountTable(activity),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCountTable(List<MarketActivity> activity) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1E293B), AppTheme.cardColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Center(
            child: Text(
              "Market Activity Breakdown",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border.symmetric(vertical: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activity.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.03)),
            itemBuilder: (context, index) {
              final item = activity[index];
              final color = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.label, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(
                      "${item.count}",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualProfilePerformanceTable(List<ProfilePerformanceData> performance) {
    return _buildSection(
      "Individual Profile Performance",
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
                Expanded(flex: 3, child: _TableHeader("Profile Name")),
                Expanded(flex: 2, child: _TableHeader("Total Queries")),
                Expanded(flex: 2, child: _TableHeader("Converted")),
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
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppTheme.secondaryColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Text(p.profileName, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("${p.conversionRate}%", style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
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
          child: content,
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
