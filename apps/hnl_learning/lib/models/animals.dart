// ============================================================
// Animals — continents + their famous animals (the "Animals" island).
// ------------------------------------------------------------
// Each animal carries an English name, a Somali name (a sensible default
// the parent can re-record / relabel), and a friendly emoji. The emoji is
// just the default picture — a real uploaded photo (Img slot 'animal-<id>')
// overrides it, so no copyrighted images are bundled.
//
// Somali names: best-effort defaults (loan-words where Somali borrows them).
// The Somali voiceover is meant to be re-recorded by the family.
//
// Pools are a strong, recognizable starter set per continent — easy to grow
// toward 100. A quiz session shuffles and serves up to 20 at a time, then
// reshuffles fresh ones next visit (see AppState.startContinent).
// ============================================================
import 'package:flutter/material.dart';

class Animal {
  final String id; // slug → Img slot 'animal-<id>' + VO ids 'animal-<id>-en/-so'
  final String en; // English name
  final String so; // Somali name (default; re-recordable)
  final String emoji; // friendly default picture
  const Animal(this.id, this.en, this.so, this.emoji);
}

class Continent {
  final String id;
  final String name;
  final String emoji; // a famous animal, shown on the map button
  final Color color; // map colour (mirrors the reference continents map)
  final List<Animal> pool;
  const Continent(this.id, this.name, this.emoji, this.color, this.pool);
}

Continent continentById(String id) => kContinents.firstWhere((c) => c.id == id);

