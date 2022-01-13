$ErrorActionPreference = 'Stop'

$VERSION = type VERSION
$VERSION = $VERSION -replace '\.','-'

$IMAGE = "bitnami/minideb:latest

$QEMU_ARCH = $env:ARCH -replace 'arn32.*','arm' -replace 'arm64.*','aarch64' -replace 'amd64','x86_64'

$DATE = ([datetime]::now).toString("yyyy-MM-ddTHH:mm:ssZ")

$VCS_REF = git rev-parse --short HEAD
$VCS_URL = git config --get remote.origin.url

Write-Host Starting build

Write-Host Building Picapport v$VERSION at $DATE

Write-Host Excecute docker version

docker version

if($isWindows) {
  Write-Host This is a windows build
  docker build -t picapport --build-arg BUILD_DATE=$DATE --build-arg VERSION=$VERSION --build-arg VCS_REF=$VCS_REF --build_arg VCS_URL=$VCS_URL -f Dockerfile.windows .
} else {
  Write-Host This is a linux build
  docker run --rm --privileged "multiarch/qemu-user-static:register" --reset
  docker build -t picapport --build-arg IMAGE="$env:ARCH/$IMAGE" --build-arg QEMU=$QEMU_ARCH --build-arg BUILD_DATE=$DATE --build-arg VERSION=$VERSION --build-arg "ARCH=$env:ARCH" --build-arg VCS_REF==$VCS_REF --build-arg VCS_URL=$VCS_URL -f Dockerfile .
}

Write-Host Execute docker images to list all images
docker images

Write-Host Execute docker inspect picapport
docker inspect picapport
