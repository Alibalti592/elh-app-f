class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String view;
  final DateTime sendAt;
  String? status; // can be 'en attente', 'accept', 'decline'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.view,
    required this.sendAt,
    this.status,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      view: json['view'] ?? '',
      sendAt: DateTime.parse(json['sendAt']),
      status: json['status'] ?? 'pending',
    );
  }
}
