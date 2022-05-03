/*

Cleaning Data

*/

Select *
From HousingData.dbo.NashvilleHousing;


--Standardize Date Format--

Select DateSold
From HousingData.dbo.NashvilleHousing;

ALTER TABLE HousingData.dbo.NashvilleHousing
Add DateSold Date;

Update HousingData.dbo.NashvilleHousing
Set DateSold = CONVERT(Date,SaleDate);



--Populate Property Address Data--

Select *
From HousingData.dbo.NashvilleHousing
Where PropertyAddress is null;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData.dbo.NashvilleHousing a
Join HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData.dbo.NashvilleHousing a
Join HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


--Separating Addresses into Individual Columns (Address, City, State)--

--Property Address (SUBSTRING)
Select PropertyAddress
From HousingData.dbo.NashvilleHousing;

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From HousingData.dbo.NashvilleHousing;


ALTER TABLE HousingData.dbo.NashvilleHousing
Add PropAddress Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
Set PropAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE HousingData.dbo.NashvilleHousing
Add PropCity Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
Set PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));


--Owner Address (PARSENAME)

Select OwnerAddress
From HousingData.dbo.NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From HousingData.dbo.NashvilleHousing;

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnAddress Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
Set OwnAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnCity Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
Set OwnCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnState Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
Set OwnState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);


--Standardize SoldAsVacant to 'Yes' and 'No'--

Select Distinct(SoldASVAcant)
From HousingData.dbo.NashvilleHousing;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From HousingData.dbo.NashvilleHousing;

Update HousingData.dbo.NashvilleHousing
SET SoldAsVacant =
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;


--Remove Duplicates--

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
From HousingData.dbo.NashvilleHousing
--Order by ParcelID;
)
DELETE
From RowNumCTE
Where row_num > 1;
--Order by PropertyAddress;


-- Delete Unused Columns--

Select *
From HousingData.dbo.NashvilleHousing;

ALTER TABLE HousingData.dbo.NashvilleHousing

DROP COLUMN PropertyAddress, OwnerAddress, SaleDate;