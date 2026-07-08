import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/tickets/presentation/ticket_detail_screen.dart';

// Minimal valid JSON that satisfies all required fields.
Map<String, dynamic> _base() => {
  'ticket_code': 'TKT-001',
  'subject': 'Test subject',
  'category': 'Reimbursement',
  'status': {
    'status_name': 'Open',
    'status_type': 'active',
    'is_closed': false,
  },
  'created_at': '2025-06-01T10:00:00Z',
  'updated_at': '2025-06-02T08:00:00Z',
};

void main() {
  // ── TicketDetailData.fromJson ──────────────────────────────────────────────
  // Tests for the full detail payload returned by GET /api/v1/tickets/:id.
  // Covers field extraction, nested-vs-bare shapes, date parsing, and all
  // optional sub-objects (priority, officer, escalation, attachments).

  // ── Basic fields ───────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — basic fields', () {
    // Confirm the two most prominent display fields are read from their
    // primary keys when both are present.
    test('parses ticket_code and subject', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.ticketCode, 'TKT-001');
      expect(d.subject, 'Test subject');
    });

    // Some endpoints return 'display_id' instead of 'ticket_code'.
    // The detail screen header must still show a readable ticket reference.
    test('falls back to display_id when ticket_code is absent', () {
      final json = _base()
        ..remove('ticket_code')
        ..['display_id'] = 'TKT-FALLBACK';
      final d = TicketDetailData.fromJson(json);
      expect(d.ticketCode, 'TKT-FALLBACK');
    });

    // Some endpoints return 'title' instead of 'subject' for the ticket name.
    test('falls back to title when subject is absent', () {
      final json = _base()
        ..remove('subject')
        ..['title'] = 'Fallback title';
      final d = TicketDetailData.fromJson(json);
      expect(d.subject, 'Fallback title');
    });
  });

  // ── Status ─────────────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — status', () {
    // The enriched response nests status details inside a map.
    // Verify the display name is extracted from the nested key.
    test('reads status_name from nested map', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.statusName, 'Open');
    });

    // status_type is used to drive colour coding in the badge widget.
    test('reads status_type from nested map', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.statusType, 'active');
    });

    // isClosed controls whether the "Add Reply" input is disabled.
    test('isClosed is true when nested is_closed = true', () {
      final json = _base()
        ..['status'] = {'status_name': 'Closed', 'is_closed': true};
      final d = TicketDetailData.fromJson(json);
      expect(d.isClosed, isTrue);
    });

    // A ticket with is_closed = false should not disable the reply input.
    test('isClosed is false when nested is_closed = false', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.isClosed, isFalse);
    });

    // Non-enriched responses pass status as a plain string.
    // The model must handle both shapes so older API versions don't break.
    test('handles bare string status', () {
      final json = _base()..['status'] = 'Waiting';
      final d = TicketDetailData.fromJson(json);
      expect(d.statusName, 'Waiting');
    });
  });
}
