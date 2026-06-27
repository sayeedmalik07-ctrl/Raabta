import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';

enum RsvpStatus { none, going, interested, notGoing }

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const List<String> _filters = [
    'Upcoming',
    'This Week',
    'Free',
    'Sports',
    'Cultural',
  ];

  int _selectedFilter = 0;
  int _selectedDateIndex = 0;
  final Map<int, RsvpStatus> _rsvpStatus = {};

  static const List<_EventItem> _events = [
    _EventItem(
      id: 0,
      emoji: '🏏',
      title: 'Indian Cricket Tournament - Al Khor',
      dateTime: 'Friday 20 June · 7:00 AM',
      dateLabel: 'Fri 20',
      location: 'Al Khor Sports Complex',
      organizerFlag: '🇮🇳',
      organizerName: 'Indians in Qatar',
      attendees: 234,
      isFree: true,
      tags: ['Upcoming', 'This Week', 'Free', 'Sports'],
      attendeeInitials: ['RM', 'AK', 'SP', 'HK'],
    ),
    _EventItem(
      id: 1,
      emoji: '🎤',
      title: 'Pakistani Cultural Night',
      dateTime: 'Saturday 21 June · 7:00 PM',
      dateLabel: 'Sat 21',
      location: 'Grand Hyatt Doha',
      organizerFlag: '🇵🇰',
      organizerName: 'Pakistanis in Qatar',
      attendees: 89,
      isFree: false,
      price: '50 QR',
      tags: ['Upcoming', 'This Week', 'Cultural'],
      attendeeInitials: ['PK', 'MN', 'QR'],
    ),
    _EventItem(
      id: 2,
      emoji: '💼',
      title: 'Expat Business Networking',
      dateTime: 'Sunday 22 June · 6:00 PM',
      dateLabel: 'Sun 22',
      location: 'W Hotel Doha',
      organizerFlag: '🌍',
      organizerName: 'Qatar Expat Network',
      attendees: 156,
      isFree: true,
      tags: ['Upcoming', 'This Week', 'Free'],
      attendeeInitials: ['EN', 'BK', 'CV', 'FL'],
    ),
  ];

  static const List<String> _calendarDates = [
    'Thu 19',
    'Fri 20',
    'Sat 21',
    'Sun 22',
    'Mon 23',
    'Tue 24',
  ];

  List<_EventItem> get _filteredEvents {
    final filter = _filters[_selectedFilter];
    if (filter == 'Upcoming') return _events;
    return _events.where((e) => e.tags.contains(filter)).toList();
  }

  void _setRsvp(int eventId, RsvpStatus status) {
    setState(() {
      _rsvpStatus[eventId] = _rsvpStatus[eventId] == status ? RsvpStatus.none : status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          widget.embedded ? AppSpacing.lg : AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          if (!widget.embedded)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                const Expanded(child: _Header()),
              ],
            )
          else
            const _Header(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _calendarDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final selected = _selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    width: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      _calendarDates[index],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return FilterChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = index),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Text(
                  'No events match this filter',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ...events.map(
              (event) => _EventCard(
                event: event,
                rsvp: _rsvpStatus[event.id] ?? RsvpStatus.none,
                onRsvp: _setRsvp,
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎉 Events & Meetups', style: AppTextStyles.h2),
        Text('Connect with your community', style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _EventItem {
  const _EventItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.dateTime,
    required this.dateLabel,
    required this.location,
    required this.organizerFlag,
    required this.organizerName,
    required this.attendees,
    required this.isFree,
    required this.tags,
    required this.attendeeInitials,
    this.price,
  });

  final int id;
  final String emoji;
  final String title;
  final String dateTime;
  final String dateLabel;
  final String location;
  final String organizerFlag;
  final String organizerName;
  final int attendees;
  final bool isFree;
  final String? price;
  final List<String> tags;
  final List<String> attendeeInitials;
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.rsvp,
    required this.onRsvp,
  });

  final _EventItem event;
  final RsvpStatus rsvp;
  final void Function(int eventId, RsvpStatus status) onRsvp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A2535), Color(0xFF0D1520)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(event.emoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.sm),
                          Text('📅 ${event.dateTime}', style: AppTextStyles.bodyMedium),
                          Text('📍 ${event.location}', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        event.isFree ? 'Free' : event.price ?? 'Paid',
                        style: TextStyle(
                          color: event.isFree ? AppColors.success : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(event.organizerFlag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(event.organizerName, style: AppTextStyles.bodyMedium),
                    const Spacer(),
                    ...event.attendeeInitials.take(3).map(
                      (initials) => Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.surfaceElevated,
                          child: Text(
                            initials,
                            style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${event.attendees} going', style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _RsvpChip(
                        label: rsvp == RsvpStatus.going ? 'Going ✓' : 'Going',
                        selected: rsvp == RsvpStatus.going,
                        onTap: () => onRsvp(event.id, RsvpStatus.going),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _RsvpChip(
                        label: 'Interested',
                        selected: rsvp == RsvpStatus.interested,
                        onTap: () => onRsvp(event.id, RsvpStatus.interested),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _RsvpChip(
                        label: 'Not Going',
                        selected: rsvp == RsvpStatus.notGoing,
                        onTap: () => onRsvp(event.id, RsvpStatus.notGoing),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpChip extends StatelessWidget {
  const _RsvpChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
