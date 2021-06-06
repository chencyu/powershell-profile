$IP_History_Dir = "$HOME\.log\iphistory"
function myip
{
    $Old_ProgressPreference = $ProgressPreference
    $ProgressPreference = 'silentlyContinue'              # 避免Invoke-Webrequest顯示進度干擾畫面
    $Current_IP = [string]$(Invoke-WebRequest -Uri "ifconfig.me/ip" -UseBasicParsing)
    Write-Output $Current_IP
    $ProgressPreference = $Old_ProgressPreference         # 復原顯示進度
    
    if (-Not (Test-Path -Path "$IP_History_Dir"))
    {
        New-Item -Path "$IP_History_Dir" -ItemType "Directory" -Force | Out-Null
    }
    Add-Content -Path "$IP_History_Dir/$Env:HOSTNAME.log" -Value "$(Get-Date -format "[yyyy.MM.dd][HH:mm][IP]")[$Current_IP]"
    return
}

function iphistory
{
    Get-Content -Path "$IP_History_Dir/$Env:HOSTNAME.log"
}

# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
