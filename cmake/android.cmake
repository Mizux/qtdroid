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
cmake_minimum_required(VERSION 3.2)

if(DEFINED ANDROID)
 return() # subsequent toolchain loading is not really needed
endif()

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release CACHE STRING "supported: Debug Release" FORCE)
endif()
message(STATUS "build type: ${CMAKE_BUILD_TYPE}")

set(JAVA_HOME $ENV{JAVA_HOME})
if(NOT JAVA_HOME)
    message(FATAL_ERROR "The JAVA_HOME environment variable is not set. Please set it to the root directory of the JDK.")
endif()
message(STATUS "java: ${JAVA_HOME}")

set(ANDROID_NDK $ENV{ANDROID_NDK})
if(NOT ANDROID_NDK)
	message(FATAL_ERROR "The ANDROID_NDK environment variable is not set. Please set it.")
endif()
message(STATUS "ndk: ${ANDROID_NDK}")

set(ANDROID_SDK $ENV{ANDROID_SDK})
if(NOT ANDROID_SDK)
	message(FATAL_ERROR "The ANDROID_SDK environment variable is not set. Please set it.")
endif()
message(STATUS "sdk: ${ANDROID_SDK}")

file(GLOB tools RELATIVE ${ANDROID_SDK}/build-tools ${ANDROID_SDK}/build-tools/*)
list(SORT tools)
list(REVERSE tools)
list(GET tools 0 ANDROID_BUILD_TOOL)
message(STATUS "build-tool: ${ANDROID_BUILD_TOOL}")

set(ANDROID_API 19)
message(STATUS "api: ${ANDROID_API}")

set(ANDROID_QT $ENV{ANDROID_QT})
if(NOT ANDROID_QT)
	message(FATAL_ERROR "The ANDROID_QT environment variable is not set. Please set it.")
endif()
message(STATUS "qt: ${ANDROID_QT}")
file(GLOB children ${ANDROID_QT}/lib/cmake/*)
foreach(child ${children})
	if(IS_DIRECTORY ${child})
		list(APPEND CMAKE_PREFIX_PATH ${child})
	endif()
endforeach()

set(ANDROID_TOOLCHAIN_MACHINE_NAME "arm-linux-androideabi")
message(STATUS "toolchain prefix: ${ANDROID_TOOLCHAIN_MACHINE_NAME}")

set(gnu-libstdc++ "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++")
file(GLOB version RELATIVE ${gnu-libstdc++}	${gnu-libstdc++}/4.*)
list(SORT version)
list(REVERSE version)
list(GET version 0 ANDROID_COMPILER_VERSION)
message(STATUS "compiler: ${ANDROID_COMPILER_VERSION}")

set(ANDROID_TOOLCHAIN_NAME ${ANDROID_TOOLCHAIN_MACHINE_NAME}-${ANDROID_COMPILER_VERSION})
set(ANDROID_TOOLCHAIN "${ANDROID_NDK}/toolchains/${ANDROID_TOOLCHAIN_NAME}/prebuilt")

file(GLOB ANDROID_NDK_HOST RELATIVE ${ANDROID_TOOLCHAIN} ${ANDROID_TOOLCHAIN}/*)
message(STATUS "ndk-host: ${ANDROID_NDK_HOST}")

set(ANDROID_ABI armeabi-v7a)
message(STATUS "target-architecture: ${ANDROID_ABI}")

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")

# setup the cross-compiler
set(ANDROID_TOOLCHAIN "${ANDROID_TOOLCHAIN}/${ANDROID_NDK_HOST}")
set(COMMAND_PREFIX "${ANDROID_TOOLCHAIN}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-")
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

# flags and definitions
add_definitions(-DANDROID)
set(ANDROID_CXX_FLAGS "")
set(ANDROID_C_FLAGS "")
set(ANDROID_LINKER_FLAGS "")

# CXX_FLAGS
set(ANDROID_SYSROOT	"${ANDROID_NDK}/platforms/android-${ANDROID_API}/arch-arm")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funwind-tables")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mthumb -fomit-frame-pointer -fno-strict-aliasing")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -finline-limit=64")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fsigned-char") # good/necessary when porting desktop libraries
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=${CMAKE_SYSTEM_PROCESSOR} -mfloat-abi=softfp")
#set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=neon")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=vfp")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fdata-sections -ffunction-sections")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -Wa,--noexecstack")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fpic")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -frtti")
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fexceptions")
set(ANDROID_C_FLAGS "${ANDROID_C_FLAGS} -fpic")
set(ANDROID_C_FLAGS "${ANDROID_C_FLAGS} -fexceptions")

# GNU STL
set(ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -std=gnu++11")
set(ANDROID_STL	"${gnu-libstdc++}/${ANDROID_COMPILER_VERSION}")
set(ANDROID_STL_INCLUDE_DIRS
	"${ANDROID_STL}/include"
	"${ANDROID_STL}/include/backward"
	"${ANDROID_STL}/libs/${ANDROID_ABI}/include")
include_directories(SYSTEM
	"${ANDROID_SYSROOT}/usr/include"
	"${ANDROID_STL_INCLUDE_DIRS}")
#set(__libstl "${ANDROID_STL}/libs/${ANDROID_ABI}/thumb/libgnustl_static.a")
#set(__libsupcxx "${ANDROID_STL}/libs/${ANDROID_ABI}/thumb/libsupc++.a")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libstl}")
#set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${__libsupcxx}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -L${ANDROID_STL}/libs/${ANDROID_ABI}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -lgnustl_shared")

# LINKER flags
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -lm -lz")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--fix-cortex-a8")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-allow-shlib-undefined")
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
set(CMAKE_FIND_ROOT_PATH "${ANDROID_TOOLCHAIN}/bin" "${ANDROID_SYSROOT}" "${CMAKE_INSTALL_PREFIX}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

# Macro to create APK using Qt SDK
macro(generate_apk TARGET SOURCE_TARGET PACKAGE_NAME)
	set(QT_ANDROID_APP_NAME ${SOURCE_TARGET})
	set(QT_ANDROID_PACKAGE_NAME ${PACKAGE_NAME})
	get_filename_component(TOOLCHAIN_DIR ${CMAKE_TOOLCHAIN_FILE} DIRECTORY)
	#configure_file(${TOOLCHAIN_DIR}/AndroidManifest.xml.in	${CMAKE_CURRENT_BINARY_DIR}/android-build/AndroidManifest.xml @ONLY)

	add_custom_command(OUTPUT android-build/libs qtdeploy.json
		# 1) create qtdeploy.json file
		COMMAND ${CMAKE_COMMAND} -E echo "{" > qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"description\": \"This file is to be read by androiddeployqt\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"qt\": \"${ANDROID_QT}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"sdk\": \"${ANDROID_SDK}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"sdkBuildToolsRevision\": \"${ANDROID_BUILD_TOOL}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"ndk\": \"${ANDROID_NDK}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"toolchain-prefix\": \"${ANDROID_TOOLCHAIN_MACHINE_NAME}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"tool-prefix\": \"${ANDROID_TOOLCHAIN_MACHINE_NAME}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"toolchain-version\": \"${ANDROID_COMPILER_VERSION}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"ndk-host\": \"${ANDROID_NDK_HOST}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"target-architecture\": \"${ANDROID_ABI}\"," >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo " \"application-binary\": \"$<TARGET_FILE:${SOURCE_TARGET}>\"" >> qtdeploy.json
		COMMAND ${CMAKE_COMMAND} -E echo "}" >> qtdeploy.json
		# 2) copy lib (gradle/androiddeployqt issue?)
		COMMAND  ${CMAKE_COMMAND} -E make_directory android-build/libs/${ANDROID_ABI}/
		COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${SOURCE_TARGET}> android-build/libs/${ANDROID_ABI}/
		# 3) Run androiddeployqt
		COMMAND ${ANDROID_QT}/bin/androiddeployqt
		--input ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json
		--output ${CMAKE_CURRENT_BINARY_DIR}/android-build
		--deployment bundled
		--android-platform android-${ANDROID_API}
		--jdk ${JAVA_HOME}
		--gradle --verbose
		--release
		VERBATIM)
	add_custom_target(${TARGET}	ALL
		DEPENDS ${SOURCE_TARGET} android-build/libs
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

	install(FILES
		${CMAKE_CURRENT_BINARY_DIR}/android-build/build/outputs/apk/android-build-debug.apk
		DESTINATION ${INSTALL_BIN_DIR} RENAME ${SOURCE_TARGET}.apk)
	#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/android-build/build/outputs/apk/android-build-release-unsigned.apk
	#	DESTINATION ${INSTALL_BIN_DIR} RENAME ${SOURCE_TARGET}.apk)
endmacro()
