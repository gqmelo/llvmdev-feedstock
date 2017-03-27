mkdir build
cd build

set CC=clcache
set CXX=clcache
clcache -M 1000000000
set "CLCACHE_BASEDIR=%SRC_DIR%
set CLCACHE_NODIRECT=1
clcache -z

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_UTILS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    -DLLVM_ENABLE_RTTI=ON ^
    -DLLVM_INCLUDE_EXAMPLES=OFF ^
    %SRC_DIR%

if errorlevel 1 exit 1

echo "################"
echo %CC%
echo %CXX%
clcache -s
echo "################"

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1

clcache -s

ninja install
if errorlevel 1 exit 1
