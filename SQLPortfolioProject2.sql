--Standardize Date Format

alter table [dbo].[Nashville Housing Data for Data Cleaning]
add SaleDateNew Date;

update [dbo].[Nashville Housing Data for Data Cleaning]
set SaleDateNew = convert (Date, SaleDate)

select SaleDateNew
from [dbo].[Nashville Housing Data for Data Cleaning]

alter table [dbo].[Nashville Housing Data for Data Cleaning]
drop column saledate;

--Populate Property Address data

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from [dbo].[Nashville Housing Data for Data Cleaning] a
join [dbo].[Nashville Housing Data for Data Cleaning] b
 on a.parcelid = b.parcelid
 and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from [dbo].[Nashville Housing Data for Data Cleaning] a
join [dbo].[Nashville Housing Data for Data Cleaning] b
    on a.parcelid = b.parcelid
    and a.[uniqueid] <> b.[uniqueid]
 where a.propertyaddress is null


--Breaking out Address Into Individual Columns (Address, City, State)
--using SUBSTRING

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Breaking out Address Into Individual Columns (Address, City, State)
 --using PARSENAME

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [dbo].[Nashville Housing Data for Data Cleaning]


ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From [dbo].[Nashville Housing Data for Data Cleaning]


Update [dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateNew,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [dbo].[Nashville Housing Data for Data Cleaning]

)
DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Remove Unused Columns

alter table [dbo].[Nashville Housing Data for Data Cleaning]
drop column owneraddress, taxdistrict, propertyaddress