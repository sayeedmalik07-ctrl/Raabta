import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';

class HelpFaqItem {
  const HelpFaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class HelpFaqCategory {
  const HelpFaqCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  final String id;
  final String title;
  final String icon;
  final List<HelpFaqItem> items;
}

/// Localized FAQ content for Help Center.
class HelpCenterContent {
  HelpCenterContent._();

  static List<HelpFaqCategory> categoriesFor(String locale) => [
        HelpFaqCategory(
          id: 'account',
          title: ProfileStrings.t('help_cat_account', locale),
          icon: '👤',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_account_profile_q', locale),
              answer: ProfileStrings.t('help_faq_account_profile_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_account_language_q', locale),
              answer: ProfileStrings.t('help_faq_account_language_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_account_signout_q', locale),
              answer: ProfileStrings.t('help_faq_account_signout_a', locale),
            ),
          ],
        ),
        HelpFaqCategory(
          id: 'eosb',
          title: ProfileStrings.t('help_cat_eosb', locale),
          icon: '💰',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_eosb_engine_q', locale),
              answer: ProfileStrings.t('help_faq_eosb_engine_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_eosb_legal_q', locale),
              answer: ProfileStrings.t('help_faq_eosb_legal_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_eosb_overtime_q', locale),
              answer: ProfileStrings.t('help_faq_eosb_overtime_a', locale),
            ),
          ],
        ),
        HelpFaqCategory(
          id: 'documents',
          title: ProfileStrings.t('help_cat_documents', locale),
          icon: '📄',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_docs_vault_q', locale),
              answer: ProfileStrings.t('help_faq_docs_vault_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_docs_share_q', locale),
              answer: ProfileStrings.t('help_faq_docs_share_a', locale),
            ),
          ],
        ),
        HelpFaqCategory(
          id: 'prayer',
          title: ProfileStrings.t('help_cat_prayer', locale),
          icon: '🕌',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_prayer_calc_q', locale),
              answer: ProfileStrings.t('help_faq_prayer_calc_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_prayer_fatwa_q', locale),
              answer: ProfileStrings.t('help_faq_prayer_fatwa_a', locale),
            ),
          ],
        ),
        HelpFaqCategory(
          id: 'trip',
          title: ProfileStrings.t('help_cat_trip', locale),
          icon: '✈️',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_trip_generate_q', locale),
              answer: ProfileStrings.t('help_faq_trip_generate_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_trip_offline_q', locale),
              answer: ProfileStrings.t('help_faq_trip_offline_a', locale),
            ),
          ],
        ),
        HelpFaqCategory(
          id: 'general',
          title: ProfileStrings.t('help_cat_general', locale),
          icon: '💬',
          items: [
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_general_report_q', locale),
              answer: ProfileStrings.t('help_faq_general_report_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_general_support_q', locale),
              answer: ProfileStrings.t('help_faq_general_support_a', locale),
            ),
            HelpFaqItem(
              question: ProfileStrings.t('help_faq_general_free_q', locale),
              answer: ProfileStrings.t(
                MonetizationState.showPremiumTierUi
                    ? 'help_faq_general_free_a'
                    : 'help_faq_general_free_a_community',
                locale,
              ),
            ),
          ],
        ),
      ];
}
