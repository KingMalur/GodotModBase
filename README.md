Godot Racing Game
=================

Idea
----
This is a 3D top down racing game, where you can use predefined or user generated cars and tracks.  
Every race is player vs at least one CPU enemy. This is the basic idea. It should be highly moddable.  

Each car is packed in a .zip file containing:  
- Car (as scene with a fixed structure -> model, etc.)  
- Stats (as .json -> weight (sets default values for: acceleration, max speed, brake strength, grip, hitpoints, etc.))  
- Meta (as .json -> id, name, description, price, etc.)  

Each cup is packed in a .zip file containing:  
- Folder of tracks (as .zip files)  
- Stats (as .json -> reward money for 1st/2nd/3rd place, car stat modifiers (varying gameplay), etc.)  
- Meta (as .json -> name, description, price, etc.)  

Each track is packed in a .zip file containing:  
- Track (as scene with a fixed structure -> start/end, checkpoints, starting positions, etc.)  
- Stats (as .json -> default number of laps, reward money for 1st/2nd/3rd place for single race without cup, car stat modifiers (varying gameplay), etc.)  
- Meta (as .json -> id, name, description, price, etc.)  

With this structure there should always be cups with tracks and never a track without a cup. If you want to add a single track you have to add a cup with only this one track in it.  

Requirements
------------
The following list is required for the project to move forward!  
If a milestone is achieved it should be marked using ✔️. Until then it is highlighted using ❌.  

Data Storage
------------
Persistent data (cars/cups/tracks, languages, etc.):  
  * .json- & .zip-files in res://data  

Changing data (user saves, options, etc.):  
  * .json-files in user://  
    * Save files in user://saves/<YYYYMMDD_HHMMSSMS>.json  
    * Activated mods per save in user://saves/<save>/activated_mods.json  
    * Options, etc. per user://options.json  

📁 res://data/  
├───📁 cars  
│   ├───📁 car .zip-file  
│   ├───📁 car .zip-file  
│   └───📁 car .zip-file  
└───📁 cups  
    ├───📁 cup .zip-file  
    │   ├───📁 track .zip-file  
    │   ├───📁 track .zip-file  
    │   ├───📁 track .zip-file  
    │   └───📁 track .zip-file  
    ├───📁 cup .zip-file  
    │   ├───📁 track .zip-file  
    │   ├───📁 track .zip-file  
    │   ├───📁 track .zip-file  
    │   └───📁 track .zip-file  
    └───📁 cup .zip-file  
        ├───📁 track .zip-file  
        ├───📁 track .zip-file  
        ├───📁 track .zip-file  
        └───📁 track .zip-file  

📁 user://  
└───📁 saves  
    ├───📁 <save>  
    │   └───📁 options, activated mods, etc.  
    ├───📁 <save>  
    │   └───📁 options, activated mods, etc.  
    └───📁 <save>  
        └───📁 options, activated mods, etc.  

### Example
Persistant car-stat-data in .json-file:  

      "id": "<type>_<manufacturer>_<model>_<iteration>",  
      "name": "name_<type>_<manufacturer>_<model>_<iteration>",  
      "description": "description_<type>_<manufacturer>_<model>_<iteration>",  
      "weight": "w_light/w_normal/w_heavy"  

Changing car-data in .json-file:  

      "id": "<type>_<manufacturer>_<model>_<iteration>",  
      "price": "1500",  
      "unlocked": "true"  

Matching in game could be done using the "id"-field.  

Checklist
---------

[❌] File-Handling (READ & WRITE)  
  * [❌] (req.) Reading .zip-files (cars, cups, mods, scripts, translations, etc.)  
  * [❌] (req.) Recursive reading of .zip-files in .zip-files (tracks, etc.)  
  * [❌] (req.) Opening JSON-files  
  * [❌] (req.) Reading from res://  
  * [❌] (req.) Reading from user://  
  * [❌] (req.) Loading data from .json  
  * [❌] (req.) Writing to res://  
  * [❌] (req.) Writing to user://  

[❌] Base Game  
  * [❌] (req.) Loading translations (.json in .zip)  
  * [❌] (req.) Loading cars (.json in .zip)  
  * [❌] (req.) Loading cups (.json in .zip)  
  * [❌] (req.) Loading tracks (.json in .zip in .zip)  
  * [❌] (opt.) Loading mods (.json in zip)  
  * [❌] (req.) Start into 3D world ()  

[❌] Mod-Support  
  * [❌] (req.) Loading required mods (e.g. expansions, updates, etc.)  
  * [❌] (req.) Loading enabled mods in correct order read from active_mods.json  
  * [❌] (req.) Loading enabled mods only if version is equal to version from active_mods.json  
  * [❌] (req.) Loading mods that add another scene/object to the game  
  * [❌] (opt.) Checking version of game vs version (min & max) required by mod (info in .json files)  
  * [❌] (opt.) Adding custom commands (LoadTranslation: path, LoadPackage: path, etc.)  

[❌] Game World  
  * [❌] (req.) 3D top down camera  
  * [❌] (req.) simple drivable car loaded from .zip-file  
  * [❌] (req.)   
  * [❌] (req.)   
  * [❌] (req.)   
  * [❌] (req.)   
  * [❌] (req.)   
  * [❌] (req.)   

[❌] Sound & Music  
  * [❌] (req.) MainMenu music that plays until Game scene is loaded  
  * [❌] (req.) Music for Game scene during exploring  
  * [❌] (req.) Music for Game scene during battle  
  * [❌] (req.) Sound effects for skills  
  * [❌] (req.) Menu effects (e.g. clicking)  
  * [❌] (opt.) Music & Sound on/off from Options have an effect  
  * [❌] (opt.) Blend different Music & Sound  

[❌] Main Menu  
  * [❌] (req.) MainMenu-scene with NewGame-/LoadGame-/Options-/Exit-Button  
  * [❌] (req.) Options-menu  
  * [❌] (req.) Starting new game  
  * [❌] (req.) Starting old game  
  * [❌] (req.) Exit to desktop  
