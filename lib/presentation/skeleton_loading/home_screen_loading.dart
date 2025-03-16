import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonHomeScreen extends StatelessWidget {
  const SkeletonHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme.inversePrimary;

    return Scaffold(
      body: Column(
        children: [
          // Top App Bar Skeleton
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 14, top: 52),
            child: Shimmer.fromColors(
              baseColor: theme,
              highlightColor: theme.withOpacity(0.7),
              child: Row(
                children: [
                  // Logo placeholder
                  Container(
                    width: MediaQuery.of(context).size.width * 0.26,
                    height: 30,
                    color: theme,
                  ),
                  const SizedBox(width: 8),
                  // Dropdown arrow placeholder
                  Container(
                    width: 20,
                    height: 20,
                    color: theme,
                  ),
                  const Spacer(),
                  // Fav icon placeholder
                  Container(width: 24, height: 24, color: theme),
                  const SizedBox(width: 24),
                  // Chat icon placeholder
                  Container(width: 24, height: 24, color: theme),
                  const SizedBox(width: 24),
                  // New story icon placeholder
                  Container(width: 24, height: 24, color: theme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List of Post Skeletons
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 3, // You can adjust the count as needed.
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Shimmer.fromColors(
                    baseColor: theme,
                    highlightColor: theme.withOpacity(0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Top Row Skeleton (Avatar, Username, More Icon)
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
                        // Main Post Image Skeleton
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          color: theme,
                        ),
                        // Action Icons Row Skeleton
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
                        // Likes and Caption Skeleton
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
