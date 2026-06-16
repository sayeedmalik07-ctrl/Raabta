import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  static const List<String> _filters = [
    'Upcoming',
    'This Week',
    'Free',
    'Sports',
    'Cultural',
  ];

  int _selectedFilter = 0;

  static const List<_EventItem> _events = [
    _EventItem(
      emoji: '🏏',
      title: 'Indian Cricket Tournament - Al Khor',
      dateTime: 'Friday 20 June · 7:00 AM',
      location: 'Al Khor Sports Complex',
      organizerFlag: '🇮🇳',
      organizerName: 'Indians in Qatar',
      attendees: 234,
      isFree: true,
      tags: ['Upcoming', 'This Week', 'Free', 'Sports'],
    ),
    _EventItem(
      emoji: '🎤',
      title: 'Pakistani Cultural Night',
      dateTime: 'Saturday 21 June · 7:00 PM',
      location: 'Grand Hyatt Doha',
      organizerFlag: '🇵🇰',
      organizerName: 'Pakistanis in Qatar',
      attendees: 89,
      isFree: false,
      price: '50 QR',
      tags: ['Upcoming', 'This Week', 'Cultural'],
    ),
    _EventItem(
      emoji: '💼',
      title: 'Expat Business Networking',
      dateTime: 'Sunday 22 June · 6:00 PM',
      location: 'W Hotel Doha',
      organizerFlag: '🌍',
      organizerName: 'Qatar Expat Network',
      attendees: 156,
      isFree: true,
      tags: ['Upcoming', 'This Week', 'Free'],
    ),
  ];

  List<_EventItem> get _filteredEvents {
    final filter = _filters[_selectedFilter];
    if (filter == 'Upcoming') return _events;
    return _events.where((e) => e.tags.contains(filter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

    return ColoredBox(
      color: _backgroundColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, widget.embedded ? 16 : 16, 20, 24),
        children: [
          if (!widget.embedded)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(child: _Header()),
              ],
            )
          else
            const _Header(),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return FilterChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = index),
                  backgroundColor: _surfaceColor,
                  selectedColor: _cyanColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? _cyanColor : _subtitleColor,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? _cyanColor : Colors.transparent,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No events match this filter',
                  style: TextStyle(color: _subtitleColor),
                ),
              ),
            )
          else
            ...events.map((event) => _EventCard(event: event)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎉 Events & Meetups',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Connect with your community',
          style: TextStyle(color: _subtitleColor, fontSize: 14),
        ),
      ],
    );
  }
}

class _EventItem {
  const _EventItem({
    required this.emoji,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.organizerFlag,
    required this.organizerName,
    required this.attendees,
    required this.isFree,
    required this.tags,
    this.price,
  });

  final String emoji;
  final String title;
  final String dateTime;
  final String location;
  final String organizerFlag;
  final String organizerName;
  final int attendees;
  final bool isFree;
  final String? price;
  final List<String> tags;
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final _EventItem event;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _freeGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📅 ${event.dateTime}',
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${event.location}',
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event.isFree
                      ? _freeGreen.withValues(alpha: 0.15)
                      : _cyanColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event.isFree ? 'Free' : event.price ?? 'Paid',
                  style: TextStyle(
                    color: event.isFree ? _freeGreen : _cyanColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(event.organizerFlag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                event.organizerName,
                style: const TextStyle(color: _subtitleColor, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${event.attendees} going',
                style: const TextStyle(color: _subtitleColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _cyanColor,
                foregroundColor: _backgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Join Event',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
