/// Static QVC / visa stage tracker steps (informational, self-checked).
class QvcStageDef {
  const QvcStageDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.url,
    this.needsVerification = true,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? url;
  final bool needsVerification;
}

abstract final class QvcStageCatalog {
  static const steps = [
    QvcStageDef(
      id: 'contract_verification',
      titleKey: 'pm_qvc_step_contract_title',
      descriptionKey: 'pm_qvc_step_contract_desc',
      url: 'https://www.qatarvisacenter.com',
      needsVerification: true,
    ),
    QvcStageDef(
      id: 'biometric_appointment',
      titleKey: 'pm_qvc_step_biometric_title',
      descriptionKey: 'pm_qvc_step_biometric_desc',
      url: 'https://www.qatarvisacenter.com',
      needsVerification: true,
    ),
    QvcStageDef(
      id: 'medical_exam',
      titleKey: 'pm_qvc_step_medical_title',
      descriptionKey: 'pm_qvc_step_medical_desc',
      url: 'https://www.qatarvisacenter.com',
      needsVerification: true,
    ),
    QvcStageDef(
      id: 'moi_visa_status',
      titleKey: 'pm_qvc_step_moi_title',
      descriptionKey: 'pm_qvc_step_moi_desc',
      url: 'https://portal.moi.gov.qa',
      needsVerification: true,
    ),
  ];
}
