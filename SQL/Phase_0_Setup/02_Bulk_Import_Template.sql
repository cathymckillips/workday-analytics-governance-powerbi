USE PeopleAnalyticsLab;
GO

-- Change this folder in EVERY BULK INSERT statement to the folder on your computer.
-- SQL Server, not SSMS, must be able to read the folder.

BULK INSERT raw.Organization FROM 'C:\PeopleAnalytics\Phase1\csv\01_Organizations.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.Position FROM 'C:\PeopleAnalytics\Phase1\csv\02_Positions.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.WorkerSnapshot FROM 'C:\PeopleAnalytics\Phase1\csv\03_Workers_2026-09-30.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.WorkerSnapshot FROM 'C:\PeopleAnalytics\Phase1\csv\04_Workers_2026-10-31.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.WorkerSnapshot FROM 'C:\PeopleAnalytics\Phase1\csv\05_Workers_2026-11-30.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.Compensation FROM 'C:\PeopleAnalytics\Phase1\csv\06_Compensation.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.EmployeeLeave FROM 'C:\PeopleAnalytics\Phase1\csv\07_Leave.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.Recruiting FROM 'C:\PeopleAnalytics\Phase1\csv\08_Recruiting.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.EmployeeCompliance FROM 'C:\PeopleAnalytics\Phase1\csv\09_Compliance.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT raw.ReportingCalendar FROM 'C:\PeopleAnalytics\Phase1\csv\10_Reporting_Calendar.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', ROWTERMINATOR='0x0a', TABLOCK);
GO

