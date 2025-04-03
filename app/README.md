# Flutter app

See the README one level op for a short intro.

<!--
pubspec.yaml


* `README.md`: This readme
* `build_prod.sh`: Script for building the production version of the web app
* `build_test.sh`: Script for building the test version of the web app
* `pubspec.yaml`:
-->

[Flutter online documentation](https://docs.flutter.dev/)

## CloudFront config

The app has been uploaded to a bucket named `taekwondo-test`.
See [../lambda/README.md](../lambda/README.md) for more information on setting it up.

Whenever a new version of the app is uploaded remember to run a cache invalidation on CloudFront with `/*` as path.
