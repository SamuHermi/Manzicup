#===============================================================================
# Daily Trainers - Manager
# Controla la rotación de entrenadores.
#
# La rotación es 100% manual: se dispara exclusivamente desde un evento
# del juego (p.e. "pasar la noche", "avanzar el día"). Llama a:
#
#   DailyTrainers::Manager.force_rotation
#
#===============================================================================
 
module DailyTrainers
  module Manager
    #---------------------------------------------------------------------------
    # Fuerza una rotación de entrenadores en todos los mapas registrados.
    # Llama a esto desde el evento de "pasar el día" de tu juego.
    #---------------------------------------------------------------------------
    def self.force_rotation
      # Obtener todos los map IDs que tienen al menos un trainer_type válido
      map_ids = get_all_daily_maps
 
      # Para cada mapa, limpiar los eventos anteriores y generar nuevos
      map_ids.each do |map_id|
        DailyTrainers.spawn_for_map(map_id)
      end
 
      # Si el jugador ya está en uno de esos mapas, refrescar el mapa actual
      if map_ids.include?($game_map&.map_id)
        refresh_current_map
      end
    end
 
    #---------------------------------------------------------------------------
    # Recopila todos los map IDs únicos que tienen al menos un trainer_type
    # con Rarity > 0 definido para ellos.
    #---------------------------------------------------------------------------
    def self.get_all_daily_maps
      maps = []
      GameData::TrainerType.each do |tr_type|
        next if tr_type.daily_rarity == 0
        next if tr_type.daily_maps.empty?
        tr_type.daily_maps.each do |map_id|
          maps.push(map_id) if !maps.include?(map_id)
        end
      end
      return maps
    end
 
    #---------------------------------------------------------------------------
    # Refresca el mapa actual para que los nuevos eventos dinámicos
    # aparezcan sin necesidad de salir y volver a entrar.
    #---------------------------------------------------------------------------
    def self.refresh_current_map
      return if !$game_map
      # Recargar los eventos dinámicos del mapa actual
      DailyTrainers.reload_events_for_current_map
      # Forzar un refresco visual del mapa
      $game_map.refresh if $game_map.respond_to?(:refresh)
    end
  end
end
 
#===============================================================================
# Extensión de PokemonGlobalMetadata para persistir los datos del sistema.
# Añade los atributos necesarios a $PokemonGlobal.
#===============================================================================
class PokemonGlobalMetadata
  # Hash de map_id => array de hashes con datos de eventos generados
  # { id:, x:, y:, tr_type_id: }
  attr_accessor :daily_trainer_events
 
  alias_method :daily_trainers_orig_initialize, :initialize
  def initialize
    daily_trainers_orig_initialize
    @daily_trainer_events = {}
  end
end