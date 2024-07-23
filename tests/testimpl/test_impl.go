package testimpl

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestMonitorPrometheus(t *testing.T, ctx types.TestContext) {

	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	dceId := terraform.Output(t, ctx.TerratestTerraformOptions(), "data_collection_endpoint_id")
	dcrId := terraform.Output(t, ctx.TerratestTerraformOptions(), "data_collection_rule_id")

	ruleGroupId := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "rule_group_ids")["MultiplePodAlertingRuleGroup"]

	t.Run("MonitoringEnabled", func(t *testing.T) {
		rgName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
		aksName := terraform.Output(t, ctx.TerratestTerraformOptions(), "cluster_name")

		cluster, err := azure.GetManagedClusterE(t, rgName, aksName, subscriptionId)
		assert.Nil(t, err, "Error getting managed cluster")

		assert.NotNil(t, cluster.AddonProfiles["monitoring"], "Monitoring addon must be enabled")
		assert.True(t, *cluster.AddonProfiles["monitoring"].Enabled, "Monitoring addon must be enabled")

	})

	t.Run("TfOutputsNotEmpty", func(t *testing.T) {
		assert.NotEmpty(t, dceId, "Data collection endpoint ID must not be empty")
		assert.NotEmpty(t, dcrId, "Data collection rule ID must not be empty")
		assert.NotEmpty(t, ruleGroupId, "Rule group ID must not be empty")
	})
}
