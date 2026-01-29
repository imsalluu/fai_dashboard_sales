import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/dashboard_layout.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../widgets/performance_chart.dart';
import '../widgets/trend_chart.dart';
import '../../../../services/api/mock_api_service.dart';
import '../../../../models/analytics.dart';
import '../../../../shared/providers/navigation_provider.dart';
import 'member_management_page.dart';
import 'query_management_page.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _api = MockApiService();
  DashboardStats? _stats;
  List<PerformanceData> _performance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _api.getStats();
    final performance = await _api.getPerformance();
    setState(() {
      _stats = stats;
      _performance = performance;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = ref.watch(navigationProvider);

    return DashboardLayout(
      title: _getSectionTitle(currentSection),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSectionContent(currentSection),
    );
  }

  String _getSectionTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.overview: return "Executive Overview";
      case DashboardSection.team: return "Sales Force Management";
      case DashboardSection.queries: return "Lead Acquisition";
      case DashboardSection.analytics: return "Revenue Intelligence";
      default: return "Admin Control";
    }
  }

  Widget _buildSectionContent(DashboardSection section) {
    switch (section) {
      case DashboardSection.overview: return _buildOverview();
      case DashboardSection.team: return const MemberManagementPage();
      case DashboardSection.queries: return const QueryManagementPage();
      case DashboardSection.analytics: return _buildAnalytics();
      default: return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Organization Performance", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Refresh Dashboard"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            childAspectRatio: 1.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: "Annual Revenue",
                value: "\$${_stats?.totalQueries}k",
                icon: Icons.payments_rounded,
                color: AppTheme.secondaryColor,
                trend: "+12.5%",
              ),
              StatCard(
                title: "Conversations",
                value: "${_stats?.activeConversations}",
                icon: Icons.forum_rounded,
                color: AppTheme.primaryColor,
                trend: "+5.2%",
              ),
              StatCard(
                title: "Avg Handling Time",
                value: "4.2h",
                icon: Icons.speed_rounded,
                color: AppTheme.accentColor,
                trend: "-0.8h",
              ),
              StatCard(
                title: "Market Share",
                value: "22.4%",
                icon: Icons.pie_chart_rounded,
                color: Colors.cyan,
                trend: "+1.1%",
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildSection(
                  "Lead Generation Velocity",
                  const SizedBox(height: 320, child: TrendChart()),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: _buildSection(
                  "Win/Loss Analysis",
                  SizedBox(height: 320, child: PerformanceChart(data: _performance)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Advanced Revenue Analytics", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text("Generate Report"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            "Global Market Reach",
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public_rounded, size: 80, color: AppTheme.mutedTextColor),
                    SizedBox(height: 16),
                    Text("Interactive Deployment Matrix", style: TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Visualization of global lead distribution and conversion density", style: TextStyle(color: AppTheme.mutedTextColor)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: _buildSection("Sales Velocity Funnel", Container(height: 300, alignment: Alignment.center, child: const Text("Pipeline Metrics Visualization"))),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildSection("Projection Modelling", Container(height: 300, alignment: Alignment.center, child: const Text("AI-Driven Revenue Forecasting"))),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppTheme.textColor)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: AppTheme.softShadow,
          ),
          child: content,
        ),
      ],
    );
  }
}
