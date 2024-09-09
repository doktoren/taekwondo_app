# Flutter app

See the README one level op for a short intro.

[Flutter online documentation](https://docs.flutter.dev/)

## CloudFront config

The app has been uploaded to a bucket named `taekwondo-test`.
See [../lambda/README.md](../lambda/README.md) for more information on setting it up.

Whenever a new version of the app is uploaded remember to run a cache invalidation on CloudFront with `/*` as path.
