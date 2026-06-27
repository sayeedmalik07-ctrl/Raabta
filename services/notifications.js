/**
 * Raabta Push Notification Service
 * FCM delivery, translation, quiet hours, in-app notification persistence.
 */

const firestoreService = require('./firestoreService');

const NOTIFICATION_TYPES = {
  IQAMA_EXPIRY: 'iqama_expiry',
  HOUSING_MATCH: 'housing_match',
  RATE_ALERT: 'rate_alert',
  COMMUNITY_REPLY: 'community_reply',
  JOB_MATCH: 'job_match',
  WEEKLY_DIGEST: 'weekly_digest',
  ADMIN_ANNOUNCEMENT: 'admin_announcement',
};

const EXPIRY_OFFSETS = [90, 60, 30, 14, 7, 3, 1];

const DEFAULT_SETTINGS = {
  iqamaExpiry: true,
  housingMatch: true,
  rateAlert: true,
  communityReply: true,
  jobMatch: true,
  weeklyDigest: true,
  adminAnnouncement: true,
  quietHoursEnabled: true,
  quietHoursStart: 23,
  quietHoursEnd: 7,
};

const TRANSLATIONS = {
  iqama_expiry_title: {
    English: 'Iqama Expiring Soon',
    Urdu: 'اقامہ جلد ختم ہو رہا ہے',
    Hindi: 'इकामा जल्द समाप्त हो रहा है',
    Arabic: 'الإقامة تنتهي قريباً',
    Filipino: 'Malapit nang mag-expire ang Iqama',
    Bengali: 'ইকামা শীঘ্রই মেয়াদ শেষ',
  },
  iqama_expiry_body: {
    English: (days) =>
      `Your Iqama expires in ${days} day${days === 1 ? '' : 's'}. Tap to renew now.`,
    Urdu: (days) => `آپ کا اقامہ ${days} دن${days === 1 ? '' : ' میں'} ختم ہو رہا ہے`,
    Hindi: (days) => `आपका इकामा ${days} दिन${days === 1 ? '' : 'ों'} में समाप्त हो रहा है`,
    Arabic: (days) => `إقامتك تنتهي خلال ${days} ${days === 1 ? 'يوم' : 'أيام'}`,
    Filipino: (days) =>
      `Mag-e-expire ang Iqama mo sa ${days} araw. I-renew na ngayon.`,
    Bengali: (days) => `আপনার ইকামা ${days} দিন${days === 1 ? '' : 'ে'} শেষ হচ্ছে`,
  },
  housing_match_title: {
    English: 'New Housing Match',
    Urdu: 'نئی رہائش مل گئی',
    Hindi: 'नया आवास मिला',
    Arabic: 'سكن جديد متاح',
    Filipino: 'Bagong tirahan',
    Bengali: 'নতুন বাসস্থান',
  },
  rate_alert_title: {
    English: 'Exchange Rate Alert',
    Urdu: 'شرح مبادلہ الرٹ',
    Hindi: 'विनिमय दर अलर्ट',
    Arabic: 'تنبيه سعر الصرف',
    Filipino: 'Rate Alert',
    Bengali: 'হার সতর্কতা',
  },
  community_reply_title: {
    English: 'New Community Reply',
    Urdu: 'نیا جواب',
    Hindi: 'नया जवाब',
    Arabic: 'رد جديد',
    Filipino: 'Bagong sagot',
    Bengali: 'নতুন উত্তর',
  },
  job_match_title: {
    English: 'New Job Match',
    Urdu: 'نئی نوکری',
    Hindi: 'नई नौकरी',
    Arabic: 'وظيفة جديدة',
    Filipino: 'Bagong trabaho',
    Bengali: 'নতুন চাকরি',
  },
  weekly_digest_title: {
    English: 'Your Weekly Raabta Digest',
    Urdu: 'ہفتہ وار خلاصہ',
    Hindi: 'साप्ताहिक सारांश',
    Arabic: 'ملخصك الأسبوعي',
    Filipino: 'Lingguhang buod',
    Bengali: 'সাপ্তাহিক সারাংশ',
  },
  admin_title: {
    English: 'Raabta Announcement',
    Urdu: 'رابطہ اعلان',
    Hindi: 'राब्ता घोषणा',
    Arabic: 'إعلان رابطة',
    Filipino: 'Anunsyo',
    Bengali: 'ঘোষণা',
  },
};

function getDb() {
  return firestoreService.getDb();
}

