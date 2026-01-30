import 'package:fai_dashboard_sales/features/admin/presentation/pages/query_management_page.dart';
import 'package:fai_dashboard_sales/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/widgets/dashboard_layout.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../models/query.dart';
import '../../../../services/api/mock_api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../core/theme/app_theme.dart';

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
      case DashboardSection.addLead: return "Register New Lead";
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
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(user),
          const SizedBox(height: 32),
          _buildStatsGrid(context),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPerformanceChart()),
              const SizedBox(width: 32),
              Expanded(flex: 1, child: _buildQuickActions()),
            ],
          ),
          const SizedBox(height: 32),
          _buildRecentActivitySection(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(User? user) {
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18)),
              const SizedBox(height: 8),
              Text(user?.name ?? "Sales Guru", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 16),
                    SizedBox(width: 8),
                    Text("You're at 85% of your monthly goal", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          // const Spacer(),
          // _buildHeaderStat("Target", "$/25.0k"),
          // const SizedBox(width: 48),
          // _buildHeaderStat("Achieved", "$ 21.4k"),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
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
          _StatCard(title: "Total Queries", value: "48", icon: Icons.forum_rounded, color: Colors.blue, trend: "+12%"),
          _StatCard(title: "Converted", value: "14", icon: Icons.check_circle_rounded, color: Colors.green, trend: "+5%"),
          _StatCard(title: "Quote Sent", value: "26", icon: Icons.description_rounded, color: Colors.orange, trend: "+8%"),
          _StatCard(title: "Response Rate", value: "92%", icon: Icons.bolt_rounded, color: Colors.purple, trend: "+2%"),
        ],
      );
    });
  }

  Widget _buildPerformanceChart() {
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (val >= 0 && val < labels.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(labels[val.toInt()], style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)));
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4)],
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

  Widget _buildQuickActions() {
    return Column(
      children: [
        _ActionItem(title: "Pending Quotes", count: "4", icon: Icons.pending_actions_rounded, color: Colors.orange),
        const SizedBox(height: 20),
        _ActionItem(title: "Follow-ups Today", count: "7", icon: Icons.notifications_active_rounded, color: Colors.red),
        const SizedBox(height: 20),
        _ActionItem(title: "High Value Leads", count: "3", icon: Icons.diamond_rounded, color: Colors.cyan),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.05)),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 20),
                ),
                title: const Text("Vikas Sharma", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text("Inquiry for AI-powered Shopify Bot", style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                  child: const Text("QUOTE SENT", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
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
  final _api = MockApiService();
  
  final _clientNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _quoteController = TextEditingController();
  final _specialCommentController = TextEditingController();
  final _monitoringRemarkController = TextEditingController();
  
  String _selectedProfile = 'AI Hook';
  String _selectedSource = 'Query';
  String _selectedService = 'Custom Website';
  QueryStatus _selectedStatus = QueryStatus.quoteSent;
  ConversationStatus _selectedConvStatus = ConversationStatus.needToFollowUp;
  String? _selectedSoldBy;
  List<User> _teamMembers = [];

  bool _f1Done = false;
  bool _f2Done = false;
  bool _f3Done = false;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    final members = await _api.getMembers();
    setState(() => _teamMembers = members);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFormCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
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
            child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lead Registration", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Enter new query details for your company's records", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
                Expanded(child: _buildInput("Client Name *", _clientNameController, Icons.person_outline_rounded)),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Country *", _countryController, Icons.public_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Profile Name *", _selectedProfile, 
                    [
                      'Byte Craft', 'Drift AI', 'Fire AI', 'AI Byte', 
                      'AI Hook', 'AI Nest', 'Zebra App', 'Turtle App', 'Logic AI'
                    ], 
                    (v) => setState(() => _selectedProfile = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildDropdown("Source *", _selectedSource, 
                    ['Query', 'Brief', 'Promoted', 'Direct Order', 'Referral'], 
                    (v) => setState(() => _selectedSource = v!))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Service Line *", _selectedService, 
                    ['Custom Website', 'Mobile App', 'AI Mobile App', 'AI Website', 'AI Agent', 'Chatbot', 'Not Clarified', 'N8N Automation', 'Bux fixing'], 
                    (v) => setState(() => _selectedService = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Quote *", _quoteController, Icons.description_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Query Status *", _selectedStatus.name, 
                    QueryStatus.values.map((e) => e.name).toList(), 
                    (v) => setState(() => _selectedStatus = QueryStatus.values.firstWhere((e) => e.name == v)))),
                const SizedBox(width: 24),
                Expanded(child: _buildDropdown("Conversation Status *", _selectedConvStatus.name, 
                    ConversationStatus.values.map((e) => e.name).toList(), 
                    (v) => setState(() => _selectedConvStatus = ConversationStatus.values.firstWhere((e) => e.name == v)))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Sold By", _selectedSoldBy ?? 'None', 
                    ['None', ..._teamMembers.map((m) => m.name)], 
                    (v) => setState(() => _selectedSoldBy = v == 'None' ? null : v))),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Special Comment *", _specialCommentController, Icons.comment_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            _buildInput("Monitoring Remark *", _monitoringRemarkController, Icons.remove_red_eye_outlined),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),
            _buildFollowUpSection(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Register Lead in System", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: val,
      dropdownColor: AppTheme.cardColor,
      style: const TextStyle(color: AppTheme.textColor),
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChange,
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).user;
      final q = SalesQuery(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        employeeName: user?.name ?? "-",
        profileName: _selectedProfile,
        clientName: _clientNameController.text,
        source: _selectedSource,
        serviceLine: _selectedService,
        country: _countryController.text,
        quote: _quoteController.text,
        specialComment: _specialCommentController.text,
        status: _selectedStatus,
        followUp1Done: _f1Done,
        followUp2Done: _f2Done,
        followUp3Done: _f3Done,
        conversationStatus: _selectedConvStatus,
        soldBy: _selectedSoldBy,
        monitoringRemark: _monitoringRemarkController.text,
        assignedMemberId: user?.id ?? "0",
      );
      await _api.addQuery(q);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Query successfully listed in the system!"),
          backgroundColor: AppTheme.secondaryColor,
        )
      );
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
