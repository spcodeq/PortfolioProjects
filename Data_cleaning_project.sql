/***************************

Cleaning Data in SQL Queries

***************************/

Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------
-- Standardize Date Format --

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data --

SELECT NasHouA.ParcelID, NasHouA.PropertyAddress, NasHouB.ParcelID, NasHouB.PropertyAddress, ISNULL(NasHouA.PropertyAddress, NasHouB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS NasHouA
JOIN PortfolioProject.dbo.NashvilleHousing AS NasHouB
	ON NasHouA.ParcelID = NasHouB.ParcelID
	AND NasHouA.[UniqueID ] <> NasHouB.[UniqueID ]
WHERE NasHouA.PropertyAddress IS NULL


UPDATE NasHouA SET PropertyAddress = ISNULL(NasHouA.PropertyAddress, NasHouB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS NasHouA
JOIN PortfolioProject.dbo.NashvilleHousing AS NasHouB
	ON NasHouA.ParcelID = NasHouB.ParcelID
	AND NasHouA.[UniqueID ] <> NasHouB.[UniqueID ]
WHERE NasHouA.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------
-- Breaking out address into individial columns (address, city, state) --

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)



UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)



UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL

------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field --

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------------
-- Remove Duplicates --

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns --

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate