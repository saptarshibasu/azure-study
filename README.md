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
* Two deployment models:
  * Classic - Legacy model
  * Resource Manager - Introduction of the resource group concept for better manageability
* There are three scenarios to be aware of:
  * Cloud Services (serverless services) doesn't support Resource Manager deployment model
  * Virtual machines, storage accounts, and virtual networks support both Resource Manager and classic deployment models
  * All other Azure services support Resource Manager

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

### Hybrid Connectivity

* Hybrid (local datacenter and Azure Virtual Network) connectivity options -
  * **Site-to-Site (S2S)** - Established between your on-premises VPN device and an Azure VPN Gateway that is deployed in a virtual network
  * **Point to Site (P2S)** - Established between a virtual network and a single computer in your network
  * **Express Route** - Established between your network and Azure, through an ExpressRoute partner. This connection is private. Traffic does not go over the internet
* **Site-to-Site (S2S)**
  * A VPN Gateway needs to be created in Azure with a public IP assigned to it
  * The enterprise datacenter needs to have a VPN device with a public IP assigned and it cannot be behind a NAT
  * The Gateway connection is over IPSec/IKE (IKE v1 or IKE v2) VPN tunnel
  * The connection is encrypted over the internet
* **Point to Site (P2S)**
  * Allows remote workers to connect to the Azure. No need for VPN device. Users can connect as long as there is internet connection
  * the connection is encrypted over the internet
  * Users use the native VPN clients on Windows and Mac devices for P2S
  * The Aggregate Throughput Benchmark for a VPN Gateway is S2S + P2S combined. If you have a lot of P2S connections, it can negatively impact a S2S connection due to throughput limitations
  * The Aggregate Throughput Benchmark is not a guaranteed throughput due to Internet traffic conditions and your application behaviors
* P2S Possible protocols:
  * **OpenVPN® Protocol**, an SSL/TLS based VPN protocol. OpenVPN can be used to connect from Android, iOS (versions 11.0 and above), Windows, Linux and Mac devices (OSX versions 10.13 and above)
  * **Secure Socket Tunneling Protocol (SSTP)**, a Microsoft proprietary TLS-based VPN protocol. Azure supports all versions of Windows that have SSTP (Windows 7 and later)
  * **IKEv2 VPN**, a standards-based IPsec VPN solution. IKEv2 VPN can be used to connect from Mac devices (OSX versions 10.11 and above)
* **Express Route**
  * This allows connections to offer more reliability, faster speeds, consistent latencies, and higher security than typical connections over the Internet
  * In an ExpressRoute connection, the virtual network gateway is configured with the gateway type 'ExpressRoute', rather than 'Vpn'
  * Connectivity can be from:
    * an any-to-any (IP VPN) network
    * a point-to-point Ethernet network
    * a virtual cross-connection through a connectivity provider at a co-location facility
  * While traffic that travels over an ExpressRoute circuit is not encrypted by default, it is possible create a solution that allows you to send encrypted traffic over an ExpressRoute circuit
  * Microsoft uses BGP, an industry standard dynamic routing protocol, to exchange routes between your on-premises network, your instances in Azure, and Microsoft public addresses
  * ExpressRoute connections enable access to the following services:
    * **Microsoft Azure services** (private peering)
    * **Microsoft Office 365 services** (Microsoft peering)
  * Provides Layer 3 connectivity
  * Provides connectivity to all regions in the geopolitical region. But, with the ExpressRoute Premium add-on, it provides connectivity accross all regions
  * Provides built-in redundancy
  * You must reserve a /29 subnet or two /30 subnets for routing interfaces. While you can create a gateway subnet as small as /29, we recommend that you create a gateway subnet of /27 or larger (/27, /26 etc.)
  * **Unlimited**
    * Speeds from 50 Mbps to 10 Gbps
    * Unlimited Inbound data transfer
    * Unlimited Outbound data transfer
    * Higher monthly fee
  * **Metered**
    * Speeds from 50 Mbps to 10 Gbps
    * Unlimited Inbound data transfer
    * Outbound data transfer charged at a predetermined rate per GB
    * Lower monthly fee  
