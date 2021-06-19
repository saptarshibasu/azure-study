# Get the VM object
$vm = Get-AzVM -Name ${Env:vmName} -ResourceGroupName ${Env:resourceGroupName}

# Enable system-assigned identity on an existing VM
Update-AzVM -ResourceGroupName ${Env:resourceGroupName} -VM $vm -IdentityType SystemAssigned

# Get the public settings template from GitHub and update the templated values for the storage account and resource ID
$publicSettings = (Invoke-WebRequest -Uri https://raw.githubusercontent.com/saptarshibasu/azure-study/master/arm-templates/simple-linux-vm/lad_pub_settings.json).Content
$publicSettings = $publicSettings.Replace('__DIAGNOSTIC_STORAGE_ACCOUNT__', ${Env:storageAccountName})
$publicSettings = $publicSettings.Replace('__VM_RESOURCE_ID__', $vm.Id)

# If you have your own customized public settings, you can inline those rather than using the preceding template: $publicSettings = '{"ladCfg":  { ... },}'

# Generate a SAS token for the agent to use to authenticate with the storage account
$sasToken = New-AzStorageAccountSASToken -Service Blob,Table -ResourceType Service,Container,Object -Permission "racwdlup" -Context (Get-AzStorageAccount -ResourceGroupName ${Env:resourceGroupName} -AccountName ${Env:storageAccountName}).Context -ExpiryTime $([System.DateTime]::Now.AddYears(10))

# Build the protected settings (storage account SAS token)
$protectedSettings="{'storageAccountName': '${Env:storageAccountName}', 'storageAccountSasToken': '$sasToken'}"

# Finally, install the extension with the settings you built
Set-AzVMExtension -ResourceGroupName ${Env:resourceGroupName} -VMName ${Env:vmName} -Location $vm.Location -ExtensionType LinuxDiagnostic -Publisher Microsoft.Azure.Diagnostics -Name LinuxDiagnostic -SettingString $publicSettings -ProtectedSettingString $protectedSettings -TypeHandlerVersion 4.0
