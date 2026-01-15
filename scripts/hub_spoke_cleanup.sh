#!/usr/bin/env bash

set -euo pipefail

#---------------
# CONFIGURATION
#---------------

HUB_SUBSCRIPTION_ID="ba143abd-03c0-43fc-bb1f-5bf74803b418"
SPOKE_SUBSCRIPTION_ID="1d6333fe-86aa-4f86-aa01-0b2e87e21855"

# rg-qoh-hub-jumpbox-cus is intentionally excluded

HUB_RESOURCE_GROUPS=(
  "NetworkWatcherRG"
  "rg-qoh-tf-backend-cus"
  "rg-ai-qoh-hub-prod-cus"
  "rg-analytics-qoh-hub-prod-cus"
  "rg-compute-qoh-hub-prod-cus"
  "rg-container-qoh-hub-prod-cus"
  "rg-database-qoh-hub-prod-cus"
  "rg-devops-qoh-hub-prod-cus"
  "rg-integration-qoh-hub-prod-cus"
  "rg-management-qoh-hub-prod-cus"
  "rg-network-qoh-hub-prod-cus"
  "rg-security-qoh-hub-prod-cus"
  "rg-storage-qoh-hub-prod-cus"
)

SPOKE_RESOURCE_GROUPS=(
  "NetworkWatcherRG"
  "rg-ai-qoh-sp-dev-cus"
  "rg-analytics-qoh-sp-dev-cus"
  "rg-compute-qoh-sp-dev-cus"
  "rg-container-qoh-sp-dev-cus"
  "rg-database-qoh-sp-dev-cus"
  "rg-devops-qoh-sp-dev-cus"
  "rg-integration-qoh-sp-dev-cus"
  "rg-management-qoh-sp-dev-cus"
  "rg-network-qoh-sp-dev-cus"
  "rg-security-qoh-sp-dev-cus"
  "rg-storage-qoh-sp-dev-cus"
)

DRY_RUN=false   # set to true to preview only

#-----------
# FUNCTIONS
#-----------

print_section_header() {
  local title="$1"

  echo ""
  echo "#-----------------------------------"
  echo "# Deleting ${title} RG's"
  echo "#-----------------------------------"
  echo ""
}

delete_resource_groups() {
  local subscription_id="$1"
  local title="$2"
  shift 2
  local resource_groups=("$@")

  print_section_header "$title"

  az account set --subscription "$subscription_id"

  for rg in "${resource_groups[@]}"; do
    if az group show --name "$rg" &>/dev/null; then
      if [[ "$DRY_RUN" == "true" ]]; then
        echo "🟡 DRY-RUN: Would delete RG '$rg'"
      else
        echo "🔥 Deleting RG '$rg'..."
        az group delete \
          --name "$rg" \
          --yes \
          --no-wait
      fi
    else
      echo "⚠️  RG '$rg' does not exist — skipping"
    fi
  done
}

#-----------
# EXECUTION
#-----------

delete_resource_groups "$HUB_SUBSCRIPTION_ID" "hub_subscription" "${HUB_RESOURCE_GROUPS[@]}"
delete_resource_groups "$SPOKE_SUBSCRIPTION_ID" "spoke_subscription" "${SPOKE_RESOURCE_GROUPS[@]}"