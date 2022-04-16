function Analyze
{
    if ($null -eq $args[0])
    {
        Write-Error -Message "Please provide drive letter will be trimed."
        return
    }

    if (IsAdmin)
    {
        Optimize-Volume -DriveLetter $args[0] -Analyze -Verbose
        Pause
    }
    else
    {
        sudo Analyze $args[0]
    }
}


function FStrim
{
    if ($null -eq $args[0])
    {
        Write-Error -Message "Please provide drive letter will be trimed."
        return
    }

    if (IsAdmin) { Optimize-Volume -DriveLetter $args[0] -ReTrim -Verbose }
    else
    {
        sudo FStrim $args[0]
    }
}


function Defrag
{
    if ($null -eq $args[0])
    {
        Write-Error -Message "Please provide drive letter will be trimed."
        return
    }

    if (IsAdmin) { Optimize-Volume -DriveLetter $args[0] -Defrag -Verbose }
    else
    {
        sudo Defrag $args[0]
    }
}


# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
