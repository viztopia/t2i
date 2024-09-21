# Set the root directory to the current directory
$rootDir = Get-Location

# Get the name of the root folder
$rootFolderName = (Split-Path -Path $rootDir -Leaf).ToUpper()

# Read the content.json file
$linkJson = Get-Content -Path (Join-Path -Path $rootDir -ChildPath "links.json") | ConvertFrom-Json

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

# Create subfolders and their index.html files
foreach ($subfolder in $linkJson.subfolders) {
    $subfolderPath = Join-Path -Path $rootDir -ChildPath $subfolder.name
    $indexPath = Join-Path -Path $subfolderPath -ChildPath "index.html"

    # Create subfolder if it doesn't exist
    if (-not (Test-Path $subfolderPath)) {
        New-Item -ItemType Directory -Path $subfolderPath | Out-Null
    }

    # Create or update index.html in the subfolder
    Create-RedirectHtml $subfolder.url | Out-File -FilePath $indexPath -Encoding UTF8 -Force
}

# Create the content for the root index.html
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$rootFolderName Links</title>
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
    <h1>$rootFolderName Links</h1>
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

# Write the content to index.html in the root directory, overwriting if it exists
$htmlContent | Out-File -FilePath (Join-Path -Path $rootDir -ChildPath "index.html") -Encoding UTF8 -Force

Write-Host "Root index.html and subfolders have been generated successfully."