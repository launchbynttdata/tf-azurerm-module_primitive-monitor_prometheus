# tf-azurerm-module_primitive-monitor_prometheus

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This terraform module provisions prometheus data collection from a target AKS cluster to a destination Azure Monitor workspace

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. _THIS STEP APPLIES ONLY TO MICROSOFT AZURE. IF YOU ARE USING A DIFFERENT PLATFORM PLEASE SKIP THIS STEP._ The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.113.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_alert_prometheus_rule_group.default_kubernetes_recording_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.default_node_recording_rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_alert_prometheus_rule_group.rule_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_prometheus_rule_group) | resource |
| [azurerm_monitor_data_collection_endpoint.dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint) | resource |
| [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#input\_data\_collection\_endpoint\_name) | Name of the data collection endpoint to create for prometheus | `string` | n/a | yes |
| <a name="input_data_collection_rule_name"></a> [data\_collection\_rule\_name](#input\_data\_collection\_rule\_name) | Name of the data collection rule to create for prometheus | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to create the data collection in | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to create the data collection in | `string` | n/a | yes |
| <a name="input_monitor_workspace_id"></a> [monitor\_workspace\_id](#input\_monitor\_workspace\_id) | ID of the Azure Monitor workspace to send data to | `string` | n/a | yes |
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | ID of the AKS cluster to collect data from | `string` | n/a | yes |
| <a name="input_enable_default_rule_groups"></a> [enable\_default\_rule\_groups](#input\_enable\_default\_rule\_groups) | Enable default recording rules for prometheus | `bool` | `true` | no |
| <a name="input_default_rule_group_interval"></a> [default\_rule\_group\_interval](#input\_default\_rule\_group\_interval) | Interval to run default recording rules in ISO 8601 format (between PT1M and PT15M) | `string` | `"PT1M"` | no |
| <a name="input_default_rule_group_naming"></a> [default\_rule\_group\_naming](#input\_default\_rule\_group\_naming) | Resource ames for the default recording rules | `map(string)` | <pre>{<br>  "kubernetes_recording": "DefaultKubernetesRecordingRuleGroup",<br>  "node_recording": "DefaultNodeRecordingRuleGroup"<br>}</pre> | no |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | map(object({<br>  enabled     = Whether or not the rule group is enabled<br>  description = Description of the rule group<br>  interval    = Interval to run the rule group in ISO 8601 format (between PT1M and PT15M)<br><br>  recording\_rules = list(object({<br>    name       = Name of the recording rule<br>    enabled    = Whether or not the recording rule is enabled<br>    expression = PromQL expression for the time series value<br>    labels     = Labels to add to the time series<br>  }))<br><br>  alert\_rules = list(object({<br>    name = Name of the alerting rule<br>    action = optional(object({<br>      action\_group\_id = ID of the action group to send alerts to<br>    }))<br>    enabled    = Whether or not the alert rule is enabled<br>    expression = PromQL expression to evaluate<br>    for        = Amount of time the alert must be active before firing, represented in ISO 8601 duration format (i.e. PT5M)<br>    labels     = Labels to add to the alerts fired by this rule<br>    alert\_resolution = optional(object({<br>      auto\_resolved   = Whether or not to auto-resolve the alert after the condition is no longer true<br>      time\_to\_resolve = Amount of time to wait before auto-resolving the alert, represented in ISO 8601 duration format (i.e. PT5M)<br>    }))<br>    severity    = Severity of the alert, between 0 and 4<br>    annotations = Annotations to add to the alerts fired by this rule<br>  })) | <pre>map(object({<br>    enabled     = bool<br>    description = string<br>    interval    = string<br><br>    recording_rules = list(object({<br>      name       = string<br>      enabled    = bool<br>      expression = string<br>      labels     = map(string)<br>    }))<br><br>    alert_rules = list(object({<br>      name = string<br>      action = optional(object({<br>        action_group_id = string<br>      }))<br>      enabled    = bool<br>      expression = string<br>      for        = optional(string)<br>      labels     = map(string)<br>      alert_resolution = optional(object({<br>        auto_resolved   = optional(bool)<br>        time_to_resolve = optional(string)<br>      }))<br>      severity    = optional(number)<br>      annotations = map(string)<br>    }))<br><br>    tags = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the Prometheus data collection | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_rule_group_ids"></a> [default\_rule\_group\_ids](#output\_default\_rule\_group\_ids) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_default_rule_group_names"></a> [default\_rule\_group\_names](#output\_default\_rule\_group\_names) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_rule_group_ids"></a> [rule\_group\_ids](#output\_rule\_group\_ids) | Resource IDs of the user-defined rule groups created for prometheus |
| <a name="output_rule_group_names"></a> [rule\_group\_names](#output\_rule\_group\_names) | Resource IDs of the user-defined rule groups created for prometheus |
| <a name="output_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#output\_data\_collection\_endpoint\_id) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#output\_data\_collection\_endpoint\_name) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_rule_id"></a> [data\_collection\_rule\_id](#output\_data\_collection\_rule\_id) | Resource ID of the data collection rule created for prometheus |
| <a name="output_data_collection_rule_name"></a> [data\_collection\_rule\_name](#output\_data\_collection\_rule\_name) | Resource ID of the data collection rule created for prometheus |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
