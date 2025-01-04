class Battle
  #=============================================================================
  # Running from battle
  #=============================================================================
  def pbCanRun?(idxBattler)
    return false if trainerBattle?
    battler = @battlers[idxBattler]
    return false if !@canRun && !battler.opposes?
    return true if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
    return true if battler.abilityActive? &&
                   Battle::AbilityEffects.triggerCertainEscapeFromBattle(battler.ability, battler)
    return true if battler.itemActive? &&
                   Battle::ItemEffects.triggerCertainEscapeFromBattle(battler.item, battler)
    return false if battler.trappedInBattle?
    allOtherSideBattlers(idxBattler).each do |b|
      return false if b.abilityActive? &&
                      Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b, self)
      return false if b.itemActive? &&
                      Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b, self)
    end
    return true
  end

  # Return values:
  # -1: Chose not to end the battle via Debug means
  #  0: Couldn't end the battle via Debug means; carry on trying to run
  #  1: Ended the battle via Debug means
  def pbDebugRun
    return 0 if !$DEBUG || !Input.press?(Input::CTRL)
    commands = [_INTL("Victoria"), _INTL("Derrota"),
                _INTL("Empate"), _INTL("Rendirse")]
    commands.push(_INTL("Captura")) if wildBattle?
    commands.push(_INTL("Cancelar"))
    case pbShowCommands(_INTL("Elige un resultado para este combate."), commands)
    when 0   # Win
      @decision = 1
    when 1   # Loss
      @decision = 2
    when 2   # Draw
      @decision = 5
    when 3   # Run away/forfeit
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("¡Escapas sin problemas!"))
      @decision = 3
    when 4   # Capture
      return -1 if trainerBattle?
      @decision = 4
    else
      return -1
    end
    return 1
  end

  # Return values:
  # -1: Failed fleeing
  #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
  #  1: Succeeded at fleeing, battle will end
  # duringBattle is true for replacing a fainted Pokémon during the End Of Round
  # phase, and false for choosing the Run command.
  def pbRun(idxBattler, duringBattle = false)
    battler = @battlers[idxBattler]
    if battler.opposes?
      return 0 if trainerBattle?
      @choices[idxBattler][0] = :Run
      @choices[idxBattler][1] = 0
      @choices[idxBattler][2] = nil
      return -1
    end
    # Running from trainer battles

    if pbDisplayConfirm(_INTL("¿Quieres perder el combate y abandonar ahora?"))
      pbSEPlay("Battle flee")
      pbDisplay(_INTL("{1} perdió el combate!", self.pbPlayer.name))
      @decision = 2
      return 1
    end
    return 0
  end
end

