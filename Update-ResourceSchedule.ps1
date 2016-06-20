workflow Update-ResourceSchedule
{
   <#
	.SYNOPSIS
		Updates Schedule tag of a VM or Resource Group that is later evaluated by Test-ResourceSchedule to decide if VM(s) will shutdown or not.
	.DESCRIPTION
		Udpates Schedule tag of a VM or Resource Group that is later evaluated by Test-ResourceSchedule to decide if VM(s) will shutdown or not. If a schedule is attached to a resource group it will apply to
		all VMs whithin that resource group, if both the resource group and VM inside it has a Schedule tag attached, the VM tag will be evaluated and takes precedence.
	.PARAMETER SubscriptioName
		Name of Azure subscription where resource groups and resources are located.
	.PARAMETER ResourceGroupName
		Name of the resource group where the VM resides
	.PARAMETER VMName
		Optional, if this parameter is used, a VM will be tagged with a Schedule tag. If it is not provided te resource group will be tagged instead.
	.PARAMETER Schedule
		Hash table that defines the schedule and Timezone of the resource. TzId is the time zone resource id and it can be obtained by exeuting [System.TimeZoneInfo]::GetSystemTimeZones() in a powershell command prompt.
        
		Sample code on how to define the hashtable:
   
		$schedule= @{
						"TzId"="Central Standard Time";
						"0"= @{
									"S"="11";
									"E"="17"};
						"1"= @{
									"S"="9";
									"E"="19"};
						"2"= @{
									"S"="9";
									"E"="19"};
						"3"= @{
									"S"="9";
									"E"="19"};
						"4"= @{
									"S"="9";
									"E"="19"};
						"5"= @{
									"S"="9";
									"E"="19"};
						"6"= @{
									"S"="11";
									"E"="17"}

					}
	   }        
        
		Where:
			TzID - Time zone ID - this is the timezone of the resource where this schedule is being applied.
			0, 1 , 2 , 3, 4, 5, 6 - numeric representation of days of week, Sunday starts in 0.
			S - Start time, numeric value of the hour from 1 to 24.
			E - End/Stop time, numeric value of the hour from 1 to 24

	.EXAMPLE
		How to manually execute this runbook from a Powershell command prompt:
		
		Add-AzureRmAccount
        
		Select-AzureRmSubscription -SubscriptionName pmcglobal
        
		$schedule= @{ "TzId"="Central Standard Time"; "0"= @{"S"="11";"E"="17"};"1"= @{"S"="9";"E"="19"};"2"= @{"S"="9";"E"="19"};"3"= @{"S"="9";"E"="19"};"4"= @{"S"="9";"E"="19"};"5"= @{"S"="9";"E"="19"};"6"= @{"S"="11";"E"="17"}}       

		$params = @{"SubscriptionName"="pmcglobal";"ResourceGroupName"="pmcrg01";"VmName"="pmcvm01";"Schedule"=$schedule}
		Start-AzureRmAutomationRunbook -Name "Add-ResourceSchedule" -Parameters $params -AutomationAccountName "pmcAutomation01" -ResourceGroupName "rgAutomation"

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
		[string]$VMName,
	
		[Parameter(Mandatory=$false)]
		$Schedule
	)
	
	# Default schedule hash table
	if ($Schedule -eq $null)
	{
		# Sunday is 0
		# it accept only hour numbers from 1 to 24 (so 24h notation)
		$schedule= @{
					"TzId"="Central Standard Time";
					"0"= @{
								"S"="11";
								"E"="17"};
					"1"= @{
								"S"="9";
								"E"="19"};
					"2"= @{
								"S"="9";
								"E"="19"};
					"3"= @{
								"S"="9";
								"E"="19"};
					"4"= @{
								"S"="9";
								"E"="19"};
					"5"= @{
								"S"="9";
								"E"="19"};
					"6"= @{
								"S"="11";
								"E"="17"}

				}
	}
	
	# Calling Add-ResourceSchedule
	if ($VMName -ne $null)
	{
		Add-ResourceSchedule -SubscriptionName $SubscriptionName -ResourceGroupName $resourceGroupName -VmName $vmName -Schedule $Schedule
	}
	else
	{
		Add-ResourceSchedule -SubscriptionName $SubscriptionName -ResourceGroupName $resourceGroupName -Schedule $Schedule
	}
}
