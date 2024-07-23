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

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "monitor_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_workspace/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["monitor_workspace"].minimal_random_suffix
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = merge(var.tags, { resource_name = module.resource_names["monitor_workspace"].standard })

  depends_on = [module.resource_group]
}

module "aks_cluster" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/kubernetes_cluster/azurerm"
  version = "~> 2.0"

  cluster_name                         = module.resource_names["aks_cluster"].minimal_random_suffix
  cluster_log_analytics_workspace_name = module.resource_names["log_analytics"].minimal_random_suffix
  prefix                               = module.resource_names["aks_cluster"].dns_compliant_minimal

  location            = var.location
  resource_group_name = module.resource_group.name

  rbac_aad        = false
  monitor_metrics = {}

  tags = merge(var.tags, { resource_name = module.resource_names["monitor_workspace"].standard })

  depends_on = [module.resource_group]
}

module "monitor_prometheus" {
  source = "../.."

  resource_group_name = module.resource_group.name
  location            = var.location

  data_collection_endpoint_name = module.resource_names["data_collection_endpoint"].minimal_random_suffix
  data_collection_rule_name     = module.resource_names["data_collection_rule"].minimal_random_suffix
  monitor_workspace_id          = module.monitor_workspace.id
  aks_cluster_id                = module.aks_cluster.aks_id

  enable_default_rule_groups  = var.enable_default_rule_groups
  default_rule_group_interval = var.default_rule_group_interval

  rule_groups = var.rule_groups

  depends_on = [module.monitor_workspace]
}
