$esc = "`e"
$hideCursor = "$esc[?25l"

function Set-Cursor([int]$x, [int]$y)
{
    $Host.UI.RawUI.CursorPosition = @{ X = $x; Y = $y }
}

function Move-Cursor([int]$x, [int]$y)
{
    $Host.UI.RawUI.CursorPosition = `
    @{
        X = $Host.UI.RawUI.CursorPosition.X + $x;
        Y = $Host.UI.RawUI.CursorPosition.Y + $y
    }
}

# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
