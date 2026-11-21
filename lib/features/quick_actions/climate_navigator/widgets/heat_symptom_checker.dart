import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';

// ─── Decision tree node types ────────────────────────────

enum _NodeType {
  question,
  selfCare,
  seekHelp,
}

class _TreeNode {
  final String id;
  final _NodeType type;
  final String textKey;
  final String? yesNodeId;
  final String? noNodeId;
  final List<String> tipKeys;
  final String? warningKey;

  const _TreeNode({
    required this.id,
    required this.type,
    required this.textKey,
    this.yesNodeId,
    this.noNodeId,
    this.tipKeys = const [],
    this.warningKey,
  });
}

const _decisionTree = <String, _TreeNode>{
  'start': _TreeNode(
    id: 'start',
    type: _NodeType.question,
    textKey: 'symptom_q_start',
    yesNodeId: 'q1',
    noNodeId: 'prevention',
  ),
  'prevention': _TreeNode(
    id: 'prevention',
    type: _NodeType.selfCare,
    textKey: 'symptom_title_prevention',
    tipKeys: [
      'symptom_tip_prevention_1',
      'symptom_tip_prevention_2',
      'symptom_tip_prevention_3',
      'symptom_tip_prevention_4',
      'symptom_tip_prevention_5',
      'symptom_tip_prevention_6',
    ],
  ),
  'q1': _TreeNode(
    id: 'q1',
    type: _NodeType.question,
    textKey: 'symptom_q_q1',
    yesNodeId: 'heatstroke_emergency',
    noNodeId: 'q2',
  ),
  'heatstroke_emergency': _TreeNode(
    id: 'heatstroke_emergency',
    type: _NodeType.seekHelp,
    textKey: 'symptom_title_heatstroke',
    warningKey: 'symptom_warn_heatstroke',
  ),
  'q2': _TreeNode(
    id: 'q2',
    type: _NodeType.question,
    textKey: 'symptom_q_q2',
    yesNodeId: 'heat_exhaustion',
    noNodeId: 'q3',
  ),
  'heat_exhaustion': _TreeNode(
    id: 'heat_exhaustion',
    type: _NodeType.selfCare,
    textKey: 'symptom_title_exhaustion',
    tipKeys: [
      'symptom_tip_exhaustion_1',
      'symptom_tip_exhaustion_2',
      'symptom_tip_exhaustion_3',
      'symptom_tip_exhaustion_4',
      'symptom_tip_exhaustion_5',
      'symptom_tip_exhaustion_6',
      'symptom_tip_exhaustion_7',
    ],
  ),
  'q3': _TreeNode(
    id: 'q3',
    type: _NodeType.question,
    textKey: 'symptom_q_q3',
    yesNodeId: 'heat_cramps',
    noNodeId: 'q4',
  ),
  'heat_cramps': _TreeNode(
    id: 'heat_cramps',
    type: _NodeType.selfCare,
    textKey: 'symptom_title_cramps',
    tipKeys: [
      'symptom_tip_cramps_1',
      'symptom_tip_cramps_2',
      'symptom_tip_cramps_3',
      'symptom_tip_cramps_4',
      'symptom_tip_cramps_5',
    ],
  ),
  'q4': _TreeNode(
    id: 'q4',
    type: _NodeType.question,
    textKey: 'symptom_q_q4',
    yesNodeId: 'heat_syncope',
    noNodeId: 'mild_heat',
  ),
  'heat_syncope': _TreeNode(
    id: 'heat_syncope',
    type: _NodeType.selfCare,
    textKey: 'symptom_title_syncope',
    tipKeys: [
      'symptom_tip_syncope_1',
      'symptom_tip_syncope_2',
      'symptom_tip_syncope_3',
      'symptom_tip_syncope_4',
      'symptom_tip_syncope_5',
    ],
  ),
  'mild_heat': _TreeNode(
    id: 'mild_heat',
    type: _NodeType.selfCare,
    textKey: 'symptom_title_mild',
    tipKeys: [
      'symptom_tip_mild_1',
      'symptom_tip_mild_2',
      'symptom_tip_mild_3',
      'symptom_tip_mild_4',
      'symptom_tip_mild_5',
    ],
  ),
};

