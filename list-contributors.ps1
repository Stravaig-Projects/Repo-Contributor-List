# This script is licences under an MIT licence. Licence details can be found at
# https://github.com/Stravaig-Projects/Repo-Contributor-List/blob/master/LICENSE
# Please keep this licence notice link intact.
#
# Full details of this script can be found at:
# https://github.com/Stravaig-Projects/Repo-Contributor-List

param
(
    [parameter(Mandatory=$false)]
    [string]$OutputFile = "contributors.md",

    [parameter(Mandatory=$false)]
    [string]$DateTimeFormat = "dddd, d MMMM, yyyy @ HH:mm:ss zzz",

    [parameter(Mandatory=$false)]
    [string]$TimeFormat = "HH:mm:ss zzz"
)

function Test-StringEquality($A, $B)
{
    $result = [string]::Compare($A, $B, $true) -eq 0
    return $result;
}

function Test-Name($contributor, $committerName)
{
    $nameMatch = $null -ne $contributor.Names.Where({ Test-StringEquality $_ $committerName }, "First", 1)[0];
    return $nameMatch;
}

function Test-Email($contributor, $committerEmail)
{
    $emailMatch = $null -ne $contributor.Emails.Where({ Test-StringEquality $_ $committerEmail }, "First", 1)[0];
    return $emailMatch;
}
function Test-Contributor($contributor, $commit)
{
    $nameMatch = Test-Name -Contributor $contributor -Commit $commit.Name;
    if ($nameMatch){
        return $true;
    }

    $emailMatch = Test-Email -Contributor $contributor -Commit $commit.Email;
    return $emailMatch;
}

& git log --format="\`"%ai\`",\`"%an\`",\`"%ae\`"" > raw-contributors.csv
$commits = Import-Csv raw-contributors.csv -Header Time,Name,Email
Remove-Item .\raw-contributors.csv
$contributors = @();
for($i = 0; $i -lt $commits.Length; $i++)
{
    #Write-Host
    #Write-Host "Loop iteration $i :"
    $nextCommit = $commits[$i];
    #Write-Host $nextCommit;
    $commitTime = [DateTime]::ParseExact($nextCommit.Time, "yyyy-MM-dd HH:mm:ss zzz", [CultureInfo]::InvariantCulture);
    $contributor = $contributors.Where({Test-Contributor -Contributor $_ -Commit $nextCommit}, "First", 1)[0]
    if ($null -eq $contributor)
    {
        $contributor = New-Object -TypeName PSObject -Property @{Names=@($nextCommit.Name); Emails=@($nextCommit.Email); FirstCommit=$commitTime; LastCommit=$commitTime; CommitCount=1};
        $contributors += $contributor;
    }
    else 
    {
        if (-not (Test-Name -Contributor $contributor -CommitterName $nextCommit.Name))
        {
            $contributor.Names += $nextCommit.Name;
        }

        if (-not (Test-Email -Contributor $contributor -CommitterEmail $nextCommit.Email))
        {
            $contributor.Emails += $nextCommit.Email;
        }
        if ($commitTime -lt $contributor.FirstCommit)
        {
            $contributor.FirstCommit = $commitTime;
        }
        if ($commitTime -gt $contributor.LastCommit)
        {
            $contributor.LastCommit = $commitTime
        }
        $contributor.CommitCount += 1;
    }
}    


"# Contributors" | Out-File $OutputFile -Encoding utf8
"" | Out-File $OutputFile -Append -Encoding utf8
"This is a list of all the contributors to this repository" | Out-File $OutputFile -Append -Encoding utf8
"" | Out-File $OutputFile -Append -Encoding utf8
foreach($contributor in $contributors)
{
    $name = $contributor.Names[0];
    $aka = ""
    if ($contributor.Names.Length -gt 1)
    {
        $aka = " (AKA ";
        $isFirst = $true;
        for($i = 1; $i -lt $contributor.Names.Length; $i++)
        {
            if (-not $isFirst) { $aka += ", " }
            $aka += "*"+$contributor.Names[$i]+"*";
        }
        $aka += ")"
    }
    $numCommits = $contributor.CommitCount
    $commits = "commit"; if ($numCommits -gt 1) { $commits += "s" }
    $start = $contributor.FirstCommit.ToString($DateTimeFormat);
    if ($contributor.FirstCommit.Date -eq $contributor.LastCommit.Date)
    {
        $end = $contributor.LastCommit.ToString($TimeFormat);
    }
    else {
        $end = $contributor.LastCommit.ToString($DateTimeFormat);        
    }
    "**$name**$aka contributed $numCommits $commits from $start to $end" | Out-File $OutputFile -Append -Encoding utf8
    "" | Out-File $OutputFile -Append -Encoding utf8
}


Write-Output $contributors
