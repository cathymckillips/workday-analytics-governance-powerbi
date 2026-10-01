USE PeopleAnalyticsLab;
GO

CREATE OR ALTER VIEW staging.vw_WorkerSnapshotRanked AS
WITH Standardized AS
(
 SELECT NULLIF(LTRIM(RTRIM(Employee_ID)),'') AS Employee_ID,
        NULLIF(LTRIM(RTRIM(Worker_Type)),'') AS Worker_Type,
        NULLIF(LTRIM(RTRIM(First_Name)),'') AS First_Name,
        NULLIF(LTRIM(RTRIM(Last_Name)),'') AS Last_Name,
        LOWER(NULLIF(LTRIM(RTRIM(Work_Email)),'')) AS Work_Email,
        Hire_Date,Termination_Date,
        CASE WHEN UPPER(LTRIM(RTRIM(Employment_Status)))='ACTIVE' THEN 'Active'
             WHEN UPPER(LTRIM(RTRIM(Employment_Status)))='TERMINATED' THEN 'Terminated'
             WHEN UPPER(LTRIM(RTRIM(Employment_Status)))='LEAVE' THEN 'Leave'
             ELSE NULLIF(LTRIM(RTRIM(Employment_Status)),'') END AS Employment_Status,
        NULLIF(LTRIM(RTRIM(Position_ID)),'') AS Position_ID,
        NULLIF(LTRIM(RTRIM(Manager_ID)),'') AS Manager_ID,
        NULLIF(LTRIM(RTRIM(Department_ID)),'') AS Department_ID,
        NULLIF(LTRIM(RTRIM(Location)),'') AS Location,FTE,
        NULLIF(LTRIM(RTRIM(Job_Profile_ID)),'') AS Job_Profile_ID,
        Extract_As_Of_Date,NULLIF(LTRIM(RTRIM(Source_System)),'') AS Source_System,Last_Updated_Timestamp
 FROM raw.WorkerSnapshot
), Ranked AS
(
 SELECT *,COUNT(*) OVER(PARTITION BY Employee_ID,Extract_As_Of_Date) AS Source_Row_Count,
        ROW_NUMBER() OVER(PARTITION BY Employee_ID,Extract_As_Of_Date ORDER BY Last_Updated_Timestamp DESC,Position_ID DESC) AS Record_Rank
 FROM Standardized
)
SELECT *,CASE WHEN Source_Row_Count>1 THEN 1 ELSE 0 END AS Duplicate_Record_Flag FROM Ranked;
GO

CREATE OR ALTER VIEW staging.vw_WorkerSnapshotClean AS
SELECT Employee_ID,Worker_Type,First_Name,Last_Name,Work_Email,Hire_Date,Termination_Date,
       Employment_Status,Position_ID,Manager_ID,Department_ID,Location,FTE,Job_Profile_ID,
       Extract_As_Of_Date,Source_System,Last_Updated_Timestamp,Source_Row_Count,Duplicate_Record_Flag
FROM staging.vw_WorkerSnapshotRanked WHERE Record_Rank=1;
GO

CREATE OR ALTER VIEW staging.vw_CompensationAsOf AS
WITH Candidates AS
(
 SELECT w.Employee_ID,w.Extract_As_Of_Date,c.Compensation_Record_ID,c.Pay_Type,c.Annual_Salary,
        c.Hourly_Rate,c.Currency,c.Effective_Date,c.End_Date,
        COUNT(c.Compensation_Record_ID) OVER(PARTITION BY w.Employee_ID,w.Extract_As_Of_Date) AS Effective_Record_Count,
        ROW_NUMBER() OVER(PARTITION BY w.Employee_ID,w.Extract_As_Of_Date ORDER BY c.Effective_Date DESC,c.Compensation_Record_ID DESC) AS Compensation_Rank
 FROM staging.vw_WorkerSnapshotClean w
 LEFT JOIN raw.Compensation c ON w.Employee_ID=c.Employee_ID
  AND c.Effective_Date<=w.Extract_As_Of_Date AND (c.End_Date IS NULL OR c.End_Date>=w.Extract_As_Of_Date)
)
SELECT *,CASE WHEN Effective_Record_Count=0 THEN 1 ELSE 0 END AS Missing_Compensation_Flag,
       CASE WHEN Effective_Record_Count>1 THEN 1 ELSE 0 END AS Multiple_Effective_Comp_Flag
FROM Candidates WHERE Compensation_Rank=1;
GO

