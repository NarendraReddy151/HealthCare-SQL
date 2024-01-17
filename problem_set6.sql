use healthcare;
/*Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine 
prescribed in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of 
hospital-exclusive medicine to the total medicine prescribed in 2022.Order the result in descending order of the percentage found.*/ 
SELECT pharmacyid,pharmacyname,SUM(quantity) medicine_quantity,
SUM(CASE WHEN hospitalExclusive='S' THEN QUANTITY ELSE NULL END) hospital_exclusive_quantity,
ROUND((SUM(CASE WHEN hospitalExclusive='S' THEN QUANTITY ELSE NULL END)/SUM(quantity))*100,2) AS hospital_exclusive_total_medicine_perc
FROM pharmacy
JOIN prescription USING(pharmacyid)
JOIN contain USING(prescriptionid)
JOIN medicine USING(medicineid)
JOIN treatment USING(treatmentid)
WHERE YEAR(date)=2022
GROUP BY pharmacyid
ORDER BY hospital_exclusive_total_medicine_perc DESC;
-- -------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.*/
SELECT state,COUNT(CASE WHEN claimid IS NULL THEN 1 ELSE NULL END) AS not_claimed,
COUNT(claimid) AS claimed,(COUNT(CASE WHEN claimid IS NULL THEN 1 ELSE NULL END)/COUNT(claimid))*100 AS perc
FROM treatment 
RIGHT JOIN claim USING(claimid)
RIGHT JOIN insuranceplan USING(UIN)
RIGHT JOIN insurancecompany USING(companyid)
RIGHT JOIN address USING(addressid)
GROUP BY state;

-- --------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the 
patients of that state in the year 2022.*/ 
SELECT state,diseasename, treatment_cnt FROM(
SELECT state,diseasename,COUNT(treatmentID)AS treatment_cnt,
FIRST_VALUE(COUNT(treatmentid)) OVER(PARTITION BY state ORDER BY COUNT(treatmentid) DESC ) AS first,
LAST_VALUE(COUNT(treatmentid)) OVER(PARTITION BY state ORDER BY COUNT(treatmentid) DESC rows between current row and unbounded following ) AS last
FROM disease
JOIN treatment USING(diseaseid)
JOIN person ON treatment.patientid=person.personid
JOIN address USING(addressid)
WHERE YEAR(date)=2022
GROUP BY state,diseaseID
ORDER BY state ,COUNT(treatmentid) DESC) A
WHERE treatment_cnt=first OR treatment_cnt=last;

-- ---------------------------------------------------------------------------------------------------------------------
/*Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, 
in each city. Generate a report that shows each city that has 10 or more registered people belonging to it and the number
 of patients from that city as well as the percentage of the patient with respect to the registered people.*/
SELECT city,COUNT(personid) AS registered_people,COUNT(patientid) AS no_of_patients,ROUND((COUNT(patientid)/COUNT(personid))*100,2) AS perc_patient_to_people FROM patient
RIGHT JOIN person ON patient.patientid=person.personid
JOIN address USING(addressid)
GROUP BY city
HAVING COUNT(personid)>10 AND COUNT(patientID)>10;

-- ------------------------------------------------------------------------------------------------------------------
/*Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects.
Find the top 3 companies using the substance in their medicine so that they can be informed about it.*/

SELECT companyname AS company_name ,COUNT(substancename) AS ranitidine_medicines FROM medicine
WHERE substancename='ranitidina'
GROUP BY companyname
ORDER BY ranitidine_medicines DESC
LIMIT 3;