* You can configure your virtual network to use both **Site-to-Site** and **Point-to-Site** concurrently, as long as you create your Site-to-Site connection using a **route-based** VPN type for your gateway
* The local network gateway typically refers to your on-premises location. You give the site a name by which Azure can refer to it, then specify the IP address of the on-premises VPN device to which you will create a connection. You also specify the IP address prefixes that will be routed through the VPN gateway to the VPN device

### Peering

* Peerling allows data transfer between virtual networks across Azure subscriptions, Azure Active Directory tenants, deployment models, and Azure regions
* For peered virtual networks, resources in either virtual network can directly connect with resources in the peered virtual network
* Azure supports the following types of peering:
  * Virtual network peering: Connect virtual networks within the same Azure region
  * Global virtual network peering: Connecting virtual networks across Azure regions
* Network traffic between peered virtual networks is private. Traffic between the virtual networks is kept on the Microsoft backbone network. No public Internet, gateways, or encryption is required in the communication between the virtual networks
* No bandwidth loss when peering with Virtual Network in the same region
* Peered Virtual Networks must be in one single cloud (i.e. either Azure public cloud regions, or China cloud regions, or Government cloud regions)
* Peered Virtual Networks must have non-overlapping IP address ranges
* Once a virtual network is peered with another virtual network, the addresss space cannot be changed. Workaround - remove peering, adjust address space, add peering back
* Each virtual network, including a peered virtual network, can have only one virtual network gateway of each type - Vpn and ExpressRoute
* A virtual network can use its gateway to connect to an on-premises network
* You can also configure the gateway in the peered virtual network as a transit point to an on-premises network. In this case, the virtual network that is using a remote gateway can't have its own gateway. A virtual network has only one gateway. The gateway is either a local or remote gateway in the peered virtual network
* When you create a virtual network gateway, you need to specify the gateway SKU that you want to use. Select the SKU that satisfies your requirements based on the types of workloads, throughputs, features, and SLAs
* When you create the virtual network gateway for a VPN gateway configuration, you must specify a VPN type. The VPN type that you choose depends on the connection topology that you want to create. For example, a P2S connection requires a RouteBased VPN type. A VPN type can also depend on the hardware that you are using. S2S configurations require a VPN device. Some VPN devices only support a certain VPN type
* if you want to create a S2S VPN gateway connection and a P2S VPN gateway connection for the same virtual network, you would use VPN type RouteBased because P2S requires a RouteBased VPN type. You would also need to verify that your VPN device supported a RouteBased VPN connection
* To confirm that virtual networks are peered, you can check effective routes. Check routes for a network interface in any subnet in a virtual network. If a virtual network peering exists, all subnets within the virtual network have routes with next hop type VNet peering, for each address space in each peered virtual network
* Transitive peering is not supported. If A is peered with B, and B with C, A cannot talk to C unless explicitly peered with C
* Service chaining enables you to direct traffic from one virtual network to a virtual appliance or gateway in a peered network through user-defined routes
* Allow forwarded traffic - This flag, if enabled when creating a peering, allows traffic forwarded by (not originated from) the peered virtual network
* Allow gateway transit - This flag, if enabled when creating a peering, allows the traffic from the peered network flow through the gateway of this virtual network. The peered network canot have its gateway configured. The peered network will then have the flag "Use remote gateways"
* Use remote gateways: Check this box to allow traffic from this virtual network to flow through a virtual network gateway attached to the virtual network you're peering with
* In a hub and spoke network topology, the hub virtual network can have a VPN Gateway that allows trafiic from the spoke virtual networks to the on-premise virtual networks. The same VPN Gateway can also allow traffic between the spoke virtual networks that are not directly peered with each other
* The benefits of hub and spoke topology include:
  * Cost savings by centralizing services that can be shared by multiple workloads, such as network virtual appliances (NVAs) and DNS servers, in a single location
  * Overcome subscriptions limits by peering virtual networks from different subscriptions to the central hub
  * Separation of concerns between central IT (SecOps, InfraOps) and workloads (DevOps)
* Typical uses for this architecture include:
  * Workloads deployed in different environments, such as development, testing, and production, that require shared services such as DNS, IDS, NTP, or AD DS. Shared services are placed in the hub virtual network, while each environment is deployed to a spoke to maintain isolation
  * Workloads that do not require connectivity to each other, but require access to shared services
  * Enterprises that require central control over security aspects, such as a firewall in the hub as a DMZ, and segregated management for the workloads in each spoke
