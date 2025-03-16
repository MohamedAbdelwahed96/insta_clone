class ReelModel {
  final String reelId;
  final String userId;
  final String videoUrl;
  final String caption;
  final List<String> likes;
  final List<String> comments;
  final List<String> views;
  final DateTime createdAt;

  ReelModel({
    required this.reelId,
    required this.userId,
    required this.videoUrl,
    required this.caption,
    this.likes = const [],
    this.comments = const [],
    this.views = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'userId': userId,
      'videoUrl': videoUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    return ReelModel(
      reelId: map['reelId'] ?? '',
      userId: map['userId'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      caption: map['caption'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
      views: List<String>.from(map['views'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
