class ExecutiveStats {
  final DashboardSummary summary;
  final List<TrendData> trends;
  final List<MarketActivity> marketActivity;
  final List<ProfilePerformanceData> profilePerformance;

  ExecutiveStats({
    required this.summary,
    required this.trends,
    required this.marketActivity,
    required this.profilePerformance,
  });

  factory ExecutiveStats.fromJson(Map<String, dynamic> json) {
    return ExecutiveStats(
      summary: DashboardSummary.fromJson(json['summary'] ?? {}),
      trends: (json['trends'] as List? ?? [])
          .map((e) => TrendData.fromJson(e))
          .toList(),
      marketActivity: (json['marketActivity'] as List? ?? [])
          .map((e) => MarketActivity.fromJson(e))
          .toList(),
      profilePerformance: (json['profilePerformance'] as List? ?? [])
          .map((e) => ProfilePerformanceData.fromJson(e))
          .toList(),
    );
  }
}

class DashboardSummary {
  final int totalQueries;
  final int totalBriefs;
  final int quotesSent;
  final int finalConverted;
  final int totalInteractions;
  final String conversionRate;

  DashboardSummary({
    required this.totalQueries,
    required this.totalBriefs,
    required this.quotesSent,
    required this.finalConverted,
    required this.totalInteractions,
    required this.conversionRate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalQueries: json['totalQueries'] ?? 0,
      totalBriefs: json['totalBriefs'] ?? 0,
      quotesSent: json['quotesSent'] ?? 0,
      finalConverted: json['finalConverted'] ?? 0,
      totalInteractions: json['totalInteractions'] ?? 0,
      conversionRate: json['conversionRate'] ?? '0%',
    );
  }
}

class TrendData {
  final String month;
  final int sales;
  final int delivery;

  TrendData({
    required this.month,
    required this.sales,
    required this.delivery,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      month: json['month'] ?? '',
      sales: json['sales'] ?? 0,
      delivery: json['delivery'] ?? 0,
    );
  }
}

class MarketActivity {
  final String label;
  final int count;
  final String color;

  MarketActivity({
    required this.label,
    required this.count,
    required this.color,
  });

  factory MarketActivity.fromJson(Map<String, dynamic> json) {
    return MarketActivity(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
      color: json['color'] ?? '#000000',
    );
  }
}

class ProfilePerformanceData {
  final String profileName;
  final int totalQueries;
  final int convertedQueries;
  final double conversionRate;

  ProfilePerformanceData({
    required this.profileName,
    required this.totalQueries,
    required this.convertedQueries,
    required this.conversionRate,
  });

  factory ProfilePerformanceData.fromJson(Map<String, dynamic> json) {
    double parseConversionRate(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        // Handle "0.0%" or "0.0"
        final clean = val.replaceAll('%', '').trim();
        return double.tryParse(clean) ?? 0.0;
      }
      return 0.0;
    }

    return ProfilePerformanceData(
      profileName: json['profileName'] ?? '',
      totalQueries: json['totalQueries'] ?? 0,
      convertedQueries: json['convertedQueries'] ?? 0,
      conversionRate: parseConversionRate(json['conversionRate']),
    );
  }
}
