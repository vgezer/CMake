#.rst:
# FindHG
# ------
#
# Extract information from a mercurial working copy
#
# The module defines the following variables:
#
# ::
#
#   Hg_EXECUTABLE - path to mercurial command line client
#   Hg_FOUND - true if the command line client was found
#   Hg_VERSION_STRING - the version of the mercurial client
#
#
# If the command line client executable is found the following macro is defined:
#
# ::
#
#   Hg_WC_INFO(<dir> <var-prefix>)
#
# Hg_WC_INFO extracts information of a mercurial working copy
# at a given location.  This macro defines the following variables:
#
# ::
#
#   <var-prefix>_WC_CHANGESET - current changeset
#   <var-prefix>_WC_REVISION - current revision
#
# Example usage:
#
# ::
#
#   find_package(Hg)
#   if(Hg_FOUND)
#     Hg_WC_INFO(${PROJECT_SOURCE_DIR} Project)
#     message("Current revision is ${Project_WC_REVISION}")
#     message("Current changeset is ${Project_WC_CHANGESET}")
#   endif()
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

FIND_PROGRAM(Hg_EXECUTABLE
  NAMES hg
  PATHS [HKEY_LOCAL_MACHINE\\Software\\TortoiseHG]
      [HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\TortoiseHG]
  DOC "hg command line client")
MARK_AS_ADVANCED(Hg_EXECUTABLE)

IF(Hg_EXECUTABLE)
  EXECUTE_PROCESS(COMMAND ${Hg_EXECUTABLE} --version
    OUTPUT_VARIABLE Hg_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  IF(Hg_VERSION MATCHES "^Mercurial Distributed SCM \\(version ([0-9][^)]*)\\)")
    SET(Hg_VERSION_STRING "${CMAKE_MATCH_1}")
  ENDIF()
  UNSET(Hg_VERSION)

  MACRO(Hg_WC_INFO dir prefix)
    EXECUTE_PROCESS(COMMAND ${Hg_EXECUTABLE} id -i -n
      WORKING_DIRECTORY ${dir}
      ERROR_VARIABLE Hg_ERROR
      OUTPUT_VARIABLE ${prefix}_WC_DATA
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${Hg_error} EQUAL 0)
      MESSAGE(SEND_ERROR "Command \"${Hg_EXECUTBALE} id -n\" in directory ${dir} failed with output:\n${Hg_ERROR}")
    ENDIF()

    STRING(REGEX REPLACE "([0-9a-f]+)\\+? [0-9]+\\+?" "\\1" ${prefix}_WC_CHANGESET ${${prefix}_WC_DATA})
    STRING(REGEX REPLACE "[0-9a-f]+\\+? ([0-9]+)\\+?" "\\1" ${prefix}_WC_REVISION ${${prefix}_WC_DATA})
  ENDMACRO(Hg_WC_INFO)
ENDIF(Hg_EXECUTABLE)

INCLUDE(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Hg
  FOUND_VAR Hg_FOUND
  REQUIRED_VARS Hg_EXECUTABLE
  VERSION_VAR Hg_VERSION_STRING)