* Throughput and max number of connections are determined by the generation and SKU of the VPN Gateway
* The best performance is obtained when we used GCMAES256 algorithm for both IPsec Encryption and Integrity

### Routing

* BGP enables the Azure VPN Gateways and your on-premises VPN devices, called BGP peers or neighbors, to exchange "routes" that will inform both gateways on the availability and reachability for those prefixes to go through the gateways or routers involved. BGP can also enable transit routing among multiple networks by propagating routes a BGP gateway learns from one BGP peer to all other BGP peers
* BGP is an optional feature you can use with Azure Route-Based VPN gateways. You should also make sure your on-premises VPN devices support BGP before you enable the feature. You can continue to use Azure VPN gateways and your on-premises VPN devices without BGP. It is the equivalent of using static routes (without BGP) vs. using dynamic routing with BGP between your networks and Azure
* BGP supports multiple tunnels between a VNet and an on-premises site with automatic failover
* This can enable transit routing with Azure VPN gateways between your on-premises sites or across multiple Azure Virtual Networks
* BGP is supported on Route-Based VPN gateways only
* You can use BGP for both cross-premises connections and VNet-to-VNet connections
* Every subnet has a route table that contains the following minimum routes:
  * **LocalVNet** - Route for local addresses (no next-hop value)
  * **On-Premises** - Route for defined on-premises address space (VNet Gateway is the next hop address)
  * **Internet** - Route for all traffic destined to the internet (Internet Gateway is the next hop address)
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
* Possible values for **Next hop types** in a route table:
  * **Virtual Network** - For each address range of the VNet
  * **Internet** - If you don't override Azure's default routes, Azure routes traffic for any address not specified by an address range within a virtual network, to the Internet, with one exception. If the destination address is for one of Azure's services, Azure routes the traffic directly to the service over Azure's backbone network, rather than routing the traffic to the Internet
  * **None** - Traffic routed to the None next hop type is dropped
  * **Virtual network (VNet) peering** - When you create a virtual network peering between two virtual networks, a route is added for each address range within the address space of each virtual network a peering is created for
  * **Virtual network gateway** - One or more routes with Virtual network gateway listed as the next hop type are added when a virtual network gateway is added to a virtual network. If your on-premises network gateway exchanges border gateway protocol (BGP) routes with an Azure virtual network gateway, a route is added for each route propagated from the on-premises network gateway
  * **VirtualNetworkServiceEndpoint** - The public IP addresses for certain services are added to the route table by Azure when you enable a service endpoint to the service. Service endpoints are enabled for individual subnets within a virtual network, so the route is only added to the route table of a subnet a service endpoint is enabled for
  * **Virtual appliance** - A virtual appliance is a virtual machine that typically runs a network application, such as a firewall
* Any network interface attached to a virtual machine that forwards network traffic to an address other than its own must have the Azure Enable IP forwarding option enabled for it. The setting disables Azure's check of the source and destination for a network interface
* Though Enable IP forwarding is an Azure setting, you may also need to enable IP forwarding within the virtual machine's operating system for the appliance to forward traffic between private IP addresses assigned to Azure network interfaces
* If the appliance must route traffic to a public IP address, it must either proxy the traffic, or network address translate the private IP address of the source's private IP address to its own private IP address, which Azure then network address translates to a public IP address, before sending the traffic to the Internet
* You can create custom, or user-defined(static), routes in Azure to override Azure's default system routes, or to add additional routes to a subnet's route table
* An on-premises network gateway can exchange routes with an Azure virtual network gateway using the border gateway protocol (BGP)
* You cannot specify VNet peering or VirtualNetworkServiceEndpoint as the next hop type in user-defined routes
* In Azure, you create a route table, then associate the route table to zero or more virtual network subnets
* Each subnet can have zero or one route table associated to it
* If you create a route table and associate it to a subnet, the routes within it are combined with, or override, the default routes Azure adds to a subnet by default
* If multiple routes contain the same address prefix, Azure selects the route type, based on the following priority:
  * User-defined route
  * BGP route
  * System route
* Deploy a virtual appliance into a different subnet than the resources that route through the virtual appliance are deployed in. Deploying the virtual appliance to the same subnet, then applying a route table to the subnet that routes traffic through the virtual appliance, can result in routing loops, where traffic never leaves the subnet
* NAT Gateway is a completely managed service throgh which goes all the outbound connections to the internet. The NAT gateway does the address translation from the private IP to a fixed range of public IP. This helps in whitelisting IPs
* Load Balancer is for the inbound connections

