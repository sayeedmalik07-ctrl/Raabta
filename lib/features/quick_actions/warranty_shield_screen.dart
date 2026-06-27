import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raabta/config/app_config.dart';
import 'package:raabta/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WarrantyItem {
  const WarrantyItem({
    required this.id,
    required this.productName,
    required this.brand,
    required this.category,
    required this.purchaseDate,
    required this.expiryDate,
    required this.purchasePriceQar,
    required this.receiptImagePath,
  });

  final String id;
  final String productName;
  final String brand;
  final String category;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double purchasePriceQar;
  final String receiptImagePath;

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpired => daysLeft < 0;
  bool get expiringsSoon => daysLeft <= 30 && daysLeft >= 0;

  WarrantyItem copyWith({
    String? id,
    String? productName,
    String? brand,
    String? category,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? purchasePriceQar,
    String? receiptImagePath,
  }) {
    return WarrantyItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      purchasePriceQar: purchasePriceQar ?? this.purchasePriceQar,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'brand': brand,
        'category': category,
        'purchaseDate': purchaseDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'purchasePriceQar': purchasePriceQar,
        'receiptImagePath': receiptImagePath,
      };

  factory WarrantyItem.fromJson(Map<String, dynamic> json) {
    return WarrantyItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      productName: json['productName'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'General',
      purchaseDate: DateTime.tryParse(json['purchaseDate'] as String? ?? '') ??
          DateTime.now(),
      expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 365)),
      purchasePriceQar: (json['purchasePriceQar'] as num?)?.toDouble() ?? 0,
      receiptImagePath: json['receiptImagePath'] as String? ?? '',
    );
  }
}

class _WarrantyStorage {
  static const _key = 'warranty_shield_items';

  static Future<List<WarrantyItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WarrantyItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<WarrantyItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}

class _WarrantyNotificationService {
  _WarrantyNotificationService._();
  static final _WarrantyNotificationService instance =
      _WarrantyNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'warranty_reminders',
    'Warranty Reminders',
    description: 'Alerts before product warranties expire',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      _initialized = true;
    } catch (e) {
      debugPrint('Warranty notification init failed: $e');
    }
  }

  Future<void> scheduleFor(WarrantyItem item) async {
    if (!_initialized) return;
    await cancelFor(item.id);

    final offsets = [30, 7, 1, 0];
    for (final daysBefore in offsets) {
      final notifyDate =
          item.expiryDate.subtract(Duration(days: daysBefore));
      if (notifyDate.isBefore(DateTime.now())) continue;

      final title = daysBefore == 0
          ? '${item.productName} warranty expired'
          : '${item.productName} warranty expiring soon';
      final body = daysBefore == 0
          ? 'Your ${item.brand} warranty has expired. Check if you need service or renewal.'
          : daysBefore == 1
              ? 'Warranty expires tomorrow — save your receipt and contact ${item.brand} if needed.'
              : 'Warranty expires in $daysBefore days (${item.expiryDate.toLocal().toString().split(' ').first}).';

      await _schedule(
        id: _id(item.id, daysBefore),
        title: title,
        body: body,
        when: notifyDate,
      );
    }
  }

  Future<void> cancelFor(String warrantyId) async {
    if (!_initialized) return;
    for (final days in [30, 7, 1, 0]) {
      await _plugin.cancel(_id(warrantyId, days));
    }
  }

  int _id(String warrantyId, int daysBefore) =>
      warrantyId.hashCode + daysBefore + 9000;

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class WarrantyShieldScreen extends StatefulWidget {
  const WarrantyShieldScreen({super.key});

  @override
  State<WarrantyShieldScreen> createState() => _WarrantyShieldScreenState();
}

