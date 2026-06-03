import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Stub data
// ─────────────────────────────────────────────────────────────────────────────

class _Message {
  final String senderName;
  final bool isMe;
  final DateTime timestamp;
  final String content;
  final List<String> attachmentNames;

  const _Message({
    required this.senderName,
    required this.isMe,
    required this.timestamp,
    required this.content,
    this.attachmentNames = const [],
  });
}

final _sampleMessages = [
  _Message(
    senderName: 'Eileen (Scholarship Admin)',
    isMe: false,
    timestamp: DateTime(2024, 9, 10, 10, 30),
    content:
        'Hello, we have received your reimbursement request for your exchange '
        'programme. Please attach your flight ticket and other supporting '
        'documents.',
  ),
  _Message(
    senderName: 'You',
    isMe: true,
    timestamp: DateTime(2024, 9, 10, 11, 5),
    content:
        'Hi Eileen, attached is my flight ticket and the invoice. Thank you!',
    attachmentNames: ['flight_ticket.pdf'],
  ),
];

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
  final List<_Message> _messages = List.from(_sampleMessages);

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _Message(
          senderName: 'You',
          isMe: true,
          timestamp: DateTime.now(),
          content: text,
        ),
      );
      _replyController.clear();
    });
    FocusScope.of(context).unfocus();
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
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MessageCard(message: _messages[i]),
            ),
          ),
          _ReplyBar(controller: _replyController, onSend: () {}),
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
                child: Text(
                  message.senderName,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: message.isMe
                        ? const Color(0xFF4338CA)
                        : AppColors.ink,
                  ),
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
  const _ReplyBar({required this.controller, required this.onSend});

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
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF3730A3),
                borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
              ),
              child: const Icon(
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
