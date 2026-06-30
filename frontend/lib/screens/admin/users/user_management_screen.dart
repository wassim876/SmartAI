import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../../theme/dark_mode_helpers.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _filteredUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFilteredUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.fetchUsers();
      if (mounted) _updateFilteredUsers();
    } catch (e) {
      if (mounted) _showSnackBar('Error loading users: ${e.toString()}', const Color(0xFFEF4444));
    }
  }

  void _updateFilteredUsers() {
    final allUsers = context.read<AuthProvider>().users;
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredUsers = allUsers;
      } else {
        final searchLower = _searchQuery.toLowerCase();
        _filteredUsers = allUsers.where((user) {
          return user.username.toLowerCase().contains(searchLower) ||
              user.email.toLowerCase().contains(searchLower) ||
              user.displayName.toLowerCase().contains(searchLower);
        }).toList();
      }
    });
  }

  void _filterUsers(String query) {
    _searchQuery = query;
    _updateFilteredUsers();
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: D.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: user.isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
              child: Text(user.username[0].toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(user.username, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: D.t1(context)))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoTile('Username', user.username),
              _buildInfoTile('Email', user.email),
              _buildInfoTile('Role', user.role),
              _buildInfoTile('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildInfoTile('Premium', user.isPremium ? 'Yes' : 'No'),
              _buildInfoTile('Joined', _formatDate(user.createdAt)),
              _buildInfoTile('Daily Usage', '${user.dailyMessagesUsed}/${user.dailyMessagesLimit}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: D.t2(context))),
          ),
          ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); _showEditUserDialog(user); },
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text('Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: D.t3(context))),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: D.t1(context))),
          Divider(color: D.divider(context), height: 12),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditUserDialog(UserModel user) {
    final TextEditingController nameController = TextEditingController(text: user.displayName);
    final TextEditingController emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;
    bool isActive = user.isActive;
    bool isPremium = user.isPremium;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: D.card(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: D.t1(context))),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(nameController, 'Name'),
                const SizedBox(height: 12),
                _dialogTextField(emailController, 'Email'),
                const SizedBox(height: 12),
                _dialogDropdown(selectedRole, (v) => setDialogState(() => selectedRole = v!)),
                const SizedBox(height: 8),
                _dialogSwitch('Active', isActive, (v) => setDialogState(() => isActive = v)),
                _dialogSwitch('Premium', isPremium, (v) => setDialogState(() => isPremium = v)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: D.t2(context))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setDialogState(() => isSaving = true);
                try {
                  final authProvider = context.read<AuthProvider>();
                  final nav = Navigator.of(context);
                  await authProvider.updateUser(user.uid, {
                    'first_name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'is_active': isActive,
                    'is_premium': isPremium,
                  });
                  if (mounted) {
                    nav.pop();
                    _showSnackBar('User updated successfully!', const Color(0xFF10B981));
                    await _fetchUsers();
                  }
                } catch (e) {
                  if (mounted) {
                    setDialogState(() => isSaving = false);
                    _showSnackBar('Error: ${e.toString()}', const Color(0xFFEF4444));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: D.t2(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
        filled: true,
        fillColor: D.inputFill(context),
      ),
      style: GoogleFonts.poppins(color: D.t1(context)),
    );
  }

  Widget _dialogDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: D.card(context),
      items: [
        DropdownMenuItem(value: 'User', child: Text('User', style: GoogleFonts.poppins(color: D.t1(context)))),
        DropdownMenuItem(value: 'Staff', child: Text('Staff', style: GoogleFonts.poppins(color: D.t1(context)))),
        DropdownMenuItem(value: 'Admin', child: Text('Admin', style: GoogleFonts.poppins(color: D.t1(context)))),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: GoogleFonts.poppins(color: D.t2(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
        filled: true,
        fillColor: D.inputFill(context),
      ),
      style: GoogleFonts.poppins(color: D.t1(context)),
    );
  }

  Widget _dialogSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: GoogleFonts.poppins(color: D.t1(context), fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF6C63FF),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.toggleUserStatus(user.uid);
      if (mounted) {
        await _fetchUsers();
        _showSnackBar('User ${user.isActive ? 'deactivated' : 'activated'} successfully!', const Color(0xFFF59E0B));
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: ${e.toString()}', const Color(0xFFEF4444));
    }
  }

  Future<void> _toggleUserPremium(UserModel user) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.toggleUserPremium(user.uid);
      if (mounted) {
        await _fetchUsers();
        _showSnackBar('Premium ${user.isPremium ? 'disabled' : 'enabled'} for ${user.username}!', const Color(0xFF10B981));
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: ${e.toString()}', const Color(0xFFEF4444));
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: D.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: D.t1(context))),
        content: Text('Are you sure you want to delete "${user.displayName}"?\n\nThis action cannot be undone.', style: GoogleFonts.poppins(color: D.t2(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins(color: D.t2(context)))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.deleteUser(user.uid);
        if (mounted) {
          await _fetchUsers();
          _showSnackBar('User deleted successfully!', const Color(0xFF10B981));
        }
      } catch (e) {
        if (mounted) _showSnackBar('Error: ${e.toString()}', const Color(0xFFEF4444));
      }
    }
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'User';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: D.card(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: D.t1(context))),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogTextField(usernameController, 'Username'),
                  const SizedBox(height: 12),
                  _dialogTextField(nameController, 'Full Name'),
                  const SizedBox(height: 12),
                  _dialogTextField(emailController, 'Email'),
                  const SizedBox(height: 12),
                  _dialogTextField(passwordController, 'Password'),
                  const SizedBox(height: 12),
                  _dialogDropdown(selectedRole, (v) => setDialogState(() => selectedRole = v!)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: D.t2(context))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                  _showSnackBar('Please fill all required fields', const Color(0xFFF59E0B));
                  return;
                }
                setDialogState(() => isSaving = true);
                try {
                  final authProvider = context.read<AuthProvider>();
                  final nav = Navigator.of(context);
                  await authProvider.createUser({
                    'username': usernameController.text,
                    'first_name': nameController.text,
                    'email': emailController.text,
                    'password': passwordController.text,
                    'role': selectedRole,
                  });
                  if (mounted) {
                    nav.pop();
                    _showSnackBar('User created successfully!', const Color(0xFF10B981));
                    await _fetchUsers();
                  }
                } catch (e) {
                  if (mounted) {
                    setDialogState(() => isSaving = false);
                    _showSnackBar('Error: ${e.toString()}', const Color(0xFFEF4444));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Create', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading && _filteredUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authProvider.errorMessage != null && _filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Failed to load users', style: GoogleFonts.poppins(fontSize: 18, color: D.t1(context))),
            const SizedBox(height: 8),
            Text(authProvider.errorMessage!, style: GoogleFonts.poppins(color: D.t2(context)), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchUsers,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Management', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Manage all registered users on the platform', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Add New User', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: D.bd(context)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: Icon(Icons.search_rounded, color: D.t3(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: D.bd(context))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
                      filled: true,
                      fillColor: D.inputFill(context),
                      hintStyle: GoogleFonts.poppins(color: D.t3(context)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: Icon(Icons.clear_rounded, color: D.t3(context)), onPressed: () { _searchQuery = ''; _updateFilteredUsers(); })
                          : null,
                    ),
                    style: GoogleFonts.poppins(color: D.t1(context)),
                  ),
                ),
                Divider(height: 1, color: D.divider(context)),
                authProvider.isLoading
                    ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
                    : authProvider.errorMessage != null
                        ? Padding(padding: const EdgeInsets.all(20), child: Text(authProvider.errorMessage!, style: GoogleFonts.poppins(color: const Color(0xFFEF4444))))
                        : _filteredUsers.isEmpty
                            ? Padding(padding: const EdgeInsets.all(20), child: Text('No users found.', style: GoogleFonts.poppins(color: D.t2(context))))
                            : LayoutBuilder(
                                builder: (context, tableConstraints) {
                                  final tableWidth = tableConstraints.maxWidth < 900 ? 900.0 : tableConstraints.maxWidth;
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: tableWidth,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(children: [
                                          Expanded(flex: 3, child: _buildTableHeader('USERNAME')),
                                          Expanded(flex: 2, child: _buildTableHeader('DISPLAY NAME')),
                                          Expanded(flex: 2, child: _buildTableHeader('JOINED DATE')),
                                          Expanded(flex: 1, child: _buildTableHeader('STATUS')),
                                          Expanded(flex: 2, child: _buildTableHeader('ACTIONS')),
                                        ]),
                                      ),
                                      Divider(height: 1, color: D.divider(context)),
                                      ..._filteredUsers.map((user) => _buildUserRow(user)),
                                    ],
                                  ),
                                ),
                              );
                            },
                              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: D.t2(context), letterSpacing: 0.5));
  }

  Widget _buildUserRow(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  child: Text(user.username[0].toUpperCase(), style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(user.username, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: D.t1(context), fontSize: 13))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.displayName, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(_formatDate(user.createdAt), style: GoogleFonts.poppins(color: D.t2(context), fontSize: 13)),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive ? const Color(0xFF10B981).withValues(alpha: 0.12) : const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(Icons.visibility_outlined, size: 20, color: D.t3(context)),
                    onPressed: () => _showUserDetails(user),
                    tooltip: 'View User Details',
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(Icons.more_vert_rounded, size: 20, color: D.t3(context)),
                    onPressed: () {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final Offset offset = renderBox.localToGlobal(Offset.zero);
                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(offset.dx + 100, offset.dy + 100, offset.dx + 100, offset.dy + 100),
                        color: D.card(context),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: D.bd(context))),
                        items: [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit_rounded, size: 18, color: D.t1(context)),
                              const SizedBox(width: 12),
                              Text('Edit User', style: GoogleFonts.poppins(color: D.t1(context))),
                            ]),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle_status',
                            child: Row(children: [
                              Icon(user.isActive ? Icons.block_rounded : Icons.check_circle_rounded, size: 18, color: user.isActive ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                              const SizedBox(width: 12),
                              Text(user.isActive ? 'Deactivate' : 'Activate', style: GoogleFonts.poppins(color: D.t1(context))),
                            ]),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle_premium',
                            child: Row(children: [
                              Icon(user.isPremium ? Icons.star_border_rounded : Icons.star_rounded, size: 18, color: const Color(0xFFF59E0B)),
                              const SizedBox(width: 12),
                              Text(user.isPremium ? 'Remove Premium' : 'Make Premium', style: GoogleFonts.poppins(color: D.t1(context))),
                            ]),
                          ),
                          PopupMenuDivider(color: D.divider(context)),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(children: [
                              const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                              const SizedBox(width: 12),
                              Text('Delete User', style: GoogleFonts.poppins(color: const Color(0xFFEF4444))),
                            ]),
                          ),
                        ],
                      ).then((value) {
                        if (value != null) {
                          switch (value) {
                            case 'edit': _showEditUserDialog(user); break;
                            case 'toggle_status': _toggleUserStatus(user); break;
                            case 'toggle_premium': _toggleUserPremium(user); break;
                            case 'delete': _deleteUser(user); break;
                          }
                        }
                      });
                    },
                    tooltip: 'More Actions',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
