# Fast file splitter

$from = = Read-Host "What is the full path and name of the log file to split? (e.g. D:\mylogfiles\mylog.txt)"
$rootName = Read-Host "What is the path and prefex where you want to extract the content? (e.g. d:\yourpath\FileBaseName)"
$ext = "txt"
$upperBound = 150MB


$fromFile = [io.file]::OpenRead($from)
$buff = new-object byte[] $upperBound
$count = $idx = 0
try {
    do {
        "Reading $upperBound"
        $count = $fromFile.Read($buff, 0, $buff.Length)
        if ($count -gt 0) {
            $to = "{0}.{1}.{2}" -f ($rootName, $idx, $ext)
            $toFile = [io.file]::OpenWrite($to)
            try {
                "Writing $count to $to"
                $tofile.Write($buff, 0, $count)
            } finally {
                $tofile.Close()
            }
        }
        $idx ++
    } while ($count -gt 0)
}
finally {
    $fromFile.Close()
}
