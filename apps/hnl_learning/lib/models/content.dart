// ============================================================
// HNL Learning — Content data (ported from js/data.js)
// Everything the app renders is defined here so it can scale
// (30–50 puzzles) by adding rows. VO lines carry an id used by
// the Voiceover Studio for per-line recording.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class Topic {
  final String id, label, emoji, world;
  final Color Function(Palette) color;
  const Topic(this.id, this.label, this.emoji, this.world, this.color);
}

final List<Topic> kTopics = [
  Topic('logic', 'Logic', '🧩', 'logic', (p) => p.logic),
  Topic('counting', 'Counting', '🔢', 'galaxy', (p) => p.galaxy),
  Topic('shapes', 'Shapes & Patterns', '🔷', 'galaxy', (p) => p.galaxy),
  Topic('memory', 'Memory', '🧠', 'discovery', (p) => p.discovery),
  Topic('letters', 'Letters', '🔤', 'discovery', (p) => p.discovery),
  Topic('sorting', 'Sorting', '🗂️', 'logic', (p) => p.logic),
  Topic('science', 'Science & World', '🔬', 'discovery', (p) => p.discovery),
];

Topic topicById(String id) => kTopics.firstWhere((t) => t.id == id);

class AvatarData {
  final String id, face;
  final Color color;
  const AvatarData(this.id, this.color, this.face);
}

const List<AvatarData> kAvatars = [
  AvatarData('mint', Color(0xFF15B886), 'happy'),
  AvatarData('coral', Color(0xFFFF7A59), 'grin'),
  AvatarData('sun', Color(0xFFFFC23C), 'wink'),
  AvatarData('sky', Color(0xFF5C7CFA), 'happy'),
  AvatarData('grape', Color(0xFF9B7EDE), 'grin'),
  AvatarData('rose', Color(0xFFFF6B9D), 'wink'),
  AvatarData('teal', Color(0xFF22B8C4), 'happy'),
  AvatarData('tang', Color(0xFFFF9F43), 'grin'),
];

class World {
  final String id, name, tagline, emoji, blurb;
  const World(this.id, this.name, this.tagline, this.emoji, this.blurb);
}

const List<World> kWorlds = [
  World('logic', 'Logic Lab', 'Puzzles & sorting', '🧪',
      'Spot patterns, finish sequences, sort the world into groups.'),
  World('galaxy', 'Number Galaxy', 'Counting, shapes & patterns', '🪐',
      'Count the stars, match shapes, complete cosmic patterns.'),
  World('discovery', 'Discovery World', 'Memory, letters & science', '🌍',
      'Flip cards, meet letters, and discover how the world works.'),
  World('arabic', 'Arabic World', 'Letters, words & sounds', '📜',
      'Meet the Arabic letters, hear each sound, and explore the language.'),
  World('animals', 'Animals', 'Continents & creatures', '🦒',
      'Hop around the world and meet amazing animals from every continent!'),
];

class PlanetData {
  final String id, name;
  final Color colorA, colorB, dots;
  final bool ring;
  final Color? ringColor;
  const PlanetData(this.id, this.name, this.colorA, this.colorB, this.dots,
      {this.ring = false, this.ringColor});
}

