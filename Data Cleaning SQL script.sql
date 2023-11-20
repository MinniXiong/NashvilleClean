/*

Cleaning Data in SQL Queries

*/

----------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Null data
SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
-- WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] AS T1
-- WHERE PropertyAddress IS NULL
JOIN [PortfolioProject].[dbo].[NashvilleHousing] AS T2 ON
T1.ParcelID = T2.ParcelID
AND T1.UniqueID <> T2.UniqueID
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress=ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] AS T1
JOIN [PortfolioProject].[dbo].[NashvilleHousing] AS T2 ON
T1.ParcelID = T2.ParcelID
AND T1.UniqueID <> T2.UniqueID
WHERE T1.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------
-- Split Property Address into address and city
SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
FROM [PortfolioProject].[dbo].[NashvilleHousing]

-- Adding the 2 columns to the original table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255), PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

----------------------------------------------------------------------------------------------------------------------
-- Split Owner address into address, city and state
SELECT OwnerAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),OwnerSplitCity Nvarchar(255),OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2), 
OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------------------------------------------
-- Remove Dulicates
-- Create CTE with entries with the same ParcelID, Property Address, Sale Price, Sale Date and Legal Reference
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
ORDER BY UniqueID) AS row_number
FROM [PortfolioProject].[dbo].[NashvilleHousing])
-- Delete entries where row_number is greater than 1
DELETE
FROM RowNumCTE
WHERE row_number>1


----------------------------------------------------------------------------------------------------------------------
-- Remove PropertyAddress and OwnerAddress that we no longer need
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress