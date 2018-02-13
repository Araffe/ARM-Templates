$rg = (new-azurermresourcegroup -name infraSecLab -Location westeurope).ResourceGroupName
$outputs = (new-azurermresourcegroupdeployment -Name infraSecLab -ResourceGroupName $rg -TemplateUri https://raw.githubusercontent.com/Araffe/ARM-Templates/master/infra-security-lab/azuredeploy.json).Outputs

$DestStorageAccount = $outputs.storageAccountName.Value
$SourceStorageAccount = "infraseclab"
$destStorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rg -accountName $DestStorageAccount).value[0]
$sasToken = "?sv=2017-04-17&ss=b&srt=sco&sp=rwdlac&se=2018-03-31T15:53:57Z&st=2018-02-13T08:53:57Z&spr=https&sig=OmRforZXFQOZQ7SEmmMLKq5ChJnXihPG8SJCS%2B3%2B76s%3D"
$SourceStorageContext = New-AzureStorageContext –StorageAccountName $SourceStorageAccount -SasToken $sasToken
$DestStorageContext = New-AzureStorageContext –StorageAccountName $DestStorageAccount -StorageAccountKey $DestStorageKey
$SourceStorageContainer = 'infraseclab'
$DestStorageContainer = (new-azurestoragecontainer -Name contoso -context $DestStorageContext).name

$Blobs = (Get-AzureStorageBlob -Context $SourceStorageContext -Container $SourceStorageContainer)
foreach ($Blob in $Blobs)
{
   Write-Output "Moving $Blob.Name"
   Start-CopyAzureStorageBlob -Context $SourceStorageContext -SrcContainer $SourceStorageContainer -SrcBlob $Blob.Name `
      -DestContext $DestStorageContext -DestContainer $DestStorageContainer -DestBlob $Blob.Name
}