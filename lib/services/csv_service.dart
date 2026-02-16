import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/lead.dart';
import 'package:uuid/uuid.dart';

class CsvService {
  static const _uuid = Uuid();

  /// Picks a CSV file and returns a list of Leads.
  Future<List<Lead>> pickAndParseCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return [];

        final csvString = utf8.decode(file.bytes!).trim();
        const converter = CsvToListConverter();
        final List<List<dynamic>> rows = converter.convert(csvString);

        if (rows.isEmpty) return [];

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
        return leads;
      }
      return [];
    } catch (e) {
      // print("CSV Service Error: $e");
      return [];
    }
  }

  String _getValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length) {
      return row[index]?.toString() ?? '';
    }
    return '';
  }
}
