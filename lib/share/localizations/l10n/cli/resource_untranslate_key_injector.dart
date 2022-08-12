import 'package:diamon_rose_app/share/localizations/l10n/cli/commons.dart';
import 'package:diamon_rose_app/share/localizations/l10n/cli/environment.dart';

String getPathOfAppLanguageArb(String languageCode) =>
    '$baseDir/generated/translate_resources/app_$languageCode.arb';

Future<void> main() async {
  final targetKeys = await getTargetTranslateKeys();

  await Future.forEach(targetKeys, injection);
}

/// Returns a list of languages with untranslated keys
Future<List<String>> getTargetTranslateKeys() async {
  final untranslatedKeysInfo = await importFile(pathOfUntranslatedKeysInfo);
  return untranslatedKeysInfo.keys.toList();
}

/// languageCode: ja, en, zh ..
Future<void> injection(String languageCode) async {
  final templateResource = await importFile(pathOfIntlMessagesArb);
  final untranslatedKeysInfo = await importFile(pathOfUntranslatedKeysInfo);
  final resource = await importFile(getPathOfAppLanguageArb(languageCode));
  final untranslatedKeys =
      // ignore: avoid_dynamic_calls
      untranslatedKeysInfo[languageCode].cast<String>() as List<String>;

  await Future.forEach<String>(untranslatedKeys, (key) async {
    resource.addAll(<String, dynamic>{
      key: '$untranslatedFlagKeyword${templateResource[key]}'
    });
  });

  await updateFile(getPathOfAppLanguageArb(languageCode), resource);
}
