#Author: Marcel Moerings/FNV

#Show which 365 groups a specific account is a member of in the current Azure Tenant
#Needs $source account in UPN format
#Needs at least read rights in Azure AD

#Connect to Azure AD
Connect-AzureAD

#UPN to check for 365 Group Membership
$source = "bron account UPN"

#Show 365 Groups for UPN defined $source
$userID = Get-AzureADUser -Filter "userPrincipalName eq '$source'" 
$groups = Get-AzureADUserMembership -ObjectId $userID.ObjectId | Sort-Object Displayname
ForEach($g in $groups){
    Write-Host $g.Displayname
}