class DashboardStats {
  final double totalSales;
  final int totalSalesCount;
  final double deliveredAmount;
  final int deliveredCount;
  final double cancelledAmount;
  final int cancelledCount;
  final double completeAmount;
  final int completeCount;
  final double nraAmount;
  final int nraCount;
  final double issuesAmount;
  final int issuesCount;

  DashboardStats({
    required this.totalSales,
    required this.totalSalesCount,
    required this.deliveredAmount,
    required this.deliveredCount,
    required this.cancelledAmount,
    required this.cancelledCount,
    required this.completeAmount,
    required this.completeCount,
    required this.nraAmount,
    required this.nraCount,
    required this.issuesAmount,
    required this.issuesCount,
  });
}

class ActionCount {
  final int customOfferSent;
  final int briefCustomOfferSent;
  final int conversationRunning;
  final int featureListSent;
  final int pass;
  final int spam;
  final int noResponse;
  final int repeat;
  final int directOrder;

  ActionCount({
    required this.customOfferSent,
    required this.briefCustomOfferSent,
    required this.conversationRunning,
    required this.featureListSent,
    required this.pass,
    required this.spam,
    required this.noResponse,
    required this.repeat,
    required this.directOrder,
  });
}

class ConversionRatio {
  final int queries;
  final int briefs;
  final int quoteSent;
  final int converted;
  final int totalReceivedMessages;
  final double conversionRate;

  ConversionRatio({
    required this.queries,
    required this.briefs,
    required this.quoteSent,
    required this.converted,
    required this.totalReceivedMessages,
    required this.conversionRate,
  });
}

class PerformanceData {
  final String memberName;
  final double target;
  final double achieved;
  final double achievementPercentage;
  final int orders;

  PerformanceData({
    required this.memberName,
    required this.target,
    required this.achieved,
    required this.achievementPercentage,
    required this.orders,
  });
}

class IndividualPerformance {
  final String id;
  final String name;
  final String role;
  final int totalQueries;
  final int convertedQueries;
  final int quoteSent;
  final num conversionRate;

  IndividualPerformance({
    required this.id,
    required this.name,
    required this.role,
    required this.totalQueries,
    required this.convertedQueries,
    required this.quoteSent,
    required this.conversionRate,
  });

  factory IndividualPerformance.fromJson(Map<String, dynamic> json) {
    return IndividualPerformance(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      totalQueries: json['total_queries'] ?? 0,
      convertedQueries: json['converted_queries'] ?? 0,
      quoteSent: json['quote_sent'] ?? 0,
      conversionRate: json['conversion_rate'] ?? 0,
    );
  }
}

class TrendData {
  final DateTime date;
  final double value;
  final int count;

  TrendData(this.date, this.value, this.count);
}

class ProfilePerformance {
  final String profileName;
  final int totalQueries;
  final int convertedQueries;
  final double conversionRate;

  ProfilePerformance({
    required this.profileName,
    required this.totalQueries,
    required this.convertedQueries,
    required this.conversionRate,
  });
}
