- @azure Rule - Use Azure Best Practices: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `azure_development-get_best_practices` tool if available.

- @terraform Rule - State Management:
  - Always use remote state storage in Azure Storage Account
  - Enable state locking to prevent concurrent access
  - Use workspaces for environment isolation
  - Implement state backup strategy

- @terraform Rule - Security Best Practices:
  - Use Azure Managed Identities for authentication where possible
  - Never store sensitive data in Terraform state
  - Use Azure Key Vault for secret management
  - Implement least privilege access for service principals
  - Use data encryption at rest and in transit

- @terraform Rule - Code Structure:
  - Follow standard Terraform file structure (main.tf, variables.tf, outputs.tf)
  - Use consistent naming conventions for resources
  - Implement proper tagging strategy for resources
  - Use modules for reusable components
  - Keep resource configurations DRY (Don't Repeat Yourself)

- @terraform Rule - Resource Management:
  - Enable soft delete for applicable resources
  - Implement proper backup and disaster recovery
  - Use resource locks for critical resources
  - Implement proper monitoring and logging
  - Consider cost optimization in resource configurations

- @terraform Rule - Validation:
  - Use terraform validate before applying changes
  - Implement pre-commit hooks for code validation
  - Use terraform fmt for consistent formatting
  - Test configurations in a development environment first
  - Document all variables and outputs thoroughly

- @azure Rule - Compliance:
  - Follow Azure landing zone principles
  - Implement proper resource organization (Management Groups, Subscriptions, Resource Groups)
  - Enable Azure Policy for governance
  - Use Azure Monitor for monitoring and alerting
  - Implement proper RBAC (Role-Based Access Control)