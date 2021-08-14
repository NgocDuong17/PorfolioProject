-- CLEANING DATA


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------


-- STANDARDIZE DATE FORMAT


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


------------------------------------------------------------


--POPULATE PROPERTY ADDRESS DATE


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

-----------------------------------------------

--BREAKING OUT ADDRESS	INTO INDIVIDUAL COLUMNS ( ADDRESS, CITY, STATE )


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------------------------
--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
	                    END 


------------------------------------------------------------------------
-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *, 
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				    UniqueID	
					) Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE 
WHERE Row_Num > 1
--ORDER BY PropertyAddress

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
