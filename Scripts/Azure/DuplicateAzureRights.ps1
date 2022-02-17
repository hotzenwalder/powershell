#Author: Marcel Moerings

#Duplicate Roles from a source user to a target user for all resources in the current subscription
#Needs $source account in UPN format. Needs $target account to duplicate rights
#Needs Global Admin in Azure AD and sufficient rights for the affected resource groups
#Current script only looks for rights in the active subscription

#Connect to Azure Tenant
Connect-AzAccount -Tenant "<Azure Tenant ID>"

#Set Azure Context to a specific subscription 
Set-AzContext -Subscription "<Azure Subscription>"

#Set source and target accounts for duplication
$source = "source account UPN"
$target = "target account UPN"

#Grab source and target accounts from Azure AD
$sourcename = Get-AzureADUser -objectid $source | Select-Object ObjectID, Displayname
$targetname = Get-AzureADUser -objectid $target | Select-Object ObjectID,DisplayName

#Enumerate rights for the source user in the current subscription and duplicate those rights to the target user
#Shows the output
$rights = Get-AzRoleAssignment -ObjectID $sourcename.ObjectId | Select-Object RoleDefinitionName, Scope
Write-Host "Add rights for"$targetname.Displayname -ForegroundColor Green
ForEach($item in $rights){        
    $rg = $item.scope.split('/')[-1]            
    Try{
        New-AzRoleAssignment -SignInName $target -RoleDefinitionName $item.RoleDefinitionName -ResourceGroupName $rg
        Write-Host $item.RoleDefinitionName "added rol to resource group" $rg 
    }
    Catch {
        Write-Host "Could not add"$item.RoleDefinitionName "as a role to resource group" $rg -ForegroundColor Yellow
    }
}
