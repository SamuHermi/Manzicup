#===============================================================================
# Core class which contains all of the data related to the current Adventure.
#===============================================================================
class RaidAdventureState
  attr_reader   :map           # The GameData::AdventureMap for the map used for this Adventure.
  attr_reader   :style         # The Raid style of this Adventure.
  attr_accessor :floor         # The current floor the player is on (Endless Mode).
  attr_accessor :hearts        # The player's current heart count.
  attr_accessor :max_hearts    # The player's current maximum heart count.
  attr_accessor :keys          # The current number of keys held by the player.
  attr_accessor :loot          # A hash of all the items obtained during an Adventure.
  attr_accessor :captures      # An array of all Pokemon captured during this Adventure.
  attr_accessor :raid_species  # A hash of all species encountered in this Adventure.
  attr_accessor :last_battled  # Tracks the ID of the last battle cleared in an Adventure.
  attr_accessor :boss_battled  # Whether or not the player reached the Adventure's boss Pokemon.
  attr_accessor :battle_count  # Keeps count of the number of battles cleared during the Adventure.
  attr_reader   :stored_party  # The player's party prior to starting the Adventure.
  attr_reader   :endless_mode  # Whether or not Endless Mode is enabled.
  attr_reader   :darkness_mode # Whether or not Darkness Mode is enabled.
  attr_reader   :playtesting   # Whether or not playtesting mode is enabled (always false).
  attr_accessor :outcome       # The outcome of the player's Adventure.
  
  def initialize(map, style, rentals, raid_species, endless, darkness)
    @map            = map
    @style          = style
    @floor          = 1
    @hearts         = rentals.length
    @max_hearts     = @hearts
    @keys           = 0
    @loot           = {}
    @captures       = []
    @raid_species   = raid_species
    @last_battled   = 0
    @boss_battled   = false
    @battle_count   = 0
    @stored_party   = $player.party
    $player.party   = rentals
    @endless_mode   = endless
    @darkness_mode  = darkness
    @playtesting    = false
    @outcome        = 0
  end
  
  # Checks for special modes.
  def endlessMode?;  return !@endless_mode.nil?  && @endless_mode;  end
  def darknessMode?; return !@darkness_mode.nil? && @darkness_mode; end
  
  def processAdventure
    pbCancelVehicles
    $game_temp.clear_battle_rules
    old_partner = $PokemonGlobal.partner
    pbDeregisterPartner
    scene = AdventureMapScene.new
    scene.pbStartScene
    scene.pbEndScene
    log_endless_record
    $player.party = @stored_party
    $PokemonGlobal.partner = old_partner
    return @outcome
  end
  
  def add_loot(item, qty = 1)
    if @loot.has_key?(item)
      @loot[item] += qty
    else
      @loot[item] = qty
    end
  end
  
  def finalize_loot
    return if @loot.empty?
    return if ![1, 3].include?(@outcome)
    case @outcome
    when 1 # Victory - Add all loot to bag. 
      @loot.each { |itm, qty| $bag.add(itm, qty) }
    when 3 # Defeated by boss - Add partial loot to bag.
      @loot.each_key do |key|
        case rand(1)
        when 0
          @loot.delete_key(key)
        when 1
          @loot[key] = [@loot[key] / 2, 1].min
          $bag.add(itm, qty)
        end
      end
    end
  end
  
  def log_endless_record
    return if @outcome != 1
    return if !@endless_mode
    record = $PokemonGlobal.raid_adventure_records(@style)
    if !record || record.empty? || @floor > record[:floor]
      $player.party.each { |p| p.heal }
      record = {
        :map      => @map.id,
        :floor    => @floor,
        :battles  => @battle_count,
        :party    => $player.party.clone
      }
    end
  end
end

