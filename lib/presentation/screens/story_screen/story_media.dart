import 'package:flutter/material.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class StoryMedia extends StatelessWidget {
  final StoryModel story;
  final String mediaUrl;
  final VoidCallback onNext;
  final Function(Duration) onProgressUpdate;
  final Function(VideoPlayerController) onControllerInitialized;

  const StoryMedia({
    super.key,
    required this.story,
    required this.mediaUrl,
    required this.onNext,
    required this.onProgressUpdate,
    required this.onControllerInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return story.isVideo
        ? VideoPlayerWidget(
      videoUrl: mediaUrl,
      autoPlay: true,
      onPlay: () {}, // Start progress tracking in parent widget
      onPause: () {}, // Pause tracking
      onDuration: onProgressUpdate,
      onControllerInitialized: onControllerInitialized,
    )
        : Image.network(
      mediaUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress != null) {
          return const Center(child: CircularProgressIndicator());
        }
        return child;
      },
    );
  }
}
