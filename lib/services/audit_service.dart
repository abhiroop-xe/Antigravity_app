import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../main.dart';

class AuditService {
  SupabaseClient? get _supabase {
    try {
      if (!isSupabaseInitialized) return null;
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Logs an action to the audit_logs table.
  /// [action] - The type of action (e.g., 'Enrichment Requested')
  /// [details] - Additional context (e.g., 'Lead ID: 123')
  /// [dataToHash] - Optional data to create a hash for verification.
  Future<void> logAction({
    required String action,
    String? details,
    String? dataToHash,
  }) async {
    try {
      final client = _supabase;
      if (client == null) {
        debugPrint('Audit (guest mode): $action${details != null ? ' - $details' : ''}');
        return;
      }

      final userId = client.auth.currentUser?.id;

      String? dataHash;
      if (dataToHash != null) {
        dataHash = sha256.convert(utf8.encode(dataToHash)).toString();
      }

      await client.from('audit_logs').insert({
        'user_id': userId,
        'action': action,
        'details': details,
        'data_hash': dataHash,
      });
    } catch (e) {
      debugPrint('Audit Log Failed: $e');
      // We don't throw here to avoid blocking the main UX if audit fails
    }
  }
}
