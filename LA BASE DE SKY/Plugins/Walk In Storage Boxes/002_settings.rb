
  #====================================================================#
  #                                                                    #
  #     Walk-In Storage Boxes with Overworld Pokemon                   #
  #                         - by derFischae (Credits if used please)   #
  #                                                                    #
  #====================================================================#

#===============================================================================
#             HELP AND MORE
#===============================================================================

# If you need help, found a bug or search for more modifications then go to
#    pokecommunity.com

#===============================================================================
#             THE SETTINGS
#===============================================================================

module WalkInBoxSettings
  
  #---------------- GRAPHICS OF SPAWNED POKEMON -------------------
  SPRITES = [true, true, true] # default [true, true, true]
  # This parameter must be an array [alt_form, female, shiny] of three bools.
  # alt_form/ female/ shiny = false means: you don't use alternative/ female/ shiny sprites for your overworld encounter.
  #                         = true  means: alternative forms/ female forms/ shiny pokemon have there own special overworld sprite.
  # If true, make sure that you have the overworld sprites with the right name in your "\Graphics\Characters\Follower" folder
  # and that you have the shiny overworld sprites with the same name in your "\Graphics\Characters\Follower shiny" folder.
  # The right name of sprites:
  #  usual form     - SPECIES.png   where SPECIES is the species name in capslock (e.g. PIDGEY.png)
  #  alternate form - SPECIES_n.png where n is the number of the form (e.g. PIKACHU_3.png)
  #  female form    - SPECIES_female.png or SPECIES_n_female (e.g. PIDGEY_female.png or PIKACHU_3_female.png)
  
  USE_STEP_ANIMATION = true # default true
  #false - means that overworld encounters don't have a stop-animation
  #true - means that overworld encounters have a stop-animation similar as  
  #       following pokemon

  #------------------- MOVEMENT OF SPAWNED POKEMON -----------------------
  DEFAULT_MOVEMENT = [3, 3, 1] # default [3, 3, 1]
  # This parameter stores an array [move_speed, move_frequency, move_type] of three integers where
  # move_speed/ move_frequency/ move_type is the default movement speed/ frequency/ type of spawned PokeEvents.
  # See RPGMakerXP for more details (compare to autonomous movement of events).
  # speed/ frequency = 1   - means lowest movement speed/ frequency
  # speed/ frequency = 6   - means highest movement speed/ frequency
  # type = 0/ 1/ 3         - means no movement/ random movement/ run to player
  # ...

  Enc_Movements = [                  # default
    [:shiny?, true, 3, 4, nil],    # [:shiny?, true, 3, 4, 3] means that shiny encounters will be faster
    [:species, :SLOWPOKE, 1, 1, nil], # [:species, :SLOWPOKE, 1, 1, nil] means that slowpoke is very slow. It might still want to run random or to the player.
    [:nature, :NAUGHTY, nil, 4, 3] # [:nature, :NAUGHTY, nil, 4, 3] means pokemon with a naughty nature will run to the player and be faster
  ]
  # This parameter is used to change movement of spawned PokeEvents depending on the spawned pokemon.
  # The data is stored as an array of arrays. You can add your own arrays.s
  # The data is stored as an array of entries [variable, value, move_speed, move_frequency, move_type], where variable
  # is a variable or method which does not require parameters of the class Pokemon,
  # value is a possible outcome value of variable and move_speed, move_frequency and move_type are the movement speed,
  # frequency and type all PokeEvents should get if value == pokemon.variable.
  # nil  - means that the movement-parameter will not be changed.
end


#------------- THE MAP IDS FOR THE STORAGE BOXES ------------ 
  #STORAGE_BOX
  # This parameter holds the id for the corresponding storage box.

  #MAP_ID
  # This parameter holds the map id of the map you created for being a walk in storage map.
  # Make sure that every map id is correct and exists.

  #SPAWN_POSITIONS # something like that [[0,0], [0,1], ... ]
  # (Requires: SPAWN_METHOD set to fixed positions)
  # This parameter holds the positions for the pokemon as an array.
  # For each slot in your storage box, you have to choose a position [x,y] on the map and list it in SPAWN_POSITIONS.
  # first entry - means the position of the pokemon in the first slot of your storage box etc.


GameData::StorageMap.register({
  :id              => :Box1,
  :id_number       => 1,
  :name            => _INTL("Box 1"),
  :storage_box     => 0,
  :map_id          => 84,
  :spawn_positions => [[3,7],[6,7],[9,12],[12,12],[15,7],[9,12],[5,13],[2,11],[15,7],[10,9],[9,10],[7,12],[2,9],[8,8],[9,8],[10,7][13,13],[16,9],[1,12],[5,7]],
})
