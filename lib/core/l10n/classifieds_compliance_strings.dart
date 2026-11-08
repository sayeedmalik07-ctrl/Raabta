import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class ClassifiedsComplianceStrings {
  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  static final _catalog = <String, Map<String, String>>{
    'host_notice': l10nEntry(
      english:
          'Raabta is a free listings and community platform. Raabta is not a party to any sale, hire, rental or job offer and does not handle payments. Deal directly and check before you pay.',
      arabic:
          'رابطت منصة مجانية للإعلانات والمجتمع. رابطت ليست طرفاً في أي بيع أو توظيف أو إيجار أو عرض عمل ولا تتعامل مع المدفوعات. تفاوض مباشرة وتحقق قبل الدفع.',
      hindi:
          'राब्ता एक मुफ़्त लिस्टिंग और कम्युनिटी प्लेटफ़ॉर्म है। राब्ता किसी भी बिक्री, हायर, किराए या नौकरी के प्रस्ताव का पक्षकार नहीं है और भुगतान संभालता नहीं। सीधे बात करें और भुगतान से पहले जाँच करें।',
      urdu:
          'رابتا ایک مفت لسٹنگ اور کمیونٹی پلیٹ فارم ہے۔ رابتا کسی بھی فروخت، ہائر، کرایہ یا نوکری کی پیشکش کا فریق نہیں اور ادائیگی نہیں سنبھالتا۔ براہِ راست بات کریں اور ادائیگی سے پہلے تصدیق کریں۔',
      malayalam:
          'Raabta സൗജന്യ ലിസ്റ്റിംഗ്, കമ്മ്യൂണിറ്റി പ്ലാറ്റ്‌ഫോമാണ്. വിൽപ്പന, ഹയർ, വാടക, ജോലി offer എന്നിവയിൽ Raabta പാർട്ടി അല്ല; പേയ്‌മെന്റ് കൈകാര്യം ചെയ്യില്ല. നേരിട്ട് deal ചെയ്ത് pay ചെയ്യുന്നതിന് മുമ്പ് verify ചെയ്യുക.',
      nepali:
          'Raabta नि:शुल्क सूची र समुदाय प्लेटफर्म हो। Raabta कुनै बिक्री, hire, भाडा वा रोजगार प्रस्तावको पक्ष होइन र भुक्तानी सम्हाल्दैन। सिधै कुरा गर्नुहोस् र तिर्नुअघि जाँच गर्नुहोस्।',
      bengali:
          'রাবতা একটি বিনামূল্যের লিস্টিং ও কমিউনিটি প্ল্যাটফর্ম। রাবতা কোনো বিক্রয়, হায়ার, ভাড়া বা চাকরির প্রস্তাবের পক্ষ নয় এবং পেমেন্ট গ্রহণ করে না। সরাসরি যোগাযোগ করুন এবং pay করার আগে যাচাই করুন।',
      tamil:
          'Raabta இலவச listing மற்றும் community தளம். விற்பனை, hire, வாடகை அல்லது job offer-ஐ Raabta party அல்ல; பணம் பரிமாற்றம் செய்யாது. நேரடியாக deal செய்து pay செய்வதற்கு முன் verify செய்யுங்கள்.',
      filipino:
          'Ang Raabta ay libreng listings at community platform. Hindi partido ang Raabta sa anumang sale, hire, rental o job offer at hindi humahawak ng bayad. Direktang makipag-deal at i-verify bago magbayad.',
    ),
    'feature_unavailable': l10nEntry(
      english: 'This feature is currently unavailable.',
      arabic: 'هذه الميزة غير متاحة حالياً.',
      hindi: 'यह सुविधा अभी उपलब्ध नहीं है।',
      urdu: 'یہ فیچر فی الحال دستیاب نہیں۔',
      malayalam: 'ഈ feature ഇപ്പോൾ ലഭ്യമല്ല.',
      nepali: 'यो feature अहिले उपलब्ध छैन।',
      bengali: 'এই feature এখন unavailable।',
      tamil: 'இந்த feature இப்போது unavailable.',
      filipino: 'Hindi available ang feature na ito ngayon.',
    ),
    'post_trade_ack_label': l10nEntry(
      english:
          'I am responsible for any trade licence or permit my listing requires, and I understand Raabta is not a party to any transaction.',
      arabic:
          'أتحمل مسؤولية أي ترخيص تجاري أو تصريح يتطلبه إعلاني، وأفهم أن رابطت ليست طرفاً في أي معاملة.',
      hindi:
          'मेरी लिस्टिंग के लिए जो भी trade licence या permit चाहिए, उसकी ज़िम्मेदारी मेरी है, और मैं समझता/समझती हूँ कि Raabta किसी transaction का पक्षकार नहीं है।',
      urdu:
          'میری listing کے لیے درکار trade licence یا permit کی ذمہ داری میری ہے، اور میں سمجھتا/سمجھتی ہوں کہ Raabta کسی transaction کا فریق نہیں۔',
      malayalam:
          'എന്റെ listing-ന് ആവശ്യമായ trade licence/permit-ന്റെ ഉത്തരവാദിത്തം എന്റേതാണ്; Raabta യാതൊരു transaction-ന്റെയും പാർട്ടി അല്ലെന്ന് ഞാൻ മനസ്സിലാക്കുന്നു.',
      nepali:
          'मेरो listing लाई चाहिने trade licence वा permit को जिम्मेवारी मेरो हो, र Raabta कुनै transaction को पक्ष होइन भन्ने म बुझ्दछु।',
      bengali:
          'আমার listing-এর জন্য প্রয়োজনীয় trade licence বা permit-এর দায়িত্ব আমার, এবং Raabta কোনো transaction-এর পক্ষ নয় বুঝি।',
      tamil:
          'என் listing-க்கு தேவையான trade licence/permits-க்கு நான் பொறுப்பு; Raabta எந்த transaction-உம் party அல்ல என்பதை நான் புரிந்துகொள்கிறேன்.',
      filipino:
          'Ako ang responsable sa trade licence o permit na kailangan ng listing ko, at nauunawaan kong hindi partido ang Raabta sa anumang transaction.',
    ),
    'post_trade_ack_required': l10nEntry(
      english: 'Please confirm the listing responsibility statement before posting.',
      arabic: 'يرجى تأكيد بيان مسؤولية الإعلان قبل النشر.',
      hindi: 'पोस्ट करने से पहले listing responsibility statement की पुष्टि करें।',
      urdu: 'پوسٹ کرنے سے پہلے listing responsibility statement کی تصدیق کریں۔',
      malayalam:
          'പോസ്റ്റ് ചെയ്യുന്നതിന് മുമ്പ് listing responsibility statement സ്ഥിരീകരിക്കുക.',
      nepali:
          'पोस्ट गर्नुअघि listing responsibility statement पुष्टि गर्नुहोस्।',
      bengali:
          'পোস্ট করার আগে listing responsibility statement নিশ্চিত করুন।',
      tamil:
          'போஸ்ட் செய்வதற்கு முன் listing responsibility statement-ஐ உறுதிப்படுத்துங்கள்.',
      filipino:
          'Pakikumpirma ang listing responsibility statement bago mag-post.',
    ),
    'non_affiliation_notice': l10nEntry(
      english:
          'Raabta is an independent app. It is not affiliated with, endorsed by, or operated by any government entity.',
      arabic:
          'رابطت تطبيق مستقل. لا يرتبط بأي جهة حكومية ولا تعتمدها ولا تديرها.',
      hindi:
          'Raabta एक स्वतंत्र ऐप है। यह किसी सरकारी संस्था से संबद्ध, समर्थित या संचालित नहीं है।',
      urdu:
          'رابتا ایک آزاد ایپ ہے۔ یہ کسی سرکاری ادارے سے وابستہ، منظورشدہ یا زیرِ انتظام نہیں۔',
      malayalam:
          'Raabta ഒരു സ്വതന്ത്ര app ആണ്. യാതൊരു government entity-യുമായി ബന്ധപ്പെട്ടിട്ടില്ല, endors ചെയ്തിട്ടില്ല, operate ചെയ്യുന്നതുമല്ല.',
      nepali:
          'Raabta एक स्वतन्त्र app हो। यो कुनै सरकारी निकायसँग सम्बद्ध, endorsed वा operated छैन।',
      bengali:
          'রাবতা একটি স্বাধীন অ্যাপ। এটি কোনো সরকারি সংস্থার সঙ্গে affiliated, endorsed বা operated নয়।',
      tamil:
          'Raabta ஒரு independent app. எந்த அரசு entity-யுடனும் affiliated/endorsed/operated அல்ல.',
      filipino:
          'Ang Raabta ay independent app. Hindi affiliated, endorsed o operated ng anumang government entity.',
    ),
    'information_only_notice': l10nEntry(
      english:
          'Raabta gives general information based on published Qatar laws and official sources. It is not legal, immigration, financial or professional advice. Laws change, so confirm with the relevant ministry or a licensed professional before acting.',
      arabic:
          'تقدّم رابطت معلومات عامة مستندة إلى قوانين قطر المنشورة والمصادر الرسمية. ليست استشارة قانونية أو هجرة أو مالية أو مهنية. القوانين تتغير — تحقق من الوزارة المعنية أو مختص مرخّص قبل التصرف.',
      hindi:
          'Raabta प्रकाशित Qatar कानूनों और आधिकारिक स्रोतों पर आधारित सामान्य जानकारी देता है। यह कानूनी, immigration, वित्तीय या professional advice नहीं है। कानून बदलते हैं — कार्रवाई से पहले संबंधित ministry या licensed professional से पुष्टि करें।',
      urdu:
          'رابتا شائع شدہ Qatar قوانین اور سرکاری ذرائع پر مبنی عام معلومات دیتا ہے۔ یہ legal، immigration، مالی یا professional مشورہ نہیں۔ قوانین بدلتے ہیں — عمل سے پہلے متعلقہ ministry یا licensed professional سے تصدیق کریں۔',
      malayalam:
          'പ്രസിദ്ധീകരിച്ച Qatar നിയമങ്ങളും official sources-ഉം അടിസ്ഥാനമാക്കി Raabta പൊതുവിവരം നൽകുന്നു. Legal/immigration/financial/professional advice അല്ല. നിയമങ്ങൾ മാറാം — act ചെയ്യുന്നതിന് മുമ്പ് ministry അല്ലെങ്കിൽ licensed professional-യോട് confirm ചെയ്യുക.',
      nepali:
          'Raabta ले प्रकाशित Qatar कानून र official sources मा आधारित सामान्य जानकारी दिन्छ। यो legal, immigration, financial वा professional advice होइन। कानून बदलिन्छ — कारबाही अघि सम्बन्धित ministry वा licensed professional सँग पुष्टि गर्नुहोस्।',
      bengali:
          'রাবতা প্রকাশিত Qatar আইন ও official sources-এর ভিত্তিতে সাধারণ তথ্য দেয়। এটি legal, immigration, financial বা professional advice নয়। আইন পরিবর্তন হয় — action নেওয়ার আগে ministry বা licensed professional-এর সঙ্গে confirm করুন।',
      tamil:
          'வெளியிடப்பட்ட Qatar சட்டங்கள் மற்றும் official sources அடிப்படையில் Raabta பொது தகவல் வழங்குகிறது. Legal/immigration/financial/professional advice அல்ல. சட்டங்கள் மாறும் — action எடுப்பதற்கு முன் ministry அல்லது licensed professional-ஐ confirm செய்யுங்கள்.',
      filipino:
          'Nagbibigay ang Raabta ng pangkalahatang impormasyon batay sa published Qatar laws at official sources. Hindi legal, immigration, financial o professional advice. Nagbabago ang batas — kumpirmahin sa ministry o licensed professional bago kumilos.',
    ),
  };
}
