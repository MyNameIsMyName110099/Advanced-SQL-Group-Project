# Week 7 - Security

Roles, users, logins and permissions on the Restaurant database.

| Item | Script | Documentation | Built by |
|---|---|---|---|
| 1 - Agent login, RestaurantUser, RestaurantDoAnything, RestaurantAddDeleteDB, RestaurantPower | `week7_item1.sql` | `Week7_Item1 Documentation.doc` | Nicholas |
| 2 - Permissions on the five Week 4 procedures | `Week7_Item2.sql` | `week7_Item2 Documentation.doc` | Nicholas |
| 3 - The five `*_table_user` users | `Week7_Item3_NK.sql` | `week7_Item3 Documentation.doc` | Nathan |

`Week7_Combined.sql` is all three items in one script, in run order (Item 2 needs the
users Item 1 creates). Use that one.

## To run it on your VM

1. **Item 1, part A is done by hand, not in the script.** In SSMS Object Explorer go to
   Security > Logins, right-click `NT SERVICE\SQLSERVERAGENT` > Properties > Status, set
   Login to **Disabled**, OK.
2. Open `Week7_Combined.sql`, click **Raw**, copy everything into a new query window and
   press F5. It switches to the Restaurant database on its own.
3. The Messages tab should end with `Commands completed successfully`.

The combined script starts by dropping anything it creates if it already exists, so it is
safe to run more than once, including on a VM that already has some of these objects.

## Check it worked

```sql
USE Restaurant;
SELECT name, type_desc FROM sys.server_principals
WHERE name LIKE 'Restaurant%' OR name LIKE '%[_]table[_]user';
SELECT name, type_desc, default_schema_name FROM sys.database_principals
WHERE name LIKE 'Restaurant%' OR name LIKE '%[_]table[_]user';
```

You should get 8 rows from the first query and 9 from the second.

Run this before Week 8, so the Week 8 backup includes these users and roles.
