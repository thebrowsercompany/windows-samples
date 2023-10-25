cmake_minimum_required(VERSION 3.26.0)
project(WinUI3AnimationsPreview)
add_custom_target(WinUI3AnimationsPreview ALL)

# REPO_ROOT is required to be set for the following modules to work
set(REPO_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/..)

list(APPEND CMAKE_MODULE_PATH ${REPO_ROOT}/cmake)
include(WindowsBuild)
