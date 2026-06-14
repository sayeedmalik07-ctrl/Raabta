import 'package:flutter/material.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _languageFilters = [
    'All',
    'Urdu',
    'Hindi',
    'Arabic',
    'Tagalog',
  ];

  static const List<String> _specialtyFilters = [
    'All',
    'GP',
    'Dentist',
    'Gynecologist',
    'Pediatrician',
  ];

  int _selectedLanguage = 0;
  int _selectedSpecialty = 0;

  static const List<_Doctor> _doctors = [
    _Doctor(
      name: 'Dr. Rajesh Kumar',
      specialty: 'GP',
      hospital: 'Al Khor Hospital',
      languages: ['Hindi', 'English'],
      flags: ['🇮🇳', '🇬🇧'],
      rating: 4.8,
      area: 'Al Khor',
      initials: 'RK',
    ),
    _Doctor(
      name: 'Dr. Fatima Al-Ali',
      specialty: 'Gynecologist',
      hospital: 'HMC',
      languages: ['Arabic', 'English'],
      flags: ['🇶🇦', '🇬🇧'],
      rating: 4.9,
      area: 'Doha',
      initials: 'FA',
    ),
    _Doctor(
      name: 'Dr. Muhammad Raza',
      specialty: 'Dentist',
      hospital: 'Aster Medical',
      languages: ['Urdu', 'English'],
      flags: ['🇵🇰', '🇬🇧'],
      rating: 4.7,
      area: 'Al Wakrah',
      initials: 'MR',
    ),
    _Doctor(
      name: 'Dr. Maria Santos',
      specialty: 'Pediatrician',
      hospital: 'Al Ahli',
      languages: ['Tagalog', 'English'],
      flags: ['🇵🇭', '🇬🇧'],
      rating: 4.8,
      area: 'Lusail',
      initials: 'MS',
    ),
    _Doctor(
      name: 'Dr. Ahmed Hassan',
      specialty: 'Cardiologist',
      hospital: 'HMC Doha',
      languages: ['Arabic', 'English'],
      flags: ['🇶🇦', '🇬🇧'],
      rating: 4.6,
      area: 'Doha',
      initials: 'AH',
    ),
  ];

  List<_Doctor> get _filteredDoctors {
    final query = _searchController.text.trim().toLowerCase();
    final language = _languageFilters[_selectedLanguage];
    final specialty = _specialtyFilters[_selectedSpecialty];

    return _doctors.where((doctor) {
      final matchesLanguage =
          language == 'All' || doctor.languages.contains(language);
      final matchesSpecialty =
          specialty == 'All' || doctor.specialty == specialty;
      final matchesSearch = query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);
      return matchesLanguage && matchesSpecialty && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Doctor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Doctors who speak your language',
                          style: TextStyle(
                            color: _subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search by name or specialty...',
                  hintStyle: const TextStyle(color: _subtitleColor),
                  prefixIcon: const Icon(Icons.search, color: _subtitleColor),
                  filled: true,
                  fillColor: _surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FilterRow(
              label: 'Language',
              filters: _languageFilters,
              selectedIndex: _selectedLanguage,
              onSelected: (index) => setState(() => _selectedLanguage = index),
            ),
            const SizedBox(height: 10),
            _FilterRow(
              label: 'Specialty',
              filters: _specialtyFilters,
              selectedIndex: _selectedSpecialty,
              onSelected: (index) => setState(() => _selectedSpecialty = index),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: doctors.isEmpty
                  ? const Center(
                      child: Text(
                        'No doctors found',
                        style: TextStyle(color: _subtitleColor, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: doctors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _DoctorCard(doctor: doctors[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Doctor {
  const _Doctor({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.languages,
    required this.flags,
    required this.rating,
    required this.area,
    required this.initials,
  });

  final String name;
  final String specialty;
  final String hospital;
  final List<String> languages;
  final List<String> flags;
  final double rating;
  final String area;
  final String initials;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String label;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: const TextStyle(
              color: _subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return FilterChip(
                label: Text(filters[index]),
                selected: isSelected,
                onSelected: (_) => onSelected(index),
                backgroundColor: _surfaceColor,
                selectedColor: _cyanColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? _cyanColor : _subtitleColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? _cyanColor : Colors.transparent,
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final _Doctor doctor;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _cyanColor.withValues(alpha: 0.2),
                child: Text(
                  doctor.initials,
                  style: const TextStyle(
                    color: _cyanColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🏥 ${doctor.hospital}',
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    doctor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...doctor.flags.map(
                (flag) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(flag, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '📍 ${doctor.area}',
                style: const TextStyle(color: _subtitleColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
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
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cyanColor,
                    side: const BorderSide(color: _cyanColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const Color _backgroundColor = Color(0xFF050A0F);
}
