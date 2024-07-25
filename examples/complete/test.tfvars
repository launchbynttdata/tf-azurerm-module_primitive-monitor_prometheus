instance_env            = 0
instance_resource       = 0
logical_product_family  = "launch"
logical_product_service = "prometheus"
class_env               = "gotest"
location                = "eastus"

rule_groups = {
  "MultiplePodAlertingRuleGroup" = {
    enabled     = true
    description = "Cluster contains more than one pod"
    interval    = "PT1M"

    recording_rules = []

    # these will appear in the 'Alerts' blade of the Azure Monitor workspace or resource group when fired
    alert_rules = [
      {
        name       = "pod_count_gt_1"
        enabled    = true
        expression = "count(kube_pod_info) > 1"
        for        = "PT1M"
        severity   = 0

        labels = {
          severity = "critical"
        }
      }
    ]
  }
}
