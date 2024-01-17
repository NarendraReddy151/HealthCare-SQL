USE healthcare;

/*ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
3 - Reference, 
4 - Similar, 
5 - New, 
6 - Specific,
7 - Biological, 
8 – Dinamized
*/
SELECT * FROM(
SELECT *,
CASE 
	WHEN producttype=1 AND taxcriteria='I' THEN 'Generic'
    WHEN producttype=2 AND taxcriteria='I' THEN 'Patent'
    WHEN producttype=3 AND taxcriteria='I'THEN 'Reference'
    WHEN producttype=4 AND taxcriteria='II'THEN 'Similar'
    WHEN producttype=5 AND taxcriteria='II'THEN 'New'
    WHEN producttype=6 AND taxcriteria='II'THEN 'Specific'
    WHEN producttype=7 THEN 'Biological'
    WHEN producttype=8 THEN 'Dinamized'
END AS product_category
FROM medicine) A
WHERE product_category IS NOT NULL; -- join pharmacy
-- ---------------------------------------------------------------------------------------------------------------------

/*Problem Statement 2:  
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription and if the total quantity of
 medicine is less than 20 tag it as “low quantity”. If the quantity of medicine is from 20 to 49 (both numbers including) 
 tag it as “medium quantity“ and if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, and the Quantity tag for 
all the prescriptions issued by 'Ally Scripts'.
3 rows from the resultant table may be as follows:
prescriptionID	totalQuantity	Tag
1147561399		43			Medium Quantity
1222719376		71			High Quantity
1408276190		48			Medium Quantity
*/

SELECT prescriptionid,SUM(quantity) AS medicines_quantity,
CASE 
	WHEN SUM(quantity)<20 THEN 'Low Quantity'
    WHEN SUM(quantity) BETWEEN 20 AND 49 THEN 'Medium Quantity'
    WHEN SUM(quantity)>=50 THEN 'High Quantity'
END AS Tag
FROM prescription
JOIN contain USING(prescriptionid)
JOIN pharmacy USING(pharmacyid)
WHERE pharmacyname='Ally Scripts'
GROUP BY prescriptionid;


-- -------------------------------------------------------------------------------------------------------------

/*Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’
when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. The discount is considered “HIGH” 
if the discount rate on a product is 30% or higher, and the discount is considered “NONE” when the discount rate on a 
product is 0%.'Spot Rx' needs to find all the Low quantity products with high discounts and all the high-quantity products
with no discount so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.

Hint: Inventory is reflected in the Keep table.*/

SELECT medicineID,quantity,discount,quantity_category,discount_category FROM(SELECT *,
CASE 
	WHEN quantity>7500 THEN 'HIGH QUANTITY'
	WHEN quantity<1000 THEN 'LOW QUANTITY'
END AS quantity_category,
CASE 
	WHEN discount>=30 THEN 'HIGH'
    WHEN discount=0 THEN 'None'
END AS discount_category
FROM pharmacy
JOIN keep USING(pharmacyid)
WHERE pharmacyname='Spot Rx')A
WHERE (quantity_category IS NOT NULL AND discount_category IS NOT NULL)
AND ((quantity_category='HIGH QUANTITY' AND discount_category='None') OR (quantity_category='LOW QUANTITY' AND discount_category='HIGH'))
ORDER BY quantity;

-- -------------------------------------------------------------------------------------------------------
/*Problem Statement 4: 
Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, hospital-exclusive medicines
 in the database. Where affordable medicines are the medicines that have a maximum price of less than 50% of the 
 avg maximum price of all the medicines in the database, and costly medicines are the medicines that have a 
 maximum price of more than double the avg maximum price of all the medicines in the database.  Mack wants clear 
 text next to each medicine name to be displayed that identifies the medicine as affordable or costly. The medicines 
 that do not fall under either of the two categories need not be displayed.
Write a SQL query for Mack for this requirement.*/
-- SELECT medicineid,maxprice, avg_price, 
-- CASE 
-- 	WHEN maxprice<avg_price/2 THEN 'affordable'
--     WHEN maxprice>avg_price*2 THEN 'costly'
-- END AS price_category
-- FROM(SELECT *,
-- AVG(maxprice) OVER()  AS avg_price FROM medicine) AS A ;

SELECT medicineid AS medicine_id,maxprice AS max_price,price_category FROM(
	SELECT medicineid,hospitalexclusive,maxprice,
	CASE 
		WHEN maxprice<(AVG(maxprice) OVER())*0.5 THEN 'affordable'
		WHEN maxprice>(AVG(maxprice) OVER())*2 THEN 'costly'
	END AS price_category
	from medicine)A
WHERE hospitalexclusive='S' AND price_category IS NOT NULL;

-- ----------------------------------------------------------------------------------------------------
/*Problem Statement 5:  
The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.

Write a SQL query to list all the patient name, gender, dob, and their category.*/

SELECT personname AS person_name,gender,dob,
CASE 
	WHEN gender='male' AND dob>'2005-01-01'THEN 'YoungMale'	
    WHEN gender='female' AND dob>'2005-01-01'THEN 'YoungFemale'
    WHEN gender='male' AND dob<'2005-01-01' AND dob>'1985-01-01'THEN 'AdultMale'
    WHEN gender='female' AND dob<'2005-01-01' AND dob>'1985-01-01'THEN 'AdultFemale'
    WHEN gender='male' AND dob<'1985-01-01' AND dob>'1970-01-01'THEN 'MidAgeMale'
    WHEN gender='female' AND dob<'1985-01-01' AND dob>'1970-01-01'THEN 'MidAgeFemale'
    WHEN gender='male' AND dob<'1970-01-01' THEN 'ElderMale'
    WHEN gender='female' AND dob<'1970-01-01' THEN 'ElderFemale'
END AS category
FROM patient
JOIN person ON patient.patientID=person.personid;




