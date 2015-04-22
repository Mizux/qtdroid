################################
##  Define Cross compilation  ##
################################
#  Usage Linux:
#   $ export JAVA_HOME=/absolute/path/to/java/home
#   $ export ANDROID_NDK_ROOT=/absolute/path/to/the/android-ndk
#   $ export ANDROID_SDK_ROOT=/absolute/path/to/the/android-sdk
#   $ mkdir build && cd build
#   $ cmake -DCMAKE_TOOLCHAIN_FILE=path/to/the/android.cmake ..
#   $ make -j8
#
#    ANDROID  will be set to true, you may test any of these
#    variables to make necessary Android-specific configuration changes.
cmake_minimum_required(VERSION 2.8)

if(DEFINED ANDROID)
 return() # subsequent toolchain loading is not really needed
endif()

set(JAVA_HOME $ENV{JAVA_HOME})
if(NOT JAVA_HOME)
    message(FATAL_ERROR "The JAVA_HOME environment variable is not set. Please set it to the root directory of the JDK.")
endif()
message(STATUS "java: ${JAVA_HOME}")

set(ANDROID_NDK_ROOT $ENV{ANDROID_NDK_ROOT})
if(NOT ANDROID_NDK_ROOT)
	message(FATAL_ERROR "The ANDROID_NDK_ROOT environment variable is not set. Please set it.")
endif()
message(STATUS "ndk: ${ANDROID_NDK_ROOT}")

set(ANDROID_SDK_ROOT $ENV{ANDROID_SDK_ROOT})
if(NOT ANDROID_SDK_ROOT)
	message(FATAL_ERROR "The ANDROID_SDK_ROOT environment variable is not set. Please set it.")
endif()
message(STATUS "sdk: ${ANDROID_SDK_ROOT}")

set(ANDROID_QT_ROOT $ENV{ANDROID_QT_ROOT})
if(NOT ANDROID_QT_ROOT)
	message(FATAL_ERROR "The ANDROID_QT_ROOT environment variable is not set. Please set it.")
