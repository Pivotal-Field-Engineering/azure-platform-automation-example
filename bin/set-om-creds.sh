#!/usr/bin/env bash

set -euo pipefail

export OM_TARGET="$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_dns)"
export OM_USERNAME="admin"
export OM_PASSWORD="$(bin/terraform output -state=control-plane/terraform.tfstate ops_manager_password)"
