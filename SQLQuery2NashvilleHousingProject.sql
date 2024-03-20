---Data cleaning in SQL

--*/

Select* From PorfolioProject.dbo.NashvilleHousing

---Standardize Date,Format


Select SaleDate, CONVERT(Date,SaleDate)
From PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
--Select SaleDate, CONVERT(Date,SaleDate)
From PorfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]

   ----------------------------------------------------------

  --- Breaking out Address into Individual Column (Address,City,States)


   Select PropertyAddress
  From PorfolioProject.dbo.NashvilleHousing

   Select
   SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
  , SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
   From PorfolioProject.dbo.NashvilleHousing

   ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select* From PorfolioProject.dbo.NashvilleHousing



Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PorfolioProject.dbo.NashvilleHousing



 ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select* From PorfolioProject.dbo.NashvilleHousing

Select Distinct(SoldAsVacant),count(SoldAsVacant)
From PorfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
From PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End

---Removed Duplicates

With RowNumCTE As(
Select*,
ROW_NUMBER() over(Partition by ParcelId,
SaleDate,PropertyAddress,salePrice,Legalreference
order by UniqueId) row_num
From PorfolioProject.dbo.NashvilleHousing
--order by ParcelId
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---Removes Unused Columns

Alter Table PorfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Select* From PorfolioProject.dbo.NashvilleHousing

Alter Table PorfolioProject.dbo.NashvilleHousing
Drop Column SaleDate