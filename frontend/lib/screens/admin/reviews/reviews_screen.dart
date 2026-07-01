import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/supabase_config.dart';
import '../../../theme/dark_mode_helpers.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('reviews')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 56, color: D.t3(context)),
                const SizedBox(height: 16),
                Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: D.t1(context))),
                const SizedBox(height: 8),
                Text('User reviews and ratings will appear here', style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
              ],
            ),
          );
        }

        final avgRating = docs.fold<double>(0, (acc, data) {
          return acc + (data['rating'] as num? ?? 0).toDouble();
        }) / docs.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reviews & Ratings', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('${docs.length} reviews · ${avgRating.toStringAsFixed(1)} average rating', style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context)), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsRow(context, docs, avgRating),
              const SizedBox(height: 24),
              ...docs.map((data) => _buildReviewCard(context, data)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, List<Map<String, dynamic>> docs, double avgRating) {
    final counts = List.filled(5, 0);
    for (final data in docs) {
      final rating = (data['rating'] as num? ?? 0).toInt();
      if (rating >= 1 && rating <= 5) counts[rating - 1]++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 400;
          if (isNarrow) {
            return Column(
              children: [
                Column(
                  children: [
                    Text(avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -1)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) => Icon(
                          i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24), size: 20)),
                    ),
                    const SizedBox(height: 4),
                    Text('${docs.length} reviews', style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRatingBars(context, docs, counts),
              ],
            );
          }
          return Row(
            children: [
              Column(
                children: [
                  Text(avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: D.t1(context), letterSpacing: -1)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) => Icon(
                        i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFFBBF24), size: 20)),
                  ),
                  const SizedBox(height: 4),
                  Text('${docs.length} reviews', style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context))),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(child: _buildRatingBars(context, docs, counts)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBars(BuildContext context, List<Map<String, dynamic>> docs, List<int> counts) {
    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = counts[star - 1];
        final pct = docs.isNotEmpty ? count / docs.length : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$star', style: GoogleFonts.poppins(fontSize: 12, color: D.t2(context))),
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: D.hover(context),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFBBF24)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$count', style: GoogleFonts.poppins(fontSize: 12, color: D.t2(context))),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> data) {
    final rating = (data['rating'] as num? ?? 0).toInt();
    final review = data['comment']?.toString() ?? '';
    final userName = data['user_id']?.toString() ?? 'User';
    final userEmail = '';
    final createdAt = DateTime.tryParse(data['created_at']?.toString() ?? '');
    final date = createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: D.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: D.bd(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [const Color(0xFF6C63FF).withValues(alpha: 0.2), const Color(0xFF6C63FF).withValues(alpha: 0.08)]),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: D.card(context),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF6C63FF)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: D.t1(context))),
                          if (userEmail.isNotEmpty)
                            Text(userEmail, style: GoogleFonts.poppins(fontSize: 11, color: D.t3(context))),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) => Icon(
                            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFFBBF24), size: 16)),
                      ),
                    ),
                  ],
                ),
                if (review.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(review, style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context), height: 1.5)),
                ],
                if (date != null) ...[
                  const SizedBox(height: 8),
                  Text('${date.day}/${date.month}/${date.year}', style: GoogleFonts.poppins(fontSize: 11, color: D.t3(context))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
