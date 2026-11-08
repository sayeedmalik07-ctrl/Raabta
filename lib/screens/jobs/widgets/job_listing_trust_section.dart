import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/screens/jobs/widgets/job_adlsa_contract_verification_card.dart';
import 'package:raabta/screens/jobs/widgets/job_employer_track_record_card.dart';
import 'package:raabta/screens/jobs/widgets/job_mol_recruitment_agency_trust_card.dart';
import 'package:raabta/screens/jobs/widgets/job_recruitment_fee_safety_card.dart';

/// Trust guidance on Jobs listing detail — Employer Track Record + ADLSA link-out.
class JobListingTrustSection extends StatelessWidget {
  const JobListingTrustSection({
    super.key,
    required this.companyName,
    required this.locale,
  });

  final String companyName;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (companyName.trim().isNotEmpty) ...[
          JobEmployerTrackRecordCard(
            companyName: companyName,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        JobRecruitmentFeeSafetyCard(locale: locale),
        const SizedBox(height: AppSpacing.lg),
        JobMolRecruitmentAgencyTrustCard(locale: locale),
        const SizedBox(height: AppSpacing.lg),
        JobAdlsaContractVerificationCard(locale: locale),
      ],
    );
  }
}
