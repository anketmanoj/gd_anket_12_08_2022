#bin/bash
set -x
BASE_DIR="lib/share/localizations/l10n"
GENERATED_DIR="$BASE_DIR/generated"
flutter clean

flutter pub get

flutter pub run intl_generator:extract_to_arb --output-dir=lib/share/localizations/l10n/generated lib/share/localizations/l10n/strings.dart

flutter pub get ./bin

dart --packages=.dart_tool/package_config.json package:diamon_rose_app/share/localizations/l10n/cli/untranslated_keys_clean.dart

flutter pub run -C ./bin intl_translation:extract_to_arb --output-dir=$GENERATED_DIR $BASE_DIR/strings.dart

cp $GENERATED_DIR/intl_messages.arb $GENERATED_DIR/translate_resources/app_ja.arb

flutter pub get

dart --packages=.dart_tool/package_config.json package:diamon_rose_app/share/localizations/l10n/cli/resource_untranslate_key_injector.dart
