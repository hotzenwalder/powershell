#Author: Marcel Moerings

#Inventory all rights from a specific user in all subscriptions in the connected Azure AD Tenant
#Needs $source account in UPN format. Also change the $output to set the location of the output CSV
#Needs Global Admin in Azure AD and sufficient rights for the affected resource groups
#Current script only looks for rights in subscription where you have rights assigned

#Connect to Azure Tenant
-Tenant "<Azure Tenant ID>"
Connect-AzAccount

Clear-Host

#Set source for inventory of rights
$source = "source account UPN"

#Set CSV file four ouput and remove existing files
$output = "C:\Archive\Output\AzureRights-$source.csv"
mkdir "C:\Archive\Output" | out-null
If (Test-path $output){
    Remove-Item "$output"  -Force  
}

#Function FillArray
#Put data inside array for later use
Function FillArray {
   $Data = New-Object PSObject
   $Data | Add-Member -MemberType NoteProperty -Name "Subscription" -Value $context.Subscription.Name
   $Data | Add-Member -MemberType NoteProperty -Name "SubscriptionID" -Value $ctx.Subscription.id
   $Data | Add-Member -MemberType NoteProperty -Name "Displayname" -Value $source               
   $Data | Add-Member -MemberType NoteProperty -Name "ResourceGroup" -Value $Groupname
   $Data | Add-Member -MemberType NoteProperty -Name "Roles" -Value $RolesAssigned
   $Array.Add($Data) | out-null       
} 

#Function NoRights
#No Rights on the current subscription
Function NoRights {
    Write-Warning "No rights for this subscription"
    $script:skip = "Y"
    $script:GroupName =""
    $script:RolesAssigned="No Rights for this subscription"
}

#Get all active subscriptions
$ctxList = Get-AzContext -ListAvailable | Select-Object * | Sort-Object Name

#Grab source account from Azure AD
$sourcename = Get-AzureADUser -objectid $source | Select-Object ObjectID, Displayname 

#Set extra variables / clear the array
$ErrorActionPreference = "Stop"
$Array = [System.Collections.ArrayList]@()

#Grab all current subscriptions and enumerate rights for the source user in the all these subscriptions
foreach($ctx in $ctxList){
    $context = Select-AzContext -Name $ctx.Name
    Write-Host -NoNewline "Active Subscription: " -ForegroundColor Green
    Write-Host $context.Subscription.Name
    Try{  
        $rights = Get-AzRoleAssignment -Scope /subscriptions/$($ctx.Subscription.Id) | Where-Object {$_.Displayname -eq $sourcename.DisplayName} | Select-Object DisplayName, RoleDefinitionName | Sort-Object RoleDefinitionName        
        $skip = "N"         
    }
    Catch{        
        NoRights
        FillArray   
        $skip = "Y"     
    }

    If ($rights.count -eq 0 -and $skip -eq "N"){
        NoRights
        FillArray        
    }
        
    If ($skip -eq "N"){

        #Get all groups in the current subscription        
        $RolesAssigned=""
        $groups = Get-AzResourceGroup | Select-Object ResourceGroupName, Location -ErrorAction SilentlyContinue | Sort-Object ResourceGroupName
        
        if ($groups.Count -eq 0){
            Write-Warning "No resource groups in this subscription"
            $GroupName =""
            foreach($right in $rights){
                $RolesAssigned=$RolesAssigned+$Right.RoleDefinitionName                
                Try{
                    if($Rights.indexof($right) -lt (($Rights.count)-1)){
                        $RolesAssigned=$RolesAssigned+","
                    }
                }
                Catch{}
            }            
            FillArray
        }
        
        Else {        
            Write-Host "Checking rights for all resource groups. Please wait..." -ForegroundColor Yellow  
            #Enumerate all the rights in the current subscription for all resource groups                
            ForEach ($group in $groups) { 
            $RolesAssigned=""
            $Groupname = $group.ResourceGroupName            
            $Roles = Get-AzRoleAssignment -ResourceGroupName $group -ErrorAction SilentlyContinue | Where-Object {$_.SignInName -eq $source} | Select-Object RoleDefinitionName                     
            if($Roles.count -eq 0){            
                $RolesAssigned="No active roles"
                Write-Warning "No active roles in this subscription"
            }
            else{                  
                foreach($Role in $Roles){
                    $RolesAssigned=$RolesAssigned+$Role.RoleDefinitionName                
                    Try{
                        if($Roles.indexof($role) -lt (($Roles.count)-1)){
                            $RolesAssigned=$RolesAssigned+","
                        }
                    }
                    Catch{}
                }        
            }        
            FillArray
            }
        }                              
    }
}  

#Export the results to a CSV file
$Array | Export-Csv -NoTypeInformation -Path "$output"

