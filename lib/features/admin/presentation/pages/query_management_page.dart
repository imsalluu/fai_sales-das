

import 'dart:convert';
import 'package:fai_dashboard_sales/core/theme/app_theme.dart';
import 'package:fai_dashboard_sales/features/auth/presentation/providers/auth_provider.dart';
import 'package:fai_dashboard_sales/models/query.dart';
import 'package:fai_dashboard_sales/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import 'package:fai_dashboard_sales/core/services/excel/excel_service.dart';

class QueryManagementPage extends ConsumerStatefulWidget {
  final VoidCallback? onAddOverride;
  final String? memberId;
  const QueryManagementPage({super.key, this.onAddOverride, this.memberId});

  @override
  ConsumerState<QueryManagementPage> createState() => _QueryManagementPageState();
}

class _QueryManagementPageState extends ConsumerState<QueryManagementPage> {
  static const double columnSum = 2480;
  static const double tableWidth = columnSum + 24; // 24 is horizonzal padding (12*2)
  
  String _searchQuery = "";
  String? _selectedEmployeeName;
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<SalesQuery> _getFilteredQueries(List<SalesQuery> queries) {
    return queries.where((q) {
      final matchesSearch = q.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesEmployee = _selectedEmployeeName == null || q.employeeName == _selectedEmployeeName;
      final matchesMemberId = widget.memberId == null || q.assignedMemberId == widget.memberId;
      
      return matchesSearch && matchesEmployee && matchesMemberId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final queriesAsync = ref.watch(projectsProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        queriesAsync.when(
          data: (queries) {
            final filtered = _getFilteredQueries(queries);
            return _buildHeader(filtered);
          },
          loading: () => _buildHeader([]),
          error: (_, __) => _buildHeader([]),
        ),
        const SizedBox(height: 24),
        usersAsync.when(
          data: (users) => _buildFilterBar(users),
          loading: () => _buildFilterBar([]),
          error: (_, __) => _buildFilterBar([]),
        ),
        const SizedBox(height: 24),
        _buildTableContainer(queriesAsync),
      ],
    );
  }

  Widget _buildHeader(List<SalesQuery> filteredQueries) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1400) { // Increased breakpoint to prevent header overflow
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sales", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 16),
              _buildHeaderActions(filteredQueries),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sales", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildHeaderActions(filteredQueries),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildHeaderActions(List<SalesQuery> filteredQueries) {
    final count = filteredQueries.length;
    final users = ref.watch(allUsersProvider).value ?? [];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text("Total $count sales", style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
        const SizedBox(width: 4),
        _buildGhostButton(
          Icons.description_outlined, 
          "Export Excel", 
          () => ExcelService.exportSalesQueries(filteredQueries)
        ),
        ElevatedButton.icon(
          onPressed: widget.onAddOverride ?? () => _showAddQueryDialog(users),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text("Add New Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGhostButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _buildFilterBar(List<User> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterSearch(),
          const SizedBox(width: 12),
          _buildFilterDropdown("Select Employee Name", _selectedEmployeeName, ['All Employees', ...users.map((m) => m.name)], (v) => setState(() {
            _selectedEmployeeName = (v == 'All Employees') ? null : v;
          })),
        ],
      ),
    );
  }

