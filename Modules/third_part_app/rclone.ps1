function Mount-Drive
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [string]
        $Remote_Target,
        [Parameter(Position = 1)]
        [string]
        $Target_Lttr
    )
    $Remote_Target = "JetsonNanoTKU"
    $Target_Lttr = "J:"

    $Cache_dir = "${Env:USERPROFILE}/.rclone/$Remote_Target/cache".Replace("\", "/")
    if (-Not (Test-Path -Path $Cache_dir))
    {
        New-Item -Path $Cache_dir -ItemType "Directory" -Force
    }

    rclone mount "$($Remote_Target):/" $Target_Lttr --cache-dir "$Cache_dir" `
        --allow-non-empty `
        --allow-other `
        --max-read-ahead 1G `
        --vfs-cache-max-age 72h0m0s `
        --vfs-cache-max-size 15G `
        --vfs-cache-mode full `
        --write-back-cache
}
