pkg_name="oksh"
pkg_origin="ryanwoodsmall"
pkg_version="7.6"
pkg_license=("BSD")
pkg_maintainer="ryanwoodsmall <rwoodsmall@gmail.com>"
pkg_description="Portable OpenBSD ksh, based on the Public Domain Korn Shell (pdksh)."
pkg_upstream_url="https://github.com/ibara/oksh"
pkg_dirname="${pkg_name}-${pkg_version}"
pkg_filename="${pkg_dirname}.tar.gz"
pkg_source="https://github.com/ibara/oksh/releases/download/${pkg_dirname}/${pkg_filename}"
pkg_shasum="26b45fc3dcaab786db6b87dcd741ac572a7ef539dbb88ea22c43ed8b54405c74"
pkg_build_deps=("core/gcc" "core/musl" "core/file" "core/busybox-static" "core/make")
pkg_bin_dirs=("bin")

DO_CHECK=1

do_build() {
  cd "${SRC_PATH}" || exit 1
  local CFLAGS="-Os -g0 -Wl,-s -Wl,-static"
  ./configure \
    --prefix="${pkg_prefix}" \
    --bindir="${pkg_prefix}/bin" \
    --mandir="${pkg_prefix}/share/man" \
    --cc="$(pkg_path_for core/musl)/bin/musl-gcc"\
    --cflags="${CFLAGS}" \
    --disable-curses \
    --enable-static
  make LDFLAGS='-s -static' CPPFLAGS=
}

do_install() {
  cd "${SRC_PATH}" || exit 1
  make install
  ln -sf oksh "${pkg_prefix}/bin/ksh"
}

do_check() {
  cd "${SRC_PATH}" || exit 1
  build_line "checking that oksh is static"
  file oksh | grep 'ELF.*static'
  build_line "checking that oksh can run something"
  build_line "set internal..."
  env -i ./oksh -c set
  build_line "KSH environment vars..."
  env -i PATH=$(pkg_path_for core/busybox-static)/bin ./oksh -c 'echo ${KSH_VERSION} ; echo ${OKSH_VERSION}' > habtest.out
  grep KSH habtest.out
  grep oksh habtest.out
  build_line "env from busybox..."
  env -i PATH=$(pkg_path_for core/busybox-static)/bin ./oksh -c env
}
