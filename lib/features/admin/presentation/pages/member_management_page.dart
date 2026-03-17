import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/user.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class MemberManagementPage extends ConsumerStatefulWidget {
  const MemberManagementPage({super.key});

  @override
  ConsumerState<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends ConsumerState<MemberManagementPage> {
  void _showAddMemberDialog({User? member}) {
    final isEditing = member != null;
    final nameController = TextEditingController(text: member?.name);
    final emailController = TextEditingController(text: member?.email);
    final passwordController = TextEditingController();
    UserRole selectedRole = member?.role ?? UserRole.sales_member;
    String selectedStatus = member?.status ?? 'active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(isEditing ? "Modify Personnel Protocol" : "Deploy New Field Agent", 
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Identification Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Communication Uplink (Email)"),
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController, 
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Access Cipher (Password)"), 
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Operational Rank"),
                  items: UserRole.values.map((role) => DropdownMenuItem(
                    value: role, 
                    child: Text(role.name.toUpperCase().replaceAll('_', ' ')),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Deployment Status"),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text("ACTIVE")),
                    DropdownMenuItem(value: 'inactive', child: Text("DEACTIVATED")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedStatus = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("ABORT", style: GoogleFonts.outfit(color: AppTheme.mutedTextColor, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': selectedRole.name,
                  'status': selectedStatus,
                };
                if (!isEditing) {
                  data['password'] = passwordController.text;
                }

                bool success;
                if (isEditing) {
                  success = await ref.read(userActionProvider.notifier).updateUser(member.id, data);
                } else {
                  success = await ref.read(userActionProvider.notifier).createUser(data);
                }

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: Text(isEditing ? "UPDATE PROTOCOL" : "INITIALIZE DEPLOYMENT", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final actionState = ref.watch(userActionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (actionState is AsyncLoading) const LinearProgressIndicator(color: AppTheme.primaryColor),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("Sales Force Alpha", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 4),
                Text("Personnel Roster & Operational Authorizations", style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.mutedTextColor, fontWeight: FontWeight.w500)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddMemberDialog(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("INITIALIZE NEW AGENT", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            error: (err, stack) => Center(child: Text("Communications Interrupted: $err", style: const TextStyle(color: Colors.red))),
            data: (members) => Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: AppTheme.softShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                itemCount: members.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 80),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final bool isActive = member.status == 'active';
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isActive ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2), 
                            AppTheme.backgroundColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (isActive ? AppTheme.primaryColor : Colors.grey).withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                          style: TextStyle(color: isActive ? AppTheme.primaryColor : Colors.grey, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white, letterSpacing: 0.2)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(member.role.name.toUpperCase().replaceAll('_', ' '), 
                            style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(member.email, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: (isActive ? Colors.green : Colors.red).withOpacity(0.2)),
                          ),
                          child: Text(isActive ? "ACTIVE" : "DEACTIVATE",
                            style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, size: 24, color: AppTheme.mutedTextColor), 
                          onPressed: () => _showAddMemberDialog(member: member),
                          tooltip: "Modify Protocol",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 24, color: AppTheme.primaryColor),
                          onPressed: () => _showDeleteConfirmation(member),
                          tooltip: "Terminate Access",
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(User member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("Critical Authorization Required", style: TextStyle(color: Colors.white)),
        content: Text("Are you certain you wish to terminate access for ${member.name}? This action cannot be easily reversed.", 
          style: const TextStyle(color: AppTheme.mutedTextColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT")),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(userActionProvider.notifier).deleteUser(member.id);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("TERMINATE ACCESS"),
          ),
        ],
      ),
    );
  }
}
