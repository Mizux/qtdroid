cmake_minimum_required(VERSION 3.4)
project(qtdroid)

##########################
##  INSTALL PARAMETERS  ##
##########################
# Offer the user the choice of overriding the installation directories
set(CMAKE_INSTALL_PREFIX install)
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for header files")
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib:$ORIGIN/")

##############################
##  COMPILATION PARAMETERS  ##
##############################
# Set this on if you need verbose output from CMake
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
set(BUILD_SHARED_LIBS ON)
set(OUTPUT_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/output)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/bin)
set(CMAKE_DOCUMENTATION_OUTPUT_DIRECTORY ${OUTPUT_PREFIX}/doc)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

if(CMAKE_COMPILER_IS_GNUCXX) # gcc / gcov
	set(C_WARNFLAGS
		-Wconversion
		-Wpointer-arith
		-Wcast-align
		-Wcast-qual
		-fno-strict-aliasing
		-Wold-style-declaration
		-Wold-style-definition
		)
	foreach(arg ${C_WARNFLAGS})
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${arg}")
	endforeach(arg ${C_WARNFLAGS})

	set(CXX_WARNFLAGS
		${C_WARNFLAGS}
		-pedantic
		-Weffc++
		-Wold-style-cast
		)
	foreach(arg ${CXX_WARNFLAGS})
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${arg}")
	endforeach(arg ${CXX_WARNFLAGS})
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang") # clang / llvm-cov gcov
	set(C_WARNFLAGS
		-Wconversion
		-Wpointer-arith
		-Wcast-align
		-Wcast-qual
		-fno-strict-aliasing
		-Wold-style-declaration
		-Wold-style-definition
		)
	foreach(arg ${C_WARNFLAGS})
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${arg}")
	endforeach(arg ${C_WARNFLAGS})

	set(CXX_WARNFLAGS
		${C_WARNFLAGS}
		-pedantic
		-Weffc++
		-Wold-style-cast
		)
	foreach(arg ${CXX_WARNFLAGS})
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${arg}")
	endforeach(arg ${CXX_WARNFLAGS})
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin)

add_subdirectory(puzzle)
