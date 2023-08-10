# Azure AI Landing Zone with Terraform

![Azure AI Landing Zone](AIArchitecture.png "Azure AI Landing Zone")

This GitHub repository provides a comprehensive guide and Terraform configurations to deploy an Azure AI Landing Zone—a specialized environment for empowering AI technologies, including advanced language models like GPT-4. The landing zone is designed to complement existing data management and data landing zones within your cloud-scale data analytics platform, enabling you to unlock the true potential of AI.

## Getting Started

To deploy the Azure AI Landing Zone with Terraform, follow the steps below:

### 1. Set up Connectivity

*   Create a file `/Landing_Zones/terraform.tfvars`.
*   Replace `<your connectivity subscription>` with your actual connectivity subscription ID in the `connectivity_subscription` field.
*   Modify settings in the file `/Landing_Zone/settings.connectivity.tf` based on your requirements.
*   Authenticate to Azure using `az login`.

### 2. Initialize and Preview the Deployment

*   Open your command line interface application and navigate to the `/Landing_Zone` folder.
*   Run `terraform init -reconfigure` to initialize the Terraform repository using local state.
*   Preview the deployment by running `terraform plan -var-file="terraform.tfvars"`.

### 3. Deploy the Connectivity Infrastructure

*   Execute `terraform apply -var-file="terraform.tfvars"` to deploy the connectivity infrastructure for the landing zone.

### 4. Deploy AI Workloads

*   Navigate to the `/Workload/AI` folder.
*   Create a file `/Workload/AI/terraform.tfvars`.
*   Replace `<your connectivity subscription>` and `<your AI subscription>` with your respective subscription IDs.
*   Copy the ID of your hub VNet deployed during the landing zone and paste it in the `hub_vnet_id` field.
*   Follow the same steps as above to deploy the AI workloads.

### 5. Configure APIM

*   Use the provided policy in the README to test OpenAI API behind APIM.
*   Replace `<Your OpenAI API Key>` and `<Your OpenAI Backend Service>` with your actual API key and backend service URL.
<!--
    IMPORTANT:
    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.
    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.
    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.
    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.
    - To remove a policy, delete the corresponding policy statement from the policy document.
    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.
    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.
    - Policies are applied in the order of their appearance, from the top down.
    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.
-->
<policies>
    <inbound>
        <base />
        <set-header name="api-key" exists-action="override">
            <value> <!-- Add Your OpenAI API Key --></></value>
        </set-header>
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <rewrite-uri template="/openai/deployments/gpt-35-turbo/completions?api-version=2023-05-15" />
        <set-backend-service base-url="https://<!-- Your OpenAI Backend Service -->.privatelink.openai.azure.com" />
    </inbound>
    <backend>
        <forward-request timeout="5" />
    </backend>
    <outbound>
        <!-- Add a policy to capture and return the full response -->
        <base />
        <return-response>
            <set-status code="200" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@(context.Response.Body.As<string>())</set-body>
        </return-response>
    </outbound>
    <on-error />
</policies>
## What's Included

This repository contains Terraform configurations and settings to deploy the following components:

*   Connectivity Components:
    *   Azure Virtual Networks (Hub) for secure connectivity to on-premises systems and other spoke networks.
    *   Azure Firewall, a network-based, stateful firewall to control and inspect traffic flow in and out of the hub.
    *   Bastion, a secure remote desktop access solution for VMs in the virtual network.
    *   Jumpbox, a secure jump host to access VMs in private subnets.

*   AI Workloads:
    *   Azure Open AI, a managed AI service for running advanced language models like GPT-4.
    *   Separate Virtual Networks (Spokes) for securely hosting AI workloads.
    *   Subnets within spokes to isolate different components.
    *   Route Tables for controlling traffic flow within virtual networks.
    *   Application Gateway, a load balancer for secure access to web applications and AI services.
    *   Azure API Management as the API gateway for managing and securing APIs, including Azure Open AI.
    *   Private DNS Zones for name resolution within the virtual network and between VNets.
    *   Cosmos DB, a globally distributed, multi-model database service to support AI applications.
    *   Web applications in Azure Web App.
    *   Azure AI services for building intelligent applications.

## Configuration Tips

This GitHub repository provides a foundation for your AI Landing Zone. However, it's essential to consider additional enhancements and best practices for your specific use case. Here are some tips for further improvement:

*   Implement Managed Identity for authenticating with Azure services.
*   Integrate Azure Key Vault for centralized secrets management.
*   Explore advanced networking configurations like Azure Virtual WAN and ExpressRoute to optimize network performance and connectivity.
*   Enable SSL/TLS certificates at the Azure Application Gateway level to enhance data encryption and security.

## Contributions

Contributions to this repository are welcome! Feel free to raise issues or submit pull requests for any improvements, bug fixes, or additional features that can benefit the community.

## License

This project is licensed under the [MIT License](link_to_license). You are free to use, modify, and distribute the code as per the terms of the license.

Let's empower AI enthusiasts like you to revolutionize AI technology with Azure and Terraform. Share this repository with your network and join our community of innovators! 🌟 #AI #Azure #Terraform #CloudComputing #TechInnovation
