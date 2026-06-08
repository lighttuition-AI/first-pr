// Grant the `admin: true` custom auth claim to a user, so they can approve
// officers and manage data in HPark Command (the Firestore rules check this claim).
//
// Usage:
//   1. Sign up your admin account once in the app (or Firebase console → Auth).
//   2. node grant_admin.mjs <UID or email>
//   3. That user signs out and back in for the claim to take effect.

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const arg = process.argv[2];
if (!arg) {
  console.error('Usage: node grant_admin.mjs <UID or email>');
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth();

async function run() {
  const user = arg.includes('@') ? await auth.getUserByEmail(arg) : await auth.getUser(arg);
  await auth.setCustomUserClaims(user.uid, { admin: true });
  console.log(`✅ ${user.email ?? user.uid} is now an admin. They must sign out and back in.`);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e.message); process.exit(1); });
