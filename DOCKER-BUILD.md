# Building new versions of this image

Follow these steps to build new version of this image.

1. Check `PHP` Version in Dockerfile
The Environment variable needs to be set to the latest php major version, currenntly this is `7.3`

2. Make your changes
Apply your changes or fix bugs. Try to build a local version:

`docker build -t scalecommerce-dev-php:local .`

Check Modules with: `docker run --rm scalecommerce-dev-php:local php -m`

If everything works increase version number `echo $(( $(cat version) + 1 )) > version` commit and push to `master`.This will trigger a new `latest` tag build on Docker Hub.

3. Build Imgaes for each php major version
Iterate through all php major versions and trigger a build on Docker Hub. You can use this helper script: `build-php-versions.sh`
