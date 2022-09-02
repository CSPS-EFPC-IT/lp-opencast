#!/bin/bash
#
# Library of logging functions.

######################################
# Output a given message and level to console using the format:
# "[date] [time] | [message level] | [message]".
# This function is NOT meant to be called directly.
# Arguments:
#   The message to output to console, a string.
#   the message level, a string.
# Outputs:
#   Writes trace messages to stdout.
######################################
function output_message_lines() {
  # Parameters
  local message="$1"
  local level="$2"

  # Constant
  local -r LEVEL_SPACE_PADDING='       '

  # Variables
  local message_timestamp

  # Get a time stamp.
  message_timestamp="$(date +"%Y-%m-%d %H:%M:%S (%Z)")"

  # Loop through each line of the message.
  while IFS= read -r line; do
    echo "${message_timestamp} | ${level^^}${LEVEL_SPACE_PADDING:${#level}} | ${line}"
  done <<< "${message}"
}

######################################
# Output a debug message only if the Azure pipeline variable System.Debug is
# set to true.
# Arguments:
#   The message to output to console, a string
# Globals:
#   System.Debug, Ref.: https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml#systemdebug
# Outputs:
#   Writes trace messages to stdout.
######################################
function logger::debug() {

  # Parameters
  local message="$1"

output_message_lines "forced: ${message}" "debug"

  # shellcheck disable=SC2154 # SYSTEM_DEBUG is an environment variable. Thus it is NOT defined in this script.
  if [[ -n "${SYSTEM_DEBUG}" && "${SYSTEM_DEBUG,,}" == "true" ]]; then
    output_message_lines "${message}" "debug"
  fi
}

######################################
# Output an informative message to console.
# Arguments:
#   The message to output to console, a string
# Outputs:
#   Writes trace messages to stdout.
######################################
function logger::info() {

  # Parameters
  local message="$1"

  output_message_lines "${message}" "info"
}

######################################
# Output a warning message to console.
# Arguments:
#   The message to output to console, a string
# Outputs:
#   Writes trace messages to stdout.
######################################
function logger::warning() {

  # Parameters
  local message="$1"

  output_message_lines "${message}" "warning"
}

######################################
# Output an error message to console.
# Arguments:
#   The message to output to console, a string
# Outputs:
#   Writes trace messages to stdout.
######################################
function logger::error() {

  # Parameters
  local message="$1"

  output_message_lines "${message}" "error"
}

######################################
# Output a line of 80 dash character.
# Arguments:
#   None.
# Outputs:
#   Writes a dash line to stdout.
######################################
function logger::separator() {
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo ""
}
