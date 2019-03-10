#Usefull for test
function Show-Line {
    Param([string]$Text)
    $output = (Get-Date).ToLongTimeString() + " " + $text
    Write-Output $output
}

$siteUrl = "https://<....>.sharepoint.com/sites/projects/"
$list = "Projects"

Show-Line "Get Credential"
$cred = Get-AutomationPSCredential -Name 'SpsAdmin';

Show-Line "Connect to SharePoint"
Connect-PnPOnline -Url $siteUrl -credential $cred

Show-Line "Get list items"
$caml = "<View><Query><Where><IsNull><FieldRef Name='Status' /></IsNull></Where></Query></View>";
$listItems = (Get-PnPListItem -List $list -Query $caml)

foreach ($listItem in $listItems) {
    $title = $listItem["Title"]
    Show-Line "Create Subsite"
    $project = New-PnPWeb -Title $title -Url $title -Description "PnP Site" -Locale 1033 -Template "STS#0"
    Show-Line("Site '" + $title + "' is successfully created.")

    $siteUrl = $project.ServerRelativeUrl + ", Open web"
    $item = Set-PnPListItem -List $list -Identity $listItem["ID"] -Values @{"Status" = "Done"; "Site" = $siteUrl}
    Show-Line "Item successfully updated."
}

Show-Line "Disconnect to SharePoint"
Disconnect-PnPOnline