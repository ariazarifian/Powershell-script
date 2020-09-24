# Run the script from the server
################################
# Script Local active directory

function DisplayMenu {
    cls
    Write-Host "Menu :"
    Write-Host "[1] List Groups"
    Write-Host "[2] List Users"
    Write-Host "[3] Add Manual User"
    Write-Host "[4] Delete Manual User"
    Write-Host "[5] Add user from CSV file"
    Write-Host "[6] Add x users"
    Write-Host "[9] Exit"
    Write-Host ""
}

function DisplayGroup {
    cls
    # Filtered with the usefull column and displays groups
    Get-ADGroup -Filter * | Format-Table -AutoSize DistinguishedName, Name, GroupCategory, GroupScope
    Read-Host "Press any key to continue"
}

function DisplayUsers {
    cls
    # Filtered with the usefull column and displays users
    Get-ADUser -Filter * | Format-Table -AutoSize
    Read-Host "Press any key to continue"
}

function AddManualUser {
    cls
    try{
        $name = Read-Host 'First and Last Name'
        $givenName = Read-Host 'Given name'
        $surname = Read-Host 'Surname'
        $samAccountName = Read-Host 'Sam account name'
        New-ADUser -Name $name -GivenName $givenName -Surname $surname -UserPrincipalName $samAccountName@project.cavd -SamAccountName $samAccountName -AccountPassword (Read-Host -AsSecureString "Input user password") -Enabled $true -ErrorAction stop
        write-Host "Works !"
        pause
    }
    catch{
        Write-host $_.Exception.Message`n
    }
    Read-Host "Press any key to continue"
}

function DeleteUser {
    cls
    try{
        $samAccountName = Read-Host 'Utilisateur'
        Remove-ADUser -Identity $samAccountName -ErrorAction stop
    }
    catch{
        Write-host $_.Exception.Message`n
        # This recursive function allows to the administrator choosing an existing user to delete. Used like a while to run down the function again.
        DeleteUser
    }
    Read-Host "Press any key to continue"
}

function AddFromCSV($initialDirectory){

    #initialDirectory gives to current directory and the net lines open a dialog file explorer.
    #The administrator can select the csv.file

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | out-null

    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.initialDirectory = $initialDirectory
    $openFileDialog.filter = "CSV (*.csv)| *.csv*"
    $openFileDialog.ShowDialog() | out-null
    
    $CSVFile = Import-csv -Path $openFileDialog.filename -Delimiter ","
    

    foreach ($user in $CSVFile)
    {
        # Try catch that permits to avoid errors
        try{
            $username = $user.SamAccountName       
            $securePass = convertto-securestring "Azerty@123" -asplaintext -force
            New-ADUser -Name $username -SamAccountName $username -AccountPassword $securePass -Surname $user.Surname -UserPrincipalName $user.UserPrincipalName -Enabled $true -ErrorAction Stop
        }
        catch{
            write-host $_.Exception.Message`n
        }        
    }
    Read-Host "Press any key to continue"
}

function AddXUsers{
    
    #Number of accounts that will be created. For example : 3 accounts
    $count = read-host "Nombre de compte à ajouter"
    # Name of the accounts. For example : User will create :  User1, User2, User3
    $nomenclature = read-host "Nomenclature"
    
    # Loop for the creation
    for($i = 1;$i -le $count; $i++){
        # try catch permits avoiding error message. For example, administrator chose an existing model name "User"
        try{
            $securePass = convertto-securestring "Azerty@123" -asplaintext -force
            New-ADUser -Name $nomenclature$i -SamAccountName $nomenclature$i -AccountPassword $securePass -Surname $nomenclature$i -UserPrincipalName $nomenclature$i@project.cavd -Enabled $true -ErrorAction Stop
        }
        catch{
            Write-Host $_.Exception.Message`n
        }
    }
    Read-Host "Press any key to continue"
}

function ChoseMenu {
    $menu = Read-Host -Prompt 'Select'
    if($menu -eq 1){
        DisplayGroup
    }
    elseif($menu -eq 2){
        DisplayUsers
    }
    elseif($menu -eq 3){
        AddManualUser
    }
    elseif($menu -eq 4){
        DeleteUser
    }
    elseif($menu -eq 5){
        AddFromCSV
    }
    elseif($menu -eq 6){
        AddXUsers
    }
    elseif($menu -eq 9){
        exit
    }
    else{
        # To avoid bugs
        Write-Host "Choose an existing number in the menu"
        Read-Host "Press any key to continue"
    }
}

# Importing module 
Import-Module ActiveDirectory

# Loop for displaying the menu and choosing the function affected to the number
while(1 -eq 1){
    DisplayMenu
    ChoseMenu
}