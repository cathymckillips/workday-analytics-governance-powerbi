IF DB_ID('PeopleAnalyticsLab') IS NULL
BEGIN
    CREATE DATABASE PeopleAnalyticsLab;
END;
GO

USE PeopleAnalyticsLab;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'raw') EXEC('CREATE SCHEMA raw');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging') EXEC('CREATE SCHEMA staging');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'governed') EXEC('CREATE SCHEMA governed');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'reporting') EXEC('CREATE SCHEMA reporting');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit') EXEC('CREATE SCHEMA audit');
GO

