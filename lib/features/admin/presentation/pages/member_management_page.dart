import 'package:flutter/material.dart';
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
    String selectedProfile = member?.assignedProfile ?? 'AI Hook';

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
            DropdownButtonFormField<String>(
              value: selectedProfile,
              dropdownColor: AppTheme.cardColor,
              decoration: const InputDecoration(labelText: "Assign Profile"),
              items: ['AI Hook', 'Drift AI', 'AI Nest', 'Fire AI', 'AI Byte', 'Byte Craft']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => selectedProfile = val!,
            ),
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
                role: UserRole.sales,
                assignedProfile: selectedProfile,
              );
              if (isEditing) {
                await _api.updateMember(newUser);
              } else {
                await _api.addMember(newUser);
              }
              Navigator.pop(context);
              if (!mounted) return;
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
            Text("Sales Team Control", style: Theme.of(context).textTheme.headlineMedium),
            ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Deploy New Member"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: _members.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 80),
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(member.name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("${member.email} • ${member.assignedProfile ?? 'No Profile'}", style: const TextStyle(color: AppTheme.mutedTextColor)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("ONLINE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, size: 24, color: AppTheme.mutedTextColor), 
                              onPressed: () => _showAddMemberDialog(member: member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 24, color: AppTheme.primaryColor),
                              onPressed: () async {
                                await _api.deleteMember(member.id);
                                _loadMembers();
                              },
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
