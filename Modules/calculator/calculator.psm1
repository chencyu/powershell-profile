function DWPD2TBW
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Int32]
        $Density,
        [Parameter(Mandatory)]
        [double]
        $DWPD
    )

    $TBW = $DWPD * 365 * 5 * $Density / 1024
    Write-Output "${TBW} TBW"
}
