#!/bin/bash
print_warn () {
 echo -e "\033[33m$1!\033[0m"
}

check_file_exist_delete () {
    if test -f $1; then
        print_warn "$1 exists. Removing ..."
        rm -rf $1
    fi
}
PROPERTIES_FILE="${HOME}/install.properties"
check_file_exist_delete $PROPERTIES_FILE
FID_VERSION_DEFAULT="7.2.32"
RLI_HOME_DEFAULT="${HOME}/radiantone/vds"
RLI_HOME_PROP="${HOME}/radiantone/vds"
CLUSTER_NAME_DEFAULT="cluster1"
read -p "Enter FID version (>=7.2.X) [${FID_VERSION_DEFAULT}]: " FID_VERSION
FID_VERSION=${FID_VERSION:-$FID_VERSION_DEFAULT}
# read -p "Enter RLI_HOME path [${RLI_HOME_DEFAULT}]: " RLI_HOME
# RLI_HOME=${RLI_HOME:-$RLI_HOME_DEFAULT}
RLI_HOME=$RLI_HOME_DEFAULT
read -p "Enter cluster name [${CLUSTER_NAME_DEFAULT}]: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-$CLUSTER_NAME}
read -p "Enter password: " PASSWORD
read -p "Re-enter password: " REPASSWORD
while [[ "$PASSWORD" != "$REPASSWORD" ]]
do
 #echo -e "\033[33mPasswords did not match!\033[0m"
 print_warn "Passwords did not match"
 read -p "Enter password: " PASSWORD
 read -p "Re-enter password: " REPASSWORD
done
read -p "Enter license: " LICENSE

download_location="http://10.11.12.113/share/artifacts/stable_releases/${FID_VERSION}/installers/ces/radiantone_${FID_VERSION}_linux_64.bin"
installer_save_location="${HOME}/radiantone_${FID_VERSION}_linux_64.bin"

echo "Downloading from $download_location ..."
echo "Saving to $installer_save_location  ..."

check_file_exist_delete $installer_save_location

curl $download_location --output $installer_save_location

chmod +x $installer_save_location

echo "USER_INSTALL_DIR=${RLI_HOME_PROP}" > ${PROPERTIES_FILE}
echo "CHOSEN_FEATURE_LIST=Application,sample" >> ${PROPERTIES_FILE}
echo "CHOSEN_INSTALL_FEATURE_LIST=Application,sample" >> ${PROPERTIES_FILE}
echo "CHOSEN_INSTALL_SET=standalone" >> ${PROPERTIES_FILE}
echo "INST_ZK_NEW=1" >> ${PROPERTIES_FILE}
echo "INST_ZK_ENSEMBLE_PORT=2888" >> ${PROPERTIES_FILE}
echo "INST_ZK_LEADER_PORT=3888" >> ${PROPERTIES_FILE}
echo "INST_ZK_CLIENT_PORT=2181" >> ${PROPERTIES_FILE}
echo "INST_ZK_JMX_PORT=2182" >> ${PROPERTIES_FILE}
echo "INST_ZK_EXISTING=0" >> ${PROPERTIES_FILE}
echo "INST_ZK_CONN=" >> ${PROPERTIES_FILE}
echo "INST_ZK_CLUSTER=${CLUSTER_NAME}" >> ${PROPERTIES_FILE}
echo "INST_ZK_LOGIN=admin" >> ${PROPERTIES_FILE}
echo "INST_ZK_PASSWORD=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "INST_ZK_PASSWORD_CONFIRM=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "root_user=cn=Directory Manager" >> ${PROPERTIES_FILE}
echo "root_password_1=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "root_password_2=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "server_port_1=2389" >> ${PROPERTIES_FILE}
echo "server_port_3=636" >> ${PROPERTIES_FILE}
echo "server_tls_enable=0" >> ${PROPERTIES_FILE}
echo "server_port_2=1099" >> ${PROPERTIES_FILE}
echo "vds_http_port=8089" >> ${PROPERTIES_FILE}
echo "vds_https_port=8090" >> ${PROPERTIES_FILE}
echo "vds_admin_http_port=9100" >> ${PROPERTIES_FILE}
echo "vds_admin_https_port=9101" >> ${PROPERTIES_FILE}
echo "INST_ASADMIN_PASSWORD=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "INST_ASADMIN_PASSWORD_CONF=82131E7DCD2DBE783D281E7DCD2DBE783D2" >> ${PROPERTIES_FILE}
echo "INST_ASADMIN_PORT=4848" >> ${PROPERTIES_FILE}
echo "INST_JMX_PORT=8686" >> ${PROPERTIES_FILE}
echo "jetty.http=7070" >> ${PROPERTIES_FILE}
echo "jetty.https=7171" >> ${PROPERTIES_FILE}
echo "Created install.properties ${PROPERTIES_FILE}"
echo "Installing VDS Silently ..."
install_silent_command="${installer_save_location} -i silent -f ${PROPERTIES_FILE}"
echo "Invoking command ${install_silent_command}"
export RLI_IA_root_password=$PASSWORD
export RLI_IA_INST_ZK_PASSWORD=$PASSWORD
export RLI_IA_INST_ASADMIN_PASSWORD=$PASSWORD
eval $install_silent_command
install_log="${RLI_HOME}/logs/install/build-finish.log"
while [ ! -f $install_log ]
do
  echo "Waiting for build to finish, Sleep 10 seconds"
  sleep 10
done
license_file="${RLI_HOME}/vds_server/license.lic"
check_file_exist_delete $license_file
echo $LICENSE > $license_file
echo "Installation completed, Now restart ..."