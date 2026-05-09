#===============================================================================
#
#===============================================================================
class Battle::Move
  attr_writer :total_pp
  attr_reader :battle, :realMove, :name, :function_code, :power, :type, :category, :accuracy, :addlEffect, :target,
              :priority, :flags
  attr_accessor :id, :pp, :calcType, :powerBoost, :snatched

  CRITICAL_HIT_RATIOS = Settings::NEW_CRITICAL_HIT_RATE_MECHANICS ? [24, 8, 2, 1] : [16, 8, 4, 3, 2]

  def to_int
    @id
  end

  # @deprecated This method is slated to be removed in v22.
  def baseDamage
    Deprecation.warn_method('baseDamage', 'v22', 'power')
    @power
  end

  #=============================================================================
  # Creating a move
  #=============================================================================
  def initialize(battle, move)
    @battle        = battle
    @realMove      = move
    @id            = move.id
    @name          = move.name # Get the move's name
    # Get data on the move
    @function_code = move.function_code
    @power         = move.power
    @type          = move.type
    @category      = move.category
    @accuracy      = move.accuracy
    @pp            = move.pp # Can be changed with Mimic/Transform
    @target        = move.target
    @priority      = move.priority
    @flags         = move.flags.clone
    @addlEffect    = move.effect_chance
    @powerBoost    = false # For Aerilate, Pixilate, Refrigerate, Galvanize
    @snatched      = false
  end

  # This is the code actually used to generate a Battle::Move object. The
  # object generated is a subclass of this one which depends on the move's
  # function code.
  def self.from_pokemon_move(battle, move)
    validate move => Pokemon::Move
    code = move.function_code || 'None'
    class_name = if code[/^\d/] # Begins with a digit
                   format('Battle::Move::Effect%s', code)
                 else
                   format('Battle::Move::%s', code)
                 end
    return Object.const_get(class_name).new(battle, move) if Object.const_defined?(class_name)

    Battle::Move::Unimplemented.new(battle, move)
  end

  #-----------------------------------------------------------------------------
  # About the move.
  #-----------------------------------------------------------------------------

  def pbTarget(_user)
    GameData::Target.get(@target)
  end

  def total_pp
    return @total_pp if @total_pp && @total_pp > 0 # Usually undefined
    return @realMove.total_pp if @realMove

    0
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def physicalMove?(thisType = nil)
    return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE

    thisType ||= @calcType
    thisType ||= @type
    return true unless thisType

    GameData::Type.get(thisType).physical?
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def specialMove?(thisType = nil)
    return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE

    thisType ||= @calcType
    thisType ||= @type
    return false unless thisType

    GameData::Type.get(thisType).special?
  end

  def damagingMove?
    @category != 2
  end

  def statusMove?
    @category == 2
  end

  def pbPriority(user)
    @priority
  end

  def usableWhenAsleep?
    false
  end

  def unusableInGravity?
    false
  end

  def healingMove?
    false
  end

  def recoilMove?
    false
  end

  def flinchingMove?
    false
  end

  def callsAnotherMove?
    false
  end

  # Whether the move can/will hit more than once in the same turn (including
  # Beat Up which may instead hit just once). Not the same as pbNumHits>1.
  def multiHitMove?
    false
  end

  def chargingTurnMove?
    false
  end

  def successCheckPerHit?
    false
  end

  def hitsFlyingTargets?
    false
  end

  def hitsDiggingTargets?
    false
  end

  def hitsDivingTargets?
    false
  end

  # For Brick Break
  def ignoresReflect?
    false
  end

  # For Future Sight/Doom Desire
  def targetsPosition?
    false
  end

  # For Snipe Shot
  def cannotRedirect?
    false
  end

  # For Explosion
  def worksWithNoTargets?
    false
  end

  # For Facade
  def damageReducedByBurn?
    true
  end

  def triggersHyperMode?
    false
  end

  def canSnatch?
    false
  end

  def canMagicCoat?
    false
  end

  # Shield Dust doesn't stop it if true
  def additionalEffectAffectsUser?
    false
  end

  def contactMove?
    @flags.any? { |f| f[/^Contact$/i] }
  end

  def canProtectAgainst?
    @flags.any? { |f| f[/^CanProtect$/i] }
  end

  def canMirrorMove?
    @flags.any? { |f| f[/^CanMirrorMove$/i] }
  end

  def thawsUser?
    @flags.any? { |f| f[/^ThawsUser$/i] }
  end

  def highCriticalRate?
    @flags.any? { |f| f[/^HighCriticalHitRate$/i] }
  end

  def bitingMove?
    @flags.any? { |f| f[/^Biting$/i] }
  end

  def punchingMove?
    @flags.any? { |f| f[/^Punching$/i] }
  end

  def kickingMove?
    @flags.any? { |f| f[/^Kicking$/i] }
  end

  def soundMove?
    @flags.any? { |f| f[/^Sound$/i] }
  end

  def powderMove?
    @flags.any? { |f| f[/^Powder$/i] }
  end

  def pulseMove?
    @flags.any? { |f| f[/^Pulse$/i] }
  end

  def bombMove?
    @flags.any? { |f| f[/^Bomb$/i] }
  end

  def danceMove?
    @flags.any? { |f| f[/^Dance$/i] }
  end

  # Causes perfect accuracy and double damage if target used Minimize. Perfect accuracy only with Gen 6+ mechanics.
  def tramplesMinimize?
    @flags.any? { |f| f[/^TramplesMinimize$/i] }
  end

  #-----------------------------------------------------------------------------
  # New move flags.
  #-----------------------------------------------------------------------------
  def windMove?
    @flags.any? { |f| f[/^Wind$/i] }
  end

  def slicingMove?
    @flags.any? { |f| f[/^Slicing$/i] }
  end

  def fieldMove?
    @flags.any? { |f| f[/^Field$/i] }
  end

  def electrocuteUser?
    @flags.any? { |f| f[/^ElectrocuteUser$/i] }
  end

  def kickingMove?
    @flags.any? { |f| f[/^Kicking$/i] }
  end

  # For False Swipe
  def nonLethal?(_user, _target)
    false
  end

  # For Bug Bite/Pluck
  def preventsBattlerConsumingHealingBerry?(battler, targets)
    false
  end

  # user is the Pokémon using this move.
  def ignoresSubstitute?(user)
    if Settings::MECHANICS_GENERATION >= 6
      return true if soundMove?
      return true if user&.hasActiveAbility?(:INFILTRATOR)
    end
    false
  end

  def type_ui_modifiers(battler)
    #
    return pbHiddenPower(battler.pokemon)[0] if @realMove.id == :HIDDENPOWER
    if @realMove.display_type(battler.pokemon) == :NORMAL and battler.ability == :PIXILATE # check if battler has ability
      return :FAIRY # type to return
    end
    if @realMove.display_type(battler.pokemon) == :NORMAL and battler.ability == :AERILATE # check if battler has ability
      return :FLYING # type to return
    end
    if @realMove.display_type(battler.pokemon) == :NORMAL and battler.ability == :REFRIGERATE # check if battler has ability
      return :ICE # type to return
    end
    if battler.ability == :NORMALIZE # check if battler has ability
      return :NORMAL # type to return
    end

    move_data = GameData::Move.get(@realMove.id)
    return battler.types[0] if move_data.has_flag?('TypeIsUserFirstType')
    return battler.types[1] if move_data.has_flag?('TypeIsUserSecondType')
    return unless soundMove? && battler.ability == :LIQUIDVOICE # from smellyski

    :WATER
  end

  def display_type(battler)
    case @function_code
    when 'TypeDependsOnUserMorpekoFormRaiseUserSpeed1'
      if battler.isSpecies?(:MORPEKO) || battler.effects[PBEffects::TransformSpecies] == :MORPEKO
        return pbBaseType(battler)
      end
    when 'TypeDependsOnUserPlate', 'TypeDependsOnUserMemory',
         'TypeDependsOnUserDrive', 'TypeAndPowerDependOnUserBerry',
         'TypeIsUserFirstType', 'TypeAndPowerDependOnWeather',
         'TypeAndPowerDependOnTerrain',
         'TypeIsUserSecondType',              # Ivy Cudgel
         'TypeIsUserSecondTypeRemoveScreens'  # Raging Bull
      return pbBaseType(battler) if Settings::SHOW_MODIFIED_MOVE_PROPERTIES
    end
    if type_ui_modifiers(battler)
      return type_ui_modifiers(battler) # get new type if there is one
    end

    @realMove.display_type(battler.pokemon)
  end

  def display_power(battler)
    if Settings::SHOW_MODIFIED_MOVE_PROPERTIES
      case @function_code
      when 'TypeAndPowerDependOnUserBerry'
        return pbNaturalGiftBaseDamage(battler.item_id)
      when 'TypeAndPowerDependOnWeather', 'TypeAndPowerDependOnTerrain',
           'PowerHigherWithUserHP', 'PowerLowerWithUserHP',
           'PowerHigherWithUserHappiness', 'PowerLowerWithUserHappiness',
           'PowerHigherWithUserPositiveStatStages', 'PowerDependsOnUserStockpile',
           'PowerHigherWithTimesHit', 'PowerHigherWithFaintedAllies',
           'IncreasePowerInElectricTerrain', 'DoublePowerIfUserPoisonedBurnedParalyzed',
           'DoublePowerIfUserHasNoItem', 'DoublePowerIfUserLastMoveFailed',
           'DoublePowerIfAllyFaintedLastTurn'
        return pbBasePower(@power, battler, nil)
      end
    end
    @realMove.display_power(battler.pokemon)
  end

  def display_category(battler)
    if Settings::SHOW_MODIFIED_MOVE_PROPERTIES
      case @function_code
      when 'CategoryDependsOnHigherDamageIgnoreTargetAbility'
        pbOnStartUse(user, nil)
        return @calcCategory
      end
    end
    @realMove.display_category(battler.pokemon)
  end

  def display_accuracy(battler)
    @realMove.display_accuracy(battler.pokemon)
  end
end
