#!/bin/bash

#
#
# Sync the data with the remote machine
#
#


# Note1 : these commands are set in "dry run" mode. Run them and see if anything
# looks weird. To sync remove --dry-run. Whatever you delete will be deleted too.

# Note 2: for a destructive sync (delete the difference) use this option '--delete' instead of 
# '--update'

#
# Columbus
#

# password to columbus machine is d3v3l0p3rs


# TO Columbus rsync (for Michael's macbookpro)
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/myudelson/Documents/pitt/pittuohmooc/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# FROM Columbus rsync (for Michael's macbookpro) 
rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/ /Users/myudelson/Documents/pitt/pittuohmooc/ 

# TO Columbus rsync (for Roya) -- FILL IN THE BLANK
rsync -avhW --progress --update --exclude-from=/Users/roya/Desktop/ProgMOOC/rsync-excludes.txt --dry-run /Users/roya/Desktop/ProgMOOC/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# FROM Columbus rsync (for Roya) -- FILL IN THE BLANK
rsync -avhW --progress --update --exclude-from=/Users/roya/Desktop/ProgMOOC/rsync-excludes.txt --dry-run developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/ /Users/roya/Desktop/ProgMOOC/

# Note: these commands are set in "dry run" mode. Run them and see if anything
# looks weird. To sync remove --dry-run. Whatever you delete will be deleted too.



# Other machines used before

# 
# # first connect to Pitt VPN if necessary
# # remote rsync (for Michael's mac mini) 
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/research/Documents/myudelson/ProgMOOC/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# 
# # logged into PAWSComp 2 sync with Columbus
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /home/myudelson/pittuohmooc/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/ /home/myudelson/pittuohmooc/ 
# 
# # logged into PAWSComp 2 sync with PSC's pylon2 storage
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /home/myudelson/pittuohmooc/ yudelson@bridges.psc.edu:/pylon2/ca4s8ip/yudelson/pittuohmooc/
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run yudelson@bridges.psc.edu:/pylon2/ca4s8ip/yudelson/pittuohmooc/ /home/myudelson/pittuohmooc/ 
# 
# # logged into Columbus sync with PSC's pylon2 storage
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /home/developers/ProgMOOC/ yudelson@data.bridges.psc.edu:/pylon2/ca4s8ip/yudelson/pittuohmooc
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run yudelson@data.bridges.psc.edu:/pylon2/ca4s8ip/yudelson/pittuohmooc /home/developers/ProgMOOC/
# 
# PAWSComp 2 to Columbus
# rsync -avhW --progress --update --exclude-from ./rsync-excludes.txt --dry-run /Users/yudelson/Documents/pitt/pittuohmooc/ developers@columbus.exp.sis.pitt.edu:/home/developers/ProgMOOC/
# 
# # copy from PSC to PAWS Comp 2
# scp -r yudelson@bridges.psc.xsede.org:/home/yudelson/pittuohmooc /home/myudelson/

