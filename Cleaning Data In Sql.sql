----Cleaning Data in SQL
Select*
From
portfolio_project..NashvilleHousing

-------------------------------------

--Changing datetime to date

Select 
CONVERT(date, SaleDate) as 
From
portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SalesDate date

Update NashvilleHousing
Set Salesdate = CONVERT(date, SaleDate)

--Putting Address in null places

Select
a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From
portfolio_project..NashvilleHousing a
Join portfolio_project..NashvilleHousing b
On
 a. ParcelID = b.ParcelID
 and
 a.[UniqueID] <> b.[UniqueID] 
 Where
 a.PropertyAddress is null


 Update a
 Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 From
portfolio_project..NashvilleHousing a
Join portfolio_project..NashvilleHousing b
On
 a. ParcelID = b.ParcelID
 and
 a.[UniqueID] <> b.[UniqueID] 
 Where
 a.PropertyAddress is null

-------------------------------------


---Separating address to address, city, state

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))
SUBSTRING(OwnerAddress, Len(OwnerAddress)-2, Len(OwnerAddress))
From
portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD AddressSplit Nvarchar(255)

Update NashvilleHousing
Set AddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add City Nvarchar(255)

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

--For OwnerAddress
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From
portfolio_project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddessSplit Nvarchar(255)

Update NashvilleHousing
Set OwnerAddessSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255)

Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255)

Update NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-----------------------------------------------------------------

--Change Y and N to Yes And No

Select Distinct SoldAsVacant,
Count(SoldAsVacant)
From
portfolio_project..NashvilleHousing
Group by
SoldAsVacant

-- Here we can see that values in column is not consistent. We need to change that

Select SoldAsVacant,
 Case When SoldAsVacant ='N' then 'No'
      When SoldAsVacant='Y' then 'Yes'
	  Else
	  SoldAsVacant
	  End
From 
portfolio_project..NashvilleHousing
---Now we will update  the table

Update NashvilleHousing
Set SoldAsVacant =
	Case When SoldAsVacant ='N' then 'No'
      When SoldAsVacant='Y' then 'Yes'
	  Else
	  SoldAsVacant
	  End
-----------------------------------------

--Remove Duplicates

Select*,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
				 UniqueID
				 ) as row_num
From
portfolio_project..NashvilleHousing

--This gives us which ids are same, now we will create a  CTE and delete duplicate rows

With rownumcte as
(
	Select*,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
				 UniqueID
				 ) as row_num
From
portfolio_project..NashvilleHousing
)

Delete 
From rownumcte
Where
row_num > 1
--Thus, duplicate rows are deleted now.

------------------------------------------------------------------

--Delete Unused Columns
Select *
From
portfolio_project..NashvilleHousing

--No, we will delete unused columns

ALTER TABLE portfolio_project..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolio_project..NashvilleHousing
Drop column SaleDate

---This data is much useful now.