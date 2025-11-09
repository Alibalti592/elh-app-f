class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String view;
  final DateTime sendAt;
  final Map<String, dynamic>? datas;

  String? status; // can be 'en attente', 'accept', 'decline'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.view,
    required this.sendAt,
    this.status,
    this.datas,
    this.isRead = false,
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
      datas: json['datas'] != null
          ? Map<String, dynamic>.from(json['datas'])
          : null,
      isRead: json['isRead'] ?? false,
    );
  }
}
