#region init
Import-Module azure
echo $PSVersionTable
Get-Module azure
Switch-AzureMode -Name AzureResourceManager
Add-AzureAccount

#NB all $b_* variables are defined on my laptop. Replace with your own values in this script.
#psedit C:\benjguin\_e\config\benjguin_config_in_PowerShell.ps1

$createCluster=$true
$removeCluster=$false

$subscriptionName=$b_subscription1Name
$storage1Name=$b_hdiStorageName
$storage2Name=$b_ulstorage001Name
$storage2Key=$b_ulstorage001Key
$clusterAdminUsername="cornac"
$clusterAdminPassword=$b_cornacPassword
$clusterRDUsername="cornacRD"
$clusterRDPassword=$b_cornacRDPassword
$clusterName=$b_hdiWindowsClusterName
$clusterContainerName=$clusterName
$resourceGroupName=$clusterName

Select-AzureSubscription -Current -Name "$subscriptionName"
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountName $storage1Name

$storage1Key=(Get-AzureStorageKey -StorageAccountName $storage1Name).Primary
#endregion


#region misc selects
Get-AzureHDInsightCluster
#endregion

#region HDInsight
$subscriptionId=(Get-AzureSubscription -SubscriptionName $subscriptionName).SubscriptionId
$passwordAsSecureString=ConvertTo-SecureString $clusterAdminPassword -AsPlainText -Force
$clusterCredential=New-Object System.Management.Automation.PSCredential ($clusterAdminUsername, $passwordAsSecureString)
$passwordAsSecureString=ConvertTo-SecureString $clusterRDPassword -AsPlainText -Force
$clusterRdpCredential=New-Object System.Management.Automation.PSCredential ($clusterRDUsername, $passwordAsSecureString)


if ($createCluster)
{
    echo "will create cluster $clusterName"

    New-AzureHDInsightClusterConfig -ClusterType Spark -HeadNodeSize "Standard_D12" -WorkerNodeSize "Standard_D12" `
            -DefaultStorageAccountName "$storage1Name.blob.core.windows.net" -DefaultStorageAccountKey $storage1Key  |
        Add-AzureHDInsightStorage -StorageAccountName "$storage2Name.blob.core.windows.net" -StorageAccountKey $storage2Key |
        New-AzureHDInsightCluster -ClusterSizeInNodes 3 -Location "North Europe" `
            -ResourceGroupName $resourceGroupName -ClusterName $clusterName -HttpCredential $clusterCredential `
            -DefaultStorageContainer $clusterContainerName -RdpCredential $clusterRdpCredential -RdpAccessExpiry (Get-Date).AddDays(20)

    echo "end of cluster creation"
}
        
if ($removeCluster)
{
    echo "will remove cluster"
    Remove-AzureHDInsightCluster -ClusterName $clusterName -ResourceGroupName $resourceGroupName
    echo "removed cluster"
}
echo "done"

#endregion

