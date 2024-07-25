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

variable "data_collection_endpoint_name" {
  description = "Name of the data collection endpoint to create for prometheus"
  type        = string
}

variable "data_collection_rule_name" {
  description = "Name of the data collection rule to create for prometheus"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the data collection in"
  type        = string
}

variable "location" {
  description = "Azure region to create the data collection in"
  type        = string
}

variable "monitor_workspace_id" {
  description = "ID of the Azure Monitor workspace to send data to"
  type        = string
}

variable "aks_cluster_id" {
  description = "ID of the AKS cluster to collect data from"
  type        = string
}

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

variable "default_rule_group_naming" {
  description = "Resource ames for the default recording rules"
  type        = map(string)
  default = {
    node_recording       = "DefaultNodeRecordingRuleGroup"
    kubernetes_recording = "DefaultKubernetesRecordingRuleGroup"
  }
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
