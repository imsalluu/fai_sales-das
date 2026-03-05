class SalesStats {
  final DashboardStatsSummary stats;
  final DashboardCounters counters;
  final List<WeeklyActivity> weeklyActivity;
  final List<Opportunity> recentOpportunities;

  SalesStats({
    required this.stats,
    required this.counters,
    required this.weeklyActivity,
    required this.recentOpportunities,
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      stats: DashboardStatsSummary.fromJson(json['stats'] ?? {}),
      counters: DashboardCounters.fromJson(json['counters'] ?? {}),
      weeklyActivity: (json['weeklyActivity'] as List? ?? [])
          .map((e) => WeeklyActivity.fromJson(e))
          .toList(),
      recentOpportunities: (json['recentOpportunities'] as List? ?? [])
          .map((e) => Opportunity.fromJson(e))
          .toList(),
    );
  }
}

class DashboardStatsSummary {
  final int totalQueries;
  final int converted;
  final int quoteSent;
  final String responseRate;

  DashboardStatsSummary({
    required this.totalQueries,
    required this.converted,
    required this.quoteSent,
    required this.responseRate,
  });

  factory DashboardStatsSummary.fromJson(Map<String, dynamic> json) {
    return DashboardStatsSummary(
      totalQueries: json['totalQueries'] ?? 0,
      converted: json['converted'] ?? 0,
      quoteSent: json['quoteSent'] ?? 0,
      responseRate: json['responseRate'] ?? '0%',
    );
  }
}

class DashboardCounters {
  final int pendingQuotes;
  final int followupsToday;
  final int highValueLeads;

  DashboardCounters({
    required this.pendingQuotes,
    required this.followupsToday,
    required this.highValueLeads,
  });

  factory DashboardCounters.fromJson(Map<String, dynamic> json) {
    return DashboardCounters(
      pendingQuotes: json['pendingQuotes'] ?? 0,
      followupsToday: json['followupsToday'] ?? 0,
      highValueLeads: json['highValueLeads'] ?? 0,
    );
  }
}

class WeeklyActivity {
  final String day;
  final int count;

  WeeklyActivity({required this.day, required this.count});

  factory WeeklyActivity.fromJson(Map<String, dynamic> json) {
    return WeeklyActivity(
      day: json['day'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class Opportunity {
  final String id;
  final String clientName;
  final String profileName;
  final String source;
  final String serviceLine;
  final String country;
  final String queryStatus;
  final DateTime createdAt;

  Opportunity({
    required this.id,
    required this.clientName,
    required this.profileName,
    required this.source,
    required this.serviceLine,
    required this.country,
    required this.queryStatus,
    required this.createdAt,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      profileName: json['profileName'] ?? '',
      source: json['source'] ?? '',
      serviceLine: json['serviceLine'] ?? '',
      country: json['country'] ?? '',
      queryStatus: json['queryStatus'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
