import 'package:flutter/material.dart';
import '../../widgets/admin/sidebar.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
          ),

          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: SafeArea(child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
