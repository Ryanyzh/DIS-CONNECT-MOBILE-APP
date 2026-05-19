class Ticket {
  final String id;
  final String title;
  final String category;
  final String status;
  final String priority;

  Ticket({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
    );
  }
}