#The first command sets the execution policy for Windows computers and allows scripts to run.
Set-ExecutionPolicy RemoteSigned

#The following command loads the Exchange Online management module.
Import-Module ExchangeOnlineManagement

#Next, you connect using your user principal name. A dialog will prompt you for your password and any multi-factor authentication requirements.
Connect-ExchangeOnline

#Get the last 90 days worth of PBI activities
$endDate = Get-Date -format "MM/dd/yyyy"
$90days = (Get-Date).AddDays(-90)
$startDate = '{0:MM/dd/yyyy}' -f $90days
$auditlogoutput = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -RecordType PowerBIAudit
$usePBI = $auditlogoutput.UserIds | Get-Unique

#Connect to Azure AD to get list of Power BI Pro Users
Install-Module -Name AzureAD
Import-Module AzureAD
Connect-AzureAD 

#Get Users in a specific group
# $ADUsers = Get-AzureADGroupMember -ObjectID <GroupObjectId> | Select-Object ObjectId, ObjectType, UserPrincipalName, UserType, @{Name="Date Retrieved";Expression={$RetrieveDate}}

#Get all Users in AD
$ADUsers = Get-AzureADUser -All $true | Select-Object ObjectId, ObjectType, UserPrincipalName, UserType, @{Name="Date Retrieved";Expression={$RetrieveDate}}

$UserLicenseDetail = ForEach ($ADUser in $ADUsers)
    {
        $UserObjectID = $ADUser.ObjectId
        $UPN = $ADUser.UserPrincipalName
        $UserName = $ADUser.DisplayName
        Get-AzureADUserLicenseDetail -ObjectId $UserObjectID| 
        Select-Object ObjectID, @{Name="User Name";Expression={$UserName}},@{Name="UserPrincipalName";Expression={$UPN}} -ExpandProperty ServicePlans
    }

$PBIProServicePlanID = '70d33638-9c74-4d01-bfd3-562de28bd4ba'

$ProUsersDetails = $UserLicenseDetail | Where-Object {$_.ServicePlanId -eq $PBIProServicePlanID}

$ProUsers = $ProUsersDetails.UserPrincipalName | Get-Unique

#List of Pro Users who haven't used PBI in the last 90 days
$ProUsers | Where-Object { $_ -ne $usePBI}
