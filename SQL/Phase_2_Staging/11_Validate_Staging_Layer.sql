USE PeopleAnalyticsLab;
GO
SELECT Extract_As_Of_Date,COUNT(*) AS Staging_Rows,COUNT(DISTINCT Employee_ID) AS Distinct_Employees
FROM staging.vw_WorkerSnapshotClean GROUP BY Extract_As_Of_Date ORDER BY Extract_As_Of_Date;

SELECT Employee_ID,Extract_As_Of_Date,COUNT(*) AS Row_Count
FROM staging.vw_WorkerEnriched GROUP BY Employee_ID,Extract_As_Of_Date HAVING COUNT(*)>1;

SELECT Extract_As_Of_Date,SUM(Duplicate_Record_Flag) AS Duplicate_Workers,
 SUM(Invalid_Position_Flag) AS Invalid_Positions,SUM(Invalid_Department_Flag) AS Invalid_Departments,
 SUM(Missing_Manager_Flag) AS Missing_Managers,SUM(Invalid_Manager_Flag) AS Invalid_Managers,
 SUM(Missing_Job_Profile_Flag) AS Missing_Job_Profiles,SUM(Invalid_FTE_Flag) AS Invalid_FTE,
 SUM(Active_With_Termination_Flag) AS Active_With_Termination,SUM(Future_Hire_Flag) AS Future_Hires,
 SUM(Missing_Compensation_Flag) AS Missing_Compensation,SUM(Multiple_Effective_Comp_Flag) AS Multiple_Compensation,
 SUM(Missing_Salary_Flag) AS Missing_Salary
FROM staging.vw_WorkerDQFlags GROUP BY Extract_As_Of_Date ORDER BY Extract_As_Of_Date;
GO
