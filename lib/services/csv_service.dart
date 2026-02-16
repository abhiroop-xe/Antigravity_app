import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/lead.dart';
import 'package:uuid/uuid.dart';

class CsvService {
  static const _uuid = Uuid();

  /// Picks a CSV file and returns a list of Leads.
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<List<Lead>> pickAndParseCsv() async {
    // Use FileType.any to avoid known MIME filtering bugs on web/Linux
    // that prevent CSV files from being selectable with FileType.custom.
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
    } catch (e) {
      debugPrint('FilePicker error: $e');
      throw Exception('Could not open file picker: $e');
    }

    // User cancelled the picker
    if (result == null || result.files.isEmpty) {
      return [];
    }

    final file = result.files.first;
    debugPrint('CSV Picker: Selected "${file.name}" with ${file.size} bytes.');

    // Validate it's actually a CSV file
    if (!file.name.toLowerCase().endsWith('.csv')) {
      throw Exception(
          'Please select a CSV file. Selected file: "${file.name}"');
    }

    if (file.bytes == null || file.bytes!.isEmpty) {
      debugPrint('CSV Picker: file.bytes is null or empty');
      throw Exception('Could not read file data or file is empty.');
    }

    String csvString;
    try {
      // Handle potential UTF-8 decoding issues
      csvString = utf8.decode(file.bytes!).trim();
    } catch (e) {
      debugPrint('UTF-8 Decode Error: $e. Falling back to latin1.');
      csvString = latin1.decode(file.bytes!).trim();
    }

    if (csvString.isEmpty) {
      throw Exception('The selected CSV file has no text content.');
    }

    const converter = CsvToListConverter(
      shouldParseNumbers: false,
      allowInvalid: true,
    );
    final List<List<dynamic>> rows = converter.convert(csvString);

    if (rows.isEmpty) {
      throw Exception('No valid CSV rows parsed from the file.');
    }

    // Identify header indices (case-insensitive)
    final headers = rows[0].map((e) => e.toString().toLowerCase()).toList();
    int nameIdx = headers.indexOf('name');
    int emailIdx = headers.indexOf('email');
    int companyIdx = headers.indexOf('company');
    int roleIdx = headers.indexOf('role');
    int phoneIdx = headers.indexOf('phone');

    // Fallback to indices if headers not named exactly
    if (nameIdx == -1) nameIdx = 0;
    if (emailIdx == -1 && headers.length > 1) emailIdx = 1;
    if (companyIdx == -1 && headers.length > 2) companyIdx = 2;
    if (roleIdx == -1 && headers.length > 3) roleIdx = 3;
    if (phoneIdx == -1 && headers.length > 4) phoneIdx = 4;

    List<Lead> leads = [];
    // Skip header row if it looks like headers
    final startIdx =
        (headers.contains('name') || headers.contains('email')) ? 1 : 0;

    for (int i = startIdx; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 2) continue; // Skip empty/invalid rows

      leads.add(Lead(
        id: _uuid.v4(),
        userId: '',
        name: _getValue(row, nameIdx),
        email: _getValue(row, emailIdx),
        company: _getValue(row, companyIdx),
        role: _getValue(row, roleIdx),
        phone: _getValue(row, phoneIdx),
      ));
    }

    if (leads.isEmpty) {
      throw Exception('No valid leads found in the CSV file.');
    }

    return leads;
  }

  String _getValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length) {
      return row[index]?.toString() ?? '';
    }
    return '';
  }
}
