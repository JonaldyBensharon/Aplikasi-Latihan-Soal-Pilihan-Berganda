class UserProfile {
  const UserProfile({required this.id, required this.displayName, required this.normalizedName});
  final String id;
  final String displayName;
  final String normalizedName;
  Map<String, dynamic> toJson() => {'id': id, 'displayName': displayName, 'normalizedName': normalizedName};
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(id: json['id'] as String, displayName: json['displayName'] as String, normalizedName: json['normalizedName'] as String);
}