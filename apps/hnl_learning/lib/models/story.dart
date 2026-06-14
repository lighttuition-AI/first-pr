// ============================================================
// Somali Story Library — data model + content (SOMALI ONLY).
// ------------------------------------------------------------
// An in-app animated storybook. Each Story plays scene-by-scene: an original
// animated scene (widgets/story_art.dart) + a still "picture" panel that the
// parent can tap to enlarge (and replace with their own art in the Picture
// Studio) + a Somali narration (tap to hear, recordable in the Voiceover
// Studio) + an optional character line. Then a couple of questions and a moral.
//
// The whole library is Somali (af-Soomaali) — no English text or voiceovers.
// Somali is a best-effort simple adaptation of an oral folktale, meant to be
// re-recorded / tuned by a Somali-speaking grown-up.
// ============================================================
import 'package:flutter/material.dart';

/// Which side a character speech bubble sits on (the talking character).
enum Speaker { narrator, left, right }

class StoryScene {
  final String id;

  /// Which animated scene composition to draw (see StorySceneArt).
  final String art;

  /// A still emoji "picture" of the scene's action (a parent can tap it to
  /// enlarge, or upload their own detailed picture into this slot).
  final String picture;

  /// Somali narrator text — tappable + recordable.
  final String narration;

  /// An optional Somali character line, shown in a speech bubble.
  final Speaker speaker;
  final String? line;

  final Color bgTop, bgBottom;

  const StoryScene({
    required this.id,
    required this.art,
    required this.picture,
    required this.narration,
    this.speaker = Speaker.narrator,
    this.line,
    required this.bgTop,
    required this.bgBottom,
  });
}

class StoryOption {
  final String emoji;
  final String label; // Somali
  final bool correct;
  const StoryOption(this.emoji, this.label, {this.correct = false});
}

class StoryQuestion {
  final String id;
  final String q; // Somali
  final List<StoryOption> options;
  const StoryQuestion(this.id, this.q, this.options);
}

class Story {
  final String id;
  final String title; // Somali
  final String emoji;
  final String ageRange;
  final String blurb; // Somali
  final List<StoryScene> scenes;
  final List<StoryQuestion> questions;
  final String moral; // Somali
  final bool ready;

  const Story({
    required this.id,
    required this.title,
    required this.emoji,
    required this.ageRange,
    required this.blurb,
    this.scenes = const [],
    this.questions = const [],
    this.moral = '',
    this.ready = false,
  });
}

/// Stable VO id for a scene's Somali narration (so recordings persist + appear
/// in the Voiceover Studio).
String storyVoId(String storyId, String sceneId) => 'st-$storyId-$sceneId';

/// Stable image-slot id for a scene's still picture (uploadable in the Studio).
String storyPicId(String storyId, String sceneId) => 'storypic-$storyId-$sceneId';

Story storyById(String id) => kStories.firstWhere((s) => s.id == id);

