import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  static const _transactions = [
    ('#TXN-10234', 'Sarah Johnson', '\$49.00', 'Jun 15, 2024', 'Success'),
    ('#TXN-10233', 'Michael Brown', '\$19.00', 'Jun 15, 2024', 'Success'),
    ('#TXN-10232', 'Emily Davis', '\$99.00', 'Jun 14, 2024', 'Pending'),
    ('#TXN-10231', 'David Wilson', '\$49.00', 'Jun 14, 2024', 'Success'),
    ('#TXN-10230', 'Jessica Miller', '\$19.00', 'Jun 13, 2024', 'Failed'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSummaryCards(),
          const SizedBox(height: 20),
          _buildTable(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 3),
              Text(
                'View and manage all payment transactions',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ExportButton(),
      ],
    );
  }

  // ── Summary Cards ────────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _SummaryCard(
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF10B981),
                  label: 'Total Revenue',
                  value: '\$24,780')),
          const SizedBox(width: 12),
          Expanded(
              child: _SummaryCard(
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF3B82F6),
                  label: 'Successful',
                  value: '1,204')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _SummaryCard(
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFF59E0B),
                  label: 'Pending',
                  value: '38')),
          const SizedBox(width: 12),
          Expanded(
              child: _SummaryCard(
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFEF4444),
                  label: 'Failed/Refunded',
                  value: '17')),
        ]),
      ],
    );
  }

  // ── Table ────────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search transactions…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(children: [
              Expanded(flex: 28, child: _colHead('TX ID')),
              Expanded(flex: 30, child: _colHead('USER')),
              Expanded(flex: 18, child: _colHead('AMT')),
              Expanded(flex: 24, child: _colHead('STATUS')),
            ]),
          ),
          Divider(height: 1, color: Colors.grey[100]),

          // Rows
          ..._transactions.map((t) => _TxRow(
              id: t.$1, user: t.$2, amount: t.$3, date: t.$4, status: t.$5)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _colHead(String label) => Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.5),
      );
}

// ── Export Button ─────────────────────────────────────────────────────────────
class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.download_rounded, size: 15),
      label: const Text('Export',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Row ───────────────────────────────────────────────────────────
class _TxRow extends StatelessWidget {
  final String id, user, amount, date, status;
  const _TxRow(
      {required this.id,
      required this.user,
      required this.amount,
      required this.date,
      required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final Color statusBg;
    switch (status) {
      case 'Success':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFFECFDF5);
        break;
      case 'Pending':
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFFFBEB);
        break;
      default:
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEF2F2);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TX ID + date stacked
              Expanded(
                flex: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              // User
              Expanded(
                flex: 30,
                child: Text(user,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis),
              ),
              // Amount
              Expanded(
                flex: 18,
                child: Text(amount,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ),
              // Status badge — dot + label, no pill padding issues
              Expanded(
                flex: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(status,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[100]),
      ],
    );
  }
}