class HeatSymptomChecker extends StatefulWidget {
  final String doctorFinderRoute;
  final String locale;

  const HeatSymptomChecker({
    super.key,
    required this.doctorFinderRoute,
    this.locale = 'English',
  });

  @override
  State<HeatSymptomChecker> createState() =>
      _HeatSymptomCheckerState();
}

class _HeatSymptomCheckerState
    extends State<HeatSymptomChecker> {

  String _currentNodeId = 'start';
  final List<String> _history = [];
  bool _isExpanded = false;

  _TreeNode get _current => _decisionTree[_currentNodeId]!;

  String _t(String key) => ClimateStrings.t(key, widget.locale);

  void _goTo(String nodeId) {
    setState(() {
      _history.add(_currentNodeId);
      _currentNodeId = nodeId;
    });
  }

  void _goBack() {
    if (_history.isEmpty) return;
    setState(() {
      _currentNodeId = _history.removeLast();
    });
  }

  void _restart() {
    setState(() {
      _currentNodeId = 'start';
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.errorBright.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    AppColors.errorBright.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🩺',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ClimateStrings.t('symptom_checker_title', widget.locale),
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textPrimary
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBright
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ClimateStrings.t('guide_offline', widget.locale),
                    style: const TextStyle(
                      color: AppColors.successBright,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        if (_isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.isLight
                  ? AppColors.glassBorder.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_history.isNotEmpty)
                  GestureDetector(
                    onTap: _goBack,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF00B4D8),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _t('symptom_back'),
                          style: TextStyle(
                            color: const Color(0xFF00B4D8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_history.isNotEmpty)
                  const SizedBox(height: 12),

                if (_current.type == _NodeType.question)
                  _buildQuestionNode(),

                if (_current.type == _NodeType.selfCare)
                  _buildSelfCareNode(),

                if (_current.type == _NodeType.seekHelp)
                  _buildSeekHelpNode(context),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionNode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _t(_current.textKey),
          style: TextStyle(
            color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _goTo(_current.yesNodeId!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorBright,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _t('symptom_yes'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goTo(_current.noNodeId!),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  side: BorderSide(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _t('symptom_no'),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelfCareNode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _t(_current.textKey),
          style: TextStyle(
            color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        ..._current.tipKeys.map(
          (tipKey) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    color: AppColors.successBright,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    _t(tipKey),
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassSecondary
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _restart,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.successBright,
              size: 15,
            ),
            label: Text(
              _t('symptom_start_over'),
              style: TextStyle(
                color: AppColors.successBright,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              side: const BorderSide(
                color: AppColors.successBright,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeekHelpNode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.errorBright.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.errorBright.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t(_current.textKey),
                style: const TextStyle(
                  color: AppColors.errorBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t(_current.warningKey ?? ''),
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassSecondary
                      : Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Semantics(
          button: true,
          label: ClimateStrings.t('guide_emergency_call', widget.locale),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              climateHeavyHaptic();
              final uri = Uri.parse('tel:999');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            icon: const Icon(
              Icons.call_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              ClimateStrings.t('guide_emergency_call', widget.locale),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorBright,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        ),

        const SizedBox(height: 10),

        Semantics(
          button: true,
          label: _t('symptom_find_doctor'),
          child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.push(widget.doctorFinderRoute);
            },
            icon: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.accentGold,
              size: 16,
            ),
            label: Text(
              _t('symptom_find_doctor'),
              style: TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              side: const BorderSide(
                color: AppColors.accentGold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _restart,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white38,
              size: 15,
            ),
            label: Text(
              _t('symptom_start_over'),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white38,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              side: BorderSide(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
