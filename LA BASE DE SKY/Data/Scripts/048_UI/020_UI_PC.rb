#===============================================================================
#
#===============================================================================
def pbPCItemStorage
  command = 0
  loop do
    command = pbShowCommandsWithHelp(nil,
                                     [_INTL("Sacar Objeto"),
                                      _INTL("Dejar Objeto"),
                                      _INTL("Tirar Objeto"),
                                      _INTL("Salir")],
                                     [_INTL("Sacar objetos del PC."),
                                      _INTL("Dejar objetos en el PC."),
                                      _INTL("Tirar objetos almacenados en el PC."),
                                      _INTL("Volver al menú anterior.")], -1, command)
    case command
    when 0   # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("No hay objetos."))
      else
        pbFadeOutIn do
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbWithdrawItemScreen
        end
      end
    when 1   # Deposit Item
      pbFadeOutIn do
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        screen.pbDepositItemScreen
      end
    when 2   # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("No hay objetos."))
      else
        pbFadeOutIn do
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbTossItemScreen
        end
      end
    else
      break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbTrainerPC
  pbMessage("\\se[PC open]" + _INTL("{1} encendió el PC.", $player.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("¿Qué quieres hacer?"),
                        [_INTL("Almacenamiento de Objetos"),
                         _INTL("Apagar")], -1, nil, command)
    case command
    when 0 then pbPCItemStorage
    else        break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPokeCenterPC
  pbMessage("\\se[PC open]" + _INTL("{1} encendió el PC.", $player.name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:pc_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("¿A qué PC quieres acceder?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
  pbSEPlay("PC close")
end

def pbGetStorageCreator
  return GameData::Metadata.get.storage_creator
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"      => proc {
    next ($player.seen_storage_creator) ? _INTL("PC de {1}", pbGetStorageCreator) : _INTL("PC de alguien")
  },
  "order"     => 10,
  "effect"    => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("Abriendo el Sistema de Almacenamiento de Pokémon."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
                                       [_INTL("Organizar Cajas"),
                                        _INTL("¡Nos vemos!")],
                                       [_INTL("Organiza a los Pokémon en las Cajas y en tu equipo."),
                                        _INTL("Vuelve al menú anterior.")], -1, command)
      break if command < 0
      if command == 0
        pbFadeOutIn do
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
        end
      else
        break
      end
    end
    next false
  }
})

MenuHandlers.add(:pc_menu, :player_pc, {
  "name"      => proc { next _INTL("PC de {1}", $player.name) },
  "order"     => 20,
  "effect"    => proc { |menu|
    pbMessage("\\se[PC access]" + _INTL("Has accedido al PC de {1}.", $player.name))
    pbTrainerPCMenu
    next false
  }
})

MenuHandlers.add(:pc_menu, :close, {
  "name"      => _INTL("Salir"),
  "order"     => 100,
  "effect"    => proc { |menu|
    next true
  }
})

