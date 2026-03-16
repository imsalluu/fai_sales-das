import 'package:intl/intl.dart';
import 'package:fai_dashboard_sales/features/admin/presentation/pages/query_management_page.dart';
import 'package:fai_dashboard_sales/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/widgets/dashboard_layout.dart';
import '../../../../models/query.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../core/theme/app_theme.dart';

import '../providers/sales_provider.dart';
import 'package:fai_dashboard_sales/features/admin/presentation/providers/admin_provider.dart';
import '../../../../models/sales_stats.dart';

class SalesDashboard extends ConsumerWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);

    return DashboardLayout(
      title: _getSectionTitle(currentSection),
      child: _buildSectionContent(currentSection, ref),
    );
  }

  String _getSectionTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.salesOverview: return "Sales Performance";
      case DashboardSection.addLead: return "Register New Query";
      case DashboardSection.tasks: return "Task Board";
      case DashboardSection.mySales: return "Sales";
      default: return "Sales Center";
    }
  }

  Widget _buildSectionContent(DashboardSection section, WidgetRef ref) {
    switch (section) {
      case DashboardSection.salesOverview: return const _OverviewTab();
      case DashboardSection.addLead: return const _QueryFormTab();
      case DashboardSection.tasks: return const _TasksTab();
      case DashboardSection.mySales: 
        return QueryManagementPage(
          onAddOverride: () => ref.read(navigationProvider.notifier).state = DashboardSection.addLead,
        );
      default: return const _OverviewTab();
    }
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(salesStatsProvider);
    
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context, ref, user),
            const SizedBox(height: 32),
            _buildStatsGrid(context, stats.stats),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildPerformanceChart(stats.weeklyActivity)),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildQuickActions(stats.counters)),
              ],
            ),
            const SizedBox(height: 32),
            _buildRecentActivitySection(context, stats.recentOpportunities),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, WidgetRef ref, User? user) {
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    
    final years = List.generate(5, (index) => DateTime.now().year - index);
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: AppTheme.softShadow,
        image: DecorationImage(
          image: const NetworkImage("https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2000"),
          fit: BoxFit.cover,
          opacity: 0.05,
          colorFilter: ColorFilter.mode(AppTheme.primaryColor.withOpacity(0.1), BlendMode.colorBurn),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18)),
              const SizedBox(height: 8),
              Text(user?.name ?? "Sales Guru", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text("ID: ${user?.id ?? 'N/A'}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 16),
                    SizedBox(width: 8),
                    Text("Manage your daily progress with real-time data", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          
          // Date Filter Section
          Row(
            children: [
              // Month Dropdown
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    dropdownColor: AppTheme.cardColor,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(months[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedMonthProvider.notifier).update(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Year Dropdown
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    dropdownColor: AppTheme.cardColor,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedYearProvider.notifier).update(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStatsSummary stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;
      return GridView.count(
        crossAxisCount: isSmall ? 2 : 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        shrinkWrap: true,
        childAspectRatio: 1.8,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatCard(title: "Total Queries", value: stats.totalQueries.toString(), icon: Icons.forum_rounded, color: Colors.blue, trend: ""),
          _StatCard(title: "Converted", value: stats.converted.toString(), icon: Icons.check_circle_rounded, color: Colors.green, trend: ""),
          _StatCard(title: "Quote Sent", value: stats.quoteSent.toString(), icon: Icons.description_rounded, color: Colors.orange, trend: ""),
          _StatCard(title: "Response Rate", value: stats.responseRate, icon: Icons.bolt_rounded, color: Colors.purple, trend: ""),
        ],
      );
    });
  }

  Widget _buildPerformanceChart(List<WeeklyActivity> activity) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Query Activity (Weekly)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(Icons.more_horiz_rounded, color: AppTheme.mutedTextColor),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) {
                        if (val >= 0 && val < activity.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(activity[val.toInt()].day, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)));
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: activity.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.secondaryColor.withOpacity(0.0)])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DashboardCounters counters) {
    return Column(
      children: [
        _ActionItem(title: "Potential Client", count: counters.potentialClients.toString(), icon: Icons.pending_actions_rounded, color: Colors.orange),
        const SizedBox(height: 20),
        _ActionItem(title: "Follow-ups Today", count: counters.followupsToday.toString(), icon: Icons.notifications_active_rounded, color: Colors.red),
        const SizedBox(height: 20),
        _ActionItem(title: "High Value Leads", count: counters.highValueLeads.toString(), icon: Icons.diamond_rounded, color: Colors.cyan),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, List<Opportunity> opportunities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Opportunities", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: opportunities.isEmpty 
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text("No recent opportunities found", style: TextStyle(color: AppTheme.mutedTextColor))),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opportunities.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final opp = opportunities[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 20),
                      ),
                      title: Row(
                        children: [
                          Text(opp.clientName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 8),
                          Text("• ${opp.country}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(opp.profileName.replaceAll('_', ' '), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(opp.serviceLine.replaceAll('_', ' '), style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(opp.createdAt),
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          opp.queryStatus.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
              ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
              Text(trend, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _ActionItem({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 20),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _QueryFormTab extends ConsumerStatefulWidget {
  const _QueryFormTab();

  @override
  ConsumerState<_QueryFormTab> createState() => _QueryFormTabState();
}

class _QueryFormTabState extends ConsumerState<_QueryFormTab> {
  final _formKey = GlobalKey<FormState>();
  // final _api = MockApiService(); // Removed
  
  final _clientNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _quoteController = TextEditingController();
  final _specialCommentController = TextEditingController();
  final _monitoringRemarkController = TextEditingController();
  
  String _selectedProfile = 'NONE';
  String _selectedSource = 'NONE';
  String _selectedService = 'NONE';
  QueryStatus _selectedStatus = QueryStatus.none;
  ConversationStatus _selectedConvStatus = ConversationStatus.none;
  String? _selectedSoldBy;
  bool _f1Done = false;
  bool _f2Done = false;
  bool _f3Done = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return usersAsync.when(
      data: (users) => _buildContent(users),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading users: $err')),
    );
  }

  Widget _buildContent(List<User> users) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFormCard(users),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSaving ? [Colors.grey, Colors.blueGrey] : [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(_isSaving ? Icons.hourglass_top_rounded : Icons.add_task_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isSaving ? "Saving Query..." : "Query Registration", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_isSaving ? "Please wait while we secure your query data" : "Enter new query details for your company's records", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<User> users) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildInput("Client Name", _clientNameController, Icons.person_outline_rounded)),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Country", _countryController, Icons.public_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Profile Name", _selectedProfile, 
                    [
                      'NONE', 'Byte Craft', 'Drift AI', 'Fire AI', 'AI Byte', 
                      'AI Hook', 'AI Nest', 'Zebra App', 'Turtle App', 'Logic AI'
                    ], 
                    (v) => setState(() => _selectedProfile = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildDropdown("Source", _selectedSource, 
                    ['NONE', 'Query', 'Brief', 'Promoted', 'Direct Order', 'Referral'], 
                    (v) => setState(() => _selectedSource = v!))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Service Line", _selectedService, 
                    ['NONE', 'Custom Website', 'Mobile App', 'AI Mobile App', 'AI Website', 'AI Agent', 'Chatbot', 'Not Clarified', 'N8N Automation', 'Bux fixing'], 
                    (v) => setState(() => _selectedService = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Quote", _quoteController, Icons.description_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Query Status", _selectedStatus.name, 
                    QueryStatus.values.map((e) => e.name).toList(), 
                    (v) => setState(() => _selectedStatus = QueryStatus.values.firstWhere((e) => e.name == v)))),
                const SizedBox(width: 24),
                Expanded(child: _buildDropdown("Conversation Status", _selectedConvStatus.name, 
                    ConversationStatus.values.map((e) => e.name).toList(), 
                    (v) => setState(() => _selectedConvStatus = ConversationStatus.values.firstWhere((e) => e.name == v)))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Sold By", _selectedSoldBy ?? 'None', 
                    ['None', ...users.map((m) => m.id)], 
                    (v) => setState(() => _selectedSoldBy = v == 'None' ? null : v),
                    itemLabels: {for (var m in users) m.id: m.name, 'None': 'None'})),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Special Comment", _specialCommentController, Icons.comment_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            if (ref.watch(authProvider).user?.role == UserRole.sales_admin)
              _buildInput("Monitoring Remark", _monitoringRemarkController, Icons.remove_red_eye_outlined),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),
            _buildFollowUpSection(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isSaving ? "PROCESSING..." : "Register Query in System", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Follow-up Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fWidget(1, _f1Done, (v) => setState(() => _f1Done = v)),
            _fWidget(2, _f2Done, (v) => setState(() => _f2Done = v)),
            _fWidget(3, _f3Done, (v) => setState(() => _f3Done = v)),
          ],
        ),
      ],
    );
  }

  Widget _fWidget(int num, bool done, Function(bool) setDone) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? AppTheme.primaryColor.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("F-0$num", style: TextStyle(fontWeight: FontWeight.bold, color: done ? AppTheme.primaryColor : AppTheme.mutedTextColor)),
          Checkbox(
            value: done, 
            onChanged: (v) => setDone(v!),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctr, IconData icon) {
    return TextFormField(
      controller: ctr,
      style: const TextStyle(color: AppTheme.textColor),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.mutedTextColor),
      ),
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?) onChange, {Map<String, String>? itemLabels}) {
    return DropdownButtonFormField<String>(
      initialValue: val,
      dropdownColor: AppTheme.cardColor,
      style: const TextStyle(color: AppTheme.textColor),
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(
        value: e, 
        child: Text(itemLabels != null ? (itemLabels[e] ?? e) : e, overflow: TextOverflow.ellipsis)
      )).toList(),
      onChanged: onChange,
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final user = ref.read(authProvider).user;
      final isAdmin = user?.role == UserRole.sales_admin;

      final newQuery = SalesQuery(
        id: "", // Placeholder
        date: DateTime.now(),
        employeeName: user?.name ?? "Sales Guru",
        profileName: _selectedProfile,
        clientName: _clientNameController.text.isEmpty ? "Unknown" : _clientNameController.text,
        source: _selectedSource,
        serviceLine: _selectedService,
        country: _countryController.text.isEmpty ? "N/A" : _countryController.text,
        quote: _quoteController.text,
        specialComment: _specialCommentController.text,
        status: _selectedStatus,
        conversationStatus: _selectedConvStatus,
        assignedMemberId: user?.id ?? "",
        followUp1Done: _f1Done,
        followUp2Done: _f2Done,
        followUp3Done: _f3Done,
        soldById: _selectedSoldBy,
        monitoringRemark: (isAdmin && _monitoringRemarkController.text.isNotEmpty) 
            ? _monitoringRemarkController.text : null,
      );

      final data = newQuery.toJson(isAdmin: isAdmin);

      try {
        await ref.read(queryActionProvider.notifier).addProject(data, isAdmin: isAdmin);
        if (!mounted) return;
        
        // Reset form
        _clientNameController.clear();
        _countryController.clear();
        _quoteController.clear();
        _specialCommentController.clear();
        _monitoringRemarkController.clear();
        setState(() {
          _f1Done = false;
          _f2Done = false;
          _f3Done = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Query successfully registered in the cluster!"),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
          )
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Critical Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Priority Tasks", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          _buildTaskCard(
            context,
            "Urgent Follow-up",
            "Client: Salman Farshe",
            "Deadline: Today, 3:00 PM",
            Icons.priority_high_rounded,
            AppTheme.primaryColor,
          ),
          _buildTaskCard(
            context,
            "Quote Revision",
            "Client: John Wick",
            "Review the updated pricing for AI Agent solution",
            Icons.edit_note_rounded,
            AppTheme.secondaryColor,
          ),
          _buildTaskCard(
            context,
            "New Lead Alert",
            "From: AI Hook Profile",
            "Unassigned lead found in pool that matches your profile",
            Icons.new_releases_rounded,
            AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, String title, String subtitle, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor)),
                Text(subtitle, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontSize: 14, color: AppTheme.mutedTextColor)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Action", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
