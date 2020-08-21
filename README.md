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
* Data Lake Storage Gen2 supports individual file sizes as high as 5TB
* Azure Active Directory service principals are typically used by services like Azure Databricks to access data in Data Lake Storage Gen2
* Data Lake Storage Gen2 supports the option of turning on a firewall and limiting access only to Azure services
* Data Lake Storage Gen2 handles 3x replication under the hood to guard against localized hardware failures
* Replication options, such as ZRS or GZRS, improve HA, while GRS & RA-GRS improve DR
* For data resiliency with Data Lake Storage Gen2, it is recommended to geo-replicate your data via GRS or RA-GRS that satisfies your HA/DR requirements
* **Distcp**
  * The most recommended tool for copying data between big data stores like Data Lake Storage Gen2, HDFS, or S3
  * Uses MapReduce jobs on a Hadoop cluster (for example, HDInsight) to scale out on all the nodes
  * Option to only update deltas between two locations
  * Handles automatic retries
  * Dynamic scaling of compute
* **Azure Data Factory**
  * Has a limit of cloud data movement units (DMUs), and eventually caps the throughput/compute for large data workloads
  * Does not offer delta updates between Data Lake Storage Gen2 accounts, so directories like Hive tables would require a complete copy to replicate
* Recommended directory structure fo better permissions management
  * IoT structure - {Region}/{SubjectMatter(s)}/{yyyy}/{mm}/{dd}/{hh}/
  * Batch jobs structure - {Region}/{SubjectMatter(s)}/In/{yyyy}/{mm}/{dd}/{hh}/, {Region}/{SubjectMatter(s)}/Out/{yyyy}/{mm}/{dd}/{hh}/, {Region}/{SubjectMatter(s)}/Bad/{yyyy}/{mm}/{dd}/{hh}/

## Azure Blob Storage

* Azure Blob storage is Microsoft's object storage solution for the cloud
* Blob storage offers three types of resources:
  * The storage account
  * A container in the storage account
  * A blob in a container
* A storage account provides a unique namespace in Azure for your data
* Azure Storage supports three types of blobs:
  * **Block blobs** store text and binary data. Block blobs are made up of blocks of data that can be managed individually. Block blobs store up to about 4.75 TiB of data. Larger block blobs are available in preview, up to about 190.7 TiB
  * **Append blobs** are made up of blocks like block blobs, but are optimized for append operations. Append blobs are ideal for scenarios such as logging data from virtual machines
  * **Page blobs** store random access files up to 8 TB in size. Page blobs store virtual hard drive (VHD) files and serve as disks for Azure virtual machines
* The types of storage accounts are
  * **General-purpose v2 accounts** - Basic storage account type for blobs (all types - block, append, page), files, queues, and tables. Recommended for most scenarios using Azure Storage
  * **General-purpose v1 accounts** - Legacy account type for blobs, files, queues, and tables. Use general-purpose v2 accounts instead when possible
  * **BlockBlobStorage accounts** - Storage accounts with premium performance characteristics for block blobs and append blobs. Recommended for scenarios with high transactions rates, or scenarios that use smaller objects or require consistently low storage latency
  * **FileStorage accounts** - Files-only storage accounts with premium performance characteristics. Recommended for enterprise or high performance scale applications
  * **BlobStorage accounts** - Legacy Blob-only storage accounts. Use general-purpose v2 accounts instead when possible.
* Azure storage redundancy types
  * **Locally redundant storage (LRS)** - A simple, low-cost redundancy strategy. Data is copied synchronously three times within the primary region
  * **Zone-redundant storage (ZRS)** - Redundancy for scenarios requiring high availability. Data is copied synchronously across three Azure availability zones in the primary region
  * **Geo-redundant storage (GRS)** - Cross-regional redundancy to protect against regional outages. Data is copied synchronously three times in the primary region, then copied asynchronously to the secondary region. For read access to data in the secondary region, enable read-access geo-redundant storage (RA-GRS)
  * **Geo-zone-redundant storage (GZRS) (preview)** - Redundancy for scenarios requiring both high availability and maximum durability. Data is copied synchronously across three Azure availability zones in the primary region, then copied asynchronously to the secondary region. For read access to data in the secondary region, enable read-access geo-zone-redundant storage (RA-GZRS)