#===============================================================================
# A simplified Raid Adventure state used for playtesting maps.
#===============================================================================
class FakeRaidAdventureState
  attr_reader   :map
  attr_reader   :style
  attr_accessor :hearts
  attr_accessor :max_hearts
  attr_accessor :keys
  attr_reader   :playtesting
  attr_accessor :outcome
  
  def initialize(map)
    @map         = map
    @style       = nil
    @hearts      = 1
    @max_hearts  = 3
    @keys        = 0
    @playtesting = true
    @outcome     = 0
  end
  
  def endlessMode?;  return false;  end
  def darknessMode?; return nil;    end
  
  def processAdventure
    old_partner = $PokemonGlobal.partner
    pbDeregisterPartner
    scene = AdventureMapScene.new
    scene.pbStartScene
    scene.pbEndScene
    $PokemonGlobal.partner = old_partner
    return @outcome
  end
end

#==========================================================================
# Accepts the following arguments:
#  :style    => Raid Type for this lair.
#  :boss     => Species ID for the boss encounter in this lair.
#  :party    => Forces a party to use during the Adventure, overriding Rental selection.
#  :gender   => Gender of the event speaker. Used to color coat dialogue text.
#  :mapID    => Adventure Map ID number of the map you wish to explore. Player manually selects otherwise.
#  :endless  => Forces Endless Mode lair, even if the player hasn't unlocked it yet.
#  :darkness => Forces Dark Mode lair, even if the player hasn't unlocked it yet.

