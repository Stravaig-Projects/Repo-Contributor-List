& git log --format="\`"%ai\`",\`"%an\`",\`"%ae\`"" > raw-contributors.csv
$commits = Import-Csv raw-contributors.csv -Header Time,Name,Email
#Remove-Item .\raw-contributors.csv
$commits