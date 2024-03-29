#!/bin/sh
. /usr/share/abuild/functions.sh

usage() {
	echo "Usage:"
	echo "$0 [show|<compiler> <binutils>]"
	echo
	echo "Possible values:"
    echo " - compiler: llvm, gnu, none"
    echo " - binutils: llvm, gnu, elftoolchain, none"
	exit 1
}

if [ x"$1" = x"show" ]; then
	clink=$(basename $(readlink -qn /usr/bin/gcc) 2>/dev/null|| echo none)
	blink=$(basename $(readlink -qn /usr/bin/ld) 2>/dev/null|| echo none)

	case $clink in
		clang) compiler=llvm;;
		gnu-gcc) compiler=gnu;;
		none) compiler=$clink;;
		*) compiler=unknown;;
	esac

	case $blink in
		lld|ld.lld) binutils=llvm;;
		gnu-ld) binutils=gnu;;
        elftoolchain-ld) binutils=elftoolchain;;
		none) binutils=$blink;;
		*) binutils=unknown;;
	esac

	echo $compiler $binutils
	exit 0
fi

if [ x"$1" = "x" -o x"$2" = "x" ]; then
        usage
fi

if [ $UID -gt 0 ]; then
	echo "You might want to try this again as uid 0."
	exit 1
fi

# some things
compiler_links="gcc g++ c++ cpp"
binutils_links="ar nm objcopy objdump ranlib readelf size strings strip addr2line"
gnu_extra="mt readobj split"
llvm_extra="mt readobj split"
elftoolchain_extra="brandelf findtextrel"

cleanup() {
	for link in $compiler_links $binutils_links $gnu_extra $llvm_extra $elftoolchain_extra ld as cc ld.bfd ld.gold; do
		rm -f /usr/bin/${link} /usr/bin/${CTARGET}-${link} /usr/bin/*-abyss-linux-${link}
	done
}

case $1 in
	llvm|gnu|none) compiler=${1};;
	*) usage;;
esac

case $2 in
	llvm|gnu|elftoolchain|none) binutils=${2};;
	*) usage;;
esac

echo "Configuring $CTARGET for ${compiler}/${binutils}..."
cleanup

if [ "$binutils" != "none" ]; then
	echo "linking binutils..."
    # setup binutils
	for link in $binutils_links; do
		ln -fvs /usr/bin/${binutils}-${link} /usr/bin/${link}
	done
    case $binutils in
        llvm)
            for link in $llvm_extra; do
                ln -fvs /usr/bin/${binutils}-${link} /usr/bin/${link}
            done
            ln -fvs ld.lld /usr/bin/ld && ln -fsv clang /usr/bin/as && ln -fsv gnu-ld.bfd /usr/bin/ld.bfd && ln -fsv gnu-ld.gold /usr/bin/ld.gold;;
        gnu)
            for link in $gnu_extra; do
                ln -fvs /usr/bin/${binutils}-${link} /usr/bin/${link}
            done
            ln -fsv $binutils-ld /usr/bin/ld && ln -fsv $binutils-as /usr/bin/as && ln -fsv $binutils-ld.bfd /usr/bin/ld.bfd && ln -fsv $binutils-ld.gold /usr/bin/ld.gold;;
        elftoolchain)
            for link in $elftoolchain_extra; do
                ln -fvs /usr/bin/${binutils}-${link} /usr/bin/${link}
            done
            ln -fsv $binutils-ld /usr/bin/ld;;
    esac
fi

if [ "$compiler" != "none" ]; then
	echo "linking compiler..."
	# setup compiler
	case $compiler in
		llvm)
			for link in $compiler_links; do
				ln -fvs /usr/bin/clang /usr/bin/${link}
			done
			ln -fvs /usr/bin/clang-cpp /usr/bin/cpp
            ln -fvs /usr/bin/clang /usr/bin/cc;;
		gnu)
			for link in $compiler_links $gnu_extra; do
				ln -fvs /usr/bin/gnu-${link} /usr/bin/${link}
			done
			ln -fvs /usr/bin/gnu-cpp /usr/bin/cpp
            ln -fvs /usr/bin/gnu-gcc /usr/bin/cc;;
	esac
fi
