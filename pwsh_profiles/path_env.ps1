$path_set = @(
    "C:\Program Files (x86)\Google\Chrome\Application",
    "$HOME\AppData\Local\Android\Sdk\platform-tools",
    "C:\Program Files\WinRAR",
    "C:\Program Files\7-Zip",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools",
    "C:\Program Files (x86)\sox",
    "$HOME\.app\mingw-w64\posix\mingw64\bin",
    "$HOME\bin"
)

function Add-Path
{
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

$ENV:INITIAL_Path = $Env:PATH

foreach ($path in $path_set)
{
    Add-Path -NewPath $path
}

# 加入當前路徑使當前資料夾下的執行檔可以直接執行
Add-Path -NewPath "."

