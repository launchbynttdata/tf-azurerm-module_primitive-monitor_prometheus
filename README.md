# tf-azurerm-module_primitive-monitor_prometheus

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This terraform module provisions prometheus data collection from a target AKS cluster to a destination Azure Monitor workspace

## Module Development

Use this repository as a standard Launch Terraform primitive module.

- Keep examples and tests aligned with code changes because they are part of the public contract.
- Preserve generated files and automation patterns from the shared skeleton unless a module-specific exception is required.
- Prefer make targets and pre-commit hooks over ad hoc commands to match CI behavior.

## Pre-Requisites

The following commands should be available on your system:

- asdf or mise
- make
- python3 (for pre-commit)

Install pinned tool versions and bootstrap dependencies from the repository root:

```
make configure
```

## Pre-Commit Hooks

This repository uses [.pre-commit-config.yaml](.pre-commit-config.yaml) to run Terraform, Go, and repository hygiene checks.

Install local hooks:

```
pre-commit install --hook-type commit-msg
```

Run all hooks manually:

```
pre-commit run --all-files
```

## Local Validation

Run the same validations used in CI:

```
make lint
make check
```

If a hook or generated file changes content (for example terraform-docs), commit the updates and rerun the checks.

## Review And Merge Process

- Open a pull request with a clear summary of functional and test-impacting changes.
- Resolve all review comments and ensure CI is green before merge.
- Keep commits focused and use conventional commit messages when possible.

## Automatic Updates

This repository receives periodic updates from the shared launch-terraform-skeleton baseline via Copier automation. Keep skeleton-managed files aligned with upstream expectations so automated updates continue to merge cleanly.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |

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
| [azurerm_monitor_data_collection_rule_association.dcra_dce](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.dcra_dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_id"></a> [aks\_cluster\_id](#input\_aks\_cluster\_id) | ID of the AKS cluster to collect data from | `string` | n/a | yes |
| <a name="input_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#input\_data\_collection\_endpoint\_name) | Name of the data collection endpoint to create for prometheus | `string` | n/a | yes |
| <a name="input_data_collection_rule_name"></a> [data\_collection\_rule\_name](#input\_data\_collection\_rule\_name) | Name of the data collection rule to create for prometheus | `string` | n/a | yes |
| <a name="input_default_rule_group_interval"></a> [default\_rule\_group\_interval](#input\_default\_rule\_group\_interval) | Interval to run default recording rules in ISO 8601 format (between PT1M and PT15M) | `string` | `"PT1M"` | no |
| <a name="input_default_rule_group_naming"></a> [default\_rule\_group\_naming](#input\_default\_rule\_group\_naming) | Resource ames for the default recording rules | `map(string)` | <pre>{<br/>  "kubernetes_recording": "DefaultKubernetesRecordingRuleGroup",<br/>  "node_recording": "DefaultNodeRecordingRuleGroup"<br/>}</pre> | no |
| <a name="input_enable_default_rule_groups"></a> [enable\_default\_rule\_groups](#input\_enable\_default\_rule\_groups) | Enable default recording rules for prometheus | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region to create the data collection in | `string` | n/a | yes |
| <a name="input_monitor_workspace_id"></a> [monitor\_workspace\_id](#input\_monitor\_workspace\_id) | ID of the Azure Monitor workspace to send data to | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to create the data collection in | `string` | n/a | yes |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | map(object({<br/>  enabled     = Whether or not the rule group is enabled<br/>  description = Description of the rule group<br/>  interval    = Interval to run the rule group in ISO 8601 format (between PT1M and PT15M)<br/><br/>  recording\_rules = list(object({<br/>    name       = Name of the recording rule<br/>    enabled    = Whether or not the recording rule is enabled<br/>    expression = PromQL expression for the time series value<br/>    labels     = Labels to add to the time series<br/>  }))<br/><br/>  alert\_rules = list(object({<br/>    name = Name of the alerting rule<br/>    action = optional(object({<br/>      action\_group\_id = ID of the action group to send alerts to<br/>    }))<br/>    enabled    = Whether or not the alert rule is enabled<br/>    expression = PromQL expression to evaluate<br/>    for        = Amount of time the alert must be active before firing, represented in ISO 8601 duration format (i.e. PT5M)<br/>    labels     = Labels to add to the alerts fired by this rule<br/>    alert\_resolution = optional(object({<br/>      auto\_resolved   = Whether or not to auto-resolve the alert after the condition is no longer true<br/>      time\_to\_resolve = Amount of time to wait before auto-resolving the alert, represented in ISO 8601 duration format (i.e. PT5M)<br/>    }))<br/>    severity    = Severity of the alert, between 0 and 4<br/>    annotations = Annotations to add to the alerts fired by this rule<br/>  })) | <pre>map(object({<br/>    enabled     = bool<br/>    description = string<br/>    interval    = string<br/><br/>    recording_rules = list(object({<br/>      name       = string<br/>      enabled    = bool<br/>      expression = string<br/>      labels     = map(string)<br/>    }))<br/><br/>    alert_rules = list(object({<br/>      name = string<br/>      action = optional(object({<br/>        action_group_id = string<br/>      }))<br/>      enabled    = bool<br/>      expression = string<br/>      for        = string<br/>      labels     = map(string)<br/>      alert_resolution = optional(object({<br/>        auto_resolved   = optional(bool)<br/>        time_to_resolve = optional(string)<br/>      }))<br/>      severity    = optional(number)<br/>      annotations = optional(map(string))<br/>    }))<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the Prometheus data collection | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#output\_data\_collection\_endpoint\_id) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#output\_data\_collection\_endpoint\_name) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_rule_id"></a> [data\_collection\_rule\_id](#output\_data\_collection\_rule\_id) | Resource ID of the data collection rule created for prometheus |
| <a name="output_data_collection_rule_name"></a> [data\_collection\_rule\_name](#output\_data\_collection\_rule\_name) | Resource ID of the data collection rule created for prometheus |
| <a name="output_default_rule_group_ids"></a> [default\_rule\_group\_ids](#output\_default\_rule\_group\_ids) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_default_rule_group_names"></a> [default\_rule\_group\_names](#output\_default\_rule\_group\_names) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_rule_group_ids"></a> [rule\_group\_ids](#output\_rule\_group\_ids) | Resource IDs of the user-defined rule groups created for prometheus |
| <a name="output_rule_group_names"></a> [rule\_group\_names](#output\_rule\_group\_names) | Resource IDs of the user-defined rule groups created for prometheus |
<!-- END_TF_DOCS -->
