import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonReel extends StatelessWidget {
  const SkeletonReel({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildShimmerContainer(context, height: 20, width: 150),
              ),
              Icon(Icons.close, color: Colors.white, size: 34),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: placeholderColor.withOpacity(0.5),
                highlightColor: placeholderColor.withOpacity(0.3),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 8),
              _buildShimmerContainer(context, height: 16, width: 120),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildShimmerContainer(context, height: 16, width: 180),
          ),
          _buildShimmerContainer(context, height: 16, width: 180),
          // Icons Row

        ],
      ),
    );
  }

  Widget _buildShimmerContainer(BuildContext context,
      {double height = 16, double width = double.infinity}) {
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;

    return Shimmer.fromColors(
      baseColor: placeholderColor.withOpacity(0.5),
      highlightColor: placeholderColor.withOpacity(0.3),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: placeholderColor,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
