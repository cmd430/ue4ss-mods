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


## Example INI
```ini
[GameSettings]
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
AirControlModifier=0.500000

[PhysicsSettings]
DefaultGravityZ=-2250

[ConsoleVariables]
r.LightMaxDrawDistanceScale=2
r.Lumen.SampleFog=1
```

## Install
Put the mod into the `Win64\ue4ss\Mods` directory and place `.ini` files into the `Win64\GameSettings` directory as follows

```
OblivionRemastered
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
                    │   LIP.lua
                    │   main.lua
```

## Download
You can grab the latest from [Releases](https://github.com/cmd430/ue4ss-mods/releases/)
