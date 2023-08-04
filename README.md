# Deploy Landing Zone

Create a file /Landing_Zones/terraform.tfvars

connectivity_subscription = "<your connectivity subscription>"

Modify your settings in the file Landing_Zone\settings.connectivity.tf

Authenticate to azure using az login

Initialize your terraform modules: 

Go into the folder  /Landing_Zone using your command line interface application then launch the following command to initialize  your terraform repo (using local tfstate)

terraform init -reconfigure

Preview your deployment: 

terraform plan -var-file="terraform.tfvars"

Deploy the connectivity infrastructure for the landing zone: 

terraform apply -var-file="terraform.tfvars"

# Deploy AI Workloads

Go into the folder Workload/AI

Create a file Workload/AI/terraform.tfvars

connectivity_subscription = "<your connectivity subscription>"
ai_subscription = "<your connectivity subscription>"
hub_vnet_id = "<copy the id of your hub vnet deployed during the landing zone>"

Use same steps as above to deploy the AI Workloads.

# Configure APIM

You can use the following Policy to test OpenAI API behind APIM

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


