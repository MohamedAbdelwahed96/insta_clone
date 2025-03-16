class StoryModel {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final bool isVideo;
  final DateTime createdAt;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    required this.isVideo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      storyId: map['storyId'] ?? '',
      userId: map['userId'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      isVideo: map['isVideo'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? 0),
    );
  }
}
