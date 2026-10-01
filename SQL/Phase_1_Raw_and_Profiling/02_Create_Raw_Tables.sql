USE PeopleAnalyticsLab;
GO

DROP TABLE IF EXISTS raw.Organization;
CREATE TABLE raw.Organization (
 Department_ID nvarchar(20), Department_Name nvarchar(100), Cost_Center nvarchar(30),
 Supervisory_Organization nvarchar(100), Business_Unit nvarchar(100), Active_Flag nvarchar(10)
);

DROP TABLE IF EXISTS raw.Position;
CREATE TABLE raw.Position (
 Position_ID nvarchar(20), Job_Profile_ID nvarchar(20), Job_Title nvarchar(100), Job_Family nvarchar(100),
 Job_Grade nvarchar(20), FTE decimal(9,2), Exempt_Status nvarchar(30), Department_ID nvarchar(20),
 Location nvarchar(100), Position_Status nvarchar(30)
);

DROP TABLE IF EXISTS raw.WorkerSnapshot;
CREATE TABLE raw.WorkerSnapshot (
 Employee_ID nvarchar(20), Worker_Type nvarchar(50), First_Name nvarchar(100), Last_Name nvarchar(100),
 Work_Email nvarchar(255), Hire_Date date, Termination_Date date, Employment_Status nvarchar(30),
 Position_ID nvarchar(20), Manager_ID nvarchar(20), Department_ID nvarchar(20), Location nvarchar(100),
 FTE decimal(9,2), Job_Profile_ID nvarchar(20), Extract_As_Of_Date date, Source_System nvarchar(100),
 Last_Updated_Timestamp datetime2(0)
);

DROP TABLE IF EXISTS raw.Compensation;
CREATE TABLE raw.Compensation (
 Compensation_Record_ID nvarchar(20), Employee_ID nvarchar(20), Pay_Type nvarchar(30),
 Annual_Salary decimal(18,2), Hourly_Rate decimal(18,2), Currency nvarchar(10), Effective_Date date,
 End_Date date, Source_System nvarchar(100)
);

DROP TABLE IF EXISTS raw.EmployeeLeave;
CREATE TABLE raw.EmployeeLeave (
 Leave_ID nvarchar(20), Employee_ID nvarchar(20), Leave_Type nvarchar(50), Start_Date date, End_Date date,
 Leave_Status nvarchar(30), Approved_Date date, Source_System nvarchar(100)
);

DROP TABLE IF EXISTS raw.Recruiting;
CREATE TABLE raw.Recruiting (
 Requisition_ID nvarchar(20), Position_ID nvarchar(20), Department_ID nvarchar(20), Open_Date date,
 Close_Date date, Requisition_Status nvarchar(30), Candidate_ID nvarchar(30), Offer_Date date,
 Hire_Date date, Recruiter nvarchar(100)
);

DROP TABLE IF EXISTS raw.EmployeeCompliance;
CREATE TABLE raw.EmployeeCompliance (
 Employee_ID nvarchar(20), I9_Status nvarchar(30), Code_of_Conduct_Status nvarchar(30),
 Harassment_Training_Status nvarchar(30), Training_Due_Date date, Background_Check_Status nvarchar(30),
 As_Of_Date date
);

DROP TABLE IF EXISTS raw.ReportingCalendar;
CREATE TABLE raw.ReportingCalendar (
 Report_Name nvarchar(150), Cadence nvarchar(30), Reporting_Period_End date, Expected_Run_Date date,
 Actual_Run_Date date, Owner nvarchar(100), Validation_Status nvarchar(50), Publication_Status nvarchar(50),
 Notes nvarchar(500)
);
GO

