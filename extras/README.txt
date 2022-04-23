MiniUI is an extensible launcher for the Miyoo Mini

Source: https://github.com/shauninman/MiniUI

----------------------------------------
Adding Paks

A pak is a folder with the pak extension name containing a shell script named launch.sh. 

There are two kinds of paks, emulators and tools. Emulator paks live in the Emus folder. Tool paks live in the Tools folder. Both folders live at the root of your SD card. If you're adding paks created by someone else (sharing is caring) just copy each pak into the corresponding folder. That's usually it but they may have additional steps. Check for a readme or ask the original author if you're unsure.

----------------------------------------
Emulator Paks

There are two kinds of emulator paks, both similar, both super simple. The first re-uses an existing MiniUI libretro core. The second uses a custom libretro core. To illustrate the different approaches, let's create a Sega Game Gear pak.

First create an "Emus" folder at the root of your SD card if one doesn't already exist. Then make sure your file browser is showing invisible files for this next step. Copy "/.system/paks/Emus/MD.pak/" into the Emus folder and rename it to GG.pak. GG is your emulator tag. The tag is used to map its roms folder to the pak. Open up the launch.sh file in a plain text editor. Find and replace `EMU_TAG=MD` with `EMU_TAG=GG` and save the file. You're done. You just created your first MiniUI emulator pak! Now create the corresponding roms folder "/Roms/Game Gear (GG)/" (see, there's that tag!) and load it up with a few roms. Boot up MiniUI and give it a shot. Easy, right? Let's do the next one.

First download this smsplus-gx_libretro.so core and put it in your GG.pak. Then open launch.sh in a plain text editor again. We need to replace two things this time. Find and replace `EMU_EXE=picodrive` with `EMU_EXE=smsplus-gx`. Then right below that line add `CORES_PATH=$(dirname "$0")`. Save and you're done. 

----------------------------------------
Tool Paks
