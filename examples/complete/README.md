# complete

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_monitor_workspace"></a> [monitor\_workspace](#module\_monitor\_workspace) | terraform.registry.launch.nttdata.com/module_primitive/monitor_workspace/azurerm | ~> 1.0 |
| <a name="module_aks_cluster"></a> [aks\_cluster](#module\_aks\_cluster) | terraform.registry.launch.nttdata.com/module_primitive/kubernetes_cluster/azurerm | ~> 2.0 |
| <a name="module_monitor_prometheus"></a> [monitor\_prometheus](#module\_monitor\_prometheus) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | <pre>{<br>  "aks_cluster": {<br>    "max_length": 80,<br>    "name": "aks"<br>  },<br>  "data_collection_endpoint": {<br>    "max_length": 80,<br>    "name": "dce"<br>  },<br>  "data_collection_rule": {<br>    "max_length": 80,<br>    "name": "dcr"<br>  },<br>  "log_analytics": {<br>    "max_length": 80,<br>    "name": "law"<br>  },<br>  "monitor_workspace": {<br>    "max_length": 80,<br>    "name": "amw"<br>  },<br>  "resource_group": {<br>    "max_length": 80,<br>    "name": "rg"<br>  }<br>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"redis"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | target resource group resource mask | `string` | `"eastus"` | no |
| <a name="input_enable_default_rule_groups"></a> [enable\_default\_rule\_groups](#input\_enable\_default\_rule\_groups) | Enable default recording rules for prometheus | `bool` | `true` | no |
| <a name="input_default_rule_group_interval"></a> [default\_rule\_group\_interval](#input\_default\_rule\_group\_interval) | Interval to run default recording rules in ISO 8601 format (between PT1M and PT15M) | `string` | `"PT1M"` | no |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | map(object({<br>  enabled     = Whether or not the rule group is enabled<br>  description = Description of the rule group<br>  interval    = Interval to run the rule group in ISO 8601 format (between PT1M and PT15M)<br><br>  recording\_rules = list(object({<br>    name       = Name of the recording rule<br>    enabled    = Whether or not the recording rule is enabled<br>    expression = PromQL expression for the time series value<br>    labels     = Labels to add to the time series<br>  }))<br><br>  alert\_rules = list(object({<br>    name = Name of the alerting rule<br>    action = optional(object({<br>      action\_group\_id = ID of the action group to send alerts to<br>    }))<br>    enabled    = Whether or not the alert rule is enabled<br>    expression = PromQL expression to evaluate<br>    for        = Amount of time the alert must be active before firing, represented in ISO 8601 duration format (i.e. PT5M)<br>    labels     = Labels to add to the alerts fired by this rule<br>    alert\_resolution = optional(object({<br>      auto\_resolved   = Whether or not to auto-resolve the alert after the condition is no longer true<br>      time\_to\_resolve = Amount of time to wait before auto-resolving the alert, represented in ISO 8601 duration format (i.e. PT5M)<br>    }))<br>    severity    = Severity of the alert, between 0 and 4<br>    annotations = Annotations to add to the alerts fired by this rule<br>  })) | <pre>map(object({<br>    enabled     = bool<br>    description = string<br>    interval    = string<br><br>    recording_rules = list(object({<br>      name       = string<br>      enabled    = bool<br>      expression = string<br>      labels     = map(string)<br>    }))<br><br>    alert_rules = list(object({<br>      name = string<br>      action = optional(object({<br>        action_group_id = string<br>      }))<br>      enabled    = bool<br>      expression = string<br>      for        = string<br>      labels     = map(string)<br>      alert_resolution = optional(object({<br>        auto_resolved   = optional(bool)<br>        time_to_resolve = optional(string)<br>      }))<br>      severity    = optional(number)<br>      annotations = optional(map(string))<br>    }))<br><br>    tags = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the Prometheus data collection | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Resource group of the AKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS cluster |
| <a name="output_default_rule_group_ids"></a> [default\_rule\_group\_ids](#output\_default\_rule\_group\_ids) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_default_rule_group_names"></a> [default\_rule\_group\_names](#output\_default\_rule\_group\_names) | Resource IDs of the default rule groups created for prometheus |
| <a name="output_rule_group_ids"></a> [rule\_group\_ids](#output\_rule\_group\_ids) | Resource IDs of the user-defined rule groups created for prometheus |
| <a name="output_rule_group_names"></a> [rule\_group\_names](#output\_rule\_group\_names) | Resource IDs of the user-defined rule groups created for prometheus |
| <a name="output_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#output\_data\_collection\_endpoint\_id) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_endpoint_name"></a> [data\_collection\_endpoint\_name](#output\_data\_collection\_endpoint\_name) | Resource ID of the data collection endpoint created for prometheus |
| <a name="output_data_collection_rule_id"></a> [data\_collection\_rule\_id](#output\_data\_collection\_rule\_id) | Resource ID of the data collection rule created for prometheus |
| <a name="output_data_collection_rule_name"></a> [data\_collection\_rule\_name](#output\_data\_collection\_rule\_name) | Resource ID of the data collection rule created for prometheus |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
