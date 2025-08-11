# Azure Terraform Project: QuoteAPI

This project deploys a secure, production-ready Quote API on Azure with Essential-Eight security controls implemented. The architecture includes Container Apps, PostgreSQL database, Application Gateway with WAF, and comprehensive monitoring.

## Prerequisites

### Azure CLI Setup
1. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. Login to Azure:
   ```bash
   az login
   ```
3. Set your subscription (if you have multiple):
   ```bash
   az account set --subscription "your-subscription-id"
   ```

### Required Tools
- **Terraform** >= 1.5: https://www.terraform.io/downloads
- **Make** (for simplified deployment)
- **Azure CLI** >= 2.45.0

### Azure Requirements
- Active Azure subscription with sufficient quota
- Contributor permissions on the subscription
- Available regions: Australia East (default), East US, West Europe

## Quick Deployment

### One-Command Bootstrap
Deploy the entire infrastructure with a single command:

```bash
make deploy
```

This command will:
1. Format Terraform code
2. Initialize Terraform
3. Validate configuration
4. Run security checks (tfsec)
5. Plan the deployment
6. Apply the configuration

### Manual Deployment Steps
If you prefer manual deployment:

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve

# To destroy when done
terraform destroy -auto-approve
```

## Architecture Components

- **Network**: Virtual Network with subnets for apps, database, and Application Gateway
- **Compute**: Azure Container Apps with managed identity
- **Database**: PostgreSQL Flexible Server with private endpoints
- **Gateway**: Application Gateway v2 with WAF protection
- **Security**: Key Vault, Log Analytics, and diagnostic settings
- **Monitoring**: Azure Monitor with alerts and dashboards

## Cost Notes

**Estimated Monthly Costs (Australia East):**
- Application Gateway WAF v2: ~$300-500/month
- Container Apps (2 instances): ~$100-200/month
- PostgreSQL Flexible Server (Standard_B2s): ~$150-300/month
- Log Analytics: ~$50-100/month
- Network components: ~$50-100/month

**Total Estimated Cost: $650-1200/month**

**Cost Optimization Tips:**
- Use smaller SKUs for development/testing
- Consider Azure Container Instances for dev environments
- Monitor usage with Azure Cost Management
- Use Azure Reserved Instances for production workloads

## Essential-Eight Controls Implementation

| Control | Implemented | Implementation Details |
|---------|-------------|----------------------|
| **Patch Applications** | ✅ Yes | Container images updated via CI/CD pipeline |
| **Patch OS** | ✅ Yes | Managed by Azure Container Apps platform |
| **Configure MS Office** | ❌ N/A | Not applicable for API workloads |
| **User Application Hardening** | ✅ Yes | WAF rules, NSGs, secure configurations |
| **Restrict Admin Privileges** | ✅ Yes | RBAC, managed identities, least privilege |
| **Multi-Factor Authentication** | ✅ Yes | Azure AD integration, conditional access |
| **Backup Data** | ✅ Yes | Automated PostgreSQL backups, geo-redundant |
| **Application Whitelisting** | ✅ Yes | Network security groups, WAF allowlists |

### Security Features
- **Network Security**: Private subnets, NSGs, private endpoints
- **Application Security**: WAF with OWASP rules, HTTPS enforcement
- **Identity Security**: Managed identities, RBAC, Azure AD integration
- **Data Security**: Encryption at rest/transit, Key Vault secrets
- **Monitoring**: Comprehensive logging, alerting, and diagnostics

## Testing the Deployment

After successful deployment:

1. **Get the public IP address:**
   ```bash
   terraform output public_ip_address
   ```

2. **Test the API endpoint:**
    Navigate to the following folder and run the curl command
   ```bash
    
    curl --cacert /terraform/modules/gateway/certificates/root.cer \
    --resolve 'secure-api-test.com.au:443:<public_ip_address>' \
    -H "Host: secure-api-test.com.au" \
    https://secure-api-test.com.au/api/quotes
    
   ```

3. **Check Log Analytics:**
   - Navigate to Azure Portal > Log Analytics Workspace
   - Review diagnostic logs and metrics

## Troubleshooting

### Common Issues
- **SSL Certificate Errors**: Ensure the certificate password is set correctly
- **Network Connectivity**: Verify NSG rules and private endpoints
- **Container App Issues**: Check logs in Azure Container Apps console

### Useful Commands
```bash
# Check deployment status
terraform show

# View logs
az containerapp logs show --name aca-quote-api --resource-group rg-quote-api

# Check Application Gateway health
az network application-gateway show --name appgw-aca-quote-api --resource-group rg-appgw
```

## Cleanup

To remove all resources and avoid ongoing charges:

```bash
make destroy
```

Or manually:
```bash
terraform destroy -auto-approve
```

## Support

For issues or questions:
- Check Azure Container Apps logs
- Review Application Gateway diagnostics
- Examine Log Analytics workspace for errors
- Verify network connectivity and firewall rules
