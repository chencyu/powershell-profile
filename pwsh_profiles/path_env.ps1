$path_set = @(
    "${env:ProgramFiles(x86)}\Google\Chrome\Application",
    "$HOME\AppData\Local\Android\Sdk\platform-tools",
    "${env:ProgramFiles}\WinRAR",
    "${env:ProgramFiles}\7-Zip",
    "$HOME\AppData\Local\Programs\Microsoft VS Code\bin"
    # "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\Common7\Tools",
    # "${env:ProgramFiles(x86)}\sox",
    # "${env:ProgramFiles}\Vim\vim82",
    # "${env:ProgramFiles}\Git\cmd",
    "$UTILS\ffmpeg\bin",
    "$UTILS\mingw-w64\posix\mingw64\bin",
    "$UTILS\Git\cmd"
    "$UTILS\bin"
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

if (-Not $_ORIGINAL_PATH)
{
    $_ORIGINAL_PATH = $Env:PATH


    foreach ($path in $path_set)
    {
        Add-Path -NewPath $path
    }
    
    # 加入當前路徑使當前資料夾下的執行檔可以直接執行
    Add-Path -NewPath "."
}
