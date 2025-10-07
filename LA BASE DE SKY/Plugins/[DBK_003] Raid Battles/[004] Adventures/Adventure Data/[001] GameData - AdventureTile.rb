#===============================================================================
# Adds new data class in GameData module for individual Adventure Map tiles.
#===============================================================================
module GameData
  class AdventureTile
    attr_reader :id            # Symbol ID of a map tile.
    attr_reader :real_name     # Display name of a map tile.
    attr_reader :description   # Description of a map tile.
    attr_reader :type          # String used to categorize a map tile into groups. (Landmark, Object, etc.)
    attr_reader :styles        # An array of [:RaidType] ID's that indicate which type of Raid Adventures this map tile may appear in.
    attr_reader :hidden        # Set to true to make these tiles invisible to the player. False by default.
    attr_reader :no_cursor     # When true, the map cursor will not react when highlighting this map tile.
    attr_reader :dark_mode     # 0 = Tile only appears on dark maps. 1 = Tile only appears on lit maps.
    attr_reader :partner       # An array of a trainer ID and name of a partner trainer used for a [:Character] tile.
    attr_reader :gender        # The gender index of a [:Character] tile (0 = Male, 1 = Female, 2 = Genderless).
    attr_reader :required      # The number of tiles of this type that a map requires. Set to -1 to make required in any amount.
    attr_reader :max_number    # The maximum number of tiles of this type that can appear on a map.
    attr_reader :variable      # A number used to randomize certain properties of a map tile.

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end
      
    def self.each_type(type)
      self.each { |s| yield s if s.type == type }
    end

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || "Unnamed"
      @description   = hash[:description]   || "Unknown tile."
      @type          = hash[:type]          || "None"
      @styles        = hash[:styles]        || []
      @hidden        = hash[:hidden]
      @no_cursor     = hash[:no_cursor]
      @dark_mode     = hash[:dark_mode]
      @partner       = hash[:partner]
      @gender        = hash[:gender]
      @required      = hash[:required]
      @max_number    = hash[:max_number]
      @variable      = hash[:variable]
    end

    def name
      return _INTL(@real_name)
    end
    
    def description
      return _INTL(@description)
    end
  end
end

#===============================================================================
# Empty

GameData::AdventureTile.register({
  :id          => :Empty,
  :name        => _INTL("Vacío"),
  :required    => -1,
  :no_cursor   => true
})

#===============================================================================
# Landmark

GameData::AdventureTile.register({
  :id          => :Pathway,
  :name        => _INTL("Camino"),
  :type        => _INTL("Landmark"),
  :no_cursor   => true,
  :required    => -1
})

GameData::AdventureTile.register({
  :id          => :StartPoint,
  :name        => _INTL("Inicio"),
  :description => _INTL("Siempre aparecerás aquí."),
  :type        => _INTL("Landmark"),
  :required    => 1
})

GameData::AdventureTile.register({
  :id          => :Battle,
  :name        => _INTL("Batalla"),
  :description => _INTL("Tendrás que enfrentarte a un Pokémon salvaje."),
  :type        => _INTL("Landmark"),
  :required    => 11
})

GameData::AdventureTile.register({
  :id          => :Crossroad,
  :name        => _INTL("Encrucijada"),
  :description => _INTL("Tendrás que elegir un camino."),
  :type        => _INTL("Landmark")
})

#===============================================================================
# Directional

GameData::AdventureTile.register({
  :id          => :TurnNorth,
  :name        => _INTL("Gira al norte"),
  :description => _INTL("Tendrás que ir hacia el norte."),
  :type        => _INTL("Directional")
})

GameData::AdventureTile.register({
  :id          => :TurnSouth,
  :name        => _INTL("Gira al sur"),
  :description => _INTL("Tendrás que ir hacia el sur."),
  :type        => _INTL("Directional")
})

GameData::AdventureTile.register({
  :id          => :TurnWest,
  :name        => _INTL("Gira al oeste"),
  :description => _INTL("Tendrás que ir hacia el oeste."),
  :type        => _INTL("Directional")
})

GameData::AdventureTile.register({
  :id          => :TurnEast,
  :name        => _INTL("Gira al eorte"),
  :description => _INTL("Tendrás que ir hacia el este."),
  :type        => _INTL("Directional")
})

GameData::AdventureTile.register({
  :id          => :RandomTurn,
  :name        => _INTL("Giro aleatorio"),
  :description => _INTL("A saber a donde irás."),
  :type        => _INTL("Directional")
})

GameData::AdventureTile.register({
  :id          => :ReverseTurn,
  :name        => _INTL("Media vuelta"),
  :description => _INTL("Tendrás que dar meida vuelta."),
  :type        => _INTL("Directional")
})

#===============================================================================
# Object

GameData::AdventureTile.register({
  :id          => :Door,
  :name        => _INTL("Puerta"),
  :description => _INTL("Tendrás que usar una llave para abrirla."),
  :type        => _INTL("Object")
})