* With GRS or GZRS, the data in the secondary location isn't available for read or write access unless there is a failover to the secondary region
* If the primary region becomes unavailable, you can choose to fail over to the secondary region. After the failover has completed, the secondary region becomes the primary region, and you can again read and write data
* Because data is replicated to the secondary region asynchronously, a failure that affects the primary region may result in data loss if the primary region cannot be recovered. The interval between the most recent writes to the primary region and the last write to the secondary region is known as the recovery point objective (RPO). The RPO indicates the point in time to which data can be recovered. Azure Storage typically has an RPO of less than 15 minutes, although there's currently no SLA on how long it takes to replicate data to the secondary region
* Geo-redundant storage (GRS) copies your data synchronously three times within a single physical location in the primary region using LRS. It then copies your data asynchronously to a single physical location in a secondary region. When data is written to the secondary location, it's also replicated within that location using LRS
* If your storage account is configured for read access to the secondary region, then you can design your applications to seamlessly shift to reading data from the secondary region if the primary region becomes unavailable for any reason
* The secondary region is available for read access after you enable RA-GRS or RA-GZRS, so that you can test your application in advance to make sure that it will properly read from the secondary in the event of an outage
* To determine which write operations have been replicated to the secondary region, your application can check the Last Sync Time property for your storage account. All write operations written to the primary region prior to the last sync time have been successfully replicated to the secondary region, meaning that they are available to be read from the secondary
* **Durability** over a given year
  * LRS - at least 99.999999999% (11 9's)	
  * ZRS - at least 99.9999999999% (12 9's)
  * GRS - at least 99.99999999999999% (16 9's)
  * GZRS - at least 99.99999999999999% (16 9's)
* **Storage account redundancy types**
  * General Purpose V2 - LRS, ZRS, GRS, GZRS
  * Block Blob Storage - LRS, ZRS
  * File Storage - LRS, ZRS
* Azure storage offers different access tiers, which allow you to store blob object data in the most cost-effective manner. The available access tiers include:
  * **Hot** - Optimized for storing data that is accessed frequently
  * **Cool** - Optimized for storing data that is infrequently accessed and stored for at least 30 days
  * **Archive** - Optimized for storing data that is rarely accessed and stored for at least 180 days with flexible latency requirements (on the order of hours)
* Only the hot and cool access tiers can be set at the account level. The archive access tier isn't available at the account level
* Hot, cool, and archive tiers can be set at the blob level during upload or after upload
* Archive storage stores data offline and offers the lowest storage costs but also the highest data rehydrate and access costs
* For objects with the tier set at the object level, the account tier won't apply. The archive tier can be applied only at the object level. You can switch between these access tiers at any time
* Data must remain in the archive tier for at least 180 days or be subject to an early deletion charge
* For small objects, a high priority rehydrate may retrieve the object from archive in under 1 hour
* While a blob is in archive storage, the blob data is offline and can't be read, overwritten, or modified
* To read or download a blob in archive, you must first rehydrate it to an online tier
* You can't take snapshots of a blob in archive storage. However, the blob metadata remains online and available, allowing you to list the blob, its properties, metadata, and blob index tags
* Setting or modifying the blob metadata while in archive is not allowed; however you may set and modify the blob index tags
* Blob Storage lifecycle management offers a rich, rule-based policy that you can use to transition your data to the best access tier and to expire data at the end of its lifecycle
* Data stored in a block blob storage account (Premium performance) cannot currently be tiered to hot, cool, or archive using Set Blob Tier or using Azure Blob Storage lifecycle management. To move data, you must synchronously copy blobs from the block blob storage account to the hot access tier in a different account
* Storage Availability
  * Hot Tier - 99.9%, 99.99% (with RA-GRS reads)
  * Cool Tier - 99%, 99.9% (with RA-GRS reads)
  * Archive Tier - offline
* Azure block blob storage offers two different performance tiers:
  * **Premium** - optimized for high transaction rates and single-digit consistent storage latency
  * **Standard** - optimized for high capacity and high throughput
* **Standard performance tier**
  * Supported storage account type - General purpose v2, BlobStorage, General purpose v1
  * Region availability - all regions
  * Redundancy - as per storage account type
* **Premium preformance tier**
  * Supported storage account type - Block blob storage
  * Region availability - selected regions
  * Redundancy - LRS, ZRS
* Premium performance block blob storage makes data available via high-performance hardware. Data is stored on solid-state drives (SSDs) which are optimized for low latency. Good for - 
  * Interactive workloads
  * Analytics - IoT many smaller writes
  * Artificial intelligence/machine learning (AI/ML)
  * Data transformation
* Standard performance supports different access tiers to store data in the most cost-effective manner. It's optimized for high capacity and high throughput on large data sets. Good for - 
  * Backup and disaster recovery datasets
  * Media content
  * Bulk data processing
* Blob storage lifecycle management offers a rich, rule-based policy:
  * Premium - Expire data at the end of its lifecycle
  * Standard - Transition data to the best access tier and expire data at the end of its lifecycle
* Azure storage service is designed to embrace a strong consistency model which guarantees that when the Storage service commits a data insert or update operation all further accesses to that data will see the latest update
* The Azure storage service uses snapshot isolation to allow read operations to happen concurrently with write operations within a single partition. Snapshot isolation guarantees that all reads see a consistent snapshot of the data even while updates are occurring – essentially by returning the last committed values while an update transaction is being processed
* You can opt to use either optimistic or pessimistic concurrency models to manage access to blobs and containers in the Blob service. If you do not explicitly specify a strategy last writes wins is the default
* **Optimistic concurrency** for blobs
  * Retrieve a blob from the storage service, the response includes an HTTP ETag Header value that identifies the current version of the object in the storage service
  * When you update the blob, include the ETag value you received in step 1 in the If-Match conditional header of the request you send to the service.
  * The service compares the ETag value in the request with the current ETag value of the blob
  * If the current ETag value of the blob is a different version than the ETag in the If-Match conditional header in the request, the service returns a 412 error to the client. This indicates to the client that another process has updated the blob since the client retrieved it
  * If the current ETag value of the blob is the same version as the ETag in the If-Match conditional header in the request, the service performs the requested operation and updates the current ETag value of the blob to show that it has created a new version
* **Pessimistic concurrency** for blobs
  * To lock a blob for exclusive use, you can acquire a lease on it
  * When you acquire a lease, you specify for how long you need the lease: this can be for between 15 to 60 seconds or infinite, which amounts to an exclusive lock
  * You can renew a finite lease to extend it, and you can release any lease when you are finished with it
  * The Blob service automatically releases finite leases when they expire.
  * Leases enable different synchronization strategies to be supported, including exclusive write / shared read, exclusive write / exclusive read and shared write / exclusive read. Where a lease exists the storage service enforces exclusive writes (put, set and delete operations) however ensuring exclusivity for read operations requires the developer to ensure that all client applications use a lease ID and that only one client at a time has a valid lease ID
  * Read operations that do not include a lease ID result in shared reads.
* The Table service uses optimistic concurrency checks as the default behavior when you are working with entities