# Run the script from the cloud
###############################
# Script azure cloud

function DisplayMenu {
    cls
    Write-Host "Menu :"
    Write-Host "[1] Show azure user"
    Write-Host "[2] Create azure user"
    Write-Host "[3] Remove azure user"
    Write-Host "[4] Import from csv"
    Write-Host "[9] Exit"
    Write-Host ""
}
function ChoseMenu {
    $menu = Read-Host -Prompt 'Select'
    if($menu -eq 1){
        ShowAzureUser
    }
    elseif($menu -eq 2){
        CreateUser
    }
    elseif($menu -eq 3){
        RemoveUser
    }
    elseif($menu -eq 4){
        ImportFromCSV
    }
    elseif($menu -eq 9){
        exit
    }
    else{
        Write-Host "Choose an existing number in the menu"
        Read-Host "Press any key to continue"
    }
}

function ShowAzureUser {
    # Displays an filtered list of users
    Get-Azaduser | select UserPrincipalName, GivenName, AccountEnabled, MailNickname, Mail, DisplayName, Id | format-table -autosize
    Read-Host "Press any key to continue"
}

function CreateUser {
    # try catch permits avoiding errors. For example, account already exists.
    try{
        $Name = Read-Host "Name"
        # Name is used for the UserPrincipalName which is absolutely lower case and without space
        $Name = $Name.ToLower() -replace '\s',''
        $DisplayName = Read-Host "Display Name"
        $MailNickName = Read-Host "Mail NickName"
        $MailNickName = $MailNickName -replace '\s',''
        # Used to get the domain name of the current azure. Awk permits to get the domain after the "@" and delete space lines.
        $Domain = Get-AzADUser | select UserPrincipalName | format-table -AutoSize | awk -F'@' 'NR>=4 && NR<=4 {print$2}'
        New-AzADUser -DisplayName "$DisplayName" -UserPrincipalName "$Name@$Domain" -Password (Read-Host -AsSecureString "Input user password") -MailNickname "$MailNickName" -ErrorAction Stop
    }
    catch{
        write-host $_.Exception.Message`n
    }
    Read-Host "Press any key to continue"
}

function RemoveUser {
    Get-Azaduser | select UserPrincipalName | format-table -autosize
    $UserPrincipalName = Read-Host "User principal name"
    Remove-AzADuser -ObjectId $UserPrincipalName
    Read-Host "Press any key to continue"
}

function ImportFromCSV {
    
    $openFileDialog = Read-Host "Quel est le path ?"
    write-host "$openFileDialog"
    $CSVFile = Import-csv -Path $openFileDialog -Delimiter ","
    

    foreach ($user in $CSVFile)
    {
        
        try{
            $Name = Read-Host "Name"
            $Name = $Name.ToLower() -replace '\s',''
            $username = $user.SamAccountName
            $MailNickName = $user.Surname     
            $securePass = convertto-securestring "Azerty@123" -asplaintext -force
            $Domain = Get-AzADUser | select UserPrincipalName | format-table -AutoSize | awk -F'@' 'NR>=4 && NR<=4 {print$2}'
            New-AzADUser -DisplayName "$username" -Password $securePass -UserPrincipalName "$Name@$Domain" -MailNickname "$MailNickName" -ErrorAction stop
        }
        catch{
            write-host $_.Exception.Message`n
        }        
    }
    Read-Host "Press any key to continue"
}


function Recursive{
    try{
        $tenantid = Read-Host "tenant id !"
        Connect-AzAccount -tenantid $tenantid -ErrorAction Stop 
    }
    catch {
        write-host $_.Exception.Message`n
        pause
        Recursive
    }
}
# Run the function to connect, the function has a recursive mode to which force the administrator to login with the valid.
Recursive
while(1 -eq 1){
    DisplayMenu
    ChoseMenu
}
