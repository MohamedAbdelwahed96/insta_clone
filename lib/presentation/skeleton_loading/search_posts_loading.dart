import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonSearchPosts extends StatelessWidget {
  const SkeletonSearchPosts({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;
    
    return Shimmer.fromColors(
      baseColor: placeholderColor,
      highlightColor: placeholderColor.withOpacity(0.5),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height*0.23,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
