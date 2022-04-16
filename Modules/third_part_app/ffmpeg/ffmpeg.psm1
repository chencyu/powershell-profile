function Record
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Int]
        $Resolution = 1080,
        [Parameter()]
        [Int]
        $FrameRate = 60,
        [Parameter()]
        [string]
        $Encode = "hevc_nvenc"
    )
    $H = $Resolution
    $W = [Int]($H * 16 / 9)
    $NewVideo = "$(Get-Date -format "yyyy.MMMM.dd--tthh-mm-ss")"
    $VPATH = "$HOME/Videos".Replace("\", "/")
    if (-Not (Test-Path -Path "$VPATH/FFmpegScreenRecord")) { New-Item -Path "$VPATH" -Name "FFmpegScreenRecord" -ItemType Directory }

    
    # ffmpeg -f gdigrab -i desktop -c:v $Encode -s $W*$H "$VPATH/FFmpegScreenRecord/$NewVideo.mp4"
    ffmpeg -f gdigrab -i desktop -c:v $Encode -s $W*$H -framerate $FrameRate -crf 18 "$VPATH/FFmpegScreenRecord/$NewVideo.mp4"
}


function Cut-Video
{
    [CmdletBinding()]
    param
    (
        [Alias("i")]
        [Parameter(Mandatory, Position = 0)]
        [string]
        $InputFile,
        [Alias("s")]
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Start,
        [Alias("e")]
        [Parameter(Mandatory, Position = 2)]
        [string]
        $End,
        [Alias("o")]
        [Parameter(Mandatory, Position = 3)]
        [string]
        $OutFile
    )

    $StartTime = [System.DateTime]$Start
    $EndTime = [System.DateTime]$End
    $DiffTime = $EndTime.Subtract($StartTime)
    
    ffmpeg -ss "$Start" -i "$InputFile" -t "$DiffTime" -avoid_negative_ts make_zero -c copy "$OutFile"
}


function Cat-Video
{
    [CmdletBinding()]
    param
    (
        [Alias("l")]
        [Parameter(Mandatory, Position = 0)]
        [String[]]
        $List,
        [Alias("o")]
        [Parameter(Mandatory, Position = 1)]
        [string]
        $OutFile
    )

    $txtList = "$Env:TMP\concatenate_video.tmp"


    if ($List.Count -lt 2)
    {
        Write-Error -Message "Please provide at least 2 video to concatenate."
        return
    }


    touch $txtList
    foreach ($Video in $List)
    {
        $Video = (Resolve-Path -Path "$Video")
        Write-Output "file '$Video'" >> $txtList
    }
    ffmpeg -f concat -safe 0 -i $txtList -c copy "$OutFile"
    Remove-Item -Path $txtList
}


function Update-FFmpeg
{
    $OldProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z" -OutFile "$Env:TMP/ffmpeg.7z"
    7z e "$Env:TMP/ffmpeg.7z" -o"$HOME/bin" *.exe -r -y
    $ProgressPreference = $OldProgressPreference
    Remove-Item -Path "$Env:TMP/ffmpeg.7z"
}

# This must be end of modules
# Export-ModuleMember -Variable *
# Export-ModuleMember -Function *
