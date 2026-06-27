import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || 'AIzaSyB0G-ghacunshN_Yhw5gRY5Jngi8JT2z5E',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || 'raabta-27c6a.firebaseapp.com',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'raabta-27c6a',
  storageBucket:
    import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || 'raabta-27c6a.firebasestorage.app',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '320469579825',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '1:320469579825:web:97173ff8bf575b213dbd10',
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const ADMIN_EMAIL = import.meta.env.VITE_ADMIN_EMAIL || 'admin@raabta.app';
