
# Python Environment Variable
$Env:PYTHONIOENCODING = "utf-8"
$VenvSet = "$Env:UserProfile/.venv".Replace("\", "/")
function jupyterkernel {
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

    if ($Install) {
        if (Test-Path env:VIRTUAL_ENV) {
            python -m ipykernel install --name "$_PYTHON_VENV_PROMPT_PREFIX" --user
            return 0
        }
        Write-Output "Please install ipykernel only in virtual environment."
        return 1
    }
    if ($Remove) {
        jupyter kernelspec remove "$_PYTHON_VENV_PROMPT_PREFIX"
        return 0
    }
    if ($List) {
        jupyter kernelspec list
    }
}


#region     [Venv]

Class EnvNames : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return (Get-ChildItem -Path "$Script:VenvSet").Name
    }
}

function IsVenv($EnvName) {
    if (Test-Path "$VenvSet/$EnvName") {
        return $true
    }
    else {
        return $false
    }
}

function hint_venv_not_exist {
    Write-Output "" "尚未建立名為`"$EnvName`"的專案" ""
}

function Exit-IfVenvNotAvailable([string]$EnvName) {
    if (Test-Path -Path "$VenvSet/$EnvName/Scripts/python.exe") {
        & "$VenvSet/$EnvName/Scripts/python.exe" --version *>$null
        if ($LASTEXITCODE -eq 0) { return }
    }
    Write-Error "`"$EnvName`" does NOT created or been corrupted, please create or remove and re-create it."
    exit 1
}

function list_env {
    $envList = Get-ChildItem "$VenvSet/"
    if (-Not $envList) {
        Write-Output "" "您目前沒有任何虛擬環境專案" ""
    }
    else {
        Write-Output "" "已建立的虛擬環境專案" ""
        for ($i = 0; $i -lt $envList.Count; $i++) {
            Write-Output ("({0:d2})  $($envList[$i].Name)" -f ($i + 1))
        }
        Write-Output ""
    }
}

function pipinit($EnvName) {
    &"$VenvSet/$EnvName/Scripts/Activate.ps1"
    python -m pip install -U pip
    pip install -U setuptools
    pip install -U wheel
    pip install -U pip-autoremove
}

function venv {
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
        [Alias("u")]
        [ValidateSet([EnvNames])]
        [String] $update,
        [Parameter(Position = 0)]
        [Alias("r")]
        [ValidateSet([EnvNames])]
        [String] $remove,
        [Parameter(Position = 0)]
        [Alias("v")]
        [ValidateSet([EnvNames])]
        [String] $version,
        [Parameter(Position = 0)]
        [Alias("a")]
        [ValidateSet([EnvNames])]
        [String] $activate,
        [Parameter(Position = 0)]
        [Alias("l")]
        [Switch] $list = $false,
        [Parameter(Position = 0)]
        [Alias("h")]
        [Switch] $help = $false,
        [Parameter()]
        [Alias("py")]
        [String] $PyVer
    )


    if ($help) {
        Get-Help -Name venv
        return 0
    }


    if (-Not (Test-Path "$VenvSet")) {
        mkdir "$VenvSet" | Out-Null
    }


    #region     [Operation]

    if ($create) {
        $EnvName = $create
        if (IsVenv $EnvName) {
            Write-Output "EnvName: $EnvName"
            Write-Error -Message "已經創建過此專案，請換另一個名稱"
            return
        }
        if ($PyVer) { Write-Output "python$($PyVer.Replace('.', ''))"; & python$($PyVer.Replace('.', '')) -m venv "$VenvSet/$EnvName" }
        else { python -m venv "$VenvSet/$EnvName" }

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create virtual environment '$EnvName'."
            if (Test-Path "$VenvSet/$EnvName") {
                Remove-Item -Recurse -Force "$VenvSet/$EnvName"
            }
            return
        }

        # SetIniScript "$EnvName"
        pipinit "$EnvName"
        deactivate
        # EnvNameAutoCompletion
        return
    }
    if ($upgrade) {
        $EnvName = $upgrade
        Exit-IfVenvNotAvailable $EnvName
        if ($PyVer) { & python${$PyVer.Replace('.', '')} -m venv --upgrade "$VenvSet/$EnvName" }
        else { python -m venv --upgrade "$VenvSet/$EnvName" }
        return
    }
    if ($remove) {
        $EnvName = $remove
        Remove-Item -Recurse "$VenvSet/$EnvName"
        # EnvNameAutoCompletion
        return
    }
    if ($activate) {
        $EnvName = $activate
        if (-Not "$EnvName") {
            Write-Output "" "請提供虛擬環境專案名稱" ""
            # Write-Output "" "Please provide envName" ""
        }
        Exit-IfVenvNotAvailable $EnvName
        &"$VenvSet/$EnvName/Scripts/Activate.ps1"
        return
    }
    if ($list) {
        list_env
        return
    }
    if ($version) {
        $EnvName = $version
        if (-Not "$EnvName") {
            Write-Output "" "請提供虛擬環境專案名稱" ""
            # Write-Output "" "Please provide envName" ""
        }
        Exit-IfVenvNotAvailable $EnvName
        & "$VenvSet/$EnvName/Scripts/python.exe" --version
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
