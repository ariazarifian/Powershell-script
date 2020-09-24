# Run the script from the cloud
###############################
# Script ARM 

function DisplayMenu {
    cls
    Write-Host "Menu :"
    Write-Host "[1] Show existing resource group"
    Write-Host "[2] Create resoure group"
    Write-Host "[3] Create a DB"
    Write-Host "[4] Delete resource group"
    Write-Host "[9] Exit"
    Write-Host ""
}

function ChoseMenu {
    $menu = Read-Host -Prompt 'Select'
    if($menu -eq 1){
        ShowResourceGroup
    }
    elseif($menu -eq 2){
        CreateResourceGroup
    }
    elseif($menu -eq 3){
        CreateDB
    }
    elseif($menu -eq 4){
        DeleteResourceGroup
    }
    elseif($menu -eq 9){
        exit
    }
    else{
        Write-Host "Choose an existing number in the menu"
        Read-Host "Press any key to continue"
    }
}

function ShowResourceGroup{
    get-azResourceGroup | Format-Table -AutoSize
    read-host
}

function CreateResourceGroup{
    $nameGroupResource = read-host "Name of the resource group. You can't change the location"

    if(Get-AzResourceGroup -Name $nameGroupResource -ErrorAction SilentlyContinue){
        Write-Host "Oopsie ! The name already existing"
        read-host
    }
    else{
        New-AzResourceGroup `
            -Name $nameGroupResource `
            -Location "Central US"
            read-host
    }
}

function CreateDB{
    $resourceGroupName = Read-Host -Prompt "Enter a project name that is used for generating resource names"
    $location = Read-Host -Prompt "Enter an Azure location (i.e. centralus)"
    $adminUser = Read-Host -Prompt "Enter the SQL server administrator username"
    $adminPassword = Read-Host -Prompt "Enter the SQl server administrator password" -AsSecureString

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-sql-database/azuredeploy.json" -administratorLogin $adminUser -administratorLoginPassword $adminPassword

Read-Host -Prompt "Press [ENTER] to continue ..."
}

function DeleteResourceGroup {
    try{
        $Name = Read-Host "Nom du groupe de ressoruce"
        Remove-AzureRmResourceGroup -Name "$Name"
    }
    catch{
        Write-Host $_.Exception.Message`n
        DeleteResourceGroup
    }
    pause
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