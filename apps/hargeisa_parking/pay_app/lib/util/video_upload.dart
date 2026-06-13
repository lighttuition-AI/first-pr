import 'dart:io';

import 'package:http/http.dart' as http;

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
/// SWAP POINT — the entire storage backend lives in this one function. To move
/// to private/signed-URL storage later, change only here; callers just hand in a
/// File and get a URL back.
Future<String?> uploadAppealVideo(File file) async {
  try {
    final ext = file.path.contains('.') ? file.path.split('.').last.toLowerCase() : 'mp4';
    final name = 'APL-${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bytes = await file.readAsBytes();
    final resp = await http
        .post(
          Uri.parse('$_supabaseUrl/storage/v1/object/$_bucket/$name'),
          headers: {
            'apikey': _supabaseAnonKey,
            'Authorization': 'Bearer $_supabaseAnonKey',
            'Content-Type': _contentType(ext),
            'x-upsert': 'true',
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 120));
    if (resp.statusCode != 200 && resp.statusCode != 201) return null;
    // Public bucket → this URL plays directly in the dashboard.
    return '$_supabaseUrl/storage/v1/object/public/$_bucket/$name';
  } catch (_) {
    return null;
  }
}

String _contentType(String ext) => switch (ext) {
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      'mp4' => 'video/mp4',
      _ => 'application/octet-stream',
    };
