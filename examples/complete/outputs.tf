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

output "resource_group" {
  description = "Resource group of the AKS cluster"
  value       = module.resource_names["resource_group"].minimal_random_suffix
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks_cluster.aks_name
}

output "default_rule_group_ids" {
  description = "Resource IDs of the default rule groups created for prometheus"
  value       = module.monitor_prometheus.default_rule_group_ids
}

output "default_rule_group_names" {
  description = "Resource IDs of the default rule groups created for prometheus"
  value       = module.monitor_prometheus.default_rule_group_names
}

output "rule_group_ids" {
  description = "Resource IDs of the user-defined rule groups created for prometheus"
  value       = module.monitor_prometheus.rule_group_ids
}

output "rule_group_names" {
  description = "Resource IDs of the user-defined rule groups created for prometheus"
  value       = module.monitor_prometheus.rule_group_names
}

output "data_collection_endpoint_id" {
  description = "Resource ID of the data collection endpoint created for prometheus"
  value       = module.monitor_prometheus.data_collection_endpoint_id
}

output "data_collection_endpoint_name" {
  description = "Resource ID of the data collection endpoint created for prometheus"
  value       = module.monitor_prometheus.data_collection_endpoint_name
}

output "data_collection_rule_id" {
  description = "Resource ID of the data collection rule created for prometheus"
  value       = module.monitor_prometheus.data_collection_rule_id
}

output "data_collection_rule_name" {
  description = "Resource ID of the data collection rule created for prometheus"
  value       = module.monitor_prometheus.data_collection_rule_name
}
