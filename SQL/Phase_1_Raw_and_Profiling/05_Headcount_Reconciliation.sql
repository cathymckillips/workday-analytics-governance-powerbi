USE PeopleAnalyticsLab;
GO

WITH Headcount AS
(
    SELECT Extract_As_Of_Date,
           COUNT(DISTINCT CASE WHEN Employment_Status='Active' THEN Employee_ID END) AS Active_Headcount
    FROM raw.WorkerSnapshot
    WHERE Extract_As_Of_Date IN ('2026-09-30','2026-10-31','2026-11-30')
    GROUP BY Extract_As_Of_Date
),
OctoberMovement AS
(
    SELECT COUNT(DISTINCT CASE WHEN Hire_Date>='2026-10-01' AND Hire_Date<'2026-11-01' THEN Employee_ID END) AS Hires,
           COUNT(DISTINCT CASE WHEN Termination_Date>='2026-10-01' AND Termination_Date<'2026-11-01' THEN Employee_ID END) AS Terminations
    FROM raw.WorkerSnapshot WHERE Extract_As_Of_Date='2026-10-31'
),
NovemberMovement AS
(
    SELECT COUNT(DISTINCT CASE WHEN Hire_Date>='2026-11-01' AND Hire_Date<'2026-12-01' THEN Employee_ID END) AS Hires,
           COUNT(DISTINCT CASE WHEN Termination_Date>='2026-11-01' AND Termination_Date<'2026-12-01' THEN Employee_ID END) AS Terminations
    FROM raw.WorkerSnapshot WHERE Extract_As_Of_Date='2026-11-30'
),
Reconciliation AS
(
    SELECT 'October 2026' AS Reporting_Month, s.Active_Headcount AS Beginning_Headcount,
           m.Hires,m.Terminations,s.Active_Headcount+m.Hires-m.Terminations AS Expected_Ending_Headcount,
           e.Active_Headcount AS Actual_Ending_Headcount
    FROM Headcount s CROSS JOIN Headcount e CROSS JOIN OctoberMovement m
    WHERE s.Extract_As_Of_Date='2026-09-30' AND e.Extract_As_Of_Date='2026-10-31'
    UNION ALL
    SELECT 'November 2026',s.Active_Headcount,m.Hires,m.Terminations,
           s.Active_Headcount+m.Hires-m.Terminations,e.Active_Headcount
    FROM Headcount s CROSS JOIN Headcount e CROSS JOIN NovemberMovement m
    WHERE s.Extract_As_Of_Date='2026-10-31' AND e.Extract_As_Of_Date='2026-11-30'
)
SELECT *, Actual_Ending_Headcount-Expected_Ending_Headcount AS Reconciliation_Variance,
       CASE WHEN Actual_Ending_Headcount=Expected_Ending_Headcount THEN 'Passed' ELSE 'Requires Investigation' END AS Reconciliation_Status
FROM Reconciliation ORDER BY Reporting_Month;
GO