// ============================================================
// 1 — Dawaco iyo Libaax (The Fox and the Lion)
// ============================================================
const _kFoxLion = Story(
  id: 'fox-lion',
  title: 'Dawaco iyo Libaax',
  emoji: '🦊',
  ageRange: '6-8',
  blurb: 'Dawaco caqli badan ayaa Libaax kibirsan tustay in caqligu xoogga ka roon yahay.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'lion-proud', picture: '🦁👑', speaker: Speaker.right, line: 'Anigaa boqor ah! Kan ugu xoogga badan!', narration: 'Banaanka weyn ee cawlan waxaa degganaa Libaax. Subax kasta si dhammaan loo maqlo ayuu u ciyi jiray.', bgTop: Color(0xFFFFE0A3), bgBottom: Color(0xFFFFC76B)),
    StoryScene(id: 's2', art: 'fox-appear', picture: '🦊💭', speaker: Speaker.left, line: 'Xoogu waa fiican yahay — laakiin caqligu waa ka sii fiican yahay.', narration: 'Meel u dhow, Dawaco oo caqli badan ayaa ruxaysay dabadeeda weyn ee casaan ah, way dhoolla caddaysay.', bgTop: Color(0xFFCDEBA6), bgBottom: Color(0xFFFFD98A)),
    StoryScene(id: 's3', art: 'lion-fall', picture: '🦁🕳️', narration: 'Libaax wuu qoslay oo wuxuu muujiyey ilkihiisa waaweyn. Si kibir ah ayuu u tegey — godka qotodheer ee hortiisana ma uu arkin. Dhac! Hoos ayuu u dhacay!', bgTop: Color(0xFFFFD98A), bgBottom: Color(0xFFE8A24D)),
    StoryScene(id: 's4', art: 'lion-pit', picture: '🦁🕳️🆘', speaker: Speaker.right, line: 'I caawiya! Waan bixi kari waayay!', narration: 'Libaax wuu ciyey oo derbiyada ku xardhay, laakiin wuu awoodi waayey inuu kor u baxo. Xooggiisa weyni kuma filnayn.', bgTop: Color(0xFFE8A24D), bgBottom: Color(0xFF9C6B33)),
    StoryScene(id: 's5', art: 'fox-log', picture: '🦊🪵🕳️', speaker: Speaker.left, line: 'Jiridda kor u fuul, Libaax — si tartiib ah!', narration: 'Dawaco way maqashay. Way fikirtay oo fikirtay. Markaas waxay godka ku soo giringirisay jirid weyn, sidii sallaan Libaax ku fuulo.', bgTop: Color(0xFFE8A24D), bgBottom: Color(0xFF9C6B33)),
    StoryScene(id: 's6', art: 'friends', picture: '🦊🤝🦁', speaker: Speaker.right, line: 'Mahadsanid, Dawaco. Caqligaagu waa ka xoog badan yahay ciyaygii.', narration: 'Libaax wuu kor u baxay, ugu dambeyntiina nabad galay. Si tartiib ah ayuu Dawaco ugu mahadceliyey, labadooduna waxay noqdeen saaxiibo aad isu jecel.', bgTop: Color(0xFFBFE8FF), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Sidee Dawaco u caawisay Libaax inuu godka ka baxo?', [
      StoryOption('🪵', 'Jirid bay soo giriñ girisay', correct: true),
      StoryOption('🦁', 'Aad bay u ciyday'),
      StoryOption('🐦', 'Way duushay'),
    ]),
    StoryQuestion('q2', 'Waa maxay casharka sheekada?', [
      StoryOption('🧠', 'Caqli iyo naxariis yeelo', correct: true),
      StoryOption('💪', 'Xoogga oo keliya ayaa muhiim ah'),
      StoryOption('😡', 'Waligaa cidna ha caawin'),
    ]),
  ],
  moral: 'Caqliga iyo naxariistu way ka xoog badan yihiin xoogga keligiis.',
);

