use healthcare;
/*Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine 
that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, wants to get a report of 
which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to generate 
the report so that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice
 if possible.  */
 SELECT pharmacyid,pharmacyname,count(*) AS medicines_count FROM pharmacy
 JOIN prescription USING(pharmacyid)
 JOIN contain USING(prescriptionid)
 JOIN medicine USING(medicineid)
 JOIN treatment USING(treatmentid)
 WHERE (YEAR(date)=2021 OR YEAR(date)=2022) AND hospitalexclusive='S'
 GROUP BY pharmacyid
 ORDER BY medicines_count DESC;
 
 /*Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments 
the plan was claimed for. The report would be more relevant if the data compares the performance for different 
years(2020, 2021 and 2022) and if the report also includes the total number of claims in the different years, as 
well as the total number of claims for each plan in all 3 years combined.*/

 