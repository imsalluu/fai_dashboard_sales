import 'dart:math';
import '../../models/user.dart';
import '../../models/query.dart';
import '../../models/analytics.dart';

class MockApiService {
  static final List<User> _members = [
    User(id: '1', name: 'Salman', email: 'salman@fireai.com', role: UserRole.admin),
    User(id: '2', name: 'John Doe', email: 'john@fireai.com', role: UserRole.sales, assignedProfile: "AI Hook"),
    User(id: '3', name: 'Jane Smith', email: 'jane@fireai.com', role: UserRole.sales, assignedProfile: "Drift AI"),
    User(id: '4', name: 'Akash', email: 'akash@fireai.com', role: UserRole.sales, assignedProfile: "AI Nest"),
  ];

  static List<SalesQuery> _queries = List.generate(50, (index) {
    final status = QueryStatus.values[Random().nextInt(QueryStatus.values.length)];
    return SalesQuery(
      id: 'Q$index',
      date: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      profileName: ['AI Hook', 'Drift AI', 'AI Nest', 'Fire AI', 'AI Byte', 'Byte Craft'][Random().nextInt(6)],
      clientName: 'Client $index',
      source: ['Query', 'Brief', 'Promoted', 'Direct Order'][Random().nextInt(4)],
      serviceLine: ['AI Website', 'AI Agent', 'Mobile App', 'Chatbot', 'Custom Website'][Random().nextInt(5)],
      country: ['USA', 'UK', 'Australia', 'Canada', 'Germany', 'Pakistan', 'India'][Random().nextInt(7)],
      status: status,
      conversationStatus: ConversationStatus.values[Random().nextInt(ConversationStatus.values.length)],
      sold: status == QueryStatus.converted,
      assignedMemberId: (Random().nextInt(3) + 2).toString(),
      specialComment: "Sample comment for query $index",
      quote: "Quote for project $index - \$${Random().nextInt(5000) + 500}",
    );
  });

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _members.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // Member Management
  Future<List<User>> getMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _members;
  }

  Future<void> addMember(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _members.add(user);
  }

  Future<void> updateMember(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _members.indexWhere((m) => m.id == user.id);
    if (index != -1) {
      _members[index] = user;
    }
  }

  Future<void> deleteMember(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _members.removeWhere((m) => m.id == id);
  }

  // Dashboard Stats
  Future<DashboardStats> getStats() async {
    final totalQueries = _queries.length;
    final totalBriefs = _queries.where((q) => q.status == QueryStatus.brief).length;
    final quoteSent = _queries.where((q) => q.status == QueryStatus.quoteSent).length;
    final converted = _queries.where((q) => q.status == QueryStatus.converted).length;
    final activeConv = _queries.where((q) => q.conversationStatus == ConversationStatus.active).length;
    
    return DashboardStats(
      totalQueries: totalQueries,
      totalBriefs: totalBriefs,
      quoteSent: quoteSent,
      converted: converted,
      conversionRate: totalQueries > 0 ? (converted / totalQueries) * 100 : 0,
      totalMessages: 1240,
      activeConversations: activeConv,
    );
  }

  Future<List<PerformanceData>> getPerformance() async {
    return _members.where((m) => m.role == UserRole.sales).map((m) {
      final mQueries = _queries.where((q) => q.assignedMemberId == m.id).toList();
      return PerformanceData(
        m.name,
        mQueries.length,
        mQueries.where((q) => q.status == QueryStatus.converted).length,
      );
    }).toList();
  }

  // Query Management
  Future<List<SalesQuery>> getQueries({String? memberId, String? search, QueryStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = _queries;
    if (memberId != null) {
      results = results.where((q) => q.assignedMemberId == memberId).toList();
    }
    if (search != null && search.isNotEmpty) {
      results = results.where((q) => q.clientName.toLowerCase().contains(search.toLowerCase())).toList();
    }
    if (status != null) {
      results = results.where((q) => q.status == status).toList();
    }
    return results;
  }

  Future<void> addQuery(SalesQuery query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _queries.insert(0, query);
  }
}
