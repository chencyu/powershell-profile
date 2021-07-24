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
