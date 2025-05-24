# Game Settings Loader
Yep, yet another UE4SS GameSettingsLoader

## Features

- Load TES4 Game Settings (GameSettings)
  - Automatically resolves TES4 -> UE5 Settings if required
- Load UE5 Game Settings (VOblivionInitialSettings)
  - Automatically resolves UE5 -> TES4 Settings if required
- Load UE5 Physics Settings (PhysicsSettings)
- Set UE5 CVars (ConsoleVariables)
- Loads from INIs in `GameSettings` directory
  - INI files support inline comments using `;` or normal comments using either `;` or `#`


## Example INI
```ini
[GameSettings]
# This section is for settings that change in the TES4 side
fActorStrengthEncumbranceMult=8.0
iNumberActorsInCombatPlayer=80
iAINumberActorsComplexScene=100
iRemoveExcessDeadCount=60
iRemoveExcessDeadTotalActorCount=80
iRemoveExcessDeadComplexTotalActorCount=80
iRemoveExcessDeadComplexCount=21
fRemoveExcessDeadTime=400.0
fRemoveExcessComplexDeadTime=200.0

[VOblivionInitialSettings]
# This section is for settings that change on the UE5 side
AirControlModifier=0.500000

[PhysicsSettings]
# UE5 physics settings can be changed here
DefaultGravityZ=-2250

[ConsoleVariables]
# UE console variables can be set here
r.LightMaxDrawDistanceScale=2 ; 2x light distance
r.Lumen.SampleFog=1           ; enable fog in water reflections
```

## Install
 1. Put the mod into the `OblivionRemastered\Binaries\Win64\ue4ss\Mods` directory
 2. Put any `.ini` files into the `OblivionRemastered\Binaries\Win64\GameSettings` directory

```
OblivionRemastered
└───Binaries
    └───Win64
        └───GameSettings
        │   │   example.ini
        │   │   ...
        │
        └───ue4ss
            └───Mods
                └───GameSettingsLoader
                    │   Readme.md
                    │
                    └───Scripts
                        │   config.lua
                        │   lib.lua
                        │   main.lua
```

## Download
You can grab the latest from [Releases](https://github.com/cmd430/ue4ss-mods/releases/)
