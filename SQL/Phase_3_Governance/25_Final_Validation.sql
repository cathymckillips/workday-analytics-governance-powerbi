USE PeopleAnalyticsLab;
GO
SELECT Extract_As_Of_Date,COUNT(*) AS Exception_Count,COUNT(DISTINCT Employee_ID) AS Affected_Employees
FROM governed.vw_HRDataQualityExceptions GROUP BY Extract_As_Of_Date ORDER BY Extract_As_Of_Date;

SELECT * FROM governed.vw_ReportPublicationGate ORDER BY Extract_As_Of_Date;

WITH r AS(SELECT Extract_As_Of_Date,COUNT(*) n FROM raw.WorkerSnapshot GROUP BY Extract_As_Of_Date),
s AS(SELECT Extract_As_Of_Date,COUNT(*) n FROM staging.vw_WorkerSnapshotClean GROUP BY Extract_As_Of_Date),
g AS(SELECT Extract_As_Of_Date,COUNT(*) n FROM governed.vw_WorkforceGoverned GROUP BY Extract_As_Of_Date),
p AS(SELECT Extract_As_Of_Date,COUNT(*) n FROM reporting.vw_WorkforceTrusted GROUP BY Extract_As_Of_Date)
SELECT r.Extract_As_Of_Date,r.n AS Raw_Rows,s.n AS Staging_Rows,g.n AS Governed_Rows,p.n AS Reporting_Rows,
       r.n-s.n AS Raw_To_Staging_Difference,
       CASE WHEN s.n=g.n AND g.n=p.n THEN 'Passed' ELSE 'Requires Investigation' END AS Layer_Reconciliation_Status
FROM r JOIN s ON r.Extract_As_Of_Date=s.Extract_As_Of_Date
JOIN g ON r.Extract_As_Of_Date=g.Extract_As_Of_Date
JOIN p ON r.Extract_As_Of_Date=p.Extract_As_Of_Date ORDER BY r.Extract_As_Of_Date;

SELECT * FROM audit.ReportRun ORDER BY Report_Run_ID DESC;
GO
