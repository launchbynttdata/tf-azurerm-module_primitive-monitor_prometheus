// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// variables required by resource names module

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    aks_cluster = {
      name       = "aks"
      max_length = 80
    }
    data_collection_endpoint = {
      name       = "dce"
      max_length = 80
    }
    data_collection_rule = {
      name       = "dcr"
      max_length = 80
    }
    log_analytics = {
      name       = "law"
      max_length = 80
    }
    monitor_workspace = {
      name       = "amw"
      max_length = 80
    }
    resource_group = {
      name       = "rg"
      max_length = 80
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "redis"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "location" {
  description = "target resource group resource mask"
  type        = string
  default     = "eastus"
}

// variables to configure prometheus

# variable "aks_cluster_id" {
#   description = "ID of the AKS cluster to collect data from"
#   type        = string
# }

variable "enable_default_rule_groups" {
  description = "Enable default recording rules for prometheus"
  type        = bool
  default     = true
}

variable "default_rule_group_interval" {
  description = "Interval to run default recording rules in ISO 8601 format (between PT1M and PT15M)"
  type        = string
  default     = "PT1M"
}

variable "rule_groups" {
  description = <<-EOF
    map(object({
      enabled     = Whether or not the rule group is enabled
      description = Description of the rule group
      interval    = Interval to run the rule group in ISO 8601 format (between PT1M and PT15M)

      recording_rules = list(object({
        name       = Name of the recording rule
        enabled    = Whether or not the recording rule is enabled
        expression = PromQL expression for the time series value
        labels     = Labels to add to the time series
      }))

      alert_rules = list(object({
        name = Name of the alerting rule
        action = optional(object({
          action_group_id = ID of the action group to send alerts to
        }))
        enabled    = Whether or not the alert rule is enabled
        expression = PromQL expression to evaluate
        for        = Amount of time the alert must be active before firing, represented in ISO 8601 duration format (i.e. PT5M)
        labels     = Labels to add to the alerts fired by this rule
        alert_resolution = optional(object({
          auto_resolved   = Whether or not to auto-resolve the alert after the condition is no longer true
          time_to_resolve = Amount of time to wait before auto-resolving the alert, represented in ISO 8601 duration format (i.e. PT5M)
        }))
        severity    = Severity of the alert, between 0 and 4
        annotations = Annotations to add to the alerts fired by this rule
      }))
  EOF
  type = map(object({
    enabled     = bool
    description = string
    interval    = string

    recording_rules = list(object({
      name       = string
      enabled    = bool
      expression = string
      labels     = map(string)
    }))

    alert_rules = list(object({
      name = string
      action = optional(object({
        action_group_id = string
      }))
      enabled    = bool
      expression = string
      for        = string
      labels     = map(string)
      alert_resolution = optional(object({
        auto_resolved   = optional(bool)
        time_to_resolve = optional(string)
      }))
      severity    = optional(number)
      annotations = optional(map(string))
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Custom tags for the Prometheus data collection"
  type        = map(string)
  default     = {}
}
