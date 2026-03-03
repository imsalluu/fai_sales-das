import 'package:flutter_riverpod/legacy.dart';

enum DashboardSection { 
  // Admin Sections
  overview, 
  team, 
  queries, 
  analytics,
  
  // Sales Sections
  salesOverview,
  addLead,
  tasks,
  mySales
}

final navigationProvider = StateProvider<DashboardSection>((ref) => DashboardSection.overview);
