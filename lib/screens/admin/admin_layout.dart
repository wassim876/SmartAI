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
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.grey[900]),
              title: Text(
                'SmartAI Admin',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_none_rounded),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/admin/notifications'),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      drawer: !isDesktop
          ? Sidebar(
              isExpanded: true,
              onToggle: () {},
            )
          : null,
      body: Row(
        children: [
          // Sidebar for desktop view
          if (isDesktop)
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
