-- Cleaning Data in SQL Queries

SELECT * FROM nashvillehousing;

TRUNCATE TABLE nashvillehousing;
-- Converting saledate column from TEXT data type to DATE data type
ALTER TABLE nashvillehousing
ALTER COLUMN saledate TYPE DATE
USING saledate:: DATE;

-- Populating Property Address Data that is NULL
/*Checking which property addresses have no data and 
updating property addresses with the same parcelid */
SELECT nh1.parcelid, nh1.propertyaddress, 
nh2.parcelid, 
nh2.propertyaddress, 
COALESCE(nh1.propertyaddress,nh2.propertyaddress) AS propertyaddress
FROM nashvillehousing nh1
JOIN nashvillehousing nh2
ON nh1.parcelid = nh2.parcelid
AND nh1.uniqueid <> nh2.uniqueid
WHERE nh1.propertyaddress IS NULL;

/*Updating Nulls 
Using correlated subquery to find the first value of the column
with the same parcelid. Uniqueid condition is optional*/
UPDATE nashvillehousing nh1
SET propertyaddress = (SELECT nh2.propertyaddress
						FROM nashvillehousing nh2
						--JOIN nashvillehousing nh2
						WHERE nh1.parcelid = nh2.parcelid
						AND nh1.uniqueid <> nh2.uniqueid
						AND nh2.propertyaddress IS NOT NULL
						LIMIT 1)
WHERE nh1.propertyaddress IS NULL;

-- Breaking out Addresses into Individual Columns(Address, City, State)

ALTER TABLE nashvillehousing
DROP COLUMN propertysplitaddress;

ALTER TABLE nashvillehousing
ADD address VARCHAR(255),
ADD city VARCHAR(255);

UPDATE nashvillehousing
SET address = SUBSTRING(propertyaddress FROM 1 for POSITION(','IN propertyaddress)-1);
UPDATE nashvillehousing
SET city = SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress)+1);

ALTER TABLE nashvillehousing
ADD ownersplitaddress VARCHAR(255),
ADD ownersplitcity VARCHAR(255),
ADD ownersplitstate VARCHAR(255);

UPDATE nashvillehousing
SET ownersplitaddress = split_part(owneraddress,',',1);
UPDATE nashvillehousing
SET ownersplitcity = split_part(owneraddress,',',2);
UPDATE nashvillehousing
SET ownersplitstate = split_part(owneraddress,',',3);

-- Change Y and N to Yes and NO in "Sold as Vacant" field

UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'YES' THEN 'Yes'
					WHEN soldasvacant = 'N' THEN 'No'
					ELSE soldasvacant
					END;

--Remove Duplicates that have the same values for the below columns.
--First create a VIEW as to not delete from RAW Data
CREATE VIEW nashvillehousing_view
AS(
SELECT *
FROM nashvillehousing);

--Remove the duplicate from the VIEW

WITH rownumcte
AS(SELECT uniqueid
	FROM(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY parcelid,propertyaddress,saleprice,saledate,legalreference
						ORDER BY uniqueid) AS row_num
		FROM nashvillehousing_view)
	WHERE row_num > 1)
DELETE FROM nashvillehousing_view
WHERE uniqueid IN(SELECT uniqueid FROM rownumcte);

--Deleting Unused Columns
DROP VIEW nashvillehousing_view;

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress,
DROP COLUMN saledate;

