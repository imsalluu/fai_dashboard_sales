class DashboardStats {
  final int totalQueries;
  final int totalBriefs;
  final int quoteSent;
  final int converted;
  final double conversionRate;
  final int totalMessages;
  final int activeConversations;

  DashboardStats({
    required this.totalQueries,
    required this.totalBriefs,
    required this.quoteSent,
    required this.converted,
    required this.conversionRate,
    required this.totalMessages,
    required this.activeConversations,
  });
}

class FunnelData {
  final String stage;
  final int count;

  FunnelData(this.stage, this.count);
}

class PerformanceData {
  final String memberName;
  final int queries;
  final int converted;

  PerformanceData(this.memberName, this.queries, this.converted);
}

class TrendData {
  final DateTime date;
  final int count;

  TrendData(this.date, this.count);
}
