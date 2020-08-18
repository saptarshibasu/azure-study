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

### Basics

* Any IP Address range defined in RFC 1918 e.g. 10.0.0.0/16
* Address ranges (CIDR) that are not allowed:
  * 224.0.0.0/4 (Multicast)
  * 255.255.255.255/32 (Broadcast)
  * 127.0.0.0/8 (Loopback)
  * 169.254.0.0/16 (Link-local)
  * 168.63.129.16/32 (Internal DNS)
* Smallest possible subnet is /29 which gives only 3 usable IP addresses
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

### Peering

* Peerling allows data transfer between virtual networks across Azure subscriptions, Azure Active Directory tenants, deployment models, and Azure regions
* For peered virtual networks, resources in either virtual network can directly connect with resources in the peered virtual network
* Azure supports the following types of peering:
  * Virtual network peering: Connect virtual networks within the same Azure region
  * Global virtual network peering: Connecting virtual networks across Azure regions
* Network traffic between peered virtual networks is private. Traffic between the virtual networks is kept on the Microsoft backbone network. No public Internet, gateways, or encryption is required in the communication between the virtual networks
* No bandwidth loss when peering with Virtual Network in the same region
* Peered Virtual Networks must be in one single cloud (i.e. either Azure public cloud regions, or China cloud regions, or Government cloud regions)
* Peered Virtual Networks must have non=overlapping IP address range
* Once a virtual network is peered with another virtual network, the addresss space cannot be changed. Workaround - remove peering, adjust address space, add peering back
* Each virtual network, including a peered virtual network, can have its own gateway
* A virtual network can use its gateway to connect to an on-premises network
* You can also configure the gateway in the peered virtual network as a transit point to an on-premises network. In this case, the virtual network that is using a remote gateway can't have its own gateway. A virtual network has only one gateway. The gateway is either a local or remote gateway in the peered virtual network
* To confirm that virtual networks are peered, you can check effective routes. Check routes for a network interface in any subnet in a virtual network. If a virtual network peering exists, all subnets within the virtual network have routes with next hop type VNet peering, for each address space in each peered virtual network
* Throughput and max number of connections are determined by the generation and SKU of the VPN Gateway
* The best performance is obtained when we used GCMAES256 algorithm for both IPsec Encryption and Integrity
* Hybrid (local datacenter and Azure Virtual Network) connectivity options -
  * Site-to-Site (S2S)
    * Established between your on-premises VPN device and an Azure VPN Gateway that is deployed in a virtual network
    * A VPN Gateway needs to be created in Azure with a public IP assigned to it
    * The enterprise datacenter needs to have a VPN device with a public IP assigned and it cannot be behind a NAT
    * The Gateway connection is over IPSec/IKE (IKE v1 or IKE v2) VPN tunnel
    * S2S connections can be used for cross-premises and hybrid configurations
  * Express Route
    * Established between your network and Azure, through an ExpressRoute partner. This connection is private. Traffic does not go over the internet
    * This allows ExpressRoute connections to offer more reliability, faster speeds, consistent latencies, and higher security than typical connections over the Internet
    * An ExpressRoute connection uses a virtual network gateway as part of its required configuration. In an ExpressRoute connection, the virtual network gateway is configured with the gateway type 'ExpressRoute', rather than 'Vpn'
    * Connectivity can be from:
      * an any-to-any (IP VPN) network
      * a point-to-point Ethernet network
      * a virtual cross-connection through a connectivity provider at a co-location facility
    * While traffic that travels over an ExpressRoute circuit is not encrypted by default, it is possible create a solution that allows you to send encrypted traffic over an ExpressRoute circuit
    * Microsoft uses BGP, an industry standard dynamic routing protocol, to exchange routes between your on-premises network, your instances in Azure, and Microsoft public addresses
    * ExpressRoute connections enable access to the following services:
      * Microsoft Azure services (private peering)
      * Microsoft Office 365 services (Microsoft peering)
    * Provides Layer 3 connectivity
    * Provides connectivity to all regions in the geopolitical region. But, with the ExpressRoute Premium add-on, it provides connectivity accross all regions
    * Provides built-in redundancy
    * You must reserve a /29 subnet or two /30 subnets for routing interfaces
    * Unlimited
      * Speeds from 50 Mbps to 10 Gbps
      * Unlimited Inbound data transfer
      * Unlimited Outbound data transfer
      * Higher monthly fee
    * Metered
      * Speeds from 50 Mbps to 10 Gbps
      * Unlimited Inbound data transfer
      * Outbound data transfer charged at a predetermined rate per GB
      * Lower monthly fee
  * Point to Site (P2S)
    * Established between a virtual network and a single computer in your network
    * Allows remote workers to connect to the Azure. No need for VPN device or public IP. Users can connect as long as there is internet connection
    * Users use the native VPN clients on Windows and Mac devices for P2S
    * The Aggregate Throughput Benchmark for a VPN Gateway is S2S + P2S combined. If you have a lot of P2S connections, it can negatively impact a S2S connection due to throughput limitations
    * The Aggregate Throughput Benchmark is not a guaranteed throughput due to Internet traffic conditions and your application behaviors
    * Possible protocols:
      * OpenVPN® Protocol, an SSL/TLS based VPN protocol. OpenVPN can be used to connect from Android, iOS (versions 11.0 and above), Windows, Linux and Mac devices (OSX versions 10.13 and above)
      * Secure Socket Tunneling Protocol (SSTP), a Microsoft proprietary TLS-based VPN protocol. Azure supports all versions of Windows that have SSTP (Windows 7 and later)
      * IKEv2 VPN, a standards-based IPsec VPN solution. IKEv2 VPN can be used to connect from Mac devices (OSX versions 10.11 and above)
  * Every subnet has a route table that contains the following minimum routes:
    * LocalVNet - Route for local addresses (no next-hop value)
    * On-Premises - Route for defined on-premises address space (VNet Gateway is the next hop address)
    * Internet - Route for all traffic destined to the internet (Internet Gateway is the next hop address)
  * Default routing in a subnet (can be overriden by User Defined Routes (UDR))
    * If address is within the VNet address prefix - route to local VNet
    * If the address is within the on-premises address prefixes on BGP published routes (BGP or Local Site Network (LSN) for S2S) - route to Gateway
    * If the address is not part of the VNet or the BGP or LSN routes - route to internet via NAT
    * If destination is an Azure data center address and ER public peering is enabled - it is routed to the Gateway
  * All resources in the Virtual Network have outbound internet connectivity by default. Here a private IP is SNAT to a public IP selected by Azure
  * For Inbound connectivity a public IP is necessary
  * Options for providing inbound internet connection
    * Adding a public IP to the service (not recommended)
    * Place instance behind a LB that has a public IP
    * Use Network Virtual Appliance (NVA) with a public IP
  * When resources deployed in virtual networks need to resolve domain names to internal IP addresses, they can use one of three methods:
    * Azure DNS private zones
      * By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today
      * You can configure zones names with a split-horizon view, which allows a private and a public DNS zone to share the name
      * It provides name resolution for virtual machines (VMs) within a virtual network and between virtual networks
    * Azure-provided name resolution
      * If you use this option the DNS zone names and records will be automatically managed by Azure and you will not be able to control the DNS zone names or the life cycle of DNS records
      * If you need a fully featured DNS solution for your virtual networks you must use Azure DNS private zones or Customer-managed DNS servers
    * Name resolution that uses your own DNS server (which might forward queries to the Azure-provided DNS servers)
  * DNS Name resolution scenarios:
  | Scenario                                 | Recommendation      |
  | ---------------------------------------- | ------------------- |
  | Name resolution between role instances   | Azure Provided DNS  |
  | or virtual machines in the same virtual  | or Azure DNS        |
  | network                                  | private zone        |
  |                                          |                     |
  | Name rsolution between different virtual | Azure DNS private   |
  | networks                                 | zones or customer   |
  |                                          | managed DNS servers |
  |                                          |                     |
  | Resolution of on-premise names from      | Customer managed    |
  | Azure                                    | DNS servers         |
  |                                          |                     |
  | Resolution of Azure names from           | Customer managed    |
  | on-premise computers                     | DNS servers forwar- |
  |                                          | ing queries to      |
  |                                          | Azure for name res- |
  |                                          | olution

  * For the custom DNs changes to take effect, the VMs need to be restarted
  * Azure DNS a.k.a public DNS is a hosting service for DNS domains
  * Azure DNN uses Anycast networking so that each DNS query is answered by the closest available DNS server
  * In addition to supporting internet-facing DNS domains, Azure DNS also supports private DNS zones (Azure Private DNS)