class PostModel {
  final String postId;
  final String uid;
  final String username;
  final String userProfileImage;
  final List<String> mediaUrls;
  final String caption;
  final DateTime createdAt;
  final List<String> likes;
  final List<String> comments;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.userProfileImage,
    required this.mediaUrls,
    required this.caption,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'],
      uid: map['uid'],
      username: map['username'],
      userProfileImage: map['userProfileImage'],
      mediaUrls: List<String>.from(map['mediaUrls']),
      caption: map['caption'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: List<String>.from(map['likes']),
      comments: List<String>.from(map['comments']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'username': username,
      'userProfileImage': userProfileImage,
      'mediaUrls': mediaUrls,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}