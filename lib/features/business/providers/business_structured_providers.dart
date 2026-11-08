import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/business/data/business_appointment_repository.dart';
import 'package:raabta/features/business/data/business_quote_repository.dart';
import 'package:raabta/features/business/domain/business_appointment_request.dart';
import 'package:raabta/features/business/domain/business_quote_request.dart';

final businessAppointmentRepositoryProvider =
    Provider<BusinessAppointmentRepository>((ref) {
  return BusinessAppointmentRepository();
});

final businessQuoteRepositoryProvider = Provider<BusinessQuoteRepository>((ref) {
  return BusinessQuoteRepository();
});

final businessAppointmentRequestsProvider = StreamProvider.family
    .autoDispose<List<BusinessAppointmentRequest>, String>((ref, businessId) {
  return ref
      .watch(businessAppointmentRepositoryProvider)
      .watchBusinessRequests(businessId);
});

final businessQuoteRequestsProvider = StreamProvider.family
    .autoDispose<List<BusinessQuoteRequest>, String>((ref, businessId) {
  return ref
      .watch(businessQuoteRepositoryProvider)
      .watchBusinessRequests(businessId);
});
