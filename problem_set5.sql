/*Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.*/
SELECT personname AS patient_name,COUNT(treatmentid) AS no_of_treatments FROM patient
JOIN treatment USING(patientid)
JOIN person ON patient.patientid=person.personid
GROUP BY patientid
HAVING COUNT(treatmentid)>1
ORDER BY no_of_treatments DESC;

-- -----------------------------------------------------------------------------------------------------------
/*Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease is more likely 
to infect a certain gender or not.Help Bharat analyze this by creating a report showing for every disease how many males
and females underwent treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio 
is also shown.*/

SELECT diseaseid,diseasename,female,male,male/female  AS male_female_ratio FROM(
	SELECT diseaseid,diseasename,COUNT(treatmentid) as female,
	LEAD(COUNT(treatmentid)) OVER(PARTITION BY diseaseid ORDER BY  diseaseid,gender) AS male
	FROM disease
	JOIN treatment USING(diseaseid)
	JOIN person ON treatment.patientid=person.personid
    WHERE YEAR(date)=2021
	GROUP BY diseaseid,gender
	ORDER BY diseaseid,gender) A
WHERE male IS NOT NULL
ORDER BY male_female_ratio DESC;
-- ----------------------------------------------------------------------------------------------
/*Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, the top 3 cities 
that had the most number treatment for that disease.Generate a report for Kelly’s requirement.*/
SELECT * FROM(
	SELECT diseaseid,diseasename,city,COUNT(treatmentid)AS no_of_treatments,
	DENSE_RANK() OVER( PARTITION BY diseaseid ORDER BY COUNT(treatmentid) DESC) AS city_rank
	FROM disease
	JOIN treatment USING(diseaseid)
	JOIN person ON treatment.patientid=person.personid
	JOIN address USING(addressid)
	GROUP BY diseaseid,city) A
WHERE city_rank<4;

-- SELECT diseaseid,diseasename,city,
-- COUNT(treatmentid) OVER(PARTITION BY diseaseid,city) AS cnt

-- FROM disease
-- JOIN treatment USING(diseaseid)
-- JOIN person ON treatment.patientid=person.personid
-- JOIN address USING(addressid);

-- -------------------------------------------------------------------------------------------------------------
/*Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not,
 For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions 
 they have prescribed for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 
 2022 be displayed in two separate columns.Write a query for Brooke’s requirement.*/
 SELECT diseaseid,pharmacyid,pharmacyname,diseasename,
 COUNT(CASE WHEN YEAR(date)=2021 THEN 1 ELSE NULL END) AS '2021', 
 COUNT(CASE WHEN YEAR(date)=2022 THEN 1 ELSE NULL END ) AS '2022'
 FROM pharmacy
 JOIN prescription USING(pharmacyid)
 JOIN treatment USING(treatmentid)
 JOIN disease USING(diseaseid)
 WHERE YEAR(date)=2021 OR YEAR(date)=2022
 GROUP BY pharmacyid,diseaseid
 ORDER BY pharmacyid,diseasename;
 

-- ------------------------------------------------------------------------------------------------------------------
/*Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company is
targeting the patients of which state the most. Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming 
more insurance of that company.*/
SELECT state,companyname AS company_name,insurance_claim_count FROM(
	SELECT state,companyname,count(cl.claimid) AS insurance_claim_count,
	RANK() OVER(PARTITION BY state ORDER BY count(claimid) DESC) AS claim_rank
	FROM insurancecompany c
	JOIN insuranceplan p ON c.companyid=p.companyid
	JOIN claim cl ON cl.UIN=p.UIN
    JOIN treatment t ON cl.claimid=t.claimid
    JOIN person pe on t.patientid=pe.personid
    JOIN address a ON a.addressid=pe.addressid
	GROUP BY state,companyname
	ORDER BY state,count(claimid) DESC)A
WHERE claim_rank=1; -- doubt






