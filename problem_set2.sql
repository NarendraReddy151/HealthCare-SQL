/*Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea 
that the pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest 
and the number of prescriptions should exceed 100. Assist the company to identify those cities 
where the pharmacy can be set up*/
SELECT city,count(DISTINCT pharmacyid) AS no_of_pharmacies,count(DISTINCT prescriptionid) AS no_of_prescriptions,
count(DISTINCT pharmacyid)/count(DISTINCT prescriptionid) AS pharmacies_to_prescriptions FROM pharmacy
JOIN prescription USING(pharmacyid)
JOIN address USING(addressid)
GROUP BY city
HAVING count(prescriptionid)>100
ORDER BY pharmacies_to_prescriptions
LIMIT 3;

-- ----------------------------------------------------------------------------------------------------------------------
/*Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently.
 For each city in their state, they need to identify the disease for which the maximum number of patients have gone 
 for treatment. Assist the state for this purpose.Note: The state of Alabama is represented as AL in Address Table.*/

SELECT city,diseaseName, patient_count FROM (SELECT DISTINCT city,diseaseid,diseaseName, COUNT(patientid) AS patient_count,
RANK() OVER(PARTITION BY city ORDER BY COUNT(patientID) DESC) AS ran
 FROM disease
 JOIN treatment USING(diseaseid)
 JOIN patient USING(patientid)
 JOIN person ON patient.patientID=person.personID
 JOIN address USING(addressid)
 WHERE state='AL'
 GROUP BY city,diseaseid
 ORDER BY  patient_count DESC) a
 WHERE ran=1;
  
 use healthcare;
 

-- --------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3: The healthcare department needs a report about insurance plans. 
The report is required to include th1we insurance plan, which was claimed the most and least for each disease.  
Assist to create such a report.*/

(SELECT diseasename,planname,insurance_claim_cnt FROM(SELECT diseaseid,diseasename,count(UIN) AS insurance_claim_cnt,planname,
RANK() OVER(PARTITION BY diseasename ORDER BY COUNT(UIN) DESC) AS c_rank FROM disease
JOIN treatment USING(diseaseid)
JOIN claim USING(claimid)
JOIN insuranceplan USING(UIN)
GROUP BY diseaseid,planname
ORDER BY diseasename) a
WHERE c_rank=1)
UNION
(SELECT diseasename,planname,insurance_claim_cnt FROM(SELECT diseaseid,diseasename,count(UIN) AS insurance_claim_cnt,planname,
RANK() OVER(PARTITION BY diseasename ORDER BY COUNT(UIN)) AS c_rank FROM disease
JOIN treatment USING(diseaseid)
JOIN claim USING(claimid)
JOIN insuranceplan USING(UIN)
GROUP BY diseaseid,planname
ORDER BY diseasename) a
WHERE c_rank=1)
ORDER BY diseasename;

SELECT * FROM disease
JOIN treatment USING(diseaseid)
JOIN claim USING(claimid);


-- ----------------------------------------------------------------------------------------------------------------
/*Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect multiple people 
in the same household. For each disease find the number of households that has more than one patient with the same disease.*/

SELECT diseasename AS disease_name,COUNT( DISTINCT addressid) AS no_of_households FROM (SELECT diseasename,addressid,count(patientid) as patient_cnt FROM address
JOIN person USING(addressid)
JOIN treatment ON person.personid=treatment.patientid
JOIN disease USING(diseaseid)
GROUP BY diseasename,addressid
HAVING count(patientid)>1) A
GROUP BY diseasename;

-- -----------------------------------------------------------------------------------------------------------------
/*Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio between 1st April 2021
and 31st March 2022 (days both included). Assist them to create such a report.*/

SELECT state,COUNT(treatmentID) AS number_of_treatments,COUNT(claimID) AS number_of_claims,COUNT(treatmentID)/COUNT(claimID) AS treatment_claim_ratio 
FROM address
LEFT JOIN person USING(addressid)
LEFT JOIN treatment ON person.personid=treatment.patientID
LEFT JOIN claim USING(claimid)
WHERE date BETWEEN '2021-04-01' AND '2022-03-31'
GROUP BY state
ORDER BY state;
 
 