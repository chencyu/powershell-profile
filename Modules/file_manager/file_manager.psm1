function clone
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [string]
        $Destination
    )

    robocopy  "$Source" "$Destination" /MT:${Env:NUMBER_OF_PROCESSORS} /XO /UNICODE | Out-Null
}

function Replace-FileName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Obsolete,
        [Parameter(Position = 1)]
        [string]
        $Replacement = ""
    )

    $(Get-ChildItem).Name | ForEach-Object -Process {
        if ($_ -match "$Obsolete")
        {
            $NewName = $_.Replace("$Obsolete", "$Replacement")
            Move-Item -Path $_ -Destination $NewName
        }
    }
}
