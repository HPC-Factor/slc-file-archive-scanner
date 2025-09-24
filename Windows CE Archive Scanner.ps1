# © HPC:Factor 2025. Windows CE local archive hash scanner
# Version: 1.0.0.20250924

# Please upload your archive scan file to https://www.hpcfactor.com/downloads/archive-check/ to see if you have
# any files that we do not have.
# Once run, the output file will be "Windows_CE_Files.txt" found on your Desktop.

 
# Enter the full Windows File System PAth to your Windows CE Archive here
$ArchivePath = "C:\My Archive"

########### DO NOT EDIT BELOW THIS LINE

$iCount      = 0
$arrPath     = New-Object System.Collections.ArrayList
$arrFilename = New-Object System.Collections.ArrayList
$arrLength   = New-Object System.Collections.ArrayList
$arrHash     = New-Object System.Collections.ArrayList
$files       = Get-ChildItem -Path "$ArchivePath\*" -Include "*.exe", "*.msi", "*.cab", "*.zip" -Recurse
$OutPath     = "$([Environment]::GetFolderPath(“Desktop”))\Windows_CE_Files.txt"

cls
Write-Host ""
Write-Host ""
Write-Host "HPC:Factor" -ForegroundColor Green
Write-Host "www.hpcfactor.com" -ForegroundColor White
Write-Host ""
Write-Host "Creates a file and MD5 hash listing of your Windows CE fle archive for comparison with the HPC:Factor Download Centre, SCL and HCL" -ForegroundColor Gray
Write-Host ""
Write-Host "Processing Files under:" -ForegroundColor Gray
Write-Host $ArchivePath -ForegroundColor Gray
Write-Host ""
Write-Host ""

# Process each file in your archive folder
foreach ($file in $files) {
    Write-Host "Processing $($file.FullName)" -ForegroundColor Green
    $arrPath.Add($file.FullName) > $nul                                             # The path is used only to inform you where a file is on your computer if you wish to find it later
    $arrFilename.Add($file.Name) > $nul                                             # The filename and extention
    $arrLength.Add($file.Length) > $nul                                             # File size in bytes
    $arrHash.Add($(Get-FileHash -Path $file.FullName -Algorithm MD5).Hash) > $nul   # MD5 hash aka the file fingerprint used to identify the same file with a different filename
    $iCount++
}

# If there is an existing output file, if there is delete it and start again
if (Test-Path $OutPath -PathType Leaf) {
    Remove-Item -Path $OutPath
}

if ($iCount -gt 0) {
    Write-Host "Creating file log at $OutPath. Please wait..." -ForegroundColor Cyan
    for ($i = 0; $i -lt $iCount; $i++) {
        $strLine = "$($arrPath[$i])|$($arrFilename[$i])|$($arrLength[$i])|$($arrHash[$i])"
        Add-Content -Path $OutPath -Value $strLine
    }
    Write-Host "Done!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please upload your file at 'https://www.hpcfactor.com/downloads/archive-check/' to see if you have something that the community does not."
}
Write-Host ""