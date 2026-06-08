// Create (or update) an officer auth account + an APPROVED officer record, so you
// can sign straight into HPark Enforce for testing without the signup→approval dance.
//
// Usage: node create_officer.mjs <email> <password> [districtId]

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const [, , email, password, districtId = 'ahmed-dhagah'] = process.argv;
if (!email || !password) {
  console.error('Usage: node create_officer.mjs <email> <password> [districtId]');
  process.exit(1);
}

const sa = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({ credential: cert(sa) });
const auth = getAuth();
const db = getFirestore();

let user;
try {
  user = await auth.getUserByEmail(email);
} catch {
  user = await auth.createUser({ email, password, displayName: 'Demo Officer' });
}

const counterRef = db.collection('counters').doc('officers');
const number = await db.runTransaction(async (tx) => {
  const snap = await tx.get(counterRef);
  const next = ((snap.data()?.value ?? 200) | 0) + 1;
  tx.set(counterRef, { value: next });
  return next;
});
const numStr = String(number).padStart(3, '0');

await db.collection('officers').doc(user.uid).set({
  id: user.uid,
  fullName: user.displayName || 'Demo Officer',
  nationalId: 'SL-0001-0001',
  phone: '+252 63 4000 000',
  dateOfBirth: new Date(1995, 0, 1).getTime(),
  badgeNumber: `HG-OFR-${numStr}`,
  status: 'approved',
  appliedAt: Date.now(),
  email,
  assignedDistrictId: districtId,
  approvedAt: Date.now(),
  approvedBy: 'City Admin',
  reviewNote: '',
  citationsIssued: 0,
  photoUrl: null,
});

console.log(`✅ Approved officer ready: ${email}  (uid ${user.uid}, badge HG-OFR-${numStr})`);
process.exit(0);
