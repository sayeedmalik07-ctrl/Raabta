/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        background: '#050A0F',
        surface: '#0D1520',
        'surface-elevated': '#111D2C',
        card: '#0F1923',
        primary: '#22D3EE',
        'primary-dark': '#0891B2',
        secondary: '#6366F1',
        accent: '#A78BFA',
        gold: '#FFB800',
        success: '#34D399',
        warning: '#FBBF24',
        error: '#F87171',
        info: '#60A5FA',
        'text-primary': '#E8EDF5',
        'text-secondary': '#8A9BB0',
        'text-muted': '#4A5568',
        border: 'rgba(255,255,255,0.1)',
        'border-highlight': 'rgba(255,255,255,0.2)',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        glow: '0 0 20px rgba(34, 211, 238, 0.15)',
      },
    },
  },
  plugins: [],
};
