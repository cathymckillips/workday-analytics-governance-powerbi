USE PeopleAnalyticsLab;
GO
CREATE OR ALTER VIEW governed.vw_WorkforceGoverned AS
WITH e AS
(
 SELECT Employee_ID,Extract_As_Of_Date,COUNT(*) AS Total_Exception_Count,
        SUM(CASE WHEN Severity='Critical' THEN 1 ELSE 0 END) AS Critical_Exception_Count,
        SUM(CASE WHEN Severity='High' THEN 1 ELSE 0 END) AS High_Exception_Count,
        MAX(CONVERT(int,Blocks_Workforce_Publish)) AS Blocks_Workforce_Publish,
        MAX(CONVERT(int,Blocks_Compensation_Publish)) AS Blocks_Compensation_Publish,
        MAX(CONVERT(int,Blocks_Compliance_Publish)) AS Blocks_Compliance_Publish
 FROM governed.vw_HRDataQualityExceptions GROUP BY Employee_ID,Extract_As_Of_Date
)
SELECT w.*,
 CASE WHEN w.Employment_Status='Active' AND w.Hire_Date<=w.Extract_As_Of_Date
       AND (w.Termination_Date IS NULL OR w.Termination_Date>w.Extract_As_Of_Date) THEN 1 ELSE 0 END AS Reporting_Active_Flag,
 COALESCE(e.Total_Exception_Count,0) AS Total_Exception_Count,
 COALESCE(e.Critical_Exception_Count,0) AS Critical_Exception_Count,
 COALESCE(e.High_Exception_Count,0) AS High_Exception_Count,
 COALESCE(e.Blocks_Workforce_Publish,0) AS Blocks_Workforce_Publish,
 COALESCE(e.Blocks_Compensation_Publish,0) AS Blocks_Compensation_Publish,
 COALESCE(e.Blocks_Compliance_Publish,0) AS Blocks_Compliance_Publish
FROM staging.vw_WorkerDQFlags w
LEFT JOIN e ON w.Employee_ID=e.Employee_ID AND w.Extract_As_Of_Date=e.Extract_As_Of_Date;
GO

CREATE OR ALTER VIEW governed.vw_ReportPublicationGate AS
SELECT Extract_As_Of_Date,COUNT(DISTINCT Employee_ID) AS Total_Workers,
 SUM(Total_Exception_Count) AS Total_Exceptions,SUM(Critical_Exception_Count) AS Critical_Exceptions,
 SUM(High_Exception_Count) AS High_Exceptions,
 SUM(CASE WHEN Blocks_Workforce_Publish=1 THEN 1 ELSE 0 END) AS Workers_Blocking_Workforce_Report,
 SUM(CASE WHEN Blocks_Compensation_Publish=1 THEN 1 ELSE 0 END) AS Workers_Blocking_Compensation_Report,
 SUM(CASE WHEN Blocks_Compliance_Publish=1 THEN 1 ELSE 0 END) AS Workers_Blocking_Compliance_Report,
 CASE WHEN SUM(CASE WHEN Blocks_Workforce_Publish=1 THEN 1 ELSE 0 END)>0 THEN 'DO NOT PUBLISH' ELSE 'READY FOR REVIEW' END AS Workforce_Publication_Status,
 CASE WHEN SUM(CASE WHEN Blocks_Compensation_Publish=1 THEN 1 ELSE 0 END)>0 THEN 'DO NOT PUBLISH' ELSE 'READY FOR REVIEW' END AS Compensation_Publication_Status,
 CASE WHEN SUM(CASE WHEN Blocks_Compliance_Publish=1 THEN 1 ELSE 0 END)>0 THEN 'DO NOT PUBLISH' ELSE 'READY FOR REVIEW' END AS Compliance_Publication_Status
FROM governed.vw_WorkforceGoverned GROUP BY Extract_As_Of_Date;
GO

CREATE OR ALTER VIEW reporting.vw_WorkforceTrusted AS
SELECT Employee_ID,Worker_Type,First_Name,Last_Name,Work_Email,Hire_Date,Termination_Date,Employment_Status,
 Extract_As_Of_Date,Position_ID,Job_Title,Job_Family,Job_Grade,Exempt_Status,Position_Status,
 Worker_Job_Profile_ID,Position_Job_Profile_ID,Worker_Department_ID AS Department_ID,Position_Department_ID,
 Department_Name,Cost_Center,Supervisory_Organization,Business_Unit,Manager_ID,Manager_First_Name,Manager_Last_Name,
 Worker_Location AS Location,Position_Location,Worker_FTE AS FTE,Position_FTE,Compensation_Record_ID,Pay_Type,
 Annual_Salary,Hourly_Rate,Currency,Compensation_Effective_Date,Reporting_Active_Flag,Total_Exception_Count,
 Critical_Exception_Count,High_Exception_Count,Blocks_Workforce_Publish,Blocks_Compensation_Publish,
 Blocks_Compliance_Publish,
 CASE WHEN Reporting_Active_Flag=1 AND Blocks_Workforce_Publish=0 THEN 1 ELSE 0 END AS Trusted_Active_Flag,
 CASE WHEN Blocks_Workforce_Publish=1 THEN 'Blocked' WHEN Total_Exception_Count>0 THEN 'Reportable With Review' ELSE 'Trusted' END AS Workforce_Record_Status,
 Source_System,Last_Updated_Timestamp
FROM governed.vw_WorkforceGoverned;
GO

