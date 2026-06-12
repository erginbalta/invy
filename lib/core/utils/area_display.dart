import '../../features/areas/repositories/area_repository.dart';
import '../../l10n/app_localizations.dart';

String displayAreaName(String name, AppLocalizations l10n) {
  return name == AreaRepository.generalAreaName ? l10n.generalArea : name;
}
