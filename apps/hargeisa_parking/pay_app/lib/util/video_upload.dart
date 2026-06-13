import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

// --- Supabase Storage (public `appeals` bucket) -----------------------------
// The Project URL + anon key are public by design (safe to embed); what the key
// can do is limited by the bucket's RLS policies (anon may only upload to /
// read the `appeals` bucket).
const _supabaseUrl = 'https://zwpplvjiwviyikxjlwve.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3cHBsdmppd3ZpeWlreGpsd3ZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODExMjYsImV4cCI6MjA5Njg1NzEyNn0.io8jy671ugm789CB6IrX4PYr0Boydj9IQC8bc0RyyQo';
const _bucket = 'appeals';

/// Uploads an appeal video to Supabase Storage and returns its public URL, or
/// null on failure (the appeal still submits without a clip).
///
/// The phone records `.mov` (QuickTime), which browsers can't play — so we first
/// convert to `.mp4` (H.264) so the dashboard plays it in any browser.
///
/// SWAP POINT — the storage backend lives in this one file. To move to
/// private/signed-URL storage later, change only here.
Future<String?> uploadAppealVideo(File file) async {
  try {
    final playable = await _toMp4(file);
    final name = 'APL-${DateTime.now().millisecondsSinceEpoch}.mp4';
    final bytes = await playable.readAsBytes();
    final resp = await http
        .post(
          Uri.parse('$_supabaseUrl/storage/v1/object/$_bucket/$name'),
          headers: {
            'apikey': _supabaseAnonKey,
            'Authorization': 'Bearer $_supabaseAnonKey',
            'Content-Type': 'video/mp4',
            'x-upsert': 'true',
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 180));
    if (resp.statusCode != 200 && resp.statusCode != 201) return null;
    // Public bucket → this URL plays directly in the dashboard.
    return '$_supabaseUrl/storage/v1/object/public/$_bucket/$name';
  } catch (_) {
    return null;
  }
}

/// Re-wraps/transcodes the recording to a browser-friendly .mp4 (H.264) using
/// the OS encoder. Returns the original file if conversion isn't available.
Future<File> _toMp4(File input) async {
  if (input.path.toLowerCase().endsWith('.mp4')) return input;
  try {
    final info = await VideoCompress.compressVideo(
      input.path,
      quality: VideoQuality.MediumQuality,
      includeAudio: true,
    );
    final out = info?.file;
    if (out != null && await out.exists() && await out.length() > 0) return out;
  } catch (_) {/* fall back to the original */}
  return input;
}
