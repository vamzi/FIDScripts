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

FID_VERSION_DEFAULT="7.3.16"
RLI_HOME_DEFAULT="${HOME}/radiantone/vds"
CLUSTER_NAME_DEFAULT="cluster1"
read -p "Enter FID version (>=7.3.X) [${FID_VERSION_DEFAULT}]: " FID_VERSION
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

download_location="http://10.11.12.113/share/artifacts/stable_releases/${FID_VERSION}/installers/ces/radiantone_${FID_VERSION}_full_linux_64.tar.gz"
installer_save_location="${HOME}/radiantone_${FID_VERSION}_full_linux_64.tar.gz"

echo "Downloading from $download_location ..."
echo "Saving to $installer_save_location  ..."

check_file_exist_delete $installer_save_location

curl $download_location --output $installer_save_location

for (( i=1; i<=5; i++ ))
do  
   if test -f $installer_save_location
   then
    break
   else
    print_warn "Download file not found ${installer_save_location}, Sleeping for 5 seconds"
    sleep 5
   fi
done

if test -f $installer_save_location
then
    echo "Download Completed!"

    zip_destination="${HOME}/radiantone/"

    if test ! -f $zip_destination; then
    echo "Creating ${zip_destination} directory"
    mkdir -p $zip_destination
    fi
    
    

    echo "Unzipping the downloaded package to ${zip_destination}"

    tar -zxf $installer_save_location --directory $zip_destination -v

    echo "Unzipping completed!"

    license_file="${RLI_HOME}/vds_server/license.lic"

    echo "Setting up the license file at ${license_file} ..."

    echo $LICENSE > $license_file

    echo "${license_file} created successfully!"

    echo "Setting up environmental variables!"

    echo "RLI_HOME=${RLI_HOME}" >> /etc/environment

    install_properties_file="${RLI_HOME}/install/install-sample.properties"

    echo "Editing ${install_properties_file} ..."
    
    sed -i "s/StrongP@ssword1/${PASSWORD}/" $install_properties_file
    
    sed -i "s/cluster1/${CLUSTER_NAME}/" $install_properties_file
    
    echo "Installing FID versiom=${FID_VERSION} ..."
    
    install_command="${RLI_HOME}/bin/instanceManager.sh --setup-install ${install_properties_file}"

    echo "Invoking the command ${install_command}"
    
    eval $install_command
    
    echo "Installation completed, Starting control panel ..."
    
    launch_control_panel="${RLI_HOME}/bin/openControlPanel.sh"
	eval $launch_control_panel
    
else
    print_warn "Installer package file not found ${installer_save_location}"
fi