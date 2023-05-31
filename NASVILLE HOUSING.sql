

Select *
From PortfolioProject.dbo.NashvileHousing


--Standardize the Date format

Select Sale_Date_Converted, CONVERT(date,saledate)
From PortfolioProject.dbo.NashvileHousing

Update NashvileHousing
Set SaleDate = CONVERT(date,saledate)

ALTER TABLE NashvileHousing
Add Sale_Date_Converted Date;

Update NashvileHousing
SET Sale_Date_Converted = CONVERT(date,saledate)

--Populate the Proprrty address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID]
where a.PropertyAddress is null


--Breaking out Address into Individual columns (Address, City, State)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)  +1 , LEN(PropertyAddress)) as address

From PortfolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
Add Propertysplitaddress nvarchar(255);

Update NashvileHousing
SET Propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvileHousing
Add PropertysplitCity nvarchar(255);

Update NashvileHousing
SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)  +1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject.dbo.NashvileHousing

Select 
PARSENAME(REPLACE(Owneraddress, ',', '.') , 3)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

From PortfolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
Add OwnersNewAddress nvarchar(255);

Update NashvileHousing
SET OwnersNewAddress = PARSENAME(REPLACE(Owneraddress, ',', '.') , 3)

ALTER TABLE NashvileHousing
Add OwnersNewCity nvarchar(255);

Update NashvileHousing
SET OwnersNewCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

ALTER TABLE NashvileHousing
Add OwnersNewState nvarchar(255);

Update NashvileHousing
SET OwnersNewState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)


-- Chnage Y and N to Yes and No in the Sold and Vacant field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvileHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvileHousing



--DELETE DUPLICATE COLUMNS 
WITH RomNumCTE AS(
Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID, propertyaddress, saleprice, legalreference
ORDER BY UniqueId) row_num

From PortfolioProject.dbo.NashvileHousing
--order by ParcelID
  )
  Select * 
  From RomNumCTE
  where row_num > 1
 Order by Propertyaddress


 --Delete Unused Columns 

 Select *
From PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN propertyaddress, owneraddress, taxdistrict

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN saledate