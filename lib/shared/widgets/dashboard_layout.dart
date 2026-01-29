import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  final String title;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.title,
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
                      children: user?.role == UserRole.admin 
                        ? _buildAdminItems(ref, currentSection) 
                        : _buildSalesItems(ref, currentSection),
                    ),
                  ),
                ),
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  title: "Sign Out",
                  onTap: () => ref.read(authProvider.notifier).logout(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopbar(context, user),
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
        title: "Overview",
        isActive: current == DashboardSection.overview,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.overview,
      ),
      _SidebarItem(
        icon: Icons.groups_rounded,
        title: "Sales Team",
        isActive: current == DashboardSection.team,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.team,
      ),
      _SidebarItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Leads & Queries",
        isActive: current == DashboardSection.queries,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.queries,
      ),
      _SidebarItem(
        icon: Icons.bar_chart_rounded,
        title: "Performance",
        isActive: current == DashboardSection.analytics,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.analytics,
      ),
    ];
  }

  List<Widget> _buildSalesItems(WidgetRef ref, DashboardSection current) {
    return [
      _SidebarItem(
        icon: Icons.analytics_outlined,
        title: "My Stats",
        isActive: current == DashboardSection.salesOverview,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.salesOverview,
      ),
      _SidebarItem(
        icon: Icons.add_circle_outline_rounded,
        title: "Submit Lead",
        isActive: current == DashboardSection.addLead,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.addLead,
      ),
      _SidebarItem(
        icon: Icons.checklist_rtl_rounded,
        title: "My Tasks",
        isActive: current == DashboardSection.tasks,
        onTap: () => ref.read(navigationProvider.notifier).state = DashboardSection.tasks,
      ),
    ];
  }

  Widget _buildBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        const Text("FIRE AI", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildTopbar(BuildContext context, User? user) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          _Breadcrumbs(title: title),
          const Spacer(),
          const IconButton(
            onPressed: null,
            icon: Badge(
              label: Text("3", style: TextStyle(fontSize: 10)),
              child: Icon(Icons.notifications_none_rounded, color: AppTheme.textColor),
            ),
          ),
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
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(user?.name[0] ?? "U", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
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
        const Text("Dashboard", style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 14)),
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
            color: isActive ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
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
