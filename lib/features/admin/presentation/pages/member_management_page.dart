import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/user.dart';
import '../../../../services/api/mock_api_service.dart';
import '../../../../core/theme/app_theme.dart';

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({super.key});

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  final _api = MockApiService();
  List<User> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await _api.getMembers();
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  void _showAddMemberDialog({User? member}) {
    final isEditing = member != null;
    final nameController = TextEditingController(text: member?.name);
    final emailController = TextEditingController(text: member?.email);
    final passwordController = TextEditingController(text: member?.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(isEditing ? "Edit Member" : "Add New Sales Member", style: const TextStyle(color: AppTheme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 12),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppTheme.mutedTextColor))),
          ElevatedButton(
            onPressed: () async {
              final newUser = User(
                id: isEditing ? member.id : DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
                role: UserRole.sales,
              );
              if (isEditing) {
                await _api.updateMember(newUser);
              } else {
                await _api.addMember(newUser);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadMembers();
            },
            child: Text(isEditing ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sales Team Control", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 4),
                Text("Operational Personnel & Permissions", style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.mutedTextColor, fontWeight: FontWeight.w500)),
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
                label: const Text("Deploy New Member", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: _members.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 80),
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.backgroundColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white, letterSpacing: 0.2)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(member.email, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withOpacity(0.2)),
                              ),
                              child: const Text("OPERATIONAL", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, size: 28, color: AppTheme.mutedTextColor), 
                              onPressed: () => _showAddMemberDialog(member: member),
                              tooltip: "Modify Protocol",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 28, color: AppTheme.primaryColor),
                              onPressed: () async {
                                await _api.deleteMember(member.id);
                                _loadMembers();
                              },
                              tooltip: "Terminate Access",
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
