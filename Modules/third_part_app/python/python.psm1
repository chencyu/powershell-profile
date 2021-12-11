
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
        [Alias("Del", "Delete")]
        [Parameter(Position = 0)]
        [switch]
        $Remove,
        [Alias("ls")]
        [Parameter(Position = 0)]
        [switch]
        $List
    )

    if ($Install)
    {
        if (Test-Path env:VIRTUAL_ENV)
        {
            python -m ipykernel install --name "$_PYTHON_VENV_PROMPT_PREFIX" --user
            return 0
        }
        Write-Output "Please install ipykernel only in virtual environment."
        return 1
    }
    if ($Remove)
    {
        jupyter kernelspec remove "$_PYTHON_VENV_PROMPT_PREFIX"
        return 0
    }
    if ($List)
    {
        jupyter kernelspec list
    }
}


#region     [Venv]

Class EnvNames : System.Management.Automation.IValidateSetValuesGenerator
{
    [string[]] GetValidValues()
    {
        return (Get-ChildItem -Path "$Script:VenvSet").Name
    }
}

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

    .DESCRIPTION
        .
    .PARAMETER create
        create a new venv with specified name.
    .PARAMETER activate
        activate the specified venv.
    .PARAMETER list
        list all venv.
    .PARAMETER remove
        remove the specified venv.
    .EXAMPLE
        C:/PS> venv -c -py 3.8 newVenv    # Create a new venv with python 3.8
        C:/PS> venv -a newVenv            # Activate the venv
        C:/PS> venv -d newVenv            # Delete the venv
        C:/PS> venv -l                    # List all venv
    .NOTES
        Author: ChenCYu
        Date:   July 09, 2020    
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [Alias("c")]
        [String] $create,
        [Parameter(Position = 0)]
        [Alias("U")]
        [ValidateSet([EnvNames])]
        [String] $upgrade,
        [Parameter(Position = 0)]
        [Alias("r")]
        [ValidateSet([EnvNames])]
        [String] $remove,
        [Parameter(Position = 0)]
        [Alias("l")]
        [Switch] $list = $false,
        [Parameter(Position = 0)]
        [Alias("a")]
        [ValidateSet([EnvNames])]
        [String] $activate,
        [Parameter(Position = 0)]
        [Alias("h")]
        [Switch] $help = $false,
        # [Parameter(Position = 1)]
        # [String] $EnvName,
        [Parameter()]
        [Alias("py")]
        [String] $PyVer
    )


    if ($help)
    {
        Get-Help -Name venv
        return 0
    }


    if (-Not (Test-Path "$VenvSet"))
    {
        mkdir "$VenvSet" | Out-Null
    }

    
    #region     [Operation]
    
    if ($create)
    {
        $EnvName = $create
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
        # EnvNameAutoCompletion
        return
    }
    if ($upgrade)
    {
        $EnvName = $upgrade
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
        $EnvName = $remove
        Remove-Item -r "$VenvSet/$EnvName"
        # EnvNameAutoCompletion
        return
    }
    if ($list)
    {
        list_env
        return
    }
    if ($activate)
    {
        $EnvName = $activate
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
Export-ModuleMember -Function venv, jupyterkernel
