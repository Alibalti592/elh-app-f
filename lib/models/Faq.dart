
List<Faq> faqsFromJson(jsonData) => (List<Faq>.from(jsonData.map((faq) => Faq.fromJson(faq))));
// List<Thread>.from(decodeData['threads'].map((thread) => Thread.fromJson(thread)));
class Faq {
  int id;
  String question;
  String reponse;
  bool online;
  bool isExpanded;

  Faq({
    required this.id,
    required this.question,
    required this.reponse,
    required this.online,
    required this.isExpanded,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    id: json["id"],
    question: json["question"],
    reponse: json["reponse"],
    online: json["online"],
    isExpanded: false, //for UI
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "reponse": reponse,
    "online": online,
  };
}