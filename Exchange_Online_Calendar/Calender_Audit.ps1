Import-Module ExchangeOnlineManagement

$upn = read-host "Enter an account with admin priveleges to manage the tenant"

Connect-ExchangeOnline -UserPrincipalName $upn

$selection = 0

do
{
    if ($selection -eq 1)
    {
        $review = read-host "Type the mailbox to review its calendar permissions"

        Get-EXOMailboxFolderPermission -identity ($review + ":\Calendar")

        $selection = 0
    }

    if ($selection -eq 2)
    {
        $mailbox = read-host "Type the mailbox for which you would like to add permissions"
        $user = read-host "Type the user you would like to add to the selected calender"
        $permission = read-host "Type the permission you would like to add (Options: Reviewer, Editor)"

        Set-EXOMailboxFolderPermission -Identity ($mailbox + ":\Calendar") -user $user -AccessRights $permission

        $selection = 0
    }

    else
    {
        $selection = read-host "Select an option: 1) Review calendar permissions 2) Grant calender permissions 3) Quit"
    }
}
until ($selection -eq 3)