# Advanced SQL Semester Project
## Week 2 Deliverables, Item 3 - AI Prompts Used to Generate the Seed Data

Kelsey Wilcox, Mason Romdenne, Nathan Krouth, Nicholas Fearing

Prepared by Mason Romdenne
30 August 2026

---

### What this document covers

This document contains the prompts used to generate the insert statements for
Item 3, the seed data for the Restaurant database. It covers the four files:

- `Week2_Restaurant_Inserts_1.sql`
- `Week2_Restaurant_Inserts_2.sql`
- `Week2_Restaurant_Inserts_3.sql`
- `Week2_Restaurant_Inserts_4.sql`

The prompts are listed in the order they were used. The work was iterative -
the first pass produced data that was technically valid but not believable for
an actual restaurant, so several rounds were spent correcting the volumes until
the numbers described a restaurant that could really exist.

---

### How the AI was used, and what it could and could not see

This matters for reading the prompts below, because it explains why several of
them exist at all.

**What it could see.** The AI ran on my own computer with access to our GitHub
repository. It could read the repo directly, so it took the CREATE TABLE
statements for all four groups' tables out of the pull requests rather than
needing me to paste them in, and it could open pull requests of its own. It also
read screenshots I took inside the VM - error dialogs, result grids, the Object
Explorer tree - so some of what it knew about the state of the database came from
pictures I sent it rather than text I typed.

**What it could not see.** SQL Server runs on a Horizon virtual machine at
netlab.nwtc.edu, and the AI had **no connection to that virtual machine and no
access to the database at any point.** It never ran a query and never read a
table. Everything it knew about what was actually in the database came second
hand from me, as a screenshot or as output I copied out of SSMS.

The loop was:

1. The AI read the table definitions out of the GitHub repo.
2. It wrote SQL as plain text on my computer.
3. I uploaded that text to Google Drive, opened Drive in the browser inside the
   VM, copied it, and pasted it into SSMS.
4. I ran it, and sent back whatever came out - a screenshot of the error, or the
   result grid copied as text.

Two consequences show up repeatedly in the prompts.

**The AI could not verify its own work against the database.** Reading a CREATE
TABLE statement out of GitHub is not the same thing as asking SQL Server what
columns a table actually has, and the difference is not academic. When the
Charities table was trimmed and a column removed, the AI updated its copy of the
table definition but not its insert, and nothing could catch that until SQL
Server rejected it - which is exactly what happened in Prompt 8. This is also why
Prompt 6 asks for a check of the generated text against the CREATE TABLE
statements. That check reads two pieces of text and compares them. It is not the
database validating anything.

**Everything had to survive the copy-and-paste route.** The scripts travel
through Google Drive and a browser clipboard, and non-ASCII characters get
mangled on the way. That is why the prompts insist on plain ASCII, why the euro
symbol is written as EUR, and why the Irish names are spelled without their
accents. Files also have to be uploaded as plain text rather than converted to
Google Docs format, because the converter rewrites straight quotes as curly
quotes and breaks every string literal in the file.

---

### Prompt 1 - generating the initial seed data

> Read the table definitions out of our GitHub repo - all four groups' scripts
> are in there, eighteen tables between them. Write INSERT statements to
> populate every one of them.
>
> You do not have access to the database itself. SQL Server is on a virtual
> machine I connect to through Horizon and there is no path from you to it. Work
> only from the CREATE TABLE statements in the repo, and assume you cannot check
> anything against the live database. I will run what you write and send back
> whatever SQL Server says, as a screenshot or as pasted text.
>
> The restaurant is in Ireland, so use Irish first names, surnames, cities and
> euro amounts throughout. Keep everything to plain ASCII characters, no
> accented letters, because these scripts get pasted into SSMS on the virtual
> machine through a browser and non-ASCII characters get mangled in transit.
> Write the euro symbol as EUR. Apostrophes in surnames like O'Brien need to be
> doubled for SQL.
>
> Requirements that have to be satisfied:
> - Every record needs a different date value, spread across three rolling years.
> - Never insert CreationDate. It has a default of SYSDATETIME() and the
>   requirement is that it records when the row was actually inserted.
> - At least five customers must have a preferred table that is different from
>   the table they actually sat at.
> - At least five servers must have more than one table assigned to them.
>
> Split the output into separate files ordered by dependency, so that every
> foreign key value refers to a row that already exists when the statement runs.

