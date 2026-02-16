// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || key == null) {
      print('Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env');
      exit(1);
    }

    print('Connecting to $url...');
    await Supabase.initialize(url: url, anonKey: key);
    final supabase = Supabase.instance.client;

    final response = await supabase.from('leads').select().limit(1);
    print('Connection successful! Fetched ${response.length} leads.');
    exit(0);
  } catch (e) {
    print('Connection failed: $e');
    exit(1);
  }
}
