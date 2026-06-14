import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, Admin! Here\'s what\'s happening with your platform.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'May 15, 2024 - Jun 15, 2024',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                size: 16, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Stats Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 5
                    : constraints.maxWidth > 700
                        ? 3
                        : 1;
                final double childAspectRatio =
                    constraints.maxWidth > 1100 ? 1.9 : 2.5;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: const [
                    StatCard(
                      icon: Icons.people,
                      iconColor: Colors.blue,
                      title: 'Total Users',
                      value: '12,450',
                      growth: '+12.5%',
                      growthType: 'vs last month',
                    ),
                    StatCard(
                      icon: Icons.chat_bubble,
                      iconColor: Colors.green,
                      title: 'Total Conversations',
                      value: '45,780',
                      growth: '+18.2%',
                      growthType: 'vs last month',
                    ),
                    StatCard(
                      icon: Icons.attach_money,
                      iconColor: Colors.amber,
                      title: 'Total Revenue',
                      value: '\$24,780',
                      growth: '+15.3%',
                      growthType: 'vs last month',
                    ),
                    StatCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.indigo,
                      title: 'AI Requests',
                      value: '98,320',
                      growth: '+20.1%',
                      growthType: 'vs last month',
                    ),
                    StatCard(
                      icon: Icons.pie_chart,
                      iconColor: Colors.purple,
                      title: 'Success Rate',
                      value: '99.2%',
                      growth: '+2.1%',
                      growthType: 'vs last month',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Charts Section
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 1100) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildChartBox(UserGrowthChart(), height: 350)),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 1,
                        child: _buildChartBox(AIServicesChart(), height: 350)),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 1,
                        child:
                            _buildChartBox(RecentActivityList(), height: 350)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildChartBox(UserGrowthChart(), height: 300),
                    const SizedBox(height: 16),
                    _buildChartBox(AIServicesChart(), height: 300),
                    const SizedBox(height: 16),
                    _buildChartBox(RecentActivityList(), height: 400),
                  ],
                );
              }
            }),

            const SizedBox(height: 32),

            // System Overview
            _buildChartBox(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSystemItem(
                    icon: Icons.cloud_done,
                    title: 'Server Status',
                    subtitle: 'All systems operational',
                    status: 'Healthy',
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSystemItem(
                    icon: Icons.storage,
                    title: 'Database',
                    subtitle: 'MongoDB Atlas',
                    status: 'Healthy',
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSystemItem(
                    icon: Icons.speed,
                    title: 'API Response Time',
                    subtitle: 'Average response time',
                    status: '120ms',
                    statusColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildSystemItem(
                    icon: Icons.folder_shared,
                    title: 'Storage Used',
                    subtitle: '256 GB / 1 TB',
                    status: '25%',
                    statusColor: Colors.orange,
                  ),
                ],
              ),
              height: 280,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartBox(Widget child, {required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }

  Widget _buildSystemItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
