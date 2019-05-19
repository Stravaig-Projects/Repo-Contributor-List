# Repo-Contributor-List
A script that determines the contributors to a git repository.

## How it works
The scripts looks through the repository history for the authors. The script assumes that a person can change their name and their email. All emails and names that correspond are assumed to be one person. e.g. 
> * "Colin Mackay" with email colin@mackay.example.com
> * "Colin Mackay" with email colin@users.noreply.github.com
> * "Colin A. Mackay" with email colin@users.noreply.github.com

... are all one person.

