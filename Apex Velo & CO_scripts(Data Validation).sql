-- Data Validation 

-- Duplication analysis 
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY CustomerID
           ORDER BY OrderDate DESC
       ) AS rn
FROM SalesOrderHeader;

-- Removing rowguid from necessary and related tables
ALTER TABLE salesperson DROP COLUMN rowguid;
ALTER TABLE store DROP COLUMN rowguid;
ALTER TABLE productsubcategory DROP COLUMN rowguid;
ALTER TABLE productcategory DROP COLUMN rowguid;
ALTER TABLE product DROP COLUMN rowguid;
ALTER TABLE salesorderheader DROP COLUMN rowguid;
ALTER TABLE salesorderdetail DROP COLUMN rowguid;

/* TRANSFORMATION: Splitting DueDate into separate Date and Time.
   This improves join performance with the Calendar Table and 
   enables time-of-day analysis.
*/
SELECT 
    SalesOrderID,
    DueDate AS Original_Timestamp,
    -- Extracting the Date only (YYYY-MM-DD)
    CAST(DueDate AS DATE) AS DueDate_Clean,
    -- Extracting the Time only (HH:MM:SS)
    CAST(DueDate AS TIME) AS DueTime_clean
FROM salesorderheader;