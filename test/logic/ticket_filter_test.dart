import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

// Mirror of _TicketListScreenState's private filter helpers so they can be
// unit-tested without spinning up a widget tree.

bool isDone(Ticket t) {
  final s = t.status.toLowerCase();
  return s == 'resolved' || s == 'closed';
}

List<Ticket> visible(List<Ticket> tickets, String query) {
  if (query.isEmpty) return tickets;
  final q = query.toLowerCase();
  return tickets
      .where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.displayId.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            t.status.toLowerCase().contains(q),
      )
      .toList();
}

List<Ticket> active(List<Ticket> tickets, String query) =>
    visible(tickets, query).where((t) => !isDone(t)).toList();

List<Ticket> resolved(List<Ticket> tickets, String query) =>
    visible(tickets, query).where(isDone).toList();

Ticket _t({
  String id = 't1',
  String displayId = 'TKT-001',
  String title = 'Test ticket',
  String category = 'Reimbursement',
  String status = 'Open',
}) => Ticket(
  id: id,
  displayId: displayId,
  title: title,
  category: category,
  status: status,
  priority: '',
);

void main() {
  // ── isDone ─────────────────────────────────────────────────────────────────

  group('isDone', () {
    // 'resolved' is the lowercase API value for tickets that have been
    // answered and closed by an officer.
    test('"resolved" status is done', () {
      expect(isDone(_t(status: 'resolved')), isTrue);
    });

    // Status values from the API may be title-cased. The check must be
    // case-insensitive to handle both 'resolved' and 'Resolved'.
    test('"Resolved" (title-case) is done', () {
      expect(isDone(_t(status: 'Resolved')), isTrue);
    });

    // 'closed' is the other terminal status, used when a ticket is manually
    // closed without a formal resolution.
    test('"closed" status is done', () {
      expect(isDone(_t(status: 'closed')), isTrue);
    });

    // Upper-case must also be handled in case the backend changes casing.
    test('"CLOSED" (upper-case) is done', () {
      expect(isDone(_t(status: 'CLOSED')), isTrue);
    });

    // 'Open' is the initial status when a ticket is first submitted.
    // It is an active (not done) state and should appear in the active tab.
    test('"Open" is not done', () {
      expect(isDone(_t(status: 'Open')), isFalse);
    });

    // 'In Review' means an officer has picked up the ticket but not yet
    // resolved it. The ticket is still active.
    test('"In Review" is not done', () {
      expect(isDone(_t(status: 'In Review')), isFalse);
    });

    // 'Waiting' is used when the officer is waiting for more info from the
    // user. The ticket is still active.
    test('"Waiting" is not done', () {
      expect(isDone(_t(status: 'Waiting')), isFalse);
    });

    // An empty status string (e.g. a partial API response) must not be
    // treated as done; it should appear in the active list for visibility.
    test('empty status is not done', () {
      expect(isDone(_t(status: '')), isFalse);
    });
  });
}
