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


output "default_rule_group_ids" {
  description = "Resource IDs of the default rule groups created for prometheus"
  value = {
    "node_recording"       = azurerm_monitor_alert_prometheus_rule_group.default_node_recording_rule_group.id
    "kubernetes_recording" = azurerm_monitor_alert_prometheus_rule_group.default_kubernetes_recording_rule_group.id
  }
}

output "default_rule_group_names" {
  description = "Resource IDs of the default rule groups created for prometheus"
  value = {
    "node_recording"       = azurerm_monitor_alert_prometheus_rule_group.default_node_recording_rule_group.name
    "kubernetes_recording" = azurerm_monitor_alert_prometheus_rule_group.default_kubernetes_recording_rule_group.name
  }
}

output "rule_group_ids" {
  description = "Resource IDs of the user-defined rule groups created for prometheus"
  value       = { for key, rule_group in azurerm_monitor_alert_prometheus_rule_group.rule_group : key => rule_group.id }
}

output "rule_group_names" {
  description = "Resource IDs of the user-defined rule groups created for prometheus"
  value       = { for key, rule_group in azurerm_monitor_alert_prometheus_rule_group.rule_group : key => rule_group.name }
}

output "data_collection_endpoint_id" {
  description = "Resource ID of the data collection endpoint created for prometheus"
  value       = azurerm_monitor_data_collection_endpoint.dce.id
}

output "data_collection_endpoint_name" {
  description = "Resource ID of the data collection endpoint created for prometheus"
  value       = azurerm_monitor_data_collection_endpoint.dce.name
}

output "data_collection_rule_id" {
  description = "Resource ID of the data collection rule created for prometheus"
  value       = azurerm_monitor_data_collection_rule.dcr.id
}

output "data_collection_rule_name" {
  description = "Resource ID of the data collection rule created for prometheus"
  value       = azurerm_monitor_data_collection_rule.dcr.id
}
