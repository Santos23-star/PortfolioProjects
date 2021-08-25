/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject..Nashvillehousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date,Saledate)
FROM PortfolioProject..Nashvillehousing

Update Nashvillehousing
SET Saledate = CONVERT(date,Saledate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT PropertyAddress
FROM PortfolioProject..Nashvillehousing
Order By ParcelID


--Where PropertyAddress is null



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing as a
Join PortfolioProject..Nashvillehousing as b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing as a
Join PortfolioProject..Nashvillehousing as b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..Nashvillehousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX( ',',PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX( ',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..Nashvillehousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX( ',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX( ',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..Nashvillehousing



SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..Nashvillehousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashvillehousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update Nashvillehousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(Soldasvacant),COUNT(Soldasvacant)
FROM PortfolioProject..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2





SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..Nashvillehousing



UPDATE Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

	

	
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER () OVER (
		Partition BY ParcelId,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER By
						UniqueID
						) Row_num
FROM PortfolioProject..Nashvillehousing
)
  SELECT *
  FROM RowNumCTE
  WHERE Row_num > 1
  ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject..Nashvillehousing


ALTER TABLE PortfolioProject..Nashvillehousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..Nashvillehousing
DROP Column SaleDate