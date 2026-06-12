// Seed Firestore with the Hargeisa Parking *reference* data so the apps have a
// real starting point: the officer roster (incl. a few pending registrations to
// approve in HPark Command), the vehicle registry an officer's plate lookup
// checks against, and the district shop deals shown in HPark Pay.
//
// Transactional data (citations, appeals) is deliberately NOT seeded — it is
// created by the real flow: an officer issues a citation in HPark Enforce, the
// driver pays/appeals it in HPark Pay, the city decides appeals in HPark Command.
//
// Usage:
//   1. Firebase console → Project settings → Service accounts → Generate new private
//      key → save it here as `serviceAccountKey.json` (git-ignored).
//   2. npm install        (first time only)
//   3. node seed_firestore.mjs
//
// Field names mirror the Dart models (e.g. Vehicle.toMap / Deal.toMap): dates are
// epoch millis, enums are stored by name. Idempotent — safe to re-run.

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccount = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const ms = (y, mo, d, h = 0, mi = 0) => new Date(y, mo - 1, d, h, mi).getTime();

// Demo officer roster. Approved officers populate the Officers/Live-map views;
// the pending ones are there to approve in HPark Command → Officer approvals.
const officers = [
  { id: 'OFR-118', fullName: 'Amina Yusuf', nationalId: 'SL-9920-1183', phone: '+252 63 4412 118', dateOfBirth: ms(1994, 3, 12), badgeNumber: 'HG-OFR-118', status: 'approved', appliedAt: ms(2026, 1, 8), assignedDistrictId: 'ahmed-dhagah', approvedAt: ms(2026, 1, 9), approvedBy: 'Hodan Ali', reviewNote: '', citationsIssued: 412, photoUrl: null },
  { id: 'OFR-104', fullName: 'Khadar Jama', nationalId: 'SL-8814-2204', phone: '+252 63 4419 104', dateOfBirth: ms(1990, 11, 2), badgeNumber: 'HG-OFR-104', status: 'approved', appliedAt: ms(2026, 1, 6), assignedDistrictId: 'mohamed-mooge', approvedAt: ms(2026, 1, 7), approvedBy: 'Hodan Ali', reviewNote: '', citationsIssued: 389, photoUrl: null },
  { id: 'OFR-127', fullName: 'Liban Warsame', nationalId: 'SL-9133-7781', phone: '+252 63 4471 127', dateOfBirth: ms(1996, 6, 24), badgeNumber: 'HG-OFR-127', status: 'pending', appliedAt: ms(2026, 6, 7, 9, 14), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
  { id: 'OFR-128', fullName: 'Sahra Abdi', nationalId: 'SL-9542-3360', phone: '+252 63 4471 128', dateOfBirth: ms(1999, 2, 9), badgeNumber: 'HG-OFR-128', status: 'pending', appliedAt: ms(2026, 6, 7, 16, 2), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
  { id: 'OFR-129', fullName: 'Mustafe Cabdi', nationalId: 'SL-9077-1145', phone: '+252 63 4471 129', dateOfBirth: ms(1993, 8, 30), badgeNumber: 'HG-OFR-129', status: 'pending', appliedAt: ms(2026, 6, 8, 7, 41), assignedDistrictId: null, approvedAt: null, approvedBy: null, reviewNote: null, citationsIssued: 0, photoUrl: null },
];

// The vehicle registry an officer's plate lookup checks against (vehicles/{plate}).
// Plates are stored normalised (uppercase, no spaces/dashes), matching
// FirebaseVehicleRepository.normalisePlate, so OCR + manual entry resolve to them.
// The first three are REAL Somaliland plates (one letter + 4 digits) for OCR testing.
const vehicles = [
  { plate: 'F4154', ownerName: 'Cabdi Jaamac', ownerNationalId: 'SL-7741-0098', make: 'Toyota Vitz', color: 'Silver', permitStatus: 'valid', outstandingCount: 0, outstandingTotal: 0 },
  { plate: 'L9019', ownerName: 'Maxamed Cali', ownerNationalId: 'SL-9012-4456', make: 'Toyota Mark X', color: 'Black', permitStatus: 'valid', outstandingCount: 0, outstandingTotal: 0 },
  { plate: 'F4157', ownerName: 'Hodan Maxamed', ownerNationalId: 'SL-3320-7711', make: 'Nissan Sunny', color: 'White', permitStatus: 'expired', outstandingCount: 0, outstandingTotal: 0 },
  { plate: 'HG3508', ownerName: 'Naima Yusuf', ownerNationalId: 'SL-6610-2245', make: 'Toyota Belta', color: 'Blue', permitStatus: 'valid', outstandingCount: 0, outstandingTotal: 0 },
];

// Stale dashed demo plates from the earlier seed — remove so they don't linger.
const staleVehiclePlates = ['HG-4821', 'HG-1190', 'HG-7732', 'HG-3508'];

// District shop deals shown in HPark Pay (deals/{code}).
const deals = [
  { shop: 'Liido Shoes', title: '50% off all sneakers', code: 'HP-LIID-26', districtId: 'ahmed-dhagah', category: 'Fashion' },
  { shop: 'Hayba Restaurant', title: 'Free drink with any meal', code: 'HP-HAYB-11', districtId: 'ahmed-dhagah', category: 'Food' },
  { shop: 'Star Electronics', title: '20% off accessories', code: 'HP-STAR-07', districtId: '26-june', category: 'Electronics' },
  { shop: 'Cadceed Cafe', title: 'Buy 1 get 1 coffee', code: 'HP-CADC-19', districtId: '26-june', category: 'Food' },
  { shop: 'Maroodi Market', title: '15% off groceries', code: 'HP-MARO-33', districtId: '31-may', category: 'Grocery' },
  { shop: 'Geel Fashion', title: '30% off dresses', code: 'HP-GEEL-22', districtId: 'mohamed-mooge', category: 'Fashion' },
  { shop: 'Naasa Hablood Gym', title: '1 month free trial', code: 'HP-NAAS-08', districtId: 'gacan-libaax', category: 'Fitness' },
  { shop: 'Koodbuur Pharmacy', title: '10% off vitamins', code: 'HP-KOOD-14', districtId: 'ibrahim-koodbuur', category: 'Health' },
];

async function run() {
  const batch = db.batch();
  for (const o of officers) batch.set(db.collection('officers').doc(o.id), o);
  for (const p of staleVehiclePlates) batch.delete(db.collection('vehicles').doc(p));
  for (const v of vehicles) batch.set(db.collection('vehicles').doc(v.plate), v);
  for (const d of deals) batch.set(db.collection('deals').doc(d.code), d);
  await batch.commit();
  console.log(`Seeded ${officers.length} officers, ${vehicles.length} vehicles, ${deals.length} deals. (citations + appeals are created by real app usage.)`);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
