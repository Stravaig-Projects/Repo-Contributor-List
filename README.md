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
* `-AkaFilePath` is the path to the AKA configuration file. (See **Configuration File** section for more information.)

### Configuration files

The script can take a number of configuration files:

* Also Known As (AKA) file. A JSON file detailing users with multiple or changing identities.
* Ignored Emails. A text file that indicates email addresses that should not be conflated with other contributors.
* Ignored Names. A text file that indicates names that should not be conflated with other contributors.

#### AKA files

It may be that over time commit information has come from various systems, email addresses change, system names are used in preference for real ones, etc. Althought the scrip tries its best to reconcile this, sometimes it isn't possible. You can provide a file of hints so that it knows what entries are equivalent to each other. This is known as an AKA (Also Known As) file. 

By default the script will look for the AKA file relative to the script location, in `.stravaig/list-contributor-akas.json`. This can be overridden with the `-AkaFilePath` parameter. If no path is supplied, and a file is not found in the default location it won't attempt to use this for configuration. However, if a file path is supplied then it must exist.

##### AKA file format

The file is a JSON file, containing a single array of entries.

Each entry must contain a `primaryName`, `akas`, and `emails`.
```
[
  {
    "primaryName": "Colin Mackay",
    "akas": [
      "colin.mackay",
      "colinangusmackay"
    ],
    "emails": [
      "colin.mackay@TeamCity",
      "github@colinmackay.scot"
    ]
  }
]
```

* `primaryName` is the name you want to appear as the primary name for a person on the produced output file.
* `akas` is an array of also-known-as names. If there are none, supply an empty array. Otherwise provide an array of strings.
* `emails` is an array of email addresses associated with the person. If there are none, supply an empty array. Otherwise provide an array of strings.

#### Ignore Files

These are flat text files containing one entry per line. Items in theses files won't be conflated with existing contributors.

By default the script will look for the ignored email file relative to the script location, in `.stravaig/list-contributor-ignore-emails.json`. This can be overridden with the `-IgnoredEmailsPath` parameter. 

Similarly the ignored names file will, by default, be looked for in `.stravaig/list-contributor-ignore-names.json` and can be overridden with the `-IgnoredNamesPath` parameter.

It should also be noted that items that appear in the AKA files, if it exists, will also be ignored. AKA files are deemed to be the canonical form, and so should also not be conflated with other contributors.

## And finally...

In its current implementation the script creates an intermediate file called `raw-contributors.csv` in the current directory. It removes it as soon as it can. This contains the raw output from the git command.