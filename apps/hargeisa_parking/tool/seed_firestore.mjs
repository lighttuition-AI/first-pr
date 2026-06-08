// Seed Firestore with the Hargeisa Parking demo data (officers, vehicles, appeals)
// so HPark Command has something to act on the moment you go live.
//
// Usage:
//   1. Firebase console → Project settings → Service accounts → Generate new private
//      key → save it here as `serviceAccountKey.json` (git-ignored).
//   2. npm install        (first time only)
//   3. node seed_firestore.mjs
//
// Field names mirror the Dart models (e.g. Officer.toMap): dates are epoch millis,
// enums are stored by name.

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccount = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const ms = (y, mo, d, h = 0, mi = 0) => new Date(y, mo - 1, d, h, mi).getTime();

const officers = [
  { id: 'OFR-118', fullName: 'Amina Yusuf', nationalId: 'SL-9920-1183', phone: '+252 63 4412 118', dateOfBirth: ms(1994, 3, 12), badgeNumber: 'HG-OFR-118', status: 'approved', appliedAt: ms(2026, 1, 8), assignedDistrictId: 'ahmed-dhagah', approvedAt: ms(2026, 1, 9), approvedBy: 'Hodan Ali', reviewNote: '', citationsIssued: 412, photoUrl: null },
  { id: 'OFR-104', fullName: 'Khadar Jama', nationalId: 'SL-8814-2204', phone: '+252 63 4419 104', dateOfBirth: ms(1990, 11, 2), badgeNumber: 'HG-OFR-104', status: 'approved', appliedAt: ms(2026, 1, 6), assignedDistrictId: 'mohamed-mooge', approvedAt: ms(2026, 1, 7), approvedBy: 'Hodan Ali', reviewNote: '', citationsIssued: 389, photoUrl: null },
  { id: 'OFR-127', fullName: 'Liban Warsame', nationalId: 'SL-9133-7781', phone: '+252 63 4471 127', dateOfBirth: ms(1996, 6, 24), badgeNumber: 'HG-OFR-127', status: 'pending', appliedAt: ms(2026, 6, 7, 9, 14), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
  { id: 'OFR-128', fullName: 'Sahra Abdi', nationalId: 'SL-9542-3360', phone: '+252 63 4471 128', dateOfBirth: ms(1999, 2, 9), badgeNumber: 'HG-OFR-128', status: 'pending', appliedAt: ms(2026, 6, 7, 16, 2), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
  { id: 'OFR-129', fullName: 'Mustafe Cabdi', nationalId: 'SL-9077-1145', phone: '+252 63 4471 129', dateOfBirth: ms(1993, 8, 30), badgeNumber: 'HG-OFR-129', status: 'pending', appliedAt: ms(2026, 6, 8, 7, 41), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
];

const vehicles = [
  { plate: 'HG-4821', ownerName: 'Cabdi Jaamac', ownerNationalId: 'SL-7741-0098', make: 'Toyota Vitz', color: 'Silver', permitStatus: 'none', outstandingCount: 2, outstandingTotal: 370000 },
  { plate: 'HG-1190', ownerName: 'Hodan Maxamed', ownerNationalId: 'SL-3320-7711', make: 'Nissan Sunny', color: 'White', permitStatus: 'valid', outstandingCount: 0, outstandingTotal: 0 },
  { plate: 'HG-7732', ownerName: 'Maxamed Cali', ownerNationalId: 'SL-9012-4456', make: 'Toyota Mark X', color: 'Black', permitStatus: 'expired', outstandingCount: 1, outstandingTotal: 120000 },
];

const appeals = [
  { id: 'APL-2026-0142', citationId: 'CIT-2026-04821', plate: 'HG-4821', violation: 'Parked in a no-parking zone', fine: 250000, reason: 'The no-parking sign was hidden behind a market stall.', videoSeconds: 38, submittedAt: ms(2026, 6, 7, 11, 20), appellantName: 'Cabdi Jaamac', status: 'review', decidedBy: null },
  { id: 'APL-2026-0139', citationId: 'CIT-2026-04655', plate: 'HG-7732', violation: 'Expired parking session', fine: 120000, reason: 'I paid via ZAAD but the session did not extend.', videoSeconds: 52, submittedAt: ms(2026, 6, 6, 16, 5), appellantName: 'Maxamed Cali', status: 'review', decidedBy: null },
];

async function run() {
  const batch = db.batch();
  for (const o of officers) batch.set(db.collection('officers').doc(o.id), o);
  for (const v of vehicles) batch.set(db.collection('vehicles').doc(v.plate), v);
  for (const a of appeals) batch.set(db.collection('appeals').doc(a.id), a);
  batch.set(db.collection('counters').doc('officers'), { value: 200 });
  await batch.commit();
  console.log(`Seeded ${officers.length} officers, ${vehicles.length} vehicles, ${appeals.length} appeals, counter=200.`);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