class RaidAdventure
  def self.start(advData = {})
    if GameData::AdventureMap::DATA.empty?
      raise _INTL("No se encontraron mapas de Aventura.")
    end
    advData[:start] = false
    advData[:outcome] = 0
    try_style = GameData::RaidType.try_get(advData[:style])
    advData[:style] = :Basic if !try_style || !try_style.available
    advData[:prefix] = (advData[:gender] == 0) ? "\\b" : (advData[:gender] == 1) ? "\\r" : ""
    if advData[:boss]
      advData[:boss] = nil if !GameData::Species.exists?(advData[:boss])
      advData[:boss] = nil if !GameData::Species.get(advData[:boss]).raid_species?(advData[:style])
    end
    adventure_name = GameData::RaidType.get(advData[:style]).lair_name
    if pbConfirmMessage(_INTL("#{advData[:prefix]}¿Quieres adentrarte en una {1}?", adventure_name))
      self.adventure_intro(advData)
      if advData[:start]
        args = [GameData::AdventureMap.get(advData[:mapID])]
        [:style, :party, :species, :endless, :darkness].each do |data|
          args.push(advData[data])
        end
        $PokemonGlobal.raid_adventure_state = RaidAdventureState.new(*args)
        advData[:outcome] = self.start_core
      end
    end
    self.adventure_outro(advData)
    $PokemonGlobal.raid_adventure_state = nil
    return advData[:outcome]
  end
  
  def self.start_core(advData = {})
    if $PokemonGlobal.raid_adventure_state.nil?
      map_data = GameData::AdventureMap.get(advData[:mapID] || 0)
      style    = advData[:style]    || :Basic
      species  = advData[:species]  || generate_raid_species(advData[:boss], style)
      endless  = advData[:endless]  || false
      darkness = advData[:darkness] || false
      party    = (advData[:party]) ? generate_rental_party(style, advData[:party]) : $player.party[0..2]
      $PokemonGlobal.raid_adventure_state = RaidAdventureState.new(map_data, style, party, species, endless, darkness)
    end
    outcome = 0
    previousBGM = $game_system.getPlayingBGM
    pbFadeOutInWithMusic { pbRaidAdventureState.processAdventure }
    pbBGMPlay(previousBGM)
    return pbRaidAdventureState.outcome
  end
  
  def self.adventure_intro(advData)
    g = advData[:prefix]
    if advData[:endless]
      advData[:start] = true
    else
      commands      = []
      command_types = []
      if !advData[:mapID] && !advData[:boss]
        routes = $PokemonGlobal.raid_adventure_routes(advData[:style])
        if routes && !routes.empty?
          pbMessage(_INTL("#{g}De acuerdo a las notas, puedes encontrarte un Pokémon especial."))
          routes.each_key do |species| 
            commands.push(_INTL("¡Encontraste a {1}!", GameData::Species.get(species).name))
            command_types.push(species)
          end
        end
      end
      commands.push(_INTL("Aventura normal"))
      command_types.push(0)
      if $PokemonGlobal.raid_adventure_endless_unlocked
        commands.push(_INTL("Aventura infinita"))
        command_types.push(1)
        record = $PokemonGlobal.raid_adventure_records(advData[:style])
        if record && !record.empty?
          commands.push(_INTL("Ver registros"))
          command_types.push(2)
        end
      end
      commands.push(_INTL("Nada"))
      loop do
        cmd = pbMessage(_INTL("#{g}¿Que tipo de aventuras quieres?"), commands)
        break if !cmd || cmd < 0
        case command_types[cmd]
        when Symbol
          advData[:start] = true
          advData[:boss] = command_types[cmd]
          advData[:mapID] = routes[advData[:boss]]
        when 0 # Normal Adventure
          advData[:start] = true
        when 1 # Endless Adventure
          advData[:start] = true
          advData[:endless] = true
        when 2 # View Record
          pbAdventureRecord(advData[:style])
        else # Nevermind
          break
        end
        break if advData[:start]
      end
    end
    if advData[:start] && !advData[:mapID]
      map_commands = []
      GameData::AdventureMap.each { |m| map_commands.push(m.name)}
      map_commands.push(_INTL("Nada"))
      advData[:mapID] = pbMessage(_INTL("#{g}¿A qué nido quieres ir?"), map_commands)
    end
    map_data = GameData::AdventureMap.try_get(advData[:mapID])
    if map_data
      advData[:boss] = nil if advData[:endless]
      advData[:species] = generate_raid_species(advData[:boss], advData[:style])
      advData[:party] = generate_rental_party(advData[:style], advData[:party])
      if !advData[:party] || advData[:party].empty?
        advData[:start] = false
        return
      end
      if !advData[:darkness] && $PokemonGlobal.raid_adventure_endless_unlocked
        advData[:darkness] = true if rand(100) < map_data.darkness
      end
      if advData[:darkness]
        pbMessage(_INTL("#{g}Esta ruta parece especialmente peligrosa: ¡No podrás ver muy lejos!\nAnda con cuidado"))
      end
      if !advData[:endless] && advData[:boss]
        speciesName = GameData::Species.get(advData[:boss]).name
        pbMessage(_INTL("#{g}¡Buena suerte en tu búsqueda de {1}!", speciesName)) 
      else
        pbMessage(_INTL("#{g}¡Buena suerte en tu aventura!"))
      end
      pbSEPlay("Door enter")
    else
      advData[:start] = false
    end
  end
  
  def self.adventure_outro(advData)
    g = advData[:prefix]
    case advData[:outcome]
    when 1 # Victory
      if advData[:endless]
        pbMessage(_INTL("#{g}¡Buah, eres buenísimo! ¡Has roto el récord!"))
      else
        pbMessage(_INTL("#{g}¡El oponente era duro de pelar y a tí te la ha soplado!"))
        $PokemonGlobal.raid_adventure_routes(advData[:style]).delete(advData[:boss])
        if !$PokemonGlobal.raid_adventure_endless_unlocked
          pbMessage(_INTL("#{g}Parece que se te da bien esto. Quizá la próxima vez quieras intentar adentrarte aún más en el nido."))
          pbMessage(_INTL("#{g}¡Prueba suerte en una Aventura Infinita y ensénales quien manda!"))
          $PokemonGlobal.raid_adventure_endless_unlocked = true
        end
        $stats.raid_adventures_cleared += 1
      end
    when 2, 3 # Defeat
      if advData[:endless]
        pbMessage(_INTL("#{g}No llegaste muy lejos esta vez, ¿eh?\nCorcholis, ¡Ya lo conseguirás!"))
      else
        pbMessage(_INTL("#{g}¡Estuviste a punto!"))
        if advData[:outcome] == 3 # Defeated by lair boss
          boss = advData[:species][6].first
          routes = $PokemonGlobal.raid_adventure_routes(advData[:style])
          if !routes.has_key?(boss)
            speciesName = GameData::Species.get(boss).name
            if pbConfirmMessage(_INTL("#{g}¿Quieres que anote dónde encontraste a {1} esta vez para que puedas buscarlo otra vez?", speciesName))
              if routes.length >= 3
                pbMessage(_INTL("#{g}NO puedes guardar más rutas..."))
                if pbConfirmMessage(_INTL("#{g}¿Quieres reemplazar alguna?"))
                  commands = []
                  routes.each_key { |sp| commands.push(GameData::Species.get(sp).name) }
                  commands.push(_INTL("Olvídalo"))
                  cmd = pbMessage(_INTL("#{g}¿Qué ruta quieres reemplazar?"), commands, -1)
                  if cmd >= 0 && cmd < commands.length
                    pbMessage(_INTL("#{g}Me apunto la ruta hacia {1}.", speciesName))
                    routes.delete(boss)
                    routes[boss] = advData[:mapID]
                  end
                end
              else
                pbMessage(_INTL("#{g}Me apunto la ruta hacia {1}.", speciesName))
                routes[boss] = advData[:mapID]
              end
            end
          end
        end
      end
    when 4 # Abandoned
      pbMessage(_INTL("#{g}¿Eh, te rindes?\n¡Vuelve cuando quieras para una nueva aventura!"))
    end
    pbMessage(_INTL("#{g}Vuelve pronto!"))
  end
  
  def self.generate_raid_species(species, style)
    raid_species = Hash.new { |key, value| key[value] = [] }
    raidRanks = GameData::Species.generate_raid_lists(style, true).clone
    battle_count = GameData::AdventureTile.get(:Battle).required
    battle_count.times do |i|
      case i + 1
      when battle_count then rank = 6
      when (7..10)      then rank = 5
      when (3..6)       then rank = 4
      else                   rank = 3
      end
      sp = (i + 1 == battle_count && !species.nil?) ? species : raidRanks[rank].sample
      sp = :DITTO if sp.nil?
      raidRanks.each_value { |array| array.delete(sp) }
      raid_species[rank] << sp
    end
    return raid_species
  end
  
  def self.generate_rental_party(style, party = nil)
    if party
      new_party = []
      party.each do |pkmn|
        case pkmn
        when Pokemon
          next if !pkmn.species_data.raid_species?(style)
          new_party.push(pkmn)
        when Symbol
          next if !GameData::Species.exists?(pkmn)
          next if !GameData::Species.get(pkmn).raid_species?(style)
          level = [($player.badge_count + 1) * 10, 70].min
          new_party.push(Pokemon.new(pkmn, level))
        end
        break if new_party.length == 3
      end
      return new_party if new_party.length == 3
      raise _INTL("No se pueden encontrar tres Pokémon válidos para formar un equipo de Aventura.")
    else
      return pbAdventureMenuRentals(style)
    end
  end
