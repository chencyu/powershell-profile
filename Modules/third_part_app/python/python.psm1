
# Python Environment Variable
$Env:PYTHONIOENCODING = "utf-8"
$VenvSet = "$Env:UserProfile/.Envs".Replace("\", "/")
function jupyterkernel
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [switch]
        $Install,
        [Parameter(Position = 0)]
        [switch]
        $Remove,
        [Parameter(Position = 0)]
        [switch]
        $List,
        [Parameter(Position = 1)]
        [string]
        $Name
    )
    if ($Install)
    {
        if (Test-Path env:VIRTUAL_ENV)
        {
            python -m ipykernel install --name "$Name" --user
        }
    }
    elseif ($Remove)
    { jupyter kernelspec remove "$Name" }
    elseif ($List)
    { jupyter kernelspec list }
}


#region     [Venv]
function IsVenv($EnvName)
{
    if (Test-Path "$VenvSet/$EnvName")
    {
        return $true
    }
    else
    {
        return $false
    }
}

function hint_venv_not_exist
{
    Write-Output "" "尚未建立名為`"$EnvName`"的專案" ""
}

function list_env
{
    $envList = Get-ChildItem "$VenvSet/"
    if (-Not $envList)
    {
        Write-Output "" "您目前沒有任何虛擬環境專案" ""
    }
    else
    {
        Write-Output "" "已建立的虛擬環境專案" ""
        for ($i = 0; $i -lt $envList.Count; $i++)
        {
            Write-Output ("({0:d2})  $($envList[$i].Name)" -f ($i + 1))
        }
        Write-Output ""
    }
}

function SetIniScript($EnvName)
{
    $IniContent = `
    @(
        'python -m pip install -U pip'
        'pip install -U setuptools'
        'pip install -U wheel'
        'Remove-Item -Path "$PSCommandPath"'
    ) -join "`r`n"
    Set-Content -Value $IniContent -PaTh "$VenvSet/$EnvName/Scripts/pipinit.ps1"
}

function pipinit($EnvName)
{
    &"$VenvSet/$EnvName/Scripts/Activate.ps1"
    python -m pip install -U pip
    pip install -U setuptools
    pip install -U wheel
    pip install -U pip-autoremove
}

function venv
{
    <#
    .SYNOPSIS
        Easy way to use venv, for common used.
        簡單使用python -m venv的指令，只適用幾個較普遍的操作。

        ._________________________________________________________.
        | [Venv - Easy way to use Python venv]                    |
        |---------------------------------------------------------|
        |  venv  <operation>        <Py_ver>           <envName>  |
        |           create       -py <3.7/3.8 ...>       newEnv   |
        |           upgrade      -py <3.7/3.8 ...>        myEnv   |
        |           remove                                myEnv   |
        |            list                                         |
        |          activate                               myEnv   |
        |             -h                                          |
        |  ex.                                                    |
        |      venv create -py 3.7 newEnvName                     |
        |      venv remove myEnvName                              |
        |_________________________________________________________|

    .DESCRIPTION
        .
    .PARAMETER Path
        The path to the .
    .PARAMETER LiteralPath
        Specifies a path to one or more locations. Unlike Path, the value of 
        LiteralPath is used exactly as it is typed. No characters are interpreted 
        as wildcards. If the path includes escape characters, enclose it in single
        quotation marks. Single quotation marks tell Windows PowerShell not to 
        interpret any characters as escape sequences.
    .EXAMPLE
        C:/PS> 
        <Description of example>
    .NOTES
        Author: ChenCYu
        Date:   July 09, 2020    
    #>

    [CmdletBinding(DefaultParameterSetName = "General")]
    param
    (
        [Parameter()]
        [Alias("cr")]
        [Switch] $create = $false,
        [Parameter()]
        [Alias("U")]
        [Switch] $upgrade = $false,
        [Parameter()]
        [Alias("delete", "del")]
        [Switch] $remove = $false,
        [Parameter()]
        [Alias("ls")]
        [Switch] $list = $false,
        [Parameter()]
        [Alias("act")]
        [Switch] $activate = $false,
        [Parameter()]
        [Alias("help")]
        [Switch] $h = $false,
        [Parameter(Position = 1)]
        [String] $EnvName,
        [Parameter()]
        [Alias("Py")]
        [String] $PyVer
    )


    if ($h)
    {
        Write-Output `
            ""`
            " _________________________________________________________"`
            "| [Venv - Easy way to use Python venv]                    |"`
            "|---------------------------------------------------------|"`
            "|  venv  <operation>        <Py_ver>           <envName>  |"`
            "|          -create       -py <3.7/3.8 ...>       newEnv   |"`
            "|          -upgrade      -py <3.7/3.8 ...>        myEnv   |"`
            "|          -remove                                myEnv   |"`
            "|           -list                                         |"`
            "|         -activate                               myEnv   |"`
            "|             -h                                          |"`
            "|  ex.                                                    |"`
            "|      venv create -py 3.7 newEnvName                     |"`
            "|      venv remove myEnvName                              |"`
            "|_________________________________________________________|"`
            ""
        return
    }


    if (-Not (Test-Path "$VenvSet"))
    {
        mkdir "$VenvSet" | Out-Null
    }

    
    #region     [Operation]
    
    if ($create)
    {
        if (IsVenv $EnvName)
        {
            Write-Output "EnvName: $EnvName"
            Write-Error -Message "已經創建過此專案，請換另一個名稱"
            return
        }
        if ($PyVer) { py -$PyVer -m venv "$VenvSet/$EnvName" }
        else { py -m venv "$VenvSet/$EnvName" }
        # SetIniScript "$EnvName"
        pipinit "$EnvName"
        deactivate
        return
    }
    if ($upgrade)
    {
        if (-Not (IsVenv "$EnvName"))
        {
            hint_venv_not_exist
        }
        if ($PyVer) { py -$PyVer -m venv --upgrade "$VenvSet/$EnvName" }
        else { py -m venv --upgrade "$VenvSet/$EnvName" }
        return
    }
    if ($remove)
    {
        Remove-Item -r "$VenvSet/$EnvName"
        return
    }
    if ($list)
    {
        list_env
        return
    }
    if ($activate)
    {
        if (-Not "$EnvName")
        {
            Write-Output "" "請提供虛擬環境專案名稱" ""
            # Write-Output "" "Please provide envName" ""
        }
        elseif (-Not (IsVenv "$EnvName"))
        {
            hint_venv_not_exist
        }
        elseif (-Not (Test-Path -Path "$VenvSet/$EnvName/Scripts/Activate.ps1"))
        {
            # hint_venv_not_exist
            Write-Output "" "您的虛擬環境專案已損壞，請移除並重新創建" ""
            Write-Output "" "Your virtual env has destoried, please remove and recreate it." ""
        }
        else
        {
            &"$VenvSet/$EnvName/Scripts/Activate.ps1"
        }
        return
    }

    #endregion  [Operation]




    Write-Output "" "語法錯誤"
    Write-Output "使用 'venv -h' 來查看說明" ""

}

#endregion  [Venv]

# This must be end of modules
Export-ModuleMember -Variable Env
Export-ModuleMember -Function jupyterkernel
Export-ModuleMember -Function venv