const List<PlanetData> kPlanets = [
  PlanetData('p1', 'Bloop', Color(0xFF5C7CFA), Color(0xFF3F5FD8), Color(0xFFA9C0FF)),
  PlanetData('p2', 'Tangelo', Color(0xFFFF9F43), Color(0xFFFF7A59), Color(0xFFFFD0A8),
      ring: true, ringColor: Color(0xFFFFD96B)),
  PlanetData('p3', 'Minty', Color(0xFF2ED3A3), Color(0xFF0E9E73), Color(0xFFBFF3E2)),
  PlanetData('p4', 'Plum', Color(0xFFB07EE8), Color(0xFF7C5BD0), Color(0xFFE2CBFF),
      ring: true, ringColor: Color(0xFFE6CCFF)),
  PlanetData('p5', 'Sunny', Color(0xFFFFD23F), Color(0xFFFFB01F), Color(0xFFFFF0B8)),
  PlanetData('p6', 'Coralia', Color(0xFFFF8FA3), Color(0xFFFF6B9D), Color(0xFFFFD6DF),
      ring: true, ringColor: Color(0xFFFFD0DC)),
  PlanetData('p7', 'Aqua', Color(0xFF39C7DE), Color(0xFF1E9FC4), Color(0xFFC2F0F7)),
  PlanetData('p8', 'Ember', Color(0xFFFF7A59), Color(0xFFE85D3D), Color(0xFFFFC9B8)),
  PlanetData('p9', 'Glow', Color(0xFF9BE15D), Color(0xFF5FB836), Color(0xFFDDF7BD),
      ring: true, ringColor: Color(0xFFDFFFC2)),
];

PlanetData planetById(String id) => kPlanets.firstWhere((p) => p.id == id);

class Promise {
  final String emoji, text;
  const Promise(this.emoji, this.text);
}

class OnboardingStep {
  final String id, step, title, vo;
  final List<Promise> promises;
  const OnboardingStep(this.id, this.step, this.title, this.promises, this.vo);
}

const List<OnboardingStep> kOnboarding = [
  OnboardingStep('welcome', 'A', 'Turn screen time into learning time', [
    Promise('🧠', 'Builds logic, memory & focus'),
    Promise('🛡️', 'Safe & completely ad-free'),
    Promise('🎓', 'Designed with educators'),
  ], 'Welcome to H N L Learning! We turn screen time into learning time. Tap the green button to begin.'),
  OnboardingStep('healthy', 'B', 'Healthy by design', [
    Promise('⏱️', 'Short 15–20 minute sessions'),
    Promise('🌿', 'Gentle built-in break reminders'),
    Promise('😊', 'Calm, joyful, never overwhelming'),
  ], 'Sessions are short and healthy — about fifteen to twenty minutes — with gentle break reminders built right in.'),
  OnboardingStep('start', 'C', "Let's set up your child", [
    Promise('🎈', 'Pick an age & favourite topics'),
    Promise('🤖', 'Robo builds a personal path'),
    Promise('🚀', 'Takes less than a minute'),
  ], "Let's set up your child. It only takes a minute, and Robo will build a learning path just for them."),
];

// ---------------- Games ----------------
enum GameType { pick, count, pattern, memory, letter, sort, science, alphabet, trace }

class PickOption {
  final String emoji;
  final double scale;
  final bool correct;
  final String? label;
  const PickOption(this.emoji, {this.scale = 1.0, this.correct = false, this.label});
}

class SortGroup {
  final String id, emoji, label;
  const SortGroup(this.id, this.emoji, this.label);
}

class SortItem {
  final String emoji, group;
  const SortItem(this.emoji, this.group);
}

/// A single playable round. Fields used depend on the game type.
class Round {
  final String id;
  final String? vo; // instruction
  final String? prompt;
  final Color bg;

  // pick / letter / science options
  final List<PickOption> options;

  // count
  final int target;
  final String item;
  final String basket;
  final int pool;

  // pattern
  final List<String> sequence;
  final String answer;
  final List<String> choices;
  final bool isRound;

  // memory
  final List<String> deck;

  // letter
  final String letter;

  // sort
  final List<SortGroup> groups;
  final List<SortItem> items;

  // science
  final String? factVo, fact, factEmoji, qVo;

  const Round({
    required this.id,
    this.vo,
    this.prompt,
    required this.bg,
    this.options = const [],
    this.target = 0,
    this.item = '',
    this.basket = '',
    this.pool = 0,
    this.sequence = const [],
    this.answer = '',
    this.choices = const [],
    this.isRound = false,
    this.deck = const [],
    this.letter = '',
    this.groups = const [],
    this.items = const [],
    this.factVo,
    this.fact,
    this.factEmoji,
    this.qVo,
  });
}

