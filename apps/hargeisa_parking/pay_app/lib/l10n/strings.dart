import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight bilingual support for HPark Pay (English ⇄ af-Soomaali).
///
/// Strings are looked up by their English source text via [tr]: when Somali is
/// active and a translation exists it is used, otherwise the English text is
/// returned unchanged (so nothing ever goes blank). Templates use `{name}`
/// placeholders filled with [trf].
enum AppLang { en, so }

class LocaleController extends ChangeNotifier {
  static const _key = 'pay_lang';

  AppLang _lang = AppLang.en;
  AppLang get lang => _lang;
  bool get isSomali => _lang == AppLang.so;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lang = (prefs.getString(_key) == 'so') ? AppLang.so : AppLang.en;
    } catch (_) {
      _lang = AppLang.en;
    }
  }

  Future<void> set(AppLang lang) async {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, lang.name);
    } catch (_) {/* non-fatal */}
  }
}

/// Shared locale controller (mirrors the theme controller pattern).
final LocaleController localeCtrl = LocaleController();

/// Translate an English source string to the active language.
String tr(String en) => localeCtrl.isSomali ? (_so[en] ?? en) : en;

/// Translate + fill `{placeholders}`. e.g. trf('Pay {amount}', {'amount': x}).
String trf(String en, Map<String, String> args) {
  var s = tr(en);
  args.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

/// English → Somali dictionary. Translations are best-effort Somaliland Somali
/// and meant to be reviewed by a native speaker; any missing key falls back to
/// English automatically.
const Map<String, String> _so = {
  // ---- Bottom navigation ----
  'Home': 'Bogga',
  'Districts': 'Degmooyin',
  'Profile': 'Akoonka',

  // ---- Auth ----
  'CITIZEN APP': 'APP-KA MUWAADINKA',
  'Welcome to HPark Pay': 'Ku soo dhowoow HPark Pay',
  'Create your account': 'Samee akoonkaaga',
  'Sign in to see and pay your parking citations.':
      'Soo gal si aad u aragto oo u bixiso ganaaxyadaada baarkinka.',
  'Register to see your citations and pay via ZAAD or eDahab.':
      'Isdiiwaangeli si aad u aragto ganaaxyadaada oo aad ugu bixiso ZAAD ama eDahab.',
  'Full name': 'Magaca oo dhan',
  'Your name': 'Magacaaga',
  'Email': 'Iimayl',
  'Password': 'Furaha sirta',
  'Somaliland national ID': 'Aqoonsiga qaranka Somaliland',
  'Vehicle plate (optional)': 'Taarikada baabuurka (ikhtiyaari)',
  'Date of birth': 'Taariikhda dhalashada',
  'Select date': 'Dooro taariikh',
  'Create account': 'Samee akoon',
  'Sign in': 'Soo gal',
  'Create an account': 'Samee akoon',
  'Already have an account?': 'Akoon ma haysataa?',
  'New here?': 'Ma cusub tahay?',
  'Please fill in all fields, including date of birth.':
      'Fadlan buuxi dhammaan meelaha, oo ay ku jirto taariikhda dhalashada.',
  'That email already has an account. Sign in instead.':
      'Iimaylkaas akoon ayuu leeyahay. Halkii soo gal.',
  'Email or password is incorrect.': 'Iimaylka ama furaha sirta waa khaldan yahay.',
  'Password should be at least 6 characters.':
      'Furaha sirta waa inuu ahaadaa ugu yaraan 6 xaraf.',
  'That email address looks invalid.': 'Iimaylkaas wuxuu u muuqdaa mid aan sax ahayn.',

  // ---- Home ----
  'OUTSTANDING BALANCE': 'LACAGTA LAGUGU LEEYAHAY',
  'All settled': 'Dhammaan waa la bixiyay',
  'Nothing to pay': 'Wax la bixiyo ma jiro',
  'Pay now': 'Hadda bixi',
  'Your citations': 'Ganaaxyadaada',
  'No citations': 'Ganaax ma jiro',
  'You have a clean record for {plate}.': 'Rikoorkaagu waa nadiif {plate}.',
  'Add your vehicle': 'Ku dar baabuurkaaga',
  'Enter your number plate to see and pay your parking citations.':
      'Geli lambarka taarikada si aad u aragto oo u bixiso ganaaxyada baarkinka.',
  'Add number plate': 'Ku dar lambarka taarikada',
  'Paid {amount} via {method}': 'Waxaa la bixiyay {amount} iyadoo loo marayo {method}',

  // ---- Citation status (from hpark_core CitationStatus.label) ----
  'Outstanding': 'Aan la bixin',
  'Paid': 'La bixiyay',
  'Appeal review': 'Dib-u-eegis',
  'Dismissed': 'La tirtiray',

  // ---- Citation detail ----
  'Citation': 'Ganaax',
  'Reference': 'Tixraac',
  'District': 'Degmo',
  'Issued': 'La soo saaray',
  'Fine': 'Ganaax',
  'Challenge': 'Racfaan',
  "Your video appeal is under review. We'll notify you of the decision.":
      'Racfaankaaga fiidiyowga ah waa la eegayaa. Waad la soo xiriiri doonnaa go\'aanka.',

  // ---- Pay sheet ----
  'Pay {amount}': 'Bixi {amount}',
  'Choose a mobile money provider.': 'Dooro adeegga lacagta mobaylka.',

  // ---- Appeal flow ----
  'Record your appeal': 'Duub racfaankaaga',
  'Review': 'Dib u eeg',
  'Appeal submitted': 'Racfaanka waa la gudbiyay',
  "Explain what you're challenging about citation {id}.":
      'Sharax waxa aad ka cabanayso ganaaxa {id}.',
  'Add a note (optional)': 'Ku dar qoraal (ikhtiyaari)',
  'Briefly summarise your appeal': 'Si kooban u soo koob racfaankaaga',
  'Re-record': 'Dib u duub',
  'Submit appeal': 'Gudbi racfaanka',
  "Your video appeal for {id} is under review. You'll be notified of the decision.":
      'Racfaankaaga fiidiyowga ah ee {id} waa la eegayaa. Waad la soo xiriiri doonnaa go\'aanka.',
  'Done': 'Diyaar',

  // ---- Appeals screen ----
  'Your appeals': 'Racfaannadaada',
  'Add your vehicle plate in Profile to track appeals.':
      'Ku dar taarikada baabuurkaaga Akoonka si aad ula socoto racfaannada.',
  'You haven\'t submitted any appeals.\nOpen a citation and tap "Challenge" to appeal.':
      'Weli racfaan ma aadan gudbin.\nFur ganaax oo taabo "Racfaan" si aad u racfaanto.',
  'Citation cancelled': 'Ganaaxa waa la joojiyay',
  'Citation stands': 'Ganaaxa wuu taagan yahay',
  'Awaiting decision': 'Sugaya go\'aan',

  // ---- Districts & deals ----
  'Districts & deals': 'Degmooyinka & dheefaha',
  'Tap a district to see shops advertising deals nearby.':
      'Taabo degmo si aad u aragto dukaamada dheefo bixinaya.',
  'No deals yet': 'Weli dheef ma jirto',
  'Loading deals…': 'Dheefaha waa la soo dejinayaa…',
  '{n} deals available': '{n} dheef la heli karo',
  'No deals in this district yet.': 'Weli degmadan dheef kuma jirto.',
  'Scan at the till to redeem': 'Iskaan garee kaashka si aad u hesho',

  // ---- Profile ----
  'National ID': 'Aqoonsiga qaranka',
  'Appearance': 'Muuqaalka',
  'Dark': 'Madow',
  'Light': 'Iftiin',
  'Vehicle plate': 'Taarikada baabuurka',
  'Tap to add your number plate': 'Taabo si aad ugu darto lambarkaaga taarikada',
  'Payment history': 'Taariikhda lacag-bixinta',
  'Past ZAAD & eDahab payments': 'Lacag-bixinnadii hore ee ZAAD & eDahab',
  'Appeals': 'Racfaannada',
  'Track your video appeals': 'La soco racfaannadaada fiidiyowga',
  'Language': 'Luqadda',
  'Help & support': 'Caawimaad & taageero',
  'Contact the city office': 'La xiriir xafiiska magaalada',
  'Sign out': 'Ka bax',
  'Hargeisa City Parking Office': 'Xafiiska Baarkinka Magaalada Hargeysa',
  'Phone': 'Telefoon',
  'Hours': 'Saacadaha',
  'English': 'Ingiriisi',
  'Somali (Soomaali)': 'Soomaali',

  // ---- Payment history ----
  'TOTAL PAID': 'WADARTA LA BIXIYAY',
  'No payments yet.': 'Weli lacag lama bixin.',

  // ---- Edit dialogs ----
  'Your vehicle plate': 'Taarikada baabuurkaaga',
  'Enter your number plate so we can show your citations.':
      'Geli lambarka taarikada si aan kuugu tuso ganaaxyadaada.',
  'Number plate': 'Lambarka taarikada',
  'Correct your Somaliland national ID if it was entered wrong.':
      'Sax aqoonsigaaga qaranka haddii si khaldan loo geliyay.',
  'Cancel': 'Jooji',
  'Save': 'Kaydi',
};
