import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';

/// Versioned official-channel references — deep links and verified phone numbers.
///
/// Phone sources (verified Aug 2026):
/// - Ooredoo: https://www.ooredoo.qa/contact-us — 111 (Ooredoo line), +974 4420 0700
/// - Vodafone: https://www.vodafone.qa/en/help/scamandspam — 111 (Vodafone line), 800 7111
abstract final class ScamTelecomChannelsConfig {
  static const version = 2;

  static List<ScamTelecomChannel> channelsFor(ScamQatarTelecomProvider provider) {
    return switch (provider) {
      ScamQatarTelecomProvider.ooredoo => _ooredoo,
      ScamQatarTelecomProvider.vodafone => _vodafone,
      ScamQatarTelecomProvider.unknown => [..._ooredoo, ..._vodafone],
    };
  }

  static const _ooredoo = [
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_ooredoo_phone',
      phoneNumber: '+97444200700',
      detailKey: 'ss_sim_channel_ooredoo_phone_detail',
    ),
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_ooredoo_web',
      url: 'https://www.ooredoo.qa/',
      detailKey: 'ss_sim_channel_ooredoo_web_detail',
    ),
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_ooredoo_support',
      url: 'https://www.ooredoo.qa/web/en/help-and-support/',
      detailKey: 'ss_sim_channel_support_detail',
    ),
  ];

  static const _vodafone = [
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_vodafone_phone',
      phoneNumber: '8007111',
      detailKey: 'ss_sim_channel_vodafone_phone_detail',
    ),
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_vodafone_web',
      url: 'https://www.vodafone.qa/',
      detailKey: 'ss_sim_channel_vodafone_web_detail',
    ),
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_vodafone_support',
      url: 'https://www.vodafone.qa/en/help-and-support',
      detailKey: 'ss_sim_channel_support_detail',
    ),
    ScamTelecomChannel(
      labelKey: 'ss_sim_channel_vodafone_scam',
      url: 'https://www.vodafone.qa/en/help/scamandspam',
      detailKey: 'ss_sim_channel_vodafone_scam_detail',
    ),
  ];
}
