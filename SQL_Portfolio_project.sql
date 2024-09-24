Create database  telco;
Use telco;
Select *From dataset_for_import;
#Query 1: Top 5 Groups with the Highest Average Monthly Charges among Churned Customers

SELECT 
   CASE 
      WHEN Age < 30 THEN 'Young Adults'
      WHEN Age >= 30 AND Age < 50 THEN 'Middle-Aged Adults'
      ELSE 'Seniors'
   END AS AgeGroup,
   Contract,
   Gender,
   ROUND(AVG(`Tenure in Months`),2) AS AvgTenure,
   ROUND(AVG(`Monthly Charge`),2) AS AvgMonthlyCharge
FROM dataset_for_import
WHERE `Churn Label` LIKE '%Yes%'
GROUP BY AgeGroup, `Customer Status`, Contract, Gender
ORDER BY AvgMonthlyCharge DESC
LIMIT 5;

#Query 2: What are the feedback or complaints from those churned customers.

SELECT `Churn Category`, COUNT(`Customer ID`) AS churn_count
FROM dataset_for_import
WHERE `Churn Label` LIKE "%Yes%"
GROUP BY `Churn Category`
ORDER BY churn_count DESC;

SELECT `Churn Category`, COUNT(`Customer ID`) AS churn_count, 
		ROUND(COUNT(`Customer ID`)/7043*100,2) AS proportion_in_percent
FROM dataset_for_import
GROUP BY `Churn Category`
ORDER BY churn_count DESC;

#Query 3: How does the payment method influence churn behavior?

WITH ChurnData AS (
    SELECT `Payment Method`, COUNT(`Customer ID`) AS Churned
    FROM dataset_for_import
    WHERE `Churn Label` LIKE '%Yes%'
    GROUP BY `Payment Method`),
LoyalData AS (
    SELECT  `Payment Method`, COUNT(`Customer ID`) AS Loyal
    FROM dataset_for_import
    WHERE `Churn Label` LIKE '%No%'
    GROUP BY `Payment Method`)
    
SELECT 
    a.`Payment Method`, a.Churned, b.Loyal, 
    a.Churned + b.Loyal AS total, 
    SUM(a.Churned + b.Loyal) OVER (ORDER BY a.`Payment Method`) AS running_total
FROM ChurnData a 
INNER JOIN LoyalData b
ON a.`Payment Method` = b.`Payment Method`;
