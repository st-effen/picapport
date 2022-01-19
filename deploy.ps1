$ErrorActionPreference = 'Stop';

if (! (Test-Path Env:\APPVEYOR_REPO_TAG_NAME)) {
  Write-Host "No version tag detected. Skip publishing."
  exit 0
}

$image = $env:REPO

Write-Host Starting deploy

#Enable experimental functions in docker cli for docker manifest command
if (!(Test-Path ~/.docker)) { mkdir ~/.docker }
'{ "experimental": "enabled" }' | Out-File ~/.docker/config.json -Encoding Ascii

docker login -u="$env:DOCKER_USER" -p="$env:DOCKER_PASS"

$os = If ($isWindows) {"windows"} Else {"linux"}
docker tag picapport "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

if ($isWindows) {
# TODO: Currently no rebasing
  # windows
#  $ErrorActionPreference = 'SilentlyContinue';
#  npm install -g rebase-docker-image
#  $ErrorActionPreference = 'Stop';
#
#  Write-Host "Rebasing image to produce 2016/1607 variant"
#  rebase-docker-image `
#   "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
#   -s stefanscherer/nanoserver:1809 `
#   -t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1607" `
#   -b stefanscherer/nanoserver:sac2016
#
#  Write-Host "Rebasing image to produce 1709 variant"
#  rebase-docker-image `
#   "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
#   -s stefanscherer/nanoserver:1809 `
#   -t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1709" `
#   -b stefanscherer/nanoserver:1709
#
#  Write-Host "Rebasing image to produce 1803 variant"
#  rebase-docker-image `
#   "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
#   -s stefanscherer/nanoserver:1809 `
#   -t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1803" `
#   -b stefanscherer/nanoserver:1803
#
#  Write-Host "Rebasing image to produce 1903 variant"
#  rebase-docker-image `
#   "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
#   -s stefanscherer/nanoserver:1809 `
#   -t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1903" `
#   -b stefanscherer/nanoserver:1903

} else {
  # Linux
  # currently no multiarch build
  #if ($env:ARCH -eq "arm64v8") {
	  if ($nev:ARCH -eq "amd64") {
    # The last in the build matrix
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      #"$($image):linux-arm64v8-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME"

    #docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm64v8-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
	docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch amd64
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"

    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      #"$($image):linux-arm64v8-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME"

    #docker manifest annotate "$($image):latest" "$($image):linux-arm64v8-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
	docker manifest annotate "$($image):latest" "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch amd64
    docker manifest push "$($image):latest"

  }
}

docker logout
