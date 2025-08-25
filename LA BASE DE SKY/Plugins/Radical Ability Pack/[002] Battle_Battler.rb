class Battle::Battler
  def phoenixDown?
    return @battle.phoenixDown[@index & 1][@pokemonIndex]
  end

  def setPhoenixDown
    @battle.phoenixDown[@index & 1][@pokemonIndex] = true
  end
  
  alias rr_pbRemoveItem pbRemoveItem
  def pbRemoveItem(permanent = true)
    rr_pbRemoveItem(permanent)
    if hasActiveAbility?(:SAGEPOWER)
      if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastMoveUsed
      elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
      end
    end
  end

  alias rr_pbEndTurn pbEndTurn
  def pbEndTurn(_choice)
    if !@effects[PBEffects::ChoiceBand] && hasActiveAbility?(:SAGEPOWER)
      if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastMoveUsed
      elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
      end
    end
    rr_pbEndTurn(_choice)
  end

  alias rr_pbCanChooseMove? pbCanChooseMove?
  def pbCanChooseMove?(move, commandPhase, showMessages = true, specialUsage = false)
    @effects[PBEffects::ChoiceBand] = nil if !pbHasMove?(@effects[PBEffects::ChoiceBand])
    if @effects[PBEffects::ChoiceBand] && move.id != @effects[PBEffects::ChoiceBand]
      choiced_move = GameData::Move.try_get(@effects[PBEffects::ChoiceBand])
      if choiced_move
        if hasActiveAbility?(:SAGEPOWER)
          if showMessages
            msg = _INTL("{1} can only use {2}!", pbThis, choiced_move.name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      end
    end   
    return rr_pbCanChooseMove?(move, commandPhase, showMessages, specialUsage) 
  end
  
  alias rr_pbFaint pbFaint
  def pbFaint(showMessage = true)
    if hasActiveAbility?(:PHOENIXDOWN, true) && fainted? && !@fainted && !phoenixDown?
      @battle.scene.pbFaintBattler(self)
      @battle.scene.pbSendOutBattlers([@index, @pokemon])
      @battle.pbShowAbilitySplash(self)
      pbRecoverHP((@totalhp / 2).round)
      pbCureStatus(false)
      pbResetStatStages
      setPhoenixDown
      @battle.pbHideAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1} rose back to battle!", pbThis))
      @battle.pbDisplay(_INTL("{1}'s stats and primary status were reset!", pbThis))
    else
      rr_pbFaint(showMessage)
    end
  end

  alias rr_pbCanLowerStatStage? pbCanLowerStatStage?
  def pbCanLowerStatStage?(*args)
    return false if fainted?
    user = args[1]
    if user && user.index == @index # Self Inflicted
      if hasActiveAbility?(:BADCOMPANY)
        if args[3]
          @battle.pbShowAbilitySplash(self)
          if Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!", pbThis, abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return true
      end
    end
    return rr_pbCanLowerStatStage?(*args)
  end
end