/// A district shop deal advertised to citizens in HPark Pay. One Firestore
/// document under `deals/{id}`; the coupon [code] is encoded into the scannable
/// QR a citizen redeems at the till. Managed by the city / partner shops.
class Deal {
  const Deal({
    required this.shop,
    required this.title,
    required this.code,
    required this.districtId,
    required this.category,
    this.id = '',
  });

  final String id; // Firestore doc id (coupon code by default)
  final String shop;
  final String title; // e.g. "50% off all sneakers"
  final String code; // coupon code encoded into the QR
  final String districtId; // links to a hpark_core district id
  final String category; // Food / Fashion / Electronics ...

  Map<String, dynamic> toMap() => {
        'shop': shop,
        'title': title,
        'code': code,
        'districtId': districtId,
        'category': category,
      };

  static Deal fromMap(Map<String, dynamic> map, {String id = ''}) => Deal(
        id: id,
        shop: map['shop'] as String? ?? '',
        title: map['title'] as String? ?? '',
        code: map['code'] as String? ?? '',
        districtId: map['districtId'] as String? ?? '',
        category: map['category'] as String? ?? '',
      );
}
