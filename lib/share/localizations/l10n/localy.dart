import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    as app_localization;

// ignore:avoid_classes_with_only_static_members
class Localy {
  static app_localization.Localy? of(BuildContext context) {
    return Localizations.of<app_localization.Localy>(
        context, app_localization.Localy);
  }
}
