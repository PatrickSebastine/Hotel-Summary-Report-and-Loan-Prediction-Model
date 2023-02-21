# Hotel Summary Report and Loan Prediction Model

This repository contains two projects. The first project involves data analysis and visualization of the BlackTECH hotel executive summary database, while the second project involves developing a loan prediction model for the BlackTECH financial institution.  

## BlackTECH Hotel Executive Summary Database  
The BlackTECH hotel executive summary database was provided in .csv files by the revenue management team. The data extracts from a hotel system include bookings, food orders, menu, requests, and rooms.  


During data analysis, it was discovered that there were data integrity/anomaly issues in three date entries on the booking table. The inconsistent column names were also corrected to maintain consistency across tables. The Food Order table had a stable join with the Menu table, but joining with the Booking, Request, and Room tables resulted in too many null values, repetitions of food orders, and order dates. As a solution, the final table was split into two, the Restaurant and Reservation tables.  


Additionally, missing records were found during the join of the Request and Booking tables, which analysis suggests were "not confirmed" or "cancelled" bookings.  


To visualize accurate time series and trends, a new table was created using DAX on Power BI, linking check-in date, check-out date, and order date. 



## BlackTECH Loan Prediction Model   
The second project involves developing a prediction model to predict whether a borrower's loan will be rolled or not, based on their previous 6 months financial records. The dataset provided had 5783 records (rows) and 11 fields (columns), with 6.5% of null values and 533 duplicate values, which were subsequently dropped. The ‘loan_id’ and ‘delq_history’ fields were also dropped since they were not needed for the analysis. Debt-to-income ratio and interest rate were derived to assist in making better predictions.  


After the data cleaning process, the Dataframe was left with 4873 records and 12 fields.  


Three classification models (Logistic Regression, Random Forest, and XGBoost) were tested, and the XGBoost model was recommended for predicting whether a borrower's loan will be rolled or not, with an accuracy and precision score of 100% and false positives and false negatives of 0. 



## Technologies Used
- SQL server
- Power BI
- Python
- Pandas
- Scikit-learn
- Logistics Regression Classification Model
- Random Forest Classification Model
- XGBoost Classification Model

## Conclusion  
This project provided insights into the hotel's growth and a prediction model for the financial institution. The XGBoost model was recommended to help the collections team predict whether a borrower's loan will be rolled or not based on their previous 6 months financial records.

