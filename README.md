# Azure Cheat Sheet

* VM Availability: https://azure.microsoft.com/en-gb/support/legal/sla/virtual-machines/v1_9/
* Azure Enterprise (https://ea.azure.com) -> Departments (Optional) -> Accounts (https://account.azure.com) -> Subscriptions (https://portal.azure.com) -> Resource Groups -> Resources
* EA Breakdown - Enterprise Admin, Department Admin, Account Owner, Service Admin

## Resource Groups

* Benefits or Purpose
  * Better organization
  * Easy de-provisioning
  * Security boundary
    * Role-based Access Control (RBAC)
  * Apply policies
* The region of the resource group indicates the region where the resource group metadata will be stored. The resource group does not require the resources to be created in the same region. However, while creating resources using template, it is convenient to inherit the region from the resource group

## Virtual Networking

* Any IP Address range defined in RFC 1918 e.g. 10.0.0.0/16
* Address ranges that are not allowed:
  * 224.0.0.0/4 (Multicast)
  * 255.255.255.255/32 (Broadcast)
  * 127.0.0.0/8 (Loopback)
  * 169.254.0.0/16 (Link-local)
  * 168.63.129.16/32 (Internal DNS)
* Smallest possible subnet is /29 which gives only 3 usable IP addresses
* Public IP addresses can be attached to Azure resources
* Azure reserves 5 IP addresses in each subnet:
  * x.x.x.0 (Network address)
  * x.x.x.1 (Default Gateway)
  * x.x.x.2 (DNS Mapping)
  * x.x.x.3 (DNS Mapping)
  * x.x.x.255 (Broadcast)
* Public IP address assigned to an Azure resource allows
  * Internet resources to communicate inbound to the Azure resources
  * Azure resources to communicate outbound to the internet
  * Azure resources to communicate outbound to the Azure public facing services
* Public IP address can be assigned to:
  * Virtual Machine NIC
  * Public facing Load Balancers
  * VPN and Application Gateways
  * Azure Firewall
* Public IP Address SKUs
  * Basic SKU
    * No longer default
    * Assigned with static or dynamic allocation method
    * open by default (NSGs recommended)
    * Assigned to any Azure resource that allows a Public IP
    * Do not support Availability Zones
  * Standard SKU
    * Preferred method
    * Always use static allocation
    * Secure by default and closed to all inbound traffic
    * Assigned to NICs, Standard LBs, or App GWs
    * Support Availability Zones and can be zone-redundant or zonal
* Virtual Network is tied to a specific region and a specific subscription