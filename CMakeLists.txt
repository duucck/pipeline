cmake_minimum_required(VERSION 3.10)

set(CMAKE_C_COMPILER /usr/bin/clang)
set(CMAKE_CXX_COMPILER /usr/bin/clang++)

project(seektest C CXX)

set(GSTREAMER_BASE_DIR "/home/clear/gstreamer_cerbero/package")

set (CMAKE_CXX_STANDARD 11)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -g")

set(Boost_USE_STATIC_LIBS ON)

find_package(Boost 1.65.1 REQUIRED COMPONENTS filesystem)

set(GSTREAMER_INCLUDE_DIRS 
    ${GSTREAMER_BASE_DIR}/1.21_dev/include/gstreamer-1.0
    ${GSTREAMER_BASE_DIR}/1.21_dev/include/json-glib-1.0
    ${GSTREAMER_BASE_DIR}/1.21_dev/include/libsoup-2.4
    ${GSTREAMER_BASE_DIR}/1.21_dev/include/libxml2
    ${GSTREAMER_BASE_DIR}/1.21_dev/include/glib-2.0
    ${GSTREAMER_BASE_DIR}/1.21_dev/lib/glib-2.0/include 
)

set(GSTREAMER_LIBRARY_DIRS 
    ${GSTREAMER_BASE_DIR}/1.21/lib
    ${GSTREAMER_BASE_DIR}/1.21/lib/gstreamer-1.0
)

set(GSTREAMER_LIBRARY_LINKS
    "-lgstsdp-1.0 -lgstbase-1.0 -lgstreamer-1.0 -ljson-glib-1.0 \
     -lgio-2.0 -lgmodule-2.0 -lgobject-2.0 -lglib-2.0 -lgstrtp-1.0 \
     -lgstcoreelements -lgstisomp4 -lgstflv -lgstvideo-1.0 \
     -lgstrtsp-1.0 -lgstrtspserver-1.0 -lgstrtmp")

include_directories(
    ${Boost_INCLUDE_DIRS}
    ${GSTREAMER_INCLUDE_DIRS}
)

link_directories(
    ${GSTREAMER_LIBRARY_DIRS}
    ${Boost_LIBRARY_DIRS}
)

add_executable(seektest test.cpp)

target_link_libraries(seektest ${GSTREAMER_LIBRARY_LINKS} ${Boost_LIBRARIES})
