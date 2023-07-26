function Get-Choice {
    param(
        [string] $Message,
        [string[]] $Options
    )

    $ValidOptions = [string]::Join("/", $Options)
    $Prompt = "$Message ($ValidOptions): "
    $Choice = Read-Host -Prompt $Prompt

    while ($Choice -notin $Options) {
        Write-Host "Invalid choice. Please enter one of the following: $ValidOptions"
        $Choice = Read-Host -Prompt $Prompt
    }

    return $Choice
}

function Get-IISWebApplicationName {
    $WebApps = Get-WebApplication
    $WebAppNames = $WebApps | ForEach-Object { $_.Attributes[1].Value }

    Write-Host "List of IIS web applications:"
    for ($i = 0; $i -lt $WebAppNames.Count; $i++) {
        Write-Host ("{0}. {1}" -f ($i + 1), $WebAppNames[$i])
    }

    Write-Host "0. Cancel"

    $ChoiceIndex = Get-Choice -Message "Enter the number of your choice" -Options (0..$WebAppNames.Count)
    if ($ChoiceIndex -eq 0) {
        Write-Host "Operation canceled."
        return $null
    }

    $WebAppName = $WebAppNames[$ChoiceIndex - 1]
    return $WebAppName
}

function Get-WindowsServiceName {
    $Services = Get-Service
    $ServiceNames = $Services | ForEach-Object { $_.Name }

    Write-Host "List of Windows services:"
    for ($i = 0; $i -lt $ServiceNames.Count; $i++) {
        Write-Host ("{0}. {1}" -f ($i + 1), $ServiceNames[$i])
    }

    $ChoiceIndex = Get-Choice -Message "Enter the number of your choice" -Options (1..$ServiceNames.Count)
    $ServiceName = $ServiceNames[$ChoiceIndex - 1]
    return $ServiceName
}

function Start-IISWebApplication {
    param([string] $WebAppName)
    Start-WebAppPool -Name $WebAppName
    #Start-WebApplication -Name $WebAppName
    Write-Host "The IIS web application '$WebAppName' has been started."
}

function Stop-IISWebApplication {
    param([string] $WebAppName)
    Stop-WebAppPool -Name $WebAppName
    #Stop-WebApplication -Name $WebAppName
    Write-Host "The IIS web application '$WebAppName' has been stopped."
}

function Remove-IISWebApplication {
    param([string] $WebAppName)
    Remove-WebAppPool -Name $WebAppName
    #Remove-WebApplication -Name $WebAppName
    Write-Host "The IIS web application '$WebAppName' has been removed."
}

function Start-WindowsService {
    param([string] $ServiceName)
    Start-Service -Name $ServiceName
    Write-Host "The Windows service '$ServiceName' has been started."
}

function Stop-WindowsService {
    param([string] $ServiceName)
    Stop-Service -Name $ServiceName
    Write-Host "The Windows service '$ServiceName' has been stopped."
}

function Remove-WindowsService {
    param([string] $ServiceName)
    Stop-Service -Name $ServiceName
    Get-Service -Name $ServiceName | Set-Service -StartupType Disabled
    Write-Host "The Windows service '$ServiceName' has been stopped and disabled."
}

# Main script
Write-Host "Choose an option:"
Write-Host "1. Manage IIS web application"
Write-Host "2. Manage Windows service"
$Option = Get-Choice -Message "Enter the number of your choice" -Options "1", "2"

if ($Option -eq "1") {
    $WebAppName = Get-IISWebApplicationName
    if ($WebAppName -ne $null) {
        Write-Host "You have selected IIS web application: '$WebAppName'"
        Write-Host "Choose an option for the IIS web application '$WebAppName':"
        Write-Host "1. Start"
        Write-Host "2. Stop"
        Write-Host "3. Remove"
        $Action = Get-Choice -Message "Enter the number of your choice" -Options "1", "2", "3"
        switch ($Action) {
            "1" { Start-IISWebApplication -WebAppName $WebAppName }
            "2" { Stop-IISWebApplication -WebAppName $WebAppName }
            "3" { Remove-IISWebApplication -WebAppName $WebAppName }
        }
    }
}
else {
    $ServiceName = Get-WindowsServiceName
    if ($ServiceName) {
        Write-Host "You have selected Windows service: '$ServiceName'"
        Write-Host "Choose an option for the Windows service '$ServiceName':"
        Write-Host "1. Start"
        Write-Host "2. Stop"
        Write-Host "3. Remove"
        $Action = Get-Choice -Message "Enter the number of your choice" -Options "1", "2", "3"
        switch ($Action) {
            "1" { Start-WindowsService -ServiceName $ServiceName }
            "2" { Stop-WindowsService -ServiceName $ServiceName }
            "3" { Remove-WindowsService -ServiceName $ServiceName }
        }
    }
}