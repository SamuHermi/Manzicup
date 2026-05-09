#===============================================================================
# CanUseInBattle handlers
#===============================================================================
ItemHandlers::CanUseInBattle.add(:GUARDSPEC, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.pbOwnSide.effects[PBEffects::Mist] > 0
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEDOLL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  unless battle.wildBattle?
    scene.pbDisplay(_INTL('Mejor no usarlo ahora... ¡Cada cosa en su momento!')) if showMessages
    next false
  end
  unless battle.canRun
    scene.pbDisplay(_INTL('¡No puedes huir!')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:CASTELIACONE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if %i[Sun HarshSun].include?(battle.pbWeather) && showMessages && showMessages
    scene.pbDisplay(_INTL('No hace tanto calor como para comerse un helado...'))
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::CanUseInBattle.addIf(:poke_balls,
                                   proc { |item| GameData::Item.get(item).is_poke_ball? },
                                   proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
                                     if battle.pbPlayer.party_full? && $PokemonStorage.full?
                                       scene.pbDisplay(_INTL('¡No queda espacio en el PC!')) if showMessages
                                       next false
                                     end
                                     if battle.rules[:disable_poke_balls]
                                       scene.pbDisplay(_INTL('¡No puedes lanzar una Poké Ball!')) if showMessages
                                       next false
                                     end
                                     # NOTE: Using a Poké Ball consumes all your actions for the round. The code
                                     #       below is one half of making this happen; the other half is in def
                                     #       pbItemUsesAllActions?.
                                     unless firstAction
                                       if showMessages
                                         scene.pbDisplay(_INTL('¡Es imposible apuntar sin estar concentrado!'))
                                       end
                                       next false
                                     end
                                     if battler.semiInvulnerable? || battler.effects[PBEffects::Commanding] >= 0
                                       if showMessages
                                         scene.pbDisplay(_INTL('¡No se puede apuntar a un Pokémon que no tienes delante!'))
                                       end
                                       next false
                                     end
                                     if battler.effects[PBEffects::CommandedBy] >= 0
                                       if showMessages
                                         scene.pbDisplay(_INTL('¡Es imposible apuntar cuando hay más de un Pokémon!'))
                                       end
                                       next false
                                     end
                                     # NOTE: The code below stops you from throwing a Poké Ball if there is more
                                     #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
                                     #       this case, but only in trainer battles, and the trainer will deflect
                                     #       them if they are trying to catch a non-Shadow Pokémon.)
                                     if battle.pbOpposingBattlerCount(0, true) > 1 &&
                                       !(GameData::Item.get(item).is_snag_ball? && battle.trainerBattle?)
                                       if battle.pbOpposingBattlerCount == 2
                                         if showMessages
                                           scene.pbDisplay(_INTL('¡Es imposible apuntar cuando hay dos Pokémon!'))
                                         end
                                       elsif showMessages
                                         scene.pbDisplay(_INTL('¡Es imposible apuntar cuando hay más de un Pokémon!'))
                                       end
                                       next false
                                     end
                                     next true
                                   })

ItemHandlers::CanUseInBattle.add(:POTION, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? || pokemon.hp == pokemon.totalhp
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POTION,
                                  :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
                                  :BERRYJUICE, :SWEETHEART, :FRESHWATER, :SODAPOP,
                                  :LEMONADE, :MOOMOOMILK, :ORANBERRY, :SITRUSBERRY,
                                  :ENERGYPOWDER, :ENERGYROOT)

ItemHandlers::CanUseInBattle.add(:AWAKENING, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:AWAKENING, :CHESTOBERRY)

ItemHandlers::CanUseInBattle.add(:BLUEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battler&.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.add(:ANTIDOTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:POISON, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::CanUseInBattle.add(:BURNHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:BURN, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::CanUseInBattle.add(:PARALYZEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:PARALYSIS, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::CanUseInBattle.add(:ICEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:FROZEN, pokemon, scene, showMessages) ||
       pbBattleItemCanCureStatus?(:FROSTBITE, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::CanUseInBattle.add(:FULLHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? ||
     (pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:FULLHEAL,
                                  :LUMBERRY, :HEALPOWDER)

ItemHandlers::CanUseInBattle.add(:FULLRESTORE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? ||
     (pokemon.hp == pokemon.totalhp && pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion] == 0))
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:REVIVE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  unless pokemon.fainted?
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:REVIVE, :MAXREVIVE, :REVIVALHERB, :MAXHONEY)

ItemHandlers::CanUseInBattle.add(:ETHER, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? || move < 0 ||
     pokemon.moves[move].total_pp <= 0 ||
     pokemon.moves[move].pp == pokemon.moves[move].total_pp
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ETHER, :MAXETHER, :LEPPABERRY)

ItemHandlers::CanUseInBattle.add(:ELIXIR, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  unless pokemon.able?
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  canRestore = false
  pokemon.moves.each do |m|
    next if m.id == 0
    next if m.total_pp <= 0 || m.pp == m.total_pp

    canRestore = true
    break
  end
  unless canRestore
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ELIXIR, :MAXELIXIR)

ItemHandlers::CanUseInBattle.add(:REDFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Attract] < 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:PERSIMBERRY, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:YELLOWFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.effects[PBEffects::Confusion] == 0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:XATTACK, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:ATTACK, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6)

ItemHandlers::CanUseInBattle.add(:XDEFENSE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:DEFENSE, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XDEFENSE,
                                  :XDEFENSE2, :XDEFENSE3, :XDEFENSE6,
                                  :XDEFEND, :XDEFEND2, :XDEFEND3, :XDEFEND6)

ItemHandlers::CanUseInBattle.add(:XSPATK, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPATK,
                                  :XSPATK2, :XSPATK3, :XSPATK6,
                                  :XSPECIAL, :XSPECIAL2, :XSPECIAL3, :XSPECIAL6)

ItemHandlers::CanUseInBattle.add(:XSPDEF, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6)

ItemHandlers::CanUseInBattle.add(:XSPEED, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:SPEED, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPEED, :XSPEED2, :XSPEED3, :XSPEED6)

ItemHandlers::CanUseInBattle.add(:XACCURACY, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanRaiseStat?(:ACCURACY, battler, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6)

ItemHandlers::CanUseInBattle.add(:MAXMUSHROOMS, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pbBattleItemCanRaiseStat?(:ATTACK, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:DEFENSE, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE, battler, scene, false) &&
     !pbBattleItemCanRaiseStat?(:SPEED, battler, scene, false)
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.criticalHitRate >= 2
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT2, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.criticalHitRate >= 2
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT3, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !battler || battler.criticalHitRate >= 3
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battle.allBattlers.none? { |b| b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF) }
    scene.pbDisplay(_INTL('No tendría ningún efecto.')) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:SANDWICH, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  target = battler.pbDirectOpposing
  bestType = battle.pbGetBestTypeJudgment(battler, target, nil, nil) || :NORMAL
  next true if battler.canChangeType? && GameData::Type.exists?(bestType) && battler.pbHasOtherType?(bestType)

  next false
})

#===============================================================================
# UseInBattle handlers.
# For items used directly or on an opposing battler.
#===============================================================================

ItemHandlers::UseInBattle.add(:GUARDSPEC, proc { |item, battler, battle|
  battler.pbOwnSide.effects[PBEffects::Mist] = 5
  battle.pbDisplay(_INTL('¡{1} se ha envuelto en niebla!', battler.pbTeam))
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = Battle::Outcome::FLEE
  battle.pbDisplayPaused(_INTL('¡Escapaste sin problemas!'))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL, :FLUFFYTAIL, :POKETOY)

ItemHandlers::UseInBattle.add(:POKEFLUTE, proc { |item, battler, battle|
  battle.allBattlers.each do |b|
    b.pbCureStatus(false) if b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF)
  end
  battle.pbDisplay(_INTL('¡Todos los Pokémon se despertaron con la melodía!'))
})

ItemHandlers::UseInBattle.addIf(:poke_balls,
                                proc { |item| GameData::Item.get(item).is_poke_ball? },
                                proc { |item, battler, battle|
                                  battle.pbThrowPokeBall(battler.index, item)
                                })

ItemHandlers::UseInBattle.add(:FOULPOKEPUFF, proc { |item, battler, battle|
  battle.pbAnimation(:BITE, battler, battler)
  battle.pbAnimation(:TEARFULLOOK, battler, battler)
  battler.pbLowerStatStage(:ATTACK, 1, battler)
  battler.pbLowerStatStage(:DEFENSE, 1, battler)
  battler.pbLowerStatStage(:SPECIAL_ATTACK, 1, battler)
  battler.pbLowerStatStage(:SPECIAL_DEFENSE, 1, battler)
  battler.pbLowerStatStage(:SPEED, 1, battler)
})

#===============================================================================
# BattleUseOnPokemon handlers.
# For items used on Pokémon or on a Pokémon's move.
#===============================================================================

ItemHandlers::BattleUseOnPokemon.add(:POTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 20, scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:POTION, :BERRYJUICE, :SWEETHEART)

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 60 : 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 120 : 200, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp - pokemon.hp, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 30 : 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 50 : 60, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 70 : 80, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 10, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp / 4, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se despertó.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING, :CHESTOBERRY, :BLUEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se curó del envenenamiento.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE, :PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se curó de la quemadura.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL, :RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARALYZEHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se curó de la parálisis.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se ha descongelado.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se curó.', name))
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL, :LUMBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = battler ? battler.pbThis : pokemon.name
  if pokemon.hp < pokemon.totalhp
    pbBattleHPItem(pokemon, battler, pokemon.totalhp, scene)
  else
    scene.pbRefresh
    scene.pbDisplay(_INTL('{1} se curó.', name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE, proc { |item, pokemon, battler, choices, scene|
  pokemon.hp = pokemon.totalhp / 2
  pokemon.hp = 1 if pokemon.hp <= 0
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL('¡{1} ya no está debilitado!', pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_HP
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL('¡{1} ya no está debilitado!', pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.copy(:MAXREVIVE, :MAXHONEY)

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER, proc { |item, pokemon, battler, choices, scene|
  if pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 60 : 50, scene)
    pokemon.changeHappiness('powder')
  end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT, proc { |item, pokemon, battler, choices, scene|
  if pbBattleHPItem(pokemon, battler, Settings::REBALANCED_HEALING_ITEM_AMOUNTS ? 120 : 200, scene)
    pokemon.changeHappiness('energyroot')
  end
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  pokemon.changeHappiness('powder')
  name = battler ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL('{1} se curó.', name))
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_HP
  pokemon.heal_status
  pokemon.changeHappiness('revivalherb')
  scene.pbRefresh
  scene.pbDisplay(_INTL('¡{1} ya no está debilitado!', pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER, proc { |item, pokemon, battler, choices, scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, 10)
  pbSEPlay('Use item in party')
  scene.pbDisplay(_INTL('Ha recuperado sus PP.'))
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER, :LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER, proc { |item, pokemon, battler, choices, scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon, battler, idxMove, pokemon.moves[idxMove].total_pp)
  pbSEPlay('Use item in party')
  scene.pbDisplay(_INTL('Ha recuperado sus PP.'))
})

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR, proc { |item, pokemon, battler, choices, scene|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, 10)
  end
  pbSEPlay('Use item in party')
  scene.pbDisplay(_INTL('Ha recuperado sus PP.'))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR, proc { |item, pokemon, battler, choices, scene|
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, pokemon.moves[i].total_pp)
  end
  pbSEPlay('Use item in party')
  scene.pbDisplay(_INTL('Ha recuperado sus PP.'))
})

#===============================================================================
# BattleUseOnBattler handlers.
# For items used on a Pokémon in battle.
#===============================================================================

ItemHandlers::BattleUsableOnBattler.add(:REDFLUTE, proc { |item, battler|
  next battler.effects[PBEffects::Attract] >= 0
})
ItemHandlers::BattleUseOnBattler.add(:REDFLUTE, proc { |item, battler, scene|
  battler.pbCureAttract
  scene.pbDisplay(_INTL('{1} se libró del enamoramiento.', battler.pbThis))
})

ItemHandlers::BattleUsableOnBattler.add(:YELLOWFLUTE, proc { |item, battler|
  next battler.effects[PBEffects::Confusion] > 0
})
ItemHandlers::BattleUseOnBattler.add(:YELLOWFLUTE, proc { |item, battler, scene|
  battler.pbCureConfusion
  scene.pbDisplay(_INTL('{1} ya no está confuso.', battler.pbThis))
})

ItemHandlers::BattleUsableOnBattler.copy(:YELLOWFLUTE, :PERSIMBERRY)
ItemHandlers::BattleUseOnBattler.copy(:YELLOWFLUTE, :PERSIMBERRY)

ItemHandlers::BattleUsableOnBattler.add(:XATTACK, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:ATTACK, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XATTACK, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6)
ItemHandlers::BattleUseOnBattler.add(:XATTACK2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:XDEFENSE, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:DEFENSE, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XDEFENSE, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XDEFENSE, :XDEFEND)
ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE, :XDEFEND)

ItemHandlers::BattleUsableOnBattler.copy(:XDEFENSE, :XDEFENSE2, :XDEFEND2, :XDEFENSE3, :XDEFEND3, :XDEFENSE6, :XDEFEND6)
ItemHandlers::BattleUseOnBattler.add(:XDEFENSE2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE2, :XDEFEND2)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE3, :XDEFEND3)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE6, :XDEFEND6)

ItemHandlers::BattleUsableOnBattler.add(:XSPATK, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPATK, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPATK, :XSPECIAL)
ItemHandlers::BattleUseOnBattler.copy(:XSPATK, :XSPECIAL)

ItemHandlers::BattleUsableOnBattler.copy(:XSPATK, :XSPATK2, :XSPECIAL2, :XSPATK3, :XSPECIAL3, :XSPATK6, :XSPECIAL6)
ItemHandlers::BattleUseOnBattler.add(:XSPATK2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK2, :XSPECIAL2)

ItemHandlers::BattleUseOnBattler.add(:XSPATK3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK3, :XSPECIAL3)

ItemHandlers::BattleUseOnBattler.add(:XSPATK6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK6, :XSPECIAL6)

ItemHandlers::BattleUsableOnBattler.add(:XSPDEF, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPDEF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6)
ItemHandlers::BattleUseOnBattler.add(:XSPDEF2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:XSPEED, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:SPEED, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XSPEED, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XSPEED, :XSPEED2, :XSPEED3, :XSPEED6)
ItemHandlers::BattleUseOnBattler.add(:XSPEED2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:XACCURACY, proc { |item, battler|
  next battler.pbCanRaiseStatStage?(:ACCURACY, battler)
})
ItemHandlers::BattleUseOnBattler.add(:XACCURACY, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES ? 2 : 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.copy(:XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6)
ItemHandlers::BattleUseOnBattler.add(:XACCURACY2, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 2, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 3, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ACCURACY, 6, battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:MAXMUSHROOMS, proc { |item, battler|
  can_raise = false
  GameData::Stat.each_main_battle do |stat|
    can_raise = true if battler.pbCanRaiseStatStage?(stat.id, battler)
    break if can_raise
  end
  next can_raise
})
ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS, proc { |item, battler, scene|
  show_anim = true
  GameData::Stat.each_main_battle do |stat|
    next unless battler.pbCanRaiseStatStage?(stat.id, battler)

    battler.pbRaiseStatStage(stat.id, 1, battler, show_anim)
    show_anim = false
  end
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT, proc { |item, battler|
  next battler.criticalHitRate < 2
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT, proc { |item, battler, scene|
  battler.setCriticalHitRate(2)
  scene.pbCommonAnimation('CriticalHitRateUp', battler)
  scene.pbDisplay(_INTL('¡{1} se está preparando para luchar!', battler.pbThis))
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT2, proc { |item, battler|
  next battler.criticalHitRate < 2
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT2, proc { |item, battler, scene|
  battler.setCriticalHitRate(2)
  scene.pbCommonAnimation('CriticalHitRateUp', battler)
  scene.pbDisplay(_INTL('¡{1} se está preparando para luchar!', battler.pbThis))
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUsableOnBattler.add(:DIREHIT3, proc { |item, battler|
  next battler.criticalHitRate < 3
})
ItemHandlers::BattleUseOnBattler.add(:DIREHIT3, proc { |item, battler, scene|
  battler.effects[PBEffects::FocusEnergy] = 3
  scene.pbDisplay(_INTL('¡{1} se está preparando para luchar!', battler.pbThis))
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:SPICYDRYPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 1, battler)
  battler.pbRaiseStatStage(:SPEED, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SPICYDRYPOKEPUFF, :DRYSPICYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SPICYBITTERPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 1, battler)
  battler.pbRaiseStatStage(:DEFENSE, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SPICYBITTERPOKEPUFF, :BITTERSPICYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SPICYSWEETPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 1, battler)
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SPICYSWEETPOKEPUFF, :SWEETSPICYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SPICYSOURPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:ATTACK, 1, battler)
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SPICYSOURPOKEPUFF, :SOURSPICYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SOURDRYPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
  battler.pbRaiseStatStage(:SPEED, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SOURDRYPOKEPUFF, :DRYSOURPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SOURBITTERPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
  battler.pbRaiseStatStage(:DEFENSE, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SOURBITTERPOKEPUFF, :BITTERSOURPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:SOURSWEETPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:SOURSWEETPOKEPUFF, :SWEETSOURPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:DRYBITTERPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 1, battler)
  battler.pbRaiseStatStage(:DEFENSE, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:DRYBITTERPOKEPUFF, :BITTERDRYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:DRYSWEETPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:SPEED, 1, battler)
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:DRYSWEETPOKEPUFF, :SWEETDRYPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:BITTERSWEETPOKEPUFF, proc { |item, battler, scene|
  battler.pbRaiseStatStage(:DEFENSE, 1, battler)
  battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
  battler.pokemon.changeHappiness('battleitem')
})
ItemHandlers::BattleUseOnBattler.copy(:BITTERSWEETPOKEPUFF, :SWEETBITTERPOKEPUFF)

ItemHandlers::BattleUseOnBattler.add(:RAGECANDYBAR, proc { |item, battler, scene|
  battler.effects[PBEffects::Rage] = true
  battler.ability = :BERSERK
  scene.pbReplaceAbilitySplash(battler)
  scene.pbDisplay(_INTL('¡{1} se ha enfurecido!', battler.pbThis))
  scene.pbHideAbilitySplash(battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:POKEBLOCKRAINBOW, proc { |item, battler, scene|
  if battler.pbOwnSide.effects[PBEffects::Rainbow] == 0
    battler.pbOwnSide.effects[PBEffects::Rainbow] = 5
    scene.pbDisplay(_INTL('¡Ha aparecido un arcoiris sobre {1}!', battler.pbTeam(true)))
    scene.pbCommonAnimation('RainbowT')
    battler.pokemon.changeHappiness('battleitem')
  end
})

ItemHandlers::BattleUseOnBattler.add(:LAVACOOKIE, proc { |item, battler, scene|
  battler.ability = :SPICYSPRAY
  scene.pbReplaceAbilitySplash(battler)
  scene.pbDisplay(_INTL('¡{1} no puede controlar el picante!', battler.pbThis))
  scene.pbCommonAnimation('RainbowT')
  scene.pbHideAbilitySplash(battler)
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:OLDGATEAU, proc { |item, battler, scene|
  battler.pbOwnSide.effects[PBEffects::Reflect] = 3
  scene.pbAnimation(:REFLECT, battler, battler)
  battler.pbOwnSide.effects[PBEffects::LightScreen] = 3
  scene.pbAnimation(:LIGHTSCREEN, battler, battler)
  scene.pbDisplay(_INTL('¡{1} ha aumentado la resistencia de {2} ante los ataques físicos y especiales!', battler.pbThis, battler.pbTeam(true)))
  battler.pokemon.changeHappiness('battleitem')
})

ItemHandlers::BattleUseOnBattler.add(:CASTELIACONE, proc { |item, battler, scene|
  battler.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
  scene.pbAnimation(:AURORAVEIL, battler, battler)
  scene.pbDisplay(_INTL('¡{1} ha aumentado la resistencia de {2} ante los ataques físicos y especiales!',
                        battler.pbThis, battler.pbTeam(true)))
})

ItemHandlers::BattleUseOnBattler.add(:LUMIOSEGALETTE, proc { |item, battler, scene|
  battler.pbOwnSide.effects[PBEffects::Tailwind] = 2
  scene.pbAnimation(:TAILWIND, battler, battler)
  scene.pbDisplay(_INTL('¡Un céfiro ha empezado a soplar sobre {1}!', battler.pbTeam(true)))
})

ItemHandlers::BattleUseOnBattler.add(:SHALOURSABLE, proc { |item, battler, scene|
  battler.effects[PBEffects::Substitute] = [(battler.totalhp / 4).ceil, 1].max
  scene.pbDisplay(_INTL('¡El aura de {1} ha creado un escudo!', battler.pbThis))
})

ItemHandlers::BattleUseOnBattler.add(:PEWTERCRUNCHIES, proc { |item, battler, scene|
  target = battler.pbDirectOpposing
  battler.pbOpposingSide.effects[PBEffects::StealthRock] = true
  scene.pbAnimation(:STEALTHROCK, battler, target)
  scene.pbUpdateHazardSprites if scene.respond_to?(:pbUpdateHazardSprites)
  scene.pbDisplay(_INTL('¡Rocas puntiagudas flotan en el aire alrededor de {1}!', battler.pbTeam(true)))
})

ItemHandlers::BattleUseOnBattler.add(:BIGMALASADA, proc { |item, battler, scene|
  target = battler.pbDirectOpposing
  battler.pbOpposingSide.effects[PBEffects::StickyWeb] = true
  scene.pbAnimation(:STICKYWEB, battler, target)
  scene.pbUpdateHazardSprites if scene.respond_to?(:pbUpdateHazardSprites)
  scene.pbDisplay(_INTL('¡Una red viscosa se extiende a los pies de {1}!', battler.pbTeam(true)))
})

ItemHandlers::BattleUseOnBattler.add(:SANDWICH, proc { |item, battler, scene|
  target = battler.pbDirectOpposing
  bestType = battler.battle.pbGetBestTypeJudgment(battler, target, nil, nil) || :NORMAL
  battler.effects[PBEffects::ExtraType] = bestType
  typeName = GameData::Type.get(bestType).name
  scene.pbDisplay(_INTL('¡{1} ha ganado el tipo a {2}!', battler.pbThis, typeName))
  scene.pbRefreshOne(battler.index)
})

ItemHandlers::BattleUseOnBattler.add(:SWEETHEART, proc { |item, battler, scene|
  battler.pbOwnSide.effects[PBEffects::Wish] = 2
  battler.pbOwnSide.effects[PBEffects::WishAmount] = battler.totalhp / 3
  battler.pbOwnSide.effects[PBEffects::WishMaker] = battler.index

  scene.pbAnimation(:WISH, battler, battler)
  scene.pbDisplay(_INTL('¡{1} ha pedido un deseo!', battler.name))
})
