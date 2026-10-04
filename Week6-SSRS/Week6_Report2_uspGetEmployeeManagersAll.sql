USE AdventureWorks2022;
GO

/*
    Week 6, Report 2 (Mason)
    uspGetEmployeeManagersAll returns the same columns as dbo.uspGetEmployeeManagers.
    The stock proc requires @BusinessEntityID, but the report has to load every
    employee by default. Here the parameter defaults to NULL:
        NULL  -> the manager chain for every employee
        an ID -> the manager chain for that one employee (same rows as the stock proc)
*/
DROP PROCEDURE IF EXISTS dbo.uspGetEmployeeManagersAll;
GO

CREATE PROCEDURE dbo.uspGetEmployeeManagersAll
    @BusinessEntityID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Same recursive query as uspGetEmployeeManagers; StartID keeps each employee's chain together
    WITH EMP_cte (StartID, BusinessEntityID, OrganizationNode, FirstName, LastName, JobTitle, RecursionLevel)
    AS (
        SELECT e.BusinessEntityID, e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, 0
        FROM HumanResources.Employee e
            INNER JOIN Person.Person p
            ON p.BusinessEntityID = e.BusinessEntityID
        WHERE @BusinessEntityID IS NULL
           OR e.BusinessEntityID = @BusinessEntityID
        UNION ALL
        SELECT EMP_cte.StartID, e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, RecursionLevel + 1
        FROM HumanResources.Employee e
            INNER JOIN EMP_cte
            ON e.OrganizationNode = EMP_cte.OrganizationNode.GetAncestor(1)
            INNER JOIN Person.Person p
            ON p.BusinessEntityID = e.BusinessEntityID
    )
    -- Join back to Employee to return the manager name
    SELECT EMP_cte.RecursionLevel, EMP_cte.BusinessEntityID, EMP_cte.FirstName, EMP_cte.LastName,
        EMP_cte.OrganizationNode.ToString() AS OrganizationNode, p.FirstName AS ManagerFirstName, p.LastName AS ManagerLastName
    FROM EMP_cte
        INNER JOIN HumanResources.Employee e
        ON EMP_cte.OrganizationNode.GetAncestor(1) = e.OrganizationNode
        INNER JOIN Person.Person p
        ON p.BusinessEntityID = e.BusinessEntityID
    ORDER BY EMP_cte.StartID, EMP_cte.RecursionLevel
    OPTION (MAXRECURSION 25);
END;
GO

/* TESTING */

-- 1. No parameter: every employee's manager chain (what the report shows on first load)
EXEC dbo.uspGetEmployeeManagersAll;

-- 2. One employee: should match the stock proc row for row
EXEC dbo.uspGetEmployeeManagersAll @BusinessEntityID = 12;
EXEC dbo.uspGetEmployeeManagers @BusinessEntityID = 12;

-- 3. Explicit NULL behaves the same as no parameter (this is what SSRS sends for a blank parameter)
EXEC dbo.uspGetEmployeeManagersAll @BusinessEntityID = NULL;
