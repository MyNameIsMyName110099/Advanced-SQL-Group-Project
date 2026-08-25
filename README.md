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
person writes a script, uploads it here, and the other two download it and run it on
their own VM. That is the whole point of this repo. It keeps our three separate
databases matching.

The other reason: the VM instructions say **"SAVE OFTEN, NO backups of these VM's are
taken."** Reservations run out after about 4 hours. If the only copy of your work is on
the VM desktop, you can lose it. Upload your scripts here at the end of every session.

## How to get a .sql file from the VM to GitHub

You do not need to install anything and you do not need to learn Git commands. The VM
has internet, so you just upload the file to the website from inside the VM.

1. In SSMS, go to **File > Save As** and save your query. Put it on the VM desktop so it
   is easy to find. Use a clear name like `Week2_CreateTables.sql`.
2. Still inside the VM, open a browser and go to **github.com**. Sign in with your own
   GitHub account.
3. Go to this repo (Advanced-SQL-Group-Project).
4. Click the **Add file** button near the top right, then click **Upload files**.
5. Drag your .sql file into the box, or click **choose your files** and pick it off the
   desktop.
6. In the box at the bottom, type a short message saying what it is. Something like
   "Add week 2 table creation script".
7. Click **Commit changes**.

That is it. The file is now on GitHub and the rest of us can see it.

If you want to put it in a folder, type the folder name in front of the file name when
you upload, like `Week2-Database/Week2_CreateTables.sql`. The slash creates the folder.

### Copy and paste instead

For a short script you can skip saving a file. Select all of your query in SSMS and copy
it, then use the clipboard panel in the NetLab viewer to get the text out. On GitHub
click **Add file > Create new file**, type a file name, paste the code in, and click
**Commit changes**.

### For the SSIS and SSRS projects (weeks 5 and 6)

Those are whole Visual Studio project folders, not single text files, so copy and paste
will not work. On the VM desktop, right click the folder and pick **Send to > Compressed
(zipped) folder**, then upload the .zip the same way as above.

## How to get a file FROM GitHub onto your VM

1. Inside the VM, open a browser and go to the repo.
2. Click into the folder and click on the .sql file you want.
3. Click the **Download raw file** button (the download arrow at the top right of the
   file).
4. Open the downloaded file in SSMS, make sure you are connected to your own server, and
   run it.

You can also just click the file, select all the code shown on the page, copy it, and
paste it into a new query window in SSMS. That is usually faster for one script.

## Rules so we do not overwrite each other

**One person per file.** If two people upload a file with the same name, the second
upload replaces the first one and that work disappears from the page. Before you start
working, say in the group chat which file you are taking.

**Post in the group chat when you upload something.** Just a quick "uploaded the table
creation script" so nobody spends an hour working on a file that already changed.

**Run scripts in order.** You cannot insert rows into a table that does not exist yet.
That is why the files are numbered.

## Do not upload these

- Database files: `.mdf`, `.ldf`, `.ndf`, `.bak`, `.trn`. These are the actual database.
  They are huge and they do not belong here.
- The VM login or the `sa` password. This repo has to be public later for the week 5 and
  6 assignments, so no passwords in any file.
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
