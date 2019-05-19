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
    Write-Host
    Write-Host "Loop iteration $i :"
    $nextCommit = $commits[$i];
    Write-Host $nextCommit;
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
Write-Output $contributors
