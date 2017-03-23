mkdir build
cd build


if [ $(uname) == Linux ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
    export CCACHE_DIR=/feedstock_root/build_artefacts/.ccache
    # Set max cache size so we don't carry old objects for too long
    ccache -M 400M
else
    export CC="ccache clang"
    export CXX="ccache clang++"
    # Set max cache size so we don't carry old objects for too long
    ccache -M 200M
fi
export CCACHE_BASEDIR="${SRC_DIR}"
ccache -z

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_TARGETS_TO_BUILD=host \
      -DLLVM_ENABLE_RTTI=ON \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_UTILS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_ENABLE_TERMINFO=OFF \
      ..

echo '################'
echo $CC
echo $CXX
ccache -s
echo '################'

if [ $(uname) == Linux ]; then
    # CircleCI builds all packages on the same build and has a much larger
    # timeout
    TIMEOUT=5400
else
    TIMEOUT=2220
fi
bash -c "#!/bin/sh
sleep $TIMEOUT
ccache -s
killall ccache
"&
KILLER_PID=$!
make -j${CPU_COUNT}
make install
kill $KILLER_PID || echo "Script already exited"
ccache -s
