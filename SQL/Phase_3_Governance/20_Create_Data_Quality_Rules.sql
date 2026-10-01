USE PeopleAnalyticsLab;
GO
IF OBJECT_ID('governed.DataQualityRule','U') IS NULL
CREATE TABLE governed.DataQualityRule
(
 Rule_ID varchar(10) NOT NULL PRIMARY KEY,Rule_Name nvarchar(150) NOT NULL,
 Rule_Description nvarchar(500) NOT NULL,Expected_Condition nvarchar(500) NOT NULL,
 Severity varchar(20) NOT NULL,Data_Owner nvarchar(100) NOT NULL,
 Blocks_Workforce_Publish bit NOT NULL,Blocks_Compensation_Publish bit NOT NULL,
 Blocks_Compliance_Publish bit NOT NULL,Active_Flag bit NOT NULL,
 Created_Date datetime2(0) NOT NULL DEFAULT SYSDATETIME(),
 CONSTRAINT CK_DQRule_Severity CHECK(Severity IN('Critical','High','Medium','Low'))
);
GO
DELETE FROM governed.DataQualityRule WHERE Rule_ID BETWEEN 'DQ001' AND 'DQ014';
INSERT governed.DataQualityRule
(Rule_ID,Rule_Name,Rule_Description,Expected_Condition,Severity,Data_Owner,Blocks_Workforce_Publish,Blocks_Compensation_Publish,Blocks_Compliance_Publish,Active_Flag)
VALUES
('DQ001','Duplicate worker snapshot record','More than one worker row exists for an employee and snapshot.','One row per Employee_ID and snapshot.','High','HRIS',0,0,0,1),
('DQ002','Invalid position reference','Position_ID does not resolve.','Populated Position_ID must exist.','High','HRIS',1,0,0,1),
('DQ003','Invalid department reference','Department_ID does not resolve.','Populated Department_ID must exist.','High','HRIS',1,0,1,1),
('DQ004','Missing manager','Worker has no Manager_ID.','Active nonexecutive workers should have a manager.','Medium','Human Resources',0,0,0,1),
('DQ005','Invalid manager reference','Manager_ID does not resolve in the snapshot.','Populated Manager_ID must resolve.','Medium','HRIS',0,0,0,1),
('DQ006','Missing job profile','Worker has no Job_Profile_ID.','Active workers should have a job profile.','High','Human Resources',0,1,1,1),
('DQ007','Job profile mismatch','Worker and position profiles differ.','Worker and position profiles should agree.','High','HRIS',1,1,0,1),
('DQ008','Invalid FTE','FTE is null, nonpositive, or above 1.0.','FTE must be >0 and <=1.0.','High','Human Resources',1,0,0,1),
('DQ009','Active worker with termination date','Active status conflicts with an effective termination.','Active workers cannot have an effective termination.','Critical','HRIS',1,1,1,1),
('DQ010','Terminated worker without date','Terminated status has no date.','Terminated workers require a date.','Critical','HRIS',1,1,1,1),
('DQ011','Future hire in snapshot','Hire date follows snapshot date.','Hire date must be on/before snapshot for current HC.','Critical','HRIS',1,1,1,1),
('DQ012','Missing compensation record','No compensation record is effective.','Eligible employees require effective compensation.','High','Compensation',0,1,0,1),
('DQ013','Multiple effective compensation records','Multiple compensation rows are effective.','Only one compensation row should be effective.','High','Compensation',0,1,0,1),
('DQ014','Missing annual salary','Salaried worker has no annual salary.','Annual salary is required for Salary pay type.','High','Compensation',0,1,0,1);
GO

