#!/usr/bin/env bash
set -euo pipefail
umask 077

ACTION="${1:?An action is required}"

export ARM_CLIENT_ID="${servicePrincipalId:?Missing service connection identity}"
export ARM_CLIENT_SECRET="${servicePrincipalKey:?Missing service connection credential}"
export ARM_TENANT_ID="${tenantId:?Missing service connection tenant}"
export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
export ARM_USE_AZUREAD=true
export TF_IN_AUTOMATION=true
export TF_INPUT=false

terraform version -json |
  jq -e '.terraform_version == "1.17.0"' >/dev/null || {
    echo "Expected Terraform 1.17.0 on the agent."
    exit 1
  }

cd "${BUILD_SOURCESDIRECTORY}/terraform"

terraform init -input=false -lockfile=readonly

case "$ACTION" in
  validate)
    terraform fmt -check
    terraform validate
    ;;

  plan)
    : "${TF_VAR_admin_cidr:?Missing ADMIN_CIDR}"
    : "${TF_VAR_mysql_admin_username:?Missing MySQL username}"
    : "${TF_VAR_mysql_admin_password:?Missing MySQL password}"
    : "${PLAN_FILE:?Missing saved-plan path}"

    mkdir -p "$(dirname "$PLAN_FILE")"

    terraform plan \
      -input=false \
      -lock-timeout=5m \
      -out="$PLAN_FILE"

    sha256sum "$PLAN_FILE"
    ;;

  apply)
    : "${PLAN_FILE:?Missing saved-plan path}"
    test -s "$PLAN_FILE"

    sha256sum "$PLAN_FILE"

    terraform apply \
      -input=false \
      -lock-timeout=5m \
      "$PLAN_FILE"
    ;;

  outputs)
    for name in \
      app_public_ip \
      backend_ansible_host \
      backend_private_ip \
      mysql_fqdn; do
      value="$(terraform output -raw "$name")"
      printf '%s = %s\n' "$name" "$value"
    done
    ;;

  *)
    echo "Unknown Terraform action."
    exit 1
    ;;
esac
