import 'package:flutter/material.dart';

class AiChatTopic {
  const AiChatTopic({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.promptKey,
  });

  final String id;
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final String promptKey;
}

abstract final class AiChatTopicsCatalog {
  static const nativeChipIds = ['eosb', 'visa', 'document', 'labour'];

  static const topics = [
    AiChatTopic(
      id: 'general',
      icon: Icons.chat_bubble_outline_rounded,
      titleKey: 'ai_cat_general_title',
      descriptionKey: 'ai_cat_general_desc',
      promptKey: 'ai_cat_general_prompt',
    ),
    AiChatTopic(
      id: 'document',
      icon: Icons.description_outlined,
      titleKey: 'ai_cat_document_title',
      descriptionKey: 'ai_cat_document_desc',
      promptKey: 'ai_cat_document_prompt',
    ),
    AiChatTopic(
      id: 'translation',
      icon: Icons.translate_rounded,
      titleKey: 'ai_cat_translation_title',
      descriptionKey: 'ai_cat_translation_desc',
      promptKey: 'ai_cat_translation_prompt',
    ),
    AiChatTopic(
      id: 'labour',
      icon: Icons.balance_outlined,
      titleKey: 'ai_cat_labour_title',
      descriptionKey: 'ai_cat_labour_desc',
      promptKey: 'ai_cat_labour_prompt',
    ),
    AiChatTopic(
      id: 'finance',
      icon: Icons.account_balance_wallet_outlined,
      titleKey: 'ai_cat_finance_title',
      descriptionKey: 'ai_cat_finance_desc',
      promptKey: 'ai_cat_finance_prompt',
    ),
    AiChatTopic(
      id: 'healthcare',
      icon: Icons.local_hospital_outlined,
      titleKey: 'ai_cat_health_title',
      descriptionKey: 'ai_cat_health_desc',
      promptKey: 'ai_cat_health_prompt',
    ),
    AiChatTopic(
      id: 'housing',
      icon: Icons.home_outlined,
      titleKey: 'ai_cat_housing_title',
      descriptionKey: 'ai_cat_housing_desc',
      promptKey: 'ai_cat_housing_prompt',
    ),
    AiChatTopic(
      id: 'visa',
      icon: Icons.flight_takeoff_outlined,
      titleKey: 'ai_cat_visa_title',
      descriptionKey: 'ai_cat_visa_desc',
      promptKey: 'ai_cat_visa_prompt',
    ),
    AiChatTopic(
      id: 'career',
      icon: Icons.work_outline_rounded,
      titleKey: 'ai_cat_career_title',
      descriptionKey: 'ai_cat_career_desc',
      promptKey: 'ai_cat_career_prompt',
    ),
  ];
}
