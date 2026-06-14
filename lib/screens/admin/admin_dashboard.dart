import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/user_growth_chart.dart';
import '../../widgets/admin/ai_services_chart.dart';
import '../../widgets/admin/recent_activity_list.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'Welcome back, John! Here\'s what\'s happening with your platform.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      'May 15, 2024 - Jun 15, 2024',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stats Cards
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
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
            ],
          ),

          const SizedBox(height: 32),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Growth Chart
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: UserGrowthChart(),
                ),
              ),
              SizedBox(width: 16),

              // AI Services Usage
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AIServicesChart(),
                ),
              ),

              SizedBox(width: 16),

              // Recent Activity
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RecentActivityList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // System Overview
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildSystemItem(
                  icon: Icons.cloud_done,
                  title: 'Server Status',
                  subtitle: 'All systems operational',
                  status: 'Healthy',
                  statusColor: Colors.green,
                ),
                SizedBox(height: 12),
                _buildSystemItem(
                  icon: Icons.storage,
                  title: 'Database',
                  subtitle: 'MongoDB Atlas',
                  status: 'Healthy',
                  statusColor: Colors.green,
                ),
                SizedBox(height: 12),
                _buildSystemItem(
                  icon: Icons.speed,
                  title: 'API Response Time',
                  subtitle: 'Average response time',
                  status: '120ms',
                  statusColor: Colors.blue,
                ),
                SizedBox(height: 12),
                _buildSystemItem(
                  icon: Icons.folder_shared,
                  title: 'Storage Used',
                  subtitle: '256 GB / 1 TB',
                  status: '25%',
                  statusColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