class _WarrantyShieldScreenState extends State<WarrantyShieldScreen> {
  final List<WarrantyItem> _warranties = [];
  final ImagePicker _picker = ImagePicker();
  bool _loading = true;
  bool _scanningReceipt = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _WarrantyNotificationService.instance.initialize();
    final items = await _WarrantyStorage.load();
    if (!mounted) return;
    setState(() {
      _warranties
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await _WarrantyStorage.save(_warranties);
  }

  Future<void> _addWarranty(WarrantyItem item) async {
    setState(() => _warranties.insert(0, item));
    await _persist();
    await _WarrantyNotificationService.instance.scheduleFor(item);
  }

  Future<void> _deleteWarranty(String id) async {
    setState(() => _warranties.removeWhere((w) => w.id == id));
    await _persist();
    await _WarrantyNotificationService.instance.cancelFor(id);
  }

  Future<String> _copyReceiptToAppDir(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${dir.path}/warranty_receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final dest = File(
      '${receiptsDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await source.copy(dest.path);
    return dest.path;
  }

  Future<Map<String, dynamic>?> _scanReceiptWithAI(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final scanResponse = await http
        .post(
          Uri.parse('${AppConfig.backendUrl}/api/document-scan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'imageBase64': base64Encode(bytes),
            'language': 'English',
            'isPremium': false,
          }),
        )
        .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

    Map<String, dynamic>? scanData;
    if (scanResponse.statusCode == 200) {
      scanData = jsonDecode(scanResponse.body) as Map<String, dynamic>;
    }

    final prompt = StringBuffer()
      ..writeln(
        'You are extracting product warranty details from a purchase receipt in Qatar.',
      )
      ..writeln(
        'Respond ONLY with valid JSON (no markdown) in this exact format:',
      )
      ..writeln(
        '{"productName":"","brand":"","category":"","purchaseDate":"YYYY-MM-DD","expiryDate":"YYYY-MM-DD","purchasePriceQar":0}',
      )
      ..writeln(
        'Rules: default warranty is 1 year from purchase if not stated; '
        'purchasePriceQar must be a number; use best guess from receipt.',
      );

    if (scanData != null) {
      prompt
        ..writeln('\nDocument scan:')
        ..writeln('Type: ${scanData['documentType']}')
        ..writeln('Dates: ${scanData['keyDates']}')
        ..writeln('Info: ${scanData['importantInfo']}')
        ..writeln('Summary: ${scanData['summary']}');
    } else {
      prompt.writeln('\nReceipt image was uploaded but OCR failed — infer from typical Qatar electronics/appliance receipts.');
    }

    final reply = await ApiService.sendMessage(prompt.toString());
    return _parseAiJson(reply);
  }

  Map<String, dynamic>? _parseAiJson(String raw) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) return null;
      return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _scanReceipt() async {
    final hasCamera = Platform.isAndroid || Platform.isIOS;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1035),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCamera)
              _SheetOption(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            _SheetOption(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 85);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image picker: $e')),
      );
      return;
    }
    if (picked == null || !mounted) return;

    setState(() => _scanningReceipt = true);
    try {
      final imageFile = File(picked.path);
      final savedPath = await _copyReceiptToAppDir(imageFile);
      final extracted = await _scanReceiptWithAI(imageFile);

      final purchaseDate = DateTime.tryParse(
            extracted?['purchaseDate'] as String? ?? '',
          ) ??
          DateTime.now();
      final expiryDate = DateTime.tryParse(
            extracted?['expiryDate'] as String? ?? '',
          ) ??
          purchaseDate.add(const Duration(days: 365));

      final item = WarrantyItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: extracted?['productName'] as String? ?? 'Receipt Purchase',
        brand: extracted?['brand'] as String? ?? 'N/A',
        category: extracted?['category'] as String? ?? 'General',
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        purchasePriceQar:
            (extracted?['purchasePriceQar'] as num?)?.toDouble() ?? 0,
        receiptImagePath: savedPath,
      );

      await _addWarranty(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛡️ Warranty Shield activated from receipt!'),
          backgroundColor: Color(0xFF2DC653),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt scan failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _scanningReceipt = false);
    }
  }

  void _showAddWarrantySheet() {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    DateTime purchaseDate = DateTime.now();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate({required bool isPurchase}) async {
            final initial = isPurchase ? purchaseDate : expiryDate;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2015),
              lastDate: DateTime(2040),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF2DC653),
                  ),
                ),
                child: child!,
              ),
            );
            if (picked == null) return;
            setSheetState(() {
              if (isPurchase) {
                purchaseDate = picked;
                if (!expiryDate.isAfter(purchaseDate)) {
                  expiryDate = purchaseDate.add(const Duration(days: 365));
                }
              } else {
                expiryDate = picked;
              }
            });
          }

          String fmt(DateTime d) =>
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Warranty',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    controller: nameCtrl,
                    hint: 'Product name (e.g. LG AC)',
                  ),
                  const SizedBox(height: 12),
                  _FormField(controller: brandCtrl, hint: 'Brand'),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: priceCtrl,
                    hint: 'Price paid (QAR)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _DatePickerRow(
                    label: 'Purchase date',
                    value: fmt(purchaseDate),
                    onTap: () => pickDate(isPurchase: true),
                  ),
                  const SizedBox(height: 8),
                  _DatePickerRow(
                    label: 'Warranty expires',
                    value: fmt(expiryDate),
                    onTap: () => pickDate(isPurchase: false),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final item = WarrantyItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          productName: nameCtrl.text.isEmpty
                              ? 'Unknown Product'
                              : nameCtrl.text,
                          brand:
                              brandCtrl.text.isEmpty ? 'N/A' : brandCtrl.text,
                          category: 'General',
                          purchaseDate: purchaseDate,
                          expiryDate: expiryDate,
                          purchasePriceQar:
                              double.tryParse(priceCtrl.text) ?? 0,
                          receiptImagePath: '',
                        );
                        await _addWarranty(item);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('🛡️ Warranty Shield Activated!'),
                            backgroundColor: Color(0xFF2DC653),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DC653),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Activate Shield',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _warranties.where((w) => !w.isExpired).toList();
    final expiringSoon = _warranties.where((w) => w.expiringsSoon).toList();
    final expired = _warranties.where((w) => w.isExpired).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        title: const Text(
          'Warranty Shield',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2DC653)),
            onPressed: _showAddWarrantySheet,
            tooltip: 'Add Warranty',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DC653)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatBox('${active.length}', 'Active', const Color(0xFF2DC653)),
                      const SizedBox(width: 12),
                      _StatBox(
                        '${expiringSoon.length}',
                        'Expiring Soon',
                        const Color(0xFFFFB627),
                      ),
                      const SizedBox(width: 12),
                      _StatBox('${expired.length}', 'Expired', const Color(0xFFE63946)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_warranties.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 56,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No warranties tracked yet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (expiringSoon.isNotEmpty) ...[
                    const Text(
                      '⚠️ Expiring Soon',
                      style: TextStyle(
                        color: Color(0xFFFFB627),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...expiringSoon.map(
                      (w) => _WarrantyCard(
                        warranty: w,
                        onDelete: () => _deleteWarranty(w.id),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (active.isNotEmpty) ...[
                    const Text(
                      '🛡️ Active Warranties',
                      style: TextStyle(
                        color: Color(0xFF2DC653),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...active
                        .where((w) => !w.expiringsSoon)
                        .map(
                          (w) => _WarrantyCard(
                            warranty: w,
                            onDelete: () => _deleteWarranty(w.id),
                          ),
                        ),
                    const SizedBox(height: 20),
                  ],
                  if (expired.isNotEmpty) ...[
                    const Text(
                      '✕ Expired',
                      style: TextStyle(
                        color: Color(0xFFE63946),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...expired.map(
                      (w) => _WarrantyCard(
                        warranty: w,
                        onDelete: () => _deleteWarranty(w.id),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DC653).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF2DC653).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF2DC653),
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scan a Receipt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _scanningReceipt
                                    ? 'AI extracting product & warranty date...'
                                    : 'AI auto-detects product & warranty date',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _scanningReceipt ? null : _scanReceipt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2DC653),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _scanningReceipt
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Scan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({required this.warranty, required this.onDelete});

  final WarrantyItem warranty;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = warranty.isExpired
        ? const Color(0xFFE63946)
        : warranty.expiringsSoon
            ? const Color(0xFFFFB627)
            : const Color(0xFF2DC653);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shield_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warranty.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  warranty.brand,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warranty.isExpired
                      ? 'Expired'
                      : warranty.expiringsSoon
                          ? '${warranty.daysLeft} days left — Act now!'
                          : '${warranty.daysLeft} days remaining',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${warranty.purchasePriceQar.toStringAsFixed(0)} QAR',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white24,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.calendar_today, color: Color(0xFF2DC653), size: 16),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 13,
        ),
        fillColor: Colors.white.withValues(alpha: 0.06),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2DC653)),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2DC653)),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
