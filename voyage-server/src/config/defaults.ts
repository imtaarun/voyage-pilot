const config = {
  mongoURI: "mongodb://localhost:27017/voyage-pilot",
  port: 3000,
  secret: "voyage-secret",
  maxAge: 1000 * 60 * 60 * 24,
  GEMINI_API_KEY: 'AIzaSyDSnmgUfTZ1u3re8Xyye4B0Qv73c3D4tVE',
  GEMINI_API_URL: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite-preview-06-17:generateContent',
};

export default config;
