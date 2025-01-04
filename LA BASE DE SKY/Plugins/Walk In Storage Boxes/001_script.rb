
  #====================================================================#
  #                                                                    #
  #     Walk-In Storage Boxes with Overworld Pokemon                   #
  #                         - by derFischae (Credits if used please)   #
  #                                                                    #
  #====================================================================#


# This script is for Pokémon Essentials v20 and v20.1 (for short PEv20).
# VERSION-NUMBER: v0.0.1


# Every storage box has an representation as a map, where you can walk in as the player and
# see your caught pokemon move as overworld pokemon and interact with them.


#===============================================================================
#            FEATURES
#===============================================================================

#  [*] You can create maps where your caught pokemon live and run around
#  [*] Pokemon play their cry when touched

#===============================================================================
#            INSTALLATION
#===============================================================================

# Installation.
# [1] Add Graphics: Either get the resources from Gen 8 Project https://reliccastle.com/resources/670/
#  and install the "Graphics/Characters" folder in your game file system.
#  Or you place your own sprites for your pokemon/fakemon with the right names in your "\Graphics\Characters\Follower" folder and your shiny sprites in your "\Graphics\Characters\Follower shiny" folder. 
#  The right name of sprites is:
#    usual form     - SPECIES.png   where SPECIES is the species name in capslock (e.g. PIDGEY.png)
#    alternate form - SPECIES_n.png where n is the number of the form (e.g. PIKACHU_3.png)
#    female form    - SPECIES_female.png or SPECIES_n_female (e.g. PIDGEY_female.png or PIKACHU_3_female.png)
# [2] Create Maps: build and design a map for each storage box and keep the corresponding map ids in mind . Also make sure that these maps are accessible for the player and connected to the ordinary maps, somehow.
# [3] Add Script
# [4] Change Settings: Open the settings.rb file in the folder and write down the map ids in the parameter STORAGE_MAPS and
#           change the parameters in the settings section therein as you like. Details descriptions about the parameters can be found there as well. 
# [5] Enjoy!

#===============================================================================
#             HELP AND MORE
#===============================================================================

# If you need help, found a bug or search for more modifications then go to
#    pokecommunity.com

#===============================================================================
#                              THE SCRIPT
#===============================================================================

module GameData
  class StorageMap

    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :storage_box
    attr_reader :map_id
    attr_reader :spawn_method
    attr_reader :spawn_positions
    attr_reader :sign_positions  

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id              = hash[:id]
      @id_number       = hash[:id_number]
      @real_name       = hash[:name] || "unnamed"
      @storage_box     = hash[:storage_box]
      @map_id          = hash[:map_id]
      @spawn_method    = hash[:spawn_method] || 0
      @spawn_positions = hash[:spawn_positions] || []
      @sign_positions  = hash[:sign_positions] || []
    end

    # @return [String] the translated name of this nature
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================
# Checks on leave Tile
#===============================================================================
#EventHandlers.trigger(:on_leave_tile, self, @oldMap, @oldX, @oldY)

# remove 
EventHandlers.add(:on_leave_tile, :remove_spawned_box_pokemon,
  proc { |thisEvent, oldMap_id, oldX, oldY|
    next if !thisEvent
    next if !thisEvent.is_a?(Game_Player)
    next if oldMap_id == $game_map.map_id
    #remove_box_pokemon_events(oldMap)
    #remove_sign_events(oldMap)
    if $map_factory
      oldMap = $map_factory.getMap(oldMap_id)
      if oldMap.is_a?(Game_Map)
        oldMap.remove_box_pokemon_events
        # alternatively: updating the sprites (old and slow but working):
        #$scene.disposeSpritesets
        #$scene.createSpritesets
        next
      end
    end
    raise ArgumentError.new(_INTL("The map you left is not listed in the map_factory"))    
  }
)

# add
EventHandlers.add(:on_leave_tile, :spawn_box_pokemon,
  proc { |thisEvent, oldMap, oldX, oldY|
    next if !thisEvent
    next if !thisEvent.is_a?(Game_Player)
    next if oldMap == $game_map.map_id
    
    #pbMessage("spawn box pokemon")
    $game_map.generate_box_pokemon_events
    # alternatively: updating the sprites (old and slow but working):
    #$scene.disposeSpritesets
    #$scene.createSpritesets
  }
)

class Game_Map

  def generate_box_pokemon_events
    GameData::StorageMap.each do |storage_map|
      next if storage_map.map_id != @map_id

      #get_all_pokemon_in_storage_box
      box_number = storage_map.storage_box
      box_pokemons = []
      $PokemonStorage.maxPokemon(box_number).times do |i|
        pkmn = $PokemonStorage[box_number][i]
        box_pokemons = box_pokemons.push(pkmn) if pkmn
      end
      next if !box_pokemons || box_pokemons.size == 0
      spawn_positions = storage_map.spawn_positions
      for i in 0..([box_pokemons.size,spawn_positions.size].min-1) do
        spawn_position = storage_map.spawn_positions[i]
        spawnBoxPokemonEvent(spawn_position[0],spawn_position[1],box_pokemons[i]) if spawn_position != nil
      end
    end
  end

  def remove_box_pokemon_events
    #self.map_id
    #pbMessage("remove spawned box pokemon")
    event_ids = @events.keys
    for event_id in event_ids do 
      if @events[event_id].is_a?(Game_BoxPokemonEvent)
        #pbMessage("true")
        if defined?($scene.spritesets)
          for sprite in $scene.spritesets[@map_id].character_sprites
            if sprite.character == @events[event_id]
              $scene.spritesets[@map_id].character_sprites.delete(sprite)
              sprite.dispose
              break
            end
          end
        end
        @events.delete(event_id)
      end
    end
  end

