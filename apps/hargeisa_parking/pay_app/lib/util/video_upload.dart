import 'dart:io';

import 'package:http/http.dart' as http;

/// Uploads an appeal video to a free, no-account host and returns its public
/// URL, or null on failure (the appeal still submits without a video).
///
/// Uses **catbox.moe** — anonymous, free, no account / card / country signup
/// (so there is no gate to hit), suitable for testing. The returned URL is a
/// direct file link the dashboard can play.
///
/// SWAP POINT — for production (private, access-controlled storage), replace the
/// body of this one function with a Supabase / Firebase Storage upload. Callers
/// only depend on "give a File, get back a URL", so nothing else changes.
Future<String?> uploadAppealVideo(File file) async {
  try {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('https://catbox.moe/user/api.php'),
    )
      ..fields['reqtype'] = 'fileupload'
      ..files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));
    final resp = await req.send().timeout(const Duration(seconds: 120));
    if (resp.statusCode != 200) return null;
    final url = (await http.Response.fromStream(resp)).body.trim();
    return url.startsWith('http') ? url : null;
  } catch (_) {
    return null;
  }
}
