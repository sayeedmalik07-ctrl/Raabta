import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/post_engine/data/post_duplicate_candidate_loader.dart';
import 'package:raabta/features/post_engine/data/post_schema_adapter.dart';
import 'package:raabta/features/post_engine/domain/marketplace_comparable_price_query.dart';
import 'package:raabta/features/post_engine/domain/marketplace_reseller_signal.dart';
import 'package:raabta/features/post_engine/domain/post_category_trust.dart';
import 'package:raabta/features/post_engine/domain/post_draft_manager.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/features/post_engine/domain/post_price_suggester.dart';
import 'package:raabta/features/post_engine/domain/post_identity_verification.dart';
import 'package:raabta/features/post_engine/domain/post_intelligence_adapter.dart';
import 'package:raabta/features/post_engine/domain/post_service_request_category_catalog.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';
import 'package:raabta/features/post_engine/domain/post_draft_publish_state.dart';
import 'package:raabta/features/post_engine/domain/post_publish_coordinator.dart';
import 'package:raabta/features/post_engine/domain/post_publish_engine.dart';
import 'package:raabta/features/post_engine/domain/post_publish_trust_gate.dart';
import 'package:raabta/features/post_engine/domain/post_quality_engine.dart';
import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';
import 'package:raabta/features/post_engine/domain/post_validation_debug.dart';
import 'package:raabta/features/post_engine/domain/post_validation_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/post_draft_relocated_snackbar.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';
import 'package:raabta/features/post_engine/presentation/widgets/draft_saved_indicator.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_category_verification_banner.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_combined_category_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_service_listing_type_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_service_request_ai_confirm_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_service_request_ai_entry_step.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_marketplace_category_confirm_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_marketplace_draft_insights_panel.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_marketplace_photo_first_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_quality_panel.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_form.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_hub_loading.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_marketplace_hub_shell.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_services_hub_shell.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_vertical_preview.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/presentation/widgets/business_contact_mode_picker.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/services/firebase_service.dart';

enum _PostFlowStep {
  listingType,
  requestAiEntry,
  requestAiConfirm,
  photoFirst,
  categoryConfirm,
  category,
  form,
  preview,
  visibility,
}

/// Unified schema-driven posting flow for Housing, Business, Services, Marketplace.
class PostFlowScreen extends ConsumerStatefulWidget {
  const PostFlowScreen({
    super.key,
    required this.vertical,
    this.categoryPath,
    this.initialListingType,
  });

  final PostVertical vertical;

  /// When null/empty, wizard opens at step 1 (combined category picker).
  final String? categoryPath;

  /// Pre-selected Services listing type (provider offer vs. customer request).
  final ServiceListingType? initialListingType;

  @override
  ConsumerState<PostFlowScreen> createState() => _PostFlowScreenState();
}

class _PostFlowScreenState extends ConsumerState<PostFlowScreen> {
  final Map<String, dynamic> _values = {};
  final GlobalKey<PostSchemaFormState> _formKey = GlobalKey();
  Map<String, String> _errors = {};
  late _PostFlowStep _step;
  String? _categoryPath;
  late ServiceListingType _serviceListingType;
  PostDraftManager? _draftManager;
  DateTime? _lastSavedAt;
  DraftRecord? _pendingDraft;
  bool _showRestoreBanner = false;
  bool _publishing = false;
  bool _tradeComplianceAcknowledged = false;
  final _requestAiController = TextEditingController();
  bool _requestAiAnalyzing = false;
  PostServiceRequestExtraction? _requestAiExtraction;
  String? _requestAiCategoryLabel;
  final _marketplaceMediaEngine = PostMediaEngine();
  List<String> _marketplacePhotoPaths = [];
  String _marketplacePhotoHint = '';
  bool _marketplaceAiAnalyzing = false;
  bool _marketplaceCategoryDetected = false;
  PostCategorySuggestion? _marketplaceCategorySuggestion;
  String? _marketplaceCategoryLabel;
  PostPriceSuggestion? _marketplacePriceSuggestion;
  bool _marketplacePriceGrounded = false;
  bool _marketplacePriceShowFallback = false;
  String? _marketplaceResellerNudgeKey;

