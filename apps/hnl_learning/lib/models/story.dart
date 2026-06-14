// ============================================================
// Somali Story Library — data model + content.
// ------------------------------------------------------------
// An in-app animated storybook. Each Story plays scene-by-scene: an original
// animated scene (drawn in widgets/story_art.dart), a bilingual narration
// (English + Somali — tap to hear, recordable in the Voiceover Studio), an
// optional character line, then end-of-story questions and a moral screen.
//
// Somali text is a best-effort simple adaptation of an oral folktale — meant to
// be re-recorded / tuned by a Somali-speaking grown-up (same convention as the
// rest of the app). Stories are *inspired adaptations*, not fixed texts.
// ============================================================
import 'package:flutter/material.dart';

/// Who is speaking a dialogue line in a scene (drives the speech bubble).
enum Speaker { narrator, fox, lion }

class StoryScene {
  final String id;

  /// Which scene composition to draw (see StorySceneArt in story_art.dart).
  final String art;

  /// Narrator text — English + Somali. Each is tappable + recordable.
  final String narrationEn;
  final String narrationSo;

  /// An optional short character line shown in a speech bubble.
  final Speaker speaker;
  final String? lineEn;
  final String? lineSo;

  final Color bgTop, bgBottom;

  const StoryScene({
    required this.id,
    required this.art,
    required this.narrationEn,
    required this.narrationSo,
    this.speaker = Speaker.narrator,
    this.lineEn,
    this.lineSo,
    required this.bgTop,
    required this.bgBottom,
  });
}

class StoryOption {
  final String emoji;
  final String labelEn, labelSo;
  final bool correct;
  const StoryOption(this.emoji, this.labelEn, this.labelSo, {this.correct = false});
}

class StoryQuestion {
  final String id;
  final String qEn, qSo;
  final List<StoryOption> options;
  const StoryQuestion(this.id, this.qEn, this.qSo, this.options);
}

class Story {
  final String id;
  final String titleEn, titleSo;
  final String emoji;
  final String ageRange; // e.g. '6-8'
  final String blurbEn, blurbSo;
  final List<StoryScene> scenes;
  final List<StoryQuestion> questions;
  final String moralEn, moralSo;

  /// false → shown in the library as "coming soon" (no scenes yet).
  final bool ready;

  const Story({
    required this.id,
    required this.titleEn,
    required this.titleSo,
    required this.emoji,
    required this.ageRange,
    required this.blurbEn,
    required this.blurbSo,
    this.scenes = const [],
    this.questions = const [],
    this.moralEn = '',
    this.moralSo = '',
    this.ready = false,
  });
}

/// VO ids for a scene's narration (stable, so recordings persist + appear in the
/// Voiceover Studio). One per language.
String storyVoId(String storyId, String sceneId, String lang) => 'st-$storyId-$sceneId-$lang';

Story storyById(String id) => kStories.firstWhere((s) => s.id == id);

