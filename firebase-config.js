import { initializeApp } from "https://www.gstatic.com/firebasejs/9.17.1/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/9.17.1/firebase-analytics.js";

const firebaseConfig = {
  apiKey: "AIzaSyBQ2bQ11NTLBAf46RDgD3obpbf762TZa5s",
  authDomain: "aiproject-90c33.firebaseapp.com",
  projectId: "aiproject-90c33",
  storageBucket: "aiproject-90c33.firebasestorage.app",
  messagingSenderId: "659817077360",
  appId: "1:659817077360:web:b9e30a4a8ba1190f05b2b5",
  measurementId: "G-SJ3FXBV5XF"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