function getMessaging() {
  return firestoreService.getMessaging();
}

function resolveLanguage(language) {
  const lang = String(language || 'English').trim();
  if (TRANSLATIONS.iqama_expiry_title[lang]) return lang;
  if (lang.includes('Urdu') || lang.includes('اردو')) return 'Urdu';
  if (lang.includes('Hindi') || lang.includes('हिंदी')) return 'Hindi';
  if (lang.includes('Arabic') || lang.includes('العربية')) return 'Arabic';
  if (lang.includes('Filipino')) return 'Filipino';
  if (lang.includes('Bengali') || lang.includes('বাংলা')) return 'Bengali';
  return 'English';
}

function translate(key, language, ...args) {
  const lang = resolveLanguage(language);
  const entry = TRANSLATIONS[key];
  if (!entry) return args[0] || '';
  const value = entry[lang] || entry.English;
  return typeof value === 'function' ? value(...args) : value;
}

function typeSettingKey(type) {
  const map = {
    [NOTIFICATION_TYPES.IQAMA_EXPIRY]: 'iqamaExpiry',
    [NOTIFICATION_TYPES.HOUSING_MATCH]: 'housingMatch',
    [NOTIFICATION_TYPES.RATE_ALERT]: 'rateAlert',
    [NOTIFICATION_TYPES.COMMUNITY_REPLY]: 'communityReply',
    [NOTIFICATION_TYPES.JOB_MATCH]: 'jobMatch',
    [NOTIFICATION_TYPES.WEEKLY_DIGEST]: 'weeklyDigest',
    [NOTIFICATION_TYPES.ADMIN_ANNOUNCEMENT]: 'adminAnnouncement',
  };
  return map[type];
}

function isQuietHours(settings) {
  if (!settings?.quietHoursEnabled) return false;
  const now = new Date();
  const qatarHour = parseInt(
    new Intl.DateTimeFormat('en-GB', {
      hour: 'numeric',
      hour12: false,
      timeZone: 'Asia/Qatar',
    }).format(now),
    10,
  );
  const start = settings.quietHoursStart ?? 23;
  const end = settings.quietHoursEnd ?? 7;
  if (start > end) return qatarHour >= start || qatarHour < end;
  return qatarHour >= start && qatarHour < end;
}

