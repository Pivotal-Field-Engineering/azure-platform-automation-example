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
wget -qO- https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_darwin_amd64.zip | bsdtar -C bin/ -xvf-
mv control-plane/terraform.tfvars-example control-plane/terraform.tfvars
# tune control-plane/terraform.tfvars
bin/terraform init terraforming-azure/terraforming-control-plane
bin/terraform apply -state=control-plane/terraform.tfstate -var-file=control-plane/terraform.tfvars terraforming-azure/terraforming-control-plane
```

* Create an NS record on the parent DNS Zone with the records returned by the following:

```bash
bin/terraform output env_dns_zone_name_servers
```

You should now have a new **MS Azure** tennancy and an unconfigured **Opsmanager**.  
* From any browser, access Ops Manger using URL defined by:
`open https://"$(bin/terraform output ops_manager_dns)"`

You can now chose to configure **Opsmanager** via the web or via the api.

##############
##NOT TESTED##
##############

1) Web - Follow the Pivotal documentation [Configuring BOSH Director on Azure](https://docs.pivotal.io/pivotalcf/2-4/om/azure/config-terraform.html)
1) Api - run `../../azure-platform-automation-example/scripts/deploy-om-director.sh` from your terminal

## Deploy the Control Plane Tile

**TODO**
