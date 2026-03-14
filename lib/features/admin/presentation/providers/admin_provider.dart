import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../models/analytics.dart';
import '../../../../models/notification.dart';
import '../../../../models/executive_stats.dart';
import '../../../../models/query.dart';
import '../../../../models/user.dart';
import '../../../../services/api/api_service.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getNotifications();

  if (response.isSuccess && response.responseData is List) {
    return (response.responseData as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  } else {
    return [];
  }
});

final performanceProvider = FutureProvider<List<IndividualPerformance>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getPerformance();

  if (response.isSuccess && response.responseData is List) {
    return (response.responseData as List)
        .map((e) => IndividualPerformance.fromJson(e))
        .toList();
  } else {
    throw Exception(response.errorMassage ?? 'Failed to load performance');
  }
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getUsers();
  if (response.isSuccess && response.responseData is List) {
    return (response.responseData as List)
        .map((e) => User.fromJson(e))
        .toList();
  }
  return [];
});

final userActionProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<void>>((ref) {
      return UserNotifier(ref.read(apiServiceProvider), ref);
    });

class UserNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;
  final Ref _ref;

  UserNotifier(this._apiService, this._ref)
    : super(const AsyncValue.data(null));

  Future<bool> createUser(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final response = await _apiService.createUser(data);
    if (response.isSuccess) {
      state = const AsyncValue.data(null);
      _ref.invalidate(usersProvider);
      _ref.invalidate(membersProvider);
      return true;
    } else {
      state = AsyncValue.error(
        response.errorMassage ?? 'Failed to create user',
        StackTrace.current,
      );
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final response = await _apiService.updateUser(id, data);
    if (response.isSuccess) {
      state = const AsyncValue.data(null);
      _ref.invalidate(usersProvider);
      _ref.invalidate(membersProvider);
      return true;
    } else {
      state = AsyncValue.error(
        response.errorMassage ?? 'Failed to update user',
        StackTrace.current,
      );
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    state = const AsyncValue.loading();
    final response = await _apiService.deleteUser(id);
    if (response.isSuccess) {
      state = const AsyncValue.data(null);
      _ref.invalidate(usersProvider);
      _ref.invalidate(membersProvider);
      return true;
    } else {
      state = AsyncValue.error(
        response.errorMassage ?? 'Failed to delete user',
        StackTrace.current,
      );
      return false;
    }
  }
}

final executiveStatsProvider = FutureProvider<ExecutiveStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getExecutiveStats();

  if (response.isSuccess) {
    return ExecutiveStats.fromJson(response.responseData);
  } else {
    throw Exception(response.errorMassage ?? 'Failed to load executive stats');
  }
});

final projectsProvider = FutureProvider<List<SalesQuery>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getProjects();

  if (response.isSuccess) {
    final List<dynamic> data = response.responseData;
    return data.map((json) => SalesQuery.fromJson(json)).toList();
  } else {
    throw Exception(response.errorMassage ?? 'Failed to load projects');
  }
});

final membersProvider = FutureProvider<List<User>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getMembers();
  if (response.isSuccess) {
    final List<dynamic> data = response.responseData;
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    return [];
  }
});

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final users = await ref.watch(usersProvider.future);
  final members = await ref.watch(membersProvider.future);
  
  // Combine and remove duplicates by ID
  final Map<String, User> userMap = {};
  for (var u in users) {
    userMap[u.id] = u;
  }
  for (var m in members) {
    userMap[m.id] = m;
  }
  
  return userMap.values.toList();
});

class QueryNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;
  final Ref _ref;

  QueryNotifier(this._apiService, this._ref)
    : super(const AsyncValue.data(null));

  Future<SalesQuery?> addProject(Map<String, dynamic> data, {bool isAdmin = false}) async {
    try {
      debugPrint("SAVING PROJECT - isAdmin: $isAdmin");
      debugPrint("Payload: ${jsonEncode(data)}");
      state = const AsyncValue.loading();
      final response = isAdmin 
          ? await _apiService.createAdminProject(data)
          : await _apiService.createProject(data);

      print("API Response: ${response.responseData}");
      print("API Error: ${response.errorMassage}");

      if (response.isSuccess) {
        final raw = response.responseData;
        Map<String, dynamic> projectJson;
        
        if (raw is Map) {
          if (raw.containsKey('project')) {
            projectJson = raw['project'];
          } else {
            projectJson = raw as Map<String, dynamic>;
          }
        } else {
          throw Exception("Unexpected response format: $raw");
        }

        final project = SalesQuery.fromJson(projectJson);
        state = const AsyncValue.data(null);
        _ref.invalidate(projectsProvider);
        return project;
      } else {
        debugPrint("API FAILURE - Status: ${response.statusCode}");
        debugPrint("Error Body: ${response.responseData}");
        
        String errorMsg = response.errorMassage ?? 'Failed to add project';
        if (response.responseData is Map && response.responseData['message'] != null) {
          errorMsg = response.responseData['message'];
        }
        
        state = AsyncValue.error(
          errorMsg,
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stack) {
      debugPrint("EXCEPTION during addProject: $e");
      debugPrint("Stacktrace: $stack");
      state = AsyncValue.error(e.toString(), stack);
      return null;
    }
  }

  Future<SalesQuery?> updateProject(String id, Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.updateProject(id, data);
      if (response.isSuccess) {
        final projectData = response.responseData['project'];
        final project = SalesQuery.fromJson(projectData);
        state = const AsyncValue.data(null);
        _ref.invalidate(projectsProvider);
        return project;
      } else {
        state = AsyncValue.error(
          response.errorMassage ?? 'Failed to update project',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiService.deleteProject(id);
      if (response.isSuccess) {
        state = const AsyncValue.data(null);
        _ref.invalidate(projectsProvider);
        return true;
      } else {
        state = AsyncValue.error(
          response.errorMassage ?? 'Failed to delete project',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final queryActionProvider =
    StateNotifierProvider<QueryNotifier, AsyncValue<void>>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return QueryNotifier(apiService, ref);
    });
