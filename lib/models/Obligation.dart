import 'dart:convert';

List<Obligation> obligationFromJson(jsonData) =>
    List<Obligation>.from(jsonData.map((x) => Obligation.fromJson(x)));

String obligationToJson(List<Obligation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Obligation {
  int? id;
  String type;
  int? emprunteurId;
  int? remainingAmount; // <-- add this
  String preteurName = "";
  String emprunteurName = "";
  String preteurNum = "";
  String emprunteurNum = "";

  String createdByName = "";
  String cardOtherName = "";
  String cardOtherTel = "";

  String firstname;
  String lastname;
  String adress;
  String tel;

  num amount; // Montant prêté
  String currency; // Devise ($ / € / autre)
  String note; // Note facultative
  DateTime date;
  String dateDisplay;

  DateTime? dateStart;
  String? dateStartDisplay;
  DateTime? dateEnd; // Date limite de remboursement
  String? dateEndDisplay;
  String raison;
  String delay;
  String moyen;
  String conditonType;
  String conditonTypeDisplay;

  bool canEdit = true;
  int? relatedUserId;

  String status = "ini";
  bool isRelatedToUser = false;
  String? fileUrl; // <-- add this
  String? file;

  Obligation({
    this.file,
    this.id,
    this.type = 'jed',
    this.preteurName = "",
    this.emprunteurName = "",
    this.preteurNum = "",
    this.emprunteurNum = "",
    this.createdByName = "",
    this.firstname = "",
    this.lastname = "",
    this.cardOtherName = "",
    this.cardOtherTel = "",
    this.adress = "",
    this.tel = "",
    this.amount = 0,
    this.currency = "",
    this.note = "",
    DateTime? date,
    String? dateDisplay,
    this.raison = "",
    this.delay = "",
    this.moyen = "",
    this.conditonType = "single",
    this.conditonTypeDisplay = "En une fois",
    this.canEdit = true,
    this.relatedUserId,
    this.dateStart,
    this.dateStartDisplay,
    this.dateEnd,
    this.dateEndDisplay,
    this.status = 'ini',
    this.emprunteurId,
    this.remainingAmount,
    this.isRelatedToUser = false,
    this.fileUrl,
  })  : this.date = date ?? DateTime.now(),
        this.dateDisplay = dateDisplay ?? DateTime.now().toString();
  int? getEmprunteurId() => emprunteurId;
  String? getFile() => file;
  String? setFile(String? file) => this.file = file;
  factory Obligation.fromJson(Map<String, dynamic> json) => Obligation(
        id: json["id"],
        type: json["type"],
        createdByName: json["createdByName"],
        firstname: json["firstname"] ?? "",
        lastname: json["lastname"] ?? "",
        preteurName: json["preteurName"] ?? "",
        emprunteurName: json["emprunteurName"] ?? "",
        emprunteurNum: json["emprunteurNum"] ?? "",
        preteurNum: json["preteurNum"] ?? "",
        cardOtherName: json["cardOtherName"] ?? "",
        cardOtherTel: json["cardOtherTel"] ?? "",
        adress: json["adress"] ?? "",
        tel: json["tel"] ?? "",
        amount: json["amount"] ?? 0,
        currency: json["currency"] ?? "EUR",
        note: json["raison"] ?? "",
        date: json["date"] != null
            ? DateTime.parse(json["date"])
            : DateTime.now(),
        dateDisplay: json["dateDisplay"] ?? "",
        raison: json["raison"] ?? "",
        delay: json["delay"] ?? "",
        moyen: json["moyen"] ?? "",
        conditonType: json["conditonType"] ?? "single",
        conditonTypeDisplay: json["conditonTypeDisplay"] ?? "En une fois",
        canEdit: json["canEdit"] ?? true,
        relatedUserId: json["relatedUserId"],
        dateStart: json["dateStart"] != null
            ? DateTime.parse(json["dateStart"])
            : null,
        dateStartDisplay: json["dateStartDisplay"] ?? "",
        dateEnd:
            json["dateEnd"] != null ? DateTime.parse(json["dateEnd"]) : null,
        dateEndDisplay: json["dateEndDisplay"] ?? "",
        status: json["status"] ?? "ini",
        isRelatedToUser: json["isRelatedToUser"] ?? false,
        emprunteurId: json['relatedUserId'], // keep for backward compatibility
        remainingAmount: json['remainingAmount'] ?? 0,
        fileUrl: json['fileUrl'], // <-- map fileUrl from API
      );
  String get contactDisplay {
    // If the user manually entered a contact
    if ((firstname.isNotEmpty ?? false) ||
        (lastname.isNotEmpty ?? false) ||
        (tel.isNotEmpty ?? false)) {
      return "${firstname ?? ''} ${lastname ?? 'aaa'} (${tel ?? ''})";
    }

    // Fallback: existing contact
    return "${emprunteurName ?? ''})";
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "firstname": firstname,
        "lastname": lastname,
        "adress": adress,
        "tel": tel,
        "amount": amount,
        "currency": currency,
        "note": raison,
        "date": date.toIso8601String(),
        "dateDisplay": dateDisplay,
        "raison": raison,
        "delay": delay,
        "moyen": moyen,
        "conditonType": conditonType,
        "conditonTypeDisplay": conditonTypeDisplay,
        "relatedUserId": relatedUserId,
        "dateStart": dateStart?.toIso8601String(),
        "dateStartDisplay": dateStartDisplay,
        "dateEnd": dateEnd?.toIso8601String(),
        "dateEndDisplay": dateEndDisplay,
        "status": status,
        "isRelatedToUser": isRelatedToUser,
        "emprunteur_id": emprunteurId,
        "remainingAmount": remainingAmount,
        "fileUrl": fileUrl,
      };

  dynamic set(String propertyName, value) {
    switch (propertyName) {
      case 'firstname':
        firstname = value;
        break;
      case 'lastname':
        lastname = value;
        break;
      case 'adress':
        adress = value;
        break;
      case 'tel':
        tel = value;
        break;
      case 'date':
        date = value;
        break;
      case 'raison':
        raison = value;
        break;
      case 'delay':
        delay = value;
        break;
      case 'amount':
        amount = value;
        break;
      case 'currency':
        currency = value;
        break;
      case 'note':
        note = value;
        break;
      case 'moyen':
        moyen = value;
        break;
      case 'dateStart':
        dateStart = value;
        break;
      case 'dateEnd':
        dateEnd = value;
        break;
    }
  }

  dynamic get(String propertyName) {
    var _mapRep = _toMap();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }
    throw ArgumentError('$propertyName property not found');
  }

  Map<String, dynamic> _toMap() => {
        "id": id,
        "type": type,
        "firstname": firstname,
        "lastname": lastname,
        "adress": adress,
        "tel": tel,
        "amount": amount,
        "currency": currency,
        "note": raison,
        "date": date.toIso8601String(),
        "dateDisplay": dateDisplay,
        "delay": delay,
        "moyen": moyen,
        "conditonType": conditonType,
        "conditonTypeDisplay": conditonTypeDisplay,
        "dateStart": dateStart?.toIso8601String(),
        "dateStartDisplay": dateStartDisplay,
        "dateEnd": dateEnd?.toIso8601String(),
        "dateEndDisplay": dateEndDisplay,
      };
}
