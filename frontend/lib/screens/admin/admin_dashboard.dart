import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/user_growth_chart.dart';
import '../../widgets/admin/ai_services_chart.dart';
import '../../widgets/admin/recent_activity_list.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accent2 = Color(0xFF8B7CFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final bool isMobile = w < 640;
          final bool isTablet = w >= 640 && w < 1020;
          final bool isDesktop = w >= 1020;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 16 : 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                SizedBox(height: isMobile ? 20 : 28),
                _buildStatsSection(context,
                    isMobile: isMobile, isTablet: isTablet),
                SizedBox(height: isMobile ? 20 : 28),
                _buildChartsSection(context,
                    isDesktop: isDesktop, isTablet: isTablet),
                SizedBox(height: isMobile ? 20 : 28),
                _buildSystemOverview(context, isMobile: isMobile),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isMobile ? 44 : 52,
          height: isMobile ? 44 : 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_accent, _accent2],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _accent.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.dashboard_rounded,
              color: Colors.white, size: 22),
        ),
        SizedBox(width: isMobile ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 21 : 26,
                  fontWeight: FontWeight.w700,
                  color: D.t1(context),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isMobile
                          ? 'All systems operational'
                          : 'Welcome back, Admin — all systems operational',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: D.t2(context), fontSize: isMobile ? 12.5 : 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildNotificationBadge(context),
      ],
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/admin/notifications'),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: D.card(context),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: D.bd(context)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none_rounded,
                  color: D.t2(context), size: 21),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: D.card(context), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context,
      {required bool isMobile, required bool isTablet}) {
    final stats = const [
      StatCard(
          icon: Icons.people_rounded,
          iconColor: Color(0xFF3B82F6),
          title: 'Total Users',
          value: '12,450',
          growth: '12.5%',
          growthType: 'vs last month'),
      StatCard(
          icon: Icons.chat_bubble_rounded,
          iconColor: Color(0xFF10B981),
          title: 'Conversations',
          value: '45,780',
          growth: '18.2%',
          growthType: 'vs last month'),
      StatCard(
          icon: Icons.attach_money_rounded,
          iconColor: Color(0xFFF59E0B),
          title: 'Revenue',
          value: '\$24,780',
          growth: '15.3%',
          growthType: 'vs last month'),
      StatCard(
          icon: Icons.trending_up_rounded,
          iconColor: Color(0xFF6366F1),
          title: 'AI Requests',
          value: '98,320',
          growth: '20.1%',
          growthType: 'vs last month'),
      StatCard(
          icon: Icons.pie_chart_rounded,
          iconColor: Color(0xFF8B5CF6),
          title: 'Success Rate',
          value: '99.2%',
          growth: '2.1%',
          growthType: 'vs last month'),
    ];

    if (isMobile) {
      return SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SizedBox(width: 165, child: stats[i]),
        ),
      );
    }

    final crossAxisCount = isTablet ? 3 : 5;
    final childAspectRatio = isTablet ? 1.45 : 1.35;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: stats,
    );
  }

  Widget _buildChartsSection(BuildContext context,
      {required bool isDesktop, required bool isTablet}) {
    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 2,
                child:
                    _buildPanel(context, const UserGrowthChart(), height: 360)),
            const SizedBox(width: 14),
            Expanded(
                flex: 1,
                child:
                    _buildPanel(context, const AIServicesChart(), height: 360)),
            const SizedBox(width: 14),
            Expanded(
                flex: 1,
                child: _buildPanel(context, const RecentActivityList(),
                    height: 360)),
          ],
        ),
      );
    } else if (isTablet) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: _buildPanel(context, const UserGrowthChart(),
                        height: 320)),
                const SizedBox(width: 14),
                Expanded(
                    child: _buildPanel(context, const AIServicesChart(),
                        height: 320)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildPanel(context, const RecentActivityList(), height: 380),
        ],
      );
    } else {
      return Column(
        children: [
          _buildPanel(context, const UserGrowthChart(), height: 280),
          const SizedBox(height: 14),
          _buildPanel(context, const AIServicesChart(), height: 300),
          const SizedBox(height: 14),
          _buildPanel(context, const RecentActivityList(), height: 360),
        ],
      );
    }
  }

  Widget _buildPanel(BuildContext context, Widget child,
      {required double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: D.bd(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: D.isDark(context)
                ? Colors.black.withValues(alpha: 0.18)
                : const Color(0xFF1A1464).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSystemOverview(BuildContext context, {required bool isMobile}) {
    final items = [
      (
        icon: Icons.cloud_done_rounded,
        title: 'Server Status',
        subtitle: 'All systems operational',
        status: 'Healthy',
        color: const Color(0xFF22C55E)
      ),
      (
        icon: Icons.storage_rounded,
        title: 'Database',
        subtitle: 'MongoDB Atlas',
        status: 'Healthy',
        color: const Color(0xFF22C55E)
      ),
      (
        icon: Icons.speed_rounded,
        title: 'API Response',
        subtitle: 'Average response time',
        status: '120ms',
        color: const Color(0xFF3B82F6)
      ),
      (
        icon: Icons.folder_shared_rounded,
        title: 'Storage Used',
        subtitle: '256 GB / 1 TB',
        status: '25%',
        color: const Color(0xFFF59E0B)
      ),
    ];

    return _buildPanel(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('System Overview',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: D.t1(context))),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildSystemItem(context, items[i]),
                  if (i != items.length - 1) const SizedBox(height: 10),
                ],
              ],
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.4,
              children: [
                for (final item in items) _buildSystemItem(context, item)
              ],
            ),
        ],
      ),
      height: null,
    );
  }

  Widget _buildSystemItem(
    BuildContext context,
    ({
      IconData icon,
      String title,
      String subtitle,
      String status,
      Color color
    }) item,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: D.hover(context),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: D.t1(context))),
                Text(item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        color: D.t2(context), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text(item.status,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    color: item.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
