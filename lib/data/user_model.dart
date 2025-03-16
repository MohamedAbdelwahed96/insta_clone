class UserModel {
  final String uid;
  final String username;
  final String fullName;
  final String pfpUrl;
  final String email;
  final List<String> followers;
  final List<String> following;
  final List<String> posts;
  final List<String> stories;
  final List<String> savedPosts;
  final String bio;
  final String pNumber;
  final String gender;
  final String website;
  final DateTime time;
  final String fcmToken;

  UserModel({
    this.uid = "",
    required this.username,
    required this.fullName,
    this.pfpUrl = "",
    required this.email,
    this.followers = const [],
    this.following = const [],
    this.posts = const [],
    this.stories = const [],
    this.savedPosts = const [],
    this.bio = "",
    this.pNumber = "",
    this.gender = "",
    this.website = "",
    required this.time,
    this.fcmToken = "",
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      pfpUrl: map['pfpUrl'] ?? '',
      email: map['email'] ?? '',
      followers: map['followers'] != null ? List<String>.from(map['followers']) : [],
      following: map['following'] != null ? List<String>.from(map['following']) : [],
      posts: map['posts'] != null ? List<String>.from(map['posts']) : [],
      stories: map['stories'] != null ? List<String>.from(map['stories']) : [],
      savedPosts: map['savedPosts'] != null ? List<String>.from(map['savedPosts']) : [],
      bio: map['bio'] ?? '',
      pNumber: map['pNumber'] ?? '',
      gender: map['gender'] ?? '',
      website: map['website'] ?? '',
      time: map['time'] != null ? DateTime.parse(map['time']) : DateTime.now(),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'fullName': fullName,
      'pfpUrl': pfpUrl,
      'email': email,
      'followers': followers,
      'following': following,
      'posts': posts,
      'stories': stories,
      'savedPosts': savedPosts,
      'bio': bio,
      'pNumber': pNumber,
      'gender': gender,
      'website': website,
      'time': time.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }
}