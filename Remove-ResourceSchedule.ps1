workflow Remove-ResourceSchedule
{
    <#
	.SYNOPSIS
		Removes  Schedule tag from a VM or Resource Group. VMs without this tag are not evaluated by Test-ResourceSchedule to decide if VM will shutdown or not.
	.DESCRIPTION
		Removes  Schedule tag from a VM or Resource Group. VMs without this tag are not evaluated by Test-ResourceSchedule to decide if VM will shutdown or not.
	.PARAMETER SubscriptioName
		Name of Azure subscription where resource groups and resources are located.
	.PARAMETER ResourceGroupName
		Name of the resource group where the VM resides
	.PARAMETER VmName
		Optional, if this parameter is used, a VM will have the Schedule tag removed. If it is not provided te resource group will have the tag removed instead.
	.EXAMPLE
		How to manually execute this runbook from a Powershell command prompt:
		
		Add-AzureRmAccount
        
		Select-AzureRmSubscription -SubscriptionName pmcglobal
        
		$params = @{"SubscriptioName"="pmcglobal";"ResourceGroupName"="pmcrg01";"VmName"="pmcvm01"}
		Start-AzureRmAutomationRunbook -Name "Remove-ResourceSchedule" -Parameters $params -AutomationAccountName "pmcAutomation01" -ResourceGroupName "rgAutomation"

	.NOTE
		Since this runbook is being created from Azure Portal (azure.portal.com), this is Resource Manager so the following cmdlets
		should be executed when starting it from an Azure Powershell 1.0 command prompt:
		
		Add-AzureRmAccount
		Select-AzureRmSubscription -SubscriptionName <subscritpionname>
		
	.DISCLAIMER
		This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
		THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
		INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
		We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object
		code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software
		product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the
		Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims
		or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
		Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained
		within the Premier Customer Services Description.
	#>

	[cmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)]
		[string]$SubscriptionName,
		
		[Parameter(Mandatory=$true)]
		[string]$ResourceGroupName,
	
		[Parameter(Mandatory=$false)]
		[string]$VMName	
	)

	# Authenticating and setting up current subscription
	Write-Output "Authenticating"
	
	$connectionName = "AzureRunAsConnection"
	try
	{
		# Get the connection "AzureRunAsConnection "
		$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

		Add-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
	}
	catch
	{
		if (!$servicePrincipalConnection)
		{
			$ErrorMessage = "Connection $connectionName not found."
			throw $ErrorMessage
		}
		else
		{
			Write-Error -Message $_.Exception
			throw $_.Exception
		}
	}

	Select-AzureRmSubscription -SubscriptionName $subscriptionName

	Write-Output "Selecting tags and leaving Schedule tag behing if it exists"

	# Getting tags and skipping Schedule tag
	$tags=@()

	if ($VMName -ne $null)
	{
		foreach ($tag in (Get-AzureRmResource -Name $vmName -resourceGroupName $resourceGroupName -ResourceType "Microsoft.Compute/virtualmachines").Tags)
		{
			if ($tag.Name -ne "Schedule")
			{
				$tags+=$tag
			}
		}
	}
	else
	{
		foreach ($tag in (Get-AzureRmResourceGroup -Name $resourceGroupName).Tags)
		{
			if ($tag.Name -ne "Schedule")
			{
				$tags+=$tag
			}
		}		
	}
	
	# Setting up tags back again without the schedule tag
	Write-Output "Saving tags without Schedule tag, vm or resource group will not have Schedule tag anymore."

	if ($VMName -ne $null)
	{
		Set-AzureRmResource -Name $vmName -resourceGroupName $resourceGroupName -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -Confirm:$false -force
	}
	else
	{
		Set-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Tag $tags
	}
}
