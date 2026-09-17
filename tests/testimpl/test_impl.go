package testimpl

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMonitorPrometheus(t *testing.T, ctx types.TestContext) {

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
		if err != nil {
			if strings.Contains(err.Error(), "AADSTS700024") || strings.Contains(err.Error(), "Client assertion is not within its valid time range") {
				t.Skipf("Skipping MonitoringEnabled check due expired Azure federated token in CI: %v", err)
			}
			require.NoError(t, err, "Error getting managed cluster")
		}

		require.NotNil(t, cluster, "Managed cluster response must not be nil")
		monitoringEnabled, err := omsAgentEnabled(cluster)
		require.NoError(t, err, "Monitoring addon must be readable")
		assert.True(t, monitoringEnabled, "Monitoring addon must be enabled")
	})

	t.Run("TfOutputsNotEmpty", func(t *testing.T) {
		assert.NotEmpty(t, dceId, "Data collection endpoint ID must not be empty")
		assert.NotEmpty(t, dcrId, "Data collection rule ID must not be empty")
		assert.NotEmpty(t, ruleGroupId, "Rule group ID must not be empty")
	})
}

func TestComposableMonitorPrometheus(t *testing.T, ctx types.TestContext) {
	TestMonitorPrometheus(t, ctx)
}

func omsAgentEnabled(cluster interface{}) (bool, error) {
	clusterBytes, err := json.Marshal(cluster)
	if err != nil {
		return false, fmt.Errorf("marshal managed cluster: %w", err)
	}

	var clusterMap map[string]interface{}
	if err := json.Unmarshal(clusterBytes, &clusterMap); err != nil {
		return false, fmt.Errorf("unmarshal managed cluster: %w", err)
	}

	addonProfiles := mapValue(clusterMap, "addonProfiles")
	if addonProfiles == nil {
		properties := mapValue(clusterMap, "properties")
		addonProfiles = mapValue(properties, "addonProfiles")
	}
	if addonProfiles == nil {
		return false, fmt.Errorf("addonProfiles not found on managed cluster")
	}

	omsAgent := mapValue(addonProfiles, "omsagent")
	if omsAgent == nil {
		return false, fmt.Errorf("omsagent addon profile not found")
	}

	enabledValue, ok := omsAgent["enabled"]
	if !ok {
		return false, fmt.Errorf("omsagent enabled property not found")
	}

	enabled, ok := enabledValue.(bool)
	if !ok {
		return false, fmt.Errorf("omsagent enabled property is not boolean")
	}

	return enabled, nil
}

func mapValue(in map[string]interface{}, key string) map[string]interface{} {
	if in == nil {
		return nil
	}

	v, ok := in[key]
	if !ok {
		return nil
	}

	m, ok := v.(map[string]interface{})
	if !ok {
		return nil
	}

	return m
}
