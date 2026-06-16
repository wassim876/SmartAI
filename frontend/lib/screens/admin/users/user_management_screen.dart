import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart'; // Assuming UserModel is defined here

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    _errorMessage = null;
    try {
      final authProvider = context.read<AuthProvider>();
      final fetchedUsers = await authProvider.fetchUsers();
      setState(() {
        _users = fetchedUsers;
        _filteredUsers = fetchedUsers;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load users: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final searchLower = query.toLowerCase();
        return user.username.toLowerCase().contains(searchLower) ||
            user.email.toLowerCase().contains(searchLower) ||
            '${user.firstName} ${user.lastName}'
                .toLowerCase()
                .contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                        fontSize: 14),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add user logic here
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
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
                          color: isDark ? Colors.white54 : Colors.grey),
                    ),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.grey[200]),

                // Scrollable Table Content
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    : _errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _errorMessage!,
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
                                                child: _tableHeader(
                                                    'USER', isDark)),
                                            Expanded(
                                                flex: 3,
                                                child: _tableHeader(
                                                    'EMAIL', isDark)),
                                            Expanded(
                                                flex: 2,
                                                child: _tableHeader(
                                                    'JOINED DATE', isDark)),
                                            Expanded(
                                                flex: 1,
                                                child: _tableHeader(
                                                    'STATUS', isDark)),
                                            Expanded(
                                                flex: 1,
                                                child: _tableHeader(
                                                    'ACTIONS', isDark)),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                          height: 1,
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.grey[200]),
                                      ..._filteredUsers
                                          .map((user) =>
                                              _buildUserRow(user, isDark))
                                          .toList(),
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

  Widget _tableHeader(String text, bool isDark) {
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
    final String displayName =
        '${user.firstName} ${user.lastName}'.trim().isEmpty
            ? user.username
            : '${user.firstName} ${user.lastName}';
    final String joinDate = user.dateJoined != null
        ? '${user.dateJoined!.day}/${user.dateJoined!.month}/${user.dateJoined!.year}'
        : 'N/A';
    final bool isActive = user.isActive;
    final String statusText = isActive ? 'Active' : 'Inactive';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(displayName,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87))),
          Expanded(
              flex: 3,
              child: Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600]),
              )),
          Expanded(
              flex: 2,
              child: Text(joinDate,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                      icon: Icon(Icons.visibility,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.grey),
                      onPressed: () {
                        // View user details
                        print('View user: ${user.username}');
                      }),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                      icon: Icon(Icons.more_vert,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.grey),
                      onPressed: () {
                        // More options (edit, delete)
                        print('More options for user: ${user.username}');
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
