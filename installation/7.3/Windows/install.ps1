if([string]::IsNullOrEmpty($args[0])){
	$FID_VERSION= Read-Host "Enter FID version (>=7.3.X)"
	# $RLI_HOME= Read-Host "Ener RLI_HOME path"
	$RLI_HOME="c:\radiantone\vds"
	$CLUSTER_NAME= Read-Host "Enter cluster name"
	$PASSWORD= Read-Host "Enter password"
	$REPASSWORD= Read-Host "Re-enter password"
  while($PASSWORD -ne $REPASSWORD){
		Write-Warning "Passwords did not match!"
		$PASSWORD= Read-Host "Enter password"
		$REPASSWORD= Read-Host "Re-enter password"
	}
	$LICENSE= Read-Host "Enter license"
	$MIGRATION_IMPORT_FILE= Read-Host "Enter path to migration zip file (Press ENTER to skip import migration)"
	if(![string]::IsNullOrEmpty($MIGRATION_IMPORT_FILE)){
		$MIGRATION_UTILITY_VERSION = Read-Host "Enter migration utility version"
	}
}else{
	$FID_VERSION=$args[0]
	$RLI_HOME=$args[1]
	$CLUSTER_NAME=$args[2]
	$PASSWORD=$args[3] # Provide in double quotes
	$LICENSE=$args[4] # Provide in double quotes
}

# Change the $download_location to force install & $installer_save_location as well with same file name from the web link 
# You can enter fid version as a dummy value if you force the $download_location
$download_location="http://10.11.12.113/share/artifacts/stable_releases/${FID_VERSION}/installers/ces/radiantone_${FID_VERSION}_full_windows_64.zip"
$installer_save_location="${HOME}\Downloads\radiantone_${FID_VERSION}_full_windows_64.zip"

echo "Downloading from ${download_location} ..."
echo "Saving to ${installer_save_location}  ..."
if (Test-Path $installer_save_location) {
	Write-Warning "${installer_save_location} exists, Removing ..."
	Remove-Item $installer_save_location
}
$wc = New-Object net.webclient
$wc.Downloadfile($download_location, $installer_save_location)

for($i=0;$i -lt 5;$i++) 
	{ 
		if(Test-Path $installer_save_location){
			break
		}else{
			Write-Warning "Download file not found ${installer_save_location}, Sleeping for 5 seconds"
			Start-Sleep 5 
		}	
	}

if (Test-Path $installer_save_location) {
	echo "Download Completed!"
	
	echo "Unzipping the downloaded package to ${RLI_HOME}"
	$zip_destination = $RLI_HOME -replace "vds$",""
	if (Test-Path $zip_destination) {
		Write-Warning "${zip_destination} exists. Removing ..."
		Remove-Item $zip_destination -Recurse -Force
	}
	Expand-Archive -Path $installer_save_location -DestinationPath $zip_destination -Force -Verbose
	echo "Unzipping completed!"

	$license_file=$RLI_HOME+'\vds_server\license.lic'
	echo "Setting up the license file at ${license_file} ..."
	New-Item $license_file
	Set-Content $license_file $LICENSE
	echo "${license_file} created successfully!"
	
	echo "Setting up environmental variables!"
	[Environment]::SetEnvironmentVariable("RLI_HOME", $RLI_HOME, "Machine")
	$install_properties_file=$RLI_HOME+'\install\install-sample.properties'
	
	echo "Editing ${install_properties_file} ..."
	(Get-Content $install_properties_file).replace('StrongP@ssword1',$PASSWORD) | Set-Content $install_properties_file
	(Get-Content $install_properties_file).replace('cluster1',$CLUSTER_NAME) | Set-Content $install_properties_file
	
	echo "Installing FID versiom=${FID_VERSION} ..."
	$install_command=$RLI_HOME+'\bin\InstanceManager.exe --setup-install '+ $install_properties_file
	echo "Invoking the command ${install_command}"
	Invoke-Expression -Command $install_command
	echo "Installation completed, Starting control panel ..."
	if([string]::IsNullOrEmpty($MIGRATION_IMPORT_FILE)){
		$launch_control_panel=$RLI_HOME+'\bin\openControlPanel.bat'
		Invoke-Expression -Command $launch_control_panel
	}else{
	$migration_utility_download_location="http://10.11.12.113/share/artifacts/stable_releases/migration-tool-v2/${MIGRATION_UTILITY_VERSION}/radiantone-migration-tool-${MIGRATION_UTILITY_VERSION}.zip"
		$migration_utility_save_location="${HOME}\Downloads\radiantone-migration-tool-${MIGRATION_UTILITY_VERSION}.zip"

		echo "Downloading from ${migration_utility_download_location} ..."
		echo "Saving to ${migration_utility_save_location}  ..."
		if (Test-Path $migration_utility_save_location) {
			Write-Warning "${migration_utility_save_location} exists, Removing ..."
			Remove-Item $migration_utility_save_location
		}
		$wc = New-Object net.webclient
		$wc.Downloadfile($migration_utility_download_location, $migration_utility_save_location)

		if (Test-Path $migration_utility_save_location) {
			echo "Migration utility Download Completed!"

			echo "Unzipping the migration utility package to ${HOME}!"
			$migration_zip_destination = $HOME
			Expand-Archive -Path $migration_utility_save_location -DestinationPath $migration_zip_destination -Force -Verbose
			echo "Unzipping completed!"

			$POWERSHELL_MIGRATION_IMPORT=$HOME+"\radiantone-migration-tool-${MIGRATION_UTILITY_VERSION}\importAndStart.ps1"
			New-Item $POWERSHELL_MIGRATION_IMPORT
			
			$migration_command=".\migrate.bat import ${MIGRATION_IMPORT_FILE} cross-environment"

			$line1='Invoke-Expression -Command "'+$migration_command+'"'
			$line2='echo "Migration completed, Starting control panel ..."'
			$line3='Invoke-Expression -Command "'+$RLI_HOME+'\bin\openControlPanel.bat"'

			Set-Content $POWERSHELL_MIGRATION_IMPORT $line1
			Add-Content $POWERSHELL_MIGRATION_IMPORT $line2
			Add-Content $POWERSHELL_MIGRATION_IMPORT $line3

			echo "Computer will restart now, You will have to execute ${POWERSHELL_MIGRATION_IMPORT} file manually after the restart for migration to complete"
			Write-Host -NoNewLine 'Press any key to continue...';
			$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
			Restart-Computer

		}
	}
}else{
 Write-Error -Message "Installer package file not found ${installer_save_location}" -Category NotSpecified
}