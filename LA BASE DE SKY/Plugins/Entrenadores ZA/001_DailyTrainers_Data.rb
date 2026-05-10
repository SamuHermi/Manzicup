#===============================================================================
# Daily Trainers - Data
# Extiende GameData::TrainerType para soportar los campos:
#   Rarity = 0..3   (0 = nunca aparece, 1 = común, 2 = poco común, 3 = raro)
#   Maps   = 5,12,34  (IDs de mapas donde puede aparecer)
#   Switch = 102     (Switch global que debe estar ON para que aparezca)
#
# En trainer_types.txt, añade estos campos a cada trainer type que quieras
# que participe en el sistema de entrenadores diarios. Ejemplo:
#
#   [YOUNGSTER]
#   Name = Jovenzuelo
#   ...
#   Rarity = 1
#   Maps = 5,12,34
#   Switch = 102
#
# Los trainer types SIN estos campos simplemente no participarán en el sistema.
#===============================================================================

module GameData
  class TrainerType
    #---------------------------------------------------------------------------
    # 1) Nuevos atributos de instancia
    #---------------------------------------------------------------------------
    attr_reader :daily_rarity # Integer 0-3
    attr_reader :daily_maps, :daily_switch # Array de map IDs (integers)   # Integer (ID del switch global) o nil

    #---------------------------------------------------------------------------
    # 2) Añadir los campos al SCHEMA para que el compilador PBS los reconozca
    #    al procesar trainer_types.txt.
    #    SCHEMA es una constante Hash definida directamente en la clase,
    #    por lo que es mutable y se puede extender aquí sin problema.
    #---------------------------------------------------------------------------
    SCHEMA['Rarity'] = [:daily_rarity, 'u']    # u  = unsigned integer
    SCHEMA['Maps']   = [:daily_maps,   '*u']   # *u = array de unsigned integers
    SCHEMA['Switch'] = [:daily_switch, 'u']

    #---------------------------------------------------------------------------
    # 3) Parchear initialize para leer los nuevos campos del hash compilado.
    #    El compilador rellena el hash con los símbolos definidos en SCHEMA,
    #    así que :daily_rarity, :daily_maps y :daily_switch estarán presentes
    #    si el PBS los define, o ausentes si no.
    #---------------------------------------------------------------------------
    alias _daily_trainers_orig_initialize initialize
    def initialize(hash)
      _daily_trainers_orig_initialize(hash)
      @daily_rarity = hash[:daily_rarity] || 0
      @daily_maps   = hash[:daily_maps]   || []
      @daily_switch = hash[:daily_switch] || nil
    end

    #---------------------------------------------------------------------------
    # Devuelve true si este trainer type puede aparecer en el mapa indicado.
    #---------------------------------------------------------------------------
    def daily_available?(map_id)
      return false if @daily_rarity == 0
      return false if @daily_maps.empty?
      return false unless @daily_maps.include?(map_id)
      return false if @daily_switch && !$game_switches[@daily_switch]

      true
    end

    #---------------------------------------------------------------------------
    # Peso de probabilidad para la selección ponderada por rareza.
    # Rarity 1 (común)        -> peso 9
    # Rarity 2 (poco común)   -> peso 3
    # Rarity 3 (raro)         -> peso 1
    # Rarity 0 (desactivado)  -> peso 0
    #---------------------------------------------------------------------------
    def daily_weight
      case @daily_rarity
      when 1 then 9
      when 2 then 3
      when 3 then 1
      else        0
      end
    end
  end
end

module GameData
  class Trainer
    #---------------------------------------------------------------------------
    # 1) Nuevos atributos de instancia
    #---------------------------------------------------------------------------
    attr_reader :min_badges # Integer 0-8
    attr_reader :max_badges, :daily_switch # Integer 0-9 # Integer (ID del switch global) o nil

    SCHEMA['MinBadges'] = [:min_badges, 'u']    # u  = unsigned integer
    SCHEMA['MaxBadges'] = [:max_badges, 'u']    # u  = unsigned integer
    SCHEMA['Switch'] = [:daily_switch, 'u']

    alias _daily_trainers_orig_initialize initialize
    def initialize(hash)
      _daily_trainers_orig_initialize(hash)
      @min_badges = hash[:min_badges] || 0
      @max_badges = hash[:max_badges] || 9
      @daily_switch = hash[:daily_switch] || nil
    end

    #---------------------------------------------------------------------------
    # Devuelve true si este trainer type puede aparecer en el mapa indicado.
    #---------------------------------------------------------------------------
    def daily_available?
      return false if $player.badge_count < @min_badges
      return false if $player.badge_count >= @max_badges
      return false if @daily_switch && !$game_switches[@daily_switch]

      true
    end
  end
end
