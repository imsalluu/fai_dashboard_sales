enum QueryStatus { query, brief, quoteSent, spam, converted, noResponse, pass, neverCame }
enum ConversationStatus { active, pending, closed, needToFollow, followUpDone, sold }

class SalesQuery {
  final String id;
  final DateTime date;
  final String profileName;
  final String clientName;
  final String source; // Query, Brief, Promoted, Direct Order
  final String serviceLine;
  final String country;
  final String? quote; // Quote text or file path
  final String? specialComment;
  final QueryStatus status;
  
  final DateTime? followUp1Date;
  final bool followUp1Done;
  final DateTime? followUp2Date;
  final bool followUp2Done;
  final DateTime? followUp3Date;
  final bool followUp3Done;
  
  final ConversationStatus conversationStatus;
  final bool sold;
  final String assignedMemberId;

  SalesQuery({
    required this.id,
    required this.date,
    required this.profileName,
    required this.clientName,
    required this.source,
    required this.serviceLine,
    required this.country,
    this.quote,
    this.specialComment,
    required this.status,
    this.followUp1Date,
    this.followUp1Done = false,
    this.followUp2Date,
    this.followUp2Done = false,
    this.followUp3Date,
    this.followUp3Done = false,
    required this.conversationStatus,
    required this.sold,
    required this.assignedMemberId,
  });

  factory SalesQuery.fromJson(Map<String, dynamic> json) {
    return SalesQuery(
      id: json['id'],
      date: DateTime.parse(json['date']),
      profileName: json['profileName'],
      clientName: json['clientName'],
      source: json['source'],
      serviceLine: json['serviceLine'],
      country: json['country'],
      quote: json['quote'],
      specialComment: json['specialComment'],
      status: QueryStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => QueryStatus.query),
      followUp1Date: json['followUp1Date'] != null ? DateTime.parse(json['followUp1Date']) : null,
      followUp1Done: json['followUp1Done'] ?? false,
      followUp2Date: json['followUp2Date'] != null ? DateTime.parse(json['followUp2Date']) : null,
      followUp2Done: json['followUp2Done'] ?? false,
      followUp3Date: json['followUp3Date'] != null ? DateTime.parse(json['followUp3Date']) : null,
      followUp3Done: json['followUp3Done'] ?? false,
      conversationStatus: ConversationStatus.values.firstWhere((e) => e.name == json['conversationStatus'], orElse: () => ConversationStatus.active),
      sold: json['sold'] ?? false,
      assignedMemberId: json['assignedMemberId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'profileName': profileName,
      'clientName': clientName,
      'source': source,
      'serviceLine': serviceLine,
      'country': country,
      'quote': quote,
      'specialComment': specialComment,
      'status': status.name,
      'followUp1Date': followUp1Date?.toIso8601String(),
      'followUp1Done': followUp1Done,
      'followUp2Date': followUp2Date?.toIso8601String(),
      'followUp2Done': followUp2Done,
      'followUp3Date': followUp3Date?.toIso8601String(),
      'followUp3Done': followUp3Done,
      'conversationStatus': conversationStatus.name,
      'sold': sold,
      'assignedMemberId': assignedMemberId,
    };
  }
}
