import 'dart:convert';
// import 'dart:io'; // Removed for Web compatibility
import 'package:file_picker/file_picker.dart';
import '../models/lead.dart';
import 'package:uuid/uuid.dart';

class CsvService {
  final Uuid _uuid = Uuid();

  /// Picks a CSV file and returns a list of Leads.
  Future<List<Lead>> pickAndParseCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Ensure bytes are available on all platforms
      );

      if (result != null) {
        final file = result.files.single;
        
        String csvString;
        if (file.bytes != null) {
           csvString = utf8.decode(file.bytes!);
        } else {
           // Fallback or error if no bytes (should not happen with withData: true)
           throw Exception("Could not read file data (Bytes missing).");
        }

        // Manual CSV Parsing (Robust enough for simple data)
        List<List<dynamic>> rows = [];
        List<String> lines = const LineSplitter().convert(csvString);
        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          // Split by comma, handling potential simple quotes if needed (simplified here)
          rows.add(line.split(',').map((e) => e.trim()).toList());
        }
        
        // Remove header row if it exists (basic check)
        if (rows.isNotEmpty && rows[0][0].toString().toLowerCase().contains('name')) {
          rows.removeAt(0);
        }

        List<Lead> leads = [];
        for (var row in rows) {
          // Expecting format: Name, Email, Company, Role, Phone
          if (row.length >= 4) {
            leads.add(Lead(
              id: _uuid.v4(),
              name: row[0].toString(),
              email: row[1].toString(),
              company: row[2].toString(),
              role: row[3].toString(),
              phone: row.length > 4 ? row[4].toString() : '',
            ));
          }
        }
        return leads;
      }
      return [];
    } catch (e) {
      print("Error parsing CSV: $e");
      return [];
    }
  }
}
