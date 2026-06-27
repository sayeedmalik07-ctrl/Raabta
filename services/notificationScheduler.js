/**
 * Scheduled notification jobs — daily 8AM Qatar time + weekly digest Sunday 8AM.
 */

const cron = require('node-cron');
const {
  runDailyNotificationJobs,
  runWeeklyDigest,
} = require('./notifications');

let dailyJob = null;
let weeklyJob = null;

function startNotificationScheduler() {
  if (dailyJob || weeklyJob) {
    console.log('Notification scheduler already running');
    return;
  }

  // Every day at 8:00 AM Qatar time (Asia/Qatar)
  dailyJob = cron.schedule(
    '0 8 * * *',
    async () => {
      try {
        await runDailyNotificationJobs();
      } catch (err) {
        console.error('Daily notification job failed:', err);
      }
    },
    { timezone: 'Asia/Qatar' },
  );

  // Weekly digest — Sundays at 8:00 AM Qatar time
  weeklyJob = cron.schedule(
    '0 8 * * 0',
    async () => {
      try {
        await runWeeklyDigest();
      } catch (err) {
        console.error('Weekly digest job failed:', err);
      }
    },
    { timezone: 'Asia/Qatar' },
  );

  console.log('Notification scheduler started (daily 8AM + weekly Sunday 8AM Qatar)');
}

function stopNotificationScheduler() {
  if (dailyJob) dailyJob.stop();
  if (weeklyJob) weeklyJob.stop();
  dailyJob = null;
  weeklyJob = null;
}

module.exports = { startNotificationScheduler, stopNotificationScheduler };
