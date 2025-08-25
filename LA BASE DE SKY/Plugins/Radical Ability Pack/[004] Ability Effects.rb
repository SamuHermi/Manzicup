#================================================================
# Fatal Precision
# Super effective moves can't miss & boosted by 20%.
#================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:FATALPRECISION,
  proc { |ability, user, target, move, mults, power, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:power_multiplier] *= 1.2 
    end
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:NOGUARD,
  proc { |ability, mods, user, target, move, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mods[:base_accuracy] = 0
    end
  }
)

#================================================================
# Bull Rush
# Boosts power by 20% & Speed by 50% in first turn.
#================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:BULLRUSH,
  proc { |ability, user, target, move, mults, power, type|
    if move.physicalMove? && user.turnCount <= 1
      mults[:attack_multiplier] *= 1.2 
    end
  }
)

Battle::AbilityEffects::SpeedCalc.add(:QUICKFEET,
  proc { |ability, battler, mult|
    next mult * 1.5 if battler.turnCount <= 1
  }
)

#================================================================
# Feline Prowess
# Doubles Special Attack stat.
#================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:FELINEPROWESS,
  proc { |ability, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 2 if move.specialMove?
  }
)

#================================================================
# Parasitic Waste 
# Attacks that poison also drain.
#================================================================s
Battle::AbilityEffects::OnDealingHit.add(:PARASITICWASTE,
  proc { |ability, user, target, move, battle|
    next if !move.function_code.include?("PoisonTarget")
    next if !move.damagingMove?
    next if !user.canHeal?
    next if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    battle.pbShowAbilitySplash(user)
    user.pbRecoverHPFromDrain(hpGain, target) 
    battle.pbHideAbilitySplash(user)
  }
)

#============================================================
# Mountaineer
# Immune to Rock attacks and Stealth Rocks.
#============================================================
Battle::AbilityEffects::MoveImmunity.add(:MOUNTAINEER,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if type != :ROCK
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

#============================================================
# Self Sufficient
# Restores 1/16 HP each turn.
#============================================================
Battle::AbilityEffects::EndOfRoundHealing.add(:SELFSUFFICIENT,
  proc { |ability, battler, battle|
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp / 16)
	  if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", battler.pbThis, battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#============================================================
# Blazing Soul
# Gives +1 priority to Fire moves at full HP.
#============================================================
Battle::AbilityEffects::PriorityChange.add(:BLAZINGSOUL,
  proc { |ability, battler, move, pri|
    next pri + 1 if move.type == :FIRE && battler.hp == battler.totalhp
  }
)

#============================================================
# Sage Power
# Ups SpAtk by 50% but only uses 1st picked move.
#============================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:SAGEPOWER,
  proc { |ability, user, target, move, mults, power, type|
    boost_special = true if move.specialMove?
    boost_special = false if defined?(move.powerMove?) && move.powerMove?
    mults[:attack_multiplier] *= 1.5 if boost_special
  }
)