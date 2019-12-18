if [ -d ../llvm/src -a "$pkgname" != "llvm" ]; then
	error "../llvm/src exists, remove before building."
fi

case $CARCH in
        aarch64) _targets="AArch64";;
        x86_64) _targets="all";;
        mips64) _targets="Mips";;
        riscv64) _targets="RISCV";;
        ppc64le) _targets="PowerPC";;
        *) echo "Unknown arch" ; return 1;;
esac
