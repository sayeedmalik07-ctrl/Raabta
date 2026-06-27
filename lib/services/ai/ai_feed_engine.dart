import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/housing_match_service.dart';
import 'package:raabta/services/ai/job_match_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum FeedCardType {
  jobRecommendation,
  housingRecommendation,
  exchangeRate,
  visaUpdate,
  communityEvent,
  businessOffer,
  governmentAnnouncement,
  scoreSuggestion,
  referralPrompt,
  sponsored,
  welcomeMessage,
}

class AIFeedCard {
  const AIFeedCard({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaRoute,
    required this.borderColor,
    required this.icon,
    this.isSponsored = false,
    this.sponsorLabel,
    this.data = const {},
    required this.createdAt,
  });

  final String id;
  final FeedCardType type;
  final int priority;
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaRoute;
  final Color borderColor;
  final String icon;
  final bool isSponsored;
  final String? sponsorLabel;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority,
        'title': title,
        'subtitle': subtitle,
        'ctaText': ctaText,
        'ctaRoute': ctaRoute,
        'borderColor': borderColor.toARGB32(),
        'icon': icon,
        'isSponsored': isSponsored,
        'sponsorLabel': sponsorLabel,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AIFeedCard.fromJson(Map<String, dynamic> json) {
    return AIFeedCard(
      id: json['id'] as String? ?? '',
      type: FeedCardType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => FeedCardType.welcomeMessage,
      ),
      priority: json['priority'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      ctaText: json['ctaText'] as String? ?? '',
      ctaRoute: json['ctaRoute'] as String? ?? '/',
      borderColor: Color(json['borderColor'] as int? ?? 0xFF22D3EE),
      icon: json['icon'] as String? ?? '✨',
      isSponsored: json['isSponsored'] as bool? ?? false,
      sponsorLabel: json['sponsorLabel'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AIFeedResult {
  const AIFeedResult({
    required this.cards,
    required this.generatedAt,
    this.isFromCache = false,
    this.cacheNote,
  });

  final List<AIFeedCard> cards;
  final DateTime generatedAt;
  final bool isFromCache;
  final String? cacheNote;

  AIFeedResult copyWith({
    List<AIFeedCard>? cards,
    DateTime? generatedAt,
    bool? isFromCache,
    String? cacheNote,
  }) {
    return AIFeedResult(
      cards: cards ?? this.cards,
      generatedAt: generatedAt ?? this.generatedAt,
      isFromCache: isFromCache ?? this.isFromCache,
      cacheNote: cacheNote ?? this.cacheNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory AIFeedResult.fromJson(Map<String, dynamic> json) {
    final cardsRaw = json['cards'] as List? ?? [];
    return AIFeedResult(
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
      cards: cardsRaw
          .map((c) => AIFeedCard.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

class AIFeedEngine {
  AIFeedEngine({
    FirebaseFirestore? firestore,
    this._prefs,
    JobMatchService? jobMatchService,
    HousingMatchService? housingMatchService,
    ExpatLifeScoreService? scoreService,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _jobMatchService = jobMatchService ?? JobMatchService(),
        _housingMatchService = housingMatchService ?? HousingMatchService(),
        _scoreService = scoreService ?? ExpatLifeScoreService();

  static const _cacheDuration = Duration(hours: 4);

  static const Color _purple = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF22D3EE);
  static const Color _green = Color(0xFF34D399);
  static const Color _amber = Color(0xFFFBBF24);
  static const Color _pink = Color(0xFFF472B6);
  static const Color _gold = Color(0xFFFFB800);

  final FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;
  final JobMatchService _jobMatchService;
  final HousingMatchService _housingMatchService;
  final ExpatLifeScoreService _scoreService;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  String _cacheKey(String uid) => 'ai_feed_cache_$uid';

  /// Generates or returns cached daily feed (4-hour TTL).
  Future<AIFeedResult> generateDailyFeed(UserAIProfile profile) async {
    final cached = await _loadCache(profile.uid);
    if (cached != null && !_isCacheExpired(cached.generatedAt)) {
      return cached.copyWith(isFromCache: true);
    }

    try {
      final feed = await _buildFeed(profile);
      await _saveCache(profile.uid, feed);
      return feed;
    } catch (e) {
      debugPrint('AIFeedEngine: feed generation failed — $e');
      if (cached != null) {
        return cached.copyWith(
          isFromCache: true,
          cacheNote: 'Last updated ${_formatRelativeTime(cached.generatedAt)}',
        );
      }
      return AIFeedResult(
        cards: [_welcomeCard(profile)],
        generatedAt: DateTime.now(),
        cacheNote: 'Showing offline welcome feed',
      );
    }
  }

  /// Forces feed regeneration and updates cache.
  Future<AIFeedResult> refreshFeed(UserAIProfile profile) async {
    final feed = await _buildFeed(profile);
    await _saveCache(profile.uid, feed);
    return feed;
  }

  Future<AIFeedResult> _buildFeed(UserAIProfile profile) async {
    final now = DateTime.now();
    final organic = <AIFeedCard>[];

    final jobCard = await _buildJobCard(profile, now);
    if (jobCard != null) organic.add(jobCard);

    final housingCard = await _buildHousingCard(profile, now);
    if (housingCard != null) organic.add(housingCard);

    final exchangeCard = await _buildExchangeRateCard(profile, now);
    if (exchangeCard != null) organic.add(exchangeCard);

    final visaCard = await _buildVisaUpdateCard(profile, now);
    if (visaCard != null) organic.add(visaCard);

    final eventCard = await _buildCommunityEventCard(profile, now);
    if (eventCard != null) organic.add(eventCard);

    final businessCards = await _buildBusinessOfferCards(profile, now);
    organic.addAll(businessCards);

    final govCards = await _buildGovernmentAnnouncementCards(profile, now);
    organic.addAll(govCards);

    final scoreCard = await _buildScoreSuggestionCard(profile, now);
    if (scoreCard != null) organic.add(scoreCard);

    final referralCard = await _buildReferralPromptCard(profile, now);
    if (referralCard != null) organic.add(referralCard);

    if (organic.isEmpty) {
      organic.add(_welcomeCard(profile));
    }

    organic.sort((a, b) => b.priority.compareTo(a.priority));

    final sponsored = await _fetchSponsoredCards(now);
    final merged = _interleaveSponsored(organic, sponsored);

    return AIFeedResult(cards: merged, generatedAt: now);
  }

  // -------------------------------------------------------------------------
  // Card builders
  // -------------------------------------------------------------------------

  Future<AIFeedCard?> _buildJobCard(UserAIProfile profile, DateTime now) async {
    final jobs = await _fetchJobs(limit: 20);
    if (jobs.isEmpty) return null;

    final ranked = _jobMatchService
        .rankJobs(jobs, profile)
        .where((r) => r.result.matchScore >= 70)
        .take(3)
        .toList();

    if (ranked.isEmpty) return null;

    final top = ranked.first;
    final topTitle = top.job['title']?.toString() ?? 'Recommended role';
    final company = top.job['company']?.toString() ?? 'Qatar employer';
    final match = top.result.matchScore;

    return AIFeedCard(
      id: 'job_rec_${now.millisecondsSinceEpoch}',
      type: FeedCardType.jobRecommendation,
      priority: 9,
      title: '💼 ${ranked.length} jobs match your profile',
      subtitle:
          'Best: $topTitle at $company — $match% match',
      ctaText: 'View Jobs',
      ctaRoute: '/jobs',
      borderColor: _purple,
      icon: '💼',
      data: {
        'jobIds': ranked.map((r) => r.result.jobId).toList(),
        'topMatchScore': match,
      },
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildHousingCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final listings = await _fetchListings(
      area: profile.preferredArea,
      since: now.subtract(const Duration(hours: 24)),
    );
    if (listings.isEmpty) return null;

    final ranked = _housingMatchService.rankListings(listings, profile);
    if (ranked.isEmpty) return null;

    final top = ranked.first;
    final listing = top.listing;
    final propertyType = listing['type']?.toString() ??
        listing['propertyType']?.toString() ??
        'Property';
    final price = listing['pricePerMonth'] ?? listing['price'] ?? 0;
    final match = top.result.matchScore;
    final area = profile.preferredArea;

    return AIFeedCard(
      id: 'housing_rec_${now.millisecondsSinceEpoch}',
      type: FeedCardType.housingRecommendation,
      priority: 8,
      title: '🏠 ${listings.length} new rooms in $area',
      subtitle:
          'Best match: $propertyType at $price QR/month — $match%',
      ctaText: 'View Housing',
      ctaRoute: '/housing',
      borderColor: _cyan,
      icon: '🏠',
      data: {
        'listingIds': ranked.take(3).map((r) => r.result.listingId).toList(),
        'topMatchScore': match,
      },
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildExchangeRateCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final rates = await _fetchExchangeRates();
    if (rates == null) return null;

    final todayInr = rates['todayInr'] as num?;
    final yesterdayInr = rates['yesterdayInr'] as num?;
    if (todayInr == null) return null;

    final change = yesterdayInr != null ? todayInr - yesterdayInr : 0;
    final absChange = change.abs();
    final direction = change >= 0 ? 'increased' : 'decreased';
    final arrow = change >= 0 ? '↑' : '↓';
    final priority = absChange > 0.05 ? 9 : 7;

    return AIFeedCard(
      id: 'exchange_${now.millisecondsSinceEpoch}',
      type: FeedCardType.exchangeRate,
      priority: priority,
      title: '💰 INR rate $direction today',
      subtitle:
          '1 QR = ${todayInr.toStringAsFixed(2)} INR $arrow${absChange.toStringAsFixed(2)}',
      ctaText: 'Check Rates',
      ctaRoute: '/money',
      borderColor: _green,
      icon: '💰',
      data: {
        'currency': 'INR',
        'rate': todayInr,
        'change': change,
      },
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildVisaUpdateCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final update = await _fetchLatestVisaUpdate(
      since: now.subtract(const Duration(days: 7)),
    );
    if (update == null) return null;

    final title = update['title']?.toString() ?? 'Visa policy update';
    final date = _formatDate(
      _parseDate(update['publishedAt'] ?? update['createdAt']),
    );

    return AIFeedCard(
      id: 'visa_${update['id'] ?? now.millisecondsSinceEpoch}',
      type: FeedCardType.visaUpdate,
      priority: 10,
      title: '📋 New Qatar visa update',
      subtitle: '$title — $date',
      ctaText: 'Read Update',
      ctaRoute: '/visa',
      borderColor: _amber,
      icon: '📋',
      data: Map<String, dynamic>.from(update),
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildCommunityEventCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final events = await _fetchEvents(
      area: profile.preferredArea,
      nationality: profile.nationality,
      until: now.add(const Duration(days: 7)),
    );
    if (events.isEmpty) return null;

    final event = events.first;
    final name = event['name']?.toString() ?? event['title']?.toString() ?? 'Community event';
    final location = event['location']?.toString() ?? profile.preferredArea;
    final community = event['community']?.toString() ?? profile.nationality;
    final priceLabel = event['isFree'] == true || event['price'] == 0
        ? 'Free'
        : '${event['price'] ?? ''} QR';
    final eventDate = _parseDate(event['date'] ?? event['startDate']);
    final dayLabel = _formatEventDay(eventDate, now);

    return AIFeedCard(
      id: 'event_${event['id'] ?? now.millisecondsSinceEpoch}',
      type: FeedCardType.communityEvent,
      priority: 6,
      title: '🎉 $name this $dayLabel',
      subtitle: '$location · $community Community · $priceLabel',
      ctaText: 'Join Event',
      ctaRoute: '/community/events',
      borderColor: _pink,
      icon: '🎉',
      data: Map<String, dynamic>.from(event),
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildScoreSuggestionCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    if (await _scoreSuggestionShownToday(profile.uid)) return null;

    final actions = _scoreService.getImprovementActions(profile);
    if (actions.isEmpty) return null;

    final action = actions.first;
    await _markScoreSuggestionShown(profile.uid);

    return AIFeedCard(
      id: 'score_${now.millisecondsSinceEpoch}',
      type: FeedCardType.scoreSuggestion,
      priority: 5,
      title: '⭐ Improve your Expat Score by +${action.pointsGain} points',
      subtitle: action.description,
      ctaText: action.title,
      ctaRoute: '/expat-score',
      borderColor: _gold,
      icon: '⭐',
      data: action.toJson(),
      createdAt: now,
    );
  }

  Future<AIFeedCard?> _buildReferralPromptCard(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final referralCount = _referralCount(profile);
    if (referralCount >= 3) return null;

    final lastShown = await _referralLastShown(profile.uid);
    if (lastShown != null &&
        now.difference(lastShown) < const Duration(days: 7)) {
      return null;
    }

    await _markReferralShown(profile.uid);

    return AIFeedCard(
      id: 'referral_${now.millisecondsSinceEpoch}',
      type: FeedCardType.referralPrompt,
      priority: 3,
      title: '👥 Invite friends, earn 50 points each',
      subtitle:
          "You've invited $referralCount friends. ${5 - referralCount} more to unlock Premium free!",
      ctaText: 'Share Raabta',
      ctaRoute: '/profile',
      borderColor: _purple,
      icon: '👥',
      data: {'referralCount': referralCount},
      createdAt: now,
    );
  }

  Future<List<AIFeedCard>> _buildBusinessOfferCards(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final offers = await _fetchCollectionDocs(
      'business_offers',
      limit: 2,
    );
    return offers.map((offer) {
      return AIFeedCard(
        id: 'biz_${offer['id']}',
        type: FeedCardType.businessOffer,
        priority: 6,
        title: offer['title']?.toString() ?? '🏪 Business offer near you',
        subtitle: offer['subtitle']?.toString() ?? '',
        ctaText: offer['ctaText']?.toString() ?? 'View Offer',
        ctaRoute: offer['ctaRoute']?.toString() ?? '/businesses',
        borderColor: _amber,
        icon: offer['icon']?.toString() ?? '🏪',
        data: Map<String, dynamic>.from(offer),
        createdAt: now,
      );
    }).toList();
  }

  Future<List<AIFeedCard>> _buildGovernmentAnnouncementCards(
    UserAIProfile profile,
    DateTime now,
  ) async {
    final announcements = await _fetchCollectionDocs(
      'government_announcements',
      limit: 1,
    );
    return announcements.map((item) {
      return AIFeedCard(
        id: 'gov_${item['id']}',
        type: FeedCardType.governmentAnnouncement,
        priority: 8,
        title: item['title']?.toString() ?? '🏛️ Government announcement',
        subtitle: item['subtitle']?.toString() ?? '',
        ctaText: item['ctaText']?.toString() ?? 'Learn More',
        ctaRoute: item['ctaRoute']?.toString() ?? '/news',
        borderColor: _amber,
        icon: item['icon']?.toString() ?? '🏛️',
        data: Map<String, dynamic>.from(item),
        createdAt: now,
      );
    }).toList();
  }

  AIFeedCard _welcomeCard(UserAIProfile profile) {
    final now = DateTime.now();
    return AIFeedCard(
      id: 'welcome_${profile.uid}',
      type: FeedCardType.welcomeMessage,
      priority: 4,
      title: '👋 Welcome back to Raabta',
      subtitle: 'Your personalized Qatar expat feed is ready',
      ctaText: 'Explore',
      ctaRoute: '/home',
      borderColor: _cyan,
      icon: '👋',
      createdAt: now,
    );
  }

  // -------------------------------------------------------------------------
  // Firestore fetchers
  // -------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _fetchJobs({int limit = 20}) async {
    if (_firestore == null) return _fallbackJobs();

    try {
      final snapshot = await _firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) return _fallbackJobs();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('AIFeedEngine: jobs fetch failed — $e');
      return _fallbackJobs();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchListings({
    required String area,
    required DateTime since,
  }) async {
    if (_firestore == null) return _fallbackListings(area);

    try {
      Query<Map<String, dynamic>> query = _firestore.collection('listings');

      if (area.isNotEmpty) {
        query = query.where('area', isEqualTo: area);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      var listings = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      listings = listings.where((listing) {
        final created = _parseDate(listing['createdAt'] ?? listing['postedAt']);
        if (created == null) {
          final daysAgo = listing['daysAgo'];
          return daysAgo is num && daysAgo < 1;
        }
        return created.isAfter(since);
      }).toList();

      if (listings.isEmpty) return _fallbackListings(area);
      return listings;
    } catch (e) {
      debugPrint('AIFeedEngine: listings fetch failed — $e');
      return _fallbackListings(area);
    }
  }

  Future<Map<String, dynamic>?> _fetchExchangeRates() async {
    if (_firestore == null) {
      return {'todayInr': 22.85, 'yesterdayInr': 22.78};
    }

    try {
      final doc = await _firestore.collection('exchange_rates').doc('INR').get();
      if (!doc.exists) {
        return {'todayInr': 22.85, 'yesterdayInr': 22.78};
      }
      final data = doc.data()!;
      return {
        'todayInr': data['today'] ?? data['rate'],
        'yesterdayInr': data['yesterday'],
      };
    } catch (e) {
      debugPrint('AIFeedEngine: exchange rates fetch failed — $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchLatestVisaUpdate({
    required DateTime since,
  }) async {
    if (_firestore == null) return null;

    try {
      final snapshot = await _firestore
          .collection('visa_updates')
          .orderBy('publishedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = {...doc.data(), 'id': doc.id};
      final published = _parseDate(data['publishedAt'] ?? data['createdAt']);
      if (published != null && published.isBefore(since)) return null;
      return data;
    } catch (e) {
      debugPrint('AIFeedEngine: visa updates fetch failed — $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEvents({
    required String area,
    required String nationality,
    required DateTime until,
  }) async {
    if (_firestore == null) return _fallbackEvents(area, nationality);

    try {
      final snapshot = await _firestore
          .collection('community_events')
          .where('date', isLessThanOrEqualTo: until.toIso8601String())
          .orderBy('date')
          .limit(10)
          .get();

      var events = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      events = events.where((event) {
        final eventArea = event['area']?.toString().toLowerCase() ?? '';
        final community = event['community']?.toString().toLowerCase() ?? '';
        final areaMatch = area.isEmpty ||
            eventArea.contains(area.toLowerCase()) ||
            area.toLowerCase().contains(eventArea);
        final nationalityMatch = nationality.isEmpty ||
            community.contains(nationality.toLowerCase());
        return areaMatch || nationalityMatch;
      }).toList();

      if (events.isEmpty) return _fallbackEvents(area, nationality);
      return events;
    } catch (e) {
      debugPrint('AIFeedEngine: events fetch failed — $e');
      return _fallbackEvents(area, nationality);
    }
  }

  Future<List<AIFeedCard>> _fetchSponsoredCards(DateTime now) async {
    final docs = await _fetchCollectionDocs('sponsored_feed', limit: 5);
    return docs.map((item) {
      return AIFeedCard(
        id: 'sponsored_${item['id']}',
        type: FeedCardType.sponsored,
        priority: item['priority'] as int? ?? 4,
        title: item['title']?.toString() ?? 'Sponsored',
        subtitle: item['subtitle']?.toString() ?? '',
        ctaText: item['ctaText']?.toString() ?? 'Learn More',
        ctaRoute: item['ctaRoute']?.toString() ?? '/businesses',
        borderColor: Color(item['borderColor'] as int? ?? _gold.toARGB32()),
        icon: item['icon']?.toString() ?? '📢',
        isSponsored: true,
        sponsorLabel: item['sponsorLabel']?.toString() ?? 'SPONSORED',
        data: Map<String, dynamic>.from(item),
        createdAt: now,
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchCollectionDocs(
    String collection, {
    int limit = 5,
  }) async {
    if (_firestore == null) return [];

    try {
      final snapshot = await _firestore
          .collection(collection)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('AIFeedEngine: $collection fetch failed — $e');
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // Sponsored interleaving
  // -------------------------------------------------------------------------

  List<AIFeedCard> _interleaveSponsored(
    List<AIFeedCard> organic,
    List<AIFeedCard> sponsored,
  ) {
    if (sponsored.isEmpty) return organic;

    final result = <AIFeedCard>[];
    var sponsoredIndex = 0;

    for (var i = 0; i < organic.length; i++) {
      result.add(organic[i]);
      if ((i + 1) % 4 == 0 && sponsoredIndex < sponsored.length) {
        result.add(sponsored[sponsoredIndex++]);
      }
    }

    while (sponsoredIndex < sponsored.length) {
      result.add(sponsored[sponsoredIndex++]);
    }

    return result;
  }

  // -------------------------------------------------------------------------
  // Cache & prefs
  // -------------------------------------------------------------------------

  Future<void> _saveCache(String uid, AIFeedResult feed) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_cacheKey(uid), jsonEncode(feed.toJson()));
    } catch (e) {
      debugPrint('AIFeedEngine: cache save failed — $e');
    }
  }

  Future<AIFeedResult?> _loadCache(String uid) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw == null) return null;
      return AIFeedResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('AIFeedEngine: cache load failed — $e');
      return null;
    }
  }

  bool _isCacheExpired(DateTime generatedAt) {
    return DateTime.now().difference(generatedAt) > _cacheDuration;
  }

  Future<bool> _scoreSuggestionShownToday(String uid) async {
    final prefs = await _getPrefs();
    final key = 'feed_score_suggestion_${uid}_${_dateKey(DateTime.now())}';
    return prefs.getBool(key) ?? false;
  }

  Future<void> _markScoreSuggestionShown(String uid) async {
    final prefs = await _getPrefs();
    final key = 'feed_score_suggestion_${uid}_${_dateKey(DateTime.now())}';
    await prefs.setBool(key, true);
  }

  Future<DateTime?> _referralLastShown(String uid) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString('feed_referral_last_shown_$uid');
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> _markReferralShown(String uid) async {
    final prefs = await _getPrefs();
    await prefs.setString(
      'feed_referral_last_shown_$uid',
      DateTime.now().toIso8601String(),
    );
  }

  int _referralCount(UserAIProfile profile) {
    for (final interest in profile.interests) {
      if (interest.startsWith('profile:referral_count:')) {
        return int.tryParse(interest.split(':').last) ?? 0;
      }
    }
    return 0;
  }

  // -------------------------------------------------------------------------
  // Fallback data (offline / empty Firestore)
  // -------------------------------------------------------------------------

  List<Map<String, dynamic>> _fallbackJobs() {
    return [
      {
        'id': 'job_fallback_1',
        'title': 'HSE Officer',
        'company': 'Qatar Energy',
        'requirements': ['NEBOSH', 'Safety', 'HSE'],
        'experience': 3,
        'area': 'Al Khor',
        'salary': 8500,
        'category': 'HSE',
      },
      {
        'id': 'job_fallback_2',
        'title': 'Site Engineer',
        'company': 'Al Jaber Group',
        'requirements': ['Engineering', 'AutoCAD'],
        'experience': 4,
        'area': 'Doha',
        'salary': 12000,
        'category': 'Engineering',
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackListings(String area) {
    final resolvedArea = area.isNotEmpty ? area : 'Al Khor';
    return [
      {
        'id': 'listing_fallback_1',
        'title': 'Room in shared villa',
        'type': 'Room',
        'pricePerMonth': 1200,
        'area': resolvedArea,
        'bedrooms': 1,
        'daysAgo': 0,
        'amenities': ['wifi', 'ac', 'parking'],
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackEvents(String area, String nationality) {
    return [
      {
        'id': 'event_fallback_1',
        'name': 'Community Meetup',
        'location': area.isNotEmpty ? area : 'Al Khor',
        'community': nationality.isNotEmpty ? nationality : 'Expats',
        'isFree': true,
        'date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }

  // -------------------------------------------------------------------------
  // Formatting helpers
  // -------------------------------------------------------------------------

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatEventDay(DateTime? date, DateTime now) {
    if (date == null) return 'week';
    if (_dateKey(date) == _dateKey(now)) return 'today';
    if (_dateKey(date) == _dateKey(now.add(const Duration(days: 1)))) {
      return 'tomorrow';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final aiFeedEngineProvider = Provider<AIFeedEngine>((ref) {
  return AIFeedEngine(
    jobMatchService: ref.watch(jobMatchServiceProvider),
    housingMatchService: ref.watch(housingMatchServiceProvider),
    scoreService: ref.watch(expatLifeScoreServiceProvider),
  );
});

final aiFeedProvider =
    AsyncNotifierProvider<AIFeedNotifier, AIFeedResult>(() {
  return AIFeedNotifier();
});

class AIFeedNotifier extends AsyncNotifier<AIFeedResult> {
  @override
  Future<AIFeedResult> build() async {
    return AIFeedResult(cards: const [], generatedAt: DateTime.now());
  }

  Future<void> load(UserAIProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final engine = ref.read(aiFeedEngineProvider);
      return engine.generateDailyFeed(profile);
    });
  }

  Future<void> refresh(UserAIProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final engine = ref.read(aiFeedEngineProvider);
      return engine.refreshFeed(profile);
    });
  }
}
