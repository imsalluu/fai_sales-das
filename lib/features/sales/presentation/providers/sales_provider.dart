import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../models/sales_stats.dart';

class SelectedYearNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().year;
  void update(int year) => state = year;
}
final selectedYearProvider = NotifierProvider<SelectedYearNotifier, int>(() => SelectedYearNotifier());

class SelectedMonthNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().month;
  void update(int month) => state = month;
}
final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, int>(() => SelectedMonthNotifier());

final salesStatsProvider = FutureProvider<SalesStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);
  
  final response = await apiService.getMyStats(year: year, month: month);
  
  if (response.isSuccess) {
    return SalesStats.fromJson(response.responseData);
  } else {
    throw Exception(response.errorMassage ?? 'Failed to load sales stats');
  }
});
