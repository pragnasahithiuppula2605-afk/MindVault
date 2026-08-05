import 'package:flutter/material.dart';

class FavoritesHeader extends StatelessWidget {
  final int totalItems;

  const FavoritesHeader({
    super.key,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your Starred Items',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),
          _FavoriteCountCard(
  totalItems: totalItems,
),
        ],
      ),
    );
  }
}

class _FavoriteCountCard extends StatelessWidget {
  const _FavoriteCountCard({
    required this.totalItems,
  });

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$totalItems Starred Items',
        style: const TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}