end

#===============================================================================
# Raid Adventure utilities.
#===============================================================================
class PokemonGlobalMetadata
  alias raid_initialize initialize
  def initialize
    raid_initialize
    @raid_adventure_state = nil
    @raid_adventure_routes = {}
    @raid_adventure_records = {}
    @raid_adventure_endless_unlocked = false
  end
  
  def raid_adventure_state
    return @raid_adventure_state
  end
  
  def raid_adventure_state=(value)
    @raid_adventure_state = value
  end
  
  def raid_adventure_routes(value = :Basic)
    @raid_adventure_routes = {} if !@raid_adventure_routes
    return nil if !GameData::RaidType.exists?(value)
    @raid_adventure_routes[value] = {} if !@raid_adventure_routes[value]
    return @raid_adventure_routes[value]
  end
  
  def raid_adventure_records(value = :Basic)
    @raid_adventure_records = {} if !@raid_adventure_records
    return nil if !GameData::RaidType.exists?(value)
    @raid_adventure_records[value] = {} if !@raid_adventure_records[value]
    return @raid_adventure_records[value]
  end
  
  def raid_adventure_endless_unlocked
    return @raid_adventure_endless_unlocked
  end
  
  def raid_adventure_endless_unlocked=(value)
    @raid_adventure_endless_unlocked = value
  end
end

def pbInRaidAdventure?
  return !$PokemonGlobal.raid_adventure_state.nil?
end

def pbRaidAdventureState
  return $PokemonGlobal.raid_adventure_state
end