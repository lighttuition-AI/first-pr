// ============================================================
// Produce — fruits + veggies for the "Fruit & Veggies" island.
// ------------------------------------------------------------
// Each item has an English name, a Somali name (best-effort default — real
// Somali where well-established, a clear transliteration otherwise; meant to
// be re-recorded by the family in the Voiceover Studio), and a big friendly
// emoji. A real uploaded photo (Img slot = the item id) overrides the emoji,
// so no copyrighted images are bundled.
//
// Only items with a clear, distinct emoji are included (so a young child can
// actually tell them apart and guess) — that caps each list well under 100,
// which is fine: a session shuffles up to 20 and rotates fresh ones next time.
//
// VO ids: '<id>-en' / '<id>-so'  ·  Img slot: '<id>'  (id is category-prefixed).
// ============================================================
class Produce {
  final String id; // e.g. 'fruit-apple' / 'veg-carrot'
  final String en; // English name
  final String so; // Somali name (default; re-recordable)
  final String emoji; // big friendly default picture
  const Produce(this.id, this.en, this.so, this.emoji);
}

/// Bundled real picture for a produce item (shown unless a grown-up uploads
/// their own); Img falls back to the emoji if this asset isn't present.
String produceAsset(String id) => 'assets/produce/$id.png';

/// The most kid-famous fruits (clear, distinct emoji each).
const List<Produce> kFruits = [
  Produce('fruit-apple', 'Apple', 'Tufaax', '🍎'),
  Produce('fruit-green-apple', 'Green Apple', 'Tufaax cagaaran', '🍏'),
  Produce('fruit-banana', 'Banana', 'Moos', '🍌'),
  Produce('fruit-orange', 'Orange', 'Liin macaan', '🍊'),
  Produce('fruit-lemon', 'Lemon', 'Liin dhanaan', '🍋'),
  Produce('fruit-watermelon', 'Watermelon', 'Qare', '🍉'),
  Produce('fruit-grapes', 'Grapes', 'Canab', '🍇'),
  Produce('fruit-strawberry', 'Strawberry', 'Faraawle', '🍓'),
  Produce('fruit-blueberries', 'Blueberries', 'Buluuberi', '🫐'),
  Produce('fruit-cherries', 'Cherries', 'Jeeri', '🍒'),
  Produce('fruit-peach', 'Peach', 'Biijo', '🍑'),
  Produce('fruit-mango', 'Mango', 'Cambe', '🥭'),
  Produce('fruit-pineapple', 'Pineapple', 'Cananaas', '🍍'),
  Produce('fruit-coconut', 'Coconut', 'Qumbe', '🥥'),
  Produce('fruit-kiwi', 'Kiwi', 'Kiiwi', '🥝'),
  Produce('fruit-melon', 'Melon', 'Meeloon', '🍈'),
  Produce('fruit-pear', 'Pear', 'Bare', '🍐'),
];

/// The most kid-famous vegetables (clear, distinct emoji each).
const List<Produce> kVeggies = [
  Produce('veg-carrot', 'Carrot', 'Karooto', '🥕'),
  Produce('veg-corn', 'Corn', 'Galley', '🌽'),
  Produce('veg-potato', 'Potato', 'Baradho', '🥔'),
  Produce('veg-sweet-potato', 'Sweet Potato', 'Baradho macaan', '🍠'),
  Produce('veg-broccoli', 'Broccoli', 'Burokoli', '🥦'),
  Produce('veg-lettuce', 'Lettuce', 'Salaato', '🥬'),
  Produce('veg-cucumber', 'Cucumber', 'Qajaar', '🥒'),
  Produce('veg-tomato', 'Tomato', 'Yaanyo', '🍅'),
  Produce('veg-eggplant', 'Eggplant', 'Bidinjaal', '🍆'),
  Produce('veg-avocado', 'Avocado', 'Afokaado', '🥑'),
  Produce('veg-chili', 'Chili Pepper', 'Basbaas', '🌶️'),
  Produce('veg-bell-pepper', 'Bell Pepper', 'Filfil', '🫑'),
  Produce('veg-garlic', 'Garlic', 'Toon', '🧄'),
  Produce('veg-onion', 'Onion', 'Basal', '🧅'),
  Produce('veg-mushroom', 'Mushroom', 'Boqoshaar', '🍄'),
  Produce('veg-peas', 'Peas', 'Digir', '🫛'),
  Produce('veg-beans', 'Beans', 'Loobiya', '🫘'),
  Produce('veg-ginger', 'Ginger', 'Sinjabiil', '🫚'),
  Produce('veg-peanuts', 'Peanuts', 'Lows', '🥜'),
];

List<Produce> produceFor(String category) => category == 'veggie' ? kVeggies : kFruits;
