import 'package:flutter/material.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  double _overallRating = 4;
  double _salaryRating = 4;
  double _housingRating = 3;
  double _managementRating = 4;
  double _workLifeRating = 3;
  String _homeFlight = 'Yes';
  String _employmentStatus = 'Current Employee';
  bool _disclaimerAccepted = false;

  static const List<String> _homeFlightOptions = ['Yes', 'No', 'Partial'];
  static const List<String> _employmentOptions = [
    'Current Employee',
    'Former Employee',
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _reviewController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _subtitleColor),
      filled: true,
      fillColor: _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _submit() {
    if (_companyController.text.trim().isEmpty) {
      _showError('Please enter a company name');
      return;
    }
    if (_reviewController.text.trim().length < 100) {
      _showError('Review must be at least 100 characters');
      return;
    }
    if (!_disclaimerAccepted) {
      _showError('Please accept the disclaimer');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted anonymously!')),
    );
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _ratingSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '⭐ ${value.toStringAsFixed(1)}',
              style: const TextStyle(
                color: _cyanColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 8,
          activeColor: _cyanColor,
          inactiveColor: _surfaceColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _chipRow({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _subtitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: _surfaceColor,
              selectedColor: _cyanColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? _cyanColor : _subtitleColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? _cyanColor : Colors.transparent,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewLength = _reviewController.text.trim().length;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Write Anonymous Review',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company name',
                style: TextStyle(
                  color: _subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _companyController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Search or enter company name...'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ratings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ratingSlider(
                label: '⭐ Overall Experience',
                value: _overallRating,
                onChanged: (v) => setState(() => _overallRating = v),
              ),
              _ratingSlider(
                label: '💰 Salary paid on time',
                value: _salaryRating,
                onChanged: (v) => setState(() => _salaryRating = v),
              ),
              _ratingSlider(
                label: '🏠 Accommodation quality (if provided)',
                value: _housingRating,
                onChanged: (v) => setState(() => _housingRating = v),
              ),
              _ratingSlider(
                label: '👔 Management & HR treatment',
                value: _managementRating,
                onChanged: (v) => setState(() => _managementRating = v),
              ),
              _ratingSlider(
                label: '📅 Work hours & overtime policy',
                value: _workLifeRating,
                onChanged: (v) => setState(() => _workLifeRating = v),
              ),
              const SizedBox(height: 8),
              _chipRow(
                title: '✈️ Home flight provided',
                options: _homeFlightOptions,
                selected: _homeFlight,
                onSelected: (v) => setState(() => _homeFlight = v),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your review',
                style: TextStyle(
                  color: _subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Share your experience...'),
              ),
              const SizedBox(height: 6),
              Text(
                '$reviewLength / 100 characters minimum',
                style: TextStyle(
                  color: reviewLength >= 100 ? _cyanColor : _subtitleColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              _chipRow(
                title: 'Employment status',
                options: _employmentOptions,
                selected: _employmentStatus,
                onSelected: (v) => setState(() => _employmentStatus = v),
              ),
              const SizedBox(height: 20),
              const Text(
                'Department (optional)',
                style: TextStyle(
                  color: _subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _departmentController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. Operations, HR, Engineering'),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _disclaimerAccepted,
                    onChanged: (v) =>
                        setState(() => _disclaimerAccepted = v ?? false),
                    activeColor: _cyanColor,
                    checkColor: _backgroundColor,
                    side: const BorderSide(color: _subtitleColor),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'I confirm this review is based on my genuine experience. '
                        'I understand false reviews may violate terms of service.',
                        style: TextStyle(
                          color: _subtitleColor,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cyanColor,
                    foregroundColor: _backgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Anonymously',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
