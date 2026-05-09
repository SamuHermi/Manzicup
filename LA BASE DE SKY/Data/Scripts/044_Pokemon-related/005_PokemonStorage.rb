#===============================================================================
#
#===============================================================================
class PokemonBox
  attr_reader   :pokemon
  attr_accessor :name, :background

  BOX_WIDTH  = 6
  BOX_HEIGHT = 5
  BOX_SIZE   = BOX_WIDTH * BOX_HEIGHT

  def initialize(name, maxPokemon = BOX_SIZE)
    @name = name
    @background = 0
    @pokemon = []
    maxPokemon.times { |i| @pokemon[i] = nil }
  end

  def length
    @pokemon.length
  end

  def nitems
    ret = 0
    @pokemon.each { |pkmn| ret += 1 unless pkmn.nil? }
    ret
  end

  def full?
    nitems == length
  end

  def empty?
    nitems == 0
  end

  def [](i)
    @pokemon[i]
  end

  def []=(i, value)
    @pokemon[i] = value
  end

  def each(&block)
    @pokemon.each(&block)
  end

  def clear
    @pokemon.clear
  end
end

#===============================================================================
#
#===============================================================================
class PokemonStorage
  attr_reader   :boxes
  attr_accessor :currentBox
  attr_writer   :unlockedWallpapers

  BASICWALLPAPERQTY = 16

  def initialize(maxBoxes = Settings::NUM_STORAGE_BOXES, maxPokemon = PokemonBox::BOX_SIZE)
    @boxes = []
    maxBoxes.times do |i|
      create_new_box(i, maxPokemon)
    end
    @currentBox = 0
    @boxmode = -1
    @unlockedWallpapers = []
    allWallpapers.length.times do |i|
      @unlockedWallpapers[i] = false
    end
  end

  def check_max_boxes_changed
    return unless @boxes.length < Settings::NUM_STORAGE_BOXES

    (Settings::NUM_STORAGE_BOXES - @boxes.length).times do |i|
      create_new_box(@boxes.length)
    end
  end

  def allWallpapers
    [
      # Basic wallpapers
      _INTL('Bosque'), _INTL('Ciudad'), _INTL('Desierto'), _INTL('Sabana'),
      _INTL('Risco'), _INTL('Volcán'), _INTL('Nieve'), _INTL('Cueva'),
      _INTL('Playa'), _INTL('Mar'), _INTL('Río'), _INTL('Cielo'),
      _INTL('Centro Pokémon'), _INTL('Máquina'), _INTL('Rosado'), _INTL('Simple'),
      # Special wallpapers
      _INTL('Espacio'), _INTL('Patio'), _INTL('Nostalgia 1'), _INTL('Torchic'),
      _INTL('Trío 1'), _INTL('PikaPika 1'), _INTL('Legendario 1'), _INTL('Equipo Galaxia 1'),
      _INTL('Distorsión'), _INTL('Concurso'), _INTL('Nostalgia 2'), _INTL('Croagunk'),
      _INTL('Trío 2'), _INTL('PikaPika 2'), _INTL('Legendario 2'), _INTL('Equipo Galaxia 2'),
      _INTL('Heartgold'), _INTL('Soulsilver'), _INTL('Hermano mayor'), _INTL('Pokéathlon'),
      _INTL('Trío 3'), _INTL('Picoreja'), _INTL('Chica Kimono'), _INTL('Revival')
    ]
  end

  def create_new_box(number, maxPokemon = PokemonBox::BOX_SIZE)
    @boxes[number] = PokemonBox.new(_INTL('Caja {1}', number + 1), maxPokemon)
    @boxes[number].background = number % BASICWALLPAPERQTY
  end

  def unlockedWallpapers
    @unlockedWallpapers ||= []
    @unlockedWallpapers
  end

  def isAvailableWallpaper?(i)
    @unlockedWallpapers ||= []
    return true if i < BASICWALLPAPERQTY
    return true if @unlockedWallpapers[i]

    false
  end

  def availableWallpapers
    ret = [[], []] # Names, IDs
    papers = allWallpapers
    @unlockedWallpapers ||= []
    papers.length.times do |i|
      next unless isAvailableWallpaper?(i)

      ret[0].push(papers[i])
      ret[1].push(i)
    end
    ret
  end

  def party
    $player.party
  end

  def party=(_value)
    raise ArgumentError.new('Not supported')
  end

  def party_full?
    $player.party_full?
  end

  def maxBoxes
    @boxes.length
  end

  def maxPokemon(box)
    return 0 if box >= maxBoxes

    box < 0 ? Settings::MAX_PARTY_SIZE : self[box].length
  end

  def full?
    maxBoxes.times do |i|
      return false unless @boxes[i].full?
    end
    true
  end

  def pbFirstFreePos(box)
    if box == -1
      ret = party.length
      return ret >= Settings::MAX_PARTY_SIZE ? -1 : ret
    end
    maxPokemon(box).times do |i|
      return i unless self[box, i]
    end
    -1
  end

  def [](x, y = nil)
    return x == -1 ? party : @boxes[x] if y.nil?

    @boxes.each do |i|
      raise 'Box is a Pokémon, not a box' if i.is_a?(Pokemon)
    end
    x == -1 ? party[y] : @boxes[x][y]
  end

  def []=(x, y, value)
    if x == -1
      party[y] = value
    else
      @boxes[x][y] = value
    end
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    if indexDst < 0 && boxDst < maxBoxes
      found = false
      maxPokemon(boxDst).times do |i|
        next if self[boxDst, i]

        found = true
        indexDst = i
        break
      end
      return false unless found
    end
    if boxDst == -1 # Copying into party
      return false if party_full?

      party[party.length] = self[boxSrc, indexSrc]
      party.compact!
    else # Copying into box
      pkmn = self[boxSrc, indexSrc]
      raise 'Trying to copy nil to storage' unless pkmn

      if Settings::HEAL_STORED_POKEMON
        old_ready_evo = pkmn.ready_to_evolve
        pkmn.heal
        pkmn.ready_to_evolve = old_ready_evo
      end
      self[boxDst, indexDst] = pkmn
    end
    true
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    return false unless pbCopy(boxDst, indexDst, boxSrc, indexSrc)

    pbDelete(boxSrc, indexSrc)
    true
  end

  def pbMoveCaughtToParty(pkmn)
    return false if party_full?

    party[party.length] = pkmn
  end

  def pbMoveCaughtToBox(pkmn, box)
    maxPokemon(box).times do |i|
      next unless self[box, i].nil?

      if Settings::HEAL_STORED_POKEMON && box >= 0
        old_ready_evo = pkmn.ready_to_evolve
        pkmn.heal
        pkmn.ready_to_evolve = old_ready_evo
      end
      self[box, i] = pkmn
      return true
    end
    false
  end

  def pbStoreCaught(pkmn, lvl = 5)
    if Settings::HEAL_STORED_POKEMON && @currentBox >= 0
      old_ready_evo = pkmn.ready_to_evolve
      pkmn.heal
      pkmn.ready_to_evolve = old_ready_evo
    end
    pkmn.level = lvl
    chance = rand(0, 100)
    move = nil
    if chance >= 90
      move = pkmn.species_data.tutor_moves.sample
    elsif chance >= 80
      move = pkmn.species_data.egg_moves.sample
    end
    pkmn.add_first_move(move)
    Console.echo_li('Nuevo mov: ' + move.name) unless move.nil?

    if chance <= 5
      pkmn.ability_index = 2
      Console.echo_li('Habilidad oculta')
    end
    pkmn.unlocked_abilities.push(pkmn.ability_id)
    Console.echo_li("\n")
    pkmn.calc_stats
    # pkmn.species = pkmn.species_data.get_baby_species
    #     maxBoxes.times do |j|
    #       maxPokemon(j).times do |i|
    #         if self[j, i].nil?
    #           self[j, i] = pkmn
    #           return j
    #         elsif self[j, i].species == pkmn.species && (self[j, i].form == pkmn.form || (MultipleForms.call("getFormOnCreation", self[j, i]) && pkmn.species != :TOXTRICITY))
    #             upgradePokemon(self[j, i],pkmn)
    #           return nil
    #         end
    #       end
    #     end
    maxBoxes.times do |j|
      maxPokemon(j).times do |i|
        next unless self[j, i].nil?

        self[j, i] = pkmn
        @currentBox = j
        return @currentBox
      end
    end
    nil
  end

  def upgradePokemon(newOne, oldOne, scene = nil)
    Console.echo_li("\nHabilidades\n")
    Console.echo_li('oldOne' + oldOne.unlocked_abilities.to_s)
    Console.echo_li('newOne' + newOne.unlocked_abilities.to_s)

    GameData::Stat.each_main do |s|
      newOne.iv[s.id] = oldOne.iv[s.id] if oldOne.iv[s.id] > newOne.iv[s.id]
    end
    Console.echo_li("\nMovimientos\n")
    Console.echo_li("oldOne #{oldOne.first_moves}")
    Console.echo_li("newOne #{newOne.first_moves}")

    oldOne.first_moves.each do |m|
      Console.echo_li(m.to_s)
      unless newOne.first_moves.include?(m)
        pbMessage(_INTL('¡{1} ha aprendido {2}!', newOne.name, GameData::Move.get(m).name))
        newOne.add_first_move(m)
      end
    end
    newOne.shiny = true if oldOne.shiny?
    if oldOne.unlocked_abilities.include?(newOne.ability)
      pbMessage(_INTL('¡{1} ha obtenido la habilidad {2}!', oldOne.name, GameData::Ability.get(newOne.ability).real_name))
      newOne.unlocked_abilities.push(newOne.abilities[oldOne.ability_index])
    end

    oldOne.unlocked_abilities.each do |i|
      Console.echo_li("\n" + i.name)
      unless newOne.unlocked_abilities.include?(i)
        newOne.unlocked_abilities.push(i)
        pbMessage(_INTL('¡{1} ha conseguido la habilidad {2}!', oldOne.name, GameData::Ability.get(i.name).real_name))
      end
    end

    Console.echo_li("\nObjetos\n")
    Console.echo_li('oldOne' + oldOne.item.to_s)
    Console.echo_li('newOne' + newOne.item.to_s)
    if oldOne.item && !newOne.item
      newOne.item = oldOne.item
    elsif oldOne.item && newOne.item

      newitem = newOne.item
      newitemname = newitem.portion_name
      if newitemname.starts_with_vowel?
        pbMessage(_INTL('{1} ya tiene equipado {2}.', newOne.name, newitemname) + "\1")
      else
        pbMessage(_INTL('{1} ya tiene equipado {2}.', newOne.name, newitemname) + "\1")
      end
      if pbConfirmMessage(_INTL('¿Quieres equipar {1} a {2} y guardar {3} en la bolsa?', oldOne.item.portion_name,
                                newOne.name, newitemname))
        $bag.add(newitem)
        newOne.item = oldOne.item
        pbMessage(_INTL('Se ha equipado {1} a {2}.', oldOne.item.portion_name, newOne.name) + "\1")
        pbMessage(_INTL('Se ha guardado {1} en la bolsa.', newitemname) + "\1")
      else
        $bag.add(oldOne.item)
        pbMessage(_INTL('Se ha guardado {1} en la bolsa.', oldOne.item.portion_name) + "\1")
      end
    end
    pbChangeExp(newOne, newOne.exp + (oldOne.exp - newOne.exp), scene) if oldOne.exp > newOne.exp
    Console.echo_li("\n")
  end

  def pbSavePokemon(pkmn)
    # Store as normal (add to party if there's space, or send to a Box if not)
    stored_box = pbStorePokemon(pbPlayer, pkmn)
    if stored_box.nil?
      pbMessage(_INTL('¡El {1} que tenías se ha potenciado!', pkmn.name))
    elsif stored_box < 0
      pbDisplayPaused(_INTL('Se agregó a {1} al equipo.', pkmn.name))
      @initialItems[0][pbPlayer.party.length - 1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    box_name = pbBoxName(stored_box)
    pbDisplayPaused(_INTL('Se envió {1} a la caja "{2}"!', pkmn.name, box_name))
  end

  def pbDelete(box, index)
    return unless self[box, index]

    self[box, index] = nil
    party.compact! if box == -1

    ret = -1

    maxPokemon(@currentBox).times do |i|
      next unless self[@currentBox, i].nil?

      self[@currentBox, i] = pkmn
      ret = @currentBox
      break
    end

    if ret < 0
      should_break = false
      maxBoxes.times do |j|
        maxPokemon(j).times do |i|
          next unless self[j, i].nil?

          self[j, i] = pkmn
          @currentBox = j
          ret = @currentBox
          should_break = true
          break
        end
        break if should_break
      end
    end

    # If this completely filled the storage, create a new box if the setting is enabled
    if full? && Settings::STORAGE_EXTEND_ON_FULL && maxBoxes < Settings::MAX_STORAGE_BOXES_EXTEND
      create_new_box(maxBoxes)
    end

    ret
  end

  def pbDelete(box, indices)
    if indices.is_a?(Range) || indices.is_a?(Array)
      indices.each do |index|
        self[box, index] = nil if self[box, index]
      end
    elsif self[box, indices]
      self[box, indices] = nil
    end
    party.compact! if box == -1
  end

  def clear
    maxBoxes.times { |i| @boxes[i].clear }
  end
end

#===============================================================================
# Regional Storage scripts
#===============================================================================
class RegionalStorage
  def initialize
    @storages = []
    @lastmap = -1
    @rgnmap = -1
  end

  def getCurrentStorage
    raise _INTL('El jugador no está en un mapa, por lo que no se puede determinar la región.') unless $game_map

    if @lastmap != $game_map.map_id
      @rgnmap = pbGetCurrentRegion # may access file IO, so caching result
      @lastmap = $game_map.map_id
    end
    if @rgnmap < 0
      raise _INTL('El mapa actual no está definido en ninguna región. Por favor, edita los ajustes de metadatos de MapPosition para este mapa.')
    end

    @storages[@rgnmap] = PokemonStorage.new unless @storages[@rgnmap]
    @storages[@rgnmap]
  end

  def allWallpapers
    getCurrentStorage.allWallpapers
  end

  def availableWallpapers
    getCurrentStorage.availableWallpapers
  end

  def unlockWallpaper(index)
    getCurrentStorage.unlockWallpaper(index)
  end

  def boxes
    getCurrentStorage.boxes
  end

  def party
    getCurrentStorage.party
  end

  def party_full?
    getCurrentStorage.party_full?
  end

  def maxBoxes
    getCurrentStorage.maxBoxes
  end

  def maxPokemon(box)
    getCurrentStorage.maxPokemon(box)
  end

  def full?
    getCurrentStorage.full?
  end

  def currentBox
    getCurrentStorage.currentBox
  end

  def currentBox=(value)
    getCurrentStorage.currentBox = value
  end

  def [](x, y = nil)
    getCurrentStorage[x, y]
  end

  def []=(x, y, value)
    getCurrentStorage[x, y] = value
  end

  def pbFirstFreePos(box)
    getCurrentStorage.pbFirstFreePos(box)
  end

  def pbCopy(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMove(boxDst, indexDst, boxSrc, indexSrc)
    getCurrentStorage.pbCopy(boxDst, indexDst, boxSrc, indexSrc)
  end

  def pbMoveCaughtToParty(pkmn)
    getCurrentStorage.pbMoveCaughtToParty(pkmn)
  end

  def pbMoveCaughtToBox(pkmn, box)
    getCurrentStorage.pbMoveCaughtToBox(pkmn, box)
  end

  def pbStoreCaught(pkmn)
    getCurrentStorage.pbStoreCaught(pkmn)
  end

  def pbDelete(box, index)
    getCurrentStorage.pbDelete(pkmn)
  end

  def create_new_box(number, maxPokemon = PokemonBox::BOX_SIZE)
    getCurrentStorage.create_new_box(number, maxPokemon)
  end
end

#===============================================================================
#
#===============================================================================
def pbUnlockWallpaper(index)
  $PokemonStorage.unlockedWallpapers[index] = true
end

# NOTE: I don't know why you'd want to do this, but here you go.
def pbLockWallpaper(index)
  $PokemonStorage.unlockedWallpapers[index] = false
end

#===============================================================================
# Look through Pokémon in storage
#===============================================================================
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  (-1...$PokemonStorage.maxBoxes).each do |i|
    $PokemonStorage.maxPokemon(i).times do |j|
      pkmn = $PokemonStorage[i][j]
      yield(pkmn, i) if pkmn
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon { |pkmn, box| yield(pkmn, box) unless pkmn.egg? }
end
