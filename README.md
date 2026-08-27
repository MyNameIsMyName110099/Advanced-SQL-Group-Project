# Advanced SQL Group Project

This is the repo for our Advanced SQL semester project. We are building the back end
database for a fictitious restaurant in Ireland. Everything is done in SQL Server, there
is no front end.

Group members: MyNameIsMyName110099, ShortLeggedFlamingo, NicholasFearing

## Read this first: what is actually stored here

We are NOT storing the database in here. You cannot upload a SQL Server database to
GitHub. What we store here are the **scripts** that build the database.

Each of us has our own VM from netlab.nwtc.edu with its own copy of SQL Server. Your
`Restaurant` database only exists on your VM. Mine only exists on mine. They are not
connected.

That matters because of this line in the project instructions:

> ALL objects developed below will need to be part of your SQL Server Instance of the
> Restaurant database. If an object is missing from your SQL Server Instance, you will
> NOT receive credit for that piece.

So all three of us need every table, function, and stored procedure on our own VM. One
person writes a script, puts it here, and the other two download it and run it on their
own VM. That is the whole point of this repo. It keeps our three separate databases
matching.

The other reason: the VM instructions say **"SAVE OFTEN, NO backups of these VM's are
taken."** Reservations run out after about 4 hours. If the only copy of your work is on
the VM desktop, you can lose it. Upload your scripts here at the end of every session.

## How we work: everything gets reviewed first

We are not uploading straight into the project. Every script gets looked at by someone
else before it becomes part of the main copy. The way GitHub does that is called a
**pull request**, or PR.

Here is the idea in plain English. Instead of changing the real project, you make your own
side copy called a **branch**, put your file there, and then ask the group to look at it.
That request is the pull request. We read your SQL, say if anything looks wrong, and once
it looks good someone clicks **Merge** and your file becomes part of the real project on
the `main` branch.

Nothing you do in a pull request affects anybody until it is merged. You cannot break the
project by opening one. If your script is wrong, we catch it there instead of after three
people have already run it on their VMs.

You do not need to install Git and you do not need to type any commands. All of this is
buttons on github.com, and the VM has internet, so you can do it from inside the VM.

## Uploading a script and opening a pull request

1. In SSMS, go to **File > Save As** and save your query to the VM desktop. Use a clear
   name like `Week2_CreateTables.sql`.
2. Still inside the VM, open a browser, go to **github.com** and sign in.
3. Go to this repo (Advanced-SQL-Group-Project).
4. Click **Add file** near the top right, then **Upload files**.
5. Drag your .sql file into the box, or click **choose your files** and pick it off the
   desktop.
6. If it belongs in a folder, put the folder in front of the file name in the name box,
   like `Week2-Database/Week2_CreateTables.sql`. The slash makes the folder.
7. At the bottom, type a short message saying what it is, like "Add week 2 table creation
   script".
8. **This is the important part.** Under that message there are two circle options. Do NOT
   leave it on "Commit directly to the `main` branch". Click the second one, **"Create a
   new branch for this commit and start a pull request"**. It fills in a branch name for
   you, which is fine, or you can type something like `week2-tables-mason`.
9. Click **Propose changes**.
10. The next page is the pull request itself. Add a sentence or two in the description
    saying what the script does and anything you are unsure about. Then click **Create
    pull request**.
11. Post in the group chat that you opened one.

That is it. Your script is now waiting for review.

## How to review a pull request

1. On the repo, click the **Pull requests** tab at the top. Open the one you want.
2. Click the **Files changed** tab. This shows the SQL. Green lines with a `+` are lines
   being added.
3. To say something about a specific line, hover over that line and click the blue **+**
   that shows up on the left. Type your comment and click **Start a review**. Do that for
   every line you want to mention.
4. When you are done, click the green **Review changes** button at the top right and pick
   one:
   - **Comment** if you just have notes.
   - **Approve** if it looks good to merge.
   - **Request changes** if something has to be fixed before it goes in.
5. Click **Submit review**.

