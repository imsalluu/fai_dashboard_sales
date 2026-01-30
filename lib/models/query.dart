enum QueryStatus { 
  customOfferSent, 
  briefCustomOfferSent, 
  briefReplied, 
  quoteSent, 
  featureListSent, 
  noResponse, 
  pass, 
  spam, 
  lowFocusCountry, 
  conversationRunning 
}

enum ConversationStatus { 
  needToFollowUp, 
  followUpDone, 
  sold, 
  neverCame, 
  foundOtherDev, 
  noNeedToFollowUp 
}

class SalesQuery {
  final String id;
  final DateTime date;
  final String employeeName;
  final String profileName;
  final String clientName;
  final String source;
  final String serviceLine;
  final String country;
  final String? quote; 
  final String? specialComment;
  final QueryStatus status;
  
  final bool followUp1Done;
  final bool followUp2Done;
  final bool followUp3Done;
  
  final ConversationStatus conversationStatus;
  final String? soldBy;
  final String? monitoringRemark;
  
  final String assignedMemberId;
  final double amount;
  final double deliveryAmount;
  final String? instSheet;
  final String? assignTeam;

  SalesQuery({
    required this.id,
    required this.date,
    required this.employeeName,
    required this.profileName,
    required this.clientName,
    required this.source,
    required this.serviceLine,
    required this.country,
    this.quote,
    this.specialComment,
    required this.status,
    this.followUp1Done = false,
    this.followUp2Done = false,
    this.followUp3Done = false,
    required this.conversationStatus,
    this.soldBy,
    this.monitoringRemark,
    required this.assignedMemberId,
    this.amount = 0,
    this.deliveryAmount = 0,
    this.instSheet,
    this.assignTeam,
  });

  factory SalesQuery.fromJson(Map<String, dynamic> json) {
    return SalesQuery(
      id: json['id'],
      date: DateTime.parse(json['date']),
      employeeName: json['employeeName'] ?? "-",
      profileName: json['profileName'],
      clientName: json['clientName'],
      source: json['source'],
      serviceLine: json['serviceLine'],
      country: json['country'],
      quote: json['quote'],
      specialComment: json['specialComment'],
      status: QueryStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => QueryStatus.customOfferSent),
      followUp1Done: json['followUp1Done'] ?? false,
      followUp2Done: json['followUp2Done'] ?? false,
      followUp3Done: json['followUp3Done'] ?? false,
      conversationStatus: ConversationStatus.values.firstWhere((e) => e.name == json['conversationStatus'], orElse: () => ConversationStatus.needToFollowUp),
      soldBy: json['soldBy'],
      monitoringRemark: json['monitoringRemark'],
      assignedMemberId: json['assignedMemberId'],
      amount: (json['amount'] ?? 0).toDouble(),
      deliveryAmount: (json['deliveryAmount'] ?? 0).toDouble(),
      instSheet: json['instSheet'],
      assignTeam: json['assignTeam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'employeeName': employeeName,
      'profileName': profileName,
      'clientName': clientName,
      'source': source,
      'serviceLine': serviceLine,
      'country': country,
      'quote': quote,
      'specialComment': specialComment,
      'status': status.name,
      'followUp1Done': followUp1Done,
      'followUp2Done': followUp2Done,
      'followUp3Done': followUp3Done,
      'conversationStatus': conversationStatus.name,
      'soldBy': soldBy,
      'monitoringRemark': monitoringRemark,
      'assignedMemberId': assignedMemberId,
      'amount': amount,
      'deliveryAmount': deliveryAmount,
      'instSheet': instSheet,
      'assignTeam': assignTeam,
    };
  }
}
