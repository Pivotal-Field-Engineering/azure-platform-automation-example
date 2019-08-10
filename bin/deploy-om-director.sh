#!/bin/bash

set -euo pipefail

## Prepare script from the outputs of the previous terraformin-azure run
# :TODO: Un-hardcode a bunch of stuff
#
prepare() {
  export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  export director_bosh_root_storage_account=$(bin/terraform output -state=control-plane/terraform.tfstate bosh_root_storage_account)
  export director_client_id=$(bin/terraform output -state=control-plane/terraform.tfstate client_id)
  export director_client_secret=$(bin/terraform output -state=control-plane/terraform.tfstate client_secret)
  export director_default_security_group_name=$(bin/terraform output -state=control-plane/terraform.tfstate bosh_deployed_vms_security_group_name)
  export director_resource_group_name=$(bin/terraform output -state=control-plane/terraform.tfstate pcf_resource_group_name)
  export director_ops_manager_ssh_public_key=$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_ssh_public_key)
  export director_ops_manager_ssh_private_key=$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_ssh_private_key)
  export director_subscription_id=$(bin/terraform output -state=control-plane/terraform.tfstate subscription_id)
  export director_tenant_id=$(bin/terraform output -state=control-plane/terraform.tfstate tenant_id)
  export director_network=$(bin/terraform output -state=control-plane/terraform.tfstate network_name)
  export director_infra_subnetwork=$(bin/terraform output -state=control-plane/terraform.tfstate infrastructure_subnet_name)
  export director_infra_cidr=$(bin/terraform output -state=control-plane/terraform.tfstate infrastructure_subnet_cidr)
  export director_infra_reserved_ip_ranges="10.0.8.1-10.0.8.9"
  export director_infra_gw=$(bin/terraform output -state=control-plane/terraform.tfstate infrastructure_subnet_gateway)
  export director_plane_subnetwork=$(bin/terraform output -state=control-plane/terraform.tfstate control_plane_subnet_name)
  export director_plane_cidr=$(bin/terraform output -state=control-plane/terraform.tfstate control_plane_subnet_cidr)
  export director_plane_reserved_ip_ranges="10.0.10.1-10.0.10.9"
  export director_plane_gw=$(bin/terraform output -state=control-plane/terraform.tfstate control_plane_subnet_gateway)
  export director_dns_servers="168.63.129.16,8.8.8.8"
  export OM_TARGET=$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_dns)
  export OM_USERNAME=admin
  export OM_PASSWORD=$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_password)
}

## Check script is ready to be run
#
check() {

  : "${director_bosh_root_storage_account:?required}"
  : "${director_client_id:?required}"
  : "${director_client_secret:?required}"
  : "${director_default_security_group_name:?required}"
  : "${director_resource_group_name:?required}"
  : "${director_ops_manager_ssh_public_key:?required}"
  : "${director_ops_manager_ssh_private_key:?required}"
  : "${director_subscription_id:?required}"
  : "${director_tenant_id:?required}"
  : "${director_network:?required}"
  : "${director_infra_subnetwork:?required}"
  : "${director_infra_cidr:?required}"
  : "${director_infra_reserved_ip_ranges:?required}"
  : "${director_infra_gw:?required}"
  : "${director_plane_subnetwork:?required}"
  : "${director_plane_cidr:?required}"
  : "${director_plane_reserved_ip_ranges:?required}"
  : "${director_plane_gw:?required}"
  : "${director_dns_servers:?required}"
  : "${OM_TARGET:?required}"
  : "${OM_USERNAME:?required}"
  : "${OM_PASSWORD:?required}"

  # :TODO: run an bin/om curl to check api connectivity
}

## Configure Ops Manager Authentication
#
opsman_auth() {
  echo "Configuring Ops Manager Authentication"
  om -t $OM_TARGET --skip-ssl-validation \
    configure-authentication \
    --decryption-passphrase pivotal123 \
    --username admin \
    --password $(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_password)
}

## Configure Ops Manager Director with OM
#
opsman_config() {
  echo "Configuring Ops Manager Director"
  om -t $OM_TARGET --skip-ssl-validation \
    configure-director --config $SCRIPT_DIR/director.yml --vars-env=director
}

## Apply changes/setup to Ops Manager
#
om_apply_changes() {
  echo "Deploying Ops Manager Director"
  om -t $OM_TARGET --skip-ssl-validation apply-changes
}

## Main script entry point
#
main() {
  prepare
  check
  opsman_auth
  opsman_config
  om_apply_changes
}

main "$@"
