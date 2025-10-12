class UserUi {
  UserUi({
    this.id,
    this.firstname,
    this.lastname,
    this.fullname,
    this.userLetters,
    this.email,
    this.created,
    this.thumb,
    this.isFriend,
    this.friendStatus,
  });

  int? id;
  String? firstname;
  String? lastname;
  String? fullname;
  String? userLetters;
  String? email;
  String? created;
  String? thumb;
  bool? isFriend;
  String? friendStatus;

  factory UserUi.fromJson(Map<String, dynamic> json) => UserUi(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    fullname: json["fullname"],
    userLetters: json["userLetters"],
    email: json["email"],
    created: json["created"],
    thumb: json["thumb"],
    isFriend: json["isFriend"] ?? false,
    friendStatus: json["friendStatus"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "fullname": fullname,
    "userLetters": userLetters,
    "email": email,
    "created": created,
    "thumb": thumb,
  };
}