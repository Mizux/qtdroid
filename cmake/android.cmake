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

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug CACHE STRING "supported: Debug Release" FORCE)
endif()
message(STATUS "build type: ${CMAKE_BUILD_TYPE}")

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

file(GLOB tools RELATIVE ${ANDROID_SDK_ROOT}/build-tools ${ANDROID_SDK_ROOT}/build-tools/*)
list(SORT tools)
list(REVERSE tools)
list(GET tools 0 ANDROID_BUILD_TOOL)
message(STATUS "build-tool: ${ANDROID_BUILD_TOOL}")

set(ANDROID_API 19)
message(STATUS "api: ${ANDROID_API}")

set(ANDROID_QT_ROOT $ENV{ANDROID_QT_ROOT})
if(NOT ANDROID_QT_ROOT)
	message(FATAL_ERROR "The ANDROID_QT_ROOT environment variable is not set. Please set it.")
endif()
message(STATUS "qt: ${ANDROID_QT_ROOT}")
file(GLOB children ${ANDROID_QT_ROOT}/lib/cmake/*)
foreach(child ${children})
	if(IS_DIRECTORY ${child})
		list(APPEND CMAKE_PREFIX_PATH ${child})
	endif()
endforeach()

set(ANDROID_TOOLCHAIN_MACHINE_NAME "arm-linux-androideabi")
message(STATUS "toolchain prefix: ${ANDROID_TOOLCHAIN_MACHINE_NAME}")

set(gnu-libstdc++ "${ANDROID_NDK_ROOT}/sources/cxx-stl/gnu-libstdc++")
file(GLOB version RELATIVE ${gnu-libstdc++}	${gnu-libstdc++}/4.*)
list(SORT version)
list(REVERSE version)
list(GET version 0 ANDROID_COMPILER_VERSION)
message(STATUS "compiler: ${ANDROID_COMPILER_VERSION}")

set(ANDROID_TOOLCHAIN_NAME ${ANDROID_TOOLCHAIN_MACHINE_NAME}-${ANDROID_COMPILER_VERSION})
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_TOOLCHAIN_NAME}/prebuilt")

file(GLOB ANDROID_NDK_HOST RELATIVE ${ANDROID_TOOLCHAIN_ROOT} ${ANDROID_TOOLCHAIN_ROOT}/*)
message(STATUS "ndk-host: ${ANDROID_NDK_HOST}")

set(ANDROID_ABI armeabi-v7a)
message(STATUS "target-architecture: ${ANDROID_ABI}")

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")

# setup the cross-compiler
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_NDK_HOST}")
set(COMMAND_PREFIX "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-")
set(CMAKE_ASM_COMPILER "${COMMAND_PREFIX}gcc"     CACHE PATH "assembler")
set(CMAKE_C_COMPILER   "${COMMAND_PREFIX}gcc"     CACHE PATH "C compiler")
set(CMAKE_CXX_COMPILER "${COMMAND_PREFIX}g++"     CACHE PATH "C++ compiler")
set(CMAKE_AS_COMPILER  "${COMMAND_PREFIX}as"      CACHE PATH "AS compiler")
set(CMAKE_STRIP        "${COMMAND_PREFIX}strip"   CACHE PATH "strip")
set(CMAKE_AR           "${COMMAND_PREFIX}ar"      CACHE PATH "archive")
set(CMAKE_LINKER       "${COMMAND_PREFIX}ld"      CACHE PATH "linker")
set(CMAKE_NM           "${COMMAND_PREFIX}nm"      CACHE PATH "nm")
set(CMAKE_OBJCOPY      "${COMMAND_PREFIX}objcopy" CACHE PATH "objcopy")
set(CMAKE_OBJDUMP      "${COMMAND_PREFIX}objdump" CACHE PATH "objdump")
set(CMAKE_RANLIB       "${COMMAND_PREFIX}ranlib"  CACHE PATH "ranlib")

# Force set compilers because standard identification works badly for us
#include(CMakeForceCompiler)
#CMAKE_FORCE_C_COMPILER( "${CMAKE_C_COMPILER}" GNU)
#set(CMAKE_C_SIZEOF_DATA_PTR 4)
#set(CMAKE_C_HAS_ISYSROOT 1)
#set(CMAKE_C_COMPILER_ABI ELF)
#CMAKE_FORCE_CXX_COMPILER( "${CMAKE_CXX_COMPILER}" GNU)
#set(CMAKE_CXX_PLATFORM_ID Linux)
#set(CMAKE_CXX_SIZEOF_DATA_PTR ${CMAKE_C_SIZEOF_DATA_PTR})
#set(CMAKE_CXX_HAS_ISYSROOT 1)
#set(CMAKE_CXX_COMPILER_ABI ELF)
#set(CMAKE_CXX_SOURCE_FILE_EXTENSIONS cc cp cxx cpp CPP c++ C)
## force ASM compiler (required for CMake < 2.8.5)
#set(CMAKE_ASM_COMPILER_ID_RUN TRUE)
#set(CMAKE_ASM_COMPILER_ID GNU)
#set(CMAKE_ASM_COMPILER_WORKS TRUE)
#set(CMAKE_ASM_COMPILER_FORCED TRUE)
#set(CMAKE_COMPILER_IS_GNUASM 1)
#set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS s S asm)
#foreach( lang C CXX ASM)
#	set(CMAKE_${lang}_COMPILER_VERSION ${ANDROID_COMPILER_VERSION})
#endforeach()

# flags and definitions
add_definitions(-DANDROID)
set(ANDROID_CXX_FLAGS "")
set(ANDROID_LINKER_FLAGS "")

# CXX_FLAGS
set(ANDROID_SYSROOT	"${ANDROID_NDK_ROOT}/platforms/android-${ANDROID_API}/arch-arm")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funwind-tables")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mthumb -fomit-frame-pointer -fno-strict-aliasing")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -finline-limit=64")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fsigned-char") # good/necessary when porting desktop libraries
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=${CMAKE_SYSTEM_PROCESSOR} -mfloat-abi=softfp")
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
set(ANDROID_STL	"${gnu-libstdc++}/${ANDROID_COMPILER_VERSION}")
set(ANDROID_STL_INCLUDE_DIRS
	"${ANDROID_STL}/include"
	"${ANDROID_STL}/include/backward"
	"${ANDROID_STL}/libs/${ANDROID_ABI}/include")
include_directories(SYSTEM
	"${ANDROID_SYSROOT}/usr/include"
	"${ANDROID_STL_INCLUDE_DIRS}")
set(__libstl "${ANDROID_STL}/libs/${ANDROID_ABI}/libgnustl_static.a")
set(__libsupcxx "${ANDROID_STL}/libs/${ANDROID_ABI}/libsupc++.a")

# LINKER flags
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libstl}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libsupcxx}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -lm")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--fix-cortex-a8")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-allow-shlib-undefined")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--gc-sections")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-z,noexecstack")

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
macro(generate_apk TARGET SOURCE_TARGET PACKAGE_NAME)
	add_custom_target(${TARGET}	ALL
		# 1) create qtdeploy.json file
		COMMAND ${CMAKE_COMMAND} -E echo "{" > qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"description\\\": \\\"This file is to be read by androiddeployqt\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"qt\\\": \\\"${ANDROID_QT_ROOT}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"sdk\\\": \\\"${ANDROID_SDK_ROOT}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"sdkBuildToolsRevision\\\": \\\"${ANDROID_BUILD_TOOL}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"ndk\\\": \\\"${ANDROID_NDK_ROOT}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"toolchain-prefix\\\": \\\"${ANDROID_TOOLCHAIN_MACHINE_NAME}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"tool-prefix\\\": \\\"${ANDROID_TOOLCHAIN_MACHINE_NAME}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"toolchain-version\\\": \\\"${ANDROID_COMPILER_VERSION}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"ndk-host\\\": \\\"${ANDROID_NDK_HOST}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"target-architecture\\\": \\\"${ANDROID_ABI}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"android-package\\\": \\\"${PACKAGE_NAME}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"android-app-name\\\": \\\"${SOURCE_TARGET}\\\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \\\"application-binary\\\": \\\"$<TARGET_FILE:${SOURCE_TARGET}>\\\"" >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo "}" >> qtdeploy.json
		# 2) copy lib (gradle/androiddeployqt issue?)
		COMMAND  ${CMAKE_COMMAND} -E make_directory libs/${ANDROID_ABI}/
		COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${SOURCE_TARGET}> libs/${ANDROID_ABI}/
		# 3) Run androiddeployqt
		COMMAND ${ANDROID_QT_ROOT}/bin/androiddeployqt
		--input ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json
		--output ${CMAKE_CURRENT_BINARY_DIR}
		--deployment bundled
		--android-platform android-${ANDROID_API}
		--jdk ${JAVA_HOME}
		--verbose --gradle
		# 4) Copy file
		COMMAND  ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/
		COMMAND  ${CMAKE_COMMAND} -E copy ./build/outputs/apk/${SOURCE_TARGET}-debug.apk ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/
		DEPENDS ${SOURCE_TARGET}
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
	install(FILES ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin/${SOURCE_TARGET}-debug.apk DESTINATION ${INSTALL_BIN_DIR})
endmacro()
