import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: _getTitle(currentSection),
      child: _buildBody(currentSection),
    );
  }

  String _getTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.salesOverview: return "My Performance";
      case DashboardSection.addLead: return "Register New Lead";
      case DashboardSection.tasks: return "My Task Center";
      default: return "Sales Dashboard";
    }
  }

  Widget _buildBody(DashboardSection section) {
    switch (section) {
      case DashboardSection.salesOverview: return const _OverviewTab();
      case DashboardSection.addLead: return const _QueryFormTab();
      case DashboardSection.tasks: return const _TasksTab();
      default: return const _OverviewTab();
    }
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dashboard Overview", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              shrinkWrap: true,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(
                  title: "My Total Queries",
                  value: "14",
                  icon: Icons.question_answer_rounded,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: "My Conversion Rate",
                  value: "28.5%",
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.secondaryColor,
                ),
                StatCard(
                  title: "Active Conversations",
                  value: "5",
                  icon: Icons.chat_bubble_rounded,
                  color: AppTheme.accentColor,
                ),
              ],
            );
          }),
          const SizedBox(height: 48),
          Text("Recent Activity", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          _buildRecentList(),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 70),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: const [AppTheme.primaryColor, AppTheme.secondaryColor, AppTheme.accentColor][index % 3].withValues(alpha: 0.1),
              child: Text("C${index + 1}", style: TextStyle(color: const [AppTheme.primaryColor, AppTheme.secondaryColor, AppTheme.accentColor][index % 3], fontWeight: FontWeight.bold)),
            ),
            title: Text("Client ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            subtitle: const Text("Ref: AI Solution Query • 2 hours ago", style: TextStyle(color: AppTheme.mutedTextColor)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.mutedTextColor, size: 16),
          );
        },
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
  final _commentController = TextEditingController();
  
  String _selectedProfile = 'AI Hook';
  String _selectedSource = 'Query';
  String _selectedService = 'AI Website';
  QueryStatus _selectedStatus = QueryStatus.query;
  ConversationStatus _selectedConvStatus = ConversationStatus.active;
  bool _isSold = false;

  bool _f1Done = false; DateTime? _f1Date;
  bool _f2Done = false; DateTime? _f2Date;
  bool _f3Done = false; DateTime? _f3Date;

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
          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lead Registration", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Enter new query details for your company's records", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    ['AI Hook', 'Drift AI', 'AI Nest', 'Fire AI', 'AI Byte', 'Byte Craft'], 
                    (v) => setState(() => _selectedProfile = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildDropdown("Source", _selectedSource, 
                    ['Query', 'Brief', 'Promoted', 'Direct Order'], 
                    (v) => setState(() => _selectedSource = v!))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdown("Service Line", _selectedService, 
                    ['AI Website', 'AI Agent', 'Mobile App', 'Chatbot', 'Custom Website'], 
                    (v) => setState(() => _selectedService = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildInput("Quote (Amount or Reference)", _quoteController, Icons.monetization_on_outlined)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 24),
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
        const Text("Follow-up Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textColor)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fWidget(1, _f1Done, _f1Date, (v) => setState(() => _f1Done = v), (d) => setState(() => _f1Date = d)),
            _fWidget(2, _f2Done, _f2Date, (v) => setState(() => _f2Done = v), (d) => setState(() => _f2Date = d)),
            _fWidget(3, _f3Done, _f3Date, (v) => setState(() => _f3Done = v), (d) => setState(() => _f3Date = d)),
          ],
        ),
      ],
    );
  }

  Widget _fWidget(int num, bool done, DateTime? date, Function(bool) setDone, Function(DateTime) setDate) {
    final hasDate = date != null;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime(2027));
              if (d != null) setDate(d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.secondaryColor),
                  const SizedBox(width: 8),
                  Text(hasDate ? DateFormat('MMM dd').format(date) : "Set Date", style: const TextStyle(fontSize: 12, color: AppTheme.textColor)),
                ],
              ),
            ),
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
      validator: (v) => v!.isEmpty ? 'Field required' : null,
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
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).user;
      final q = SalesQuery(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        profileName: _selectedProfile,
        clientName: _clientNameController.text,
        source: _selectedSource,
        serviceLine: _selectedService,
        country: _countryController.text,
        quote: _quoteController.text,
        specialComment: _commentController.text,
        status: _selectedStatus,
        followUp1Done: _f1Done, followUp1Date: _f1Date,
        followUp2Done: _f2Done, followUp2Date: _f2Date,
        followUp3Done: _f3Done, followUp3Date: _f3Date,
        conversationStatus: _selectedConvStatus,
        sold: _isSold,
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
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
