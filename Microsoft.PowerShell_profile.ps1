# 切換為UTF-8
# 比chcp 65001好
# 編碼其實有分輸入編碼與輸出編碼
# 從檔案讀的屬於輸入編碼，所以若.bat、.ps1用Big5編碼，輸入編碼用UTF-8就有可能出問題
# 有可能要視情況拿掉OutputEncoding這行
# 從 Python執行輸出導向給檔案時會亂碼，改採mode con cp select
# 或者設置$Env:PYTHONIOENCODING="utf-8"來解決
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding(65001)

# 上面兩行都執行，下面這行就不用
# mode con cp select=65001 | Out-Null

$ProfileRoot = "$HOME\Documents\PowerShell"

#region 檢測當前用戶是否為root/admin
function IsAdmin
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    if ($principal.IsInRole($adminRole))
    {
        return $true
    }
    return $false
}
#endregion

#region 設置指令的別名
Set-Alias -Name gh -Value Get-Help -Option AllScope
Set-Alias -Name nul -Value Out-Null -Option AllScope
Set-Alias -Name make -Value mingw32-make -Option AllScope
#endregion


function Edit-Profile
{
    if ($null -eq (whereis code))
    {
        notepad.exe $Profile
        return
    }

    # code (Split-Path -Parent (Get-Item $Profile).Target)
    code (Split-Path -Parent (Get-Item $Profile))
    return
}

# 從Lib中逐個資料夾，逐個載入腳本
Get-ChildItem -Path "${ProfileRoot}/pwsh_profiles" | ForEach-Object -Process {
    if ($_.Extension -eq ".ps1") { . "$_" }
}

