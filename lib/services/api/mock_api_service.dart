import 'dart:math';
import '../../models/user.dart';
import '../../models/query.dart';
import '../../models/analytics.dart';

class MockApiService {
  static final List<User> _members = [
    User(id: '1', name: 'Salman', email: 'admin@gmail.com', password: '11', role: UserRole.sales_admin),
    User(id: '2', name: 'Md. Istiaqe Ahmed', email: 'istiaqe@fireai.agency', password: 'password123', role: UserRole.sales_member),
    User(id: '3', name: 'Md. Shahin Alam Alif', email: 'shahin@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '4', name: 'Saidul Islam Apu', email: 'opu@gmail.com', password: '11', role: UserRole.sales_member),
    User(id: '5', name: 'Nirmol Malo', email: 'nirmol@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '6', name: 'Sumaia Akther Urmi', email: 'urmi@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '7', name: 'Piqlu Chowdhury', email: 'piqlu@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '8', name: 'Minhaz Chowdhury', email: 'minhaz@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '9', name: 'AKASH', email: 'akash@fireai.com', password: 'password123', role: UserRole.sales_member),
    User(id: '10', name: 'Kritab Mondal Tanu', email: 'tanu@fireai.com', password: 'password123', role: UserRole.sales_member),
  ];

  static List<SalesQuery> _queries = List.generate(100, (index) {
    final employeeNames = [
      'Piqlu Chowdhury', 'Minhaz Chowdhury', 'AKASH', 'Nirmol Malo', 
      'Saidul Islam Apu', 'Md. Istiaqe Ahmed', 'Kritab Mondal Tanu', 
      'MD Shahin Alam Alif', 'Sumaia Akther Urmi'
    ];
    final profiles = [
      'Byte Craft', 'Drift AI', 'Fire AI', 'AI Byte', 
      'AI Hook', 'AI Nest', 'Zebra App', 'Turtle App', 'Logic AI'
    ];
    final sources = ['Query', 'Brief', 'Promoted', 'Direct Order', 'Referral'];
    final services = [
      'Custom Website', 'Mobile App', 'AI Mobile App', 
      'AI Website', 'AI Agent', 'Chatbot', 'Not Clarified', 
      'N8N Automation', 'Bux fixing'
    ];
    final countries = ['United States', 'Pakistan', 'Georgia', 'Germany', 'United Kingdom'];
    final status = QueryStatus.values[index % QueryStatus.values.length];
    final convStatus = ConversationStatus.values[index % ConversationStatus.values.length];
    
    return SalesQuery(
      id: 'FO${index + 1000}',
      date: DateTime.now().subtract(Duration(days: index % 30)),
      employeeName: employeeNames[index % employeeNames.length],
      profileName: profiles[index % profiles.length],
      clientName: ['timio155', 'Quasim Z', 'ankur7037', 'konstantinekha', 'josepht'][index % 5],
      source: sources[index % sources.length],
      serviceLine: services[index % services.length],
      country: countries[index % countries.length],
      quote: index % 2 == 0 ? 'SYNQ - Social M...' : '-',
      specialComment: index % 3 == 0 ? "quotation sent need to follow" : "-",
      status: status,
      followUp1Done: index % 2 == 0,
      followUp2Done: index % 4 == 0,
      followUp3Done: index % 5 == 0,
      conversationStatus: convStatus,
      soldBy: index % 2 == 0 ? employeeNames[(index + 1) % employeeNames.length] : null,
      monitoringRemark: index % 4 == 0 ? "Potential client" : "-",
      assignedMemberId: (index % 7 + 1).toString(),
    );
  });

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _members.firstWhere((u) => u.email == email && u.password == password);
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
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardStats(
      totalSales: 296971,
      totalSalesCount: 100,
      deliveredAmount: 37396,
      deliveredCount: 19,
      cancelledAmount: 0,
      cancelledCount: 8,
      completeAmount: 0,
      completeCount: 0,
      nraAmount: 12000,
      nraCount: 13,
      issuesAmount: 0,
      issuesCount: 0,
    );
  }

