import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No reviews yet',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('User reviews and ratings will appear here',
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          );
        }

        final avgRating = docs.fold<double>(0, (acc, doc) {
          return acc + (doc['rating'] as num? ?? 0).toDouble();
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
                        Text('Reviews & Ratings',
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900])),
                        const SizedBox(height: 4),
                        Text('${docs.length} reviews · ${avgRating.toStringAsFixed(1)} average rating',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsRow(docs, avgRating),
              const SizedBox(height: 24),
              ...docs.map((doc) => _buildReviewCard(doc)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(List<QueryDocumentSnapshot> docs, double avgRating) {
    final counts = List.filled(5, 0);
    for (final doc in docs) {
      final rating = (doc['rating'] as num? ?? 0).toInt();
      if (rating >= 1 && rating <= 5) counts[rating - 1]++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avgRating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                      fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey[900])),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) => Icon(
                    i < avgRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFBBF24),
                    size: 20)),
              ),
              const SizedBox(height: 4),
              Text('${docs.length} reviews',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = counts[star - 1];
                final pct = docs.isNotEmpty ? count / docs.length : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: Colors.grey[100],
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFBBF24)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$count',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rating = (data['rating'] as num? ?? 0).toInt();
    final review = data['review'] ?? '';
    final userName = data['userName'] ?? 'Anonymous';
    final userEmail = data['userEmail'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final date = createdAt?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1)),
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
                          Text(userName,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[900])),
                          if (userEmail.isNotEmpty)
                            Text(userEmail,
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 16)),
                    ),
                  ],
                ),
                if (review.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(review,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[700], height: 1.5)),
                ],
                if (date != null) ...[
                  const SizedBox(height: 8),
                  Text('${date.day}/${date.month}/${date.year}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
