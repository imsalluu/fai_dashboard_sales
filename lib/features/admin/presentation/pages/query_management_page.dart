

import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:fai_dashboard_sales/models/query.dart';
import 'package:fai_dashboard_sales/models/user.dart';
import 'package:fai_dashboard_sales/services/api/mock_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class QueryManagementPage extends StatefulWidget {
  final VoidCallback? onAddOverride;
  final String? memberId;
  const QueryManagementPage({super.key, this.onAddOverride, this.memberId});

  @override
  State<QueryManagementPage> createState() => _QueryManagementPageState();
}

class _QueryManagementPageState extends State<QueryManagementPage> {
  static const double columnSum = 2080;
  static const double tableWidth = columnSum + 24; // 24 is horizonzal padding (12*2)
  final _api = MockApiService();
  List<SalesQuery> _queries = [];
  List<User> _members = [];
  bool _isLoading = true;
  String _searchQuery = "";
  
  String? _selectedTag;
  String? _selectedEmployeeName;
  final _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final queries = await _api.getQueries(
      search: _searchQuery,
      memberId: widget.memberId,
    );
    // Note: In a real app, you'd also filter by _selectedEmployeeName in the API call
    // or filter the result list here.
    final members = await _api.getMembers();
    setState(() {
      _queries = queries;
      if (_selectedEmployeeName != null) {
        _queries = _queries.where((q) => q.employeeName == _selectedEmployeeName).toList();
      }
      _members = members;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildFilterBar(),
        const SizedBox(height: 24),
        _buildTableContainer(),
      ],
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1400) { // Increased breakpoint to prevent header overflow
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sales", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 16),
              _buildHeaderActions(),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sales", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildHeaderActions(),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildHeaderActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text("Total ${_queries.length} sales", style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
        const SizedBox(width: 4),
        _buildGhostButton(Icons.description_outlined, "Export Excel", () {}),
        ElevatedButton.icon(
          onPressed: widget.onAddOverride ?? _showAddQueryDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text("Add New Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGhostButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterSearch(),
          const SizedBox(width: 12),
          _buildFilterDropdown("Select Employee Name", _selectedEmployeeName, ['All Employees', ..._members.map((m) => m.name)], (v) => setState(() {
            _selectedEmployeeName = (v == 'All Employees') ? null : v;
            _fetchData();
          })),
        ],
      ),
    );
  }

  Widget _buildFilterSearch() {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search sales...",
          hintStyle: const TextStyle(color: AppTheme.mutedTextColor),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.mutedTextColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
        onChanged: (val) {
          _searchQuery = val;
          _fetchData();
        },
      ),
    );
  }

  Widget _buildFilterDate(String label, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (d != null) onSelect(d);
      },
      child: Container(
        width: 160,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(date != null ? DateFormat('MM/dd/yyyy').format(date) : label, style: TextStyle(fontSize: 13, color: date != null ? Colors.white : AppTheme.mutedTextColor))),
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.mutedTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String? val, List<String> items, Function(String?) onChange) {
    return Container(
      width: 160,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(label, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
          dropdownColor: AppTheme.cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.mutedTextColor),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, color: Colors.white)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildTableContainer() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)) 
            : LayoutBuilder(
                builder: (context, constraints) => _buildTable(constraints.maxHeight),
              ),
      ),
    );
  }

 Widget _buildTable(double height) {
  return Scrollbar(
    controller: _horizontalScrollController,
    thumbVisibility: true,
    trackVisibility: true,
    thickness: 8,
    radius: const Radius.circular(4),
    scrollbarOrientation: ScrollbarOrientation.bottom,
    child: SingleChildScrollView(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: [
            _buildStickyHeader(),

            // ✅ FIX: height explicitly defined
            SizedBox(
              height: height - 44, // header height বাদ
              child: ListView.builder(
                itemCount: _queries.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final q = _queries[index];
                  return _buildTableRow(q, index);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  

  Widget _buildStickyHeader() {
  return Container(
    height: 44, // 🔥 FIXED SMALL HEIGHT
    alignment: Alignment.centerLeft,
    color: Colors.white.withOpacity(0.04),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      width: columnSum,
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            child: Text(
              "#",
              style: TextStyle(
                color: AppTheme.mutedTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _HeaderCell("Date", 100),
          _HeaderCell("Employee Name", 150),
          _HeaderCell("Profile Name", 120),
          _HeaderCell("Client Name", 150),
          _HeaderCell("Source", 120),
          _HeaderCell("Service Line", 180),
          _HeaderCell("Country", 120),
          _HeaderCell("Quote", 120),
          _HeaderCell("Special Comment", 200),
          _HeaderCell("Query Status", 140),
          _HeaderCell("Follow up 01", 60),
          _HeaderCell("Follow up 02", 60),
          _HeaderCell("Follow up 03", 60),
          _HeaderCell("Conv. Status", 140),
          _HeaderCell("Sold By", 120),
          _HeaderCell("Monitoring Remark", 200),
        ],
      ),
    ),
  );
}


  Widget _HeaderCell(String label, double width) {
    return SizedBox(width: width, child: Text(label, style: const TextStyle(color: AppTheme.mutedTextColor, fontWeight: FontWeight.bold, fontSize: 12)));
  }

  Widget _buildTableRow(SalesQuery q, int index) {
    return InkWell(
      onTap: () => _showEditQueryDialog(q),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
          color: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.01),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Consistent padding with header
        child: Container(
          width: columnSum, // Ensure exact alignment
          child: Row(
            children: [
              SizedBox(width: 40, child: Checkbox(value: false, onChanged: (v) {}, side: BorderSide(color: Colors.white.withOpacity(0.2)))),
              _DataCell(DateFormat('MM/dd/yyyy').format(q.date), 100),
              _DataCell(q.employeeName, 150, isBold: true),
              _DataCell(q.profileName, 120),
              _DataCell(q.clientName, 150),
              _DataCell(q.source, 120),
              _DataCell(q.serviceLine, 180),
              _DataCell(q.country, 120),
              _DataCell(q.quote ?? "-", 120),
              _DataCell(q.specialComment ?? "-", 200),
              SizedBox(width: 140, child: _buildStatusChip(q.status)),
              _FollowUpCell(q.followUp1Done, 60),
              _FollowUpCell(q.followUp2Done, 60),
              _FollowUpCell(q.followUp3Done, 60),
              SizedBox(width: 140, child: _buildConvStatusChip(q.conversationStatus)),
              _DataCell(q.soldBy ?? "-", 120),
              _DataCell(q.monitoringRemark ?? "-", 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _DataCell(String text, double width, {bool isBold = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _FollowUpCell(bool done, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Icon(
          done ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          color: done ? AppTheme.secondaryColor : Colors.white.withOpacity(0.2),
          size: 18,
        ),
      ),
    );
  }


  Widget _buildStatusChip(QueryStatus status) {
    String text;
    Color color;

    switch (status) {
      case QueryStatus.customOfferSent: text = "Custom Offer Sent"; color = Colors.blue; break;
      case QueryStatus.briefCustomOfferSent: text = "Brief Custom Offer Sent"; color = Colors.lightBlue; break;
      case QueryStatus.briefReplied: text = "Brief Replied"; color = Colors.cyan; break;
      case QueryStatus.quoteSent: text = "Quote Sent"; color = Colors.indigo; break;
      case QueryStatus.featureListSent: text = "Feature List Sent"; color = Colors.teal; break;
      case QueryStatus.noResponse: text = "No Response"; color = Colors.grey; break;
      case QueryStatus.pass: text = "Pass"; color = Colors.blueGrey; break;
      case QueryStatus.spam: text = "Spam"; color = Colors.red.shade300; break;
      case QueryStatus.lowFocusCountry: text = "Low Focus Country"; color = Colors.brown; break;
      case QueryStatus.conversationRunning: text = "Conversation Running"; color = Colors.orange; break;
    }

    return _chip(text, color);
  }

  Widget _buildConvStatusChip(ConversationStatus status) {
    String text;
    Color color;

    switch (status) {
      case ConversationStatus.needToFollowUp: text = "Need to Follow-up"; color = Colors.orange; break;
      case ConversationStatus.followUpDone: text = "Follow-up Done"; color = Colors.blue; break;
      case ConversationStatus.sold: text = "Sold"; color = Colors.green; break;
      case ConversationStatus.neverCame: text = "Never Came"; color = Colors.red; break;
      case ConversationStatus.foundOtherDev: text = "Found Other DEV"; color = Colors.purple; break;
      case ConversationStatus.noNeedToFollowUp: text = "No Need to Follow-up"; color = Colors.grey; break;
    }

    return _chip(text, color);
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showAddQueryDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddQueryDialog(
        members: _members,
        onSave: (newQuery) {
          _api.addQuery(newQuery);
          _fetchData();
        },
      ),
    );
  }

  void _showEditQueryDialog(SalesQuery query) {
    showDialog(
      context: context,
      builder: (context) => _AddQueryDialog(
        members: _members,
        initialQuery: query,
        onSave: (updatedQuery) {
          _api.updateQuery(updatedQuery);
          _fetchData();
        },
      ),
    );
  }
}


class _AddQueryDialog extends StatefulWidget {
  final List<User> members;
  final SalesQuery? initialQuery;
  final Function(SalesQuery) onSave;

  const _AddQueryDialog({required this.members, required this.onSave, this.initialQuery});

  @override
  State<_AddQueryDialog> createState() => _AddQueryDialogState();
}

class _AddQueryDialogState extends State<_AddQueryDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _date;
  late String _employeeName;
  late String _profileName;
  late String _clientName;
  late String _source;
  late String _serviceLine;
  late String _country;
  late String _quote;
  late String _specialComment;
  late QueryStatus _status;
  late bool _f1;
  late bool _f2;
  late bool _f3;
  late ConversationStatus _convStatus;
  late String? _soldByName;
  late String _monitoringRemark;
  
  final List<String> _validProfiles = [
    'Byte Craft', 'Drift AI', 'Fire AI', 'AI Byte', 
    'AI Hook', 'AI Nest', 'Zebra App', 'Turtle App', 'Logic AI'
  ];

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery;
    _date = q?.date ?? DateTime.now();
    _employeeName = q?.employeeName ?? (widget.members.isNotEmpty ? widget.members.first.name : '');
    
    // Ensure the profile exists in our list, otherwise default to first
    String incomingProfile = q?.profileName ?? 'Byte Craft';
    if (!_validProfiles.contains(incomingProfile)) {
      incomingProfile = _validProfiles.first;
    }
    _profileName = incomingProfile;

    _clientName = q?.clientName ?? '';
    _source = q?.source ?? 'Query';
    _serviceLine = q?.serviceLine ?? 'Custom Website';
    _country = q?.country ?? 'United States';
    _quote = q?.quote ?? '';
    _specialComment = q?.specialComment ?? '';
    _status = q?.status ?? QueryStatus.quoteSent;
    _f1 = q?.followUp1Done ?? false;
    _f2 = q?.followUp2Done ?? false;
    _f3 = q?.followUp3Done ?? false;
    _convStatus = q?.conversationStatus ?? ConversationStatus.needToFollowUp;
    _soldByName = q?.soldBy;
    _monitoringRemark = q?.monitoringRemark ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialQuery == null ? "Add New Sale" : "Edit Sale", style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: AppTheme.cardColor,
      scrollable: true,
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(
                DropdownButtonFormField<String>(
                  value: _employeeName,
                  decoration: const InputDecoration(labelText: "E. Name *"),
                  items: widget.members.map((m) => DropdownMenuItem(value: m.name, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => _employeeName = val!),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _profileName,
                  decoration: const InputDecoration(labelText: "Profile Name *"),
                  items: _validProfiles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _profileName = val!),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildRow(
                TextFormField(
                  initialValue: _clientName,
                  decoration: const InputDecoration(labelText: "Client Name *"),
                  onChanged: (val) => _clientName = val,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _source,
                  decoration: const InputDecoration(labelText: "Source *"),
                  items: ['Query', 'Brief', 'Promoted', 'Direct Order', 'Referral']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _source = val!),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildRow(
                DropdownButtonFormField<String>(
                  value: _serviceLine,
                  decoration: const InputDecoration(labelText: "Service Line *"),
                  items: [
                    'Custom Website', 'Mobile App', 'AI Mobile App', 
                    'AI Website', 'AI Agent', 'Chatbot', 'Not Clarified', 
                    'N8N Automation', 'Bux fixing'
                  ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _serviceLine = val!),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _country,
                  decoration: const InputDecoration(labelText: "Country *"),
                  onChanged: (val) => _country = val,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildRow(
                TextFormField(
                  initialValue: _quote,
                  decoration: const InputDecoration(labelText: "Quote *"),
                  onChanged: (val) => _quote = val,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                DropdownButtonFormField<QueryStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: "Query Status *"),
                  items: QueryStatus.values.map((s) {
                    String label = s.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toLowerCase();
                    label = label[0].toUpperCase() + label.substring(1);
                    return DropdownMenuItem(value: s, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => _status = val!),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CheckboxListTile(title: const Text("Follow up 1", style: TextStyle(fontSize: 12)), value: _f1, onChanged: (v) => setState(() => _f1 = v!))),
                  Expanded(child: CheckboxListTile(title: const Text("Follow up 2", style: TextStyle(fontSize: 12)), value: _f2, onChanged: (v) => setState(() => _f2 = v!))),
                  Expanded(child: CheckboxListTile(title: const Text("Follow up 3", style: TextStyle(fontSize: 12)), value: _f3, onChanged: (v) => setState(() => _f3 = v!))),
                ],
              ),
              const SizedBox(height: 16),
              _buildRow(
                DropdownButtonFormField<ConversationStatus>(
                  value: _convStatus,
                  decoration: const InputDecoration(labelText: "Conversation Status *"),
                  items: ConversationStatus.values.map((s) {
                    String label = s.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toLowerCase();
                    label = label[0].toUpperCase() + label.substring(1);
                    return DropdownMenuItem(value: s, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => _convStatus = val!),
                ),
                DropdownButtonFormField<String>(
                  value: _soldByName,
                  decoration: const InputDecoration(labelText: "Sold By"),
                  items: [null, ...widget.members.map((m) => m.name)]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s ?? "None"))).toList(),
                  onChanged: (val) => setState(() => _soldByName = val),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _specialComment,
                decoration: const InputDecoration(labelText: "Special Comment *"),
                onChanged: (val) => _specialComment = val,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _monitoringRemark,
                decoration: const InputDecoration(labelText: "Monitoring Remark *"),
                onChanged: (val) => _monitoringRemark = val,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final member = widget.members.firstWhere((m) => m.name == _employeeName);
              final query = SalesQuery(
                id: widget.initialQuery?.id ?? 'FO${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                date: _date,
                employeeName: _employeeName,
                profileName: _profileName,
                clientName: _clientName,
                source: _source,
                serviceLine: _serviceLine,
                country: _country,
                quote: _quote,
                specialComment: _specialComment,
                status: _status,
                followUp1Done: _f1,
                followUp2Done: _f2,
                followUp3Done: _f3,
                conversationStatus: _convStatus,
                soldBy: _soldByName,
                monitoringRemark: _monitoringRemark,
                assignedMemberId: member.id,
              );
              widget.onSave(query);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
          child: Text(widget.initialQuery == null ? "Save Sale" : "Update Sale"),
        ),
      ],
    );
  }

  Widget _buildRow(Widget w1, Widget w2) {
    return Row(
      children: [
        Expanded(child: w1),
        const SizedBox(width: 16),
        Expanded(child: w2),
      ],
    );
  }
}
