if (IsAdmin) { $IDENTITY_SYMBOL = "#" }
else { $IDENTITY_SYMBOL = "$" }

function global:prompt {
    Write-Host "$(Get-Date -format "(yyyy.MM.dd)(hh:mm tt)")" -ForegroundColor Blue -NoNewline
    Write-Host "[PowerShell]" -ForegroundColor DarkYellow
    Write-Host "$USER@$HOSTNAME" -ForegroundColor Green -NoNewline
    Write-Host ":[" -NoNewline
    Write-Host "$((Get-Location).Path.Replace('\', '/'))" -ForegroundColor Blue -NoNewline
    Write-Host "]" -NoNewline
    Write-Host " $IDENTITY_SYMBOL" -NoNewLine
    Write-Host "`n>>" -NoNewline
    return " "
}

function Get-Font {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    (New-Object System.Drawing.Text.InstalledFontCollection).Families
}

function TabExpansion2 {
    # https://github.com/PowerShell/PowerShell/issues/18180
    <# Options include:
         RelativeFilePaths - [bool]
             Always resolve file paths using Resolve-Path -Relative.
             The default is to use some heuristics to guess if relative or absolute is better.

       To customize your own custom options, pass a hashtable to CompleteInput, e.g.
             return [System.Management.Automation.CommandCompletion]::CompleteInput($inputScript, $cursorColumn,
                 @{ RelativeFilePaths=$false }
    #>

    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    [OutputType([System.Management.Automation.CommandCompletion])]
    Param
    (
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [string] $inputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [int] $cursorColumn = $inputScript.Length,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
        [System.Management.Automation.Language.Ast] $ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
        [System.Management.Automation.Language.Token[]] $tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
        [System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $options = $null
    )

    End {
        $CompletionOutput = if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet') {
            [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#inputScript#>  $inputScript,
                <#cursorColumn#> $cursorColumn,
                <#options#>      $options)
        }
        else {
            [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#ast#>              $ast,
                <#tokens#>           $tokens,
                <#positionOfCursor#> $positionOfCursor,
                <#options#>          $options)
        }

        if ($CompletionOutput.CompletionMatches.Count -gt 0) {
            $Start = $CompletionOutput.ReplacementIndex
            $Typed = $inputScript.Substring($Start, [Math]::Min($CompletionOutput.ReplacementLength, $inputScript.Length - $Start))
            # 命令位置（行首、; | & ( 之後）必須保留 .\，否則無法執行目前目錄的檔案
            $Before = $inputScript.Substring(0, $Start).TrimEnd()
            $IsCommandPosition = $Before -eq '' -or $Before -match '[;|&(]$' -or $Before -match '(^|\s)(&|\.)$'

            # 使用者自己輸入了 .\ 或 ./ 就尊重，不動
            $StripDot = !$IsCommandPosition -and $Typed -notmatch '^[''"]?\.[\\/]'
            $ProviderTypes = @(
                [System.Management.Automation.CompletionResultType]::ProviderContainer,
                [System.Management.Automation.CompletionResultType]::ProviderItem
            )
            [System.Object[]]$NewCompletionList = foreach ($Item in $CompletionOutput.CompletionMatches) {
                if ($Item.ResultType -in $ProviderTypes) {
                    $NewText = $Item.CompletionText
                    if ($StripDot) { $NewText = $NewText -replace '^([''"&\s]*)\.\\', '$1' }
                    # 補全結果一律用 /（PowerShell 與 Windows API 都接受）
                    $NewText = $NewText.Replace('\', '/')
                    $ListText = $Item.ListItemText
                    [System.Management.Automation.CompletionResult]::new($NewText, $ListText, $Item.ResultType, $Item.ToolTip)
                }
                else {
                    $Item
                }
            }
            $CompletionOutput.CompletionMatches = $NewCompletionList
        }

        return $CompletionOutput
    }
}

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete()
    # PSReadLine 對目錄補全會自行附加 \，補全後改成 /
    $Line = $null; $Cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line, [ref]$Cursor)
    if ($Cursor -gt 0 -and $Line[$Cursor - 1] -eq '\') {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($Cursor - 1, 1, '/')
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor)
    }
}
# Set-PSReadlineKeyHandler -Key Tab -Shift -Function Complete