end

#===============================================================================
# adding new Class Game_BoxPokemonEvent and a new method attr_accessor to this Class
# to store the corresponding Pokemon in the Game_Event
#===============================================================================
class Game_BoxPokemonEvent < Game_Event
  #attr_accessor :event
  attr_accessor :pokemon # contains the original pokemon of class Pokemon

  def initialize(map_id, event, map=nil)
    super(map_id, event, map)
  end
end

#===============================================================================
# new Method spawnBoxPokemonEvent in Class Game_Map in Script Game_Map
#===============================================================================
class Game_Map
  def spawnBoxPokemonEvent(x,y,pokemon)
    #--- generating a new event ---------------------------------------
    event = RPG::Event.new(x,y)
    #--- nessassary properties ----------------------------------------
    key_id = (@events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    #--- Graphic of the event -----------------------------------------
    encounter = [pokemon.species,pokemon.level]
    
    form = pokemon.form
    gender = pokemon.gender
    shiny = pokemon.shiny?
    #event.pages[0].graphic.tile_id = 0
    graphic_form = (WalkInBoxSettings::SPRITES[0] && form!=nil) ? form : 0
    graphic_gender = (WalkInBoxSettings::SPRITES[1] && gender!=nil) ? gender : 0
    graphic_shiny = (WalkInBoxSettings::SPRITES[2] && shiny!=nil) ? shiny : false
    fname = ow_sprite_filename(x,y,encounter[0].to_s, graphic_form, graphic_gender, graphic_shiny)
    fname.gsub!("Graphics/Characters/","")
    event.pages[0].graphic.character_name = fname
    #--- movement of the event --------------------------------
    event.pages[0].move_speed = WalkInBoxSettings::DEFAULT_MOVEMENT[0]
    event.pages[0].move_frequency = WalkInBoxSettings::DEFAULT_MOVEMENT[1]
    event.pages[0].move_type = WalkInBoxSettings::DEFAULT_MOVEMENT[2]
    event.pages[0].step_anime = true if WalkInBoxSettings::USE_STEP_ANIMATION
    event.pages[0].trigger = 2
    event.pages[0].move_route.list[0].code = 10
    event.pages[0].move_route.list[1] = RPG::MoveCommand.new
    for move in WalkInBoxSettings::Enc_Movements do
      if pokemon.method(move[0]).call == move[1]
        event.pages[0].move_speed = move[2] if move[2]
        event.pages[0].move_frequency = move[3] if move[3]
        event.pages[0].move_type = move[4] if move[4]
      end
    end
    #--- event commands of the event -------------------------------------
    parameter = "pbPlayCryOnOverworld(:" + pokemon.species.to_s + ", "+ pokemon.form.to_s + ")" # Play the pokemon cry of encounter
    Compiler::push_script(event.pages[0].list,sprintf(parameter))
    #  - finally push end command
    Compiler::push_end(event.pages[0].list)
    #--- creating and adding the Game_PokeEvent ------------------------------------
    gameEvent = Game_BoxPokemonEvent.new(@map_id, event, self)
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    gameEvent.pokemon = pokemon
  
    @events[key_id] = gameEvent
    #--- updating the sprites --------------------------------------------------------
    sprite = Sprite_Character.new(Spriteset_Map.viewport,@events[key_id])
    $scene.spritesets[self.map_id]=Spriteset_Map.new(self) if $scene.spritesets[self.map_id]==nil
    $scene.spritesets[self.map_id].character_sprites.push(sprite)
    # alternatively: updating the sprites (old and slow but working):
    #$scene.disposeSpritesets
    #$scene.createSpritesets
  end
end

#-------------------------------------------------------------------------------
# New method for easily get the appropriate Pokemon Graphic
#-------------------------------------------------------------------------------
def ow_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
  pbMessage(species)
  fname = GameData::Species.check_graphic_file("Graphics/Characters/", species, form, gender, shiny, shadow, "Followers")
  fname = "Graphics/Characters/Followers/000.png" if nil_or_empty?(fname)
  return fname
end

#===============================================================================
# adding new method pbPlayCryOnOverworld to load/play Pokémon cry files 
# SPECIAL THANKS TO "Ambient Pokémon Cries" - by Vendily
# actually it's not used, but that code helped to include the pkmn cries faster
#===============================================================================
def pbPlayCryOnOverworld(pokemon,form=0,volume=30,pitch=100) # default volume=90
  return if !pokemon || pitch <= 0
  form = 0 if form==nil
  if pokemon.is_a?(Pokemon)
    if !pokemon.egg?
      GameData::Species.play_cry_from_pokemon(pokemon,volume,pitch)
    end
  else
    GameData::Species.play_cry_from_species(pokemon,form,volume,pitch)
  end
end

#===============================================================================
# adding a new method attr_reader to the Class Spriteset_Map in Script
# Spriteset_Map to get access to the variable @character_sprites of a
# Spriteset_Map
#===============================================================================
class Spriteset_Map
  attr_reader :character_sprites
end

#===============================================================================
# adding a new method attr_reader to the Class Scene_Map in Script
# Scene_Map to get access to the Spriteset_Maps listed in the variable 
# @spritesets of a Scene_Map
#===============================================================================
class Scene_Map
  attr_reader :spritesets
end

