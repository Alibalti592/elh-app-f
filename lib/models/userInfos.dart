import 'dart:convert';

UserInfos userInfosFromJson(String str) => UserInfos.fromJson(json.decode(str));

String userInfosToJson(UserInfos data) => json.encode(data.toJson());

class UserInfos {
  UserInfos({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    this.phone,
    required this.phonePrefix,
    required this.city,
    this.birthdate,
    this.email,
    required this.photo,
    this.socialProfileSlug,
  });

  int? id;
  String firstname;
  String lastname;
  String fullname;
  String? phone;
  String phonePrefix = '+33';
  String city;
  DateTime? birthdate;
  String? email;
  String photo;
  String? socialProfileSlug;

  factory UserInfos.fromJson(Map<String, dynamic> json) => UserInfos(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    fullname: "${json["firstname"]} ${json["lastname"]}",
    phone: json["phone"],
    city: json["city"] == null ? "" : json["city"],
    phonePrefix: json["phonePrefix"] == null ? "+33" : json["phonePrefix"],
    birthdate: json["birthdate"] != '' && json["birthdate"] != null ? DateTime.parse(json["birthdate"]) : null,
    email: json["email"],
    photo: json["photo"] == null ? "" : json["photo"],
    socialProfileSlug: json["socialProfileSlug"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "firstname": firstname,
    "lastname": lastname,
    "phone": phone,
    "phonePrefix": phonePrefix,
    "city": city,
    "birthdate": birthdate == null ? '' : "${birthdate!.year.toString().padLeft(4, '0')}-${birthdate!.month.toString().padLeft(2, '0')}-${birthdate!.day.toString().padLeft(2, '0')}",
    "email": email,
    "photo": photo,
    "socialProfileSlug": socialProfileSlug,
  };
}