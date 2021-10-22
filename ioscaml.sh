#!/bin/sh -e

IOSCAMLVER=4.07.1

ioscaml_create_switches() {
  opam switch -y create ${IOSCAMLVER}+ios+arm64 ${IOSCAMLVER}
  opam switch -y create ${IOSCAMLVER}+ios+amd64 ${IOSCAMLVER}
}

ioscaml_foreach() {
  for i in ${IOSCAMLVER}+ios+arm64 ${IOSCAMLVER}+ios+amd64; do
    opam switch -y --no-warning $i
    eval $(opam config env --switch=$i)
    if ! OPAMYES=1 $*; then return 1; fi
  done
}

ioscaml_configure() {
  if [ -z "${SDK}" -o -z "${VER}" ]; then
    echo "Usage: SDK=14.5 VER=12.0 ioscaml_configure" >&2
    echo "  SDK specifies the installed iOS SDK version." >&2
    echo "  VER specifies the -miphoneos-version-min value." >&2
    return 1
  fi
  case $(opam switch show) in
  ${IOSCAMLVER}+ios+arm64)
    ARCH=arm64 SUBARCH=arm64 PLATFORM=iPhoneOS \
      opam reinstall -y conf-ios
    ;;
  ${IOSCAMLVER}+ios+amd64)
    ARCH=amd64 SUBARCH=x86_64 PLATFORM=iPhoneSimulator \
      opam reinstall -y conf-ios
    ;;
  esac
}

ioscaml_ocamlbuild() {
  ocamlbuild -build-dir $(opam config var conf-ios:arch) $*
}