const List<Continent> kContinents = [
  Continent('africa', 'Africa', '🦁', Color(0xFFF2A03D), [
    Animal('lion', 'Lion', 'Libaax', '🦁'),
    Animal('elephant', 'Elephant', 'Maroodi', '🐘'),
    Animal('giraffe', 'Giraffe', 'Geri', '🦒'),
    Animal('zebra', 'Zebra', 'Dameer-dibadeed', '🦓'),
    Animal('rhino', 'Rhino', 'Wiyil', '🦏'),
    Animal('hippo', 'Hippo', 'Jeer', '🦛'),
    Animal('leopard', 'Leopard', 'Shabeel', '🐆'),
    Animal('cheetah', 'Cheetah', 'Haramcad', '🐆'),
    Animal('gorilla', 'Gorilla', 'Gorilla', '🦍'),
    Animal('monkey', 'Monkey', 'Daanyeer', '🐒'),
    Animal('crocodile', 'Crocodile', 'Yaxaas', '🐊'),
    Animal('camel', 'Camel', 'Geel', '🐪'),
    Animal('buffalo', 'Buffalo', 'Gisi', '🐃'),
    Animal('gazelle', 'Gazelle', 'Cawl', '🦌'),
    Animal('hyena', 'Hyena', 'Waraabe', '🐺'),
    Animal('warthog', 'Warthog', 'Gadhqorre', '🐗'),
    Animal('flamingo', 'Flamingo', 'Flaamingo', '🦩'),
    Animal('snake', 'Snake', 'Mas', '🐍'),
    Animal('chimp', 'Chimpanzee', 'Daanyeer-madow', '🐵'),
    Animal('tortoise', 'Tortoise', 'Diin', '🐢'),
  ]),
  Continent('asia', 'Asia', '🐼', Color(0xFFB9A6E0), [
    Animal('panda', 'Panda', 'Panda', '🐼'),
    Animal('tiger', 'Tiger', 'Tiigar', '🐯'),
    Animal('elephant_as', 'Elephant', 'Maroodi', '🐘'),
    Animal('orangutan', 'Orangutan', 'Daanyeer-cas', '🦧'),
    Animal('monkey_as', 'Monkey', 'Daanyeer', '🐒'),
    Animal('camel_as', 'Camel', 'Geel', '🐫'),
    Animal('peacock', 'Peacock', 'Daawus', '🦚'),
    Animal('cobra', 'Cobra', 'Mas', '🐍'),
    Animal('deer_as', 'Deer', 'Deero', '🦌'),
    Animal('waterbuffalo', 'Water Buffalo', 'Gisi', '🐃'),
    Animal('leopard_as', 'Leopard', 'Shabeel', '🐆'),
    Animal('rhino_as', 'Rhino', 'Wiyil', '🦏'),
    Animal('bear_as', 'Bear', 'Orso', '🐻'),
    Animal('boar_as', 'Wild Boar', 'Doofaar', '🐗'),
    Animal('crocodile_as', 'Crocodile', 'Yaxaas', '🐊'),
    Animal('rooster', 'Rooster', 'Diiq', '🐓'),
  ]),
  Continent('europe', 'Europe', '🦊', Color(0xFFC8A98C), [
    Animal('fox', 'Fox', 'Dawaco', '🦊'),
    Animal('wolf', 'Wolf', 'Yey', '🐺'),
    Animal('bear_eu', 'Bear', 'Orso', '🐻'),
    Animal('deer_eu', 'Deer', 'Deero', '🦌'),
    Animal('rabbit', 'Rabbit', 'Bakayle', '🐰'),
    Animal('hedgehog', 'Hedgehog', 'Cawsharaar', '🦔'),
    Animal('squirrel', 'Squirrel', 'Dabagaalle', '🐿️'),
    Animal('owl', 'Owl', 'Guumeys', '🦉'),
    Animal('eagle_eu', 'Eagle', 'Gorgor', '🦅'),
    Animal('boar_eu', 'Wild Boar', 'Doofaar', '🐗'),
    Animal('horse', 'Horse', 'Faras', '🐎'),
    Animal('goat', 'Goat', 'Ri', '🐐'),
    Animal('otter', 'Otter', 'Dige', '🦦'),
    Animal('swan', 'Swan', 'Berde', '🦢'),
  ]),
  Continent('north_america', 'North America', '🦅', Color(0xFFE36A6A), [
    Animal('baldeagle', 'Bald Eagle', 'Gorgor', '🦅'),
    Animal('grizzly', 'Grizzly Bear', 'Orso', '🐻'),
    Animal('bison', 'Bison', 'Gisi-weyn', '🦬'),
    Animal('wolf_na', 'Wolf', 'Yey', '🐺'),
    Animal('beaver', 'Beaver', 'Biifar', '🦫'),
    Animal('raccoon', 'Raccoon', 'Rakuun', '🦝'),
    Animal('deer_na', 'Deer', 'Deero', '🦌'),
    Animal('moose', 'Moose', 'Muus', '🫎'),
    Animal('fox_na', 'Fox', 'Dawaco', '🦊'),
    Animal('owl_na', 'Owl', 'Guumeys', '🦉'),
    Animal('turkey', 'Turkey', 'Turki', '🦃'),
    Animal('rattlesnake', 'Rattlesnake', 'Mas', '🐍'),
    Animal('squirrel_na', 'Squirrel', 'Dabagaalle', '🐿️'),
    Animal('alligator', 'Alligator', 'Yaxaas', '🐊'),
    Animal('rabbit_na', 'Rabbit', 'Bakayle', '🐰'),
  ]),
  Continent('south_america', 'South America', '🦥', Color(0xFF8FBBE8), [
    Animal('sloth', 'Sloth', 'Sloodh', '🦥'),
    Animal('llama', 'Llama', 'Lama', '🦙'),
    Animal('monkey_sa', 'Monkey', 'Daanyeer', '🐒'),
    Animal('jaguar', 'Jaguar', 'Shabeel', '🐆'),
    Animal('toucan', 'Toucan', 'Tuukaan', '🦜'),
    Animal('parrot', 'Parrot', 'Baqbaqaa', '🦜'),
    Animal('capybara', 'Capybara', 'Kabibaara', '🦫'),
    Animal('flamingo_sa', 'Flamingo', 'Flaamingo', '🦩'),
    Animal('frog', 'Frog', 'Rah', '🐸'),
    Animal('anaconda', 'Anaconda', 'Mas-weyn', '🐍'),
    Animal('caiman', 'Caiman', 'Yaxaas', '🐊'),
    Animal('butterfly', 'Butterfly', 'Balanbaalis', '🦋'),
  ]),
  Continent('oceania', 'Oceania', '🦘', Color(0xFF8FD49A), [
    Animal('kangaroo', 'Kangaroo', 'Kangaruu', '🦘'),
    Animal('koala', 'Koala', 'Koowala', '🐨'),
    Animal('crocodile_oc', 'Crocodile', 'Yaxaas', '🐊'),
    Animal('dingo', 'Dingo', 'Dingo', '🐕'),
    Animal('snake_oc', 'Snake', 'Mas', '🐍'),
    Animal('parrot_oc', 'Parrot', 'Baqbaqaa', '🦜'),
    Animal('penguin_oc', 'Penguin', 'Pingwiin', '🐧'),
    Animal('shark', 'Shark', 'Libaax-badeed', '🦈'),
    Animal('dolphin', 'Dolphin', 'Dolfin', '🐬'),
    Animal('seaturtle', 'Sea Turtle', 'Diin-badeed', '🐢'),
    Animal('whale_oc', 'Whale', 'Nibiri', '🐳'),
    Animal('octopus', 'Octopus', 'Faro-badeed', '🐙'),
  ]),
  Continent('antarctica', 'Antarctica', '🐧', Color(0xFFAFC4CC), [
    Animal('penguin', 'Penguin', 'Pingwiin', '🐧'),
    Animal('seal', 'Seal', 'Nibiri-yar', '🦭'),
    Animal('whale', 'Whale', 'Nibiri', '🐳'),
    Animal('orca', 'Orca', 'Orka', '🐋'),
    Animal('krill', 'Krill', 'Kuril', '🦐'),
    Animal('squid', 'Squid', 'Sicid', '🦑'),
    Animal('fish_an', 'Fish', 'Kalluun', '🐟'),
  ]),
];
