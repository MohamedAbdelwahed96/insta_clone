import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonSearchUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;

    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: placeholderColor,
        highlightColor: placeholderColor.withOpacity(0.5),
        child: CircleAvatar(
          backgroundColor: placeholderColor,
          radius: 20,
        ),
      ),
      title: Shimmer.fromColors(
        baseColor: placeholderColor,
        highlightColor: placeholderColor.withOpacity(0.5),
        child: Container(
          height: 12,
          width: 100,
          color: placeholderColor,
        ),
      ),
    );
  }
}