---

### Prompt 2 - resolving the circular reference

> Customers has a foreign key PreferredRes pointing at Reservations, and
> Reservations has a foreign key CustomerID pointing back at Customers. Neither
> table can be fully populated before the other.
>
> Handle this by inserting the customers first with PreferredRes set to NULL,
> then inserting the reservations, then running an UPDATE to fill in each
> customer's preferred reservation afterwards.

---

### Prompt 3 - capping every table at 100 rows

> Cap every table at 100 rows. Nothing should be over 100.
>
> In a real database we would use whatever number the business actually needed,
> but this is a class project and the requirement is a hundred records, so a
> hundred is the ceiling.

---

### Prompt 4 - correcting the staffing numbers

> The staffing is not realistic. There are five branches and you have given the
> restaurant 100 chefs, which works out at twenty chefs per kitchen. No
> restaurant runs a kitchen that way.
>
> A real restaurant employs far more servers than chefs. Rework the staff so the
> ratio makes sense: a kitchen has a head chef, a sous chef, a pastry chef and a
> couple of cooks, while the floor needs enough servers to cover every shift.

---

### Prompt 5 - correcting the food and charity volumes

> A few more of the volumes are not believable.
>
> We are not donating to a hundred different charities. A restaurant builds a
> relationship with a handful of local food banks and shelters near each branch.
>
> A hundred dishes and a hundred menu items is not a realistic menu either. A
> pub menu is around forty items.
>
> Note that the Recipes table is one row per ingredient in a dish rather than one
> row per recipe, so a hundred rows there is the ingredient lines for the dishes,
> not a hundred separate recipes. That one can stay at a hundred.
>
> Cut the rest down to numbers that describe a restaurant that could actually
> exist, and keep everything at or under a hundred.

---

### Prompt 6 - checking the generated text before running it

Since the AI could not test anything against the database, the next best thing
was to have it check its own output as text, against the CREATE TABLE statements
it had read out of the repo.

> You cannot run any of this, and neither can I until I paste it into the VM, so
> check it as text first. Compare the generated inserts against the CREATE TABLE
> statements in the repo and report anything SQL Server would reject:
>
> - Every foreign key value must fall inside the range of IDs that actually
>   exist in the parent table, accounting for each table's IDENTITY seed.
> - Every CHECK constraint must pass, including the email pattern on Employees
>   and Customers and the value lists on ChefType, OrderChannel and PaymentMethod.
> - Every UNIQUE constraint must hold, including CharityName, BillingNumber and
>   the ChefID and LocationID pair on ChefLocations.
> - No string value may exceed the width of its column.
> - Every string and date value must be a quoted literal.
> - CreationDate must never appear in a column list.
> - Each order total must equal the sum of that order's line items.
> - Every character in every file must be plain ASCII.

This check caught the charity names repeating every sixty rows, which would have
failed the UNIQUE constraint on forty of them.

A second problem was found by reading the generated file rather than by the
check - one phone number had been written without quotes around it, which is a
plain syntax error. The check was then extended to confirm that every string and
date value is a quoted literal, so that particular mistake cannot get through
again.

---

### Prompt 7 - correcting data that had already been loaded

> The first version of the seed data was already run against the database before
> the volumes were corrected, so Dishes and Ingredients hold the old counts.
> Screenshot of the row counts I got back from SSMS is attached.
>
> Write a script that clears just those two tables, resets their identity
> counters so the IDs start at their original seeds again, and reloads the
> corrected rows. Leave the other tables alone since their data did not change.
>
> Note that TRUNCATE will not work here because other tables have foreign keys
> pointing at Dishes.

---

### Prompt 8 - a column that did not exist, and rows inserted twice