// ============================================================
// 2 — Libaax iyo Jiir (The Lion and the Mouse)
// ============================================================
const _kLionMouse = Story(
  id: 'lion-mouse',
  title: 'Libaax iyo Jiir',
  emoji: '🐭',
  ageRange: '3-5',
  blurb: 'Libaax weyn ayaa u naxariistay jiir yar — kaasoo abaalgudaya naxariista.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'lm-sleep', picture: '🦁😴🐭', narration: 'Libaax wuxuu ku hurday hooska markii jiir yaru uu cagtiisa kor uga orday oo uu toosiyey.', bgTop: Color(0xFFFFE9B0), bgBottom: Color(0xFFFFC76B)),
    StoryScene(id: 's2', art: 'lm-catch', picture: '🦁🐭🙏', speaker: Speaker.right, line: 'Fadlan i sii daa! Maalin maalmaha ka mid ah ayaan ku caawin karaa!', narration: 'Libaax wuxuu jiirka yar ku qabtay cagtiisa weyn. Jiirkii oo gariiraya ayaa kor u qayliyey.', bgTop: Color(0xFFFFD98A), bgBottom: Color(0xFFE8A24D)),
    StoryScene(id: 's3', art: 'lm-free', picture: '🦁😄🐭', speaker: Speaker.right, line: 'Soco, yarow!', narration: 'Libaax wuu qoslay — "Sidee mid sidaas u yar iigu caawin karaa?" — laakiin si naxariis leh ayuu jiirkii u sii daayey.', bgTop: Color(0xFFCDEBA6), bgBottom: Color(0xFFFFD98A)),
    StoryScene(id: 's4', art: 'lm-net', picture: '🦁🕸️🆘', speaker: Speaker.right, line: 'I caawiya! Waan xidhmay!', narration: 'Dhowr maalmood ka dib, Libaax wuxuu ku dhacay shabag ugaadhsade. Wuu ciyey oo wuu jiiday, laakiin wuu samri waayey.', bgTop: Color(0xFFE8C27A), bgBottom: Color(0xFFB98A48)),
    StoryScene(id: 's5', art: 'lm-rescue', picture: '🐭🦷🕸️', narration: 'Jiirkii yaraa ayaa maqlay oo soo orday. Ilkihiisa afaysan ayuu ku ruugay ilaa xadhkihii ay go\'aan.', bgTop: Color(0xFFE8C27A), bgBottom: Color(0xFFB98A48)),
    StoryScene(id: 's6', art: 'lm-friends', picture: '🦁🤝🐭', speaker: Speaker.left, line: 'Mahadsanid, saaxiib yarow!', narration: 'Libaax wuu xoroobay! "Xitaa saaxiibka ugu yar ayaa samayn kara waxyaabaha ugu waaweyn." Waxayna noqdeen saaxiibo weligood ah.', bgTop: Color(0xFFBFE8FF), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Sidee jiirka yaru u caawiyey Libaax?', [
      StoryOption('🦷', 'Xadhkihii ayuu ruugay', correct: true),
      StoryOption('🦁', 'Wuu ciyey'),
      StoryOption('🏃', 'Wuu cararay'),
    ]),
    StoryQuestion('q2', 'Maxuu Libaax bartay?', [
      StoryOption('🤝', 'Xitaa saaxiibada yaryar way caawin karaan', correct: true),
      StoryOption('💪', 'Xayawaanka waaweyn oo keliya ayaa muhiim ah'),
      StoryOption('🙅', 'Waligaa saaxiib ha yeelan'),
    ]),
  ],
  moral: 'Qof walba qiimo buu leeyahay — xitaa kan ugu yari wax waaweyn buu qaban karaa.',
);

// ============================================================
// 3 — Geelkii Faanka Badnaa (The Proud Camel)
// ============================================================
const _kProudCamel = Story(
  id: 'proud-camel',
  title: 'Geelkii Faanka Badnaa',
  emoji: '🐫',
  ageRange: '6-8',
  blurb: 'Geel faan badan ayaa bartay in qof walba muhiim yahay — yar iyo weynba.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'pc-proud', picture: '🐫👑', speaker: Speaker.left, line: 'Anigaa ugu weyn oo ugu fiican! Cidna iguma weyna!', narration: 'Geel wuxuu jeclaa faanka. Wuxuu si dheer ugu istaagay cammuudaha si dhammaan loo arko.', bgTop: Color(0xFFFFE0A3), bgBottom: Color(0xFFEAB45E)),
    StoryScene(id: 's2', art: 'pc-boast', picture: '🐫🦊', speaker: Speaker.right, line: 'Qof walba wax buu ku fiican yahay, Geel.', narration: 'Dawaco ayaa kor ugu dhoolla caddaysay. "Qof walba wax buu ku fiican yahay, Geel," ayay tidhi. Laakiin Geel wuu ka hindhisay.', bgTop: Color(0xFFCDEBA6), bgBottom: Color(0xFFEAD08A)),
    StoryScene(id: 's3', art: 'pc-stuck', picture: '🐫🟤🆘', speaker: Speaker.left, line: 'Hoogay! Waan dhegay! I caawiya!', narration: 'Isagoo si kibir ah u socda, Geel ma uu fiirin meeshuu dhigayo — wuxuuna toos u galay dhoobo qoto dheer. Wuu ku liimbaaday!', bgTop: Color(0xFFC9E6F2), bgBottom: Color(0xFFCE9A52)),
    StoryScene(id: 's4', art: 'pc-help', picture: '🦊🐫💪', speaker: Speaker.right, line: 'Dhammaan wada jiida — riix!', narration: 'Dawaco oo caqli badan ayaa u yeedhay xayawaanka oo dhan. Iyagoo wada jira — yar iyo weynba — way jiideen ilaa Geel ka soo baxay.', bgTop: Color(0xFFC9E6F2), bgBottom: Color(0xFFCE9A52)),
    StoryScene(id: 's5', art: 'pc-humble', picture: '🐫🤝🦊', speaker: Speaker.left, line: 'Mahadsanidiin, saaxiibadayaal. Qof walba waa muhiim!', narration: 'Ugu dambeyntii oo nabad galay, Geel wuxuu u mahadceliyey saaxiibadiis. "Hadda waan arkay — qof walba waa muhiim, xitaa kuwa yaryar." Mar dambena ma uu faanin.', bgTop: Color(0xFFBFE8FF), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Maxaa Geel u dhegay?', [
      StoryOption('🐫', 'Si kibir ah ayuu dhoobada u galay', correct: true),
      StoryOption('😴', 'Wuu hurday'),
      StoryOption('🌧️', 'Roob ayaa da\'ayey'),
    ]),
    StoryQuestion('q2', 'Waa maxay casharka?', [
      StoryOption('🤝', 'Is-hoosaysii — qof walba waa muhiim', correct: true),
      StoryOption('🐫', 'Weynaanta ayaa had iyo jeer fiican'),
      StoryOption('🙅', 'Dadka ha caawin'),
    ]),
  ],
  moral: 'Is-hoosaysii — qof walba waa muhiim, yar iyo weynba.',
);

