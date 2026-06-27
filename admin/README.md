# Raabta Admin Dashboard

React 18 + Vite + Tailwind admin panel for the Raabta Qatar expat platform.

## Stack

- **Frontend:** React 18, Vite, Tailwind CSS, Recharts, TanStack Table, React Quill
- **Auth:** Firebase Auth (admin@raabta.app only)
- **Backend:** Vercel serverless API routes with Firebase Admin SDK
- **Theme:** Dark mode matching the Flutter app (`#050A0F` background, `#22D3EE` primary)

## Pages

| Route | Page |
|-------|------|
| `/` | Overview — users, revenue, listings, AI usage, nationality pie chart |
| `/moderation` | Listing queue — approve/reject/flag, bulk approve, scam score filter |
| `/users` | User search, ban/suspend, grant premium |
| `/exchange-rates` | Edit exchange house rates, notify users on big changes |
| `/content` | Visa guides (rich text), doctors, businesses, announcements |
| `/ai-monitor` | AI conversations, flag wrong answers, API cost tracker |

## Local development

```bash
cd admin
npm install
npm run dev
```

Uses mock data by default (`VITE_USE_MOCK=true` in `.env.development`).

For full API + Firestore:

```bash
cp .env.example .env.local
# Fill in Firebase credentials
VITE_USE_MOCK=false
npx vercel dev
```

## Firebase setup

1. Create user **admin@raabta.app** in Firebase Console → Authentication
2. Set env vars on Vercel:
   - `FIREBASE_SERVICE_ACCOUNT_JSON` — full service account JSON string
   - `ADMIN_EMAIL=admin@raabta.app`
   - `ADMIN_KEY` — for push notification triggers via Railway backend
   - `BACKEND_URL=https://raabta-backend-production.up.railway.app`
3. Client env vars (Vite):
   - `VITE_FIREBASE_API_KEY`, `VITE_FIREBASE_APP_ID`, etc.

## Deploy to Vercel

```bash
cd admin
npx vercel
```

Or connect the `admin/` folder as root directory in Vercel dashboard.

## Deploy to Netlify

```bash
cd admin
npm run build
# Publish dist/ folder
# Add redirects: /* /index.html 200
# Add serverless functions from api/ folder
```

## Security

- Only `admin@raabta.app` can sign in (enforced client + server)
- All API routes verify Firebase ID token via Admin SDK
- Never commit `.env.local` or service account JSON
