#.rst:
# FindOpenCL
# ----------
#
# Try to find OpenCL
#
# Once done this will define
#
# ::
#
#   OpenCL_FOUND          - system has OpenCL
#   OpenCL_INCLUDE_DIR    - the OpenCL include directory
#   OpenCL_LIBRARIES      - Link against this library to use OpenCL
#   OpenCL_LIBRARY        - Path to the OpenCL library
#   OpenCL_VERSION_STRING - Highest supported OpenCL version (eg. 1.2)
#

#=============================================================================
# Copyright 2014 Matthaeus G. Chajdas
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

FUNCTION(_FIND_OPENCL_VERSION)
  INCLUDE(CheckSymbolExists)
  INCLUDE(CMakePushCheckState)

  CMAKE_PUSH_CHECK_STATE()
  FOREACH(VERSION "2_0" "1_2" "1_1" "1_0")
    SET(CMAKE_REQUIRED_INCLUDES "${OpenCL_INCLUDE_DIR}")

    IF(APPLE)
      CHECK_SYMBOL_EXISTS(
        CL_VERSION_${VERSION}
        "${OpenCL_INCLUDE_DIR}/OpenCL/cl.h"
        OPENCL_VERSION_${VERSION})
    ELSE()
      CHECK_SYMBOL_EXISTS(
        CL_VERSION_${VERSION}
        "${OpenCL_INCLUDE_DIR}/CL/cl.h"
        OPENCL_VERSION_${VERSION})
    ENDIF()

    IF(OPENCL_VERSION_${VERSION})
      STRING(REPLACE "_" "." VERSION "${VERSION}")
      SET(OpenCL_VERSION_STRING ${VERSION} CACHE
        STRING "Highest supported OpenCL version")
      BREAK()
    ENDIF()
  ENDFOREACH()
  CMAKE_POP_CHECK_STATE()
ENDFUNCTION()

FIND_PATH(OpenCL_INCLUDE_DIR
  NAMES
    CL/cl.h OpenCL/cl.h
  PATHS ENV
    "PROGRAMFILES(X86)"
    AMDAPPSDKROOT
    INTELOCLSDKROOT
    NVSDKCOMPUTE_ROOT
    CUDA_PATH
    ATISTREAMSDKROOT
  PATH_SUFFIXES
    OpenCL/common/inc
    "AMD APP/include")

_FIND_OPENCL_VERSION()

IF(WIN32)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY(OpenCL_LIBRARY
      NAMES OpenCL
      PATHS ENV
        "PROGRAMFILES(X86)"
        AMDAPPSDKROOT
        INTELOCLSDKROOT
        CUDA_PATH
        NVSDKCOMPUTE_ROOT
        ATISTREAMSDKROOT
      PATH_SUFFIXES
        "AMD APP/lib/x86"
        lib/x86
        lib/Win32
        OpenCL/common/lib/Win32)
  ELSEIF(CMAKE_SIZEOF_VOID_P EQUAL 8)
    FIND_LIBRARY(OpenCL_LIBRARY
      NAMES OpenCL
      PATHS ENV
        "PROGRAMFILES(X86)"
        AMDAPPSDKROOT
        INTELOCLSDKROOT
        CUDA_PATH
        NVSDKCOMPUTE_ROOT
        ATISTREAMSDKROOT
      PATH_SUFFIXES
        "AMD APP/lib/x86_64"
        lib/x86_64
        lib/x64
        OpenCL/common/lib/x64)
  ENDIF()
ELSE()
  FIND_LIBRARY(OpenCL_LIBRARY
    NAMES OpenCL)
ENDIF()

SET(OpenCL_LIBRARIES ${OpenCL_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  OpenCL
  FOUND_VAR OpenCL_FOUND
  REQUIRED_VARS OpenCL_LIBRARY OpenCL_INCLUDE_DIR
  VERSION_VAR OpenCL_VERSION_STRING)

MARK_AS_ADVANCED(
  OpenCL_INCLUDE_DIR
  OpenCL_LIBRARY
  OpenCL_LIBRARIES
  OpenCL_VERSION_STRING)
