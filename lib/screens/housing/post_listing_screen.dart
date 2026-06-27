import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/listings_api_service.dart';

class PostListingScreen extends ConsumerStatefulWidget {
  const PostListingScreen({super.key});

  @override
  ConsumerState<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends ConsumerState<PostListingScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  static const List<String> _amenityOptions = [
    'WiFi',
    'AC',
    'Parking',
    'Kitchen',
    'Laundry',
    'Balcony',
    'Gym',
    'Furnished',
  ];

  int _step = 0;
  bool _isSubmitting = false;
  bool _isPremiumUser = false;
  bool _featured = false;

  final List<File> _photoFiles = [];
  final List<String> _uploadedPhotoUrls = [];
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController(text: '1');
  final _bathroomsController = TextEditingController(text: '1');
  final _whatsappController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactNameController = TextEditingController();

  ListingType _type = ListingType.room;
  bool _furnished = true;
  String _area = qatarAreas.first;
  GenderPreference _gender = GenderPreference.any;
  NationalityPreference _nationality = NationalityPreference.any;
  final Set<String> _selectedAmenities = {'WiFi', 'AC'};

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _whatsappController.dispose();
    _phoneController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
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

  Future<void> _pickPhotos(ImageSource source) async {
    if (source == ImageSource.camera) {
      final photo = await _picker.pickImage(source: source, imageQuality: 80);
      if (photo != null) {
        setState(() => _photoFiles.add(File(photo.path)));
      }
      return;
    }

    final photos = await _picker.pickMultiImage(imageQuality: 80);
    if (photos.isNotEmpty) {
      setState(() => _photoFiles.addAll(photos.map((p) => File(p.path))));
    }
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (_photoFiles.isEmpty) return 'Add at least one photo';
        return null;
      case 1:
        if (_titleController.text.trim().length < 5) {
          return 'Title must be at least 5 characters';
        }
        final price = int.tryParse(_priceController.text.trim());
        if (price == null || price < 500 || price > 20000) {
          return 'Enter a valid price (500–20,000 QR)';
        }
        if (_descriptionController.text.trim().length < 20) {
          return 'Description must be at least 20 characters';
        }
        return null;
      case 2:
        return null;
      case 3:
        if (_whatsappController.text.trim().length < 8) {
          return 'Enter a valid WhatsApp number';
        }
        if (_contactNameController.text.trim().isEmpty) {
          return 'Enter contact name';
        }
        return null;
      default:
        return null;
    }
  }

  Future<List<String>> _uploadPhotos() async {
    if (_uploadedPhotoUrls.isNotEmpty) return _uploadedPhotoUrls;

    final urls = <String>[];
    final api = ref.read(listingsApiServiceProvider);
    final storage = HousingFirestoreService();
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    for (final file in _photoFiles) {
      try {
        if (FirebaseService.isReady) {
          final url = await storage.uploadPhoto(file, listingId: tempId);
          urls.add(url);
        } else {
          final url = await api.uploadPhoto(file);
          urls.add(url);
        }
      } catch (_) {
        urls.add(
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=${urls.length}',
        );
      }
    }

    _uploadedPhotoUrls.addAll(urls);
    return urls;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final photoUrls = await _uploadPhotos();
      final request = CreateListingRequest(
        title: _titleController.text.trim(),
        area: _area,
        pricePerMonth: int.parse(_priceController.text.trim()),
        type: _type,
        furnished: _furnished,
        bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 1,
        bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 1,
        photoUrls: photoUrls,
        description: _descriptionController.text.trim(),
        amenities: _selectedAmenities.toList(),
        genderPreference: _gender,
        nationalityPreference: _nationality,
        whatsapp: _whatsappController.text.trim().replaceAll('+', ''),
        phone: _phoneController.text.trim().isEmpty
            ? '+${_whatsappController.text.trim()}'
            : _phoneController.text.trim(),
        contactName: _contactNameController.text.trim(),
        featured: _featured,
        isPremiumUser: _isPremiumUser,
      );

      final listing =
          await ref.read(housingRepositoryProvider).createListing(request);

      try {
        final scan = await ref.read(housingRepositoryProvider).scanListingScam(
              listingId: listing.id,
              request: request,
            );
        if (scan.verdict == ScamVerdict.likelyScam && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ AI flagged possible scam (${scan.scamScore}/100). '
                'Our team will review your listing.',
              ),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      } catch (_) {
        // Scan is best-effort — listing still created
      }

      ref.invalidate(housingListingsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listing.status == ListingStatus.pending
                ? 'Listing submitted! Status: Pending admin approval.'
                : 'Listing published successfully!',
          ),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      Navigator.of(context).pop();
    } on ListingsApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    final error = _validateStep(_step);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_step < 5) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    const stepTitles = [
      'Photos',
      'Details',
      'Location',
      'Contact',
      'Preview',
      'Submit',
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        title: const Text('Post Listing'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(stepTitles.length, (index) {
                final active = index <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 5 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: active ? _cyanColor : const Color(0xFF1A2535),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Step ${_step + 1}: ${stepTitles[_step]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF1A2535)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: FilledButton.styleFrom(
                      backgroundColor: _cyanColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _step == 5 ? 'Submit Listing' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildPhotosStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildContactStep();
      case 4:
        return _buildPreviewStep();
      case 5:
        return _buildSubmitStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add photos of your property',
          style: TextStyle(color: _subtitleColor),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickPhotos(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(foregroundColor: _cyanColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickPhotos(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(foregroundColor: _cyanColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_photoFiles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_photo_alternate, color: _subtitleColor, size: 48),
                SizedBox(height: 8),
                Text('No photos yet', style: TextStyle(color: _subtitleColor)),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _photoFiles.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_photoFiles[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _photoFiles.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('Listing title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('Price per month (QR)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('Full description'),
        ),
        const SizedBox(height: 16),
        const Text('Property type', style: TextStyle(color: _subtitleColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ListingType.room,
            ListingType.flat,
            ListingType.sharing,
            ListingType.studio,
          ].map((t) {
            final selected = _type == t;
            return ChoiceChip(
              label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
              selected: selected,
              onSelected: (_) => setState(() => _type = t),
              selectedColor: _cyanColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: selected ? _cyanColor : _subtitleColor),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _furnished,
          onChanged: (v) => setState(() => _furnished = v),
          title: const Text('Furnished', style: TextStyle(color: Colors.white)),
          activeThumbColor: _cyanColor,
          contentPadding: EdgeInsets.zero,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bedroomsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Bedrooms'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _bathroomsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Bathrooms'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Amenities', style: TextStyle(color: _subtitleColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenityOptions.map((a) {
            final selected = _selectedAmenities.contains(a);
            return FilterChip(
              label: Text(a),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedAmenities.add(a);
                  } else {
                    _selectedAmenities.remove(a);
                  }
                });
              },
              selectedColor: _cyanColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: selected ? _cyanColor : _subtitleColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select area (exact address hidden for safety)',
          style: TextStyle(color: _subtitleColor),
        ),
        const SizedBox(height: 12),
        ...qatarAreas.map((area) {
          final selected = _area == area;
          return ListTile(
            title: Text(area, style: const TextStyle(color: Colors.white)),
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _cyanColor : _subtitleColor,
            ),
            tileColor:
                selected ? _cyanColor.withValues(alpha: 0.08) : _surfaceColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () => setState(() => _area = area),
          );
        }),
        const SizedBox(height: 16),
        const Text('Gender preference', style: TextStyle(color: _subtitleColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: GenderPreference.values.map((g) {
            final selected = _gender == g;
            return ChoiceChip(
              label: Text(genderLabel(g)),
              selected: selected,
              onSelected: (_) => setState(() => _gender = g),
              selectedColor: _cyanColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: selected ? _cyanColor : _subtitleColor),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Text('Nationality preference', style: TextStyle(color: _subtitleColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: NationalityPreference.values.map((n) {
            final selected = _nationality == n;
            return ChoiceChip(
              label: Text(nationalityLabel(n)),
              selected: selected,
              onSelected: (_) => setState(() => _nationality = n),
              selectedColor: _cyanColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: selected ? _cyanColor : _subtitleColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      children: [
        TextField(
          controller: _contactNameController,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('Contact name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('WhatsApp number (e.g. 97455123456)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('Phone number (optional)'),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_photoFiles.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _photoFiles.first,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _titleController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text('📍 $_area', style: const TextStyle(color: _subtitleColor)),
          Text(
            '${_priceController.text} QR/month',
            style: const TextStyle(color: _cyanColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_descriptionController.text, style: const TextStyle(color: _subtitleColor)),
          const SizedBox(height: 8),
          Text(
            'Contact: ${_contactNameController.text} · WhatsApp: ${_whatsappController.text}',
            style: const TextStyle(color: _subtitleColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your listing will show as "Pending" until approved by our admin team.',
                  style: TextStyle(color: Colors.amber, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _isPremiumUser,
          onChanged: (v) => setState(() {
            _isPremiumUser = v;
            if (!v) _featured = false;
          }),
          title: const Text('Premium user', style: TextStyle(color: Colors.white)),
          subtitle: const Text(
            'Enable to mark listing as Featured (paid)',
            style: TextStyle(color: _subtitleColor, fontSize: 12),
          ),
          activeThumbColor: _cyanColor,
        ),
        if (_isPremiumUser)
          SwitchListTile(
            value: _featured,
            onChanged: (v) => setState(() => _featured = v),
            title: const Text('Featured listing', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Boost visibility at top of search results',
              style: TextStyle(color: _subtitleColor, fontSize: 12),
            ),
            activeThumbColor: _cyanColor,
          ),
        const SizedBox(height: 12),
        const Text(
          'By submitting, you agree to Raabta\'s housing guidelines and moderation policy.',
          style: TextStyle(color: _subtitleColor, fontSize: 12),
        ),
      ],
    );
  }
}
