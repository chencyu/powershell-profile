function yt($URL)
{
    youtube-dl -f bestaudio -v -x --audio-format mp3 --audio-quality 0 "$URL"
}

Export-ModuleMember -Function yt
