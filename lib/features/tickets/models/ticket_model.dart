class Ticket {
  final String id;

  /// Human-readable reference shown in the UI, e.g. "REB-2024-0012"
  final String displayId;
  final String title;
  final String category;
  final String status;
  final String priority;
  final DateTime? createdAt;

  Ticket({
    required this.id,
    this.displayId = '',
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      displayId: json['display_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_id': displayId,
        'title': title,
        'category': category,
        'status': status,
        'priority': priority,
        'created_at': createdAt?.toIso8601String(),
      };
}
