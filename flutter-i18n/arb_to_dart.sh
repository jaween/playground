#!/usr/bin/env bash
pub run intl_translation:generate_from_arb --output-dir=lib/l10n/localizations \
  --no-use-deferred-loading lib/l10n/my_app_localizations.dart \
  assets/l10n/*.arb