// ============================================================
// 4 — Dawaco iyo Waraabe (The Fox and the Hyena)
// ============================================================
const _kFoxHyena = Story(
  id: 'fox-hyena',
  title: 'Dawaco iyo Waraabe',
  emoji: '🐺',
  ageRange: '6-8',
  blurb: 'Dawaco caqli badan ayaa ka adkaata Waraabe hunguri weyn.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'fh-meet', picture: '🐺🍖', speaker: Speaker.right, line: 'Cuntadan oo dhan anigaa iska leh!', narration: 'Waraabe oo hunguri weyn ayaa helay cad hilib ah. Wuu ku faraxsanaa, oo cidna ma uu wadaagi rabin.', bgTop: Color(0xFFEAD9B0), bgBottom: Color(0xFFD9B978)),
    StoryScene(id: 's2', art: 'fh-trick', picture: '🦊👉🧀', speaker: Speaker.left, line: 'Waraabow! Halkaas waxaa yaal hilib aad u badan!', narration: 'Dawaco oo caqli badan ayaa aragtay. "Waraabow," ayay tidhi, "halkaas waxaa yaal cunto aad uga badan tan!"', bgTop: Color(0xFFCDEBA6), bgBottom: Color(0xFFEAD08A)),
    StoryScene(id: 's3', art: 'fh-greed', picture: '🐺🏃💨', narration: 'Waraabe hungurigiisu wuu badnaa. Cadkiisii wuu iska daayey oo si dheereyn ah ayuu ugu orday meeshii kale — laakiin waxba kuma jirin!', bgTop: Color(0xFFEAD9B0), bgBottom: Color(0xFFD9B978)),
    StoryScene(id: 's4', art: 'fh-gone', picture: '🦊😋🍖', narration: 'Markuu soo laabtay, cadkiisii hore wuu ka maqnaa. Dawaco ayaa si tartiib ah u cuntay. Hungurigu wuu lumiyey waxa uu hayey.', bgTop: Color(0xFFFFE9C7), bgBottom: Color(0xFFEAD08A)),
    StoryScene(id: 's5', art: 'fh-lesson', picture: '🐺😔💡', speaker: Speaker.right, line: 'Hungurigu wax kama tarin. Waa inaan maskaxdayda isticmaalo.', narration: 'Waraabe wuu xishooday. "Hunguri badnaantu wax xun bay ii keentay," ayuu yidhi. Maalintaas wuxuu bartay inuu fikiro ka hor intaanu wax samayn.', bgTop: Color(0xFFBFE8FF), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Maxaa keenay in Waraabe cuntadiisii lumiyo?', [
      StoryOption('🍖', 'Hungurigiisa badan', correct: true),
      StoryOption('😴', 'Hurdadiisa'),
      StoryOption('🌧️', 'Roobka'),
    ]),
    StoryQuestion('q2', 'Waa maxay casharka?', [
      StoryOption('🧠', 'Maskaxda isticmaal, hungurina ha badan', correct: true),
      StoryOption('🏃', 'Had iyo jeer orod'),
      StoryOption('😡', 'Cidna ha aamin'),
    ]),
  ],
  moral: 'Hunguri badnaantu waa belaayo — maskaxdaada isticmaal.',
);

