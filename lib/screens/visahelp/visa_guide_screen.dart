import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/ai_chat_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VisaGuideScreen extends ConsumerStatefulWidget {
  const VisaGuideScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  ConsumerState<VisaGuideScreen> createState() => _VisaGuideScreenState();
}

class _VisaGuideScreenState extends ConsumerState<VisaGuideScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  int? _expandedStep;

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _askAiAboutStep(VisaGuide guide, VisaGuideStep step) {
    final language = ref.read(userLanguageProvider).valueOrNull ?? 'English';
    final message =
        'I am following the "${guide.title}" guide in Raabta. '
        'Please explain Step ${step.stepNumber}: "${step.title}" in simple language. '
        'Documents needed: ${step.documents.join(", ")}. '
        'Respond in $language.';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiChatScreen(
          initialMessage: message,
          contextSubtitle: guide.title,
        ),
      ),
    );
  }

  Future<void> _shareGuide(VisaGuide guide) async {
    final buffer = StringBuffer('${guide.title}\n${guide.summary}\n\n');
    for (final step in guide.steps) {
      buffer.writeln('Step ${step.stepNumber}: ${step.title}');
      buffer.writeln(step.description);
      buffer.writeln('');
    }
    buffer.writeln('Official links:');
    for (final link in guide.officialLinks) {
      buffer.writeln('${link.name}: ${link.url}');
    }
    await Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(visaGuideProvider(widget.categoryId));
    final languageAsync = ref.watch(userLanguageProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: guideAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _cyanColor),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: _subtitleColor, size: 48),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: const TextStyle(color: _subtitleColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(visaGuideProvider(widget.categoryId)),
                  child: const Text('Retry', style: TextStyle(color: _cyanColor)),
                ),
              ],
            ),
          ),
          data: (guide) {
            final languageLabel = languageAsync.valueOrNull ?? 'English';

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Language: $languageLabel',
                                style: const TextStyle(
                                  color: _subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _shareGuide(guide),
                          icon: const Icon(Icons.share, color: _cyanColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      guide.summary,
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: guide.officialLinks.map((link) {
                        return ActionChip(
                          label: Text(link.name),
                          avatar: const Icon(Icons.link, size: 16),
                          backgroundColor: _surfaceColor,
                          labelStyle: const TextStyle(color: _cyanColor),
                          side: BorderSide(color: _cyanColor.withValues(alpha: 0.3)),
                          onPressed: () => _openLink(link.url),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final step = guide.steps[index];
                        final isExpanded = _expandedStep == step.stepNumber;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: isExpanded
                                  ? Border.all(
                                      color: _cyanColor.withValues(alpha: 0.4),
                                    )
                                  : null,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      _expandedStep = isExpanded
                                          ? null
                                          : step.stepNumber;
                                    });
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _cyanColor.withValues(alpha: 0.15),
                                    child: Text(
                                      '${step.stepNumber}',
                                      style: const TextStyle(
                                        color: _cyanColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    step.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${step.time} · ${step.cost}',
                                    style: const TextStyle(
                                      color: _subtitleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: _subtitleColor,
                                  ),
                                ),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.description,
                                          style: const TextStyle(
                                            color: _subtitleColor,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Documents needed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: step.documents
                                              .map(
                                                (doc) => Chip(
                                                  label: Text(doc),
                                                  backgroundColor:
                                                      _backgroundColor,
                                                  labelStyle: const TextStyle(
                                                    color: _subtitleColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _askAiAboutStep(guide, step),
                                            icon: const Icon(
                                              Icons.smart_toy_outlined,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Ask AI about this step',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _cyanColor,
                                              side: BorderSide(
                                                color: _cyanColor
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: guide.steps.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
