import 'package:intl/intl.dart';
import '../../features/admin/presentation/providers/admin_provider.dart';
import '../../models/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  final String title;
  final Widget? topBarActions;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.topBarActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final currentSection = ref.watch(navigationProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppTheme.sidebarColor,
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(4, 0)),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildBranding(),
                const SizedBox(height: 48),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: user?.role == UserRole.sales_admin 
                        ? _buildAdminItems(ref, currentSection) 
                        : _buildSalesItems(ref, currentSection),
                    ),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  title: "Sign Out",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.cardColor,
                        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                        content: const Text("Are you sure you want to sign out?", style: TextStyle(color: AppTheme.mutedTextColor)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(authProvider.notifier).logout();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopbar(context, ref, user),
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundColor,
                    padding: const EdgeInsets.all(32.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdminItems(WidgetRef ref, DashboardSection current) {
    return [
      _SidebarItem(
        icon: Icons.grid_view_rounded,
        title: "Executive Dashboard",
        isActive: current == DashboardSection.overview,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.overview,
      ),
      _SidebarItem(
        icon: Icons.groups_rounded,
        title: "Sales Management",
        isActive: current == DashboardSection.team,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.team,
      ),
      _SidebarItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Sales",
        isActive: current == DashboardSection.queries,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.queries,
      ),
      _SidebarItem(
        icon: Icons.bar_chart_rounded,
        title: "Performance Statistics",
        isActive: current == DashboardSection.analytics,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.analytics,
      ),
    ];
  }

  List<Widget> _buildSalesItems(WidgetRef ref, DashboardSection current) {
    return [
      _SidebarItem(
        icon: Icons.analytics_outlined,
        title: "Sales Performance",
        isActive: current == DashboardSection.salesOverview,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.salesOverview,
      ),
      _SidebarItem(
        icon: Icons.add_circle_outline_rounded,
        title: "Register New Query",
        isActive: current == DashboardSection.addLead,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.addLead,
      ),
      _SidebarItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Sales",
        isActive: current == DashboardSection.mySales,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.mySales,
      ),
    ];
  }

  Widget _buildBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/fai_logo.png',
          height: 170,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildTopbar(BuildContext context, WidgetRef ref, User? user) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          _Breadcrumbs(title: title),
          const Spacer(),
          notificationsAsync.when(
            data: (notifications) => IconButton(
              onPressed: () => _showNotificationsDialog(context, notifications),
              icon: Badge(
                isLabelVisible: notifications.isNotEmpty,
                label: Text("${notifications.length}", style: const TextStyle(fontSize: 10)),
                child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textColor),
              ),
            ),
            loading: () => const SizedBox(width: 48, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondaryColor)))),
            error: (_, __) => const IconButton(onPressed: null, icon: Icon(Icons.notifications_off_rounded, color: AppTheme.mutedTextColor)),
          ),
          if (topBarActions != null) const SizedBox(width: 8),
          if (topBarActions != null) topBarActions!,
          const SizedBox(width: 24),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user?.name ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textColor)),
                  Text(user?.role.name.toUpperCase() ?? "ROLE", style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(user?.name[0] ?? "U", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, List<NotificationModel> notifications) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppTheme.secondaryColor),
            const SizedBox(width: 12),
            const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: notifications.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_paused_rounded, color: AppTheme.mutedTextColor, size: 48),
                      SizedBox(height: 16),
                      Text("No notifications yet", style: TextStyle(color: AppTheme.mutedTextColor)),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(n.message, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  n.type.replaceAll('_', ' '),
                                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, hh:mm a').format(n.createdAt),
                                style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: AppTheme.mutedTextColor)),
          ),
        ],
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final String title;
  const _Breadcrumbs({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // const Text("Dashboard", style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 14)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right, size: 16, color: AppTheme.mutedTextColor),
        ),
        Text(title, style: const TextStyle(color: AppTheme.textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? AppTheme.primaryColor : AppTheme.mutedTextColor, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.mutedTextColor,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
