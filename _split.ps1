$CHAPTERS_PATH = "Chapters"

$mkvName = Get-Item '*.mkv'

if(!$mkvName.Exists) {
    Write-Output "[ERROR]mkv file not fount, exit"
    Exit
}
Write-Output "[INFO]Get mkv file" $mkvName.Name

if (!(Test-Path $CHAPTERS_PATH)) {
    Write-Output "[INFO]Create directory: $CHAPTERS_PATH"
    New-Item -itemType Directory -Path . -Name $CHAPTERS_PATH
}
else {
    Write-Output "[INFO]Directory: $CHAPTERS_PATH already exists."
}

Write-Output "[INFO]Try use mkvextract to get chapters"
mkvextract.exe $mkvName.FullName chapters "$CHAPTERS_PATH/_chapters.xml"

[xml]$chapters = Get-Content "$CHAPTERS_PATH/_chapters.xml"

$chapterList = $chapters.Chapters.EditionEntry.ChapterAtom

if ($null -eq $chapterList) {
    Write-Output "[ERROR]Cannot get chapters infomation from $CHAPTERS_PATH/_chapters.xml"
} else {
    $chapterCount = $chapterList.Length
    Write-Output "[INFO]Get $chapterCount chapters from xml"
}

for ($i = 1; $i -lt $chapterCount; $i++) {
    $chapter = $chapterList[$i - 1]
    $nextChapter = $chapterList[$i]
    $chapterName = $chapter.ChapterDisplay.ChapterString

    Write-Output "[INFO]Try codec $chapterName"
    ffmpeg -ss $chapter.ChapterTimeStart -to $nextChapter.ChapterTimeStart -i $mkvName -vcodec hevc -acodec flac $chapterName
}