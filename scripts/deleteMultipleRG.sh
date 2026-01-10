#!/usr/bin/env bash
set -euo pipefail

#---------------
# CONFIGURATION
#---------------

HUB_SUBSCRIPTION_ID="ba143abd-03c0-43fc-bb1f-5bf74803b418"
SPOKE_SUBSCRIPTION_ID="1d6333fe-86aa-4f86-aa01-0b2e87e21855"

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
  "rg-ai-qoh-sp-prod-cus"
  "rg-analytics-qoh-sp-prod-cus"
  "rg-compute-qoh-sp-prod-cus"
  "rg-container-qoh-sp-prod-cus"
  "rg-database-qoh-sp-prod-cus"
  "rg-devops-qoh-sp-prod-cus"
  "rg-integration-qoh-sp-prod-cus"
  "rg-management-qoh-sp-prod-cus"
  "rg-network-qoh-sp-prod-cus"
  "rg-security-qoh-sp-prod-cus"
  "rg-storage-qoh-sp-prod-cus"
)

DRY_RUN=false   # set to true to preview only

#-----------
# FUNCTIONS
#-----------

confirm() {
  read -r -p "$1 [y/N]: " response
  [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
}

delete_resource_groups() {
  local subscription_id="$1"
  shift
  local resource_groups=("$@")

  echo "--------------------------------------------------"
  echo "Target subscription: $subscription_id"
  echo "Resource groups to delete:"
  for rg in "${resource_groups[@]}"; do
    echo "  - $rg"
  done
  echo "--------------------------------------------------"

  if ! confirm "Proceed with deletion in this subscription?"; then
    echo "❌ Skipping subscription $subscription_id"
    return
  fi

  az account set --subscription "$subscription_id"

  for rg in "${resource_groups[@]}"; do
    if az group exists --name "$rg"; then
      if [[ "$DRY_RUN" == "true" ]]; then
        echo "🟡 DRY-RUN: Would delete RG '$rg'"
      else
        echo "🔥 Deleting RG '$rg'..."
        az group delete --name "$rg" --yes --no-wait
      fi
    else
      echo "⚠️  RG '$rg' does not exist — skipping"
    fi
  done
}

#-----------
# EXECUTION
#-----------

echo "🚨 WARNING: This script deletes Azure Resource Groups."
echo "🚨 Make sure you are in the correct tenant and environment."
echo ""

confirm "Do you want to continue?" || exit 1

delete_resource_groups "$HUB_SUBSCRIPTION_ID" "${HUB_RESOURCE_GROUPS[@]}"
delete_resource_groups "$SPOKE_SUBSCRIPTION_ID" "${SPOKE_RESOURCE_GROUPS[@]}"

echo "✅ Deletion requests submitted."
echo "ℹ️  Use 'az group list --query \"[?properties.provisioningState=='Deleting']\"' to monitor."