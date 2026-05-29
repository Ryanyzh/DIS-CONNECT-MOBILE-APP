import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  static const int _totalSteps = 3;

  late final PageController _pageController;
  int _currentStep = 0; // 0-indexed

  // ── Step 1 state ─────────────────────────────────────────────────────────
  final _subjectController = TextEditingController();

  // ── Step 2 state ─────────────────────────────────────────────────────────
  final _descController = TextEditingController();

  // ── Step 3 state ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Step indicator ──────────────────────────────────────────────
          _StepIndicator(current: _currentStep, total: _totalSteps),

          // ── Page content ────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    const stepTitles = ['Ticket Info', 'Details', 'Review & Attach'];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: null, // TODO: confirm discard if there are unsaved changes
      ),
      title: Column(
        children: [
          Text(
            'New Ticket',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontSize: 17,
            ),
          ),
          Text(
            stepTitles[_currentStep],
            style: AppTypography.caption.copyWith(
              color: AppColors.mute,
              fontSize: 11,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step pages
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: if user has a profile, show their name/email and pre-fill contact info fields
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: category dropdown, priority selector, subject field
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: description field, due date picker, file attachments, submit button
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current; // 0-indexed
  final int total;
  const _StepIndicator({required this.current, required this.total});

  static const _labels = ['Ticket Info', 'Details', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(total * 2 - 1, (i) {
          // Even indices → step circles; odd indices → connector lines
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final isDone = current > stepBefore;
            // top: (circle radius 15) − (half line height 1) = 14
            // keeps the connector centred on the circle, not the whole Column
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF4338CA)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            );
          }

          final step = i ~/ 2;
          final isDone = current > step;
          final isActive = current == step;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF4338CA)
                      : isActive
                      ? const Color(0xFF4338CA)
                      : const Color(0xFFF1F5F9),
                  border: isActive
                      ? Border.all(color: const Color(0xFFE0E7FF), width: 3)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          '${step + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF4338CA)
                      : isDone
                      ? AppColors.body
                      : AppColors.mute,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
