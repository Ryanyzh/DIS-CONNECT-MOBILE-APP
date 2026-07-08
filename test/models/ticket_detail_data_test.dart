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

  // ── Category ───────────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — category', () {
    // The enriched response nests category inside a map object.
    test('reads category_name from nested map', () {
      final json = _base()..['category'] = {'category_name': 'Internship'};
      final d = TicketDetailData.fromJson(json);
      expect(d.category, 'Internship');
    });

    // Non-enriched responses pass category as a plain string.
    test('reads bare string category', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.category, 'Reimbursement');
    });
  });

  // ── Priority ───────────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — priority', () {
    // Tickets without a priority set should show no priority badge.
    test('returns null priority when empty', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.priority, isNull);
    });

    // Priority is nested in an object that also carries the badge colour.
    test('parses priority_name from nested map', () {
      final json = _base()
        ..['priority'] = {'priority_name': 'High', 'color_code': '#EF4444'};
      final d = TicketDetailData.fromJson(json);
      expect(d.priority, 'High');
    });

    // The colour is stored as a hex string and must be converted to a
    // Flutter Color so the badge widget can apply it directly.
    test('parses priority color from hex code', () {
      final json = _base()
        ..['priority'] = {'priority_name': 'High', 'color_code': '#EF4444'};
      final d = TicketDetailData.fromJson(json);
      expect(d.priorityColor, isNotNull);
      expect(d.priorityColor, const Color(0xFFEF4444));
    });

    // When the API omits color_code the badge falls back to a default colour,
    // so priorityColor should be null rather than throwing.
    test('priorityColor is null when color_code absent', () {
      final json = _base()..['priority'] = {'priority_name': 'Low'};
      final d = TicketDetailData.fromJson(json);
      expect(d.priorityColor, isNull);
    });
  });

  // ── Date parsing (_parseDate) ──────────────────────────────────────────────

  group('TicketDetailData.fromJson — date parsing (_parseDate)', () {
    // Timestamps arrive as UTC strings. The detail screen shows local time,
    // so the model must convert before storing.
    test('createdAt is parsed to local time', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.createdAt.isUtc, isFalse);
    });

    // updatedAt drives the "Last updated" line in the timeline section.
    test('updatedAt is parsed to local time', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.updatedAt.isUtc, isFalse);
    });

    // A ticket without a due date should not show the due-date row at all.
    test('dueAt is null when field is absent', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.dueAt, isNull);
    });

    // Some API versions use 'due_date' instead of 'due_at'. The model checks
    // both keys so either format works.
    test('dueAt falls back to due_date field', () {
      final json = _base()..['due_date'] = '2025-09-01T00:00:00Z';
      final d = TicketDetailData.fromJson(json);
      expect(d.dueAt, isNotNull);
    });

    // Regression: the backend used to default due_at to the Unix epoch
    // (1970-01-01) when no due date was set. The parser guards against this
    // by treating any epoch-or-earlier timestamp as absent.
    test('epoch due_at is treated as absent — regression for 1970 bug', () {
      final json = _base()..['due_at'] = '1970-01-01T00:00:00Z';
      final d = TicketDetailData.fromJson(json);
      expect(d.dueAt, isNull);
    });

    // Ensure the epoch guard also covers any negative-millisecond timestamp
    // (pre-1970 dates are equally invalid as due dates).
    test('negative epoch due_at is treated as absent', () {
      final json = _base()..['due_at'] = '1969-12-31T23:59:59Z';
      final d = TicketDetailData.fromJson(json);
      expect(d.dueAt, isNull);
    });

    // A legitimate future due date should be parsed and stored normally.
    // Using noon UTC to avoid any timezone-induced day boundary shifts.
    test('valid future dueAt is parsed correctly', () {
      final json = _base()..['due_at'] = '2027-06-15T12:00:00Z';
      final d = TicketDetailData.fromJson(json);
      expect(d.dueAt, isNotNull);
      expect(d.dueAt!.year, 2027);
    });

    // resolvedAt and closedAt are only populated by the backend once those
    // lifecycle events occur. Before that they must remain null.
    test('null resolved_at and closed_at remain null', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.resolvedAt, isNull);
      expect(d.closedAt, isNull);
    });
  });

  // ── Officer ────────────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — officer', () {
    // The enriched response nests the assigned officer in an object.
    // All three fields (name, role, initials) are used in the officer card.
    test('reads officer name from nested assigned_officer map', () {
      final json = _base()
        ..['assigned_officer'] = {
          'name': 'Alice Tan',
          'role': 'HR Manager',
          'initials': 'AT',
        };
      final d = TicketDetailData.fromJson(json);
      expect(d.officerName, 'Alice Tan');
      expect(d.officerRole, 'HR Manager');
      expect(d.officerInitials, 'AT');
    });

    // Flat officer fields are used by older API response shapes.
    test('falls back to flat officer_name field', () {
      final json = _base()
        ..['officer_name'] = 'Bob Lim'
        ..['officer_role'] = 'Admin'
        ..['officer_initials'] = 'BL';
      final d = TicketDetailData.fromJson(json);
      expect(d.officerName, 'Bob Lim');
      expect(d.officerInitials, 'BL');
    });

    // An unassigned ticket has no officer. The officer card must be hidden
    // when all officer fields are null.
    test('officer fields are null when absent', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.officerName, isNull);
      expect(d.officerRole, isNull);
    });
  });

  // ── Escalation ─────────────────────────────────────────────────────────────

  group('TicketDetailData.fromJson — escalation', () {
    // Most tickets are never escalated; the flag should default to false
    // so the escalation banner is hidden.
    test('isEscalated defaults to false', () {
      final d = TicketDetailData.fromJson(_base());
      expect(d.isEscalated, isFalse);
    });

    // When the backend marks a ticket as escalated, the UI shows a banner.
    test('isEscalated is true when flag set', () {
      final json = _base()..['is_escalated'] = true;
      final d = TicketDetailData.fromJson(json);
      expect(d.isEscalated, isTrue);
    });

    // The escalation object carries the recipient's name and the timestamp,
    // both shown in the escalation banner.
    test('reads escalated_to_name from nested escalation map', () {
      final json = _base()
        ..['is_escalated'] = true
        ..['escalation'] = {
          'to_name': 'Senior Officer',
          'escalated_at': '2025-07-01T09:00:00Z',
        };
      final d = TicketDetailData.fromJson(json);
      expect(d.escalatedToName, 'Senior Officer');
      expect(d.escalatedAt, isNotNull);
    });
  });
}
