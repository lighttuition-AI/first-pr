// Create (or find) an admin user and grant the `admin: true` claim in one step —
// handy for provisioning the first HPark Command admin.
//
// Usage: node create_admin.mjs <email> <password>

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const [, , email, password] = process.argv;
if (!email || !password) {
  console.error('Usage: node create_admin.mjs <email> <password>');
  process.exit(1);
}

const sa = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({ credential: cert(sa) });
const auth = getAuth();

let user;
try {
  user = await auth.getUserByEmail(email);
} catch {
  user = await auth.createUser({ email, password, displayName: 'City Admin' });
}
await auth.setCustomUserClaims(user.uid, { admin: true });
console.log(`✅ Admin ready: ${email}  (uid ${user.uid})`);
process.exit(0);
