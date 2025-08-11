# Azure Terraform Infrastructure as Code - Secure Azure Container Apps API

🚀 **Production-ready Azure infrastructure with Essential-Eight security controls**

## Overview

This repository contains a complete Infrastructure as Code (IaC) solution for deploying a secure, scalable Azure Container Apps API (Quotes) on Microsoft Azure. Built with Terraform, this project implements industry-leading security practices and follows the Essential-Eight cybersecurity framework.

## ✨ Key Features

- **🔒 Essential-Eight Compliant**: Implements all applicable Essential-Eight security controls
- **🏗️ Modular Architecture**: Clean, reusable Terraform modules for network, compute, data, and gateway
- **🛡️ Enterprise Security**: WAF, private endpoints, managed identities, and comprehensive monitoring
- **📊 Production Ready**: High availability, auto-scaling, and disaster recovery capabilities
- **💰 Cost Optimized**: Detailed cost estimates and optimization recommendations
- **🚀 One-Command Deployment**: Simple `make deploy` for complete infrastructure setup

## 🏛️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Application   │    │   PostgreSQL    │
│   Gateway WAF   │◄──►│   Container     │◄──►│   Flexible      │
│   (Public)      │    │   Apps          │    │   Server        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Virtual       │    │   Key Vault     │    │   Log Analytics │
│   Network       │    │   (Secrets)     │    │   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛡️ Security Features

| Essential-Eight Control | Status | Implementation |
|------------------------|--------|---------------|
| Patch Applications | ✅ | Container image updates via CI/CD |
| Patch OS | ✅ | Azure-managed platform updates |
| User Application Hardening | ✅ | WAF rules, NSGs, secure configs |
| Restrict Admin Privileges | ✅ | RBAC, managed identities |
| Multi-Factor Authentication | ✅ | Azure AD integration |
| Backup Data | ✅ | Automated geo-redundant backups |
| Application Whitelisting | ✅ | Network security groups, WAF |

## 🚀 Quick Start

```bash
# Prerequisites
az login
az account set --subscription "your-subscription-id"

# Deploy everything
make deploy

# Test the API
    
curl --cacert /terraform/modules/gateway/certificates/root.cer \
--resolve 'secure-api-test.com.au:443:<public_ip_address>' \
-H "Host: secure-api-test.com.au" \
https://secure-api-test.com.au/api/quotes

# Cleanup
make destroy
```

## 📊 Cost Estimates

**Monthly Costs (Australia East):**
- Application Gateway WAF v2: ~$300-500
- Container Apps: ~$100-200  
- PostgreSQL Flexible Server: ~$150-300
- Log Analytics: ~$50-100
- Network components: ~$50-100

**Total: $650-1200/month**

## 🏗️ Infrastructure Components

- **Network**: Virtual Network with isolated subnets
- **Compute**: Azure Container Apps with auto-scaling
- **Database**: PostgreSQL Flexible Server with private endpoints
- **Gateway**: Application Gateway v2 with WAF protection
- **Security**: Key Vault, managed identities, RBAC
- **Monitoring**: Log Analytics, diagnostic settings, alerts

## 📁 Project Structure

```
terraform/
├── modules/
│   ├── common/          # Shared resources (Key Vault, Log Analytics)
│   ├── network/         # Virtual network and subnets
│   ├── compute/         # Container Apps configuration
│   ├── data/           # PostgreSQL database
│   └── gateway/        # Application Gateway with WAF
├── main.tf             # Main configuration
├── variables.tf        # Input variables
├── providers.tf        # Azure provider configuration
└── README.md          # Detailed documentation
```

## 🎯 Use Cases

- **Production API Deployment**: Secure, scalable API hosting
- **DevOps Learning**: Infrastructure as Code best practices
- **Security Compliance**: Essential-Eight framework implementation
- **Azure Architecture**: Modern cloud-native patterns
- **Cost Management**: Detailed cost analysis and optimization

## 🔧 Technologies

- **Infrastructure**: Terraform, Azure Resource Manager
- **Compute**: Azure Container Apps
- **Database**: Azure PostgreSQL Flexible Server
- **Networking**: Azure Virtual Network, Application Gateway
- **Security**: Azure Key Vault, WAF, Private Endpoints
- **Monitoring**: Azure Monitor, Log Analytics

## 📚 Documentation

- [Detailed README](terraform/README.md) with step-by-step instructions
- [Cost Analysis](terraform/README.md#cost-notes) and optimization tips
- [Security Controls](terraform/README.md#essential-eight-controls-implementation) mapping
- [Troubleshooting Guide](terraform/README.md#troubleshooting)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is a demonstration project. For production use, please:
- Review and customize security configurations
- Implement proper CI/CD pipelines
- Add comprehensive testing
- Consider compliance requirements for your industry

---

**Tags**: `azure` `terraform` `infrastructure-as-code` `security` `essential-eight` `container-apps` `postgresql` `application-gateway` `waf` `monitoring` 