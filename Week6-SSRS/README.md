# Week 6 - SSRS Reports

Two SSRS reports built in Visual Studio against AdventureWorks2022.

| Report | Project | Procedure it calls | Built by |
|---|---|---|---|
| 1 - Bill of Materials | `SSRS Reports/SSRS Report - Nicholas` | `uspGetBillOfMaterials_NullEnabled` | Nicholas |
| 2 - Employee Managers | `SSRS Reports/SSRS Report - Mason` | `dbo.uspGetEmployeeManagersAll` | Mason |

Nathan set up both base solutions (originals in `Nathan/`).

## To run them

1. Run both `.sql` scripts in this folder in SSMS. Each creates a copy of the stock procedure
   whose parameters default to NULL, so the report loads all data when it first opens.
2. Open the `.sln` in each project folder with File > Open > Project/Solution.
3. Preview the report.

The server and database name are only in each project's `AdventureWorks.rds`
(`ADVSQL` / `AdventureWorks2022`, Windows authentication), plus the `USE` line at the top of each script.
