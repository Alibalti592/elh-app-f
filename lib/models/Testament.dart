import 'dart:convert';

Testament testamentFromJson(jsonDatas) => Testament.fromJson(jsonDatas);
String testamentToJson(Testament data) => json.encode(data.toJson());

class Testament {
  int? id;
  String? from;
  String? location;
  String? family;
  String? goods;
  String? toilette;
  String? fixe;
  String? lastwill;

  Testament({
    this.id,
    this.from,
    this.location,
    this.family,
    this.goods,
    this.toilette,
    this.fixe,
    this.lastwill,
  });

  factory Testament.fromJson(Map<String, dynamic> json) => Testament(
    id: json["id"],
    from: json["from"],
    location: json["location"],
    family: json["family"],
    goods: json["goods"],
    toilette: json["toilette"],
    fixe: json["fixe"],
    lastwill: json["lastwill"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "location": location,
    "family": family,
    "goods": goods,
    "toilette": toilette,
    "fixe": fixe,
    "lastwill": lastwill,
  };


  dynamic set(String propertyName, value) {
    print(propertyName);
    if(propertyName == 'location') {
      this.location = value;
    } else if(propertyName == 'family') {
      this.family = value;
    } else if(propertyName == 'goods') {
      this.goods = value;
    }else if(propertyName == 'toilette') {
      this.toilette = value;
    }else if(propertyName == 'fixe') {
      this.fixe = value;
    }else if(propertyName == 'lastwill') {
      this.lastwill = value;
    }
  }

  dynamic get(String propertyName) {
    var _mapRep = toJson();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }
    throw ArgumentError('$propertyName property not found');
  }
}