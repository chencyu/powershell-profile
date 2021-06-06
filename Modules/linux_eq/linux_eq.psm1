function su
{
    Start-Process -FilePath "pwsh.exe" -Verb RunAs
    Exit
}

function sudo
{
    Start-Process -FilePath "pwsh.exe" -Verb RunAs -ArgumentList ("-Command " + $args)
}

function cdls
{
    param( [String]$Path )
    Set-Location -Path $Path
    Get-ChildItem
}

function whereis($SearchedCMD)
{
    $CMDinfo = (Get-Command $SearchedCMD)
    switch ($CMDinfo.CommandType)
    {
        "Application" { Write-Output $CMDinfo.Path }
        "ExternalScript" { Write-Output $CMDinfo.Path }
        "Cmdlet" { Write-Output "A Cmdlet in PowerShell" }
        "Function"
        {
            Write-Output "A Function in PowerShell"
            $Title = "Show its content?"
            $Info = ""
            $Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&yes", "&no")
            [int]$defaultchoice = 1
            $opt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
            switch ($opt)
            {
                0 { Write-Host $CMDinfo.Definition }
                Default {}
            }
            
        }
        Default {}
    }
}

function vim
{
    wsl vim $args
}

function touch
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FileName
    )
    if (Test-Path -Path $FileName)
    {
        (Get-ChildItem -Path $FileName).LastWriteTime = Get-Date
    }
    else
    {
        New-Item -Path $FileName -ItemType File
    }
}


function ln
{
    [CmdletBinding()]
    param
    (
        # Symbolic Link Path
        [Parameter(Mandatory)]
        [string]
        $Link,
        # Target File/Directory Path
        [Parameter(Mandatory)]
        [string]
        $Target
    )
    New-Item -ItemType SymbolicLink -Path "$Link" -Target "$Target"
}


# This must be end of modules
# Export-ModuleMember -Variable *
Export-ModuleMember -Function *
