return {
  name = "GameSettingsLoader",
  author = 'xEpicBradx',
  version = "3.1.1",

  debug = false,                       -- Print extra logs to help with debugging
  game_settings_path = "GameSettings", -- path for GameSettings dir, example "OBSE\\Plugins\\GameSettings"

  -- Oblivion Game Rule -> UnrealEngine VOblivionInitialSettings
  tes4_to_ue5_bindings = {
    fMoveCharWalkMax = "DefaultMoveCharWalkMax",
    fMoveCharWalkMin = "DefaultMoveCharWalkMin",
    fMoveCreatureWalkMax = "DefaultMoveCreatureWalkMax",
    fMoveCreatureWalkMin = "DefaultMoveCreatureWalkMin",
    fMoveEncumEffect = "DefaultMoveEncumEffect",
    fMoveEncumEffectNoWea = "DefaultMoveEncumEffectNoWea",
    fMoveNoWeaponMult = "DefaultMoveNoWeaponMult",
    fMoveRunMult = "DefaultMoveRunMult",
    fMoveSneakMult = "DefaultMoveSneakMult",
    fMoveWeightMax = "DefaultMoveWeightMax",
    fSneakRunningMult = "SneakRunningMult",
    fSneakBootWeightBase = "SneakBootWeightBase",
    fSneakBootWeightMult = "SneakBootWeightMult",
    fSneakLightMult = "SneakLightMult",
    fSneakSkillMult = "SneakSkillMult",
    fSneakBaseValue = "SneakBaseValue",
    fSneakSleepBonus = "SneakSleepBonus",
    fSneakSoundLosMult = "SneakSoundLosMult",
    fSneakTargetAttackBonus = "SneakTargetAttackBonus",
    fSneakTargetInCombatBonus = "SneakTargetInCombatBonus",
    fDamageSkillMult = "SkillDamageMultiplier",
    fArrowSpeedMult = "ArrowInitialSpeedMultiplier",
    fArrowWeakSpeed = "ArrowWeakSpeedMultiplier",
    fArrowAgeMax = "ArrowLifeDuration",
    fMoveRunAthleticsMult = "DefaultMoveRunAthleticsMult",
    fMoveSwimRunAthleticsMult = "DefaultSwimMoveRunAthleticsMult",
    fMoveSwimRunBase = "DefaultMoveSwimRunBase",
    fMoveSwimWalkAthleticsMult = "DefaultMoveSwimWalkAthleticsMult",
    fMoveSwimWalkBase = "DefaultMoveSwimWalkBase",
    fSneakUnseenMin = "SneakUnseenMin",
    fSneakNoticedMin = "SneakNoticedMin",
    fSneakLostMin = "SneakLostMin",
    fSneakMaxDistance = "SneakMaxDistance",
    fSneakExteriorDistanceMult = "SneakExteriorDistanceMult",
    fDetectionNightEyeBonus = "DetectionNightEyeBonus",
    fMagicProjectileBaseSpeed = "MagicProjectileSpeedMultiplier",
    fActorStrengthEncumbranceMult = "DefaultStrengthEncumbranceMult",
    fCombatHitConeAngle = "CombatHitConeAngle"
  }
}