  Widget _buildFilterSearch() {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search sales...",
          hintStyle: const TextStyle(color: AppTheme.mutedTextColor),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.mutedTextColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
        onChanged: (val) {
          setState(() => _searchQuery = val);
        },
      ),
    );
  }

  Widget _buildFilterDate(String label, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (d != null) onSelect(d);
      },
      child: Container(
        width: 160,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(date != null ? DateFormat('MM/dd/yyyy').format(date) : label, style: TextStyle(fontSize: 13, color: date != null ? Colors.white : AppTheme.mutedTextColor))),
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.mutedTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String? val, List<String> items, Function(String?) onChange) {
    return Container(
      width: 160,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: val,
          hint: Text(label, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
          dropdownColor: AppTheme.cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.mutedTextColor),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, color: Colors.white)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildTableContainer(AsyncValue<List<SalesQuery>> queriesAsync) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: queriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (queries) => LayoutBuilder(
            builder: (context, constraints) => _buildTable(constraints.maxHeight, _getFilteredQueries(queries)),
          ),
        ),
      ),
    );
  }

 Widget _buildTable(double height, List<SalesQuery> queries) {
  return Scrollbar(
    controller: _horizontalScrollController,
    thumbVisibility: true,
    trackVisibility: true,
    thickness: 8,
    radius: const Radius.circular(4),
    scrollbarOrientation: ScrollbarOrientation.bottom,
    child: SingleChildScrollView(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: [
            _buildStickyHeader(),

            // ✅ FIX: height explicitly defined
            SizedBox(
              height: height - 44, // header height বাদ
              child: ListView.builder(
                itemCount: queries.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final q = queries[index];
                  return _buildTableRow(q, index);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  

  Widget _buildStickyHeader() {
  return Container(
    height: 44, // 🔥 FIXED SMALL HEIGHT
    alignment: Alignment.centerLeft,
    color: Colors.white.withOpacity(0.04),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      width: columnSum,
      child: Row(
        children: [
          const SizedBox(
            width: 50,
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                "#",
                style: TextStyle(
                  color: AppTheme.mutedTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          _HeaderCell("Date", 110),
          _HeaderCell("Employee Name", 170),
          _HeaderCell("Profile Name", 140),
          _HeaderCell("Client Name", 170),
          _HeaderCell("Source", 140),
          _HeaderCell("Service Line", 200),
          _HeaderCell("Country", 140),
          _HeaderCell("Quote", 150),
          _HeaderCell("Special Comment", 240),
          _HeaderCell("Query Status", 160),
          _HeaderCell("Follow up 01", 80),
          _HeaderCell("Follow up 02", 80),
          _HeaderCell("Follow up 03", 80),
          _HeaderCell("Conv. Status", 160),
          _HeaderCell("Sold By", 150),
          _HeaderCell("Monitoring Remark", 250),
        ],
      ),
    ),
  );
}


  Widget _HeaderCell(String label, double width) {
    return SizedBox(width: width, child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(label, style: const TextStyle(color: AppTheme.mutedTextColor, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
    ));
  }

  Widget _buildTableRow(SalesQuery q, int index) {
    return InkWell(
      onTap: () => _showEditQueryDialog(q),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
          color: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.01),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Consistent padding with header
        child: Container(
          width: columnSum, // Ensure exact alignment
          child: Row(
            children: [
              SizedBox(width: 50, child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Checkbox(value: false, onChanged: (v) {}, side: BorderSide(color: Colors.white.withOpacity(0.2))),
              )),
              _DataCell(DateFormat('MM/dd/yyyy').format(q.date), 110),
              _DataCell(q.employeeName, 170, isBold: true),
              _DataCell(q.profileName, 140),
              _DataCell(q.clientName, 170),
              _DataCell(q.source, 140),
              _DataCell(q.serviceLine, 200),
              _DataCell(q.country, 140),
              _DataCell(q.quote ?? "-", 150),
              _DataCell(q.specialComment ?? "-", 240),
              SizedBox(width: 160, child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildStatusChip(q.status),
              )),
              _FollowUpCell(q.followUp1Done, 80),
              _FollowUpCell(q.followUp2Done, 80),
              _FollowUpCell(q.followUp3Done, 80),
              SizedBox(width: 160, child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildConvStatusChip(q.conversationStatus),
              )),
              _DataCell(q.soldBy ?? "-", 150),
              _DataCell(q.monitoringRemark ?? "-", 250),
            ],
          ),
        ),
      ),
    );
  }

  Widget _DataCell(String text, double width, {bool isBold = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _FollowUpCell(bool done, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Center(
          child: Icon(
            done ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
            color: done ? AppTheme.secondaryColor : Colors.white.withOpacity(0.2),
            size: 18,
          ),
        ),
      ),
    );
  }


  Widget _buildStatusChip(QueryStatus status) {
    String text;
    Color color;

    switch (status) {
      case QueryStatus.customOfferSent: text = "Custom Offer Sent"; color = Colors.blue; break;
      case QueryStatus.briefCustomOfferSent: text = "Brief Custom Offer Sent"; color = Colors.lightBlue; break;
      case QueryStatus.briefReplied: text = "Brief Replied"; color = Colors.cyan; break;
      case QueryStatus.quoteSent: text = "Quote Sent"; color = Colors.indigo; break;
      case QueryStatus.featureListSent: text = "Feature List Sent"; color = Colors.teal; break;
      case QueryStatus.noResponse: text = "No Response"; color = Colors.grey; break;
      case QueryStatus.pass: text = "Pass"; color = Colors.blueGrey; break;
      case QueryStatus.spam: text = "Spam"; color = Colors.red.shade300; break;
      case QueryStatus.lowFocusCountry: text = "Low Focus Country"; color = Colors.brown; break;
      case QueryStatus.conversationRunning: text = "Conversation Running"; color = Colors.orange; break;
    }

    return _chip(text, color);
  }

  Widget _buildConvStatusChip(ConversationStatus status) {
    String text;
    Color color;

    switch (status) {
      case ConversationStatus.needToFollowUp: text = "Need to Follow-up"; color = Colors.orange; break;
      case ConversationStatus.followUpDone: text = "Follow-up Done"; color = Colors.blue; break;
      case ConversationStatus.sold: text = "Sold"; color = Colors.green; break;
      case ConversationStatus.neverCame: text = "Never Came"; color = Colors.red; break;
      case ConversationStatus.foundOtherDev: text = "Found Other DEV"; color = Colors.purple; break;
      case ConversationStatus.noNeedToFollowUp: text = "No Need to Follow-up"; color = Colors.grey; break;
    }

    return _chip(text, color);
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showAddQueryDialog(List<User> users) {
    final user = ref.read(authProvider).user;
    showDialog(
      context: context,
      builder: (context) => _AddQueryDialog(
        users: users,
        currentUserId: user?.id ?? '',
        userRole: user?.role ?? UserRole.sales_member,
        onSave: (newQuery) async {
          final isAdmin = user?.role == UserRole.sales_admin;
          final result = await ref.read(queryActionProvider.notifier).addProject(
            newQuery.toJson(isAdmin: isAdmin),
            isAdmin: isAdmin,
          );
          return result != null;
        },
      ),
    );
  }

  void _showEditQueryDialog(SalesQuery query) async {
    final users = ref.read(allUsersProvider).value ?? [];
    final user = ref.read(authProvider).user;
    
    // Show loading indicator or just fetch silently
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getProjectById(query.id);
    
    SalesQuery latestQuery = query;
    if (response.isSuccess) {
      latestQuery = SalesQuery.fromJson(response.responseData);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _AddQueryDialog(
        users: users,
        initialQuery: latestQuery,
        currentUserId: user?.id ?? '',
        userRole: user?.role ?? UserRole.sales_member,
        onSave: (updatedQuery) async {
          final result = await ref.read(queryActionProvider.notifier).updateProject(
            query.id, 
            updatedQuery.toJson(),
          );
          return result != null;
        },
      ),
    );
  }
}

class _AddQueryDialog extends ConsumerStatefulWidget {
  final List<User> users;
  final String currentUserId;
  final SalesQuery? initialQuery;
  final UserRole userRole;
  final Future<bool> Function(SalesQuery) onSave;

  const _AddQueryDialog({
    required this.users, 
    required this.currentUserId,
    required this.onSave, 
    required this.userRole,
    this.initialQuery,
  });

  @override
  ConsumerState<_AddQueryDialog> createState() => _AddQueryDialogState();
}

class _AddQueryDialogState extends ConsumerState<_AddQueryDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _date;
  late String? _employeeId;
  late String _profileName;
  late String _clientName;
  late String _source;
  late String _serviceLine;
  late String _country;
  late String _quote;
  late String _specialComment;
  late QueryStatus _status;
  late bool _f1;
  late bool _f2;
  late bool _f3;
  late ConversationStatus _convStatus;
  late String? _soldById;
  late String _monitoringRemark;
  
  final List<String> _validProfiles = [
    'Byte Craft', 'Drift AI', 'Fire AI', 'AI Byte', 
    'AI Hook', 'AI Nest', 'Zebra App', 'Turtle App', 'Logic AI'
  ];

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery;
    _date = q?.date ?? DateTime.now();
    
    // For members creating new queries, default to their own ID
    if (q == null && widget.userRole != UserRole.sales_admin) {
      _employeeId = widget.currentUserId;
    } else {
      _employeeId = q?.assignedMemberId ?? (widget.users.isNotEmpty ? widget.users.first.id : null);
    }
    
    // Ensure the profile exists in our list
    _profileName = q?.profileName ?? 'Byte Craft';
    if (!_validProfiles.contains(_profileName)) {
      _validProfiles.add(_profileName);
    }

    _clientName = q?.clientName ?? '';
    
    _source = q?.source ?? 'Query';
    final List<String> sourceItems = ['Query', 'Brief', 'Promoted', 'Direct Order', 'Referral'];
    if (!sourceItems.contains(_source)) {
      // We'll handle this in the build method by adding it to the list locally if needed
    }

    _serviceLine = q?.serviceLine ?? 'Custom Website';
    _country = q?.country ?? 'United States';
    _quote = q?.quote ?? '';
    _specialComment = q?.specialComment ?? '';
    _status = q?.status ?? QueryStatus.quoteSent;
    _f1 = q?.followUp1Done ?? false;
    _f2 = q?.followUp2Done ?? false;
    _f3 = q?.followUp3Done ?? false;
    _convStatus = q?.conversationStatus ?? ConversationStatus.needToFollowUp;
    _soldById = q?.soldById;
    _monitoringRemark = q?.monitoringRemark ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.initialQuery == null ? Icons.add_chart_rounded : Icons.edit_note_rounded,
                color: AppTheme.secondaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                widget.initialQuery == null ? "Add New Sale" : "Edit Sale",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.initialQuery == null 
                ? "Fill in the details below to register a new lead." 
                : "Update the existing lead information.",
            style: const TextStyle(fontSize: 13, color: AppTheme.mutedTextColor, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      scrollable: true,
      content: SizedBox(
        width: 850, // Increased width
        child: Form(
          key: _formKey,
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                labelStyle: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 14),
                hintStyle: const TextStyle(color: AppTheme.mutedTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                if (widget.userRole == UserRole.sales_admin) ...[
                  _buildRow(
                    DropdownButtonFormField<String>(
                      value: _employeeId,
                      decoration: const InputDecoration(
                        labelText: "Employee Name",
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.mutedTextColor),
                      ),
                      dropdownColor: AppTheme.cardColor,
                      items: widget.users.map((m) => DropdownMenuItem(
                        value: m.id, 
                        child: Text(m.name),
                      )).toList(),
                      onChanged: (val) => setState(() => _employeeId = val),
                    ),
                    DropdownButtonFormField<String>(
                      value: _profileName,
                      decoration: const InputDecoration(
                        labelText: "Profile Name ",
                        prefixIcon: Icon(Icons.business_center_outlined, size: 20, color: AppTheme.mutedTextColor),
                      ),
                      dropdownColor: AppTheme.cardColor,
                      items: _validProfiles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _profileName = val!),
                    ),
                  ),
                ] else ...[
                   DropdownButtonFormField<String>(
                    value: _profileName,
                    decoration: const InputDecoration(
                      labelText: "Profile Name ",
                      prefixIcon: Icon(Icons.business_center_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: _validProfiles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _profileName = val!),
                  ),
                ],
                const SizedBox(height: 20),
                _buildRow(
                  TextFormField(
                    initialValue: _clientName,
                    decoration: const InputDecoration(
                      labelText: "Client Name",
                      prefixIcon: Icon(Icons.face_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    onChanged: (val) => _clientName = val,
                  ),
                  DropdownButtonFormField<String>(
                    value: _source,
                    decoration: const InputDecoration(
                      labelText: "Source",
                      prefixIcon: Icon(Icons.hub_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: (() {
                      final items = ['Query', 'Brief', 'Promoted', 'Direct Order', 'Referral'];
                      if (!items.contains(_source)) items.add(_source);
                      return items;
                    })().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _source = val!),
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow(
                  DropdownButtonFormField<String>(
                    value: _serviceLine,
                    decoration: const InputDecoration(
                      labelText: "Service Line",
                      prefixIcon: Icon(Icons.settings_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: (() {
                      final items = [
                        'Custom Website', 'Mobile App', 'AI Mobile App', 
                        'AI Website', 'AI Agent', 'Chatbot', 'Not Clarified', 
                        'N8N Automation', 'Bug Fixing'
                      ];
                      if (!items.contains(_serviceLine)) items.add(_serviceLine);
                      return items;
                    })().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _serviceLine = val!),
                  ),
                  TextFormField(
                    initialValue: _country,
                    decoration: const InputDecoration(
                      labelText: "Country",
                      prefixIcon: Icon(Icons.public_rounded, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    onChanged: (val) => _country = val,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow(
                  TextFormField(
                    initialValue: _quote,
                    decoration: const InputDecoration(
                      labelText: "Quote URL",
                      prefixIcon: Icon(Icons.link_rounded, size: 20, color: AppTheme.mutedTextColor),
                      hintText: "http://example.com/quote",
                    ),
                    onChanged: (val) => _quote = val,
                  ),
                  DropdownButtonFormField<QueryStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: "Query Status",
                      prefixIcon: Icon(Icons.pending_actions_rounded, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: QueryStatus.values.map((s) {
                      String label = s.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toLowerCase();
                      label = label[0].toUpperCase() + label.substring(1);
                      return DropdownMenuItem(value: s, child: Text(label));
                    }).toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.checklist_rtl_rounded, size: 18, color: AppTheme.secondaryColor),
                          SizedBox(width: 8),
                          Text("Follow Up Checks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("F1", style: TextStyle(fontSize: 13, color: Colors.white)), 
                            value: _f1, 
                            onChanged: (v) => setState(() => _f1 = v!),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )),
                          Expanded(child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("F2", style: TextStyle(fontSize: 13, color: Colors.white)), 
                            value: _f2, 
                            onChanged: (v) => setState(() => _f2 = v!),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )),
                          Expanded(child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("F3", style: TextStyle(fontSize: 13, color: Colors.white)), 
                            value: _f3, 
                            onChanged: (v) => setState(() => _f3 = v!),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow(
                  DropdownButtonFormField<ConversationStatus>(
                    value: _convStatus,
                    decoration: const InputDecoration(
                      labelText: "Conversation Status",
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: ConversationStatus.values.map((s) {
                      String label = s.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toLowerCase();
                      label = label[0].toUpperCase() + label.substring(1);
                      return DropdownMenuItem(value: s, child: Text(label));
                    }).toList(),
                    onChanged: (val) => setState(() => _convStatus = val!),
                  ),
                  DropdownButtonFormField<String>(
                    value: _soldById,
                    decoration: const InputDecoration(
                      labelText: "Sold By",
                      prefixIcon: Icon(Icons.point_of_sale_rounded, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    dropdownColor: AppTheme.cardColor,
                    items: (() {
                      final ids = [null, ...widget.users.map((m) => m.id)];
                      if (_soldById != null && !ids.contains(_soldById)) {
                        ids.add(_soldById!);
                      }
                      return ids;
                    })().map((id) {
                      final member = widget.users.where((m) => m.id == id).firstOrNull;
                      return DropdownMenuItem(value: id, child: Text(member?.name ?? "None"));
                    }).toList(),
                    onChanged: (val) => setState(() => _soldById = val),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _specialComment,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Special Comment",
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.comment_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    hintText: "Add any special instructions or comments...",
                  ),
                  onChanged: (val) => _specialComment = val,
                ),
                const SizedBox(height: 20),
                if (widget.userRole == UserRole.sales_admin)
                  TextFormField(
                    initialValue: _monitoringRemark,
                    decoration: const InputDecoration(
                      labelText: "Monitoring Remark",
                      prefixIcon: Icon(Icons.monitor_heart_outlined, size: 20, color: AppTheme.mutedTextColor),
                    ),
                    onChanged: (val) => _monitoringRemark = val,
                  ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.mutedTextColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final member = widget.users.where((m) => m.id == _employeeId).firstOrNull;
              final query = SalesQuery(
                id: widget.initialQuery?.id ?? '',
                date: _date,
                employeeName: member?.name ?? "-",
                profileName: _profileName,
                clientName: _clientName,
                source: _source,
                serviceLine: _serviceLine,
                country: _country,
                quote: _quote,
                specialComment: _specialComment,
                status: _status,
                followUp1Done: _f1,
                followUp2Done: _f2,
                followUp3Done: _f3,
                conversationStatus: _convStatus,
                soldById: _soldById,
                soldBy: widget.users.where((m) => m.id == _soldById).firstOrNull?.name,
                monitoringRemark: _monitoringRemark,
                assignedMemberId: _employeeId ?? "",
              );
              
              final success = await widget.onSave(query);

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.initialQuery == null ? "Sale saved successfully" : "Sale updated successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                final error = ref.read(queryActionProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error?.toString() ?? "Failed to save sale. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please fill all required fields correctly."),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
          child: Text(widget.initialQuery == null ? "Save Sale" : "Update Sale"),
        ),
      ],
    );
  }

  Widget _buildRow(Widget w1, Widget w2) {
    return Row(
      children: [
        Expanded(child: w1),
        const SizedBox(width: 16),
        Expanded(child: w2),
      ],
    );
  }
}