class Game {
  final String id, title, world, topic, reward;
  final GameType type;
  final List<Round> rounds;

  /// Whether this game can be pulled into a Daily Mission. Explore-style
  /// games with no win condition (e.g. the alphabet board) set this false.
  final bool mission;

  const Game(this.id, this.type, this.world, this.topic, this.title, this.reward,
      this.rounds, {this.mission = true});
}

final List<Game> kGames = [
  // 1 — LOGIC: which one (tap-pick)
  Game('logic-pick', GameType.pick, 'logic', 'logic', 'Which one?', 'p2', [
    Round(
      id: 'lg1',
      vo: 'Look at the two cars. Which car is BIGGER? Tap it!',
      prompt: 'Which is bigger?',
      bg: Color(0xFFEAF4FB),
      options: [PickOption('🚗', scale: 1.7, correct: true), PickOption('🚗')],
    ),
    Round(
      id: 'lg2',
      vo: "Which one of these is the ODD one out? Tap the one that's different!",
      prompt: 'Tap the odd one out',
      bg: Color(0xFFFFF3EC),
      options: [PickOption('🍎'), PickOption('🍎'), PickOption('⚽', correct: true), PickOption('🍎')],
    ),
    Round(
      id: 'lg3',
      vo: 'One of these can FLY. Tap the thing that flies in the sky!',
      prompt: 'Which one can fly?',
      bg: Color(0xFFEFF6EE),
      options: [PickOption('🐠'), PickOption('🦋', correct: true), PickOption('🐌')],
    ),
  ]),
  // 2 — COUNTING: drag N into the basket
  Game('counting-basket', GameType.count, 'galaxy', 'counting', 'Count & drop', 'p1', [
    Round(id: 'ct1', vo: 'Robo wants exactly THREE apples in the basket. Drag three apples in!', target: 3, item: '🍎', basket: '🧺', pool: 5, bg: Color(0xFFFBF3E7)),
    Round(id: 'ct2', vo: 'Now drag exactly FIVE stars into the jar. Count them out loud!', target: 5, item: '⭐', basket: '🫙', pool: 7, bg: Color(0xFFEEF1FF)),
    Round(id: 'ct3', vo: 'Pop exactly TWO balloons into the box. Just two!', target: 2, item: '🎈', basket: '📦', pool: 5, bg: Color(0xFFFFEFF4)),
  ]),
  // 3 — SHAPES & PATTERNS: drag the next piece into the slot
  Game('shapes-pattern', GameType.pattern, 'galaxy', 'shapes', 'Finish the pattern', 'p4', [
    Round(id: 'sp1', vo: 'Look at the pattern. What shape comes NEXT? Drag it into the empty spot!', sequence: ['🔺', '🟦', '🔺', '🟦', '🔺', '?'], answer: '🟦', choices: ['🟦', '🔺', '🟢'], bg: Color(0xFFEFF6EE)),
    Round(id: 'sp2', vo: 'Which colour comes next in the row? Drag it to finish the pattern!', sequence: ['🔴', '🟡', '🔴', '🟡', '?'], answer: '🔴', choices: ['🟡', '🔴', '🔵'], bg: Color(0xFFFFF4EC)),
    Round(id: 'sp3', vo: "This one's a round one! Which item is ROUND like the balloon? Drag it over!", sequence: ['🎈', '➡️', '?'], answer: '🍊', isRound: true, choices: ['🍊', '📕', '🔺'], bg: Color(0xFFEEF1FF)),
  ]),
  // 4 — MEMORY: flip & match
  Game('memory-match', GameType.memory, 'discovery', 'memory', 'Flip & match', 'p3', [
    Round(id: 'mm1', vo: 'Flip the cards two at a time and find the matching pairs. Use your memory!', deck: ['🦊', '🐢', '🦉', '🐝'], bg: Color(0xFFEFF6EE)),
    Round(id: 'mm2', vo: 'Find all the matching pairs. Remember where each picture is!', deck: ['🍓', '🌸', '🚀', '🐳', '🎈'], bg: Color(0xFFFFF0F4)),
  ]),
  // 5 — LETTERS: match letter to picture
  Game('letters-match', GameType.letter, 'discovery', 'letters', 'Letter sounds', 'p5', [
    Round(id: 'lt1', vo: 'This is the letter B. Buh — B! Tap the picture that starts with B!', letter: 'B', bg: Color(0xFFFFF7E8), options: [PickOption('🍌', correct: true, label: 'Banana'), PickOption('🍎', label: 'Apple'), PickOption('🐱', label: 'Cat')]),
    Round(id: 'lt2', vo: 'The letter S says sss. Tap the one that starts with S!', letter: 'S', bg: Color(0xFFEEF1FF), options: [PickOption('☀️', correct: true, label: 'Sun'), PickOption('🌙', label: 'Moon'), PickOption('🐶', label: 'Dog')]),
    Round(id: 'lt3', vo: 'Find the picture that starts with the letter F. Fff — F!', letter: 'F', bg: Color(0xFFEFF6EE), options: [PickOption('🐟', correct: true, label: 'Fish'), PickOption('🥕', label: 'Carrot'), PickOption('🌻', label: 'Flower (no!)')]),
  ]),
  // 6 — SORTING: drag items into the right group
  Game('sorting-groups', GameType.sort, 'logic', 'sorting', 'Sort it out', 'p6', [
    Round(id: 'st1', vo: 'The monkey eats the banana, the cat eats the fish. Drag each food to the right animal!', bg: Color(0xFFF0ECFB), groups: [SortGroup('monkey', '🐵', 'Monkey'), SortGroup('cat', '🐱', 'Cat')], items: [SortItem('🍌', 'monkey'), SortItem('🐟', 'cat')]),
    Round(id: 'st2', vo: 'Some of these are animals and some are plants. Drag each one to its own group!', bg: Color(0xFFEFF6EE), groups: [SortGroup('animal', '🐾', 'Animals'), SortGroup('plant', '🌱', 'Plants')], items: [SortItem('🦒', 'animal'), SortItem('🌳', 'plant'), SortItem('🐠', 'animal'), SortItem('🌷', 'plant')]),
  ]),
  // 7 — SCIENCE: fact, then a quick question
  Game('science-fact', GameType.science, 'discovery', 'science', 'Discover!', 'p7', [
    Round(id: 'sc1', factVo: 'Did you know? The Sun is a giant star, and it gives us light and warmth every day!', fact: 'The Sun is a giant star! ☀️', factEmoji: '☀️', qVo: 'Now, which one gives us light in the daytime? Tap it!', prompt: 'Which gives us daytime light?', bg: Color(0xFFFFF7E8), options: [PickOption('☀️', correct: true), PickOption('🌙'), PickOption('⭐')]),
    Round(id: 'sc2', factVo: 'Bees are tiny helpers! They visit flowers and help new plants grow.', fact: 'Bees help flowers grow! 🐝', factEmoji: '🐝', qVo: 'Which little helper visits flowers? Tap it!', prompt: 'Who visits flowers?', bg: Color(0xFFEFF6EE), options: [PickOption('🐝', correct: true), PickOption('🐙'), PickOption('🦖')]),
  ]),
  // 8 — ARABIC WORLD · game 1: the alphabet board (tap a letter to hear it).
  // Explore-only (no win condition) so it never joins a Daily Mission.
  Game('arabic-alphabet', GameType.alphabet, 'arabic', 'letters', 'Arabic Letters', '', [
    Round(id: 'ar-board', vo: 'Tap each letter to hear its sound!', bg: Color(0xFF21386E)),
  ], mission: false),
  // 9 — ARABIC WORLD · game 2: trace each letter with a finger (pick a color).
  Game('arabic-trace', GameType.trace, 'arabic', 'letters', 'Letter Tracing', '', [
    Round(id: 'ar-trace', vo: 'Pick a colour, then trace the letter with your finger!', bg: Color(0xFFFCEEDD)),
  ], mission: false),
];

