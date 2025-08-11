CREATE TABLE nashvillehousing(
uniqueid SERIAL PRIMARY KEY,
parcelid TEXT,
landuse TEXT,
propertyaddress TEXT,
saledate TEXT,
saleprice TEXT,
legalreference TEXT,
soldasvacant TEXT,
ownername TEXT,
owneraddress TEXT,
acreage DECIMAL(6,2),
taxdistrict TEXT,
landvalue INT,
buildingvalue INT,
totalvalue INT,
yearbuilt INT,
bedrooms INT,
fullbath INT,
halfbath INT
);

DROP TABLE nashvillehousing;

SELECT * FROM nashvillehousing;