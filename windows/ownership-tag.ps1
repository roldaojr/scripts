param ([Boolean]$setTag=$false, [Boolean]$setComputerName=$false)

if($setTag -and $setComputerName) {
    Write-Host "setTag e setComputerName can not be used twogether"
    exit 1
}

Function Get-WmiNamespace {
    Param (
        $Namespace='root'
    )
    Get-WmiObject -Namespace $Namespace -Class __NAMESPACE | ForEach-Object {
            ($ns = '{0}\{1}' -f $_.__NAMESPACE,$_.Name)
            Get-WmiNamespace $ns
    }
}

function Set-OwnershipTag {
    # Check HP firmware
    if(Get-WmiNamespace | where {($_ -eq "ROOT\HP\INSTRUMENTEDBIOS")} -ne $null) {
        $settings = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSSettingInterface
        $settings.SetBiosSetting("Ownership Tag", $env:ComputerName)
    }
    # Check Dell firmware
    $nsDell = Get-WmiNamespace | where {($_ -eq "ROOT\DCIM\SYSMAN")}
    if(Get-WmiNamespace | where {($_ -eq "ROOT\DCIM\SYSMAN")} -ne $null) {
        $settings = Get-WmiObject -Namespace root\dcim\sysman -Class DCIM_Chassis
        $settings.ChangePropertyOwnershipTag($env:ComputerName, "")
    }
    Write-Host "No wmi interface detected"
}

function Get-OwnershipTag {
    # Check HP firmware
    $nsHP = Get-WmiNamespace | where {($_ -eq "ROOT\HP\INSTRUMENTEDBIOS")}
    if($nsHP -ne $null) {
        $setting = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSSetting -Filter "name = 'Ownership Tag'"
        return $setting.value
    }
    # Check Dell firmware
    $nsDell = Get-WmiNamespace | where {($_ -eq "ROOT\DCIM\SYSMAN")}
    if($nsDell -ne $null) {
        $settings = Get-WmiObject -Namespace root\dcim\sysman -Class DCIM_Chassis
        return $settings.PropertyOwnershipTag
    }
    Write-Host "No wmi interface detected"
}

if($setTag -eq $true) {
    Write-Host "Setting Ownership Tag to $env:ComputerName"
    Set-OwnershipTag
} else {
    $tag = Get-OwnershipTag
    if ($tag -eq "") {
        Write-Host "Ownership Tag is not set."
        if($setComputerName -eq $false) {
            $o = Read-Host "Set to '$env:ComputerName'? [Y/n] "
            if($o -eq "" -or $o -eq "y" -or $o -eq "Y") {
                Write-Host "Setting Ownership Tag to $env:ComputerName"
                Set-OwnershipTag
            }
        }
    } else {
        Write-Host "Ownership Tag is $tag"
        if($tag -ne $env:ComputerName) {
            Write-Host "Computer name é not equal to to Ownership Tag."
            if($setComputerName -eq $false) {
                $o = Read-Host "Set computer name to '$tag'? [Y/n] "
                if($o -ne "" -and $o -ne "y" -and $o -ne "Y") {
                    exit 0
                }
            }
            Rename-Computer -newName $tag
        }
    }
}
