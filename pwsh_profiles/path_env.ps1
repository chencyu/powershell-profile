$path_set = @(
    "${env:ProgramFiles}\Google\Chrome\Application",
    "$HOME\AppData\Local\Android\Sdk\platform-tools", # https://dl.google.com/android/repository/platform-tools-latest-windows.zip
    "$HOME\AppData\Local\Programs\Microsoft VS Code\bin",
    "$HOME\.local\bin",
    "$HOME\.android\bin"
)

function Add-Path {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $NewPath
    )
    $Env:PATH = "$NewPath;" + $Env:PATH

    # 整理PATH，避免一些不標準的語法
    $Env:PATH = $Env:PATH.Replace(";;", ";")
    if ($Env:PATH[-1] -eq ";") { $Env:PATH = $Env:PATH.Remove($Env:PATH.Length - 1) }
}

# 設置額外的路徑到環境變數Path，避免Registry中的Path超過2048字元

if (-Not $_ORIGINAL_PATH) {
    $_ORIGINAL_PATH = $Env:PATH


    foreach ($path in $path_set) {
        Add-Path -NewPath $path
    }

    # 加入當前路徑使當前資料夾下的執行檔可以直接執行
    Add-Path -NewPath "."

    # 移除SVP4PRO自己設定的PATH
    $env:PYTHONPATH = ""
}