> Two problems turned up while the files were being run. Screenshots of both are
> attached.
>
> The Charities insert names a LastDonationDate column and SQL Server rejects it
> with "Invalid column name". That column was removed from the Charities table
> when the table was trimmed, and the insert was never updated to match, so all
> fifteen rows were refused.
>
> Insert file 1 was also run a second time by mistake. Positions was protected by
> its UNIQUE constraint on PositionName and stayed at fifteen rows, but
> Demographic, Suppliers, Dishes and Ingredients had nothing stopping them and
> every row went in again.
>
> Correct the insert so its column list matches the table, and write a script
> that removes the duplicated rows and resets those identity counters.
>
> Then extend the text check to compare every insert's column list against the
> CREATE TABLE statements, so a column that does not exist on a table cannot get
> through again.

This one is the clearest example of the gap described at the top of this
document. The AI had been told the column was removed from Charities and updated
the table definition, but its insert still named the old column, and it had no
way to notice - it could not query the database to see which columns actually
existed. The check from Prompt 6 compared values against the constraints but
never confirmed that the column names themselves were real. It took SQL Server
rejecting the statement on my VM, and me sending the error back, for the mismatch
to surface at all. The check now compares column lists across all eighteen
tables.

The duplicated rows were not a defect in the scripts. These inserts are written
to run once against a freshly built database, and running one of them twice will
duplicate every row in a table that has no unique constraint to prevent it.

---

### Row counts, and the reasoning for the tables under 100

The requirement asks for at least one hundred records per table, and also says:

> "For some tables, it may not make sense to add 100 records. If/when this
> happens, document your reasoning for not inserting at least 100 records."

Ten of the eighteen tables are below one hundred. The reasoning for each is
below, and is also written into the comment above the relevant INSERT statement
in the scripts themselves.

| Table | Rows | Reasoning |
|---|---:|---|
| Positions | 15 | These are the job titles the restaurant actually has - owner, managers, five kinds of cook, servers, bartenders, hosts, dish washers, cleaners, a driver. A hundred rows would mean inventing eighty-five job titles that do not exist. |
| Demographic | 5 | One row per branch. The requirement describes a restaurant that is thinking about opening more locations, not a chain of a hundred. Five branches across Dublin, Galway, Cork, Limerick and Waterford. |
| KitchenDetails | 5 | One kitchen per branch. There are five branches, so there are five kitchens. |
| Chefs | 25 | Five kitchen staff per branch - a head chef, a sous chef, a pastry chef and two cooks. A hundred chefs across five branches would be twenty per kitchen, which no restaurant runs. |
| Dishes | 40 | A pub menu is around forty items. A hundred would not be a menu anyone could work from. |
| Menu | 40 | One entry per dish on the menu, so it follows the dish count. |
| Ingredients | 60 | Forty dishes do not need a hundred separate ingredients. Sixty covers the menu with room for seasonal items. |
| ServerEmployees | 50 | Ten servers per branch. Enough to cover lunch and dinner shifts across five locations without inventing staff. |
| ChefLocations | 75 | Twenty-five chefs each covering three of the five branches. The row count falls out of the chef count rather than being chosen. |
| Charities | 15 | About three per branch. A restaurant builds a real relationship with a few local food banks and shelters. Donating to a hundred separate organisations is not something a five-branch restaurant does. |

The remaining eight tables are at one hundred: Suppliers, Employees, ResTables,
Recipes, Customers, Reservations, Transactions and TransactionDetails.

Two of those are worth a note. **Recipes** is one row per ingredient in a dish,
so a hundred rows is the ingredient lines for the forty dishes at roughly two or
three each, not a hundred separate recipes. **TransactionDetails** is one line
per bill across the hundred orders.

**Total: 1,130 rows across eighteen tables.**

---

### How the scripts were produced

Rather than writing out roughly 1,130 INSERT rows by hand, the AI was asked to
write a script that generates the SQL files. That approach was used for two
reasons.

First, consistency. Each order's OrderTotal in the Transactions table is
calculated from that order's rows in TransactionDetails, so the header and the
line items always agree. The UnitPrice on each line is taken from the same
formula that sets the menu price in the Dishes table, so the price on a bill
matches the price on the menu. Getting that right by hand across a hundred
orders would be very easy to get wrong.

Second, correcting volumes. Each time a row count was found to be unrealistic,
the number was changed in one place and the affected files were regenerated,
rather than every foreign key value being renumbered by hand.

That generator ran on my own computer and only ever wrote text files. It never
connected to SQL Server. The files that are submitted are ordinary T-SQL, and
nothing outside SQL Server is needed to run them.