async function getUserRecord(userId) {
  const db = getDb();
  if (!db) return null;
  const doc = await db.collection('users').doc(userId).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

async function getNotificationSettings(userId) {
  const db = getDb();
  if (!db) return { ...DEFAULT_SETTINGS };

  const doc = await db
    .collection('users')
    .doc(userId)
    .collection('settings')
    .doc('notifications')
    .get();

  return { ...DEFAULT_SETTINGS, ...(doc.exists ? doc.data() : {}) };
}

async function saveInAppNotification(userId, notification) {
  const db = getDb();
  if (!db) return null;

  const ref = db.collection('users').doc(userId).collection('notifications').doc();
  const payload = {
    id: ref.id,
    title: notification.title,
    body: notification.body,
    type: notification.type || 'general',
    route: notification.route || '/home',
    data: notification.data || {},
    read: false,
    createdAt: new Date().toISOString(),
  };
  await ref.set(payload);
  return payload;
}

async function sendPushNotification({
  userId,
  title,
  body,
  data = {},
  language,
  type = 'general',
  skipQuietHours = false,
}) {
  const user = await getUserRecord(userId);
  const settings = await getNotificationSettings(userId);
  const userLang = language || user?.notificationLanguage || user?.language || 'English';
  const resolvedLang = resolveLanguage(userLang);

  const settingKey = typeSettingKey(type);
  if (settingKey && settings[settingKey] === false) {
    return { sent: false, reason: 'type_disabled', type };
  }

  if (!skipQuietHours && isQuietHours(settings)) {
    await saveInAppNotification(userId, {
      title: translateTitle(title, resolvedLang, type),
      body: translateBody(body, resolvedLang, type),
      type,
      route: data.route || '/home',
      data,
    });
    return { sent: false, reason: 'quiet_hours', queued: true };
  }

  const translatedTitle = translateTitle(title, resolvedLang, type);
  const translatedBody = translateBody(body, resolvedLang, type);

  const inApp = await saveInAppNotification(userId, {
    title: translatedTitle,
    body: translatedBody,
    type,
    route: data.route || '/home',
    data,
  });

  const token = user?.fcmToken;
  const messaging = getMessaging();

  if (!token || !messaging) {
    return {
      sent: false,
      reason: token ? 'messaging_unavailable' : 'no_token',
      inApp,
    };
  }

  try {
    const messageId = await messaging.send({
      token,
      notification: { title: translatedTitle, body: translatedBody },
      data: {
        ...Object.fromEntries(
          Object.entries({ ...data, type, notificationId: inApp?.id || '' }).map(
            ([k, v]) => [k, String(v)],
          ),
        ),
      },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });

    return { sent: true, messageId, inApp, language: resolvedLang };
  } catch (err) {
    console.error(`FCM send failed for ${userId}:`, err.message);
    if (err.code === 'messaging/registration-token-not-registered') {
      const db = getDb();
      if (db) {
        await db.collection('users').doc(userId).set({ fcmToken: null }, { merge: true });
      }
    }
    return { sent: false, reason: err.message, inApp };
  }
}

function translateTitle(title, lang, type) {
  if (typeof title === 'string' && title.startsWith('__')) {
    const key = title.slice(2);
    return translate(key, lang);
  }
  const typeTitles = {
    iqama_expiry: translate('iqama_expiry_title', lang),
    housing_match: translate('housing_match_title', lang),
    rate_alert: translate('rate_alert_title', lang),
    community_reply: translate('community_reply_title', lang),
    job_match: translate('job_match_title', lang),
    weekly_digest: translate('weekly_digest_title', lang),
    admin_announcement: translate('admin_title', lang),
  };
  return typeTitles[type] || title;
}

function translateBody(body, lang, type) {
  if (typeof body === 'object' && body?.key && body?.days != null) {
    return translate(body.key, lang, body.days);
  }
  return body;
}

async function registerFcmToken(userId, fcmToken, platform = 'unknown') {
  const db = getDb();
  if (!db) return { saved: false };

  await db.collection('users').doc(userId).set(
    {
      fcmToken,
      fcmPlatform: platform,
      fcmUpdatedAt: new Date().toISOString(),
    },
    { merge: true },
  );

  return { saved: true };
}

function daysUntil(dateStr) {
  const expiry = new Date(dateStr);
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  expiry.setHours(0, 0, 0, 0);
  return Math.round((expiry - now) / 86400000);
}

async function runIqamaExpiryChecks() {
  const db = getDb();
  if (!db) return { processed: 0 };

  const snapshot = await db.collection('users').get();
  let sent = 0;

  for (const doc of snapshot.docs) {
    const user = doc.data();
    const userId = doc.id;
    const expiries = user.documentExpiries || user.deadlines || [];

    for (const item of expiries) {
      const expiryDate = item.expiryDate || item.date;
      if (!expiryDate) continue;

      const days = daysUntil(expiryDate);
      if (!EXPIRY_OFFSETS.includes(days)) continue;

      const sentKey = `iqama_alert_${item.id || item.documentType}_${days}`;
      if (user[sentKey]) continue;

      const result = await sendPushNotification({
        userId,
        title: '__iqama_expiry_title',
        body: { key: 'iqama_expiry_body', days },
        type: NOTIFICATION_TYPES.IQAMA_EXPIRY,
        data: {
          route: '/visa',
          guideId: item.guideId || 'iqama_renewal',
          daysRemaining: String(days),
          documentType: item.documentType || 'Iqama',
        },
      });

      if (result.sent || result.queued) {
        await db.collection('users').doc(userId).set({ [sentKey]: true }, { merge: true });
        sent += 1;
      }
    }
  }

  return { processed: snapshot.size, sent };
}

async function runHousingMatchNotifications() {
  const db = getDb();
  if (!db) return { sent: 0 };

  const [usersSnap, listingsSnap] = await Promise.all([
    db.collection('users').get(),
    db.collection('listings').where('status', '==', 'approved').limit(50).get(),
  ]);

  const listings = listingsSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  let sent = 0;

  for (const userDoc of usersSnap.docs) {
    const user = userDoc.data();
    const searches = user.savedSearches || user.housingPreferences || [];
    if (!searches.length && !user.preferredArea) continue;

    const area = user.preferredArea || searches[0]?.area;
    const maxPrice = user.budgetRange?.max || searches[0]?.maxPrice || 99999;

    const matches = listings.filter(
      (l) =>
        (!area || l.area === area) &&
        (l.pricePerMonth || l.price) <= maxPrice,
    );

    if (!matches.length) continue;

    const top = matches[0];
    const result = await sendPushNotification({
      userId: userDoc.id,
      title: '__housing_match_title',
      body: `New ${top.type || 'listing'} in ${top.area} — ${top.pricePerMonth || top.price} QR/month`,
      type: NOTIFICATION_TYPES.HOUSING_MATCH,
      data: { route: '/housing', listingId: top.id },
    });

    if (result.sent || result.queued) sent += 1;
  }

  return { sent };
}

async function runRateAlertNotifications() {
  const db = getDb();
  if (!db) return { sent: 0 };

  let todayRate = 22.85;
  try {
    const rateDoc = await db.collection('exchange_rates').doc('INR').get();
    if (rateDoc.exists) {
      todayRate = rateDoc.data().today || rateDoc.data().rate || todayRate;
    }
  } catch (_) {
    /* use default */
  }

  const usersSnap = await db.collection('users').get();
  let sent = 0;

  for (const userDoc of usersSnap.docs) {
    const user = userDoc.data();
    const alerts = user.rateAlerts || [];
    for (const alert of alerts) {
      if (alert.currency !== 'INR') continue;
      if (todayRate < alert.targetRate) continue;

      const result = await sendPushNotification({
        userId: userDoc.id,
        title: '__rate_alert_title',
        body: `INR reached ${todayRate.toFixed(2)} — your target was ${alert.targetRate}`,
        type: NOTIFICATION_TYPES.RATE_ALERT,
        data: { route: '/money', currency: 'INR', rate: String(todayRate) },
      });

      if (result.sent || result.queued) sent += 1;
    }
  }

  return { sent };
}

async function sendCommunityReplyNotification(userId, { questionTitle, replyPreview }) {
  return sendPushNotification({
    userId,
    title: '__community_reply_title',
    body: `Someone answered "${questionTitle}": ${replyPreview}`,
    type: NOTIFICATION_TYPES.COMMUNITY_REPLY,
    data: { route: '/community' },
  });
}

async function sendJobMatchNotification(userId, { jobTitle, company, matchScore }) {
  return sendPushNotification({
    userId,
    title: '__job_match_title',
    body: `${jobTitle} at ${company} — ${matchScore}% match`,
    type: NOTIFICATION_TYPES.JOB_MATCH,
    data: { route: '/jobs' },
  });
}

async function runWeeklyDigest() {
  const db = getDb();
  if (!db) return { sent: 0 };

  const usersSnap = await db.collection('users').get();
  let sent = 0;

  for (const userDoc of usersSnap.docs) {
    const user = userDoc.data();
    const area = user.preferredArea || 'Al Khor';

    const result = await sendPushNotification({
      userId: userDoc.id,
      title: '__weekly_digest_title',
      body: `Top picks in ${area}: 3 housing listings + 3 jobs matched for you this week.`,
      type: NOTIFICATION_TYPES.WEEKLY_DIGEST,
      data: { route: '/home' },
    });

    if (result.sent || result.queued) sent += 1;
  }

  return { sent };
}

async function sendAdminAnnouncement(userIds, { title, body, route = '/news' }) {
  const results = [];
  const targets = userIds?.length
    ? userIds
    : (await getDb()?.collection('users').get())?.docs.map((d) => d.id) || [];

  for (const userId of targets) {
    const result = await sendPushNotification({
      userId,
      title: title || '__admin_title',
      body,
      type: NOTIFICATION_TYPES.ADMIN_ANNOUNCEMENT,
      data: { route },
      skipQuietHours: true,
    });
    results.push({ userId, ...result });
  }

  return results;
}

async function runDailyNotificationJobs() {
  console.log('--- Daily notification job started ---', new Date().toISOString());

  const expiry = await runIqamaExpiryChecks();
  const housing = await runHousingMatchNotifications();
  const rates = await runRateAlertNotifications();

  console.log('--- Daily notifications complete ---', { expiry, housing, rates });
  return { expiry, housing, rates };
}

module.exports = {
  NOTIFICATION_TYPES,
  EXPIRY_OFFSETS,
  sendPushNotification,
  registerFcmToken,
  runIqamaExpiryChecks,
  runHousingMatchNotifications,
  runRateAlertNotifications,
  runWeeklyDigest,
  runDailyNotificationJobs,
  sendCommunityReplyNotification,
  sendJobMatchNotification,
  sendAdminAnnouncement,
  translate,
  resolveLanguage,
};
