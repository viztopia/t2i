# Function to create redirect HTML content
function Create-RedirectHtml($url) {
    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url=$url">
    <title>Redirecting...</title>
</head>
<body>
    <p>If you are not redirected automatically, <a href="$url">click here</a>.</p>
</body>
</html>
"@
}

# Function to process a directory
function Process-Directory($directoryPath) {
    $linksJsonPath = Join-Path -Path $directoryPath -ChildPath "links.json"
    
    if (Test-Path $linksJsonPath) {
        # Read the links.json file
        $linkJson = Get-Content -Path $linksJsonPath | ConvertFrom-Json

        # Create subfolders and their index.html files
        foreach ($subfolder in $linkJson.subfolders) {
            $subfolderPath = Join-Path -Path $directoryPath -ChildPath $subfolder.name
            $indexPath = Join-Path -Path $subfolderPath -ChildPath "index.html"

            # Create subfolder if it doesn't exist
            if (-not (Test-Path $subfolderPath)) {
                New-Item -ItemType Directory -Path $subfolderPath | Out-Null
            }

            # Create or update index.html in the subfolder
            Create-RedirectHtml $subfolder.url | Out-File -FilePath $indexPath -Encoding UTF8 -Force
        }

        # Create the content for the index.html
        $folderName = (Split-Path -Path $directoryPath -Leaf).ToUpper()
        $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$folderName Links</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin-bottom: 10px;
        }
        a {
            color: #0066cc;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1>$folderName Links</h1>
    <ul>
"@

        # Add links for each subfolder
        foreach ($subfolder in $linkJson.subfolders) {
            $capitalizedName = (Get-Culture).TextInfo.ToTitleCase($subfolder.name)
            $htmlContent += "        <li><a href=`"$($subfolder.name)/index.html`" target=`"_blank`">$capitalizedName</a></li>`n"
        }

        # Close the HTML content
        $htmlContent += @"
    </ul>
</body>
</html>
"@

        # Write the content to index.html in the current directory
        $htmlContent | Out-File -FilePath (Join-Path -Path $directoryPath -ChildPath "index.html") -Encoding UTF8 -Force

        Write-Host "Generated index.html for $directoryPath"
    }
    else {
        # If no links.json, recursively process subdirectories
        Get-ChildItem -Path $directoryPath -Directory | ForEach-Object {
            Process-Directory $_.FullName
        }
    }
}

# Set the root directory to the current directory
$rootDir = Get-Location

# Start processing from the root directory
Process-Directory $rootDir

Write-Host "Index generation completed successfully."