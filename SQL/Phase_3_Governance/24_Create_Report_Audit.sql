USE PeopleAnalyticsLab;
GO
IF OBJECT_ID('audit.ReportRun','U') IS NULL
CREATE TABLE audit.ReportRun
(
 Report_Run_ID int IDENTITY(1,1) PRIMARY KEY,Report_Name nvarchar(150) NOT NULL,
 Reporting_Period_End date NOT NULL,Expected_Run_Date date NULL,Actual_Run_Timestamp datetime2(0) NOT NULL,
 Source_Row_Count int NULL,Staging_Row_Count int NULL,Reporting_Row_Count int NULL,
 Total_Exception_Count int NULL,Critical_Exception_Count int NULL,High_Exception_Count int NULL,
 Blocking_Worker_Count int NULL,Validation_Status varchar(30) NOT NULL,Publication_Status varchar(30) NOT NULL,
 Analyst_Name nvarchar(100) NULL,Validation_Notes nvarchar(1000) NULL
);
GO
DECLARE @Period date='2026-11-30',@Report nvarchar(150)='Monthly Workforce Dashboard';
IF NOT EXISTS(SELECT 1 FROM audit.ReportRun WHERE Report_Name=@Report AND Reporting_Period_End=@Period)
INSERT audit.ReportRun
(Report_Name,Reporting_Period_End,Expected_Run_Date,Actual_Run_Timestamp,Source_Row_Count,Staging_Row_Count,
 Reporting_Row_Count,Total_Exception_Count,Critical_Exception_Count,High_Exception_Count,Blocking_Worker_Count,
 Validation_Status,Publication_Status,Analyst_Name,Validation_Notes)
SELECT @Report,@Period,'2026-12-02',SYSDATETIME(),
 (SELECT COUNT(*) FROM raw.WorkerSnapshot WHERE Extract_As_Of_Date=@Period),
 (SELECT COUNT(*) FROM staging.vw_WorkerSnapshotClean WHERE Extract_As_Of_Date=@Period),
 (SELECT COUNT(*) FROM reporting.vw_WorkforceTrusted WHERE Extract_As_Of_Date=@Period),
 g.Total_Exceptions,g.Critical_Exceptions,g.High_Exceptions,g.Workers_Blocking_Workforce_Report,
 CASE WHEN g.Workers_Blocking_Workforce_Report>0 THEN 'Requires Investigation' ELSE 'Passed' END,
 'Not Published','Catherine McKillips',
 CASE WHEN g.Workers_Blocking_Workforce_Report>0 THEN 'Publication held because unresolved blocking exceptions were identified.' ELSE 'Validation passed.' END
FROM governed.vw_ReportPublicationGate g WHERE g.Extract_As_Of_Date=@Period;
GO

