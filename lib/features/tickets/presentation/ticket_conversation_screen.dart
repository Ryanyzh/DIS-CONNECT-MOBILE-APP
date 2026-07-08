import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class _Message {
  final String messageId;
  final String senderName;
  final String senderRole;
  final bool isMe;
  final DateTime timestamp;
  final String content;
  final List<String> attachmentNames;

  const _Message({
    required this.messageId,
    required this.senderName,
    required this.senderRole,
    required this.isMe,
    required this.timestamp,
    required this.content,
    this.attachmentNames = const [],
  });

  factory _Message.fromJson(Map<String, dynamic> json, String currentUid) {
    final attachments = (json['attachments'] as List?) ?? [];
    return _Message(
      messageId: json['message_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderRole: json['sender_role'] as String? ?? '',
      isMe: json['sender_id'] == currentUid,
      timestamp:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      content: json['message_text'] as String? ?? '',
      attachmentNames: attachments
          .map((a) => (a as Map<String, dynamic>)['file_name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketConversationScreen extends StatefulWidget {
  final String ticketId;
  const TicketConversationScreen({super.key, required this.ticketId});

  @override
  State<TicketConversationScreen> createState() =>
      _TicketConversationScreenState();
}

class _TicketConversationScreenState extends State<TicketConversationScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  List<_Message> _messages = [];
  bool _loading = true;
  bool _sending = false;

  // RTDB subscription — cancelled in dispose().
  StreamSubscription<DatabaseEvent>? _rtdbSub;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  late final TicketRepository _repo = TicketRepository(ApiClient());

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _rtdbSub?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Listen to ticket_messages/{ticketId} in Realtime Database.
  // onValue fires immediately with the full snapshot, then again on any change.
  void _subscribeToMessages() {
    final uid = _currentUid;
    final ref = FirebaseDatabase.instance.ref('ticket_messages/${widget.ticketId}');

    _rtdbSub = ref.onValue.listen((event) {
      if (!mounted) return;

      final raw = event.snapshot.value;
      if (raw == null) {
        setState(() { _messages = []; _loading = false; });
        return;
      }

      // RTDB returns Map<dynamic, dynamic> keyed by message ID.
      final messages = (raw as Map<dynamic, dynamic>)
          .values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList()
        ..sort((a, b) =>
            (a['created_at'] as String).compareTo(b['created_at'] as String));

      setState(() {
        _messages = messages.map((m) => _Message.fromJson(m, uid)).toList();
        _loading = false;
      });
      _scrollToBottom();
    }, onError: (e) {
      debugPrint('RTDB message listener error: $e');
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _send() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _replyController.clear();
    FocusScope.of(context).unfocus();
    try {
      // The backend writes the message to RTDB — the listener above will
      // automatically pick it up without a manual re-fetch.
      await _repo.sendMessage(widget.ticketId, text);
    } catch (e) {
      debugPrint('Failed to send message: $e');
      _replyController.text = text;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const GradientIcon(icon: Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Conversation',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nSend the first message below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _MessageCard(message: _messages[i]),
                  ),
          ),
          _ReplyBar(
            controller: _replyController,
            onSend: _send,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  final _Message message;
  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(message.messageId),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: message.isMe
                            ? const Color(0xFF4C39F2)
                            : AppColors.ink,
                      ),
                    ),
                    if (message.senderRole.isNotEmpty)
                      Text(
                        message.senderRole == 'hr' ? 'HR Officer' : 'Scholar',
                        style: AppTypography.caption.copyWith(
                          color: message.isMe
                              ? const Color(0xFF9A32F8)
                              : AppColors.mute,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('d MMM, h:mm a').format(message.timestamp),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.body,
              height: 1.6,
            ),
          ),
          if (message.attachmentNames.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...message.attachmentNames.map(
              (name) => Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseSm),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.download_outlined,
                      color: AppColors.body,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  const _ReplyBar({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodySm.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Add a reply...',
                hintStyle: AppTypography.bodySm.copyWith(color: AppColors.mute),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: sending
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF6A2FF3),
                borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
              ),
              child: sending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
