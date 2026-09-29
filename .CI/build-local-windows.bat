@echo off
rem Local Windows build replicating CI (build.yml) minus crashpad/LTO
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set PATH=%PATH%;C:\Users\moham\AppData\Roaming\Python\Python314\Scripts
cd /d D:\YChatterino\ychatterino
if not exist build mkdir build
cd build

if not exist conanbuildinfo_ok (
    conan install .. -s build_type=RelWithDebInfo -c tools.cmake.cmaketoolchain:generator="Ninja" -b missing --output-folder=. -o with_openssl3=True || exit /b 2
    echo ok> conanbuildinfo_ok
)

if not exist CMakeCache.txt (
    cmake -G Ninja ^
        -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
        -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake ^
        -DCMAKE_PREFIX_PATH=D:/Qt/6.10.2/msvc2022_64 ^
        -DUSE_PRECOMPILED_HEADERS=ON ^
        -DBUILD_WITH_CRASHPAD=OFF ^
        -DCHATTERINO_LTO=OFF ^
        -DCHATTERINO_FORCE_LTO=OFF ^
        -DCHATTERINO_SPELLCHECK=On ^
        .. || exit /b 3
)

ninja || exit /b 4
echo BUILD_SUCCESS
