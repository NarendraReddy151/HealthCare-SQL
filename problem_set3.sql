USE healthcare;
/*
Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive 
medicine that they can’t find elsewhere and facing problems due to that.Joshua, from the pharmacy management, 
wants to get a report of which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. 
Assist Joshua to generate the report so that the pharmacies who prescribe hospital-exclusive medicine more often are 
advised to avoid such practice if possible. */
SELECT pharmacyid,pharmacyname,sum(quantity) AS quantity FROM pharmacy
JOIN prescription USING(pharmacyid)
JOIN contain USING(prescriptionid)
JOIN medicine USING(medicineid)
JOIN treatment USING(treatmentid)
WHERE hospitalExclusive='S' AND
(YEAR(date)='2021' OR YEAR(date)='2022')
GROUP BY pharmacyid
order by sum(quantity) desc;
-- --------------------------------------------------------------------------------------------------------------------
/*Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments 
the plan was claimed for.*/
 SELECT planname AS plan_name,companyName AS company_name,count(treatmentid) AS no_of_treatments FROM insurancecompany
 JOIN insuranceplan USING(companyID)
 JOIN claim USING(UIN)
 JOIN treatment USING(claimid)
 GROUP BY plan_name,companyname
 ORDER BY plan_name,companyname;
 
 
 -- -------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans.*/
-- SELECT companyname,planname,count(claimid),
-- RANK() OVER(PARTITION BY companyname ORDER BY count(claimid)DESC) AS ran FROM insurancecompany
-- JOIN insuranceplan USING(companyid)
-- JOIN claim USING(UIN)
-- GROUP BY companyname,planname
-- ORDER BY companyname,count(claimID) DESC;
SELECT companyname,planname,cnt FROM (SELECT companyname,planname,count(claimid) cnt,
FIRST_VALUE(count(claimid)) OVER(PARTITION BY companyname ORDER BY count(claimid)DESC) AS first,
LAST_VALUE(count(claimid)) OVER(PARTITION BY companyname ORDER BY count(claimid)DESC 
rows between current row and unbounded following) AS last
FROM insurancecompany
JOIN insuranceplan USING(companyid)
JOIN claim USING(UIN)
GROUP BY companyname,planname
ORDER BY companyname,count(claimID) DESC)A
WHERE cnt=first OR cnt=last;

-- -----------------------------------------------------------------------------------------------------------
/*Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state 
requires more attention in the healthcare sector. Generate a report for them that shows the state name, 
number of registered people in the state, number of registered patients in the state, and the people-to-patient ratio. 
sort the data by people-to-patient ratio.*/

SELECT state,COUNT(personID) AS registered_people,COUNT(patientid) AS registered_patients,COUNT(personid)/count(patientid) AS people_patient_ratio
FROM patient
RIGHT JOIN person ON patient.patientID=person.personid
JOIN address USING(addressid)
GROUP BY state
ORDER BY people_patient_ratio;

-- ---------------------------------------------------------------------------------------------------------
/*Problem Statement 5: Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the
 total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria I for treatments 
 that took place in 2021. Assist Jhonny in generating the report.*/
 SELECT keep.pharmacyid,pharmacy.pharmacyname,SUM(keep.quantity) AS quantity,COUNT(contain.medicineid) AS medicine_ids FROM address
 JOIN pharmacy USING(addressid)
 JOIN keep USING(pharmacyid)
 JOIN medicine USING(medicineid)
 JOIN contain USING(medicineid)
 JOIN prescription USING(prescriptionID)
 JOIN treatment USING(treatmentid)
 WHERE YEAR(date)=2021 AND taxcriteria='I' AND state='AZ'
 GROUP BY keep.pharmacyid
 ORDER BY count(contain.medicineid);


 
 