  Future<ActionCount> getActionCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ActionCount(
      customOfferSent: 45,
      briefCustomOfferSent: 12,
      conversationRunning: 8,
      featureListSent: 5,
      pass: 3,
      spam: 15,
      noResponse: 20,
      repeat: 2,
      directOrder: 1,
    );
  }

  Future<ConversionRatio> getConversionRatio() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ConversionRatio(
      queries: 159,
      briefs: 39,
      quoteSent: 60,
      converted: 4,
      totalReceivedMessages: 198,
      conversionRate: 2.02,
    );
  }

  Future<List<PerformanceData>> getPerformance() async {
    final List<Map<String, dynamic>> performanceMock = [
      {'name': 'Md. Shahin Alam Alif', 'target': 5000, 'achieved': 3120, 'orders': 5},
      {'name': 'Md. Istiaqe Ahmed', 'target': 7000, 'achieved': 4240, 'orders': 1},
      {'name': 'Saidul Islam Apu', 'target': 5000, 'achieved': 2701.6, 'orders': 5},
      {'name': 'Nirmol Malo', 'target': 5000, 'achieved': 1680, 'orders': 3},
      {'name': 'Sumaia Akther Urmi', 'target': 5000, 'achieved': 1528, 'orders': 3},
      {'name': 'Piqlu Chowdhury', 'target': 15000, 'achieved': 3520, 'orders': 2},
      {'name': 'Minhaz Chowdhury', 'target': 8000, 'achieved': 1200, 'orders': 1},
      {'name': 'AKASH', 'target': 6000, 'achieved': 2500, 'orders': 4},
      {'name': 'Kritab Mondal Tanu', 'target': 5000, 'achieved': 0, 'orders': 0},
    ];

    return performanceMock.map((m) => PerformanceData(
      memberName: m['name'],
      target: (m['target'] as int).toDouble(),
      achieved: (m['achieved'] as num).toDouble(),
      achievementPercentage: (m['achieved'] / m['target']) * 100,
      orders: m['orders'],
    )).toList();
  }

  // Future<List<IndividualPerformance>> getIndividualPerformance() async {
  //   return [
  //     IndividualPerformance(name: 'Md. Istiaqe Ahmed', totalQueries: 12, convertedQueries: 8, conversionRate: 66.7),
  //     IndividualPerformance(name: 'Minhaz Chowdhury', totalQueries: 6, convertedQueries: 1, conversionRate: 16.7),
  //     IndividualPerformance(name: 'Nirmol Malo', totalQueries: 42, convertedQueries: 1, conversionRate: 2.4),
  //     IndividualPerformance(name: 'Md. Shahin Alam Alif', totalQueries: 26, convertedQueries: 5, conversionRate: 19.2),
  //     IndividualPerformance(name: 'Saidul Islam Apu', totalQueries: 33, convertedQueries: 4, conversionRate: 12.1),
  //     IndividualPerformance(name: 'Sumaia Akther Urmi', totalQueries: 15, convertedQueries: 3, conversionRate: 20.0),
  //     IndividualPerformance(name: 'Piqlu Chowdhury', totalQueries: 20, convertedQueries: 4, conversionRate: 20.0),
  //     IndividualPerformance(name: 'AKASH', totalQueries: 10, convertedQueries: 4, conversionRate: 40.0),
  //     IndividualPerformance(name: 'Kritab Mondal Tanu', totalQueries: 2, convertedQueries: 0, conversionRate: 0.0),
  //   ];
  // }

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

  Future<void> updateQuery(SalesQuery query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _queries.indexWhere((q) => q.id == query.id);
    if (index != -1) {
      _queries[index] = query;
    }
  }

  Future<List<ProfilePerformance>> getProfilePerformance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ProfilePerformance(profileName: 'Byte Craft', totalQueries: 41, convertedQueries: 10, conversionRate: 24.5),
      ProfilePerformance(profileName: 'Drift AI', totalQueries: 38, convertedQueries: 8, conversionRate: 21.0),
      ProfilePerformance(profileName: 'Fire AI', totalQueries: 28, convertedQueries: 6, conversionRate: 21.4),
      ProfilePerformance(profileName: 'AI Byte', totalQueries: 16, convertedQueries: 4, conversionRate: 25.0),
      ProfilePerformance(profileName: 'AI Hook', totalQueries: 45, convertedQueries: 12, conversionRate: 26.6),
      ProfilePerformance(profileName: 'AI Nest', totalQueries: 32, convertedQueries: 9, conversionRate: 28.1),
      ProfilePerformance(profileName: 'Zebra App', totalQueries: 18, convertedQueries: 3, conversionRate: 16.6),
      ProfilePerformance(profileName: 'Turtle App', totalQueries: 12, convertedQueries: 1, conversionRate: 8.3),
      ProfilePerformance(profileName: 'Logic AI', totalQueries: 25, convertedQueries: 5, conversionRate: 20.0),
    ];
  }
}
