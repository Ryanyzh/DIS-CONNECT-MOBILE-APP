import '../../../core/network/api_client.dart';

class FaqEntry {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;

  const FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
  });

  factory FaqEntry.fromJson(Map<String, dynamic> json) {
    return FaqEntry(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      order: json['order'] as int? ?? 0,
    );
  }
}

class FaqRepository {
  final ApiClient apiClient;
  FaqRepository(this.apiClient);

  Future<List<FaqEntry>> getFaqs() async {
    final response = await apiClient.get('/api/faqs') as List;
    return response
        .map((item) => FaqEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
