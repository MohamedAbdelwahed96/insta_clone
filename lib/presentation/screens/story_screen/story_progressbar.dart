import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final List<double> progressList;
  const StoryProgressBar({super.key, required this.progressList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: progressList.map((progress) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
