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

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = var.data_collection_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  tags                = local.tags
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = var.data_collection_rule_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = var.monitor_workspace_id
      name               = "MonitorAccount"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitorAccount"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  tags        = local.tags

  depends_on = [azurerm_monitor_data_collection_endpoint.dce]
}

resource "azurerm_monitor_data_collection_rule_association" "dcra_dcr" {
  name                    = local.aks_cluster_name
  target_resource_id      = var.aks_cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association of data collection rule to AKS cluster"

  depends_on = [azurerm_monitor_data_collection_rule.dcr]
}

resource "azurerm_monitor_data_collection_rule_association" "dcra_dce" {
  target_resource_id          = var.aks_cluster_id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  description                 = "Association of data collection endpoint to AKS cluster"

  depends_on = [azurerm_monitor_data_collection_rule.dcr]
}

# Rules provided by Azure in their documentation for enabling prometheus
# https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=terraform#enable-prometheus-and-grafana
# https://github.com/Azure/prometheus-collector/blob/0349c8630edc4cf3da5905ce3d3f59013527599f/AddonTerraformTemplate/main.tf#L114
resource "azurerm_monitor_alert_prometheus_rule_group" "default_node_recording_rule_group" {
  name                = var.default_rule_group_naming["node_recording"]
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = local.aks_cluster_name
  description         = "Default Node Recording Rules"
  rule_group_enabled  = var.enable_default_rule_groups
  interval            = var.default_rule_group_interval
  scopes              = [var.monitor_workspace_id, var.aks_cluster_id]

  rule {
    enabled    = true
    record     = "instance:node_num_cpu:sum"
    expression = <<EOF
count without (cpu, mode) (  node_cpu_seconds_total{job="node",mode="idle"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_cpu_utilisation:rate5m"
    expression = <<EOF
1 - avg without (cpu) (  sum without (mode) (rate(node_cpu_seconds_total{job="node", mode=~"idle|iowait|steal"}[5m])))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_load1_per_cpu:ratio"
    expression = <<EOF
(  node_load1{job="node"}/  instance:node_num_cpu:sum{job="node"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_memory_utilisation:ratio"
    expression = <<EOF
1 - (  (    node_memory_MemAvailable_bytes{job="node"}    or    (      node_memory_Buffers_bytes{job="node"}      +      node_memory_Cached_bytes{job="node"}      +      node_memory_MemFree_bytes{job="node"}      +      node_memory_Slab_bytes{job="node"}    )  )/  node_memory_MemTotal_bytes{job="node"})
EOF
  }
  rule {
    enabled = true

    record     = "instance:node_vmstat_pgmajfault:rate5m"
    expression = <<EOF
rate(node_vmstat_pgmajfault{job="node"}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_weighted_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_weighted_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_drop_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_drop_total{job="node", device!="lo"}[5m]))
EOF
  }

  tags = local.tags
}

# Rules provided by Azure in their documentation for enabling prometheus
# https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=terraform#enable-prometheus-and-grafana
# https://github.com/Azure/prometheus-collector/blob/0349c8630edc4cf3da5905ce3d3f59013527599f/AddonTerraformTemplate/main.tf#L204
resource "azurerm_monitor_alert_prometheus_rule_group" "default_kubernetes_recording_rule_group" {
  name                = var.default_rule_group_naming["kubernetes_recording"]
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = local.aks_cluster_name
  description         = "Default Kubernetes Recording Rules"
  rule_group_enabled  = var.enable_default_rule_groups
  interval            = var.default_rule_group_interval
  scopes              = [var.monitor_workspace_id, var.aks_cluster_id]

  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
    expression = <<EOF
sum by (cluster, namespace, pod, container) (  irate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_working_set_bytes"
    expression = <<EOF
container_memory_working_set_bytes{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_rss"
    expression = <<EOF
container_memory_rss{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_cache"
    expression = <<EOF
container_memory_cache{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_swap"
    expression = <<EOF
container_memory_swap{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ( (kube_pod_status_phase{phase=~"Pending|Running"} == 1) )
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    label_replace(      kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},      "replicaset", "$1", "owner_name", "(.*)"    ) * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (      1, max by (replicaset, namespace, owner_name) (        kube_replicaset_owner{job="kube-state-metrics"}      )    ),    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "deployment"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "daemonset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "statefulset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="Job"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "job"
    }
  }
  rule {
    enabled    = true
    record     = ":node_memory_MemAvailable_bytes:sum"
    expression = <<EOF
sum(  node_memory_MemAvailable_bytes{job="node"} or  (    node_memory_Buffers_bytes{job="node"} +    node_memory_Cached_bytes{job="node"} +    node_memory_MemFree_bytes{job="node"} +    node_memory_Slab_bytes{job="node"}  )) by (cluster)
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:node_cpu:ratio_rate5m"
    expression = <<EOF
sum(rate(node_cpu_seconds_total{job="node",mode!="idle",mode!="iowait",mode!="steal"}[5m])) by (cluster) /count(sum(node_cpu_seconds_total{job="node"}) by (cluster, instance, cpu)) by (cluster)
EOF
  }

  tags = local.tags
}

resource "azurerm_monitor_alert_prometheus_rule_group" "rule_group" {
  for_each = var.rule_groups

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = local.aks_cluster_name
  description         = each.value.description
  rule_group_enabled  = each.value.enabled
  interval            = each.value.interval
  scopes              = [var.monitor_workspace_id, var.aks_cluster_id]

  dynamic "rule" {
    for_each = each.value.recording_rules

    content {
      enabled    = rule.value.enabled
      record     = rule.value.name
      expression = rule.value.expression
      labels     = rule.value.labels
    }
  }

  dynamic "rule" {
    for_each = each.value.alert_rules

    content {
      enabled     = rule.value.enabled
      alert       = rule.value.name
      expression  = rule.value.expression
      for         = rule.value.for
      severity    = rule.value.severity
      labels      = rule.value.labels
      annotations = rule.value.annotations

      dynamic "action" {
        for_each = rule.value.action != null ? [1] : []

        content {
          action_group_id = action.value.action_group_id
        }
      }

      dynamic "alert_resolution" {
        for_each = rule.value.alert_resolution != null ? [1] : []

        content {
          auto_resolved   = alert_resolution.value.auto_resolved
          time_to_resolve = alert_resolution.value.time_to_resolve
        }
      }
    }
  }

  tags = merge(local.tags, each.value.tags)
}
