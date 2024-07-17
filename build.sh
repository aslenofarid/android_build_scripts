#!/bin/bash

set -e
#Credit to Meghthedev for the initial script 

export PROJECTFOLDER="Lineage-17.1"
export PROJECTID="85"
export REPO_INIT="repo init -u https://github.com/LineageOS/android.git -b lineage-17.1"
export BUILD_DIFFERENT_ROM="$REPO_INIT" # Change this if you'd like to build something else

# Destroy Old Clones
if (grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"')) || [ "${DCDEVSPACE}" == "1" ]; then   
   crave clone destroy -y /crave-devspaces/$PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
else
   rm -rf $PROJECTFOLDER || true
fi

# Create New clone
if [ "${DCDEVSPACE}" == "1" ]; then
   crave clone create --projectID $PROJECTID /crave-devspaces/$PROJECTFOLDER || echo "Crave clone create failed!"
   cd /crave-devspaces/$PROJECTFOLDER
else
   mkdir $PROJECTFOLDER
   cd $PROJECTFOLDER
   echo "Running $REPO_INIT"
   $REPO_INIT
fi

# Run inside foss.crave.io devspace
# Remove existing local_manifests
crave run --no-patch -- "rm -rf .repo/local_manifests && \

# Init Manifest
$BUILD_DIFFERENT_ROM && \

# Clone local_manifests repository
git clone https://github.com/aslenofarid/local_manifest.git --depth 1 -b lineage-17.1 .repo/local_manifests && \

# Sync the repositories
/opt/crave/resync.sh && \ 

# Set up build environment
source build/envsetup.sh && \

# Lunch configuration
lunch lineage_X00TD-user && \

# export
export BUILD_USERNAME=aslenofarid
export TZ=Asia/Jakarta

# Build the ROM
brunch X00TD"

cd ..

# Clean up
if grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"') || [ "${DCDEVSPACE}" == "1" ]; then
  crave clone destroy -y /crave-devspaces/$PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
else  
  rm -rf $PROJECTFOLDER || true
fi
# Upload zips to Telegram
/opt/crave/telegram/upload.sh
