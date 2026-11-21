import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/services/employer_track_record_service.dart';

final employerTrackRecordServiceProvider = Provider<EmployerTrackRecordService>(
  (ref) => EmployerTrackRecordService(),
);
