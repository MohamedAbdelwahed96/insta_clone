import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonProfilePost extends StatelessWidget {
  const SkeletonProfilePost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use your theme's inversePrimary color for placeholders.
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;

    return Shimmer.fromColors(
      baseColor: placeholderColor,
      highlightColor: placeholderColor.withOpacity(0.7),
      child: Stack(
        children: [
          // Main image placeholder (fills available space).
          Container(
            width: double.infinity,
            height: double.infinity,
            color: placeholderColor,
          ),
        ],
      ),
    );
  }
}
