function 公會招生
{
    $公會招生文 = Get-Content -Path "$Env:GDrive/Game/PC Game/黑色沙漠/公會招生文.txt"
    Set-Clipboard -Value $公會招生文
}
