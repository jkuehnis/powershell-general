$share = "\\any\unc\path"
$PSProviderAlphabet = [char[]]([char]'C'..[char]'Z')
$UsedPSProvider = (get-psdrive).Name | Sort-Object
$FreePSProvider = $PSProviderAlphabet | ? {$UsedPSProvider -notcontains $_}

New-PSDrive -Name $FreePSProvider[0] -PSProvider "FileSystem" -Root $share
