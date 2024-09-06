# Define the path to the config file
$configFilePath = "./SprayBlockerConfig.txt"

# Check if the config file exists
if (-Not (Test-Path -Path $configFilePath)) {
    # Prompt the user for the URL and folder path
    Write-Output "We didn't find a config file for your information, So we need your input."
    Write-Output "This will be the URL you use for a blacklist, a raw pastebin would be the best option"
    $url = Read-Host "Enter URL"
    Write-Output "This will be your folder local to you, Your sunrust spray folder will often be in data/sr_sprays"
    Write-Output "This is being asked because where your Garry's mod localization will be is dependent on you."
    $folderPath = Read-Host "Enter the folder path"

    # Create the config file with the provided input
    "$url`n$folderPath" | Out-File -FilePath $configFilePath
} else {
    # Read the config file to get the URL and folder path
    $config = Get-Content -Path $configFilePath
    $url = $config[0].Trim()
    $folderPath = $config[1].Trim()
    Write-Output "Spray Blocker is monitoring Sprays..."
    continue
}

$timer = [System.Diagnostics.Stopwatch]::StartNew()

while ($true) {
    if ($timer.ElapsedMilliseconds -ge 1000) {
        try {
            # Fetch the content from the URL
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing
            $lines = $response.Content -split "`n"

            # Initialize arrays for Names and Filenames
            $Names = @()
            $Filenames = @()

            # Loop through each line in the array
            foreach ($line in $lines) {
                if ($line.Trim().StartsWith("--")) {
                    # Add to Names array if the line is a comment
                    $Names += $line.Trim().Substring(2).Trim()
                } else {
                    # Add to Filenames array if the line is not a comment
                    $Filenames += $line.Trim()
                }
            }

            # Loop through each filename in the Filenames array
            for ($i = 0; $i -lt $Filenames.Length; $i++) {
                $partialName = $Filenames[$i]
                $userName = $Names[$i]

                # Get all files in the directory that match the partial name
                $files = Get-ChildItem -Path $folderPath -Filter "$partialName*"

                # Loop through each matching file and delete it
                foreach ($file in $files) {
                    Remove-Item -Path $file.FullName -Force
                    Write-Output "Deleted File $($file.FullName) from $userName"
                }
            }
        } catch {
            Write-Output "Failed to retrieve the content from the URL or an error occurred: $_"
        }

        # Reset the timer
        $timer.Restart()
    }
}