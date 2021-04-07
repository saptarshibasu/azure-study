# Azure Cheat Sheet

## Table of Content

[Basics](#basics)
[Resource Groups](#resource-groups)
[Virtual Networking](#virtual-networking)


## Basics

* VM Availability: https://azure.microsoft.com/en-gb/support/legal/sla/virtual-machines/v1_9/
* Azure Enterprise (https://ea.azure.com) -> Departments (Optional) -> Accounts (https://account.azure.com) -> Subscriptions (https://portal.azure.com) -> Resource Groups -> Resources
* EA Breakdown - Enterprise Admin, Department Admin, Account Owner, Service Admin

## Resource Groups
* A container that holds related resources for an Azure solution
* Generally used to hold resources that share the same lifecycle, so they can be easily deployed, updated, and deleted as a group
* The region of the resource group indicates the region where the resource group metadata will be stored
* The resource group does not require the resources to be created in the same region
* It is a good practice to create the resources in the same region as the resource group because 
  * It is convenient to inherit the region from the resource group
  * If the resource group's region is temporarily unavailable, you can't update resources in the resource group because the metadata is unavailable even though the resources may be up and running
* RBAC can be used to allow an application to access all resources in a resource group
* Naming convention - `rg-<App / Service name>-<Subscription type>-<###>` e.g. `rg-sharepoint-prod-001`
* Two deployment models:
  * Classic - Legacy model
  * Resource Manager - Introduction of the resource group concept for better manageability
* Cloud Services (serverless services) don't support Resource Manager deployment model

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
* A resource without a public IP assigned can communicate outbound. Its address is network address translated by Azure to an unpredictable public address, by default
* Public IP address can be assigned to:
  * Virtual Machine NIC
  * Public facing Load Balancers
  * VPN Gateways
  * Application Gateways
  * Azure Firewall
  * Bastion Host
* Public IP Address SKUs
  * Basic SKU
    * No longer default
    * Assigned with static or dynamic allocation method
    * Open by default (NSGs recommended)
    * Assigned to any Azure resource that allows a Public IP
    * Do not support Availability Zones
  * Standard SKU
    * Preferred method
    * Always use static allocation
    * Secure by default and closed to all inbound traffic
    * Assigned to NICs, Standard LBs, or App GWs
    * Support Availability Zones and can be zone-redundant or zonal
* Inbound communication with a Standard SKU resource fails until you create and associate a network security group and explicitly allow the desired inbound traffic
* Virtual Network is tied to a specific region and a specific subscription

### Hybrid Connectivity

* Hybrid (local datacenter and Azure Virtual Network) connectivity options -
  * **Site-to-Site (S2S)** - Established between your on-premises VPN device and an Azure VPN Gateway that is deployed in a virtual network
  * **Point to Site (P2S)** - Established between a Azure VPN Gateway and a single computer in your network
  * **Express Route** - Established between your network and Azure Expressroute Gateway, through an ExpressRoute partner. This connection is private. Traffic does not go over the internet
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
  * While traffic that travels over an ExpressRoute circuit is not encrypted by default, it is possible to create a solution that allows you to send encrypted traffic over an ExpressRoute circuit
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


## Azure Bastion

* Azure Bastion is a fully managed platform PaaS service from Azure that is hardened internally to provide you secure RDP/SSH connectivity
* Azure Bastion is deployed per virtual network
* Workings of Azure Bastion
  * The Bastion host is deployed in the virtual network
  * The user connects to the Azure portal using any HTML5 browser
  * The user selects the virtual machine to connect to
  * With a single click, the RDP/SSH session opens in the browser
  * No public IP is required on the Azure VM.
* NSGs are required on target subnets to allow RDP/SSH from Azure Bastion only
* With Azure Bastion we get RDP/SSH session over TLS on port 443 enabling you to traverse corporate firewalls securely
* Azure Bastion is deployed in a dedicated subnet which must be named as AzureBastionSubnet. This subnet must be at least /27 or larger
* Azure Bastion needs a static public IP (Standard SKU)

## Azure Load Balancer

* Azure Load Balancer operates at layer four of the Open Systems Interconnection (OSI) model
* Azure load balancer can be public or internal depending on whether a public or private IP is selected respectively
* By default, Load balancer uses a Five-tuple hash. The hash includes:
  * Source IP address
  * Source port (changes for each new flow from the same source IP)
  * Destination IP address
  * Destination port
  * IP protocol number to map flows to available servers
* Affinity to a source IP address is created by using a two or three-tuple hash
* Packets of the same flow arrive on the same instance behind the load-balanced front end
* Azure Load Balancer has an idle timeout setting of 4 minutes to 30 minutes. By default, it is set to 4 minutes. To keep the session alive, use TCP keep-alive

## Azure Firewall

* Azure Firewall is a managed next-generation firewall that offers network address translation (NAT)
* Azure Firewall bases packet filtering on Internet Protocol (IP) addresses and Transmission Control Protocol and User Datagram Protocol (TCP/UDP) ports, or on application-based HTTP(S) or SQL attributes
* Azure Firewall also leverages Microsoft threat intelligence to identify malicious IP addresses
* Use Azure Firewall alone when there are no web applications in the virtual network
* Azure Firewall in front of Application Gateway when you want Azure Firewall to inspect and filter traffic before it reaches the Application Gateway
* When used behind an Application Gateway, it doesn't do any SNAT as the traffic is coming from and going to a private IP. Therefore User Define Route (UDR) is required to route the traffic through the firewall
* A VPN gateway or ExpressRoute gateway sits in front of Azure Firewall and/or Application Gateway, when the clients are on the on-premise network
* Even if all clients are located on-premises or in Azure, both the Azure Application Gateway and the Azure Firewall need to have public IP addresses, so that Microsoft can manage the services
* In a hub and spoke architecture, Azure Firewall, Application Gateway, and API Management gateway components uasually all go to the hub virtual network
* Can be used with Kubernetes


## Application Gateway

* Azure Application Gateway is a managed web traffic load balancer and HTTP(S) full reverse proxy that can do secure socket layer (SSL) encryption and decryption
* Application Gateway can make routing decisions based on additional attributes of an HTTP request, for example URI path or host headers. This type of routing is known as application layer (OSI layer 7) load balancing
* Application Gateway also uses Web Application Firewall to inspect web traffic and detect attacks at the HTTP layer
* Azure Application Gateway can be used as an internal application load balancer or as an internet-facing application load balancer. An internet-facing application gateway uses public IP addresses
* Azure Web Application Firewall (WAF) on top of Azure Application Gateway is a security-hardened device with a limited attack surface that operates facing the public internet
* Application Gateway doesn't act as a routing device with NAT, but behaves as a full reverse application proxy
* Application Gateway terminates the web session from the client, and establishes a separate session with one of its backend servers
* Use Application Gateway alone when there are only web applications in the virtual network, and network security groups (NSGs) provide sufficient output filtering
* Azure Firewall and Application Gateway in parallel, the most common design, when you want Azure Application Gateway to protect HTTP(S) applications from web attacks, and Azure Firewall to protect all other workloads and filter outbound traffic
* Application Gateway in front of Azure Firewall when you want Azure Firewall to inspect all traffic and WAF to protect web traffic, and the application needs to know the client's source IP address
* Application Gateway in front of Azure Firewall captures the incoming packet's source IP address in the X-forwarded-for header. The source IP may be important to the backend servers in providing geolocation based services
* Can be used with Kubernetes
* Integrate reverse proxy services like API Management gateway with Application Gateway to provide functionality like API throttling or authentication proxy
* An application gateway inserts four additional headers to all requests before it forwards the requests to the backend. These headers are x-forwarded-for, x-forwarded-proto, x-forwarded-port, and x-original-host
* X-original-host header contains the original host header with which the request arrived
* You can configure application gateway to modify request and response headers and URL by using Rewrite HTTP headers and URL or to modify the URI path by using a path-override setting. However, unless configured to do so, all incoming requests are proxied to the backend
* If session affinity is enabled as an option, then it adds a gateway-managed affinity cookie
* Application Gateway or WAF deployments under the autoscaling SKU can scale up or down based on changing traffic load patterns. Autoscaling also removes the requirement to choose a deployment size or instance count during provisioning
* An Application Gateway or WAF deployment can span multiple Availability Zones, removing the need to provision separate Application Gateway instances in each zone with a Traffic Manager
* Application Gateway v2 supports integration with Key Vault for server certificates that are attached to HTTPS enabled listeners
* Application Gateway provides native support for WebSocket across all gateway sizes
* To establish a WebSocket connection, a specific HTTP-based handshake is exchanged between the client and the server. If successful, the application-layer protocol is "upgraded" from HTTP to WebSockets, using the previously established TCP connection. Once this occurs, HTTP is completely out of the picture; data can be sent or received using the WebSocket protocol by both endpoints, until the WebSocket connection is closed
* WebSocket has low overhead unlike HTTP and can reuse the same TCP connection for multiple request/responses resulting in a more efficient utilization of resources. WebSocket protocols are designed to work over traditional HTTP ports of 80 and 443
* You can use application gateway to redirect traffic. It has a generic redirection mechanism which allows for redirecting traffic received at one listener to another listener or to an external site
* A common redirection scenario for many web applications is to support automatic HTTP to HTTPS redirection to ensure all communication between application and its users occurs over an encrypted path
* The following types of redirection are supported:
  * 301 Permanent Redirect
  * 302 Found
  * 303 See Other
  * 307 Temporary Redirect
* Application Gateway redirection support offers the following capabilities:
  * Global redirection - Redirects from one listener to another listener on the gateway. This enables HTTP to HTTPS redirection on a site.
  * Path-based redirection - This type of redirection enables HTTP to HTTPS redirection only on a specific site area, for example a shopping cart area denoted by /cart/*.
  * Redirect to external site - With this change, customers need to create a new redirect configuration object, which specifies the target listener or external site to which redirection is desired. The configuration element also supports options to enable appending the URI path and query string to the redirected URL
* Advantages of TLS termination at the Gateway:
  * Improved performance – The biggest performance hit when doing TLS decryption is the initial handshake. To improve performance, the server doing the decryption caches TLS session IDs and manages TLS session tickets. If this is done at the application gateway, all requests from the same client can use the cached values. If it’s done on the backend servers, then each time the client’s requests go to a different server the client must re‑authenticate. The use of TLS tickets can help mitigate this issue, but they are not supported by all clients and can be difficult to configure and manage
  * Better utilization of the backend servers – SSL/TLS processing is very CPU intensive, and is becoming more intensive as key sizes increase. Removing this work from the backend servers allows them to focus on what they are most efficient at, delivering content
  * Intelligent routing – By decrypting the traffic, the application gateway has access to the request content, such as headers, URI, and so on, and can use this data to route requests
  * Certificate management – Certificates only need to be purchased and installed on the application gateway and not all backend servers. This saves both time and money
* For the TLS connection to work, you need to ensure that the TLS/SSL certificate meets the following conditions:
  * That the current date and time is within the "Valid from" and "Valid to" date range on the certificate
  * That the certificate's "Common Name" (CN) matches the host header in the request. For example, if the client is making a request to https://www.contoso.com/, then the CN must be www.contoso.com
* You may not want unencrypted communication to the backend servers. You may have security requirements, compliance requirements, or the application may only accept a secure connection. Azure Application Gateway has end-to-end TLS encryption to support these requirements
* When configured with end-to-end TLS communication mode, Application Gateway terminates the TLS sessions at the gateway and decrypts user traffic. It then applies the configured rules to select an appropriate backend pool instance to route traffic to. Application Gateway then initiates a new TLS connection to the backend server and re-encrypts data using the backend server's public key certificate before transmitting the request to the backend. Any response from the web server goes through the same process back to the end user


## Azure Front Door

* If Azure Firewall is used in front of the Application Gateway to filter the maliscious traffic, the source client IP can be injected in the client request by placing Azure Front Door in front of the firewall
* Azure Front Door functionality partly overlaps with Azure Application Gateway. For example, both services offer web application firewalling, SSL offloading, and URL-based routing. One main difference is that while Azure Application Gateway is inside a virtual network, Azure Front Door is a global, decentralized service
* In some situations, you can simplify virtual network design by replacing Application Gateway with a decentralized Azure Front Door

## API Management Gateway


## Traffic Manager

* Azure Traffic Manager is a DNS-based traffic load balancer that enables you to distribute traffic optimally to services across global Azure regions
* Traffic Manager uses DNS to direct client requests to the most appropriate service endpoint based on a traffic-routing method and the health of the endpoints
* Using a CNAME record with the domain name registrar, the DNS queris for the given domain name need to be routed to traffic manager
* Traffic Manager is resilient to failure, including the failure of an entire Azure region
* Traffic Manager improves application responsiveness by directing traffic to the endpoint with the lowest network latency for the client
* Azure Traffic Manager supports six traffic-routing methods to determine how to route network traffic to the various service endpoints
  * **Priority** - Select Priority when you want to use a primary service endpoint for all traffic, and provide backups in case the primary or the backup endpoints are unavailable
  * **Weighted** - Select Weighted when you want to distribute traffic across a set of endpoints, either evenly or according to weights, which you define. Following are some use cases:
    * **Gradual application upgrade** - Allocate a percentage of traffic to route to a new endpoint, and gradually increase the traffic over time to 100%.
    * **Application migration to Azure** - Create a profile with both Azure and external endpoints. Adjust the weight of the endpoints to prefer the new endpoints.
    * **Cloud-bursting for additional capacity** - Quickly expand an on-premises deployment into the cloud by putting it behind a Traffic Manager profile. When you need extra capacity in the cloud, you can add or enable more endpoints and specify what portion of traffic goes to each endpoint.
  * **Performance** - Select Performance when you have endpoints in different geographic locations and you want end users to use the "closest" endpoint in terms of the lowest network latency
  * **Geographic** - Select Geographic so that users are directed to specific endpoints (Azure, External, or Nested) based on which geographic location their DNS query originates from. This empowers Traffic Manager customers to enable scenarios where knowing a user’s geographic region and routing them based on that is important. Examples include complying with data sovereignty mandates, localization of content & user experience and measuring traffic from different regions
  * **Multivalue** - Select MultiValue for Traffic Manager profiles that can only have IPv4/IPv6 addresses as endpoints. When a query is received for this profile, all healthy endpoints are returned. Use case:
    * The Multivalue traffic-routing method allows you to get multiple healthy endpoints in a single DNS query response. This enables the caller to do client-side retries with other endpoints in the event of a returned endpoint being unresponsive. This pattern can increase the availability of a service and reduce the latency associated with a new DNS query to obtain a healthy endpoint. MultiValue routing method works only if all the endpoints of type ‘External’ and are specified as IPv4 or IPv6 addresses
  * **Subnet** - Select Subnet traffic-routing method to map sets of end-user IP address ranges to a specific endpoint within a Traffic Manager profile. When a request is received, the endpoint returned will be the one mapped for that request’s source IP address. Use case:
    * Subnet routing can be used to deliver a different experience for users connecting from a specific IP space. For example, using subnet routing, a customer can make all requests from their corporate office be routed to a different endpoint where they might be testing an internal only version of their app. Another scenario is if you want to provide a different experience to users connecting from a specific ISP (For example, block users from a given ISP)
* A single Traffic Manager profile can use only one traffic routing method. You can select a different traffic routing method for your profile at any time. Changes are applied within one minute, and no downtime is incurred
* Traffic-routing methods can be combined by using nested Traffic Manager profiles. Nesting enables sophisticated and flexible traffic-routing configurations that meet the needs of larger, complex applications
* Traffic Manager does not receive DNS queries directly from clients. Rather, DNS queries come from the recursive DNS service that the clients are configured to use. Therefore, the IP address used to determine the 'closest' endpoint is not the client's IP address, but it is the IP address of the recursive DNS service. In practice, this IP address is a good proxy for the client
* Since a region can be mapped only to one endpoint, Traffic Manager returns it regardless of whether the endpoint is healthy or not. It is strongly recommended that customers using the geographic routing method associate it with the Nested type endpoints that has child profiles containing at least two endpoints within each
* MinChildEndpoints - Below this threshold, the parent profile considers the entire child profile to be unavailable and directs traffic to the other endpoints
* Endpoint Types
  * **Azure endpoints** are used for services hosted in Azure
  * **External endpoints** are used for IPv4/IPv6 addresses, FQDNs, or for services hosted outside Azure that can either be on-premises or with a different hosting provider
  * **Nested endpoints** are used to combine Traffic Manager profiles to create more flexible traffic-routing schemes to support the needs of larger, more complex deployments
* There is no restriction on how endpoints of different types are combined in a single Traffic Manager profile. Each profile can contain any mix of endpoint types
* Only Web Apps at the 'Standard' SKU or above are eligible for use with Traffic Manager
* When an endpoint receives an HTTP request, it uses the 'host' header in the request to determine which Web App should service the request. The host header contains the DNS name used to initiate the request, for example 'contosoapp.azurewebsites.net'
* Each Traffic Manager profile can have at most one Web App endpoint from each Azure region. To work around for this constraint, you can configure a Web App as an External endpoint
* Nested endpoints combine multiple Traffic Manager profiles to create flexible traffic-routing schemes and support the needs of larger, complex deployments. With Nested endpoints, a 'child' profile is added as an endpoint to a 'parent' profile. Both the child and parent profiles can contain other endpoints of any type, including other nested profiles
* Traffic Manager allows you to configure the TTL used in Traffic Manager DNS responses for DN response caching by clients


## Azure Monitor


## Security Center


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

## Azure Event Hub

* Event publishers can publish events using HTTPS or AMQP 1.0 or Apache Kafka (1.0 and above)
* All Event Hubs consumers connect via the AMQP 1.0 session. All Kafka consumers connect via the Kafka protocol 1.0 and later
* Kafka `Cluster` is equivalent to EventHub `Namespace`
* Scale in Event Hubs is controlled by the number of `throughput units` provisioned. A single throughput lets you:
  * Ingress: Up to 1 MB per second or 1000 events per second (whichever comes first)
  * Egress: Up to 2 MB per second or 4096 events per second
* Beyond the capacity of the purchased throughput units, ingress is throttled and a ServerBusyException is returned. Egress does not produce throttling exceptions, but is still limited to the capacity of the purchased throughput units
* Up to 20 throughput units can be purchased for an Event Hubs namespace and are shared across all event hubs in that namespace
* Event Hubs can automatically scale up throughput units when the throughput limit is reahed if the `Auto-Inflate` feature is used
* With Event Hub, it is possible to write with any of the three supported protocols and read with any another
* Unlike Kafka, Log compaction is not supported by Event Hub (Cosmos DB should be used for such requirements)
* Event Hubs `Capture` enables specifying an Azure Blob storage account and container, or an Azure Data Lake Storage account, which are used to store the captured data beyond the Event Hub retention period
* Captured data is written in Apache Avro format
* Event Hubs Capture enables setting up a window to control capturing. This window is a minimum size and time configuration with a "first wins policy," meaning that the first trigger encountered causes a capture operation. If there is a fifteen-minute, 100 MB capture window and 1 MB worth of data is sent per second, the size window triggers before the time window
* Each partition captures independently and writes a completed block blob at the time of capture, named for the time at which the capture interval was encountered
* The storage naming convention is as follows:
```
{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}

https://mystorageaccount.blob.core.windows.net/mycontainer/mynamespace/myeventhub/0/2017/12/08/03/03/17.avro
```
* In the event that the Azure storage blob is temporarily unavailable, Event Hubs Capture will retain the data for the data retention period configured on the event hub and back fill the data once the storage account is available again
* Event Hubs writes empty files when there is no data
* Event Hubs Capture is metered similarly to throughput units: as an hourly charge. The charge is directly proportional to the number of throughput units purchased for the namespace
* Retention period:
  * The default value and shortest possible retention period is 1 day (24 hours)
  * For Event Hubs Standard, the maximum retention period is 7 days
  * For Event Hubs Dedicated, the maximum retention period is 90 days
  * If the retention period is changed, it applies to all messages including messages that are already in the event hub
* The number of partitions is specified at creation and must be between 1 and 32 in Event Hubs Standard. The partition count can be up to 2000 partitions per Capacity Unit in Event Hubs Dedicated
* If you don't specify a partition key when publishing an event, a round-robin assignment is used
* Azure Storage Blob is used as a checkpoint store
* By default, the function that processes the events is called sequentially for a given partition. Subsequent events and calls to this function from the same partition queue up behind the scenes as the event pump continues to run in the background on other threads. Events from different partitions can be processed concurrently and any shared state that is accessed across partitions have to be synchronized
* If high availability is most important, it's better not to target a specific partition (using partition ID/key). Using partition ID/key downgrades the availability of an event hub to partition-level because in the absence of a partition key Event Hub sends the event to a different partition if the first attempted partition is unavailable

## ARM Template

* Use parameters for settings that vary according to the environment, like SKU, size, or capacity
* We recommend running the ARM test toolkit and the what-if operation on your templates before deploying them
  * The test toolkit checks whether your template uses best practices. It provides warnings when it identifies changes that could improve how you've implemented your template
  * The what-if operation shows the changes your template will make to your environment. You can see unintended changes before they're deployed. What-if also returns any errors it can detect during preflight validation. For example, if your template contains a syntactical error, it returns that error. It also returns any errors it can determine about the final state of the deployed resources. For example, if your template deploys a storage account with a name that is already in use, what-if returns that error
* Use the copy element to specify more than one instance. You can use copy on resources, properties, variables, and outputs
* Yes, they can be used across subscriptions as long as the user has read access to the template spec. Template specs can't be used across tenants
* You can include Azure PowerShell or Azure CLI scripts in your templates
* If you need to run a script on a host operating system in a VM, then the custom script extension and/or DSC would be a better choice. However, deployment scripts have advantages, such as setting the timeout duration
* When deploying your resources, you specify that the deployment is either an incremental update or a complete update
* The default mode is incremental
* For both modes, Resource Manager tries to create all resources specified in the template. If the resource already exists in the resource group and its settings are unchanged, no operation is taken for that resource. If you change the property values for a resource, the resource is updated with those new values. If you try to update the location or type of an existing resource, the deployment fails with an error
* In complete mode, Resource Manager deletes resources that exist in the resource group but aren't specified in the template
* What-if shows you which resources will be created, deleted, or modified. Use what-if to avoid unintentionally deleting resources
* Sections of template:
  * $schema - required
  * contentVersion - required
  * apiProfile - optional
  * parameters - optioanl
  * variables - optional
  * functions - optional
  * resources - required
  * outputs - optional
* linked template refers to a separate template file that is referenced via a link from the main template
* nested template to refer to embedded template syntax within the main template
* To link a template, add a deployments resource to your main template. In the templateLink property, specify the URI of the template to include
* By default, Resource Manager creates the resources in parallel. It applies no limit to the number of resources deployed in parallel, other than the total limit of 800 resources in the template. The order in which they're created isn't guaranteed
* To serially deploy more than one instance of a resource, set mode to serial and batchSize to the number of instances to deploy at a time. With serial mode, Resource Manager creates a dependency on earlier instances in the loop, so it doesn't start one batch until the previous batch completes
* You specify that a resource is deployed after another resource by using the dependsOn element. To deploy a resource that depends on the collection of resources in a loop, provide the name of the copy loop in the dependsOn element


## Script

### Deploy A Simple Web Server

```
#!/bin/bash

sudo apt upgrade -y
sudo apt install apache2 -y
sudo ufw allow 'Apache'
cd /var/www/html
echo "<html><h1>Hello AWS Study - Welcome To My Webpage</h1><body>`hostnamectl`</body></html>" > index.html

```

### Install CNI Plugin for Installing Kubernetes

```
#!/bin/bash

sudo apt upgrade -y
curl https://raw.githubusercontent.com/Azure/azure-container-networking/v1.1.7/scripts/install-cni-plugin.sh > install-cni-plugin.sh
chmod +x install-cni-plugin.sh
sudo ./install-cni-plugin.sh v1.1.7 v0.8.7

```

### Test ARM Template

#### ARM Test Toolkit

Download ARM Test Toolkit: https://aka.ms/arm-ttk-latest

```
cd arm-ttk
Get-ChildItem *.ps1, *.psd1, *.ps1xml, *.psm1 -Recurse | Unblock-File
Import-Module ./arm-ttk.psd1
Test-AzTemplate -TemplatePath /path/to/template
```

#### ARM Validation with WhatIf

```
Install-Module -Name Az -Force
```

```
Connect-AzAccount
```

```
New-AzResourceGroup `
  -Name rg-kube-dev-001 `
  -Location eastus

New-AzResourceGroupDeployment `
  -Whatif `
  -ResourceGroupName rg-kube-dev-001 `
  -TemplateUri "D:\gitrepo\kubernetes-study\lab\arm\azureDeploy.json"
```