// ------------------------------------------------------------
// The library. Story 1 (Fox & Lion) is fully built; the rest are
// recognisable Somali folktales scaffolded as "coming soon".
// ------------------------------------------------------------
const _kFoxLion = Story(
  id: 'fox-lion',
  titleEn: 'The Fox and the Lion',
  titleSo: 'Dawaco iyo Libaax',
  emoji: '🦊',
  ageRange: '6-8',
  blurbEn: 'A clever fox shows a proud lion that wisdom beats strength.',
  blurbSo: 'Dawaco caqli badan ayaa Libaax kibirsan tustay in caqligu xoogga ka roon yahay.',
  ready: true,
  scenes: [
    StoryScene(
      id: 's1',
      art: 'lion-proud',
      narrationEn: 'In the wide golden savanna lived Libaax the lion. Every morning he roared so all could hear.',
      narrationSo: 'Banaanka weyn ee cawlan waxaa degganaa Libaax. Subax kasta si dhammaan loo maqlo ayuu u ciyi jiray.',
      speaker: Speaker.lion,
      lineEn: 'I am the king! The strongest of all!',
      lineSo: 'Anigaa boqor ah! Kan ugu xoogga badan!',
      bgTop: Color(0xFFFFE0A3),
      bgBottom: Color(0xFFFFC76B),
    ),
    StoryScene(
      id: 's2',
      art: 'fox-appear',
      narrationEn: 'Nearby, Dawaco the clever fox swished her big orange tail and smiled.',
      narrationSo: 'Meel u dhow, Dawaco oo caqli badan ayaa ruxaysay dabadeeda weyn ee casaan ah, way dhoolla caddaysay.',
      speaker: Speaker.fox,
      lineEn: 'Being strong is good, Libaax — but being clever is better.',
      lineSo: 'Xoogu waa fiican yahay, Libaax — laakiin caqligu waa ka sii fiican yahay.',
      bgTop: Color(0xFFCDEBA6),
      bgBottom: Color(0xFFFFD98A),
    ),
    StoryScene(
      id: 's3',
      art: 'lion-fall',
      narrationEn: 'Libaax just laughed and showed his big teeth. He stomped away proudly — and did not see the deep pit ahead. Tumble! Down he fell!',
      narrationSo: 'Libaax wuu qoslay oo wuxuu muujiyey ilkihiisa waaweyn. Si kibir ah ayuu u tegey — godka qotodheer ee hortiisana ma uu arkin. Dhac! Hoos ayuu u dhacay!',
      bgTop: Color(0xFFFFD98A),
      bgBottom: Color(0xFFE8A24D),
    ),
    StoryScene(
      id: 's4',
      art: 'lion-pit',
      narrationEn: 'The lion roared and clawed at the walls, but he could not climb out. His great strength was not enough.',
      narrationSo: 'Libaax wuu ciyey oo derbiyada ku xardhay, laakiin wuu awoodi waayey inuu kor u baxo. Xooggiisa weyni kuma filnayn.',
      speaker: Speaker.lion,
      lineEn: 'Help! I cannot get out!',
      lineSo: 'I caawiya! Waan bixi kari waayay!',
      bgTop: Color(0xFFE8A24D),
      bgBottom: Color(0xFF9C6B33),
    ),
    StoryScene(
      id: 's5',
      art: 'fox-log',
      narrationEn: 'Dawaco heard him. She thought and thought. Then she rolled a big log into the pit, like a ladder for Libaax to climb.',
      narrationSo: 'Dawaco way maqashay. Way fikirtay oo fikirtay. Markaas waxay godka ku soo giriñ girisay jirid weyn, sidii sallaan Libaax ku fuulo.',
      speaker: Speaker.fox,
      lineEn: 'Climb up the log, Libaax — slow and steady!',
      lineSo: 'Jiridda kor u fuul, Libaax — si tartiib ah!',
      bgTop: Color(0xFFE8A24D),
      bgBottom: Color(0xFF9C6B33),
    ),
    StoryScene(
      id: 's6',
      art: 'friends',
      narrationEn: 'Libaax climbed out, safe at last. He thanked Dawaco softly, and the two became the best of friends.',
      narrationSo: 'Libaax wuu kor u baxay, ugu dambeyntiina nabad galay. Si tartiib ah ayuu Dawaco ugu mahadceliyey, labadooduna waxay noqdeen saaxiibo aad isu jecel.',
      speaker: Speaker.lion,
      lineEn: 'Thank you, Dawaco. Your wisdom is stronger than my roar.',
      lineSo: 'Mahadsanid, Dawaco. Caqligaagu waa ka xoog badan yahay ciyaygii.',
      bgTop: Color(0xFFBFE8FF),
      bgBottom: Color(0xFFCDEBA6),
    ),
  ],
  questions: [
    StoryQuestion(
      'q1',
      'How did Dawaco help Libaax out of the pit?',
      'Sidee Dawaco u caawisay Libaax inuu godka ka baxo?',
      [
        StoryOption('🪵', 'She rolled in a log', 'Jirid bay soo giriñ girisay', correct: true),
        StoryOption('🦁', 'She roared loudly', 'Aad bay u ciyday'),
        StoryOption('🐦', 'She flew away', 'Way duushay'),
      ],
    ),
    StoryQuestion(
      'q2',
      'What is the lesson of the story?',
      'Waa maxay casharka sheekada?',
      [
        StoryOption('🧠', 'Be clever and kind', 'Caqli iyo naxariis yeelo', correct: true),
        StoryOption('💪', 'Only strength matters', 'Xoogga oo keliya ayaa muhiim ah'),
        StoryOption('😡', 'Never help others', 'Waligaa cidna ha caawin'),
      ],
    ),
  ],
  moralEn: 'Wisdom and kindness are stronger than strength alone.',
  moralSo: 'Caqliga iyo naxariistu way ka xoog badan yihiin xoogga keligiis.',
);

