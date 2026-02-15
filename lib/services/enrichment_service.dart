import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pii_scrubber.dart';
import 'token_service.dart';

class EnrichmentService {
  final PiiScrubber _piiScrubber = PiiScrubber();
  final TokenService _tokenService = TokenService();
  String? _apiKey;

  EnrichmentService() {
    _apiKey = dotenv.env['MISTRAL_API_KEY'];
  }

  /// Enriches a lead by generating a summary of the company using Mistral AI.
  Future<String> enrichLead(String companyName, String role) async {
    // 1. Check Token Limit
    _tokenService.checkLimit();

    // 2. Prepare Context (Scrub PII)
    final safeCompany = _piiScrubber.scrub(companyName);
    final safeRole = _piiScrubber.scrub(role);

    // 3. Construct Prompt
    final prompt = 'Research the company "$safeCompany" and the role "$safeRole". '
        'Provide a 3-bullet summary of recent news and how this role might be relevant. '
        'Do NOT include any private info.';

    try {
      if (_apiKey != null && _apiKey!.isNotEmpty && !_apiKey!.startsWith('your-')) {
        final uri = Uri.parse('https://api.mistral.ai/v1/chat/completions');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            "model": "mistral-tiny", // Using the fastest/cheapest model
            "messages": [
              {"role": "user", "content": prompt}
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'] as String;
          _tokenService.incrementUsage();
          return content;
        } else {
          // If API fails, fallback to mock but log error
          print('Mistral API Error: ${response.statusCode} - ${response.body}');
          throw Exception('Mistral API Error: ${response.statusCode}');
        }
      } else {
        // Mock response if API key is missing
        await Future.delayed(const Duration(seconds: 1)); 
        return "Mock Mistral Enrichment for $safeCompany:\n"
            "- [Mock] Recently raised significant capital locally.\n"
            "- [Mock] Expanding $safeRole department.\n"
            "- [Mock] Strong market presence in privacy sector.";
      }
    } catch (e) {
      print('Enrichment Failed: $e');
      throw Exception('Enrichment Failed: $e');
    }
  }
}
