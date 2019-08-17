# Repo-Contributor-List
A script that determines the contributors to a git repository.

## How it works
The scripts looks through the repository history for the authors. The script assumes that a person can change their name and their email. All emails and names that correspond are assumed to be one person. e.g. 
> * "Colin Mackay" with email colin@mackay.example.com
> * "Colin Mackay" with email colin@users.noreply.github.com
> * "Colin A. Mackay" with email colin@users.noreply.github.com

... are all one person.

## How to run the script

### Prerequesites

Git needs to be installed and referenced in the `path` environment variable.

### Running the script

The script `list-contributors.ps1` should be copied to the base of your repository. If you are happy with the default options, you can run it at a powershell prompt like this:

```
PS C:\dev\my-git-repository> .\list-contributors.ps1
```

You can also run it as part of a build script to automatically create a list of contributors to a repository.

### Options

* `-OutputFile` is the path to the file you want to output the results to. By default it will create/overwrite a file called `contributors.md` in the current directory.
* `-DateTimeFormat` is the format that the date and time will appear in the output file. Defaults to `dddd, d MMMM, yyyy @ HH:mm:ss zzz` if omitted.
* `-TimeFormat` is the format that the time will appear in the output file. Defaults to `HH:mm:ss zzz` if omitted.
* `-SortOrder` orders the contributors list in the output file. It can be one of `Name`, `FirstCommit`, `LastCommit`, or `CommitCount`. Defaults to `Name` if omitted.
* `-SortDirection` determines the direction of the sort. It can be either `Ascending` or `Descending`. Defaults to `Ascending` if omitted.

## And finally...

In its current implementation the script creates an intermediate file called `raw-contributors.csv` in the current directory. It removes it as soon as it can. This contains the raw output from the git command.