if([string]::IsNullOrEmpty($args[0])){
$FID_VERSION= Read-Host "Enter FID version (Ex: 7.2.21)"
$RLI_HOME= Read-Host "Ener RLI_HOME path (Ex: c:\radiantone\vds)"
$CLUSTER_NAME= Read-Host "Enter cluster name"
$PASSWORD= Read-Host "Enter password"
$REPASSWORD= Read-Host "Re-enter password"
while($PASSWORD -ne $REPASSWORD){
Write-Warning "Passwords did not match!"
$PASSWORD= Read-Host "Enter password"
$REPASSWORD= Read-Host "Re-enter password"
}
$LICENSE= Read-Host "Enter license"
}else{
$FID_VERSION=$args[0]
$RLI_HOME=$args[1]
$CLUSTER_NAME=$args[2]
$PASSWORD=$args[3] # Provide in double quotes
$LICENSE=$args[4] # Provide in double quotes
}
$RLI_HOME_PROP = $RLI_HOME.Replace("\","\\")
$PROPERTIES_FILE = "${HOME}\Downloads\install.properties"

# Change the $download_location to force install & $installer_save_location as well with same file name from the web link 
# You can enter fid version as a dummy value if you force the $download_location

$download_location="http://10.11.12.113/share/artifacts/stable_releases/${FID_VERSION}/installers/ces/radiantone_${FID_VERSION}_windows_64.exe"
$installer_save_location="${HOME}\Downloads\radiantone_${FID_VERSION}_windows_64.exe"
echo "Downloading from ${download_location} ..."
echo "Saving to ${installer_save_location}  ..."
if (Test-Path $installer_save_location) {
Write-Warning "${installer_save_location} exists, Removing ..."
Remove-Item $installer_save_location
}
$wc = New-Object net.webclient
$wc.Downloadfile($download_location, $installer_save_location)
echo "Download Completed!"
echo "Creating install.properties ${PROPERTIES_FILE}"
if (Test-Path $PROPERTIES_FILE) {
Remove-Item $PROPERTIES_FILE
}
New-Item $PROPERTIES_FILE
Set-Content $PROPERTIES_FILE "USER_INSTALL_DIR=${RLI_HOME_PROP}"
Add-Content $PROPERTIES_FILE "CHOSEN_FEATURE_LIST=Application,sample"
Add-Content $PROPERTIES_FILE "CHOSEN_INSTALL_FEATURE_LIST=Application,sample"
Add-Content $PROPERTIES_FILE "CHOSEN_INSTALL_SET=standalone"
Add-Content $PROPERTIES_FILE "INST_ZK_NEW=1"
Add-Content $PROPERTIES_FILE "INST_ZK_ENSEMBLE_PORT=2888"
Add-Content $PROPERTIES_FILE "INST_ZK_LEADER_PORT=3888"
Add-Content $PROPERTIES_FILE "INST_ZK_CLIENT_PORT=2181"
Add-Content $PROPERTIES_FILE "INST_ZK_JMX_PORT=2182"
Add-Content $PROPERTIES_FILE "INST_ZK_EXISTING=0"
Add-Content $PROPERTIES_FILE "INST_ZK_CONN="
Add-Content $PROPERTIES_FILE "INST_ZK_CLUSTER=${CLUSTER_NAME}"
Add-Content $PROPERTIES_FILE "INST_ZK_LOGIN=admin"
Add-Content $PROPERTIES_FILE "INST_ZK_PASSWORD=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "INST_ZK_PASSWORD_CONFIRM=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "root_user=cn=Directory Manager"
Add-Content $PROPERTIES_FILE "root_password_1=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "root_password_2=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "server_port_1=2389"
Add-Content $PROPERTIES_FILE "server_port_3=636"
Add-Content $PROPERTIES_FILE "server_tls_enable=0"
Add-Content $PROPERTIES_FILE "server_port_2=1099"
Add-Content $PROPERTIES_FILE "vds_http_port=8089"
Add-Content $PROPERTIES_FILE "vds_https_port=8090"
Add-Content $PROPERTIES_FILE "vds_admin_http_port=9100"
Add-Content $PROPERTIES_FILE "vds_admin_https_port=9101"
Add-Content $PROPERTIES_FILE "INST_ASADMIN_PASSWORD=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "INST_ASADMIN_PASSWORD_CONF=82131E7DCD2DBE783D281E7DCD2DBE783D2"
Add-Content $PROPERTIES_FILE "INST_ASADMIN_PORT=4848"
Add-Content $PROPERTIES_FILE "INST_JMX_PORT=8686"
Add-Content $PROPERTIES_FILE "jetty.http=7070"
Add-Content $PROPERTIES_FILE "jetty.https=7171"
echo "Created install.properties ${PROPERTIES_FILE}"
echo "Installing VDS Silently ..."
$install_silent_command="${installer_save_location} -i silent -f ${PROPERTIES_FILE}"
echo "Invoking command ${install_silent_command}"
Set-Item -Path Env:RLI_IA_root_password -Value $PASSWORD
Set-Item -Path Env:RLI_IA_INST_ZK_PASSWORD -Value $PASSWORD
Set-Item -Path Env:RLI_IA_INST_ASADMIN_PASSWORD -Value $PASSWORD
Invoke-Expression -Command $install_silent_command
$install_log=$RLI_HOME+"\logs\install\build-finish.log"
while (!(Test-Path $install_log)) {
echo "Waiting for build to finish, Sleep 10 seconds"
Start-Sleep 10
}
$license_file=$RLI_HOME+'\vds_server\license.lic'
if (Test-Path $license_file) {
Write-Warning "Removing exisiting ${license_file}"
Remove-Item $license_file
}
echo "Setting up the license file at ${license_file} ..."
New-Item $license_file
Set-Content $license_file $LICENSE
echo "${license_file} created successfully!"
echo "Installation completed, Now restart ..."
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Restart-Computer