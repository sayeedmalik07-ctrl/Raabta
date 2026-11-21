class GoldFaqItem {
  const GoldFaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// Static Qatar-adapted gold FAQ — bundled, no Firestore.
abstract final class GoldFaqContent {
  static const items = [
    GoldFaqItem(
      question: 'What is 24K vs 22K vs 21K vs 18K gold?',
      answer:
          'Karat (K) measures purity out of 24. 24K is ~99.9% pure gold — common for bars and coins. '
          '22K (~91.7%) is widely used for jewellery in South Asian and Gulf markets. '
          '21K and 18K contain more alloy for durability and are often used in lighter or stone-set pieces. '
          'This app derives all karat prices from the live 24K QAR rate using fixed purity ratios.',
    ),
    GoldFaqItem(
      question: 'Why does the price change during the day?',
      answer:
          'Gold is traded globally in USD. When international spot prices move, the QAR equivalent changes '
          'through Qatar\'s fixed USD peg (3.64). Local shop windows may lag slightly, but the reference rate '
          'here tracks spot and refreshes throughout the day.',
    ),
    GoldFaqItem(
      question: 'Is there VAT on gold in Qatar?',
      answer:
          'Investment-grade gold bars and coins are typically sold without VAT in Qatar. '
          'Jewellery may include making charges (craftsmanship fees) rather than VAT on the metal itself. '
          'Always confirm the invoice breakdown at the shop — this app separates gold value from making charges.',
    ),
    GoldFaqItem(
      question: 'What\'s the difference between gold price and jewellery price?',
      answer:
          'The gold price is the value of the metal by weight and purity. Jewellery adds a making charge '
          '(labour/design fee) on top. Coins and bars usually have little or no making charge. '
          'Use the calculator here to see gold value, making charge, and total separately.',
    ),
    GoldFaqItem(
      question: 'How often is this rate updated?',
      answer:
          'The backend fetches international spot gold and converts to QAR about every 30 minutes (Qatar time), '
          'with anchor refreshes twice daily. Timestamps on the card show when the last snapshot was saved. '
          'This is reference data — not a live exchange feed.',
    ),
    GoldFaqItem(
      question: 'What is a Tola / Sovereign?',
      answer:
          'A Tola is a traditional South Asian unit equal to 11.6638 grams — still quoted in many souqs. '
          'A Sovereign (often 8 grams in Gulf retail) is a common small bar/coin weight. '
          'Both are included in the weight table so you can compare like-for-like with shop quotes.',
    ),
  ];
}
