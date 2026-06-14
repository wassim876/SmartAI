import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
                    'Transactions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View and manage all payment transactions',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _summaryCard(Icons.attach_money, Colors.green, 'Total Revenue', '\$24,780'),
                  _summaryCard(Icons.check_circle_outline, Colors.blue, 'Successful', '1,204'),
                  _summaryCard(Icons.pending_outlined, Colors.orange, 'Pending', '38'),
                  _summaryCard(Icons.cancel_outlined, Colors.red, 'Failed/Refunded', '17'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Transactions Table
          Container(
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by user, transaction ID, or amount...',
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

                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('TRANSACTION ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 3, child: Text('USER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                      Expanded(flex: 1, child: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                    ],
                  ),
                ),
                const Divider(height: 1),

                _buildTxRow('#TXN-10234', 'Sarah Johnson', '\$49.00', 'Jun 15, 2024', 'Success'),
                _buildTxRow('#TXN-10233', 'Michael Brown', '\$19.00', 'Jun 15, 2024', 'Success'),
                _buildTxRow('#TXN-10232', 'Emily Davis', '\$99.00', 'Jun 14, 2024', 'Pending'),
                _buildTxRow('#TXN-10231', 'David Wilson', '\$49.00', 'Jun 14, 2024', 'Success'),
                _buildTxRow('#TXN-10230', 'Jessica Miller', '\$19.00', 'Jun 13, 2024', 'Failed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(IconData icon, Color color, String title, String value) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxRow(String id, String user, String amount, String date, String status) {
    Color statusColor;
    switch (status) {
      case 'Success':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(user, style: TextStyle(color: Colors.grey[600]))),
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(date, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.receipt_long_outlined, size: 18, color: Colors.grey),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
