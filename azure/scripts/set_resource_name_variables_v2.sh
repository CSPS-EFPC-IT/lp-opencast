#!/bin/bash
#
# Set a resource name variable in Azure build agent context.

# Exit on error.
set -e

# Load helper libraries.
# shellcheck source=./logger.sh
source "$(dirname "$0")"/logger.sh

######################################
# Set a given variable to a given value in Azure build agent context.
# Arguments:
#   The variable name, a string.
#   The variable value, a string.
#   Whether or not the new variable should be flagged as an "output variable", a boolean.
# Outputs:
#   Writes trace messages to stdout.
#   Commands to create the new variables in Azure build-agent context.
######################################
function set_variable_in_azure_context() {
  # Parameters
  local name="$1"
  local value="$2"
  local is_output="$3"

  logger::debug "- Setting \"${name}\" variable to \"${value}\"..."
  echo "##vso[task.setvariable variable=${name};isOutput=${is_output}]${value}"
}

######################################
# Set a given variable name in Azure build agent context based on given
# solution name, environment name, component name and Azure resource type .
# Notes
#   The resource names produced do NOT comply with Protected B naming
#   convention.
# Arguments:
#   Solution name, a string.
#   Environment name, a string.
#   Component name, an string. Optional.
#   Azure Resource Type, a string.
#   Output variable name, a string.
#   Whether or not the new variable should be flagged as an "output variable", a boolean. Default value: false.
# Outputs:
#   Writes trace messages to stdout.
# Returns:
#   0: Normal completion.
#   1: Invalid input parameters.
######################################
function main() {
  # Input parameters with default value.
  declare -Ax parameters=( \
    [--component-name]="none" \
    [--environment-name]="" \
    [--is-output]="false" \
    [--resource-type]="" \
    [--solution-name]="" \
    [--variable-name]="" \
  )

  # Variables
  local resource_name_prefix

  logger::info "Parsing input parameters..."
  # Map input parameter values.
  while [[ $# -gt 0 ]]; do
    case $1 in
      --component-name|\
      --environment-name|\
      --is-output|\
      --resource-type|\
      --solution-name|\
      --variable-name\
      )
        if [[ $# -lt 2 ]]; then
          logger::error "Input parameter \"$1\" requires a value. Aborting."
          exit 1
        fi
        parameters[${1}]="$2"
        shift 2
        ;;
      *)
        logger::error "Unknown input parameter: \"$1\"."
        logger::error "Usage: $0 ${!parameters[*]}"
        exit 1
        ;;
    esac
  done

  # Check for missing input parameters.
  for key in "${!parameters[@]}"; do
    if [[ -z "${parameters[${key}]}" ]]; then
      logger::error "Missing input parameter: \"${key}\". Aborting."
      logger::error "Usage: $0 ${!parameters[*]}"
      exit 1
    fi
    logger::debug "Input parameter value: ${key} = \"${parameters[${key}]}\"."
  done

  logger::info "Computing resource name prefix..."
  resource_name_prefix="${parameters[--solution-name]}"
  # Add environment name (in uppercase characters) to resource name prefix for
  # non-production environments.
  if [[ "${parameters[--environment-name]}" != "prod" ]]; then
    resource_name_prefix="${resource_name_prefix}-${parameters[--environment-name]^^}"
  fi
  # Add component name token, if provided.
  if [[ "${parameters[--component-name]}" != "none" ]]; then
      resource_name_prefix="${resource_name_prefix}-${parameters[--component-name]}"
  fi
  logger::debug "resource_name_prefix = \"${resource_name_prefix}\""

  # logger::info "Setting variable name..."
  case ${parameters[--resource-type]} in
    "Microsoft.Compute/disks")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-Disk" "${parameters[--is-output]}"
      ;;
    "Microsoft.ContainerService/managedClusters")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-K8S" "${parameters[--is-output]}"
      ;;
    "Microsoft.DBforMariaDB/servers"|\
    "Microsoft.DBforMySQL/servers"|\
    "Microsoft.DBforPostgreSQL/servers")
      # Use lowercase letters for PostgreSQL/MySQL/MariaDB server names.
      # Ref.: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdbforpostgresql
      # Ref.: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformysql
      # Ref.: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix,,}-db" "${parameters[--is-output]}"
      ;;
    "Microsoft.KeyVault/vaults")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-KV" "${parameters[--is-output]}"
      ;;
    "Microsoft.ManagedIdentity/userAssignedIdentities")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-UAMI" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/applicationGateways")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-AG" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/bastionHosts")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-BH" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/networkInterfaces")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-NIC" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/networkSecurityGroups")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-NSG" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/privateEndpoints")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-PE" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/publicIPAddresses")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-PublicIP" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/virtualNetworks")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-VN" "${parameters[--is-output]}"
      ;;
    "Microsoft.Network/virtualNetworks/subnets")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-SN" "${parameters[--is-output]}"
      ;;
    "Microsoft.OperationalInsights/workspaces")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-LAW" "${parameters[--is-output]}"
      ;;
   "Microsoft.Storage/storageAccounts")
      # Use lower case letters only.
      # See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage
      set_variable_in_azure_context "${parameters[--variable-name]}" "$(tr -cd '[:alnum:]' <<< "${resource_name_prefix,,}sa")" "${parameters[--is-output]}"
      ;;
    "Microsoft.Web/serverfarms")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-ASP" "${parameters[--is-output]}"
      ;;
    "Microsoft.Web/sites")
      set_variable_in_azure_context "${parameters[--variable-name]}" "${resource_name_prefix}-AS" "${parameters[--is-output]}"
      ;;
    *)
      logger::error "Unrecognized resource type: \"${parameters[--resource-type]}\". Aborting."
      exit 1
  esac

  logger::info "Done."
}

main "$@"