/// One Arabic letter slot: the glyph + a stable VO id. The default spoken
/// text is the letter's name (TTS stand-in); a grown-up can record the real
/// pronunciation per letter in the Voiceover Studio.
class ArabicLetter {
  final String id; // e.g. 'ar-alif'
  final String glyph; // 'أ'
  final String name; // 'Alif' — TTS default + Studio label
  const ArabicLetter(this.id, this.glyph, this.name);
}

const List<ArabicLetter> kArabicLetters = [
  ArabicLetter('ar-alif', 'أ', 'Alif'),
  ArabicLetter('ar-baa', 'ب', 'Baa'),
  ArabicLetter('ar-taa', 'ت', 'Taa'),
  ArabicLetter('ar-thaa', 'ث', 'Thaa'),
  ArabicLetter('ar-jiim', 'ج', 'Jiim'),
  ArabicLetter('ar-haa', 'ح', 'Haa'),
  ArabicLetter('ar-khaa', 'خ', 'Khaa'),
  ArabicLetter('ar-daal', 'د', 'Daal'),
  ArabicLetter('ar-dhaal', 'ذ', 'Dhaal'),
  ArabicLetter('ar-raa', 'ر', 'Raa'),
  ArabicLetter('ar-zaay', 'ز', 'Zaay'),
  ArabicLetter('ar-siin', 'س', 'Siin'),
  ArabicLetter('ar-shiin', 'ش', 'Shiin'),
  ArabicLetter('ar-saad', 'ص', 'Saad'),
  ArabicLetter('ar-daad', 'ض', 'Daad'),
  ArabicLetter('ar-taa2', 'ط', 'Taa (heavy)'),
  ArabicLetter('ar-thaa2', 'ظ', 'Dhaa (heavy)'),
  ArabicLetter('ar-ayn', 'ع', 'Ayn'),
  ArabicLetter('ar-ghayn', 'غ', 'Ghayn'),
  ArabicLetter('ar-faa', 'ف', 'Faa'),
  ArabicLetter('ar-qaaf', 'ق', 'Qaaf'),
  ArabicLetter('ar-kaaf', 'ك', 'Kaaf'),
  ArabicLetter('ar-laam', 'ل', 'Laam'),
  ArabicLetter('ar-miim', 'م', 'Miim'),
  ArabicLetter('ar-nuun', 'ن', 'Nuun'),
  ArabicLetter('ar-haa2', 'هـ', 'Haa (soft)'),
  ArabicLetter('ar-waaw', 'و', 'Waaw'),
  ArabicLetter('ar-yaa', 'ي', 'Yaa'),
];

