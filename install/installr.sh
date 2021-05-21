#!/bin/bash

# m1nstallr.sh
# A script to install macos and
# additional packagesfound in a packages folder in the same directory
# as this script

if [[ $EUID != 0 ]] ; then
    echo "m1nstallr: Please run this as root, or via sudo."
    exit -1
fi


arch=$(/usr/bin/arch)
if [[ "$arch" != "arm64" ]]; then
    echo "m1nstallr: This should be only run on ARM based Macs"
    exit -1
fi

echo "Prepping Mac for Setup"
echo
## Rename drive after wiping disk
if [[ -d '/Volumes/Untitled' ]]; then
diskutil rename "Untitled" "Macintosh HD"
fi


count=`ls -1 /Volumes/Macintosh\ HD/Users/Shared/*.pkg 2>/dev/null | wc -l`
if [ $count != 0 ]
then 
    echo "Cleaning out Firstboot Packages"
    rm /Volumes/Macintosh\ HD/Users/Shared/*.pkg
fi 

## Add files to convince installer that this is an in-place upgrade
if [[ ! -d '/Volumes/Macintosh HD/System/Library/CoreServices' ]]; then
mkdir -p '/Volumes/Macintosh HD/System/Library/CoreServices'
fi

if [[ ! -f '/Volumes/Macintosh HD/System/Library/CoreServices/SystemVersion.plist' ]]; then
touch '/Volumes/Macintosh HD/System/Library/CoreServices/SystemVersion.plist'
fi

if [[ ! -d '/Volumes/Macintosh HD/private/var/db/dslocal/nodes/Default' ]]; then
mkdir -p '/Volumes/Macintosh HD/private/var/db/dslocal/nodes/Default'
fi

## Add firstboot launch daemon and script
if [[ ! -d '/Volumes/Macintosh HD/Library' ]]; then
cp -rv /Volumes/install/Library /Volumes/Macintosh\ HD
fi

if [[ ! -d '/Volumes/Macintosh HD/Users' ]]; then
cp -rv /Volumes/install/Users /Volumes/Macintosh\ HD
fi
echo
echo "****** Welcome to m1nstallr! ******"
echo
osvers=$(sw_vers | grep ProductVersion | awk 'END {print $NF}')
hwinfo=$(ioreg -c "IOPlatformExpertDevice" | awk -F '"' '/model/ {print $4}'| sed -e '/^ *$/d' | head -n1)
echo "This is a '$hwinfo' running on macOS'$osvers'"
echo
## Present configuration options
PS3='Please enter your choice: '
options=("No Configuration" "DEP Staff Configuration" "Staff Loaner Configuration" "Student Configuration" "Student Lab Configuration" "Quit")
COLUMNS=12
select opt in "${options[@]}"
do
    case $opt in
        "No Configuration")
            echo "You chose choice $REPLY which is $opt.
This is the $opt workflow which will reinstall macOS 11.3.1"
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    break
else
    exit 0
fi
            ;;
        "DEP Staff Configuration")
            echo "You chose choice $REPLY which is $opt.
This is the $opt workflow which will reinstall macOS 11.3.1 and install 
a first-boot script that will install general apps for staff/faculty after the Mac Setup Assistant.
Please add this device to the Staff DEP Enrollment prestage enrollment in the JSS before
completing this workflow."
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    break
else
    exit 0
fi
            ;;
        "Staff Loaner Configuration")
            echo "You chose choice $REPLY which is $opt.
This is the $opt workflow which will reinstall macOS 11.3.1 and install 
a first-boot script that will install general apps for staff/faculty after the Mac Setup Assistant.
The CasperSplash app and staff onboarding login scripts will not be installed as this device 
will be a loaner device with no primary or permanent user. 
Please add this device to the Staff DEP Enrollment prestage enrollment in the JSS before
completing this workflow.
Upon completion of this workflow, you will be required to log into the techsupport account
to rename the device."
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	break
else
    exit 0
fi
            ;;
        "Student Configuration")
            echo "You chose choice $REPLY which is $opt.
This is the $opt workflow which will reinstall macOS 11.3.1 and install 
a first-boot script that will install general apps for students after the Mac Setup Assistant.
Please add this device to your site's Student Device Enrollment prestage enrollment in the JSS before
completing this workflow.
Upon completion of this workflow, you will be required to log into the techsupport account
to rename the device."
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	break
else
    exit 0
fi
            ;;
        "Student Lab Configuration")
            echo "You chose choice $REPLY which is $opt.
This is the $opt workflow which will reinstall macOS 11.3.1 and install 
a first-boot script that will install general and Adobe Creative Cloud apps for student media labs 
after the Mac Setup Assistant.
Please add this device to your site's Student Device Enrollment prestage enrollment in the JSS before
completing this workflow.
Upon completion of this workflow, you will be required to log into the techsupport account
to rename the device."
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	break
else
    exit 0
fi
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
if [[ $opt == "No Configuration" ]]; then 
rm /Volumes/Macintosh\ HD/Library/LaunchDaemons/org.pausd.depshippayload.plist
rm /Volumes/Macintosh\ HD/Users/Shared/Firstboot.sh	
elif [[ $opt == "DEP Staff Configuration" ]]; then 
PACKAGE="/Volumes/install/packages/DEPShip-Staff-8.0.pkg"
elif [[ $opt == "Staff Loaner Configuration" ]]; then
PACKAGE="/Volumes/install/packages/DEPShip-Staff-Loaner-3.0.pkg"
elif [[ $opt == "Student Configuration" ]]; then
PACKAGE="/Volumes/install/packages/DEPShip-Student.pkg"
elif [[ $opt == "Student Lab Configuration" ]]; then
PACKAGE="/Volumes/install/packages/DEPShip-Lab-2.0.pkg"
fi

# build our startosinstall command
CMD="cp ${PACKAGE} /Volumes/Macintosh\ HD/Users/Shared" 

    
# kick off the OS install
eval $CMD
## Run installer
/Volumes/install/Install\ macOS\ Big\ Sur.app/Contents/MacOS/InstallAssistant_springboard