Actually run the script on your VM before you approve it. Reading SQL is not the same as
knowing it works, and the whole reason we are doing this is so a broken script does not
end up on all three of our instances.

GitHub will not let you approve your own pull request, which is fine since there are three
of us. Get one other person to approve before merging.

## How to fix a script after someone requests changes

You do not open a new pull request. You add the fixed file to the same branch and the open
PR updates itself.

1. Fix the script in SSMS on your VM and save it again with the **exact same file name**.
2. On the repo page, click the branch dropdown on the left (it says `main`) and pick your
   branch off the list.
3. Now do **Add file > Upload files** the same as before, into the same folder path.
4. At the bottom this time, leave it on **"Commit directly to the [your branch] branch"**.
   You are already on your own branch, so that is safe.
5. Click **Commit changes**. Go back to the pull request and it will show the new version.
6. Reply to the comments so the reviewer knows to look again.

## Merging it in

Once someone has approved it:

1. Open the pull request and go to the **Conversation** tab.
2. Click **Merge pull request**, then **Confirm merge**.
3. Click **Delete branch**. This is just cleanup, it does not delete your file. The file is
   on `main` now.
4. Tell the group chat it got merged so everyone knows to pull the new script down and run
   it on their own VM.

## How to get a file FROM GitHub onto your VM

1. Inside the VM, open a browser and go to the repo. Make sure you are on the `main`
   branch.
2. Click into the folder and click the .sql file you want.
3. Click the **Download raw file** button (the download arrow at the top right of the
   file).
4. Open it in SSMS, check you are connected to your own server, and run it.

You can also just click the file, select all the code on the page, copy it, and paste it
into a new query window. That is usually faster for one script.

## The SSIS and SSRS projects (weeks 5 and 6)

Those are whole Visual Studio project folders, not single text files. On the VM desktop,
right click the folder and pick **Send to > Compressed (zipped) folder**, then upload the
.zip through a pull request the same way.

One thing to know: GitHub cannot show you what changed inside a .zip, so the Files changed
tab will just say the file is binary. To review those, download the zip and open the
project yourself.

## Rules so we do not step on each other

**Everything goes through a pull request.** Nobody commits straight to `main`, including
whoever owns the repo.

**One person per file.** Say in the group chat which file you are taking before you start.
If two of us change the same file on different branches, GitHub calls it a merge conflict
and it turns into a headache.

**Post in the group chat** when you open a PR, when you approve one, and when you merge
one.

**Run scripts in order.** You cannot insert rows into a table that does not exist yet.
That is why the files are numbered.

## Do not upload these

- Database files: `.mdf`, `.ldf`, `.ndf`, `.bak`, `.trn`. These are the actual database.
  They are huge and they do not belong here.
- The VM login or the `sa` password. This repo has to be public later for the week 5 and 6
  assignments, so no passwords in any file.
- Visual Studio junk folders: `bin`, `obj`, `.vs`.

## Planned folder layout

```
Week2-Database/        create database, create tables, relationships, seed data
Week3-Functions/       the five functions
Week4-Procs-Indexes/   stored procedures, indexes, CRUD procedures
Week5-SSIS/            FinalProjectSSISFileLoad, FinalProjectTableExport
Week6-SSRS/            SSRS Reports
Week7-Security/        roles, users, object permissions
Week8-Backup/          backup, transaction log, shrink
docs/                  database diagram, index reasoning, other write ups
screenshots/           the test screenshots the project asks for
```

## Order to run everything on a fresh VM

1. Create database
2. Create tables
3. Relationships
4. Insert the seed data
5. Functions
6. Stored procedures
7. Indexes
8. Security and permissions

## To do

- This repo is private right now. Weeks 5 and 6 both say to submit a link to a **public**
  GitHub repo, so we need to either make this one public or set up a second public one
  before week 5.
- Ask the instructor about week 4. Items 1b and 1c are both named `spN_RecipeDetails` but
  they return different things, so one of them needs a different name.
- Get `SSIS File Load.txt` off Canvas. Week 5 needs it.
