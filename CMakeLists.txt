cmake_minimum_required(VERSION 2.8.0)
project(qtsamples)

##########################
##  INSTALL PARAMETERS  ##
##########################
# Offer the user the choice of overriding the installation directories
set(CMAKE_INSTALL_PREFIX install)
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR include CACHE PATH "Installation directory for header files")

# Make relative paths absolute (needed later on)
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

##############################
##  COMPILATION PARAMETERS  ##
##############################
# Set this on if you need verbose output from CMake
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

if(UNIX AND NOT APPLE)
	set(C_WARNFLAGS
		#-Werror
		-Wall
		-Wextra
		-Wconversion
		-Wpointer-arith
		-Wcast-align
		-fno-strict-aliasing
		-Wno-long-long
		)
	foreach(arg ${C_WARNFLAGS})
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${arg}")
	endforeach(arg ${C_WARNFLAGS})

	set(CXX_WARNFLAGS
		${C_WARNFLAGS}
		-pedantic
		#-pedantic-errors
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
