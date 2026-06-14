import 'package:flutter/material.dart';

class AIServicesScreen extends StatelessWidget {
  const AIServicesScreen({super.key});

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
                    'AI Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and monitor all AI-powered services',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service'),
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

          // Service Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildServiceCard(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.blue,
                    title: 'Chat Assistant',
                    description: 'Conversational AI assistant for general queries',
                    requests: '35,070',
                    usage: 35.6,
                    status: 'Active',
                  ),
                  _buildServiceCard(
                    icon: Icons.image_outlined,
                    color: Colors.green,
                    title: 'Image Analysis',
                    description: 'Detect objects, text, and content in images',
                    requests: '22,418',
                    usage: 22.8,
                    status: 'Active',
                  ),
                  _buildServiceCard(
                    icon: Icons.mic_none_outlined,
                    color: Colors.orange,
                    title: 'Speech to Text',
                    description: 'Transcribe audio recordings into text',
                    requests: '14,996',
                    usage: 15.3,
                    status: 'Active',
                  ),
                  _buildServiceCard(
                    icon: Icons.record_voice_over_outlined,
                    color: Colors.purple,
                    title: 'Text to Speech',
                    description: 'Convert written text into natural speech',
                    requests: '10,520',
                    usage: 10.7,
                    status: 'Active',
                  ),
                  _buildServiceCard(
                    icon: Icons.translate_outlined,
                    color: Colors.teal,
                    title: 'Translation',
                    description: 'Translate text between multiple languages',
                    requests: '8,455',
                    usage: 8.6,
                    status: 'Active',
                  ),
                  _buildServiceCard(
                    icon: Icons.apps_outlined,
                    color: Colors.grey,
                    title: 'Others',
                    description: 'Miscellaneous AI utilities and tools',
                    requests: '5,861',
                    usage: 6.0,
                    status: 'Maintenance',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String requests,
    required double usage,
    required String status,
  }) {
    final bool isActive = status == 'Active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$requests requests',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$usage% of total',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Configure'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