CREATE OR ALTER VIEW staging.vw_WorkerEnriched AS
SELECT w.Employee_ID,w.Worker_Type,w.First_Name,w.Last_Name,w.Work_Email,w.Hire_Date,w.Termination_Date,
       w.Employment_Status,w.Extract_As_Of_Date,w.Position_ID,p.Job_Title,p.Job_Family,p.Job_Grade,
       p.Exempt_Status,p.Position_Status,w.Job_Profile_ID AS Worker_Job_Profile_ID,
       p.Job_Profile_ID AS Position_Job_Profile_ID,w.Department_ID AS Worker_Department_ID,
       p.Department_ID AS Position_Department_ID,o.Department_Name,o.Cost_Center,o.Supervisory_Organization,
       o.Business_Unit,w.Manager_ID,m.First_Name AS Manager_First_Name,m.Last_Name AS Manager_Last_Name,
       w.Location AS Worker_Location,p.Location AS Position_Location,w.FTE AS Worker_FTE,p.FTE AS Position_FTE,
       c.Compensation_Record_ID,c.Pay_Type,c.Annual_Salary,c.Hourly_Rate,c.Currency,
       c.Effective_Date AS Compensation_Effective_Date,c.Effective_Record_Count,w.Source_Row_Count,
       w.Duplicate_Record_Flag,c.Missing_Compensation_Flag,c.Multiple_Effective_Comp_Flag,
       w.Source_System,w.Last_Updated_Timestamp
FROM staging.vw_WorkerSnapshotClean w
LEFT JOIN raw.Position p ON w.Position_ID=p.Position_ID
LEFT JOIN raw.Organization o ON w.Department_ID=o.Department_ID
LEFT JOIN staging.vw_WorkerSnapshotClean m ON w.Manager_ID=m.Employee_ID AND w.Extract_As_Of_Date=m.Extract_As_Of_Date
LEFT JOIN staging.vw_CompensationAsOf c ON w.Employee_ID=c.Employee_ID AND w.Extract_As_Of_Date=c.Extract_As_Of_Date;
GO

CREATE OR ALTER VIEW staging.vw_WorkerDQFlags AS
SELECT w.*,
 CASE WHEN Employee_ID IS NULL THEN 1 ELSE 0 END AS Missing_Employee_ID_Flag,
 CASE WHEN Position_ID IS NULL THEN 1 ELSE 0 END AS Missing_Position_ID_Flag,
 CASE WHEN Position_ID IS NOT NULL AND Job_Title IS NULL THEN 1 ELSE 0 END AS Invalid_Position_Flag,
 CASE WHEN Worker_Department_ID IS NULL THEN 1 ELSE 0 END AS Missing_Department_ID_Flag,
 CASE WHEN Worker_Department_ID IS NOT NULL AND Department_Name IS NULL THEN 1 ELSE 0 END AS Invalid_Department_Flag,
 CASE WHEN Manager_ID IS NULL THEN 1 ELSE 0 END AS Missing_Manager_Flag,
 CASE WHEN Manager_ID IS NOT NULL AND Manager_First_Name IS NULL AND Manager_Last_Name IS NULL THEN 1 ELSE 0 END AS Invalid_Manager_Flag,
 CASE WHEN Worker_Job_Profile_ID IS NULL THEN 1 ELSE 0 END AS Missing_Job_Profile_Flag,
 CASE WHEN Worker_Job_Profile_ID IS NOT NULL AND Position_Job_Profile_ID IS NOT NULL AND Worker_Job_Profile_ID<>Position_Job_Profile_ID THEN 1 ELSE 0 END AS Job_Profile_Mismatch_Flag,
 CASE WHEN Worker_FTE IS NULL OR Worker_FTE<=0 OR Worker_FTE>1 THEN 1 ELSE 0 END AS Invalid_FTE_Flag,
 CASE WHEN Employment_Status='Active' AND Termination_Date IS NOT NULL AND Termination_Date<=Extract_As_Of_Date THEN 1 ELSE 0 END AS Active_With_Termination_Flag,
 CASE WHEN Employment_Status='Terminated' AND Termination_Date IS NULL THEN 1 ELSE 0 END AS Terminated_Without_Date_Flag,
 CASE WHEN Hire_Date>Extract_As_Of_Date THEN 1 ELSE 0 END AS Future_Hire_Flag,
 CASE WHEN Pay_Type='Salary' AND Annual_Salary IS NULL THEN 1 ELSE 0 END AS Missing_Salary_Flag
FROM staging.vw_WorkerEnriched w;
GO

