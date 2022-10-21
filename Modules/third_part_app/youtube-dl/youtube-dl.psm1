function yt-mp3($URL)
{
    youtube-dl -f bestaudio -v -x --audio-format mp3 --audio-quality 0 "$URL"
}

function yt-upgrade()
{
    if (-Not (Test-Path -Path "${UTILS}\youtube-dl\bin")) { New-Item -Path "${UTILS}\youtube-dl\bin" -ItemType Directory -Force }
    if (Test-Path -Path "${UTILS}\youtube-dl\bin\youtube-dl.exe") { Remove-Item -Path "${UTILS}\youtube-dl\bin\youtube-dl.exe" }
    Write-Output $RealUri
    Invoke-WebRequest -Uri "https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe" -OutFile "${UTILS}\youtube-dl\bin\youtube-dl.exe"
}

Export-ModuleMember -Function yt-mp3, yt-upgrade
