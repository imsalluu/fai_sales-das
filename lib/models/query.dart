enum QueryStatus { 
  none,
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
  none,
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
  final String? soldById;
  final String? monitoringRemark;
  
  final String assignedMemberId;
  final double amount;
  final double deliveryAmount;
  final String? instSheet;
  final String? assignTeam;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.soldById,
    this.monitoringRemark,
    required this.assignedMemberId,
    this.amount = 0,
    this.deliveryAmount = 0,
    this.instSheet,
    this.assignTeam,
    this.createdAt,
    this.updatedAt,
  });

  factory SalesQuery.fromJson(Map<String, dynamic> json) {
    // Helper for status enums
    T parseEnum<T>(String? val, List<T> values, T defaultValue) {
      if (val == null || val == "NONE") return defaultValue;
      // Convert "CONVERSATION_RUNNING" to "conversationRunning"
      final parts = val.toLowerCase().split('_');
      final camelCase = parts.first + parts.skip(1).map((e) => e[0].toUpperCase() + e.substring(1)).join('');
      return values.firstWhere((e) => e.toString().split('.').last == camelCase, orElse: () => defaultValue);
    }

    // Extract employee name from nested object or field
    String extractName(dynamic employee) {
      if (employee is Map) return employee['name'] ?? "-";
      return "-";
    }

    // Normalize string from "UPPER_SNAKE_CASE" to "Title Case"
    String normalize(String? s) {
      if (s == null || s == "NONE") return "N/A";
      if (!s.contains('_') && s == s.toUpperCase()) {
         return s[0] + s.substring(1).toLowerCase();
      }
      return s.split('_').map((e) => e.isEmpty ? "" : e[0].toUpperCase() + e.substring(1).toLowerCase()).join(' ');
    }

    return SalesQuery(
      id: json['id'],
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      employeeName: json['employeeName'] ?? extractName(json['employee']),
      profileName: normalize(json['profileName']),
      clientName: json['clientName'] ?? "Unknown",
      source: normalize(json['source']),
      serviceLine: normalize(json['serviceLine']),
      country: json['country'] ?? "N/A",
      quote: json['quote'],
      specialComment: json['comment'] ?? json['specialComment'],
      status: parseEnum(json['queryStatus'] ?? json['status'], QueryStatus.values, QueryStatus.customOfferSent),
      followUp1Done: json['f01'] ?? (json['followupCount'] != null && json['followupCount'] >= 1) ?? false,
      followUp2Done: json['f02'] ?? (json['followupCount'] != null && json['followupCount'] >= 2) ?? false,
      followUp3Done: json['f03'] ?? (json['followupCount'] != null && json['followupCount'] >= 3) ?? false,
      conversationStatus: parseEnum(json['conversationStatus'], ConversationStatus.values, ConversationStatus.needToFollowUp),
      soldBy: json['soldBy'] != null ? extractName(json['soldBy']) : null,
      soldById: json['soldBy'] != null ? json['soldBy']['id'] : json['soldById'],
      monitoringRemark: json['remark'] ?? json['monitoringRemark'],
      assignedMemberId: json['employeeId'] ?? json['assignedMemberId'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      deliveryAmount: (json['deliveryAmount'] ?? 0).toDouble(),
      instSheet: json['instSheet'],
      assignTeam: json['assignTeam'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson({bool isAdmin = false}) {
    String toUpperSnake(String s) {
      if (s == 'N/A' || s == 'Unknown' || s == '-') return 'NONE';
      String result = s.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
            (m) => '${m.group(1)}_${m.group(2)}',
      );
      return result.replaceAll(' ', '_').toUpperCase();
    }

    final data = <String, dynamic>{
      'profileName': toUpperSnake(profileName),
      'clientName': clientName.isEmpty ? "Unknown" : clientName,
      'source': source.isEmpty ? "NONE" : toUpperSnake(source),
      'serviceLine': serviceLine.isEmpty ? "NONE" : toUpperSnake(serviceLine),
      'country': country.isEmpty ? "Unknown" : country,
      'quote': quote ?? "",
      'queryStatus': toUpperSnake(status.name),
      'conversationStatus': toUpperSnake(conversationStatus.name),
      'comment': specialComment ?? "",
      'remark': monitoringRemark ?? "",
      'f01': followUp1Done,
      'f02': followUp2Done,
      'f03': followUp3Done,
    };

    if (isAdmin) {
      data['employeeName'] = employeeName;
      if (assignedMemberId.isNotEmpty) {
        data['employeeId'] = assignedMemberId;
      }
    }

    if (soldById != null && soldById!.isNotEmpty) {
      data['soldById'] = soldById;
    }

    return data;
  }
}
