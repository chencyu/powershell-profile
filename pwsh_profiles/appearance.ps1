function global:prompt
{
    Write-Host "$(Get-Date -format "(yyyy.MMMM.dd)(tt hh:mm)")" -ForegroundColor Blue -NoNewline
    Write-Host "[PowerShell]" -ForegroundColor DarkYellow
    Write-Host "$USER@$HOSTNAME" -ForegroundColor Green -NoNewline
    Write-Host ":[" -NoNewline
    Write-Host "$(Get-Location)" -ForegroundColor Blue -NoNewline
    Write-Host "]" -NoNewline
    if (IsAdmin) { Write-Host " #" -NoNewLine }
    else { Write-Host " $" -NoNewLine }
    Write-Host "`n>>" -NoNewline
    return " "
}

function Get-Font
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    (New-Object System.Drawing.Text.InstalledFontCollection).Families
}
