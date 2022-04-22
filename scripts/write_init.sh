#!/bin/bash
# setup basic init executable
printf "#!/bin/sh\nexec /bin/sh" > $BUILD_FOLDER/initramfs/init