--Cleaning data in SQL Queries
SELECT *
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

SELECT SaleDate, CAST(SaleDate AS Date)
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET SaleDate = CAST(SaleDate AS Date)

--- Populate Property Address Data
SELECT *
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Joining the nashville data by itself to distinguish the ParcelIDs and the property address
-- Using ISNULL to populate b.propertyAddress for NULL a.propertyAddress) and updating the table.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning] as A
JOIN portfolio.dbo.[Nashville Housing Data for Data Cleaning] AS B
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID] --This is to distinguish the ParcelIDs as there are ParcelIDs that are the same
--Where a.PropertyAddress IS NULL

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning] as A
JOIN portfolio.dbo.[Nashville Housing Data for Data Cleaning] AS B
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID] --This is to distinguish the ParcelIDs as there are ParcelIDs that are the same
Where a.PropertyAddress IS NULL

--Breaking Out Address into Individual Columns(Address, City, State) Using SUBSTRING and CHARINDEX.

SELECT PropertyAddress
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning] 

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(propertyAddress)) AS Address
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(propertyAddress))

SELECT *
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

--Owner Address string manipulation but Using PARSENAME this time.
SELECT OwnerAddress
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

--PARSENAME only works with periods so we replace the commas with periods.
SELECT PARSENAME(Replace(OwnerAddress, ',', '.'), 3) --Address.
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2), -- City
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) --State
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]
--PARSENAME does the string manipulation backwards and it is more straightforward than the SUBSTRING.

ALTER TABLE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE portfolio.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState NVARCHAR(255);

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET OWnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET OWnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET OWnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold As Vacant" field using a case statement.
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM portfolio.dbo.[Nashville Housing Data for Data Cleaning]

Update portfolio.dbo.[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

