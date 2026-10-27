# EpicBook Infrastructure Automation

Infrastructure repository for Assignment 04.

## Directories

- bootstrap/: Terraform setup for the Azure pipeline-agent VM,
  its networking, and Terraform remote-state storage.
- terraform/: EpicBook infrastructure deployed through Azure DevOps.

## Deployment approach

1. Prepare bootstrap infrastructure from the local Ubuntu WSL terminal.
2. Register the self-hosted agent with Azure DevOps.
3. Configure protected Terraform remote state.
4. Run the Infrastructure Pipeline to provision EpicBook resources.
5. Manually transfer approved non-sensitive outputs to the application repository.

Do not commit credentials, private keys, Terraform state, or saved plans.
