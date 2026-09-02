package testimpl

import (
	"context"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestComposableMonitorPrometheus(t *testing.T, ctx types.TestContext) {

	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	dceId := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "data_collection_endpoint_id")
	dcrId := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "data_collection_rule_id")

	ruleGroupId := terraform.OutputMapContext(t, context.Background(), ctx.TerratestTerraformOptions(), "rule_group_ids")["MultiplePodAlertingRuleGroup"]

	t.Run("MonitoringEnabled", func(t *testing.T) {
		rgName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "resource_group_name")
		aksName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "cluster_name")

		cluster, err := azure.GetManagedClusterContextE(t, context.Background(), rgName, aksName, subscriptionId)
		assert.Nil(t, err, "Error getting managed cluster")

		assert.NotNil(t, cluster, "AKS cluster must exist")
		assert.Equal(t, aksName, *cluster.Name, "AKS cluster name must match")
	})

	t.Run("TfOutputsNotEmpty", func(t *testing.T) {
		assert.NotEmpty(t, dceId, "Data collection endpoint ID must not be empty")
		assert.NotEmpty(t, dcrId, "Data collection rule ID must not be empty")
		assert.NotEmpty(t, ruleGroupId, "Rule group ID must not be empty")
	})
}
