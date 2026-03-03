import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../models/sales_stats.dart';

final salesStatsProvider = FutureProvider<SalesStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getMyStats();
  
  if (response.isSuccess) {
    return SalesStats.fromJson(response.responseData);
  } else {
    throw Exception(response.errorMassage ?? 'Failed to load sales stats');
  }
});