// ============================================================
// 5 — Wiil Waal (The Clever Boy)
// ============================================================
const _kWiilWaal = Story(
  id: 'wiil-waal',
  title: 'Wiil Waal',
  emoji: '🤓',
  ageRange: '9-12',
  blurb: 'Wiil caqli badan ayaa xalliya wax dadka waaweyni ay ku guuldareystaan.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'ww-intro', picture: '🤓📖', narration: 'Waxaa jiray wiil yar oo caqli badan oo aad u jeclaa akhriska. Had iyo jeer buug ayuu sitay.', bgTop: Color(0xFFBFE3FF), bgBottom: Color(0xFFD9EFB8)),
    StoryScene(id: 's2', art: 'ww-problem', picture: '👴❓', speaker: Speaker.right, line: 'Yaa ii sheegi kara jawaabta su\'aashan adag?', narration: 'Maalin maalmaha ka mid ah, odayaasha tuulada ayaa la kulmay su\'aal aad u adag. Cidna ma ay garan jawaabta.', bgTop: Color(0xFFFFE9C7), bgBottom: Color(0xFFEAD08A)),
    StoryScene(id: 's3', art: 'ww-think', picture: '🤓💭📖', narration: 'Wiil Waal wuu fariistay oo wuu fikiray. Buuggiisii ayuu akhriyey, oo si fiican ayuu uga fakaray.', bgTop: Color(0xFFD9EFB8), bgBottom: Color(0xFFEAD08A)),
    StoryScene(id: 's4', art: 'ww-solve', picture: '🤓💡', speaker: Speaker.left, line: 'Waan helay jawaabta! Way fudud tahay haddaad fikirto.', narration: 'Wiil Waal jawaabtii ayuu helay! Si caqli leh ayuu u sharraxay, dhammaanna way la yaabeen.', bgTop: Color(0xFFCDEBA6), bgBottom: Color(0xFFD9EFB8)),
    StoryScene(id: 's5', art: 'ww-respect', picture: '👏🤓🎉', narration: 'Tuulada oo dhan ayaa wiilka caqliga leh ammaantay. Way barteen in caqligu ka qiimo badan yahay xoogga.', bgTop: Color(0xFFBFE8FF), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Maxuu Wiil Waal ku xalliyey su\'aasha?', [
      StoryOption('🧠', 'Caqligiisa iyo akhriskiisa', correct: true),
      StoryOption('💪', 'Xooggiisa'),
      StoryOption('🏃', 'Orodkiisa'),
    ]),
    StoryQuestion('q2', 'Waa maxay casharka?', [
      StoryOption('📖', 'Caqligu xoog buu ka roon yahay', correct: true),
      StoryOption('💪', 'Xoogga ayaa muhiim ah'),
      StoryOption('😴', 'Waxba ha baran'),
    ]),
  ],
  moral: 'Caqliga iyo aqoontu waxay ka xoog badan yihiin itaalka jirka.',
);

