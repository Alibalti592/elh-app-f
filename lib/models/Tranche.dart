class Tranche {
  final int id;
  final double amount;
  final String paidAt;
  final String status;
  final String? fileUrl;

  Tranche({
    required this.id,
    required this.amount,
    required this.paidAt,
    required this.status,
    this.fileUrl,
  });

  factory Tranche.fromJson(Map<String, dynamic> json) {
    return Tranche(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paidAt'],
      status: json['status'],
      fileUrl: json['fileUrl'],
    );
  }
  Tranche copyWith({
    int? id,
    double? amount,
    String? paidAt,
    String? status,
    String? fileUrl,
  }) {
    return Tranche(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