Game gameById(String id) => kGames.firstWhere((g) => g.id == id);
List<Game> gamesInWorld(String world) => kGames.where((g) => g.world == world).toList();

// ---------------- Voiceover lines ----------------
class VoLineData {
  final String id, text, where;
  const VoLineData(this.id, this.text, this.where);
}

/// Non-game screen VO (id → text). Order matters for grouping.
const Map<String, VoLineData> kScreenVo = {
  'age': VoLineData('vo-age', 'How old is your child? Tap their age.', 'Child setup'),
  'practise': VoLineData('vo-practise', 'What should we practise? Tap all the things your child loves.', 'Child setup'),
  'avatar': VoLineData('vo-avatar', 'Choose your buddy! Tap a character, or add your own photo.', 'Child setup'),
  'ready': VoLineData('vo-ready', "Hooray! Your adventure is ready. Let's go!", 'Child setup'),
  'home': VoLineData('vo-home', 'Welcome home! Tap an island to start playing, or tap your Daily Mission.', 'Hub'),
  'mission': VoLineData('vo-mission', "Today's mission has a few quick games. Ready? Let's play!", 'Hub'),
  'break': VoLineData('vo-break', 'Great job! Time for a little break. Stretch, blink, and come back soon!', 'Hub'),
  'rewards': VoLineData('vo-rewards', "Look at all the planets you've collected! Tap one to see it spin.", 'Hub'),
  'gate': VoLineData('vo-gate', 'Grown-ups only! Tap the numbers in order to continue.', 'Hub'),
};

