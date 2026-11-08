import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Aggregates pre-fill data from profile, EOSB, and overtime — read-only.
class CvPrefillService {
  CvPrefillService(this._ref);

  final Ref _ref;

  Future<CvDocument> buildPrefilled({String? existingId}) async {
    final profile = _ref.read(userAIProfileProvider);
    final contact = await _loadContactInfo();
    final eosbInput = await _loadEosbInput();
    final overtimeProfile = await _loadOvertimeProfile();
    final historyRoles = await _loadHistoryRoles();

    final languageEntries = <CvLanguageEntry>[];
    if (profile?.language.isNotEmpty == true) {
      languageEntries.add(CvLanguageEntry(language: profile!.language));
    }

    final hardSkills = <String>[...?profile?.skills];
    final toolSkills = <String>[...?profile?.certifications];

    final experience = <CvExperience>[];

    if (eosbInput?.companyName.isNotEmpty == true) {
      experience.add(
        CvExperience(
          employer: eosbInput!.companyName,
          jobTitle: overtimeProfile?.jobTitle.isNotEmpty == true
              ? overtimeProfile!.jobTitle
              : profile?.profession ?? eosbInput.industry,
          startDate: eosbInput.joiningDate,
          endDate: eosbInput.lastWorkingDate,
          isCurrent: eosbInput.lastWorkingDate == null,
        ),
      );
    } else if (overtimeProfile?.companyName.isNotEmpty == true) {
      experience.add(
        CvExperience(
          employer: overtimeProfile!.companyName,
          jobTitle: overtimeProfile.jobTitle.isNotEmpty
              ? overtimeProfile.jobTitle
              : profile?.profession ?? '',
          startDate: overtimeProfile.joiningDate,
          isCurrent: true,
        ),
      );
    }

    for (final role in historyRoles) {
      final duplicate = experience.any(
        (e) =>
            e.employer == role.employer &&
            e.startDate == role.startDate,
      );
      if (!duplicate) experience.add(role);
    }

    return CvDocument(
      id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: profile?.profession.isNotEmpty == true
          ? '${profile!.profession} CV'
          : 'My CV',
      fullName: contact.displayName,
      email: contact.email,
      phone: contact.phone,
      location: profile?.nationality.isNotEmpty == true
          ? 'Doha, ${profile!.nationality}'
          : 'Doha, Qatar',
      nationality: profile?.nationality ?? '',
      languageEntries: languageEntries,
      skills: CvSkills(
        hardSkills: hardSkills.toSet().toList(),
        toolsSoftware: toolSkills.toSet().toList(),
      ),
      professionalSummary: profile?.profession.isNotEmpty == true
          ? 'Experienced ${profile!.profession} professional in Qatar.'
          : '',
      experience: experience.take(5).toList(),
      education: const [CvEducation()],
      isRtl: (profile?.language ?? '').toLowerCase().contains('arabic'),
      updatedAt: DateTime.now(),
    );
  }

  Future<_ContactInfo> _loadContactInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _ContactInfo(displayName: '', phone: '', email: '');
    }

    var displayName = user.displayName ?? '';
    var phone = user.phoneNumber ?? '';
    var email = user.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      displayName = displayName.isNotEmpty
          ? displayName
          : (data['displayName'] as String? ?? '');
      phone = phone.isNotEmpty
          ? phone
          : (data['phone'] as String? ?? data['phoneNumber'] as String? ?? '');
      email = email.isNotEmpty ? email : (data['email'] as String? ?? '');
    } catch (_) {}

    return _ContactInfo(
      displayName: displayName.isEmpty ? 'Raabta member' : displayName,
      phone: phone,
      email: email,
    );
  }

  Future<EosbEmployeeInput?> _loadEosbInput() async {
    try {
      final repo = await _ref.read(eosbRepositoryProvider.future);
      final cached = repo.loadCachedInput();
      if (cached != null) return cached;
      final current = _ref.read(eosbProvider).input;
      return current.companyName.isNotEmpty ? current : null;
    } catch (_) {
      return null;
    }
  }

  Future<OvertimeEmployeeProfile?> _loadOvertimeProfile() async {
    try {
      final profile = _ref.read(overtimeTruthProvider).record.profile;
      if (profile.companyName.isNotEmpty || profile.jobTitle.isNotEmpty) {
        return profile;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<CvExperience>> _loadHistoryRoles() async {
    try {
      final repo = await _ref.read(eosbRepositoryProvider.future);
      final history = await repo.loadHistory();
      return history
          .where((h) => h.input.companyName.isNotEmpty)
          .map(
            (h) => CvExperience(
              employer: h.input.companyName,
              jobTitle: h.input.industry,
              startDate: h.input.joiningDate,
              endDate: h.input.lastWorkingDate,
              isCurrent: h.input.lastWorkingDate == null,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class _ContactInfo {
  const _ContactInfo({
    required this.displayName,
    required this.phone,
    required this.email,
  });

  final String displayName;
  final String phone;
  final String email;
}

final cvPrefillServiceProvider = Provider((ref) => CvPrefillService(ref));
