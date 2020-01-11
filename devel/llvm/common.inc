pkgver=9.0.1
pkgrel=1
pkgdesc="$pkgname"
arch="all"
url=.
license=.

if [ -d ../llvm/src -a "$pkgname" != "llvm" ]; then
	error "../llvm/src exists, remove before building."
	exit 1
fi

case $CARCH in
        aarch64) _targets="AArch64" _linker="lld" ;;
        x86_64) _targets="X86" _linker="lld" ;;
        mips64) _targets="Mips" _linker="gnu-ld" ;;
        riscv64) _targets="RISCV" _linker="gnu-ld" ;;
        ppc64le) _targets="PowerPC" _linker="gnu-ld" ;;
        *) echo "Unknown arch" ; return 1 ;;
esac