// The recognisable Somali folktales — scaffolded; built out one at a time.
const _kComingSoon = [
  Story(id: 'fox-hyena', titleEn: 'The Fox and the Hyena', titleSo: 'Dawaco iyo Waraabe', emoji: '🐺', ageRange: '6-8', blurbEn: 'The clever fox outwits a greedy hyena.', blurbSo: 'Dawaco caqli badan ayaa ka adkaata Waraabe hunguri weyn.'),
  Story(id: 'lion-mouse', titleEn: 'The Lion and the Mouse', titleSo: 'Libaax iyo Jiir', emoji: '🐭', ageRange: '3-5', blurbEn: 'A tiny mouse repays a mighty lion\'s kindness.', blurbSo: 'Jiir yar ayaa ka abaalgudaya naxariista Libaax weyn.'),
  Story(id: 'proud-camel', titleEn: 'The Proud Camel', titleSo: 'Geelkii Faanka Badnaa', emoji: '🐫', ageRange: '6-8', blurbEn: 'A boastful camel learns to be humble.', blurbSo: 'Geel faan badan ayaa bartay is-hoosaysiinta.'),
  Story(id: 'goat-hyena', titleEn: 'The Goat and the Hyena', titleSo: 'Ari iyo Waraabe', emoji: '🐐', ageRange: '3-5', blurbEn: 'A clever goat escapes a hungry hyena.', blurbSo: 'Ari caqli badan ayaa ka baxsata Waraabe gaajaysan.'),
  Story(id: 'brave-bird', titleEn: 'The Brave Little Bird', titleSo: 'Shimbirta Yar ee Geesiga Ah', emoji: '🐦', ageRange: '3-5', blurbEn: 'A tiny bird is braver than all the big animals.', blurbSo: 'Shimbir yar ayaa ka geesinimo badan xayawaanka waaweyn.'),
  Story(id: 'wiil-waal', titleEn: 'Wiil Waal, the Clever Boy', titleSo: 'Wiil Waal', emoji: '🤓', ageRange: '9-12', blurbEn: 'A clever boy solves what grown-ups cannot.', blurbSo: 'Wiil caqli badan ayaa xalliya wax dadka waaweyni ay ku guuldareystaan.'),
  Story(id: 'lost-camel', titleEn: 'The Boy and the Lost Camel', titleSo: 'Wiilkii iyo Geelkii Lumay', emoji: '🔎', ageRange: '9-12', blurbEn: 'A boy uses clues to find a missing camel.', blurbSo: 'Wiil ayaa calaamado ku raadiya geel lumay.'),
  Story(id: 'wise-man', titleEn: 'The King and the Wise Man', titleSo: 'Boqorkii iyo Ninkii Xikmadda Badnaa', emoji: '👑', ageRange: '9-12', blurbEn: 'A wise villager solves a king\'s riddles.', blurbSo: 'Nin xikmad badan ayaa xalliya halxidhaalaha boqorka.'),
  Story(id: 'dhegdheer', titleEn: 'Dhegdheer, the Ogre', titleSo: 'Dhegdheer', emoji: '👹', ageRange: '9-12', blurbEn: 'Clever children outwit the long-eared ogre.', blurbSo: 'Carruur caqli badan ayaa ka baxsata Dhegdheer.'),
];

final List<Story> kStories = [_kFoxLion, ..._kComingSoon];
