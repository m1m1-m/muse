const { initializeApp } = require("firebase/app");
const {
  getAuth,
  connectAuthEmulator,
  signInWithEmailAndPassword,
} = require("firebase/auth");

const firebaseConfig = {
  apiKey: "demo-api-key",
  authDomain: "muse-35420.firebaseapp.com",
  projectId: "muse-35420",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Connect to the Authentication Emulator
connectAuthEmulator(auth, "http://127.0.0.1:9099");

async function main() {
  try {
    const userCredential = await signInWithEmailAndPassword(
      auth,
      "test@example.com",
      "Password123"
    );

    const token = await userCredential.user.getIdToken();

    console.log("\n===== ID TOKEN =====\n");
    console.log(token);
    console.log("\n====================\n");
  } catch (err) {
    console.error(err);
  }
}

main();