// ============================================================
// 6 — Dhegdheer (The Ogre Woman)
// ============================================================
const _kDhegdheer = Story(
  id: 'dhegdheer',
  title: 'Dhegdheer',
  emoji: '👹',
  ageRange: '9-12',
  blurb: 'Carruur caqli badan ayaa ka baxsata Dhegdheer oo dheg weyn ku maqasha qof kasta.',
  ready: true,
  scenes: [
    StoryScene(id: 's1', art: 'dd-warn', picture: '👧👦🌳', narration: 'Laba carruur ah ayaa ku ciyaaraya meel u dhow kaynta. Waayeelku waxay uga digeen inay ka fogaadaan Dhegdheer.', bgTop: Color(0xFFCDE8B0), bgBottom: Color(0xFFE8D58A)),
    StoryScene(id: 's2', art: 'dd-appear', picture: '👹👂', speaker: Speaker.left, line: 'Waan ku maqlayaa… meel kastood joogtaan!', narration: 'Dhegdheer ayaa soo baxday — naag weyn oo leh hal dheg oo aad u weyn oo ay wax kasta ku maqasho meel fog.', bgTop: Color(0xFF9FB9D6), bgBottom: Color(0xFFB8A0C8)),
    StoryScene(id: 's3', art: 'dd-listen', picture: '👂🔊', narration: 'Dhegdheer dhegteeda weyn ayay wax walba ku maqashaa. Carruurtu way baqeen, laakiin ma ay ooyin.', bgTop: Color(0xFF9FB9D6), bgBottom: Color(0xFFB8A0C8)),
    StoryScene(id: 's4', art: 'dd-plan', picture: '🤫💭', speaker: Speaker.right, line: 'Aamus… si qunyar ah u hadal si aysan noo maqlin.', narration: 'Carruurtu way fikireen. Si aad u qunyar ah ayay isula hadleen, oo qorshe ay ku baxsadaan ayay sameeyeen.', bgTop: Color(0xFFCDE8B0), bgBottom: Color(0xFFE8D58A)),
    StoryScene(id: 's5', art: 'dd-escape', picture: '🏃👧👦🌊', narration: 'Markay Dhegdheer hurudday, carruurtii si qunyar ah ayay u carareen oo webigii ay ka gudbeen. Dhegteedu ma ay maqlin!', bgTop: Color(0xFFBFE3FF), bgBottom: Color(0xFFCDE8B0)),
    StoryScene(id: 's6', art: 'dd-safe', picture: '🏡👧👦❤️', narration: 'Carruurtii nabad ayay guriga ku noqdeen. Way barteen inay dhegaystaan waayeelka, oo ay si caqli leh u wada shaqeeyaan.', bgTop: Color(0xFFFFE9C7), bgBottom: Color(0xFFCDEBA6)),
  ],
  questions: [
    StoryQuestion('q1', 'Maxay carruurtu ku baxsadeen Dhegdheer?', [
      StoryOption('🤫', 'Caqli iyo aamusnaan', correct: true),
      StoryOption('💪', 'Xoog'),
      StoryOption('😡', 'Dagaal'),
    ]),
    StoryQuestion('q2', 'Waa maxay casharka?', [
      StoryOption('👂', 'Dhegayso waayeelka oo fikir', correct: true),
      StoryOption('🏃', 'Kaligaa orod'),
      StoryOption('🙈', 'Waxba ha dhegaysan'),
    ]),
  ],
  moral: 'Dhegayso waayeelkaaga, fikirna ka hor intaadan wax samayn.',
);

// The remaining recognisable folktales — scaffolded; built out next.
const _kComingSoon = [
  Story(id: 'goat-hyena', title: 'Ari iyo Waraabe', emoji: '🐐', ageRange: '3-5', blurb: 'Ari caqli badan ayaa ka baxsata Waraabe gaajaysan.'),
  Story(id: 'brave-bird', title: 'Shimbirta Yar ee Geesiga Ah', emoji: '🐦', ageRange: '3-5', blurb: 'Shimbir yar ayaa ka geesinimo badan xayawaanka waaweyn.'),
  Story(id: 'lost-camel', title: 'Wiilkii iyo Geelkii Lumay', emoji: '🔎', ageRange: '9-12', blurb: 'Wiil ayaa calaamado ku raadiya geel lumay.'),
  Story(id: 'wise-man', title: 'Boqorkii iyo Ninkii Xikmadda Badnaa', emoji: '👑', ageRange: '9-12', blurb: 'Nin xikmad badan ayaa xalliya halxidhaalaha boqorka.'),
];

final List<Story> kStories = [
  _kFoxLion,
  _kLionMouse,
  _kProudCamel,
  _kFoxHyena,
  _kWiilWaal,
  _kDhegdheer,
  ..._kComingSoon,
];
