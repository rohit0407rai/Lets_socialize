class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.pushToken,
    required this.email,
  });
  late  String image;
  late  String name;
  late  String about;
  late String createdAt;
  late bool isOnline;
  late  String id;
  late  String lastActive;
  late  String pushToken;
  late  String email;
// this function is for getting data from the server and converting it into dart-json to dart-object
  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    name = json['name']  ??'';
    about = json['about'] ??'';
    createdAt = json['created_at'] ??'';
    isOnline = json['is_online'] ??'';
    id = json['id'] ??'';
    lastActive = json['last_active'] ??'';
    pushToken = json['push_token'] ??'';
    email = json['email'] ??'';
  }
 // this is used to add the data to server we pass the data from toJson
  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['name'] = name;
    _data['about'] = about;
    _data['created_at'] = createdAt;
    _data['is_online'] = isOnline;
    _data['id'] = id;
    _data['last_active'] = lastActive;
    _data['push_token'] = pushToken;
    _data['email'] = email;
    return _data;
  }
}