import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all registered users on the platform',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Scrollable Table Content
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000, // Explicit width fixes the 'Expanded' crash
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: _tableHeader('USER')),
                              Expanded(flex: 3, child: _tableHeader('EMAIL')),
                              Expanded(
                                  flex: 2, child: _tableHeader('JOINED DATE')),
                              Expanded(flex: 1, child: _tableHeader('STATUS')),
                              Expanded(flex: 1, child: _tableHeader('ACTIONS')),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        _buildUserRow(
                            'Sarah Johnson',
                            'sarah.johnson@email.com',
                            'Jun 15, 2024',
                            'Active'),
                        _buildUserRow(
                            'Michael Brown',
                            'michael.brown@email.com',
                            'Jun 15, 2024',
                            'Active'),
                        _buildUserRow('Emily Davis', 'emily.davis@email.com',
                            'Jun 14, 2024', 'Inactive'),
                        _buildUserRow('David Wilson', 'david.wilson@email.com',
                            'Jun 14, 2024', 'Active'),
                        _buildUserRow(
                            'Jessica Miller',
                            'jessica.miller@email.com',
                            'Jun 13, 2024',
                            'Active'),
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

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildUserRow(String name, String email, String date, String status) {
    bool isActive = status == 'Active';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 3,
              child: Text(
                email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              )),
          Expanded(
              flex: 2,
              child: Text(date, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
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
                      icon: const Icon(Icons.visibility,
                          size: 18, color: Colors.grey),
                      onPressed: () {}),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                      icon: const Icon(Icons.more_vert,
                          size: 18, color: Colors.grey),
                      onPressed: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
