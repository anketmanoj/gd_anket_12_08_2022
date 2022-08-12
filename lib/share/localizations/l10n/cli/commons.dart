import 'dart:convert';
import 'dart:io' show File;

Future<Map<String, dynamic>> importFile(String path) async {
  final jsonString = await File(path).readAsString();
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  return decoded;
}

Future<void> updateFile(String path, Map<String, dynamic> updatedData) async {
  const encoder = JsonEncoder.withIndent('  ');

  final writingJson = encoder.convert(updatedData);
  await File(path).writeAsString(writingJson);
}
