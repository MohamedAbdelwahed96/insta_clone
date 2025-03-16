import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonPostWidget extends StatelessWidget {
  const SkeletonPostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the theme's inversePrimary color for placeholders.
    final theme = Theme.of(context).colorScheme.inversePrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        // Use the theme for the shimmer effect.
        baseColor: theme,
        // Create a slightly lighter version of the theme color.
        highlightColor: theme.withOpacity(0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Avatar, Username, More Icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: theme,
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    color: theme,
                  ),
                ],
              ),
            ),
            // Main Image Area
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: theme,
            ),
            // Action Icons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(width: 30, height: 30, color: theme),
                  const SizedBox(width: 12),
                  Container(width: 30, height: 30, color: theme),
                  const SizedBox(width: 12),
                  Container(width: 30, height: 30, color: theme),
                  const Spacer(),
                  Container(width: 30, height: 30, color: theme),
                ],
              ),
            ),
            // Likes and Caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 12, color: theme),
                  const SizedBox(height: 4),
                  Container(width: 200, height: 12, color: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
