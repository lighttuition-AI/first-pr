import '../models/pay_models.dart';

/// Sample outstanding + paid citations for the demo citizen.
List<Citation> seedCitations() => [
      Citation(
        id: 'CIT-2026-04821',
        plate: 'HG-4821',
        violation: 'Parked in a no-parking zone',
        amount: 250000,
        issuedAt: DateTime(2026, 6, 5, 14, 22),
        districtName: 'Ahmed Dhagah',
      ),
      Citation(
        id: 'CIT-2026-04655',
        plate: 'HG-4821',
        violation: 'Expired parking session',
        amount: 120000,
        issuedAt: DateTime(2026, 5, 28, 9, 5),
        districtName: 'Mohamed Mooge',
      ),
      Citation(
        id: 'CIT-2026-03990',
        plate: 'HG-4821',
        violation: 'Blocking a driveway',
        amount: 180000,
        issuedAt: DateTime(2026, 5, 12, 17, 40),
        districtName: '26 June',
        status: CitationStatus.paid,
      ),
    ];

/// Sample shop deals, keyed to district ids from hpark_core.
const List<Deal> kDeals = [
  Deal(shop: 'Liido Shoes', title: '50% off all sneakers', code: 'HP-LIID-26', districtId: 'ahmed-dhagah', category: 'Fashion'),
  Deal(shop: 'Hayba Restaurant', title: 'Free drink with any meal', code: 'HP-HAYB-11', districtId: 'ahmed-dhagah', category: 'Food'),
  Deal(shop: 'Star Electronics', title: '20% off accessories', code: 'HP-STAR-07', districtId: '26-june', category: 'Electronics'),
  Deal(shop: 'Cadceed Cafe', title: 'Buy 1 get 1 coffee', code: 'HP-CADC-19', districtId: '26-june', category: 'Food'),
  Deal(shop: 'Maroodi Market', title: '15% off groceries', code: 'HP-MARO-33', districtId: '31-may', category: 'Grocery'),
  Deal(shop: 'Geel Fashion', title: '30% off dresses', code: 'HP-GEEL-22', districtId: 'mohamed-mooge', category: 'Fashion'),
  Deal(shop: 'Naasa Hablood Gym', title: '1 month free trial', code: 'HP-NAAS-08', districtId: 'gacan-libaax', category: 'Fitness'),
  Deal(shop: 'Koodbuur Pharmacy', title: '10% off vitamins', code: 'HP-KOOD-14', districtId: 'ibrahim-koodbuur', category: 'Health'),
];

List<Deal> dealsForDistrict(String districtId) =>
    kDeals.where((d) => d.districtId == districtId).toList();
