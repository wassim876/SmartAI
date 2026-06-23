import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/admin/sidebar.dart';
import '../../theme/dark_mode_helpers.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: D.bg(context),
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: D.appBar(context),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              centerTitle: false,
              leading: IconButton(
                icon: Icon(Icons.menu_rounded, color: D.t1(context), size: 22),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/images/smartai.png', width: 28, height: 28, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Admin Panel', style: GoogleFonts.poppins(color: D.t1(context), fontSize: 17, fontWeight: FontWeight.w700)),
              ]),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: D.hover(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: D.t2(context), size: 20),
                    onPressed: () => Navigator.pushNamed(context, '/admin/notifications'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: Colors.transparent,
              width: 260,
              child: Sidebar(isExpanded: true, onToggle: () => Navigator.pop(context)),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            Sidebar(
              isExpanded: _isSidebarExpanded,
              onToggle: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            ),
          Expanded(
            child: Container(
              color: D.bg(context),
              child: SafeArea(child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
