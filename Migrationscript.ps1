# Danny Davis
# Date 2018-11-14
# Migrate stuff

# Load Module
Import-Module Sharegate

# User & Password
$password = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$userName = "USERNAME"

# Reading file
# Information needed:
# - URL to Source + Destination Site Collection
# - Listname of Source + Destination
# - Foldername of Source + Destination 
# file design:
# type;sourceurl;destinationurl;sourceList;destinationList;sourcefolder;destinationfolder
# Example:
# LIST;https://source/sites/bla;https://destination/sites/bla;SRCList;DestList;;
# FOLDER;https://source/sites/bla;https://destination/sites/bla;SRCList;DestList;SrcFolder;DestFolder;
# UNC;\\folder\folder1\FilesToImport;http://destination/sites/destinationsite;;DestinationListName;;;TestSiteCollectionTitle
$migrationList = Import-Csv MigrationList.csv -Header type, sourceurl, destinationurl, sourceList, destinationList, sourceFolder, destinationFolder, title -Delimiter ";"

# Check every entry of file
foreach($mL in $migrationList)
{
    # Write content to vars
    $type = $mL.type
    $sourceURL = $mL.sourceurl
    $destinationURL = $mL.destinationURL
    $sourceList = $mL.sourceList
    $destinationList = $mL.destinationList
    $sourceFolder = $mL.sourceFolder
    $destinationFolder = $mL.destinationFolder
    $title = $mL.title

    # if type = List -> copy the list
    if($type.ToLower() -eq "list")
    {
        $fileName =  "c:\temp\Migration\MigrationInformation_$title.xslx"
        Write-Host "Type: " $type " | SourceList: " $sourceURL
        $srcSite = Connect-Site -Url $sourceURL -Username $userName -Password $password
        $destSite = Connect-Site -Url $destinationURL -Username $userName -Password $password
        $srcList = Get-List -Name $sourceList -Site $srcSite
        $destList = Get-List -Name $destinationList -Site $destSite
        Copy-Content -SourceList $srcList -DestinationList $destList -ExcelFilePath $fileName
    }

    # if type = Folder -> copy only folder
    if($type.ToLower() -eq "folder")
    {
        $fileName =  "c:\temp\Migration\MigrationInformation_$title.xslx"
        Write-Host "Type: " $type " | SourceList: " $sourceURL
        $srcSite = Connect-Site -Url $sourceURL -Username $userName -Password $password
        $destSite = Connect-Site -Url $destinationURL -Username $userName -Password $password
        $srcList = Get-List -Name $sourceList -Site $srcSite
        $destList = Get-List -Name $destinationList -Site $destSite
        Copy-Content -SourceList $srcList -DestinationList $destList -SourceFolder $sourceFolder -DestinationFolder $destinationFolder -ExcelFilePath $fileName
    }

    if($type.ToLower() -eq "unc")
    {
        Write-Host "Type: " $type " | SourceList: " $sourceURL
        $destSite = Connect-Site -Url $destinationURL -Username $userName -Password $password
        $destList = Get-List -Name $destinationList -Site $destSite
        Import-Document -SourceFolder $sourceURL -DestinationList $destList -ExcelFilePath $fileName
    }
}