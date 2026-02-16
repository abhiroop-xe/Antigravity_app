import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pii_scrubber.dart';
import 'token_service.dart';
import 'audit_service.dart';

class EnrichmentService {
  final PiiScrubber _piiScrubber = PiiScrubber();
  final TokenService _tokenService = TokenService();
  final AuditService _auditService = AuditService();
  String? _mistralKey;
  String? _geminiKey;
  String? _openAIKey;

  // Dynamic toggle for token saving
  bool _forceMock = true;

  EnrichmentService() {
    _mistralKey = dotenv.env['MISTRAL_API_KEY'];
    _geminiKey = dotenv.env['GEMINI_API_KEY'];
    _openAIKey = dotenv.env['OPENAI_API_KEY'];
  }

  bool get isMockMode => _forceMock;
  void setMockMode(bool value) => _forceMock = value;

  /// Enriches a lead using either Mistral or Gemini AI.
  Future<String> enrichLead(String company, String role) async {
    // 1. Log for audit
    await _auditService.logAction(
      action: 'Enrichment Started',
      details: 'Company: $company, Role: $role',
      dataToHash: '$company|$role',
    );

    // 2. Scrub PII
    final scrubbedCompany = _piiScrubber.scrub(company);
    final scrubbedRole = _piiScrubber.scrub(role);

    // 3. Force mock if enabled to save tokens
    if (_forceMock) {
      await Future.delayed(const Duration(seconds: 1));
      final result =
          'Enriched data for $scrubbedRole at $scrubbedCompany (Mock AI Summary - Token Saving Mode)';
      await _auditService.logAction(action: 'Enrichment Completed (Mock)');
      return result;
    }

    // 4. Prioritize OpenAI if available (User request), then Mistral, then Gemini
    if (_openAIKey != null && _openAIKey!.isNotEmpty) {
      return await _enrichWithOpenAI(scrubbedCompany, scrubbedRole);
    } else if (_mistralKey != null &&
        _mistralKey != 'your-mistral-api-key' &&
        _mistralKey!.isNotEmpty) {
      return await _enrichWithMistral(scrubbedCompany, scrubbedRole);
    } else if (_geminiKey != null && _geminiKey!.isNotEmpty) {
      return await _enrichWithGemini(scrubbedCompany, scrubbedRole);
    } else {
      // Mock fallback if no keys are available
      await Future.delayed(const Duration(seconds: 2));
      final result =
          'Enriched data for $scrubbedRole at $scrubbedCompany (Mock AI Summary)';
      await _auditService.logAction(action: 'Enrichment Completed (Mock)');
      return result;
    }
  }

  Future<String> _enrichWithOpenAI(String company, String role) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // Premium model
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a business research assistant. Provide concise, professional summaries.'
            },
            {
              'role': 'user',
              'content':
                  'Provide a 2-sentence summary for $role at $company. Focus on responsibilities and company impact.'
            }
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'];
        await _auditService.logAction(action: 'Enrichment Success (OpenAI)');
        _tokenService.incrementUsage();
        return result;
      } else {
        throw Exception(
            'OpenAI Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('OpenAI failed, trying Mistral if available: $e');
      if (_mistralKey != null && _mistralKey!.isNotEmpty) {
        return await _enrichWithMistral(company, role);
      }
      rethrow;
    }
  }

  Future<String> _enrichWithMistral(String company, String role) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.mistral.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_mistralKey',
        },
        body: jsonEncode({
          'model': 'mistral-tiny',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a business research assistant.'
            },
            {
              'role': 'user',
              'content': 'Provide a 2-sentence summary for $role at $company.'
            }
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'];
        await _auditService.logAction(action: 'Enrichment Success (Mistral)');
        _tokenService.incrementUsage();
        return result;
      } else {
        throw Exception('Mistral Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Mistral failed, trying Gemini if available: $e');
      if (_geminiKey != null && _geminiKey!.isNotEmpty) {
        return await _enrichWithGemini(company, role);
      }
      rethrow;
    }
  }

  Future<String> _enrichWithGemini(String company, String role) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Provide a concise 2-sentence business summary for the role of $role at the company $company. Focus on market position and responsibilities.'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['candidates'][0]['content']['parts'][0]['text'];
        await _auditService.logAction(action: 'Enrichment Success (Gemini)');
        _tokenService.incrementUsage();
        return result;
      } else {
        throw Exception(
            'Gemini Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      await _auditService.logAction(action: 'Enrichment Failed', details: '$e');
      rethrow;
    }
  }
}
