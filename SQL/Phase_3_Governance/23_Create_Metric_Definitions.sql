USE PeopleAnalyticsLab;
GO
IF OBJECT_ID('governed.MetricDefinition','U') IS NULL
CREATE TABLE governed.MetricDefinition
(
 Metric_ID varchar(20) NOT NULL PRIMARY KEY,Metric_Name nvarchar(150) NOT NULL,
 Business_Definition nvarchar(1000) NOT NULL,Calculation_Logic nvarchar(1000) NOT NULL,
 Primary_Source nvarchar(200) NOT NULL,Reporting_Cadence varchar(30) NOT NULL,
 Metric_Owner nvarchar(100) NOT NULL,Approved_Flag bit NOT NULL,Effective_Date date NOT NULL,Notes nvarchar(1000) NULL
);
GO
DELETE FROM governed.MetricDefinition WHERE Metric_ID BETWEEN 'MET001' AND 'MET007';
INSERT governed.MetricDefinition
(Metric_ID,Metric_Name,Business_Definition,Calculation_Logic,Primary_Source,Reporting_Cadence,Metric_Owner,Approved_Flag,Effective_Date,Notes)
VALUES
('MET001','Active Headcount','Distinct workers active as of the reporting date.','Count distinct Employee_ID where status is Active, hire date is on/before the report date, and termination is null/after the report date.','Worker snapshot','Weekly/Monthly','People Analytics',0,'2026-09-01','Pending HR approval for contingent workers.'),
('MET002','Active FTE','Total FTE capacity for active workers.','Sum valid FTE for workers meeting Active Headcount.','Worker and position','Monthly','People Analytics',0,'2026-09-01','Expected FTE range is >0 and <=1.'),
('MET003','New Hires','Workers hired during the period.','Count distinct Employee_ID with Hire_Date in period.','Worker snapshot','Monthly','People Analytics',0,'2026-09-01','Rehire treatment requires approval.'),
('MET004','Terminations','Workers terminated during the period.','Count distinct Employee_ID with Termination_Date in period.','Worker snapshot','Monthly','People Analytics',0,'2026-09-01',NULL),
('MET005','Net Workforce Change','Difference between hires and terminations.','New Hires minus Terminations.','Worker snapshots','Monthly','People Analytics',0,'2026-09-01',NULL),
('MET006','Turnover Rate','Terminations divided by average active headcount.','Terms / average of beginning and ending active HC.','Worker snapshots','Monthly','People Analytics',0,'2026-09-01','Population requires HR approval.'),
('MET007','Compliance Complete Percentage','Eligible active employees complete across required controls.','Fully complete eligible active employees / all eligible active employees.','Worker and compliance','Monthly','HR Compliance',0,'2026-09-01','Eligibility requires approval.');
GO

