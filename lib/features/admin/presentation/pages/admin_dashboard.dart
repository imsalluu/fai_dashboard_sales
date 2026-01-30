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
import 'performance_page.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _api = MockApiService();
  DashboardStats? _stats;
  ActionCount? _actionCount;
  List<PerformanceData> _performance = [];
  List<IndividualPerformance> _individualPerformance = [];
  List<ProfilePerformance> _profilePerformance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await _api.getStats();
    final actionCount = await _api.getActionCount();
    final performance = await _api.getPerformance();
    final individualPerformance = await _api.getIndividualPerformance();
    final profilePerformance = await _api.getProfilePerformance();
    
    setState(() {
      _stats = stats;
      _actionCount = actionCount;
      _performance = performance;
      _individualPerformance = individualPerformance;
      _profilePerformance = profilePerformance;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = ref.watch(navigationProvider);

    return DashboardLayout(
      title: _getSectionTitle(currentSection),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : _buildSectionContent(currentSection),
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

  Widget _buildSectionContent(DashboardSection section) {
    switch (section) {
      case DashboardSection.overview: return _buildOverview();
      case DashboardSection.team: return const MemberManagementPage();
      case DashboardSection.queries: return const QueryManagementPage();
      case DashboardSection.analytics: return const PerformancePage();
      default: return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatGrid(),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSection(
                  "Monthly Sales Trends",
                  const SizedBox(height: 300, child: TrendChart(color: Color(0xFF6366F1))),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildSection(
                  "Monthly Delivery Trends",
                  const SizedBox(height: 300, child: TrendChart(color: Color(0xFF10B981))),
                ),
              ),
            ],
          ),
             const SizedBox(height: 48),
          _buildConversionAndActionSection(),
          const SizedBox(height: 48),
          _buildIndividualProfilePerformanceTable(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
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
          value: "159",
          icon: Icons.question_answer_rounded,
          gradientColors: [const Color(0xFF4F46E5), const Color(0xFF818CF8)], // Indigo Dusk
          subtitle: "Total inquiries received",
          subtitleIcon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Total Briefs",
          value: "39",
          icon: Icons.assignment_rounded,
          gradientColors: [const Color(0xFF059669), const Color(0xFF34D399)], // Emerald Forest
          subtitle: "Project briefs submitted",
          subtitleIcon: const Icon(Icons.description_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Quotes Sent",
          value: "60",
          icon: Icons.request_quote_rounded,
          gradientColors: [const Color(0xFFDC2626), const Color(0xFFF87171)], // Ruby Red
          subtitle: "Pricing proposals active",
          subtitleIcon: const Icon(Icons.send_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Final Converted",
          value: "4",
          icon: Icons.handshake_rounded,
          gradientColors: [const Color(0xFF7C3AED), const Color(0xFFA78BFA)], // Royal Purple
          subtitle: "Successfully closed deals",
          subtitleIcon: const Icon(Icons.verified_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Total Interactions",
          value: "198",
          icon: Icons.forum_rounded,
          gradientColors: [const Color(0xFF0284C7), const Color(0xFF38BDF8)], // Sky Blue
          subtitle: "Customer messages",
          subtitleIcon: const Icon(Icons.chat_bubble_rounded, color: Colors.white70, size: 12),
        ),
        StatCard(
          title: "Conversion Rate",
          value: "2.5%",
          icon: Icons.analytics_rounded,
          gradientColors: [const Color(0xFFD97706), const Color(0xFFFBBF24)], // Amber Sunset
          subtitle: "Closing efficiency",
          subtitleIcon: const Icon(Icons.trending_up_rounded, color: Colors.white70, size: 12),
        ),
      ],
    );
  }

  Widget _buildEmployeePerformanceTable() {
    return DataTable(
      horizontalMargin: 0,
      columns: const [
        DataColumn(label: Text("RANK")),
        DataColumn(label: Text("EMPLOYEE")),
        DataColumn(label: Text("TARGET")),
        DataColumn(label: Text("ACHIEVED")),
        DataColumn(label: Text("ACHIEVEMENT %")),
        DataColumn(label: Text("ORDERS")),
      ],
      rows: _performance.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return DataRow(cells: [
          DataCell(Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(data.memberName, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text("\$${data.target.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}")),
          DataCell(Text("\$${data.achieved.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}")),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${data.achievementPercentage.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: data.achievementPercentage / 100,
                    backgroundColor: Colors.white10,
                    color: data.achievementPercentage >= 100 ? Colors.green : AppTheme.secondaryColor,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          DataCell(Text("${data.orders}")),
        ]);
      }).toList(),
    );
  }

  Widget _buildConversionAndActionSection() {
    return _buildSection("Market Activity & Performance Breakdown", 
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: _buildActionCountTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCountTable() {
    if (_actionCount == null) return const SizedBox();
    final items = [
      ("Custom Offer Sent", _actionCount!.customOfferSent, const Color(0xFF6366F1)),
      ("Brief Custom Offer Sent", _actionCount!.briefCustomOfferSent, const Color(0xFF10B981)),
      ("Conversation Running", _actionCount!.conversationRunning, const Color(0xFFF59E0B)),
      ("Feature List Sent", _actionCount!.featureListSent, const Color(0xFFEF4444)),
      ("Pass", _actionCount!.pass, const Color(0xFF94A3B8)),
      ("Spam", _actionCount!.spam, const Color(0xFF475569)),
      ("No Response", _actionCount!.noResponse, const Color(0xFF64748B)),
      ("Repeat", _actionCount!.repeat, const Color(0xFF0EA5E9)),
      ("Direct Order", _actionCount!.directOrder, const Color(0xFF8B5CF6)),
    ];

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
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.03)),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: item.$3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.$1, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(
                      "${item.$2}",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: item.$3),
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

  Widget _buildIndividualProfilePerformanceTable() {
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
          ..._profilePerformance.map((p) => Container(
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
