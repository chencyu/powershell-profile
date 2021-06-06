function Add-Time
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Time1,
        [Parameter(Mandatory)]
        [string]
        $Time2
    )

    $ResultTime = ([System.TimeSpan]($Time1)).Add([System.TimeSpan]($Time2))
    Write-Output "$ResultTime"
}


function Sub-Time
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Time1,
        [Parameter(Mandatory)]
        [string]
        $Time2
    )

    $ResultTime = ([System.TimeSpan]($Time1)).Subtract([System.TimeSpan]($Time2))
    Write-Output "$ResultTime"
}


# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
