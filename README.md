# Template for Application on Kubernetes

This repository serves as a starting point for provisioning Kubernetes infrastructure on the Freifunk Düsseldorf cluster.

## Requirements

For initial provisioning and configuration of the Terraform workspace, you need a Terraform Cloud login token. Please ask our team to provide it to you.

Required software:
- Terraform CLI
- git

## Usage

Follow these steps to get started:
1. Create a new repository in our orga, using this template. 
1. Open the repository in your favorite editor (for example VS Code)
1. Modify the workspace prefix to show your application's name
1. Modify the Kubernetes namespace to show your application's name
1. Login to Terraform Cloud (see below)
1. Create a new workspace for your application (see below)
1. Initialize the workspace (see below)
1. Apply the configuration (see below)

Command for logging in to Terraform Cloud:
```shell
terraform login
``` 
You will be asked for the token. Paste it and submit with ENTER (no input will be echoed).

Command for creating a workspace called 'dev':
```shell
terraform workspace new dev
```

Command for initializing the workspace:
```shell
terraform init
```

Command for applying your current configuration:
```shell
terraform apply
```

If everything goes well, you will be shown a Terraform apply plan that says it will create a Kubernetes namespace according to your configuration. You will have to accept the plan by typing 'yes'. 

You can then configure more resources using this namespace. Terraform will take the current configuration from your project directory. When you are satisfied with a modification, don't forget to commit your changes.

Have a lot of fun! :3
