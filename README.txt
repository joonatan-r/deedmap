
-- Description --

This plugin for The Lord of the Rings Online adds a new map of Middle-earth with interactable, 
filterable deed location markers. The map uses the existing in game map images and similar 
controls. All deed locations tell the name and exact location of the deed and have a short 
description. 

The map also includes milestone "travel buttons" that execute a port skill for the 
corresponding location (if it's available to the player) when clicked. There are default 
travel buttons for every reputation faction that have a port skill that all players can earn, and 
players have the ability to add and save new travel buttons anywhere and change the skills used 
in both the default and custom buttons (useful for example for changing to the players racial 
port skill, as it's different from the default one). 

This plugin is a work-in-progress project, and unfortunately at the time of writing this only 
includes the deeds in Ered Luin, The Shire, Bree-land and the Lone-lands. The whole 
map is "complete" for fully supporting the travel button system, but it could have more zoom-in 
button places, and currently there is only one default travel button for each location (even 
though the locations can sometimes be seen from multiple maps). 

The chat command "/deedmap" is used to toggle visibility of the map. It is recommended to bind 
this to a quickslot with "/shortcut [quickslot number] /deedmap" for ease of use. 

-- Installation --

To install the plugin, copy the "GonnhirPlugins" folder to LOTRO's plugin folder, which should be 
in "Documents\The Lord of the Rings Online\" (easiest way to find it should be by clicking 
"Explore screenshots folder" from the top downward arrow in the launcher). If it doesn't exist 
yet, create the folder "plugins". You'll also need to copy the "Turbine" folder in the plugins 
folder if you don't already have it there. 

If successful, you should be able to load the plugin in game from the plugin manager or by using 
the "/plugins load DeedMapPlugin" chat command. 
