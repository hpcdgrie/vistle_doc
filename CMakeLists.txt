cmake_minimum_required(VERSION 3.15.2 FATAL_ERROR)

project(
    Vistle_doc
    DESCRIPTION "Documentation for Vistle"
    HOMEPAGE_URL https://vistle.io)

find_package(Vistle REQUIRED COMPONENTS modules)

message("ALL_MODULES" ${ALL_MODULES})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_custom_target(vistle_doc ALL)

get_filename_component(VISTLE_BUILD_DIR "${Vistle_DIR}/../../.." ABSOLUTE)
find_path(VISTLE_SOURCE_DIR lib/vistle/core/object.h PATHS ${Vistle_DIR}/../../../..)
if(NOT VISTLE_SOURCE_DIR)
    message(FATAL_ERROR "Vistle source directory not found")
endif()

find_package(Sphinx REQUIRED)
if(SPHINX_EXECUTABLE)

add_custom_command(
    TARGET vistle_doc
    COMMAND ${SPHINX_EXECUTABLE} -M html source build
    WORKING_DIRECTORY  ${PROJECT_SOURCE_DIR}/docs
    COMMENT "Building readTheDocs documentation"
    DEPENDS vistle_module_doc)

    set(VISTLE_BUILD_DOC TRUE)
else()
    message("Sphinx not found, documentation can not be built")
    set(VISTLE_BUILD_DOC FALSE)
    return()
endif()





include(cmake/Documentation.cmake)

foreach(targetname ${ALL_MODULES})
    # get_filename_component(targetname ${executable} NAME_WE)
    file(GLOB TARGET_DIRS "${VISTLE_SOURCE_DIR}/module/*/${targetname}")
    foreach(dir ${TARGET_DIRS})
        if(IS_DIRECTORY ${dir})
            set(TARGET_SOURCE_DIR ${dir})
        endif()
    endforeach()
    get_filename_component(PARENT_DIR ${TARGET_SOURCE_DIR} DIRECTORY)
    get_filename_component(CATEGORY ${PARENT_DIR} NAME) 
    add_module_doc_target(${targetname} ${TARGET_SOURCE_DIR} ${CATEGORY})
endforeach()