/// Reward reveal VO — one per planet (keyed by planet id, e.g. "p2").
final Map<String, VoLineData> kRewardVo = {
  for (final p in kPlanets)
    p.id: VoLineData('vo-reward-${p.id}',
        'You unlocked ${p.name}! A brand new planet for your collection!',
        'Planet · ${p.name}'),
};

/// The launch-splash sister names — spoken in order over the harp. Stretched
/// defaults (extra letters); re-recordable in the Studio under "Splash screen".
/// Each carries the TTS speech-rate used for its default stretch (1 = least).
const List<VoLineData> kSplashVo = [
  VoLineData('splash-name-1', 'Nimoo', 'Splash · sister 1'),
  VoLineData('splash-name-2', 'Ladannn', 'Splash · sister 2'),
  VoLineData('splash-name-3', 'Hiboooo', 'Splash · sister 3'),
];

/// Short spoken reactions Robo gives during play (every one editable).
const List<VoLineData> kFeedbackVo = [
  VoLineData('vo-fb-toomany', 'Ooh, too many! Take some out.', 'Counting · too many'),
  VoLineData('vo-fb-addmore', 'Not quite — add a few more!', 'Counting · add more'),
  VoLineData('vo-fb-tryagain', 'Oops — try again! You can do it.', 'Wrong answer'),
  VoLineData('vo-fb-nice', 'Nice work! Keep going!', 'Correct answer'),
];

VoLineData feedbackVo(String id) => kFeedbackVo.firstWhere((f) => f.id == id);

class VoGroup {
  final String group;
  final List<VoLineData> lines;
  const VoGroup(this.group, this.lines);
}

/// Build the full registry the Voiceover Studio lists. Every spoken line in
/// the app — including each Arabic letter — is here so it can be re-recorded.
List<VoGroup> buildVoRegistry() {
  final groups = <VoGroup>[];
  groups.add(VoGroup('Splash screen', List.of(kSplashVo)));
  groups.add(VoGroup('Onboarding', [
    for (final o in kOnboarding) VoLineData('vo-onb-${o.id}', o.vo, 'Onboarding ${o.step}'),
  ]));
  final screen = kScreenVo.values.toList();
  groups.add(VoGroup('Setup', screen.sublist(0, 4)));
  groups.add(VoGroup('Hub & Flow', screen.sublist(4)));
  groups.add(VoGroup("Robo's reactions", List.of(kFeedbackVo)));
  for (final g in kGames) {
    final lines = <VoLineData>[];
    for (final r in g.rounds) {
      if (r.vo != null) lines.add(VoLineData(r.id, r.vo!, g.title));
      if (r.factVo != null) lines.add(VoLineData('${r.id}-fact', r.factVo!, '${g.title} · fact'));
      if (r.qVo != null) lines.add(VoLineData('${r.id}-q', r.qVo!, '${g.title} · question'));
    }
    // The alphabet board's spoken content is its 28 letters — each is its
    // own recordable line, in addition to the board's instruction.
    if (g.type == GameType.alphabet) {
      for (final l in kArabicLetters) {
        lines.add(VoLineData(l.id, l.name, 'Arabic letter · ${l.glyph}'));
      }
    }
    groups.add(VoGroup(g.title, lines));
  }
  groups.add(VoGroup('Planet rewards', kRewardVo.values.toList()));
  return groups;
}

/// The floating in-game speaker must use the SAME id the Studio registers.
String voIdForRound(Round r) => r.vo != null ? r.id : '${r.id}-fact';
