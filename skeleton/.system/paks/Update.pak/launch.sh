#!/bin/sh
# Update.pak

TMP_UPDATE_DIR="/mnt/SDCARD/.tmp_update"
INSTALL_ZIP="/mnt/SDCARD/MiniUI.zip"
SYSTEM_PATH="/mnt/SDCARD/.system"

progressui &

progress 0 Installing update
sleep 1

NUM=0
PERCENT=0
TOTAL=`unzip -l ${INSTALL_ZIP} | grep -o -E '[0-9]+\s+files$' | grep -o -E '[0-9]+'`
unzip -l $INSTALL_ZIP | awk -F" " '{print $4}' | grep -o -E '.*\/.*' | while read FILE_PATH
do
	NUM=`expr $NUM + 1`
	PERCENT=`expr $NUM \* 99 \/ $TOTAL`
	BASENAME=$(basename $FILE_PATH)
	progress $PERCENT Unzipping $BASENAME
	unzip -q -o "$INSTALL_ZIP" "$FILE_PATH" -d "$TMP_UPDATE_DIR" 
done

progress 99 Cleaning up
sleep 1

rm -f "$INSTALL_ZIP"

OLD_SYSTEM_PATH="/mnt/SDCARD/.tmp_update/.system-old"

mv "$SYSTEM_PATH" "$OLD_SYSTEM_PATH"
mv "$TMP_UPDATE_DIR/.system" "$SYSTEM_PATH"

# preserve any unoffical Emus and Tools paks
for SRC_PATH in `find $OLD_SYSTEM_PATH -type d -name "*.pak"` ; do
	REL_PATH=${SRC_PATH/$OLD_SYSTEM_PATH/}
	DST_PATH=$SYSTEM_PATH$REL_PATH
	if [ ! -d "$DST_PATH" ]; then
		mv $SRC_PATH $DST_PATH
	fi
done

#preserve any unofficial libretro cores
for SRC_PATH in `find $OLD_SYSTEM_PATH -type f -name "*_libretro.so"` ; do
	REL_PATH=${SRC_PATH/$OLD_SYSTEM_PATH/}
	DST_PATH=$SYSTEM_PATH$REL_PATH
	if [ ! -f "$DST_PATH" ]; then
		mv $SRC_PATH $DST_PATH
	fi
done

# perform post-update actions if present in updated .system folder
if [ -f "$SYSTEM_PATH/post-update.sh" ]; then
	"$SYSTEM_PATH/post-update.sh"
	rm -f "$SYSTEM_PATH/post-update.sh"
fi

progress 100 Update complete
sleep 1

progress quit

killall keymon
killall lumon
rm -rf "$OLD_SYSTEM_PATH"

killall launch.sh
