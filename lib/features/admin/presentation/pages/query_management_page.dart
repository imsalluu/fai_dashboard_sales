import 'package:flutter/material.dart';
import '../../../../models/query.dart';
import '../../../../services/api/mock_api_service.dart';
import '../../../../core/theme/app_theme.dart';

class QueryManagementPage extends StatefulWidget {
  const QueryManagementPage({super.key});

  @override
  State<QueryManagementPage> createState() => _QueryManagementPageState();
}

class _QueryManagementPageState extends State<QueryManagementPage> {
  final _api = MockApiService();
  List<SalesQuery> _queries = [];
  bool _isLoading = true;
  String _searchQuery = "";
  QueryStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  Future<void> _fetchQueries() async {
    setState(() => _isLoading = true);
    final queries = await _api.getQueries(search: _searchQuery, status: _selectedStatus);
    setState(() {
      _queries = queries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Intelligence Feed", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search by client or country...",
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchQueries();
                  },
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<QueryStatus?>(
                  value: _selectedStatus,
                  dropdownColor: AppTheme.cardColor,
                  decoration: const InputDecoration(labelText: "Query Lifecycle Status"),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("All Stages")),
                    ...QueryStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))),
                  ],
                  onChanged: (val) {
                    _selectedStatus = val;
                    _fetchQueries();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Table Container
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
              : Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                        dataRowMaxHeight: 80,
                        horizontalMargin: 28,
                        columns: const [
                          DataColumn(label: Text("CLIENT ENTITY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                          DataColumn(label: Text("PROFILE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                          DataColumn(label: Text("SERVICE LINE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                          DataColumn(label: Text("LIFECYCLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                          DataColumn(label: Text("DATE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                          DataColumn(label: Text("COMMAND", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: AppTheme.mutedTextColor))),
                        ],
                        rows: _queries.map((q) => DataRow(cells: [
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.clientName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                              Text(q.country, style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
                            ],
                          )),
                          DataCell(Text(q.profileName, style: const TextStyle(color: AppTheme.textColor))),
                          DataCell(Text(q.serviceLine, style: const TextStyle(color: AppTheme.textColor))),
                          DataCell(_buildStatusChip(q.status.name)),
                          DataCell(Text(q.date.toString().split(' ')[0], style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12))),
                          DataCell(IconButton(icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.secondaryColor), onPressed: () {})),
                        ])).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'converted': color = Colors.green; break;
      case 'brief': color = AppTheme.secondaryColor; break;
      case 'quoteSent': color = Colors.purpleAccent; break;
      case 'spam': color = AppTheme.primaryColor; break;
      case 'noResponse': color = AppTheme.mutedTextColor; break;
      default: color = Colors.blueAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
