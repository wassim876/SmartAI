import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dark_mode_helpers.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/user_growth_chart.dart';
import '../../widgets/admin/ai_services_chart.dart';
import '../../widgets/admin/recent_activity_list.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 700;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dashboard', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text('Welcome back, Admin! Here\'s what\'s happening.', style: GoogleFonts.poppins(color: D.t2(context), fontSize: 14)),
                        ],
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 16),
                      _buildNotificationBadge(context),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100 ? 5 : constraints.maxWidth > 700 ? 3 : 2;
                final double childAspectRatio = constraints.maxWidth > 1100 ? 1.6 : constraints.maxWidth > 700 ? 1.4 : 1.6;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                  children: const [
                    StatCard(icon: Icons.people_rounded, iconColor: Color(0xFF3B82F6), title: 'Total Users', value: '12,450', growth: '+12.5%', growthType: 'vs last month'),
                    StatCard(icon: Icons.chat_bubble_rounded, iconColor: Color(0xFF10B981), title: 'Conversations', value: '45,780', growth: '+18.2%', growthType: 'vs last month'),
                    StatCard(icon: Icons.attach_money_rounded, iconColor: Color(0xFFF59E0B), title: 'Revenue', value: '\$24,780', growth: '+15.3%', growthType: 'vs last month'),
                    StatCard(icon: Icons.trending_up_rounded, iconColor: Color(0xFF6366F1), title: 'AI Requests', value: '98,320', growth: '+20.1%', growthType: 'vs last month'),
                    StatCard(icon: Icons.pie_chart_rounded, iconColor: Color(0xFF8B5CF6), title: 'Success Rate', value: '99.2%', growth: '+2.1%', growthType: 'vs last month'),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 1100) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildChartBox(context, const UserGrowthChart(), height: 360)),
                    const SizedBox(width: 14),
                    Expanded(flex: 1, child: _buildChartBox(context, const AIServicesChart(), height: 360)),
                    const SizedBox(width: 14),
                    Expanded(flex: 1, child: _buildChartBox(context, const RecentActivityList(), height: 360)),
                  ],
                );
              } else if (constraints.maxWidth > 700) {
                return Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildChartBox(context, const UserGrowthChart(), height: 350)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildChartBox(context, const AIServicesChart(), height: 350)),
                  ]),
                  const SizedBox(height: 14),
                  _buildChartBox(context, const RecentActivityList(), height: 400),
                ]);
              } else {
                return Column(children: [
                  _buildChartBox(context, const UserGrowthChart(), height: 300),
                  const SizedBox(height: 14),
                  _buildChartBox(context, const AIServicesChart(), height: 320),
                  const SizedBox(height: 14),
                  _buildChartBox(context, const RecentActivityList(), height: 380),
                ]);
              }
            }),

            const SizedBox(height: 28),

            _buildChartBox(context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Overview', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: D.t1(context))),
                  const SizedBox(height: 16),
                  _buildSystemItem(context, icon: Icons.cloud_done_rounded, title: 'Server Status', subtitle: 'All systems operational', status: 'Healthy', statusColor: const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _buildSystemItem(context, icon: Icons.storage_rounded, title: 'Database', subtitle: 'MongoDB Atlas', status: 'Healthy', statusColor: const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _buildSystemItem(context, icon: Icons.speed_rounded, title: 'API Response', subtitle: 'Average response time', status: '120ms', statusColor: const Color(0xFF3B82F6)),
                  const SizedBox(height: 12),
                  _buildSystemItem(context, icon: Icons.folder_shared_rounded, title: 'Storage Used', subtitle: '256 GB / 1 TB', status: '25%', statusColor: const Color(0xFFF59E0B)),
                ],
              ),
              height: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/admin/notifications'),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: D.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: D.bd(context)),
          ),
          child: Stack(children: [
            Icon(Icons.notifications_none_rounded, color: D.t2(context), size: 22),
            Positioned(
              right: 2, top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: D.card(context), width: 1.5),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildChartBox(BuildContext context, Widget child, {required double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: D.bd(context), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSystemItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required String status, required Color statusColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: D.hover(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: D.t1(context))),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: D.t2(context), fontSize: 12)),
          ]),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(status, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}
