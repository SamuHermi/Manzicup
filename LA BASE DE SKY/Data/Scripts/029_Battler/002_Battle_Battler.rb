#===============================================================================
#
#===============================================================================
class Battle::Battler
  # Fundamental to this object
  attr_reader   :battle
  # The Pokémon and its properties
  attr_reader   :pokemon # Boolean to mark whether self has fainted properly   # Boolean to mark whether self was captured
  # Things the battler has done in battle
  attr_accessor :turnCount # For Instruct        # For Stomping Tantrum   # For Stomping Tantrum # ID of multi-turn move currently being used # Used for Emergency Exit/Wimp Out # Used for Emergency Exit/Wimp Out # Used for Eject Pack # Boolean for Focus Punch # Boolean for whether self took damage this round # Boolean for whether self's stat(s) raised this round # Boolean for whether self's stat(s) lowered this round # Whether Hail started in the round
  attr_accessor :pokemonIndex, :species, :types, :ability_id, :item_id, :moves, :attack, :spatk, :speed, :stages,
                :captured, :effects, :participants, :lastAttacker, :lastFoeAttacker, :lastHPLost, :lastHPLostFromFoe, :lastMoveUsed, :lastMoveUsedType, :lastRegularMoveUsed, :lastRegularMoveTarget, :lastRoundMoved, :lastMoveFailed, :lastRoundMoveFailed, :movesUsed, :currentMove, :droppedBelowHalfHP, :droppedBelowThirdHP, :statsDropped, :tookMoveDamageThisRound, :tookDamageThisRound, :tookPhysicalHit, :statsRaisedThisRound, :statsLoweredThisRound, :canRestoreIceFace, :damageState

  # These arrays should all have the same number of values in them
  STAT_STAGE_MULTIPLIERS    = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
  STAT_STAGE_DIVISORS       = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
  ACC_EVA_STAGE_MULTIPLIERS = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
  ACC_EVA_STAGE_DIVISORS    = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
  STAT_STAGE_MAXIMUM        = STAT_STAGE_MULTIPLIERS.length / 2 # 6, is also the minimum (-6)

  #-----------------------------------------------------------------------------
  # Complex accessors.
  #-----------------------------------------------------------------------------

  attr_reader :stagesChangeRecord, :totalhp, :fainted, :dummy, :level, :form, :hp, :status, :statusCount

  def level=(value)
    @level = value
    @pokemon.level = value if @pokemon
  end

  def form=(value)
    @form = value
    @pokemon.form = value if @pokemon && !@effects[PBEffects::Transform]
  end

  def ability
    GameData::Ability.try_get(@ability_id)
  end

  def ability=(value)
    new_ability = GameData::Ability.try_get(value)
    @ability_id = new_ability ? new_ability.id : nil
  end

  def item
    GameData::Item.try_get(@item_id)
  end

  def item=(value)
    new_item = GameData::Item.try_get(value)
    @item_id = new_item ? new_item.id : nil
    @pokemon.item = @item_id if @pokemon
  end

  def defense
    return @spdef if @battle.field.effects[PBEffects::WonderRoom] > 0

    @defense
  end

  attr_writer :defense, :spdef, :name

  def spdef
    return @defense if @battle.field.effects[PBEffects::WonderRoom] > 0

    @spdef
  end

  def hp=(value)
    @hp = value.to_i
    @pokemon.hp = value.to_i if @pokemon
  end

  def fainted?
    @hp <= 0
  end

  def status=(value)
    @effects[PBEffects::Truant] = false if @status == :SLEEP && value != :SLEEP
    @effects[PBEffects::Toxic]  = 0 if value != :POISON || statusCount == 0
    @status = value
    @pokemon.status = value if @pokemon
    self.statusCount = 0 if value != :POISON && value != :SLEEP
    @battle.scene.pbRefreshOne(@index)
  end

  def statusCount=(value)
    @statusCount = value
    @pokemon.statusCount = value if @pokemon
    @battle.scene.pbRefreshOne(@index)
  end

  #-----------------------------------------------------------------------------
  # Properties from Pokémon.
  #-----------------------------------------------------------------------------

  def happiness
    @pokemon ? @pokemon.happiness : 0
  end

  def affection_level
    @pokemon ? @pokemon.affection_level : 2
  end

  def gender
    @pokemon ? @pokemon.gender : 0
  end

  def nature
    @pokemon ? @pokemon.nature : nil
  end

  def pokerusStage
    @pokemon ? @pokemon.pokerusStage : 0
  end

  def isSpecies?(*check_species)
    @pokemon&.isSpecies?(*check_species)
  end

  #-----------------------------------------------------------------------------
  # Mega Evolution, Primal Reversion, Shadow Pokémon.
  #-----------------------------------------------------------------------------

  def hasMega?
    # Console.echo_li("hasMega? Battle_Battler\n")
    return false if @effects[PBEffects::Transform]

    @pokemon&.hasMegaForm?
  end

  def mega?
    @pokemon&.mega?
  end

  def hasPrimal?
    return false if @effects[PBEffects::Transform]

    @pokemon&.hasPrimalForm?
  end

  def hasManzi?
    return false if @effects[PBEffects::Transform]

    @pokemon&.hasManziForm?
  end

  def primal?
    @pokemon&.primal?
  end

  def manzi?
    @pokemon&.manzi?
  end

  def shadowPokemon?
    false
  end

  def inHyperMode?
    false
  end

  #-----------------------------------------------------------------------------
  # Display-only properties.
  #-----------------------------------------------------------------------------

  def name
    return @effects[PBEffects::Illusion].name if @effects[PBEffects::Illusion]

    @name
  end

  def displayPokemon
    return @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]

    pokemon
  end

  def displaySpecies
    return @effects[PBEffects::Illusion].species if @effects[PBEffects::Illusion]

    species
  end

  def displayGender
    return @effects[PBEffects::Illusion].gender if @effects[PBEffects::Illusion]

    gender
  end

  def displayForm
    return @effects[PBEffects::Illusion].form if @effects[PBEffects::Illusion]

    form
  end

  def shiny?
    return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]

    @pokemon&.shiny?
  end

  def super_shiny?
    @pokemon&.super_shiny?
  end

  def owned?
    return false unless @battle.wildBattle?

    $player.owned?(displaySpecies)
  end
  alias owned owned?

  def abilityName
    abil = ability
    abil ? abil.name : ''
  end

  def itemName
    itm = item
    itm ? itm.name : ''
  end

  def pbThis(lowerCase = false)
    if opposes?
      return lowerCase ? _INTL('el {1} rival', name) : _INTL('El {1} rival', name) if @battle.trainerBattle?

      return lowerCase ? _INTL('el {1} salvaje', name) : _INTL('El {1} salvaje', name)

    elsif !pbOwnedByPlayer?
      return lowerCase ? _INTL('el {1} aliado', name) : _INTL('El {1} aliado', name)
    end
    name
  end

  def pbTeam(lowerCase = false)
    if opposes?
      return lowerCase ? _INTL('el equipo rival') : _INTL('El equipo rival')
    end

    lowerCase ? _INTL('tu equipo') : _INTL('Tu equipo')
  end

  def pbOpposingTeam(lowerCase = false)
    if opposes?
      return lowerCase ? _INTL('tu equipo') : _INTL('Tu equipo')
    end

    lowerCase ? _INTL('el equipo rival') : _INTL('El equipo rival')
  end

  #-----------------------------------------------------------------------------
  # Calculated properties.
  #-----------------------------------------------------------------------------

  def plainStats
    ret = {}
    ret[:ATTACK]          = attack
    ret[:DEFENSE]         = defense
    ret[:SPECIAL_ATTACK]  = spatk
    ret[:SPECIAL_DEFENSE] = spdef
    ret[:SPEED]           = speed
    ret
  end

  def stat_with_stages(stat)
    stat_value = 0
    case stat
    when :ATTACK          then stat_value = attack
    when :DEFENSE         then stat_value = defense
    when :SPECIAL_ATTACK  then stat_value = spatk
    when :SPECIAL_DEFENSE then stat_value = spdef
    when :SPEED           then stat_value = speed
    else
      raise _INTL('No se puede obtener la estadística con etapas para {1}.', stat)
    end
    stage = @stages[stat] + STAT_STAGE_MAXIMUM
    (stat_value.to_f * STAT_STAGE_MULTIPLIERS[stage] / STAT_STAGE_DIVISORS[stage]).floor
  end

  def pbSpeed
    return 1 if fainted?

    speed = stat_with_stages(:SPEED)
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    speedMult = Battle::AbilityEffects.triggerSpeedCalc(ability, self, speedMult) if abilityActive?
    # Item effects that alter calculated Speed
    speedMult = Battle::ItemEffects.triggerSpeedCalc(item, self, speedMult) if itemActive?
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind] > 0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp] > 0
    # Paralysis
    if status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)
      speedMult /= Settings::MECHANICS_GENERATION >= 7 ? 2 : 4
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    [(speed * speedMult).round, 1].max
  end

  def pbWeight
    ret = @pokemon ? @pokemon.weight : 500
    ret += @effects[PBEffects::WeightChange]
    ret = 1 if ret < 1
    ret = Battle::AbilityEffects.triggerWeightCalc(ability, self, ret) if abilityActive? && !beingMoldBroken?
    ret = Battle::ItemEffects.triggerWeightCalc(item, self, ret) if itemActive?
    [ret, 1].max
  end

  #-----------------------------------------------------------------------------
  # Queries about what the battler has.
  #-----------------------------------------------------------------------------

  # Returns the active types of this Pokémon. The array should not include the
  # same type more than once, and should not include any invalid types.
  def pbTypes(withExtraType = false)
    ret = @types.uniq
    # Burn Up erases the Fire-type
    ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
    # Double Shock erases the Electric-type
    ret.delete(:ELECTRIC) if @effects[PBEffects::DoubleShock]
    # Roost erases the Flying-type (if there are no types left, adds the Normal-
    # type)
    if @effects[PBEffects::Roost]
      ret.delete(:FLYING)
      ret.push(:NORMAL) if ret.length == 0
    end
    # Add the third type specially
    if withExtraType && @effects[PBEffects::ExtraType] && !ret.include?(@effects[PBEffects::ExtraType])
      ret.push(@effects[PBEffects::ExtraType])
    end
    ret
  end

  def pbHasType?(type)
    return false unless type

    activeTypes = pbTypes(true)
    activeTypes.include?(GameData::Type.get(type).id)
  end

  def pbHasOtherType?(type)
    return false unless type

    activeTypes = pbTypes(true)
    activeTypes.delete(GameData::Type.get(type).id)
    activeTypes.length > 0
  end

  def canChangeType?
    !%i[MULTITYPE RKSSYSTEM].include?(@ability_id)
  end

  #-----------------------------------------------------------------------------
  # Ability.
  #-----------------------------------------------------------------------------

  # NOTE: Do not create any held item which affects whether a Pokémon's ability
  #       is active. The ability Klutz affects whether a Pokémon's item is
  #       active, and the code for the two combined would cause an infinite loop
  #       (regardless of whether any Pokémon actually has either the ability or
  #       the item - the code existing is enough to cause the loop).
  def abilityActive?(ignore_fainted = false, check_ability = nil)
    return false if fainted? && !ignore_fainted
    return false if @effects[PBEffects::GastroAcid]
    return false if check_ability != :NEUTRALIZINGGAS && ability != :NEUTRALIZINGGAS &&
                    @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)

    true
  end

  def hasActiveAbility?(check_ability, ignore_fainted = false)
    return false unless abilityActive?(ignore_fainted, check_ability)
    return check_ability.include?(@ability_id) if check_ability.is_a?(Array)

    ability == check_ability
  end
  alias hasWorkingAbility hasActiveAbility?
  alias has_active_ability? hasActiveAbility?

  # Returns whether the ability can be negated.
  def unstoppableAbility?(abil = nil)
    abil ||= @ability_id
    abil = GameData::Ability.try_get(abil)
    return false unless abil

    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      #      :EMBODYASPECTATTACK,                                # This can be negated
      #      :EMBODYASPECTDEFENSE,                               # This can be negated
      #      :EMBODYASPECTSPDEF,                                 # This can be negated
      #      :EMBODYASPECTSPEED,                                 # This can be negated
      #      :FLOWERGIFT,                                        # This can be negated
      #      :FORECAST,                                          # This can be negated
      :GULPMISSILE,
      #      :HUNGERSWITCH,                                      # This can be negated
      :ICEFACE,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :TERASHIFT,
      :ZENMODE,
      :ZEROTOHERO,
      # Abilities intended to be inherent properties of a certain species
      :ASONECHILLINGNEIGH,
      :ASONEGRIMNEIGH,
      :COMATOSE,
      #      :COMMANDER,                                         # This can be negated
      #      :POISONPUPPETEER,                                   # This can be negated
      #      :PROTOSYNTHESIS,                                    # This can be negated
      #      :QUARKDRIVE,                                        # This can be negated
      :RKSSYSTEM
      #      :TERAFORMZERO,                                      # This can be negated
      #      :TERASHELL,                                         # This can be negated
      #      :WONDERGUARD                                        # This can be negated
    ]
    ability_blacklist.delete(:ZENMODE) if Settings::MECHANICS_GENERATION <= 6
    return true if ability_blacklist.include?(abil.id)
    return true if hasActiveItem?(:ABILITYSHIELD)

    false
  end

  # Applies to losing self's ability (i.e. being replaced by another).
  def unlosableAbility?(abil = nil)
    abil ||= @ability_id
    abil = GameData::Ability.try_get(abil)
    return false unless abil

    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :EMBODYASPECTATTACK,
      :EMBODYASPECTDEFENSE,
      :EMBODYASPECTSPDEF,
      :EMBODYASPECTSPEED,
      #      :FLOWERGIFT,                                       # This can be replaced
      #      :FORECAST,                                         # This can be replaced
      :HUNGERSWITCH,
      :ICEFACE,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :TERASHIFT,
      :ZENMODE,
      :ZEROTOHERO,
      # Appearance-changing abilities
      :ILLUSION,
      #      :IMPOSTER,                                         # This can be replaced
      # Abilities intended to be inherent properties of a certain species
      :ASONECHILLINGNEIGH,
      :ASONEGRIMNEIGH,
      :COMATOSE,
      :COMMANDER,
      :POISONPUPPETEER,
      :PROTOSYNTHESIS,
      :QUARKDRIVE,
      :RKSSYSTEM,
      :TERAFORMZERO,
      :TERASHELL,
      :WONDERGUARD,
      # Abilities that can't be negated
      :NEUTRALIZINGGAS
    ]
    ability_blacklist.delete(:ZENMODE) if Settings::MECHANICS_GENERATION <= 6
    if Settings::MECHANICS_GENERATION <= 8
      ability_blacklist.delete(:HUNGERSWITCH)
      ability_blacklist.delete(:ILLUSION)
      ability_blacklist.delete(:NEUTRALIZINGGAS)
      ability_blacklist.push(:GULPMISSILE)
    end
    return true if ability_blacklist.include?(abil.id)
    return true if hasActiveItem?(:ABILITYSHIELD)

    false
  end

  # Applies to gaining the ability.
  def ungainableAbility?(abil = nil)
    abil ||= @ability_id
    abil = GameData::Ability.try_get(abil)
    return false unless abil

    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :EMBODYASPECTATTACK,
      :EMBODYASPECTDEFENSE,
      :EMBODYASPECTSPDEF,
      :EMBODYASPECTSPEED,
      :FLOWERGIFT,
      :FORECAST,
      :HUNGERSWITCH,
      :ICEFACE,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :TERASHIFT,
      :ZENMODE,
      :ZEROTOHERO,
      # Appearance-changing abilities
      :ILLUSION,
      :IMPOSTER,
      # Abilities intended to be inherent properties of a certain species
      :ASONECHILLINGNEIGH,
      :ASONEGRIMNEIGH,
      :COMATOSE,
      :COMMANDER,
      :POISONPUPPETEER,
      :PROTOSYNTHESIS,
      :QUARKDRIVE,
      :RKSSYSTEM,
      :TERAFORMZERO,
      :TERASHELL,
      :WONDERGUARD,
      # Abilities that replace themselves
      :POWEROFALCHEMY,
      :RECEIVER,
      :TRACE,
      # Abilities that can't be negated
      :NEUTRALIZINGGAS
    ]
    ability_blacklist.delete(:ZENMODE) if Settings::MECHANICS_GENERATION <= 6
    ability_blacklist.push(:GULPMISSILE) if Settings::MECHANICS_GENERATION <= 8
    ability_blacklist.include?(abil.id)
  end

  #-----------------------------------------------------------------------------
  # Held item.
  #-----------------------------------------------------------------------------

  def itemActive?(ignoreFainted = false)
    return false if fainted? && !ignoreFainted
    return false if @effects[PBEffects::Embargo] > 0
    return false if @battle.field.effects[PBEffects::MagicRoom] > 0
    return false if @battle.corrosiveGas[@index % 2][@pokemonIndex]
    return false if hasActiveAbility?(:KLUTZ, ignoreFainted)

    true
  end
  alias item_active? itemActive?

  def hasActiveItem?(check_item, ignore_fainted = false)
    return false unless itemActive?(ignore_fainted)
    return check_item.include?(@item_id) if check_item.is_a?(Array)

    item == check_item
  end
  alias hasWorkingItem hasActiveItem?

  # Returns whether the specified item will be unlosable for this Pokémon.
  def unlosableItem?(check_item)
    return false unless check_item

    item_data = GameData::Item.get(check_item)
    return false if @effects[PBEffects::Transform]

    # Items that change a Pokémon's form
    if mega? # Check if item was needed for this Mega Evolution
      return true if @pokemon.species_data.mega_stone == item_data.id
    else # Check if item could cause a Mega Evolution
      GameData::Species.each do |data|
        next if data.species != @species || data.unmega_form != @form
        return true if data.mega_stone == item_data.id
      end
    end
    # Other unlosable items
    item_data.unlosable?(@species, ability)
  end

  def initialItem
    @battle.initialItem(idxOwnSide, @pokemonIndex)
  end

  def knockOffItem
    @battle.knockOffItem(idxOwnSide, @pokemonIndex)
  end

  def recycleItem
    @battle.recycleItem(idxOwnSide, @pokemonIndex)
  end

  def setRecycleItem(value)
    item_data = GameData::Item.try_get(value)
    new_item = item_data ? item_data.id : nil
    @battle.setRecycleItem(idxOwnSide, @pokemonIndex, new_item)
  end

  #-----------------------------------------------------------------------------
  # Moves.
  #-----------------------------------------------------------------------------

  def eachMove(&block)
    @moves.each(&block)
  end

  def eachMoveWithIndex(&block)
    @moves.each_with_index(&block)
  end

  def pbHasMove?(move_id)
    return false unless move_id

    eachMove { |m| return true if m.id == move_id }
    false
  end

  def pbHasMoveType?(check_type)
    return false unless check_type

    check_type = GameData::Type.get(check_type).id
    eachMove { |m| return true if m.type == check_type }
    false
  end

  def pbHasMoveFunction?(*arg)
    return false unless arg

    eachMove do |m|
      arg.each { |code| return true if m.function_code == code }
    end
    false
  end

  def pbGetMoveWithID(move_id)
    return nil unless move_id

    eachMove { |m| return m if m.id == move_id }
    nil
  end

  #-----------------------------------------------------------------------------
  # Other properties.
  #-----------------------------------------------------------------------------

  def hasMoldBreaker?
    hasActiveAbility?(%i[MOLDBREAKER TERAVOLT TURBOBLAZE])
  end

  def beingMoldBroken?
    return false if hasActiveItem?(:ABILITYSHIELD)

    @battle.moldBreaker
  end

  def airborne?
    return false if hasActiveItem?(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pbHasType?(:FLYING)
    return true if hasActiveAbility?(%i[LEVITATE ORNITHES], true) && !@battle.moldBreaker
    return true if hasActiveItem?(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise] > 0
    return true if @effects[PBEffects::Telekinesis] > 0

    false
  end

  def affectedByAdditionalEffects?
    return false if hasActiveItem?(:COVERTCLOAK)

    true
  end

  def takesIndirectDamage?(showMsg = false)
    return false if fainted?

    if hasActiveAbility?(:MAGICGUARD)
      if showMsg
        @battle.pbShowAbilitySplash(self)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL('¡No afecta a {1}!', pbThis(true)))
        else
          @battle.pbDisplay(_INTL('¡No afecta a {1} gracias a {2}!', pbThis(true), abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      return false
    end
    true
  end

  def takesSandstormDamage?
    return false unless takesIndirectDamage?
    return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
    return false if inTwoTurnAttack?('TwoTurnAttackInvulnerableUnderground',
                                     'TwoTurnAttackInvulnerableUnderwater')
    return false if hasActiveAbility?(%i[OVERCOAT SANDFORCE SANDRUSH SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)

    true
  end

  def takesHailDamage?
    return false unless takesIndirectDamage?
    return false if pbHasType?(:ICE)
    return false if inTwoTurnAttack?('TwoTurnAttackInvulnerableUnderground',
                                     'TwoTurnAttackInvulnerableUnderwater')
    return false if hasActiveAbility?(%i[OVERCOAT ICEBODY SNOWCLOAK])
    return false if hasActiveItem?(:SAFETYGOGGLES)

    true
  end

  def takesShadowSkyDamage?
    return false unless takesIndirectDamage?
    return false if pbHasType?(:DARK) || pbHasType?(:GHOST)
    return false if inTwoTurnAttack?('TwoTurnAttackInvulnerableUnderground',
                                     'TwoTurnAttackInvulnerableUnderwater')
    return false if hasActiveItem?(:SAFETYGOGGLES)

    true
  end

  def effectiveWeather
    ret = @battle.pbWeather
    ret = :None if %i[Sun Rain HarshSun HeavyRain].include?(ret) && hasActiveItem?(:UTILITYUMBRELLA)
    ret
  end

  def affectedByTerrain?
    return false if airborne?
    return false if semiInvulnerable?

    true
  end

  def affectedByPowder?(showMsg = false)
    return false if fainted?

    if pbHasType?(:GRASS) && Settings::MORE_TYPE_EFFECTS
      @battle.pbDisplay(_INTL('¡No afecta a {1}!', pbThis(true))) if showMsg
      return false
    end
    if Settings::MECHANICS_GENERATION >= 6
      if hasActiveAbility?(:OVERCOAT) && !beingMoldBroken?
        if showMsg
          @battle.pbShowAbilitySplash(self)
          if Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL('¡No afecta a {1}!', pbThis(true)))
          else
            @battle.pbDisplay(_INTL('¡No afecta a {1} gracias a {2}!', pbThis(true), abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
      if hasActiveItem?(:SAFETYGOGGLES)
        @battle.pbDisplay(_INTL('¡No afecta a {1} gracia a su {2}!', pbThis(true), itemName)) if showMsg
        return false
      end
    end
    true
  end

  def canHeal?
    return false if fainted? || @hp >= @totalhp
    return false if @effects[PBEffects::HealBlock] > 0

    true
  end

  def affectedByContactEffect?(showMsg = false)
    return false if fainted?

    if hasActiveItem?(:PROTECTIVEPADS)
      @battle.pbDisplay(_INTL('¡{1} se ha protegido gracias a {2}!', pbThis, itemName)) if showMsg
      return false
    end
    true
  end

  def trappedInBattle?
    return true if @effects[PBEffects::Trapping] > 0
    return true if @effects[PBEffects::MeanLook] >= 0
    return true if @effects[PBEffects::JawLock] >= 0
    return true if @battle.allBattlers(true).any? { |b| b.effects[PBEffects::JawLock] == @index }
    return true if @effects[PBEffects::Octolock] >= 0
    return true if @effects[PBEffects::Ingrain]
    return true if @effects[PBEffects::NoRetreat]
    return true if @battle.field.effects[PBEffects::FairyLock] > 0

    false
  end

  # Returns whether this battler can be made to switch out because of another
  # battler's move.
  def canBeForcedOutOfBattle?(show_message = true)
    if @effects[PBEffects::Commanding] >= 0 || @effects[PBEffects::CommandedBy] >= 0
      @battle.pbDisplay(_INTL('¡Pero falló!'))
      return false
    end
    if hasActiveAbility?(:SUCTIONCUPS) && !beingMoldBroken?
      if show_message
        @battle.pbShowAbilitySplash(self)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL('{1} se ancla!', pbThis))
        else
          @battle.pbDisplay(_INTL('{1} se ancla con {2}!', pbThis, abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      return false
    end
    return false if hasActiveAbility?(:GUARDDOG) && !beingMoldBroken?

    if @effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL('{1} se ancla con sus raíces!', pbThis)) if show_message
      return false
    end
    true
  end

  def movedThisRound?
    @lastRoundMoved && @lastRoundMoved == @battle.turnCount
  end

  def usingMultiTurnAttack?
    return true if @effects[PBEffects::TwoTurnAttack]
    return true if @effects[PBEffects::HyperBeam] > 0
    return true if @effects[PBEffects::Rollout] > 0
    return true if @effects[PBEffects::Outrage] > 0
    return true if @effects[PBEffects::Uproar] > 0
    return true if @effects[PBEffects::Bide] > 0

    false
  end

  def inTwoTurnAttack?(*arg)
    return false unless @effects[PBEffects::TwoTurnAttack]

    ttaFunction = GameData::Move.get(@effects[PBEffects::TwoTurnAttack]).function_code
    arg.each { |a| return true if a == ttaFunction }
    false
  end

  def semiInvulnerable?
    inTwoTurnAttack?('TwoTurnAttackInvulnerableInSky',
                     'TwoTurnAttackInvulnerableUnderground',
                     'TwoTurnAttackInvulnerableUnderwater',
                     'TwoTurnAttackInvulnerableInSkyParalyzeTarget',
                     'TwoTurnAttackInvulnerableRemoveProtections',
                     'TwoTurnAttackInvulnerableInSkyTargetCannotAct')
  end

  def pbEncoredMoveIndex
    return -1 if @effects[PBEffects::Encore] == 0 || !@effects[PBEffects::EncoreMove]

    ret = -1
    eachMoveWithIndex do |m, i|
      next if m.id != @effects[PBEffects::EncoreMove]

      ret = i
      break
    end
    ret
  end

  def belched?
    @battle.belch[@index & 1][@pokemonIndex]
  end

  def setBelched
    @battle.belch[@index & 1][@pokemonIndex] = true
  end

  #-----------------------------------------------------------------------------
  # Methods relating to this battler's position on the battlefield.
  #-----------------------------------------------------------------------------
  # Returns whether the given position belongs to the opposing Pokémon's side.
  def opposes?(i = 0)
    i = i.index if i.respond_to?('index')
    (@index & 1) != (i & 1)
  end

  # Returns whether the given position/battler is near to self.
  def near?(i)
    i = i.index if i.respond_to?('index')
    @battle.nearBattlers?(@index, i)
  end

  # Returns whether self is owned by the player.
  def pbOwnedByPlayer?
    @battle.pbOwnedByPlayer?(@index)
  end

  def wild?
    @battle.wildBattle? && opposes?
  end

  # Returns 0 if self is on the player's side, or 1 if self is on the opposing
  # side.
  def idxOwnSide
    @index & 1
  end

  # Returns 1 if self is on the player's side, or 0 if self is on the opposing
  # side.
  def idxOpposingSide
    (@index & 1) ^ 1
  end

  # Returns the data structure for this battler's side.
  def pbOwnSide
    @battle.sides[idxOwnSide]
  end

  # Returns the data structure for the opposing Pokémon's side.
  def pbOpposingSide
    @battle.sides[idxOpposingSide]
  end

  # Returns an array containing all unfainted ally Pokémon.
  def allAllies(with_commanders = false)
    @battle.allSameSideBattlers(@index, with_commanders).reject { |b| b.index == @index }
  end

  # Yields each unfainted ally Pokémon.
  # Unused
  def eachAlly(with_commanders = false, &block)
    allAllies(with_commanders).each(&block)
  end

  # Returns an array containing all unfainted opposing Pokémon.
  def allOpposing(with_commanders = false)
    @battle.allOtherSideBattlers(@index, with_commanders)
  end

  # Yields each unfainted opposing Pokémon.
  # Unused
  def eachOpposing(with_commanders = false, &block)
    allOpposing(with_commanders).each(&block)
  end

  # Returns the battler that is most directly opposite to self. unfaintedOnly is
  # whether it should prefer to return a non-fainted battler.
  def pbDirectOpposing(unfaintedOnly = false)
    @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
      next unless @battle.battlers[i]
      break if unfaintedOnly && @battle.battlers[i].fainted?

      return @battle.battlers[i]
    end
    # Wanted an unfainted battler but couldn't find one; make do with a fainted
    # battler
    @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
      return @battle.battlers[i] if @battle.battlers[i]
    end
    @battle.battlers[(@index ^ 1)]
  end

  def pbGetJudgmentType(check_type = nil)
    if pbOwnedByPlayer? && hasLegendPlateJudgment?
      target = nil
      @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
        battler = @battle.battlers[i]
        next if !battler || battler.fainted? || battler.isCommander?

        target = battler
        break
      end
      return @battle.pbGetBestTypeJudgment(self, target, nil, check_type) || :NORMAL
    end
    :NORMAL
  end

  #-----------------------------------------------------------------------------
  # Used to simplify checking for a valid Pokemon using the Legend Plate.
  #-----------------------------------------------------------------------------
  def hasLegendPlateJudgment?
    isSpecies?(:ARCEUS) &&
      hasActiveAbility?(:MULTITYPE) &&
      hasActiveItem?(:LEGENDPLATE) &&
      pbHasMove?(:JUDGMENT)
  end
end
