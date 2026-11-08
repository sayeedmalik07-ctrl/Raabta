/// Tunable local keyword/pattern lists for fundraising-solicitation moderation.
///
/// Adjust patterns here without changing prefilter logic.
abstract final class CommunityFundraisingModerationConfig {
  /// Strong local matches — trigger warn interstitial (not hard block).
  static const List<String> flagPatterns = [
    // English — private transfers / collections
    r'\b(send|transfer|wire|pay)\b.{0,40}\b(qar|qr|riyal|cash|money|amount)\b.{0,60}\b(account|iban|number|wallet)\b',
    r'\b(donate|donation|contribute|contribution|chip in)\b.{0,50}\b(to|for)\b.{0,40}\b(my|his|her|their|this|private|personal)\b',
    r'\bcollecting for\b',
    r'\bcontribute for (the )?(family|colleague|friend|worker|patient)\b',
    r'\bhelp needed\b.{0,40}\b(urgent )?(transfer|payment|money)\b',
    r'\b(iban|account number|bank details|wallet address)\b.{0,80}\b(donate|donation|help|family|urgent|collect)\b',
    r'\b(donate|donation|zakat|sadaqah|sadaqa|sadaqat|fitra|fitrana)\b.{0,40}\b(to this|on this|this number|this account)\b',
    r'\bplease send\b.{0,30}\b(qar|qr|for the family)\b',
    // Arabic script / mixed
    r'(ارسل|أرسل|إرسال|ارسال|حول|تبرع|تبرعات|جمع(?:نا)?|مساعدة(?: عاجلة)?).{0,50}(حساب|آيبان|iban|رقم)',
    r'(ريال|qar|qr).{0,40}(حساب|آيبان|iban)',
    r'(حساب|آيبان).{0,40}(عائلة|أسرة|زميل|family)',
    r'(زكاة|صدقة|فطرة|فطر).{0,40}(هذا الرقم|هذا الحساب|للحساب)',
    r'جمع(?:نا)?(?: ل)?(?: تذكرة| أسرة| عائلة| زميل)',
    r'(براہ کرم|براہِ کرم).{0,50}(اکاؤنٹ|account|حساب).{0,50}(بھیج|send|transfer)',
    r'(خاندان|colleague|زميل).{0,40}(اکاؤنٹ|account|حساب|iban)',
    // Hindi / Urdu (Latin transliteration common in groups)
    r'\b(bhejo|bhej do|transfer karo|account par)\b.{0,50}\b(qar|paisa|rupee|family|madad)\b',
    r'\b(donate karo|chanda|collection chal|jama kar)\b.{0,60}\b(account|iban|number par)\b',
    r'\b(zakat|sadaqah|fitra)\b.{0,30}\b(is number|is account|account par)\b',
    r'\bmadad chahiye\b.{0,40}\b(jaldi|urgent)\b.{0,30}\b(transfer|paisa|account)\b',
    // Malayalam / Tamil / Bengali / Nepali — key loanwords + account cues
    r'\b(donate|collection|fund)\b.{0,40}\b(iban|account)\b',
    r'(تبرع|दान|দান|நன்கொடை|दान).{0,40}(account|iban|number)',
  ];

  /// Benign discussion — skip flag even if a weak keyword appears elsewhere.
  static const List<String> allowPatterns = [
    r'\bhow (do|can|to) i\b.{0,40}\b(pay|give|donate)\b.{0,40}\b(zakat|sadaqah|charity)\b',
    r'\bofficial charity\b',
    r'\brecognised charity\b',
    r'\brecognized charity\b',
    r'\bthrough an official\b',
    r'\bqatar charity\b(?!.{0,40}\b(send|transfer|account|iban|number par|bhejo)\b)',
    r'\bcharity is running a campaign\b',
    r'\bcharity campaign\b',
    r'\blending a hand\b',
    r'\bhelp moving\b',
    r'\bmove a sofa\b',
    r'\bmove (my|the) sofa\b',
    r'\breward for (lost|found)\b',
    r'\blost and found reward\b',
    r'\b(salary|eosb|remittance|end of service)\b',
    r'\b(كيف|how|کیسے).{0,40}(زكاة|zakat|زکوٰة|زکات).{0,40}(رسمي|official|charity|خیریت|سرکاری)\b',
    r'\b(zakat rules|rules of zakat)\b',
    r'\bofficial channel\b',
    r'(سرکاری|recognised|recognized).{0,30}(charity|خیریت).{0,30}(zakat|زکوٰة|زكاة)',
  ];
}
