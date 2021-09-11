#region     [personal info configuration]
$git_username = "chencyu"
$git_useremail = "chencyu.code@gmail.com"
#endregion  [personal info configuration]

if (-Not (Get-Command vim))
{
    winget install vim
    if (-Not (Test-Path -Path "$HOME/.vim_runtime"))
    {
        git clone --depth=1 "https://github.com/amix/vimrc.git" "$HOME/.vim_runtime"
        Write-Output "set nu" >> "$HOME/.vim_runtime/my_configs.vim"
        Write-Output "set mouse=a" >> "$HOME/.vim_runtime/my_configs.vim"
    }
}

if (-Not (Get-Command git))
{
    winget install git
    git config --global user.email "$git_useremail"
    git config --global user.name "$git_username"
    git config --global core.autocrlf false
}
