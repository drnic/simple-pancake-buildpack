#!/bin/bash

mkdir -p $CACHE_DIR/bin
export PATH=$CACHE_DIR/bin:$PATH

function install_yj() {
  package_name=yj
  mkdir -p $CACHE_DIR/$package_name
  cd $CACHE_DIR/$package_name
  yj_uri=https://github.com/sclevine/yj/releases/download/v4.0.0/yj-linux
  yj_sha256=0019875f3f0aa1ea14a0969ce8557789e95fe0307fa1d25ef29ed70ad9874438
  if [[ -d $BUILDPACK_DIR/dependencies ]]; then
    echo "Using [$(ls $BUILDPACK_DIR/dependencies/*/yj-linux)]"
    cp $BUILDPACK_DIR/dependencies/*/yj-linux $CACHE_DIR/$package_name/
  else
    echo "Downloading [$yj_uri]"
    curl -sSLO $yj_uri
  fi
  echo "$yj_sha256  yj-linux" | sha256sum -c
  mv yj-linux $CACHE_DIR/bin/yj
  chmod +x $CACHE_DIR/bin/yj
}

function fetch_dependency() {
  PACKAGE_NAME=$1

  mkdir -p $CACHE_DIR/$PACKAGE_NAME
  default_version=$(cat $BUILDPACK_DIR/manifest.yml | yj -y | jq -r --arg name $PACKAGE_NAME '.default_versions[] | select(.name == $name ).version')
  download_uri=$(cat    $BUILDPACK_DIR/manifest.yml | yj -y | jq -r --arg name $PACKAGE_NAME --arg version $default_version '.dependencies[] | select(.name == $name and .version == $version).uri')
  download_sha256=$(cat $BUILDPACK_DIR/manifest.yml | yj -y | jq -r --arg name $PACKAGE_NAME --arg version $default_version '.dependencies[] | select(.name == $name and .version == $version).sha256')
  filename=$(basename $download_uri)

  cd $CACHE_DIR/$PACKAGE_NAME/
  if [[ -d $BUILDPACK_DIR/dependencies ]]; then
    echo "Using [$(ls $BUILDPACK_DIR/dependencies/*/$filename)]"
    cp $BUILDPACK_DIR/dependencies/*/$filename .
  else
    echo "Downloading [$download_uri]"
    curl -sSLO $download_uri
  fi
  package=$(ls *)
  echo "$download_sha256  $package" | sha256sum -c
}

install_yj
