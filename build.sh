#!/bin/bash

set -e
#Credit to Meghthedev for the initial script 

# Initialize repo with specified manifest
export PROJECTFOLDER="/crave-devspaces/Lineage20"
export PROJECTID="36"
export REPO_INIT="repo init -u https://github.com/accupara/los20.git -b lineage-20.0 --git-lfs --depth=1"
if grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"') && [ "${DCDEVSPACE}" == "1" ]; then
   crave clone destroy -y $PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
else
   rm -rf $PROJECTFOLDER || true
fi

if [ "${DCDEVSPACE}" == "1" ]; then
   crave clone create --projectID $PROJECTID $PROJECTFOLDER || echo "Crave clone create failed!"
else
   mkdir $PROJECTFOLDER
   echo "Running $REPO_INIT"
   $REPO_INIT
fi

# Run inside foss.crave.io devspace
# Remove existing local_manifests
crave run --no-patch -- "rm -rf .repo/local_manifests && \

# Clone local_manifests repository
git clone https://github.com/sounddrill31/local_manifests --depth 1 -b lineage-oxygen .repo/local_manifests && \

 # Sync the repositories
 /opt/crave/resync.sh && \ 

# Set up build environment
source build/envsetup.sh && \

# Lunch configuration
lunch lineage_oxygen-userdebug && \

# Build the ROM
mka bacon"

# Clean up
if grep -q "$PROJECTFOLDER" <(crave clone list --json | jq -r '.clones[]."Cloned At"') && [ "${DCDEVSPACE}" == "1" ]; then
  crave clone destroy -y $PROJECTFOLDER || echo "Error removing $PROJECTFOLDER"
else  
  rm -rf $PROJECTFOLDER || true
fi
# Upload zips to Telegram
/opt/crave/telegram/upload.sh
