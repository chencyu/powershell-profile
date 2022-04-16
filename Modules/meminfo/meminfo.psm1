function MemUsage
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Keep
    )
    # Cursur Setting
    $esc = [char]27
    
    # let the caret move to column (horizontal) pos 12
    $column = 12
    $resetHorizontalPos = "$esc[${column}G"
    $gotoFirstColumn = "$esc[0G"
        
    $hideCursor = "$esc[?25l"
    $showCursor = "$esc[?25h"
    $resetAll = "$esc[0m"


    # FreePhysicalMemory     : 9569344
    # FreeVirtualMemory      : 9207868
    # MaxProcessMemorySize   : 137438953344
    # TotalVirtualMemorySize : 19724324
    # TotalVisibleMemorySize : 16717860

    $Mem_Free = (Get-CimInstance -Class Win32_OperatingSystem).FreePhysicalMemory
    $Mem_Total = (Get-CimInstance -Class Win32_OperatingSystem).TotalVisibleMemorySize
    $Mem_Usage = $Mem_Total - $Mem_Free
    Write-Host "${hideCursor}`r[" -NoNewline
    for ($i = 0; $i -lt 20; $i++)
    {
        if ((100 * $i / 20) -lt (100 * $Mem_Usage / $Mem_Total))
        {
            Write-Host "${hideCursor}|" -NoNewline -ForegroundColor Green
        }
        else
        {
            Write-Host "${hideCursor} " -NoNewline
        }
    }
    $Mem_Percent = [UInt64](100 * $Mem_Usage / $Mem_Total)
    Write-Host "${hideCursor}] [$Mem_Percent%]" -NoNewline
    
    if ($Keep) { Write-Host "${hideCursor}  [$([UInt64]($Mem_Usage/1024))MB / $([UInt64]($Mem_Total/1024))MB]" -NoNewline }
    else { Write-Host "${hideCursor}  [$([UInt64]($Mem_Usage/1024))MB / $([UInt64]($Mem_Total/1024))MB]" }
}

function MemMonitor
{
    Write-Host ""
    Write-Host "Press [Ctrl + C] to stop the monitor"
    while ($true)
    {
        MemUsage -Keep
        Start-Sleep -Milliseconds 500
    }
    Write-Host ""
    return 0
}

# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
