import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final BoxFit fit;
  final bool tapToPlayPause;
  final bool autoPlay;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final Function(VideoPlayerController)? onControllerInitialized;
  final Function(Duration)? onDuration;

  const VideoPlayerWidget({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.fit = BoxFit.cover,
    this.tapToPlayPause = false,
    this.autoPlay = false,
    this.onPlay,
    this.onPause,
    this.onControllerInitialized,
    this.onDuration
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController video;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      video = VideoPlayerController.file(widget.videoFile!);
    } else if (widget.videoUrl != null) {
      video = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      throw ArgumentError("Either videoFile or videoUrl must be provided");
    }

    video.initialize().then((_) {
      if (widget.autoPlay) video.play();
      widget.onControllerInitialized?.call(video);
      widget.onDuration?.call(video.value.duration);
      setState(() {
        isInitialized = true;
      });
    });

    video.addListener(() {
      if (video.value.isPlaying) {
        widget.onPlay?.call();
      } else {
        widget.onPause?.call();
      }
    });
  }

  void play() {
    if (isInitialized) video.play();
  }

  void pause() {
    if (isInitialized) video.pause();
  }

  @override
  void dispose() {
    video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) return Center(child: CircularProgressIndicator());

    return VisibilityDetector(
      key: Key(widget.videoUrl ?? widget.videoFile?.path ?? "video"),
      onVisibilityChanged: (value) {
        if (value.visibleFraction == 0 && video.value.isPlaying) {
          video.pause();
        }
      },
      child: GestureDetector(
        onTap: widget.tapToPlayPause
            ? () {
          if (video.value.isPlaying) {
            video.pause();
          } else {
            video.play();
          }
          setState(() {});
        }
            : null,
        child: ClipRRect(
          child: AspectRatio(
            aspectRatio: 1,
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: video.value.size.width,
                height: video.value.size.height,
                child: VideoPlayer(video),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
