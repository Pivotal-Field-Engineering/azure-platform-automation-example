# Introduction

This workshop will walk you through the process of deploying **Pivotal Platform (PAS or PKS)** on **Microsoft Azure**. We will stand up **Concourse** using the **Pivotal Control Plane Tile** and deploy a **Pivotal Platform** runtime using **Platform Automation**.

***To log issues about this workshop***, click here to go to the [github](https://github.com/Pivotal-Field-Engineering/azure-platform-automation-example/issues) repository issue submission form.

## Outline

* Prepare your workstation
* Pave out an **Azure** tenancy and standup an **Opsmanager**
* Install the **Pivotal Control Plane Tile**
* Login to Concourse
* Deploy PAS or PKS using **Pivotal Platform Automation** (Concourse pipeline)

## Preparing your workstation

Before starting on this hands on lab you will need the following:

* a Microsoft Azure account
* A registered domain name and control of the dns
* A Linux or MacOS terminal environment (laptop or jump host)
* [Terraform 0.11](https://www.terraform.io/downloads.html)
* [OM CLI](https://github.com/pivotal-cf/om)

```bash
cd ~/workdir
git clone https://github.com/Pivotal-Field-Engineering/azure-platform-automation-example.git
cd azure-platform-automation-example
git clone https://github.com/Pivotal-Field-Engineering/terraforming-azure.git
mkdir bin
# grab a specific verison of Terraform
wget -qO- https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_darwin_amd64.zip | bsdtar -C bin/ -xvf-
mv control-plane/terraform.tfvars-example control-plane/terraform.tfvars
```

## Pave out a new Azure tennancy

``` bash
# tune control-plane/terraform.tfvars
bin/terraform init terraforming-azure/terraforming-control-plane
bin/terraform apply -state=control-plane/terraform.tfstate -var-file=control-plane/terraform.tfvars terraforming-azure/terraforming-control-plane
```

* Create an NS record on the parent DNS Zone with the records returned by the following:

```bash
bin/terraform output -state=control-plane/terraform.tfstate env_dns_zone_name_servers
```
**TODO** update NS records with `az cli`

You should now have a new **MS Azure** tennancy and an unconfigured **Opsmanager**.

* From any browser, access Ops Manger using URL defined by:
`open https://"$(bin/terraform output ops_manager_dns)"`

You can now chose to configure **Opsmanager** via the web or via the api but we
will be running a script against the Ops Manager api.

* Configure the Ops Manager BOSH tile
  `bin/deploy-om-director.sh`

## Deploy the Control Plane Tile

``` bash
mkdir artifacts
# configure om
source bin/set-om-creds.sh
# om download tile
om download-product \
  --pivnet-api-token="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  --output-directory="artifacts/" \
  --pivnet-file-glob="*.pivotal" \
  --pivnet-product-slug="p-control-plane-components" \
  --product-version-regex="1.0.0*" \
  --stemcell-iaas="azure"
# om upload tile
# om configure tile
# om apply changes
```
