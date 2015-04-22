cmake_minimum_required(VERSION 2.8.12)
set(_NAME puzzle)

#####################
##  Documentation  ##
#####################
#add_subdirectory("doc")

###################
##  Compilation  ##
###################
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

# Qt Setting
find_package(Qt5Widgets REQUIRED)

file(GLOB_RECURSE _HDRS include *.hpp)
file(GLOB_RECURSE _SRCS src *.cpp)
qt5_add_resources(_QRCS puzzle.qrc)

if(ANDROID)
	add_library(${_NAME} SHARED ${_HDRS} ${_SRCS} ${_QRCS})
else()
	add_executable(${_NAME} ${_HDRS} ${_SRCS} ${_QRCS})
endif()
target_link_libraries(${_NAME} Qt5::Widgets)
target_include_directories(${_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)

set_target_properties(${_NAME} PROPERTIES PUBLIC_HEADER "${_HDRS}")
install(TARGETS ${_NAME}
	RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin
	LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT shlib
	PUBLIC_HEADER DESTINATION "${INSTALL_INCLUDE_DIR}/${_NAME}" COMPONENT dev)
