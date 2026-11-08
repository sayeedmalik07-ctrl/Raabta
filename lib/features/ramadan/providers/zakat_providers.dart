import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/ramadan/data/zakat_repository.dart';

final zakatRepositoryProvider = Provider((ref) => ZakatRepository());
