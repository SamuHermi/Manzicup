####################
##### CREDITS ######
####################
Please give credit to "Mega Mewthree" if you use any part of this system, including parts derived from this system.

Credit Vendily for updating to v17

Credit Gardenette for updating to v20.1

####################
### INSTRUCTIONS ###
####################
1. Copy over the graphics to the correct folders.
2. Make the edits in Extra Edits and install the three script sections
3. Open your game.
4. The achievements system will work properly on the first try. Enjoy!

**Disclaimer**
If you put this script above the v20.1 Essentials Hotfixes, or if you have the hotfixes as a plugin, this will overwrite the method for selling items, and selling items will not be counted towards achievements. I just copied the code from the hotfix and modified it to add to the achievement count. The def pbSellScreen in the Misc Bug Fixes script for hotfix 1.0.7 can be removed.

####################
# Add Achievements #
####################
1. Open Achievement_Module.rb in the plugin's folder.
2. Define a new achievement in @achievementList like this:
"{INTERNAL_NAME}"=>{
    "id"=>{a unique ID},
    "name"=>"{the displayed name of the achievement}",
    "description"=>"{a description}",
    "goals"=>[number,higher number,even higher number] # An array of goals, such as [100,250,500].
}
3. Go to the script that has the event you want to attach an achievement to, and add this in a logical place:
Achievements.incrementProgress("{INTERNAL_NAME}",{number to add to progress})

If you instead want to set the progress to a specific value, use this:
Achievements.setProgress("{INTERNAL_NAME}",{number to set progress to})

To decrease the progress of an achievement, use this:
Achievements.decrementProgress("{INTERNAL_NAME}",{number to add to progress})
4. Test your achievement to make sure it actually works.

####################
####### FAQs #######
####################
Q: Why are most of my achievements starting at zero progress?
A: Achievement progress cannot be tracked before you add this system.
   The exception is STEPS and bought items in the pokemart, since the game already had a variable for those.

Q: Why is there an error?
A: Please send the error and a description of the issue on the relic castle post's discussion.
   
Q: Why isn't my custom achievement working?
A: Please post a description of the issue and your code for your achievement on the relic castle post's discussion.
   
Q: I deleted an achievement. Can I still get my progress back after readding it?
A: Not if you had saved after deleting the achievement.
   If you want to prevent deleting an achievement from deleting progress, modify def fixAchievements.

Q: What is the meaning of life?
A: Your life is spent trying to find Arceus.

^^^ True - Gardenette