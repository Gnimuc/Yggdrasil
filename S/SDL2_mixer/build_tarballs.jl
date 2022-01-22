# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "SDL2_mixer"
version = v"2.0.4"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/libsdl-org/SDL_mixer.git", "da75a58c19de9fedea62724a5f7770cbbe39adf9"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/SDL*/
export CPPFLAGS="-I${prefix}/include"
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} --with-pic
make -j${nproc}
make install
if [[ "${target}" == *-freebsd* ]]; then
    # We need to manually build the shared library for FreeBSD
    cd "${libdir}"
    ar x libSDL2_mixer.a
    cc -shared -o libSDL2_mixer.${dlext} *.o
fi
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()


# The products that we will ensure are always built
products = [
    LibraryProduct(["libSDL2_mixer", "SDL2_mixer"], :libsdl2_mixer)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    PackageSpec(name="SDL2_jll", uuid="ab825dc5-c88e-5901-9575-1e5e20358fcf")
    PackageSpec(name="libvorbis_jll", uuid="f27f6e37-5d2b-51aa-960f-b287f2bc3b7a")
    PackageSpec(name="FLAC_jll", uuid="1d38b3a6-207b-531b-80e8-c83f48dafa73")
    PackageSpec(name="mpg123_jll", uuid="3205ef68-7822-558b-ad0d-1b4740f12437")
]

# Build the tarballs.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
