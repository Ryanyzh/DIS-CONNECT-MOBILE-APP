class Ticket {
  final String id;
  final String displayId;
  final String title;
  final String category;
  final String status;
  final String priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ticket({
    required this.id,
    this.displayId = '',
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    String resolve(dynamic field, String nameKey) {
      if (field is Map) return (field[nameKey] ?? '').toString();
      if (field is String) return field;
      return '';
    }

    return Ticket(
      id:         (json['ticket_id'] ?? json['id'] ?? '').toString(),
      displayId:  (json['ticket_code'] ?? json['display_id'] ?? '').toString(),
      title:      (json['subject'] ?? json['title'] ?? '').toString(),
      category:   resolve(json['category'], 'category_name'),
      status:     resolve(json['status'], 'status_name'),
      priority:   resolve(json['priority'], 'priority_name'),
      createdAt:  _parseDate(json['created_at']),
      updatedAt:  _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_code': displayId,
        'subject': title,
        'category': category,
        'status': status,
        'priority': priority,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