  static const _wizardSteps = 3;

  @override
  void dispose() {
    final draftFormId = _draftManager?.formId;
    _requestAiController.dispose();
    _draftManager?.dispose();
    if (draftFormId != null) {
      unawaited(
        DraftService.instance.getDraft(draftFormId).then((record) {
          if (record != null) PostDraftRelocatedSnackbar.markPending();
        }),
      );
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _categoryPath = widget.categoryPath?.isNotEmpty == true
        ? widget.categoryPath
        : null;
    _serviceListingType =
        widget.initialListingType ?? ServiceListingType.provider;
    if (widget.vertical == PostVertical.services && _categoryPath == null) {
      if (widget.initialListingType == null) {
        _step = _PostFlowStep.listingType;
      } else if (widget.initialListingType == ServiceListingType.request) {
        _step = _PostFlowStep.requestAiEntry;
      } else {
        _step = _PostFlowStep.category;
      }
    } else if (widget.vertical == PostVertical.marketplace &&
        _categoryPath == null) {
      _step = _PostFlowStep.photoFirst;
    } else {
      _step = _categoryPath == null
          ? _PostFlowStep.category
          : _PostFlowStep.form;
    }
    if (_categoryPath != null) {
      _initDrafts(_categoryPath!);
    }
  }

  bool get _forServiceRequest =>
      widget.vertical == PostVertical.services &&
      _serviceListingType == ServiceListingType.request;

  void _onListingTypeSelected(ServiceListingType type) {
    setState(() {
      _serviceListingType = type;
      _step = type == ServiceListingType.request
          ? _PostFlowStep.requestAiEntry
          : _PostFlowStep.category;
      _values.clear();
      _errors = {};
      _requestAiExtraction = null;
      _requestAiCategoryLabel = null;
      _requestAiController.clear();
    });
  }

  void _goToManualCategory() {
    setState(() {
      _step = _PostFlowStep.category;
      _requestAiExtraction = null;
      _requestAiCategoryLabel = null;
    });
  }

  void _goToMarketplaceManualCategory() {
    setState(() {
      _step = _PostFlowStep.category;
      _marketplaceCategorySuggestion = null;
      _marketplaceCategoryLabel = null;
    });
  }

  void _goToMarketplaceManualForm() {
    setState(() {
      _step = _PostFlowStep.category;
      _marketplacePhotoPaths = [];
      _marketplacePhotoHint = '';
      _marketplaceCategorySuggestion = null;
      _marketplaceCategoryLabel = null;
    });
  }

  String _marketplaceDetectFreeText(List<String> photoPaths, String hint) {
    final buffer = StringBuffer('Marketplace item with ${photoPaths.length} photo(s).');
    if (hint.isNotEmpty) {
      buffer.write(' $hint');
    }
    return buffer.toString();
  }

  Future<void> _continueMarketplacePhotos(
    List<String> photoPaths,
    String hint,
    String locale,
  ) async {
    if (photoPaths.isEmpty || _marketplaceAiAnalyzing) return;

    setState(() {
      _marketplacePhotoPaths = List<String>.from(photoPaths);
      _marketplacePhotoHint = hint;
      _marketplaceAiAnalyzing = true;
    });

    try {
      if (!_marketplaceCategoryDetected) {
        final user = ref.read(currentUserProvider);
        final suggestion = await PostEngine().intelligence.detectCategory(
              freeText: _marketplaceDetectFreeText(photoPaths, hint),
              locale: locale,
              userId: user?.uid,
            );
        if (!mounted) return;

        if (suggestion == null ||
            suggestion.categoryPath.trim().isEmpty ||
            suggestion.confidence < 0.35) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PostEngineStrings.t('marketplace_ai_failed', locale),
              ),
            ),
          );
          setState(() => _step = _PostFlowStep.category);
          return;
        }

