USE PeopleAnalyticsLab;
GO

-- 1. Confirm row counts and snapshot coverage.
SELECT Extract_As_Of_Date, COUNT(*) AS Source_Rows, COUNT(DISTINCT Employee_ID) AS Distinct_Employees
FROM raw.WorkerSnapshot GROUP BY Extract_As_Of_Date ORDER BY Extract_As_Of_Date;

-- 2. Find duplicate employee IDs within a snapshot. Do not use DISTINCT to hide the cause.
SELECT Extract_As_Of_Date, Employee_ID, COUNT(*) AS Row_Count,
       MIN(Last_Updated_Timestamp) AS First_Update, MAX(Last_Updated_Timestamp) AS Last_Update
FROM raw.WorkerSnapshot
GROUP BY Extract_As_Of_Date, Employee_ID HAVING COUNT(*) > 1;

-- 3. Profile required fields in the November extract.
SELECT
 SUM(CASE WHEN Employee_ID IS NULL OR Employee_ID='' THEN 1 ELSE 0 END) AS Missing_Employee_ID,
 SUM(CASE WHEN Position_ID IS NULL OR Position_ID='' THEN 1 ELSE 0 END) AS Missing_Position,
 SUM(CASE WHEN Department_ID IS NULL OR Department_ID='' THEN 1 ELSE 0 END) AS Missing_Department,
 SUM(CASE WHEN Job_Profile_ID IS NULL OR Job_Profile_ID='' THEN 1 ELSE 0 END) AS Missing_Job_Profile,
 SUM(CASE WHEN Manager_ID IS NULL OR Manager_ID='' THEN 1 ELSE 0 END) AS Missing_Manager
FROM raw.WorkerSnapshot WHERE Extract_As_Of_Date='2026-11-30';

-- 4. Look for status/date contradictions and future hires.
SELECT * FROM raw.WorkerSnapshot
WHERE Extract_As_Of_Date='2026-11-30'
  AND ((Employment_Status='Active' AND Termination_Date IS NOT NULL)
    OR (Employment_Status='Terminated' AND Termination_Date IS NULL)
    OR Hire_Date > Extract_As_Of_Date);

-- 5. Validate FTE range.
SELECT * FROM raw.WorkerSnapshot
WHERE Extract_As_Of_Date='2026-11-30' AND (FTE <= 0 OR FTE > 1 OR FTE IS NULL);

-- 6. Test department and position referential integrity.
SELECT w.Employee_ID, w.Department_ID FROM raw.WorkerSnapshot w
LEFT JOIN raw.Organization o ON o.Department_ID=w.Department_ID
WHERE w.Extract_As_Of_Date='2026-11-30' AND o.Department_ID IS NULL;

SELECT w.Employee_ID, w.Position_ID FROM raw.WorkerSnapshot w
LEFT JOIN raw.Position p ON p.Position_ID=w.Position_ID
WHERE w.Extract_As_Of_Date='2026-11-30' AND p.Position_ID IS NULL;

-- 7. Check active employees for missing compensation.
SELECT w.Employee_ID, w.Employment_Status, c.Compensation_Record_ID
FROM raw.WorkerSnapshot w LEFT JOIN raw.Compensation c ON c.Employee_ID=w.Employee_ID
WHERE w.Extract_As_Of_Date='2026-11-30' AND w.Employment_Status='Active'
GROUP BY w.Employee_ID,w.Employment_Status,c.Compensation_Record_ID
HAVING c.Compensation_Record_ID IS NULL;

-- 8. Find salaried compensation rows without salary and overlapping effective records.
SELECT * FROM raw.Compensation WHERE Pay_Type='Salary' AND Annual_Salary IS NULL;
SELECT Employee_ID, COUNT(*) AS Open_Ended_Records FROM raw.Compensation
WHERE End_Date IS NULL GROUP BY Employee_ID HAVING COUNT(*) > 1;

-- 9. Check compliance records that do not match a November worker.
SELECT c.Employee_ID FROM raw.EmployeeCompliance c
LEFT JOIN raw.WorkerSnapshot w ON w.Employee_ID=c.Employee_ID AND w.Extract_As_Of_Date='2026-11-30'
WHERE w.Employee_ID IS NULL;

-- 10. Create your own reconciliation query:
-- September ending active HC + October hires - October terms = October ending active HC.
-- Repeat for November. Explain any non-reconciling result before changing the data.