endif()
message(STATUS "qt: ${ANDROID_QT_ROOT}")
FILE(GLOB children ${ANDROID_QT_ROOT}/lib/cmake/*)
FOREACH(child ${children})
	IF(IS_DIRECTORY ${child})
		LIST(APPEND CMAKE_PREFIX_PATH ${child})
	ENDIF()
ENDFOREACH()

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")

# setup the cross-compiler
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64")
set(ANDROID_TOOLCHAIN_MACHINE_NAME "arm-linux-androideabi")
set(CMAKE_ASM_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-gcc"     CACHE PATH "assembler")
set(CMAKE_C_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-gcc" CACHE PATH "C compiler")
set(CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-g++" CACHE PATH "C++ compiler")
set(CMAKE_AS_COMPILER	"${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-as" CACHE PATH "AS compiler")
set(CMAKE_STRIP   "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-strip"   CACHE PATH "strip")
set(CMAKE_AR      "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ar"      CACHE PATH "archive")
set(CMAKE_LINKER  "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ld"      CACHE PATH "linker")
set(CMAKE_NM      "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-nm"      CACHE PATH "nm")
set(CMAKE_OBJCOPY "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-objcopy" CACHE PATH "objcopy")
set(CMAKE_OBJDUMP "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-objdump" CACHE PATH "objdump")
set(CMAKE_RANLIB  "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ranlib"  CACHE PATH "ranlib")

# Force set compilers because standard identification works badly for us
include( CMakeForceCompiler)
CMAKE_FORCE_C_COMPILER( "${CMAKE_C_COMPILER}" GNU)
set(CMAKE_C_SIZEOF_DATA_PTR 4)
set(CMAKE_C_HAS_ISYSROOT 1)
set(CMAKE_C_COMPILER_ABI ELF)
CMAKE_FORCE_CXX_COMPILER( "${CMAKE_CXX_COMPILER}" GNU)
set(CMAKE_CXX_PLATFORM_ID Linux)
set(CMAKE_CXX_SIZEOF_DATA_PTR ${CMAKE_C_SIZEOF_DATA_PTR})
set(CMAKE_CXX_HAS_ISYSROOT 1)
set(CMAKE_CXX_COMPILER_ABI ELF)
set(CMAKE_CXX_SOURCE_FILE_EXTENSIONS cc cp cxx cpp CPP c++ C)
# force ASM compiler (required for CMake < 2.8.5)
set(CMAKE_ASM_COMPILER_ID_RUN TRUE)
set(CMAKE_ASM_COMPILER_ID GNU)
set(CMAKE_ASM_COMPILER_WORKS TRUE)
set(CMAKE_ASM_COMPILER_FORCED TRUE)
set(CMAKE_COMPILER_IS_GNUASM 1)
set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS s S asm)
foreach( lang C CXX ASM)
  set( CMAKE_${lang}_COMPILER_VERSION 4.9)
endforeach()

# flags and definitions
add_definitions(-DANDROID)
set(ANDROID_CXX_FLAGS "")
set(ANDROID_LINKER_FLAGS "")

# CXX_FLAGS
set(ANDROID_SYSROOT	"${ANDROID_NDK_ROOT}/platforms/android-19/arch-arm")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funwind-tables")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mthumb -fomit-frame-pointer -fno-strict-aliasing")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -finline-limit=64")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fsigned-char") # good/necessary when porting desktop libraries
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=armv7-a -mfloat-abi=softfp")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=neon")
#set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=vfpv3")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fdata-sections -ffunction-sections")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -Wa,--noexecstack")
set(CMAKE_CXX_FLAGS "-fpic ${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "-frtti ${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS "-fexceptions ${CMAKE_CXX_FLAGS}")
set(CMAKE_C_FLAGS "-fpic ${CMAKE_C_FLAGS}")
set(CMAKE_C_FLAGS "-fexceptions ${CMAKE_C_FLAGS}")

# STL
set(ANDROID_STL	"${ANDROID_NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.9")
set(ANDROID_STL_INCLUDE_DIRS
	"${ANDROID_STL}/include"
	"${ANDROID_STL}/include/backward"
	"${ANDROID_STL}/libs/armeabi-v7a/include")
include_directories(SYSTEM
	"${ANDROID_SYSROOT}/usr/include"
	"${ANDROID_STL_INCLUDE_DIRS}")
set(__libstl "${ANDROID_STL}/libs/armeabi-v7a/libgnustl_static.a")
set(__libsupcxx "${ANDROID_STL}/libs/armeabi-v7a/libsupc++.a")

# LINKER flags
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libstl}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libsupcxx}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -lm")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--fix-cortex-a8")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-allow-shlib-undefined")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--gc-sections")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-z,noexecstack")
# crt
#set(__crtbegin "${ANDROID_SYSROOT}/usr/lib/crtbegin_so.o")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__crtbegin}")

# cache flags
set( CMAKE_CXX_FLAGS           ""                        CACHE STRING "c++ flags")
set( CMAKE_CXX_FLAGS_RELEASE   "-O3 -DNDEBUG"            CACHE STRING "c++ Release flags")
set( CMAKE_CXX_FLAGS_DEBUG     "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c++ Debug flags")
set( CMAKE_C_FLAGS             ""                        CACHE STRING "c flags")
set( CMAKE_C_FLAGS_RELEASE     "-O3 -DNDEBUG"            CACHE STRING "c Release flags")
set( CMAKE_C_FLAGS_DEBUG       "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c Debug flags")
set( CMAKE_SHARED_LINKER_FLAGS ""                        CACHE STRING "shared linker flags")
set( CMAKE_MODULE_LINKER_FLAGS ""                        CACHE STRING "module linker flags")
set( CMAKE_EXE_LINKER_FLAGS    "-Wl,-z,nocopyreloc"      CACHE STRING "executable linker flags")

# finish flags
set( CMAKE_CXX_FLAGS           "${ANDROID_CXX_FLAGS} ${CMAKE_CXX_FLAGS}")
set( CMAKE_C_FLAGS             "${ANDROID_CXX_FLAGS} ${CMAKE_C_FLAGS}")
set( CMAKE_SHARED_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")
set( CMAKE_MODULE_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS}")
set( CMAKE_EXE_LINKER_FLAGS    "${ANDROID_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")

# set these global flags for cmake client scripts to change behavior
set(ANDROID True)

# where is the target environment
set(CMAKE_FIND_ROOT_PATH "${ANDROID_TOOLCHAIN_ROOT}/bin" "${ANDROID_SYSROOT}" "${CMAKE_INSTALL_PREFIX}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

# Macro to create APK using Qt SDK