        final schema = await ref.read(
          postVerticalSchemaProvider(PostVertical.marketplace).future,
        );
        final node = schema.findCategoryByPath(suggestion.categoryPath);
        if (node == null || !node.leaf) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PostEngineStrings.t('marketplace_ai_failed', locale),
              ),
            ),
          );
          setState(() => _step = _PostFlowStep.category);
          return;
        }

        setState(() {
          _marketplaceCategoryDetected = true;
          _marketplaceCategorySuggestion = suggestion;
          _marketplaceCategoryLabel = PostEngineStrings.label(
            node.labelKey,
            locale,
            fallback: node.fallbackLabel,
          );
          _step = _PostFlowStep.categoryConfirm;
        });
        return;
      }

      setState(() => _step = _PostFlowStep.categoryConfirm);
    } finally {
      if (mounted) setState(() => _marketplaceAiAnalyzing = false);
    }
  }

  Future<void> _confirmMarketplaceCategory(String locale) async {
    final suggestion = _marketplaceCategorySuggestion;
    if (suggestion == null) return;

    final path = suggestion.categoryPath;
    final seedValues = <String, dynamic>{
      'photos': List<String>.from(_marketplacePhotoPaths),
      if (_marketplacePhotoHint.isNotEmpty) 'notes': _marketplacePhotoHint,
    };

    setState(() {
      _categoryPath = path;
      _values
        ..clear()
        ..addAll(seedValues);
      _step = _PostFlowStep.form;
      _errors = {};
      _showRestoreBanner = false;
      _pendingDraft = null;
    });
    await _initDrafts(path);

    final user = ref.read(currentUserProvider);
    final title = await PostEngine().intelligence.generateTitle(
          fieldValues: {...seedValues, '_categoryPath': path},
          locale: locale,
          userId: user?.uid,
        );
    final description = await PostEngine().intelligence.generateDescription(
          fieldValues: {...seedValues, '_categoryPath': path},
          locale: locale,
          userId: user?.uid,
        );

    if (!mounted) return;
    setState(() {
      if (title != null && title.trim().isNotEmpty) {
        _values['title'] = title.trim();
      }
      if (description != null && description.trim().isNotEmpty) {
        _values['description'] = description.trim();
      }
    });
    _draftManager?.scheduleSave(_values);
    await _refreshMarketplaceDraftInsights(locale);
  }

  Future<void> _refreshMarketplaceDraftInsights(String locale) async {
    if (widget.vertical != PostVertical.marketplace) return;
    final categoryPath = _categoryPath;
    if (categoryPath == null) return;

    PostPriceSuggestion? priceSuggestion;
    var priceGrounded = false;
    var priceShowFallback = false;
    String? resellerKey;

    try {
      final listings = await ref.read(marketplaceListingsProvider.future);
      final leafId = PostSchemaAdapter.leafCategoryId(categoryPath);
      final comparable = const MarketplaceComparablePriceQuery().query(
        categoryLeafId: leafId,
        condition: _values['condition']?.toString(),
        allListings: listings,
      );
      priceGrounded = comparable.grounded;
      priceShowFallback = !comparable.grounded;
      priceSuggestion = comparable.toSuggestion();

      final user = ref.read(currentUserProvider);
      if (user != null && FirebaseService.isReady) {
        final ownerListings = await loadOwnerMarketplaceListingMaps(
          firestore: FirebaseFirestore.instance,
          ownerUserId: user.uid,
        );
        final signal = const MarketplaceResellerSignalEvaluator().evaluate(
          ownerListings: ownerListings,
          draftValues: _values,
          categoryPath: categoryPath,
        );
        if (signal.shouldShow) resellerKey = signal.reasonKey;
      }
    } catch (_) {
      // Insights are optional — never block posting.
    }

    if (!mounted) return;
    setState(() {
      _marketplacePriceSuggestion = priceSuggestion;
      _marketplacePriceGrounded = priceGrounded;
      _marketplacePriceShowFallback = priceShowFallback;
      _marketplaceResellerNudgeKey = resellerKey;
    });
  }

  Future<void> _analyzeServiceRequest(String locale) async {
    final description = _requestAiController.text.trim();
    if (description.length < 8 || _requestAiAnalyzing) return;

    final schema = await ref.read(
      postVerticalSchemaProvider(PostVertical.services).future,
    );
    final catalog = PostServiceRequestCategoryCatalog.compactPromptList(
      schema,
      locale,
    );
    final user = ref.read(currentUserProvider);

    setState(() => _requestAiAnalyzing = true);
    try {
      final extraction = await PostEngine().intelligence.extractServiceRequest(
            freeText: description,
            categoryCatalog: catalog,
            locale: locale,
            userId: user?.uid,
          );
      if (!mounted) return;
      if (extraction == null || !extraction.isUsable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostEngineStrings.t('request_ai_failed', locale)),
          ),
        );
        return;
      }
      final node = schema.findCategoryByPath(extraction.categoryPath);
      if (node == null || !node.leaf) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostEngineStrings.t('request_ai_failed', locale)),
          ),
        );
        return;
      }
      setState(() {
        _requestAiExtraction = extraction;
        _requestAiCategoryLabel = PostEngineStrings.label(
          node.labelKey,
          locale,
          fallback: node.fallbackLabel,
        );
        _step = _PostFlowStep.requestAiConfirm;
      });
    } finally {
      if (mounted) setState(() => _requestAiAnalyzing = false);
    }
  }

  void _applyServiceRequestAi(Map<String, dynamic> confirmedValues) {
    final extraction = _requestAiExtraction;
    if (extraction == null) return;
    final path = extraction.categoryPath;
    setState(() {
      _categoryPath = path;
      _values
        ..clear()
        ..addAll(confirmedValues);
      _step = _PostFlowStep.form;
      _errors = {};
      _showRestoreBanner = false;
      _pendingDraft = null;
      _requestAiExtraction = null;
    });
    _initDrafts(path);
  }

  Future<void> _initDrafts(String categoryPath) async {
    _draftManager?.dispose();
    final manager = PostEngine().drafts(
      vertical: widget.vertical,
      categoryPath: categoryPath,
      onSaved: (at) {
        if (mounted) setState(() => _lastSavedAt = at);
      },
    );
    await manager.init();
    final draft = await manager.loadRestorableDraft();
    if (!mounted) return;
    setState(() {
      _draftManager = manager;
      if (draft != null) {
        _pendingDraft = draft;
        _showRestoreBanner = true;
        _lastSavedAt = draft.savedAt;
      }
    });
  }

  void _onCategorySelected(String path) {
    setState(() {
      _categoryPath = path;
      _step = _PostFlowStep.form;
      if (_marketplacePhotoPaths.isNotEmpty &&
          !_values.containsKey('photos')) {
        _values['photos'] = List<String>.from(_marketplacePhotoPaths);
      } else {
        _values.clear();
      }
      _errors = {};
      _showRestoreBanner = false;
      _pendingDraft = null;
    });
    _initDrafts(path);
    if (widget.vertical == PostVertical.marketplace) {
      final locale = ref.read(appLocaleProvider);
      _refreshMarketplaceDraftInsights(locale);
    }
  }

  void _onValuesChanged(Map<String, dynamic> next) {
    final prevCondition = _values['condition']?.toString();
    setState(() {
      _values
        ..clear()
        ..addAll(next);
      _errors = {};
    });
    _draftManager?.scheduleSave(_values);
    if (widget.vertical == PostVertical.marketplace &&
        prevCondition != next['condition']?.toString()) {
      _refreshMarketplaceDraftInsights(ref.read(appLocaleProvider));
    }
  }

  Future<void> _saveDraft() async {
    await _draftManager?.saveDraft(_values);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostFlowActions.saveDraftLabel(
              widget.vertical,
              ref.read(appLocaleProvider),
            ),
          ),
        ),
      );
    }
  }

  String? _resumeListingId() {
    final data = _pendingDraft?.data;
    if (data == null) return null;
    return PostDraftPublishState.listingId(data) ??
        PostDraftPublishState.publishId(data);
  }

  Future<void> _publish() async {
    final categoryPath = _categoryPath;
    if (categoryPath == null) return;
    if (_publishing) return;
    _publishing = true;

    final locale = ref.read(appLocaleProvider);
    final schema = await ref.read(
      postCategoryFieldSchemaProvider(
        (
          vertical: widget.vertical,
          categoryPath: categoryPath,
          forServiceRequest: _forServiceRequest,
        ),
      ).future,
    );
    final values = _formKey.currentState?.collectValues() ?? _values;
    if (values != _values) {
      setState(() {
        _values
          ..clear()
          ..addAll(values);
      });
    }
    final validation = const PostValidationEngine().validate(
      schema: schema,
      values: values,
      locale: locale,
      debug: true,
      debugVertical: widget.vertical.id,
      debugCategoryPath: categoryPath,
    );
    if (validation.isNotEmpty) {
      PostValidationDebug.logNavigation(
        nextRoute: 'publish',
        allowed: false,
        reason: '${validation.length} validation error(s)',
      );
      setState(() {
        _errors = validation;
        _step = _PostFlowStep.form;
      });
      _publishing = false;
      return;
    }

    PostValidationDebug.logNavigation(nextRoute: 'publish', allowed: true);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostEngineStrings.t('sign_in_required', locale))),
      );
      _publishing = false;
      return;
    }

    if (!_tradeComplianceAcknowledged) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClassifiedsComplianceStrings.t('post_trade_ack_required', locale),
          ),
        ),
      );
      _publishing = false;
      return;
    }

    final verticalSchema = await ref.read(
      postVerticalSchemaProvider(widget.vertical).future,
    );
    final trustReq = PostCategoryTrustRequirements.forPath(
      verticalSchema,
      categoryPath,
    );
    if (trustReq.identityVerificationRequired &&
        !PostIdentityVerification.isVerified(user)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngineStrings.t('trust_identity_required', locale),
          ),
        ),
      );
      _publishing = false;
      return;
    }
    if (trustReq.businessVerificationRequired) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngineStrings.t('trust_business_required', locale),
          ),
        ),
      );
      _publishing = false;
      return;
    }
    if (trustReq.licenseVerificationRequired) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngineStrings.t('trust_license_required', locale),
          ),
        ),
      );
      _publishing = false;
      return;
    }

    if (mounted) setState(() {});

    PostTrustEvaluation trust;
    try {
      trust = await PostPublishTrustGate.evaluate(
        vertical: widget.vertical,
        categoryPath: categoryPath,
        fieldValues: values,
        ownerUserId: user.uid,
        locale: locale,
        resumeListingId: _resumeListingId(),
      );
    } on PostDuplicateCandidateLoadException catch (e) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${PostEngineStrings.t('publish_failed', locale)}: $e'),
        ),
      );
      return;
    }

    if (!trust.allowed) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trust.userMessage)),
      );
      return;
    }
    if (trust.outcome == PostTrustOutcome.reviewRequired && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trust.userMessage)),
      );
    }

    final quality = const PostQualityEngine().evaluate(
      schema: schema,
      values: values,
      locale: locale,
    );
    if (!quality.canPublish) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PostEngineStrings.t('quality_publish_blocked', locale)),
        ),
      );
      return;
    }

    try {
      final postEngine = ref.read(postEngineProvider);
      final draftManager = _draftManager;
      if (draftManager == null) {
        throw StateError('Draft manager not initialized');
      }
      final coordinator = PostPublishCoordinator(
        draftManager: draftManager,
        engine: postEngine.publish,
      );
      final result = await coordinator.publish(
        vertical: widget.vertical,
        categoryPath: categoryPath,
        fieldValues: values,
        ownerUserId: user.uid,
        schema: schema,
        serviceListingType: widget.vertical == PostVertical.services
            ? _serviceListingType
            : ServiceListingType.provider,
        posterIdentityVerified: PostIdentityVerification.isVerified(user),
        tradeComplianceAcknowledged: _tradeComplianceAcknowledged,
      );

      if (result.shouldEmitSideEffects) {
        PostEngine().lifecycle.initialState(requiresReview: false);
        PostEngine().analytics.trackPublish(
          verticalId: widget.vertical.id,
          categoryPath: categoryPath,
          listingId: result.listingId,
          userId: user.uid,
        );
        unawaited(
          ref.read(savedSearchMatchClientProvider).triggerMatch(
                vertical: SavedSearchVertical.fromStorage(widget.vertical.id)!,
                listingId: result.listingId,
                publisherUserId: user.uid,
              ),
        );
      }
      if (widget.vertical == PostVertical.marketplace) {
        ref.invalidate(marketplaceListingsProvider);
      }
      if (widget.vertical == PostVertical.services) {
        ref.invalidate(recentServiceListingsProvider);
      }
      if (!mounted) return;
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostEngineStrings.t('publish_success', locale))),
        );
        context.pop();
      } else if (result.isPartialMedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              PostEngineStrings.t('publish_media_incomplete', locale),
            ),
          ),
        );
      }
    } on PostPublishInFlightException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostEngineStrings.t('publish_in_flight', locale))),
        );
      }
    } on PostPublishMediaException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostEngineStrings.t('publish_missing_photos', locale)),
          ),
        );
      }
    } on PostPublishOwnershipException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostEngineStrings.t('publish_ownership_denied', locale)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${PostEngineStrings.t('publish_failed', locale)}: $e',
            ),
          ),
        );
      }
    } finally {
      _publishing = false;
      if (mounted) setState(() {});
    }
  }

  void _restoreDraft() {
    final data = _pendingDraft?.data;
    if (data == null) return;
    final restored = Map<String, dynamic>.from(data)
      ..remove('_vertical')
      ..remove('_categoryPath')
      ..remove('_schemaVersion');
    setState(() {
      _values
        ..clear()
        ..addAll(restored);
      _showRestoreBanner = false;
    });
  }

  Widget _flowShell({
    required String locale,
    required Widget body,
    String? subtitle,
    Widget? headerTrailing,
  }) {
    if (widget.vertical == PostVertical.services) {
      return PostFlowServicesHubShell(
        locale: locale,
        subtitle: subtitle,
        headerTrailing: headerTrailing,
        child: body,
      );
    }
    if (widget.vertical == PostVertical.marketplace) {
      return PostFlowMarketplaceHubShell(
        locale: locale,
        subtitle: subtitle,
        headerTrailing: headerTrailing,
        child: body,
      );
    }
    return GlassScreenScaffold(
      title: PostFlowActions.flowTitle(widget.vertical, locale),
      actions: headerTrailing != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: headerTrailing,
              ),
            ]
          : null,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);

    if (_step == _PostFlowStep.listingType) {
      return _flowShell(
        locale: locale,
        body: PostServiceListingTypeStep(
          locale: locale,
          totalSteps: _wizardSteps,
          onSelected: _onListingTypeSelected,
        ),
      );
    }

    if (_step == _PostFlowStep.requestAiEntry && _forServiceRequest) {
      return _flowShell(
        locale: locale,
        subtitle: PostEngineStrings.t('flow_subtitle_service_request', locale),
        body: PostServiceRequestAiEntryStep(
          locale: locale,
          controller: _requestAiController,
          analyzing: _requestAiAnalyzing,
          totalSteps: _wizardSteps,
          onAnalyze: () => _analyzeServiceRequest(locale),
          onManual: _goToManualCategory,
        ),
      );
    }

    if (_step == _PostFlowStep.requestAiConfirm &&
        _requestAiExtraction != null) {
      final extraction = _requestAiExtraction!;
      return _flowShell(
        locale: locale,
        subtitle: PostEngineStrings.t('flow_subtitle_service_request', locale),
        body: PostServiceRequestAiConfirmStep(
          locale: locale,
          totalSteps: _wizardSteps,
          categoryPath: extraction.categoryPath,
          categoryLabel: _requestAiCategoryLabel ?? extraction.categoryPath,
          fieldValues: extraction.fieldValues,
          onConfirm: _applyServiceRequestAi,
          onReject: _goToManualCategory,
        ),
      );
    }

    if (_step == _PostFlowStep.photoFirst &&
        widget.vertical == PostVertical.marketplace) {
      return PostFlowMarketplaceHubShell(
        locale: locale,
        child: PostMarketplacePhotoFirstStep(
          locale: locale,
          totalSteps: _wizardSteps,
          mediaEngine: _marketplaceMediaEngine,
          initialPhotoPaths: _marketplacePhotoPaths,
          initialHint: _marketplacePhotoHint,
          analyzing: _marketplaceAiAnalyzing,
          onContinue: (paths, hint) =>
              _continueMarketplacePhotos(paths, hint, locale),
          onManualCategory: _goToMarketplaceManualCategory,
          onManualForm: _goToMarketplaceManualForm,
        ),
      );
    }

    if (_step == _PostFlowStep.categoryConfirm &&
        widget.vertical == PostVertical.marketplace &&
        _marketplaceCategoryLabel != null) {
      return PostFlowMarketplaceHubShell(
        locale: locale,
        child: PostMarketplaceCategoryConfirmStep(
          locale: locale,
          totalSteps: _wizardSteps,
          categoryLabel: _marketplaceCategoryLabel!,
          onConfirm: () => _confirmMarketplaceCategory(locale),
          onChangeCategory: _goToMarketplaceManualCategory,
        ),
      );
    }

    if (_step == _PostFlowStep.category) {
      return _flowShell(
        locale: locale,
        subtitle: PostEngineStrings.t('pick_category', locale),
        body: PostCombinedCategoryStep(
          vertical: widget.vertical,
          locale: locale,
          totalSteps: _wizardSteps,
          serviceListingType: widget.vertical == PostVertical.services
              ? _serviceListingType
              : null,
          onCategorySelected: _onCategorySelected,
        ),
      );
    }

    final categoryPath = _categoryPath!;
    final schemaAsync = ref.watch(
      postCategoryFieldSchemaProvider(
        (
          vertical: widget.vertical,
          categoryPath: categoryPath,
          forServiceRequest: _forServiceRequest,
        ),
      ),
    );

    return _flowShell(
      locale: locale,
      subtitle: _categoryPath,
      headerTrailing:
          DraftSavedIndicator(lastSavedAt: _lastSavedAt, locale: locale),
      body: schemaAsync.when(
        loading: () {
          if (widget.vertical == PostVertical.business ||
              widget.vertical == PostVertical.housing ||
              widget.vertical == PostVertical.services ||
              widget.vertical == PostVertical.marketplace) {
            return const PostFlowHubLoading();
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassErrorState(
              message: PostEngineStrings.t('schema_load_error', locale),
              onRetry: () => ref.invalidate(
                postCategoryFieldSchemaProvider(
                  (
                    vertical: widget.vertical,
                    categoryPath: categoryPath,
                    forServiceRequest: _forServiceRequest,
                  ),
                ),
              ),
              retryLabel: CommonActionStrings.t('action_retry', locale),
            ),
          ),
        ),
        data: (schema) {
          final mediaEngine = PostMediaEngine();
          final photoTips = mediaEngine.photoRecommendations(
            vertical: widget.vertical,
            categoryPath: categoryPath,
          );
          final quality = const PostQualityEngine().evaluate(
            schema: schema,
            values: _values,
            locale: locale,
            photoRecommendations: photoTips,
          );
          final verticalSchemaAsync =
              ref.watch(postVerticalSchemaProvider(widget.vertical));
          final trustReq = verticalSchemaAsync.maybeWhen(
            data: (verticalSchema) => PostCategoryTrustRequirements.forPath(
              verticalSchema,
              categoryPath,
            ),
            orElse: () => const PostCategoryTrustRequirements(),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              if (widget.vertical == PostVertical.business ||
                  widget.vertical == PostVertical.services) ...[
                HubNoticeBanner.hostNotice(locale: locale),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_showRestoreBanner)
                DraftRestoreBanner(
                  savedAt: _pendingDraft!.savedAt,
                  onRestore: _restoreDraft,
                  onDiscard: () async {
                    await _draftManager?.clearDraft();
                    if (!mounted) return;
                    setState(() {
                      _showRestoreBanner = false;
                      _pendingDraft = null;
                    });
                  },
                ),
              if (_step == _PostFlowStep.form)
                PostFlowStepIndicator(
                  currentStep: 2,
                  totalSteps: _wizardSteps,
                  stepLabelKey: 'flow_step_details',
                  locale: locale,
                ),
              const SizedBox(height: AppSpacing.md),
              if (_step == _PostFlowStep.form &&
                  trustReq.hasAnyRequirement) ...[
                PostCategoryVerificationBanner(
                  requirements: trustReq,
                  locale: locale,
                ),
              ],
              if (_step == _PostFlowStep.form &&
                  widget.vertical == PostVertical.marketplace) ...[
                PostMarketplaceDraftInsightsPanel(
                  locale: locale,
                  priceSuggestion: _marketplacePriceSuggestion,
                  priceGrounded: _marketplacePriceGrounded,
                  showUngroundedFallback: _marketplacePriceShowFallback,
                  resellerNudgeKey: _marketplaceResellerNudgeKey,
                ),
              ],
              if (_step == _PostFlowStep.form) ...[
                PostSchemaForm(
                  key: _formKey,
                  schema: schema,
                  values: _values,
                  locale: locale,
                  errors: _errors,
                  mediaEngine: mediaEngine,
                  onChanged: _onValuesChanged,
                ),
                if (widget.vertical == PostVertical.business) ...[
                  const SizedBox(height: AppSpacing.lg),
                  BusinessContactModePicker(
                    locale: locale,
                    value: BusinessContactModeX.fromStorage(
                      _values['contactMode']?.toString(),
                    ),
                    onChanged: (mode) {
                      setState(() {
                        _values['contactMode'] = mode.storageValue;
                      });
                      _draftManager?.scheduleSave(_values);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PostQualityPanel(score: quality, locale: locale),
              ] else
                PostVerticalPreview(
                  vertical: widget.vertical,
                  categoryPath: categoryPath,
                  values: _values,
                  locale: locale,
                ),
              const SizedBox(height: AppSpacing.xl),
              if (_step == _PostFlowStep.form) ...[
                GlassSecondaryButton(
                  label: PostFlowActions.previewLabel(widget.vertical, locale),
                  onPressed: _values.isEmpty
                      ? null
                      : () => setState(() => _step = _PostFlowStep.preview),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassSecondaryButton(
                  label: PostFlowActions.saveDraftLabel(widget.vertical, locale),
                  onPressed: _saveDraft,
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostFlowActions.publishLabel(widget.vertical, locale),
                  onPressed:
                      quality.canPublish && !_publishing ? _publish : null,
                ),
              ] else if (_step == _PostFlowStep.preview) ...[
                CheckboxListTile(
                  value: _tradeComplianceAcknowledged,
                  onChanged: (v) => setState(
                    () => _tradeComplianceAcknowledged = v ?? false,
                  ),
                  title: Text(
                    ClassifiedsComplianceStrings.t('post_trade_ack_label', locale),
                    style: AppTypography.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                GlassSecondaryButton(
                  label: PostEngineStrings.t('action_back_to_edit', locale),
                  onPressed: () => setState(() => _step = _PostFlowStep.form),
                ),
                if (MonetizationState.showPremiumTierUi) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GlassSecondaryButton(
                    label: PostEngineStrings.t('action_choose_visibility', locale),
                    onPressed: () =>
                        setState(() => _step = _PostFlowStep.visibility),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostFlowActions.publishLabel(widget.vertical, locale),
                  onPressed:
                      quality.canPublish && !_publishing ? _publish : null,
                ),
              ] else if (MonetizationState.showPremiumTierUi) ...[
                GlassSecondaryButton(
                  label: PostEngineStrings.t('action_skip_visibility', locale),
                  onPressed:
                      quality.canPublish && !_publishing ? _publish : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostEngineStrings.t('action_choose_visibility', locale),
                  onPressed: quality.canPublish && !_publishing
                      ? () async {
                          final title = _values['title']?.toString() ??
                              _values['brand']?.toString() ??
                              PostEngineStrings.t('preview_untitled', locale);
                          await context.push(
                            '/boost-listing',
                            extra: {
                              'title': title,
                              'views': 0,
                              'contacts': 0,
                              'id': 'draft',
                            },
                          );
                          if (mounted) await _publish();
                        }
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