### DNS

* Azure DNS a.k.a public DNS is a hosting service for DNS domains
* In addition to supporting internet-facing DNS domains, Azure DNS also supports private DNS zones (Azure Private DNS)
* Azure DNS uses Anycast networking so that each DNS query is answered by the closest available DNS server
* **Azure DNS** provides an authoritative DNS service. It does not provide a recursive DNS service. Cloud Services and VMs in Azure are automatically configured to use a recursive DNS service that is provided separately as part of Azure's infrastructure
* If the user buys a custome domain contoso.net, the domain name registrar allows the user to setup NS record to point to the authoritative name server (in this case Azure DNS). The registrar stores the NS records in the .net parent zone
* **Private Azure DNS** - By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today. The records contained in a private DNS zone are not resolvable from the Internet. DNS resolution against a private DNS zone works only from virtual networks that are linked to it
* You can also enable auto-registration feature to automatically manage the life cycle of the DNS records for the virtual machines deployed in a virtual network
* Azure provided name resolution provides only basic authoritative DNS capabilities. If you use this option the DNS zone names and records will be automatically managed by Azure and you will not be able to control the DNS zone names or the life cycle of DNS records. If you need a fully featured DNS solution for your virtual networks you must use Azure DNS private zones or Customer-managed DNS servers
* When resources deployed in virtual networks need to resolve domain names to internal IP addresses, they can use one of three methods:
  * Azure DNS private zones
  * Azure-provided name resolution
  * Name resolution that uses your own DNS server (which might forward queries to the Azure-provided DNS servers)
* DNS Name resolution scenarios:
  * **Name resolution for resources in the same VNet** - Azure Provided DNS or Azure DNS private zone
  * **Name resolution for resources between different VNets** - Azure DNS private zones or customer managed DNS servers
  * **Resolution of on-premise names from Azure** - Cusomer managed DNS servers
  * **Resolution of Azure names from on-premise computers** - Customer managed DNS servers forwarding queries to Azure for name resolution
* For the custom DNS changes to take effect, the VMs need to be restarted

## Azure Data Lake Storage

* Azure Data Lake Storage Gen2 is a set of capabilities dedicated to big data analytics, built on Azure Blob storage
* A fundamental part of Data Lake Storage Gen2 is the addition of a hierarchical namespace to Blob storage
* Data Lake Storage Gen2 allows you to manage and access data just as you would with a Hadoop Distributed File System (HDFS)
* One of the primary access methods for data in Azure Data Lake Storage Gen2 is via the Hadoop FileSystem
* Data Lake Storage Gen2 allows users of Azure Blob Storage access to a new driver, the Azure Blob File System driver or ABFS
* ABFS is part of Apache Hadoop and is included in many of the commercial distributions of Hadoop
* Using ABFS, many applications and frameworks can access data in Azure Blob Storage without any code explicitly referencing Data Lake Storage Gen2
* **Ingesting data into ADLS**
  * **Adhoc data**
    * Local Computer - Azure PowerShell, Azure CLI, Storage Explorer, AzCopy tool
    * Azure Storage Blob - Azure Data Factory, AzCopy tool, DistCp running on HDInsignt cluster
  * **Streamed Data** - The following tools will usually capture and process the data on an event-by-event basis in real-time, and then write the events in batches into Data Lake Storage Gen2 so that they can be further processed
    * Azure Stream Analytics
    * Azure HDInsight Storm
  * **Relational Data**
    * Azure Data Factory
  * **Web server log data**
    * Azure Data Factory
    * Azure PowerShell
    * Azure CLI
  * **Data associated with Azure HDInsight clusters**
    * Azure DistCp
    * AzCopy tool
    * Azure Data Factory
  * **Data stored in on-premises or IaaS Hadoop clusters**
    * Azure Data Factory
  * **Really large datasets**
    * Azure ExpressRoute
* **Processng Data**
  * Azure HDInsight
  * Azure Databricks
* **Visualizing Data**
  * Power BI
* **Download the data**
  * Azure Data Factory
  * Azure DistCp
  * Azure Storage Explorer
  * AzCopy tool
