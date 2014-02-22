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

function(_FIND_OPENCL_VERSION)
  include(CheckSymbolExists)
  include(CMakePushCheckState)

  CMAKE_PUSH_CHECK_STATE()
  foreach(VERSION "2_0" "1_2" "1_1" "1_0")
    set(CMAKE_REQUIRED_INCLUDES "${OpenCL_INCLUDE_DIR}")

    if(APPLE)
      CHECK_SYMBOL_EXISTS(
        CL_VERSION_${VERSION}
        "${OpenCL_INCLUDE_DIR}/OpenCL/cl.h"
        OPENCL_VERSION_${VERSION})
    else()
      CHECK_SYMBOL_EXISTS(
        CL_VERSION_${VERSION}
        "${OpenCL_INCLUDE_DIR}/CL/cl.h"
        OPENCL_VERSION_${VERSION})
    endif()

    if(OPENCL_VERSION_${VERSION})
      string(REPLACE "_" "." VERSION "${VERSION}")
      set(OpenCL_VERSION_STRING ${VERSION} CACHE
        STRING "Highest supported OpenCL version")
      break()
    endif()
  endforeach()
  CMAKE_POP_CHECK_STATE()
endfunction()

find_path(OpenCL_INCLUDE_DIR
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

if(WIN32)
  if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    find_library(OpenCL_LIBRARY
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
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    find_library(OpenCL_LIBRARY
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
  endif()
else()
  find_library(OpenCL_LIBRARY
    NAMES OpenCL)
endif()

set(OpenCL_LIBRARIES ${OpenCL_LIBRARY})

include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(
  OpenCL
  FOUND_VAR OpenCL_FOUND
  REQUIRED_VARS OpenCL_LIBRARY OpenCL_INCLUDE_DIR
  VERSION_VAR OpenCL_VERSION_STRING)

mark_as_advanced(
  OpenCL_INCLUDE_DIR
  OpenCL_LIBRARY
  OpenCL_LIBRARIES
  OpenCL_VERSION_STRING)
