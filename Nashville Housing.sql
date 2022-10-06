/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--self join to replace null addresses
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
	SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD SplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress))



-- Owner Address Split

SELECT 
	OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
ADD 
	OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT 
	*
FROM PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


--------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UNIQUEID
			) row_num
	FROM PortfolioProject.dbo.NashvilleHousing
	--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN
	OwnerAddress,
	PropertyAddress,
	TaxDistrict;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate;
