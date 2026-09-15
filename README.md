# OpenTTD 15.3 voor Android

Dit project bouwt OpenTTD 15.3 als een native Android APK voor 64-bit ARM-tablets,
waaronder de Samsung Galaxy Tab S8. De APK draait rechtstreeks op Android en heeft
geen Winlator of Windows-emulatie nodig.

De build combineert:

- de officiële OpenTTD 15.3-broncode;
- de SDL/Android-infrastructuur van `pelya/commandergenius`;
- een kleine compatibiliteitspatch voor de moderne OpenTTD CMake-build;
- uitsluitend `arm64-v8a`, passend bij moderne Android-tablets.

## APK bouwen

Open **Actions**, kies **Build OpenTTD 15.3 Android** en start **Run workflow**.
Na een geslaagde build staat de APK bij de workflow artifacts als
`OpenTTD-15.3-Android-arm64`.

## Licentie

OpenTTD is beschikbaar onder de GNU General Public License versie 2. De Android-
buildinfrastructuur behoudt de licenties van de oorspronkelijke projecten. Dit
repository bevat alleen buildbestanden en de patch; de oorspronkelijke bronnen
worden tijdens de build uit hun publieke repositories opgehaald.
