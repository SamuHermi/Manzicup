class Battle::Move
  # New move flags for abilities.

  def boneMove?
    return @flags.any? { |f| f[/^Bone$/i] } || Settings::BONE_MOVES.include?(@id)
  end

  alias rr_pbNumHits pbNumHits
  def pbNumHits(user, targets)
    return 1 if defined?(powerMove?) && powerMove?
    if user.hasActiveAbility?(:ORAORAORAORA) && punchingMove? &&
       pbDamagingMove? && !chargingTurnMove? && targets.length == 1 
      user.effects[PBEffects::ParentalBond] = 3
      return 2
    end
    return rr_pbNumHits(user, targets)
  end

  alias rr_pbCalcTypeModSingle pbCalcTypeModSingle
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = rr_pbCalcTypeModSingle(moveType, defType, user, target)
    if Effectiveness.resistant_type?(moveType, defType)
      if user.hasActiveAbility?(:BONEZONE) && boneMove?
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    return ret
  end

  alias rr_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    rr_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    if user.effects[PBEffects::ParentalBond] == 1 
      if !user.hasActiveAbility?(:PARENTALBOND)
        multipliers[:power_multiplier] *= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
      end
      multipliers[:power_multiplier] /= 2 if user.hasActiveAbility?(:ORAORAORAORA)
    end
  end

  alias rr_pbAdditionalEffectChance pbAdditionalEffectChance
  def pbAdditionalEffectChance(user, target, effectChance = 0)
    return 0 if user.hasActiveAbility?(:FROZENMIST) && !@battle.moldBreaker
    return rr_pbAdditionalEffectChance(user, target, effectChance)
  end
end

class Battle::Move::RecoilMove < Battle::Move
  alias rr_pbEffectAfterAllHits pbEffectAfterAllHits
  def pbEffectAfterAllHits(user, target)
    if user.hasActiveAbility?(:BADCOMPANY)
      return
    else
      rr_pbEffectAfterAllHits(user, target)
    end
  end
end

class Battle::Move::UserTargetSwapItems < Battle::Move
  def pbEffectAgainstTarget(user, target)
    oldUserItem = user.item
    oldUserItemName = user.itemName
    oldTargetItem = target.item
    oldTargetItemName = target.itemName
    user.item                             = oldTargetItem
    user.effects[PBEffects::ChoiceBand]   = nil if !user.hasActiveAbility?([:GORILLATACTICS, :SAGEPOWER])
    user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem) if user.hasActiveAbility?(:UNBURDEN)
    target.item                           = oldUserItem
    target.effects[PBEffects::ChoiceBand] = nil if !target.hasActiveAbility?([:GORILLATACTICS, :SAGEPOWER])
    target.effects[PBEffects::Unburden]   = (!target.item && oldTargetItem) if target.hasActiveAbility?(:UNBURDEN)
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && oldTargetItem == target.initialItem
      user.setInitialItem(oldTargetItem)
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!", user.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.", user.pbThis, oldTargetItemName)) if oldTargetItem
    @battle.pbDisplay(_INTL("{1} obtained {2}.", target.pbThis, oldUserItemName)) if oldUserItem
    user.pbHeldItemTriggerCheck
    target.pbHeldItemTriggerCheck
  end
end