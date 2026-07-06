import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/faq/data/faq_repository.dart';

void main() {
  group('FaqEntry.fromJson', () {
    // Confirm all five fields are read correctly when the API returns a
    // fully populated FAQ entry.
    test('parses all fields from complete json', () {
      final e = FaqEntry.fromJson({
        'id': 'faq-1',
        'question': 'How do I submit a reimbursement?',
        'answer': 'Log in and navigate to Tickets.',
        'category': 'Finance',
        'order': 3,
      });

      expect(e.id, 'faq-1');
      expect(e.question, 'How do I submit a reimbursement?');
      expect(e.answer, 'Log in and navigate to Tickets.');
      expect(e.category, 'Finance');
      expect(e.order, 3);
    });

    // The FAQ screen groups entries by category. If the field is missing
    // from the API response the entry should appear in the General group
    // rather than crash or be hidden.
    test('defaults category to General when absent', () {
      final e = FaqEntry.fromJson({
        'id': 'faq-2',
        'question': 'Q',
        'answer': 'A',
      });
      expect(e.category, 'General');
    });

    // The order field drives sort position within a category group.
    // A missing field should not throw; it defaults to 0 (top of group).
    test('defaults order to 0 when absent', () {
      final e = FaqEntry.fromJson({
        'id': 'faq-3',
        'question': 'Q',
        'answer': 'A',
        'category': 'HR',
      });
      expect(e.order, 0);
    });

    // An entirely empty JSON object (e.g. a stub response during development)
    // must not throw. All string fields default to empty, numeric to 0.
    test('produces empty strings for all missing text fields', () {
      final e = FaqEntry.fromJson({});
      expect(e.id, '');
      expect(e.question, '');
      expect(e.answer, '');
      expect(e.category, 'General');
      expect(e.order, 0);
    });

    // Explicit order: 0 must be treated as a valid value (first position),
    // not confused with a missing field that also happens to be 0.
    test('handles int 0 order correctly', () {
      final e = FaqEntry.fromJson({
        'id': 'faq-4',
        'question': 'Q',
        'answer': 'A',
        'order': 0,
      });
      expect(e.order, 0);
    });

    // Large order values should be preserved as-is; no clamping or truncation.
    test('large order value is preserved', () {
      final e = FaqEntry.fromJson({
        'id': 'faq-5',
        'question': 'Q',
        'answer': 'A',
        'order': 999,
      });
      expect(e.order, 999);
    });
  });
}
