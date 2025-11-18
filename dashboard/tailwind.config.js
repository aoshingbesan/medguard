/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0fdfa',
          100: '#ccfbf1',
          200: '#99f6e4',
          300: '#5eead4',
          400: '#2dd4bf',
          500: '#14b8a6',
          600: '#176F5B', // Main brand color from Flutter app (#176F5B)
          700: '#0F4D40', // Dark variant from Flutter app (#0F4D40)
          800: '#0d9488',
          900: '#134e4a',
        },
      },
    },
  },
  plugins: [],
}

