use healthcare;
/*Problem Statement 1: 
Insurance companies want to know if a disease is claimed higher or lower than average. Write a stored procedure that returns 
“claimed higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed disease is 
higher than the average return “claimed higher than average” otherwise “claimed lower than average”.*/

DELIMITER //

CREATE PROCEDURE insurance_claim_status(id VARCHAR(50))
BEGIN
SELECT *,IF(no_of_claims>avg_claims,"claimed higher than average","claimed lower than average") AS claimed_status FROM
	(
    SELECT *,AVG(no_of_claims) OVER() AS avg_claims FROM 
		(
        SELECT diseasename,diseaseid,COUNT(claimid)AS no_of_claims
		FROM disease
		JOIN treatment USING(diseaseid)
		JOIN claim USING(claimid)
		GROUP BY diseaseid,diseasename
		)A
    )B
WHERE diseaseid=id;
END //
DELIMITER ;

CALL insurance_claim_status(40);

-- -----------------------------------------------------------------------------------------------------------
/*Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease,
 if the number is same for both the genders, the value should be ‘same’.*/
DELIMITER //
CREATE PROCEDURE get_genderwise_treatment_details(id INT)
BEGIN
SELECT disease_name,
number_of_male_treated,
number_of_female_treated,
IF(number_of_female_treated>number_of_male_treated,"female",IF(number_of_female_treated<number_of_male_treated,"male","same")) AS more_treated_gender 
FROM 
	 (SELECT diseaseid,diseasename AS disease_name,COUNT(treatmentid) AS number_of_female_treated,
	 LEAD(COUNT(treatmentid)) OVER(PARTITION BY diseaseid ORDER BY diseaseid,gender) AS number_of_male_treated
	 FROM disease
	 JOIN treatment USING(diseaseid)
	 JOIN person ON treatment.patientid=person.personid
	 GROUP BY gender,diseaseid
	 ORDER BY diseaseid
     )A
WHERE number_of_male_treated IS NOT NULL AND diseaseid=id;
END //
DELIMITER ;

CALL get_genderwise_treatment_details(20);

-- -------------------------------------------------------------------------------------------------------------------------
 
/*Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan,
 and whether the plan is the most claimed or least claimed. */
 SELECT companyname AS company_name,planname AS plan_name,cnt,IF(min_rank<max_rank,"least claimed","most claimed") AS claim_status 
 FROM
	  (
		SELECT companyname,planname,count(claimid) as cnt,
           DENSE_RANK() OVER( ORDER BY count(claimid)) AS min_rank,
	      DENSE_RANK() OVER(ORDER BY count(claimid) DESC) AS max_rank 
		  FROM insurancecompany
		  JOIN insuranceplan USING(companyid)
		  JOIN claim USING(UIN)
		  GROUP BY companyname,planname
		  ORDER BY companyname ASC,cnt DESC
          )A
WHERE max_rank<4 OR min_rank<4
ORDER by cnt DESC;

-- -------------------------------------------------------------------------------------------------------------------
 /*Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.*/

DELIMITER $$
CREATE FUNCTION category(dob DATE,gender varchar(6))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
DECLARE category VARCHAR(20);
IF gender='male' AND dob>'2005-01-01'THEN SET category='YoungMale';
ELSEIF (gender='female' AND dob>'2005-01-01') THEN SET category='YoungFemale';
ELSEIF (gender='male' AND dob<'2005-01-01' AND dob>'1985-01-01') THEN SET category='AdultMale';
ELSEIF (gender='female' AND dob<'2005-01-01' AND dob>'1985-01-01') THEN SET category='AdultFemale';
ELSEIF (gender='male' AND dob<'1985-01-01' AND dob>'1970-01-01')THEN SET category='MidAgeMale';
ELSEIF (gender='female' AND dob<'1985-01-01' AND dob>'1970-01-01')THEN SET category='MidAgeFemale';
ELSEIF (gender='male' AND dob<'1970-01-01') THEN SET category='ElderMale';
ELSEIF (gender='female' AND dob<'1970-01-01') THEN SET category='ElderFemale';
END IF;
RETURN (category);
END$$
DELIMITER ;

SELECT diseasename AS disease_name,category FROM (
	SELECT *,RANK() OVER(PARTITION BY diseaseid ORDER BY cnt DESC) AS category_rank FROM(
		SELECT diseaseid,diseasename,category,COUNT(patientid) cnt
		FROM(
			SELECT *,category(dob,gender) AS category FROM person
			JOIN patient ON patient.patientID=person.personid
			JOIN treatment USING(patientid)
			JOIN disease USING(diseaseid)
			)A
		GROUP BY diseaseid,category
		ORDER BY diseasename,COUNT(patientid) DESC
		)B
	)C
WHERE category_rank=1;
-- ---------------------------------------------------------------------------------------------------------------
/*Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName, 
description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. 
Write a query to find */
SELECT * FROM(
	SELECT companyname AS company_name,productname AS product_name,description,maxprice AS max_price,
	IF(maxprice<5,'affordable',IF(maxprice>1000,'pricey',NULL)) AS price_category
	FROM medicine)A
WHERE price_category IS NOT NULL
ORDER BY max_price DESC;



