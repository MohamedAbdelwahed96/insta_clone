import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.inversePrimary;

    return Shimmer.fromColors(
      baseColor: placeholderColor,
      highlightColor: placeholderColor.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: placeholderColor,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatPlaceholder(placeholderColor),
                        _buildStatPlaceholder(placeholderColor),
                        _buildStatPlaceholder(placeholderColor),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(width: 150, height: 16, color: placeholderColor),
              SizedBox(height: 6),
              Container(width: 100, height: 14, color: placeholderColor),
              SizedBox(height: 6),
              Container(width: double.infinity, height: 14, color: placeholderColor),
              SizedBox(height: 4),
              Container(width: double.infinity, height: 14, color: placeholderColor),
              SizedBox(height: 6),
              Container(width: 120, height: 14, color: placeholderColor),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPlaceholder(Color color) {
    return Column(
      children: [
        Container(width: 40, height: 16, color: color),
        SizedBox(height: 4),
        Container(width: 30, height: 12, color: color),
      ],
    );
  }
}
