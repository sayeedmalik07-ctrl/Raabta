enum LegalDocumentType { privacy, terms }

class LegalContent {
  LegalContent._();

  static String title(LegalDocumentType type) {
    return switch (type) {
      LegalDocumentType.privacy => 'Privacy Policy',
      LegalDocumentType.terms => 'Terms of Service',
    };
  }

  static String body(LegalDocumentType type) {
    return switch (type) {
      LegalDocumentType.privacy => _privacyPolicy,
      LegalDocumentType.terms => _termsOfService,
    };
  }

  static const String _privacyPolicy = '''
Last updated: June 2026

Raabta ("we", "our", "us") operates the Raabta mobile application for expats in Qatar. This Privacy Policy explains how we collect, use, and protect your information.

Information we collect
• Account data: phone number, display name, language preference, and profile fields you choose to provide.
• Usage data: features you use, saved preferences, and anonymized analytics to improve the app.
• User content: listings, reviews, community posts, scanned documents, and support tickets you submit.
• Safety preferences: when you block someone in classifieds chats, we store their user ID under your account so messaging rules can be enforced. You can review and remove blocks in Profile → Privacy → Blocked users.
• Chat reports: when you report a classifieds conversation, we store a short snapshot of the reported message and a few nearby messages (not ongoing access to the thread) to help moderation.
• Device data: app version and platform type when you report an issue.

How we use information
• To provide and personalize Raabta features (jobs, housing, EOSB calculations, prayer times, etc.).
• To secure your account and prevent abuse.
• To respond to support requests and improve the product.

Sharing
We do not sell your personal data. We may share data with service providers (Firebase/Google Cloud) strictly to operate the app, or when required by law. When you use Scam Shield link checks, suspicious URLs may be sent to our server and to Google Web Risk for reputation lookup — not for advertising.

Data storage
Data is stored on Firebase (Firestore, Storage, Auth) with industry-standard security. You may request deletion by contacting support.

Retention
We keep classifieds chat reports and related moderation records for up to 24 months, then delete or anonymize them unless a longer period is required for legal or safety reasons.

Your choices
• Update profile information in Profile → Edit Profile.
• Sign out anytime from Profile.
• Report privacy concerns via Profile → Report Issue.

Contact
Questions about this policy: support@raabta.app

This in-app summary is provided for convenience. The authoritative version may also be published at raabtaone.com/privacy.
''';

  static const String _termsOfService = '''
Last updated: June 2026

Welcome to Raabta. By using our app you agree to these Terms of Service.

The service
Raabta provides community, housing, jobs, financial tools, EOSB/overtime calculators, document tools, prayer times, trip planning, and AI-assisted guidance for expats in Qatar. Features may change as we improve the product.

Not professional advice
EOSB, overtime, visa, health, and AI outputs are informational only — not legal, medical, financial, or religious advice. Verify important decisions with qualified professionals and official sources (e.g. ADLSA 16008).

Your account
You are responsible for activity on your account. Keep your phone number secure. Do not share false listings, scam job posts, or abusive content. We may suspend accounts that violate these terms.

User content
You retain ownership of content you post. You grant Raabta a license to display and process it to operate the service. Do not post content you do not have rights to share.

Listings platform
Raabta hosts user-generated listings and community content. Raabta is not a party to transactions between users and does not process payments for sales, hires, rentals, or job offers. You are responsible for any trade licence or permit your listing requires.

Reports and moderation
You may report listings or content you believe violates these terms. We may remove or hide content at our discretion. Feature availability may change as we improve the product or to meet legal requirements.

Limitation of liability
Raabta is provided "as is". We are not liable for indirect damages arising from use of the app or reliance on calculated estimates.

Changes
We may update these terms. Continued use after changes constitutes acceptance.

Contact
support@raabta.app

This in-app summary is provided for convenience. The authoritative version may also be published at raabtaone.com/terms.
''';
}
