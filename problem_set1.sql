select * from patient;

USE healthcare;
-- ----------------------------------------------------------------------------------------------------------------------
/*Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report*/

SELECT
CASE 
	WHEN age BETWEEN 0 AND 14 THEN 'Children'
	WHEN age BETWEEN 15 AND 24 THEN 'Youth'
	WHEN age BETWEEN 25 AND 64 THEN 'Adults'
	ELSE 'Seniors'
END AS category,
COUNT(treatmentID) AS treatments_count
FROM(
    SELECT *,TIMESTAMPDIFF(YEAR,dob,'2022-01-01') AS age
    FROM patient 
) subquery RIGHT JOIN treatment USING(patientId)
WHERE YEAR(date)=2022
GROUP BY category;

-- ------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy.*/

SELECT diseasename AS disease_name,COUNT(CASE WHEN gender = 'male' THEN 1 ELSE NULL END) / 
COUNT(CASE WHEN gender = 'female' THEN 1 ELSE NULL END) AS male_to_female_ratio from treatment
JOIN person ON person.personid=treatment.patientID
JOIN disease USING(diseaseId)
GROUP BY DISEASENAME
ORDER BY male_to_female_ratio DESC;

SELECT diseasename AS disease_name,COUNT(CASE WHEN gender = 'female' THEN 1 ELSE NULL END) / COUNT(CASE WHEN gender = 'male' THEN 1 ELSE NULL END) AS female_to_male_ratio from treatment
JOIN person ON person.personid=treatment.patientID
JOIN disease USING(diseaseId)
GROUP BY DISEASENAME
ORDER BY female_to_male_ratio DESC;

-- -----------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made 
for all the treatments. He also wants to figure out if the gender of the patient has any 
impact on the insurance claim. Assist Jacob in this situation by generating a report that finds for 
each gender the number of treatments, number of claims, and treatment-to-claim ratio. 
And notice if there is a significant difference between the */

SELECT gender,COUNT(treatmentID) AS number_of_treatments,COUNT(claimID) AS number_of_claims,COUNT(treatmentID)/COUNT(claimID) AS treatment_claim_ratio 
FROM person
LEFT JOIN treatment ON person.personid=treatment.patientID
LEFT JOIN claim USING(claimid)
GROUP BY GENDER;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------

/*Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. Generate a report on their behalf that shows 
how many units of medicine each pharmacy has in their inventory, the total maximum retail price of those medicines, and the total price of all the 
medicines after discount. Note: discount field in keep signifies the percentage of discount on the maximum price.*/ 

SELECT pharmacyname,sum(maxprice),sum(quantity),sum(total_price)
FROM(SELECT pharmacyID,pharmacyname,quantity,maxprice*quantity AS maxPrice,
CASE WHEN discount<>0 THEN (maxprice*quantity)*((100-discount)/100) 
	 ELSE (maxprice*quantity) 
END AS total_price
FROM medicine
JOIN keep USING(medicineId)
JOIN pharmacy USING(pharmacyId)) A 
GROUP BY pharmacyid;

SELECT pharmacyID,pharmacyname,COUNT(medicineID) AS no_of_medicineId,SUM(quantity) AS medicine_units,SUM(maxprice*quantity) AS maxPrice,
ROUND(SUM(CASE WHEN discount<>0 THEN (maxprice*quantity)*((100-discount)/100) 
	 ELSE (maxprice*quantity) 
END),2)AS total_price
FROM medicine
JOIN keep USING(medicineId)
JOIN pharmacy USING(pharmacyId)
GROUP BY pharmacyId; -- T

SELECT pharmacyID,pharmacyname,COUNT(medicineID) AS no_of_medicineId,SUM(quantity) AS medicine_units,SUM(maxprice) AS maxPrice,
ROUND(SUM(CASE WHEN discount<>0 THEN (maxprice)*((100-discount)/100) 
	 ELSE (maxprice) 
END),2)AS total_price
FROM medicine
JOIN keep USING(medicineId)
JOIN pharmacy USING(pharmacyId)
GROUP BY pharmacyId;

-- ------------------------------------------------------------------------------------------------------------------------------------------------

/*Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, 
for them, generate a report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. */
SELECT DISTINCT pharmacyid,
MAX(SUM(quantity)) OVER (PARTITION BY pharmacyid) AS max,
MIN(SUM(quantity)) OVER (PARTITION BY pharmacyid) AS min,
AVG(SUM(quantity)) OVER (PARTITION BY pharmacyid) AS avg FROM contain
JOIN prescription USING(prescriptionID)
GROUP BY PHARMACYID,prescriptionID;

SELECT DISTINCT pharmacyid,
MAX(COUNT(medicineid)) OVER (PARTITION BY pharmacyid) AS max,
MIN(COUNT(medicineid)) OVER (PARTITION BY pharmacyid) AS min,
AVG(COUNT(medicineid)) OVER (PARTITION BY pharmacyid) AS avg FROM contain
JOIN prescription USING(prescriptionID)
GROUP BY PHARMACYID,prescriptionID; -- T

SELECT * FROM contain
JOIN prescription USING(prescriptionID);




