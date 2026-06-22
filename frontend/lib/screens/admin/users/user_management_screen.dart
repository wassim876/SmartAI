// lib/screens/admin/users/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';

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

      if (mounted) {
        _updateFilteredUsers();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading users: ${e.toString()}', Colors.red);
      }
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

  // ============ VIEW USER DETAILS ============
  void _showUserDetails(UserModel user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: user.isAdmin ? Colors.purple : Colors.blue,
              child: Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.username,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoTile('Username', user.username, isDark),
              _buildInfoTile('Email', user.email, isDark),
              _buildInfoTile('Role', user.role, isDark),
              _buildInfoTile(
                  'Status', user.isActive ? 'Active' : 'Inactive', isDark),
              _buildInfoTile('Premium', user.isPremium ? 'Yes' : 'No', isDark),
              _buildInfoTile('Joined', _formatDate(user.createdAt), isDark),
              _buildInfoTile(
                  'Daily Usage',
                  '${user.dailyMessagesUsed}/${user.dailyMessagesLimit}',
                  isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditUserDialog(user);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A4FCF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ============ EDIT USER ============
  void _showEditUserDialog(UserModel user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController nameController =
        TextEditingController(text: user.displayName);
    final TextEditingController emailController =
        TextEditingController(text: user.email);
    String selectedRole = user.role;
    bool isActive = user.isActive;
    bool isPremium = user.isPremium;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
          title: Text(
            'Edit User',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  dropdownColor:
                      isDark ? const Color(0xFF1E1E3F) : Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'User', child: Text('User')),
                    DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(
                    'Active',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() {
                      isActive = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF5A4FCF),
                ),
                SwitchListTile(
                  title: Text(
                    'Premium',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: isPremium,
                  onChanged: (value) {
                    setDialogState(() {
                      isPremium = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF5A4FCF),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
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
                          _showSnackBar(
                              'User updated successfully!', Colors.green);
                          await _fetchUsers();
                        }
                      } catch (e) {
                        if (mounted) {
                          setDialogState(() => isSaving = false);
                          _showSnackBar('Error: ${e.toString()}', Colors.red);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A4FCF),
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TOGGLE STATUS ============
  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.toggleUserStatus(user.uid);

      if (mounted) {
        await _fetchUsers();
        _showSnackBar(
          'User ${user.isActive ? 'deactivated' : 'activated'} successfully!',
          Colors.orange,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  // ============ TOGGLE PREMIUM ============
  Future<void> _toggleUserPremium(UserModel user) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.toggleUserPremium(user.uid);

      if (mounted) {
        await _fetchUsers();
        _showSnackBar(
          'Premium ${user.isPremium ? 'disabled' : 'enabled'} for ${user.username}!',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  // ============ DELETE USER ============
  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete "${user.displayName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
          _showSnackBar('User deleted successfully!', Colors.green);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error: ${e.toString()}', Colors.red);
        }
      }
    }
  }

  // ============ ADD NEW USER ============
  void _showAddUserDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
          title: Text(
            'Add New User',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    dropdownColor:
                        isDark ? const Color(0xFF1E1E3F) : Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'User', child: Text('User')),
                      DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (usernameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        _showSnackBar(
                            'Please fill all required fields', Colors.orange);
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
                          _showSnackBar(
                              'User created successfully!', Colors.green);
                          await _fetchUsers();
                        }
                      } catch (e) {
                        if (mounted) {
                          setDialogState(() => isSaving = false);
                          _showSnackBar('Error: ${e.toString()}', Colors.red);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A4FCF),
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ============ SNACKBAR HELPER ============
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading && _filteredUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (authProvider.errorMessage != null && _filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load users',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.errorMessage!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A4FCF),
                foregroundColor: Colors.white,
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
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all registered users on the platform',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Users Table
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161622) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF2A2A3E) : Colors.grey[50],
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchQuery = '';
                                _updateFilteredUsers();
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.grey[200],
                ),

                // Scrollable Table Content
                authProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    : authProvider.errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : _filteredUsers.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No users found.'),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width:
                                      1000, // Fixed width prevents layout crash with Expanded widgets
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: _buildTableHeader(
                                                    'USERNAME', isDark)),
                                            Expanded(
                                                flex: 3,
                                                child: _buildTableHeader(
                                                    'DISPLAY NAME', isDark)),
                                            Expanded(
                                                flex: 2,
                                                child: _buildTableHeader(
                                                    'JOINED DATE', isDark)),
                                            Expanded(
                                                flex: 1,
                                                child: _buildTableHeader(
                                                    'STATUS', isDark)),
                                            Expanded(
                                                flex: 1,
                                                child: _buildTableHeader(
                                                    'ACTIONS', isDark)),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                          height: 1,
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.grey[200]),
                                      ..._filteredUsers.map((user) =>
                                          _buildUserRow(user, isDark)),
                                    ],
                                  ),
                                ),
                              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.grey[600],
      ),
    );
  }

  Widget _buildUserRow(UserModel user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // USERNAME
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // DISPLAY NAME
          Expanded(
            flex: 2,
            child: Text(
              user.displayName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          // ROLE
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.role == 'Admin'
                    ? Colors.purple.withValues(alpha: 0.15)
                    : user.role == 'Staff'
                        ? Colors.blue.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: user.role == 'Admin'
                      ? Colors.purple
                      : user.role == 'Staff'
                          ? Colors.blue
                          : isDark
                              ? Colors.white70
                              : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // STATUS
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: user.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // ACTIONS
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // View Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.visibility,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () => _showUserDetails(user),
                    tooltip: 'View User Details',
                  ),
                ),
                // More Menu Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final Offset offset =
                          renderBox.localToGlobal(Offset.zero);

                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx + 100,
                          offset.dy + 100,
                          offset.dx + 100,
                          offset.dy + 100,
                        ),
                        items: [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text('Edit User'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle_status',
                            child: Row(
                              children: [
                                Icon(
                                  user.isActive
                                      ? Icons.block
                                      : Icons.check_circle,
                                  size: 20,
                                  color: user.isActive
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Text(user.isActive ? 'Deactivate' : 'Activate'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle_premium',
                            child: Row(
                              children: [
                                Icon(
                                  user.isPremium
                                      ? Icons.star_border
                                      : Icons.star,
                                  size: 20,
                                  color: user.isPremium
                                      ? Colors.orange
                                      : Colors.amber,
                                ),
                                const SizedBox(width: 12),
                                Text(user.isPremium
                                    ? 'Remove Premium'
                                    : 'Make Premium'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete User',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).then((value) {
                        if (value != null) {
                          switch (value) {
                            case 'edit':
                              _showEditUserDialog(user);
                              break;
                            case 'toggle_status':
                              _toggleUserStatus(user);
                              break;
                            case 'toggle_premium':
                              _toggleUserPremium(user);
                              break;
                            case 'delete':
                              _deleteUser(user);
                              break;
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
