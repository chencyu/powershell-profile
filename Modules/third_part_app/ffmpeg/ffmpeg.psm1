﻿function Record
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Int]
        $Resolution = 1080,
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
    ffmpeg  -f gdigrab -i desktop -c:v $Encode -s $W*$H -framerate 30 `
        -f alsa -i default -crf 18 "$VPATH/FFmpegScreenRecord/$NewVideo.mp4"
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
    
    ffmpeg -ss "$Start" -hwaccel nvdec -i $InputFile -t "$DiffTime" -avoid_negative_ts make_zero -c:v hevc_nvenc -x265-params lossless=1 $OutFile
}


function Cat-Video
{
    [CmdletBinding()]
    param
    (
        [Alias("l")]
        [Parameter(Mandatory, Position = 0)]
        [array]
        $List,
        [Alias("o")]
        [Parameter(Mandatory, Position = 1)]
        [string]
        $OutFile
    )


    if ($List.Count -lt 2)
    {
        Write-Error -Message "Please provide at least 2 video to concatenate."
    }


    Write-Output "" > "$Env:TMP\concatenate_video.tmp"
    for ($i = 0; $i -lt $List.Count; $i++)
    {
        $Video = (Resolve-Path -Path "$($List[$i])")
        Write-Output "file '$Video'" >> "$Env:TMP\concatenate_video.tmp"
    }
    ffmpeg -f concat -safe 0 -i "$Env:TMP\concatenate_video.tmp" -c copy "$OutFile"
}


function Update-FFmpeg
{
    Invoke-WebRequest -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z" -OutFile ""
}

# This must be end of modules
Export-ModuleMember -Variable *
Export-ModuleMember -Function *
