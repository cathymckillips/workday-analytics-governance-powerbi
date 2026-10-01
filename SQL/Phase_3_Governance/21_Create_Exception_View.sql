USE PeopleAnalyticsLab;
GO
CREATE OR ALTER VIEW governed.vw_HRDataQualityExceptions AS
SELECT w.Employee_ID,w.First_Name,w.Last_Name,w.Extract_As_Of_Date,w.Department_Name,w.Position_ID,w.Job_Title,
       x.Rule_ID,r.Rule_Name,r.Rule_Description,r.Expected_Condition,r.Severity,r.Data_Owner,
       CONVERT(nvarchar(500),x.Actual_Value) AS Actual_Value,
       r.Blocks_Workforce_Publish,r.Blocks_Compensation_Publish,r.Blocks_Compliance_Publish,
       w.Source_System,w.Last_Updated_Timestamp,CAST('Open' AS varchar(20)) AS Resolution_Status
FROM staging.vw_WorkerDQFlags w
CROSS APPLY
(
 VALUES
 ('DQ001',w.Duplicate_Record_Flag,CONCAT('Duplicate record flag: ',CONVERT(varchar(10),w.Duplicate_Record_Flag))),
 ('DQ002',w.Invalid_Position_Flag,CONCAT('Position_ID: ',COALESCE(w.Position_ID,'NULL'))),
 ('DQ003',w.Invalid_Department_Flag,CONCAT('Department_ID: ',COALESCE(w.Worker_Department_ID,'NULL'))),
 ('DQ004',w.Missing_Manager_Flag,CONCAT('Manager_ID: ',COALESCE(w.Manager_ID,'NULL'))),
 ('DQ005',w.Invalid_Manager_Flag,CONCAT('Manager_ID: ',COALESCE(w.Manager_ID,'NULL'))),
 ('DQ006',w.Missing_Job_Profile_Flag,CONCAT('Worker Job_Profile_ID: ',COALESCE(w.Worker_Job_Profile_ID,'NULL'))),
 ('DQ007',w.Job_Profile_Mismatch_Flag,CONCAT('Worker profile: ',COALESCE(w.Worker_Job_Profile_ID,'NULL'),'; position profile: ',COALESCE(w.Position_Job_Profile_ID,'NULL'))),
 ('DQ008',w.Invalid_FTE_Flag,CONCAT('Worker FTE: ',COALESCE(CONVERT(varchar(30),w.Worker_FTE),'NULL'))),
 ('DQ009',w.Active_With_Termination_Flag,CONCAT('Status: ',COALESCE(w.Employment_Status,'NULL'),'; termination: ',COALESCE(CONVERT(varchar(10),w.Termination_Date,23),'NULL'))),
 ('DQ010',w.Terminated_Without_Date_Flag,CONCAT('Status: ',COALESCE(w.Employment_Status,'NULL'),'; termination: NULL')),
 ('DQ011',w.Future_Hire_Flag,CONCAT('Hire: ',COALESCE(CONVERT(varchar(10),w.Hire_Date,23),'NULL'),'; snapshot: ',CONVERT(varchar(10),w.Extract_As_Of_Date,23))),
 ('DQ012',w.Missing_Compensation_Flag,CONCAT('Compensation record: ',COALESCE(w.Compensation_Record_ID,'NULL'))),
 ('DQ013',w.Multiple_Effective_Comp_Flag,CONCAT('Effective compensation rows: ',COALESCE(CONVERT(varchar(30),w.Effective_Record_Count),'0'))),
 ('DQ014',w.Missing_Salary_Flag,CONCAT('Pay type: ',COALESCE(w.Pay_Type,'NULL'),'; annual salary: ',COALESCE(CONVERT(varchar(30),w.Annual_Salary),'NULL')))
) x(Rule_ID,Rule_Failed,Actual_Value)
INNER JOIN governed.DataQualityRule r ON x.Rule_ID=r.Rule_ID AND r.Active_Flag=1
WHERE x.Rule_Failed=1;
GO