GameData::AdventureTile.register({
  :id          => :Switch,
  :name        => _INTL("Interruptor"),
  :description => _INTL("Puede que te revele algo oculto."),
  :type        => _INTL("Object")
})

GameData::AdventureTile.register({
  :id          => :Warp,
  :name        => _INTL("Teletransporte"),
  :description => _INTL("Te transportará a una ubicación aleatoria."),
  :type        => _INTL("Object")
})

GameData::AdventureTile.register({
  :id          => :Portal,
  :name        => _INTL("Portal"),
  :description => _INTL("Te teletransportará al comienzo."),
  :type        => _INTL("Object")
})

GameData::AdventureTile.register({
  :id          => :Teleporter,
  :name        => _INTL("Teletransportador"),
  :description => _INTL("Te permite volver a un punto anterior."),
  :type        => _INTL("Object"),
  :dark_mode   => 1
})

GameData::AdventureTile.register({
  :id          => :Roadblock,
  :name        => _INTL("Bloqueo"),
  :description => _INTL("Te impide el paso a no ser que un Pokémon te ayude"),
  :type        => _INTL("Object"),
  :variable    => 12
})

GameData::AdventureTile.register({
  :id          => :HiddenTrap,
  :name        => _INTL("Trampa oculta"),
  :description => _INTL("Esta trampa puede dañar a tus Pokémon."),
  :type        => _INTL("Object"),
  :hidden      => true
})

#===============================================================================
# Collectable

GameData::AdventureTile.register({
  :id          => :Berries,
  :name        => _INTL("Bayas"),
  :description => _INTL("Recoger bayas puede curar a tus Pokémon."),
  :type        => _INTL("Collectable")
})

GameData::AdventureTile.register({
  :id          => :Flare,
  :name        => _INTL("Yesca"),
  :description => _INTL("Aumenta tu visión."),
  :type        => _INTL("Collectable"),
  :dark_mode   => 0
})

GameData::AdventureTile.register({
  :id          => :Key,
  :name        => _INTL("Llave"),
  :description => _INTL("Desbloquea las puertas."),
  :type        => _INTL("Collectable")
})

GameData::AdventureTile.register({
  :id          => :Chest,
  :name        => _INTL("Cofre"),
  :description => _INTL("Usa una llave para llevarte lo que hay dentro."),
  :type        => _INTL("Collectable")
})

#===============================================================================
# Character

GameData::AdventureTile.register({
  :id          => :Assistant,
  :name        => _INTL("Ayudante"),
  :description => _INTL("Te ofrece un intercambio."),
  :type        => _INTL("Character"),
  :gender      => 0
})

GameData::AdventureTile.register({
  :id          => :ItemVendor,
  :name        => _INTL("Vendedor"),
  :description => _INTL("Ofrece objetos equipables a tus Pokémon."),
  :type        => _INTL("Character"),
  :styles      => [:Basic, :Max, :Tera],
  :gender      => 0
})

GameData::AdventureTile.register({
  :id          => :MoveTutor,
  :name        => _INTL("Tutor"),
  :description => _INTL("Enseña movimientos a tus Pokémon."),
  :type        => _INTL("Character"),
  :gender      => 1
})

GameData::AdventureTile.register({
  :id          => :Nurse,
  :name        => _INTL("Enfermera"),
  :description => _INTL("Cura a tus Pokémon"),
  :type        => _INTL("Character"),
  :gender      => 1
})

GameData::AdventureTile.register({
  :id          => :Mystic,
  :name        => _INTL("Vidente"),
  :description => _INTL("Recupera tus corazones."),
  :type        => _INTL("Character"),
  :gender      => 1
})

GameData::AdventureTile.register({
  :id          => :MysteryNPC,
  :name        => _INTL("NPC misterioso"),
  :description => _INTL("¿Quién será?"),
  :type        => _INTL("Character")
})

GameData::AdventureTile.register({
  :id          => :Researcher,
  :name        => _INTL("Investigador"),
  :description => _INTL("Cambia ciertos atributos de tus Pokémon."),
  :type        => _INTL("Character"),
  :styles      => [:Ultra, :Max, :Tera],
  :gender      => 0
})

GameData::AdventureTile.register({
  :id          => :PartnerA,
  :name        => _INTL("Partner Brendan"),
  :description => _INTL("Quiere echarte una mano."),
  :type        => _INTL("Character"),
  :partner     => [:POKEMONTRAINER_Brendan, "Brendan"],
  :max_number  => 1
})

GameData::AdventureTile.register({
  :id          => :PartnerB,
  :name        => _INTL("Partner May"),
  :description => _INTL("Quiere echarte una mano."),
  :type        => _INTL("Character"),
  :partner     => [:POKEMONTRAINER_May, "May"],
  :max_number  => 1
})