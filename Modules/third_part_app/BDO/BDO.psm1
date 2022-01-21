$BDO = "$DATA/Game/PC Game/黑色沙漠/.shell"

function 公會招生
{
    $公會招生文 = Get-Content -Path "$BDO/公會招生文.txt"
    Set-Clipboard -Value $公會招生文
}

function 會長號
{
    Get-Content -Path "$BDO/會長號.txt"
}

function 東飾品材料
{
    Get-Content -Path "$BDO/東飾品材料.txt"
}

function 黑洞位置圖
{
    &"$BDO/黑洞位置圖.jpg"
}

function 層數
{
    Get-Content -Path "$BDO/層數.txt"
}

Export-ModuleMember -Function 公會招生, 會長號, 東飾品材料, 黑洞位置圖, 層數
