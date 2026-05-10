#===============================================================================
# Daily Trainers - Spawn
# Gestiona la creación y eliminación de eventos dinámicos de entrenadores
# en el mapa actual. Los eventos se crean como objetos RPG::Event en runtime
# y se inyectan directamente en $game_map.events.
#
# Cada evento generado:
#   - Tiene el sprite del trainer_type correspondiente
#   - Mira hacia el jugador (paso a paso, usando move route)
#   - Inicia batalla al contacto (trigger: player touch)
#   - Al ser derrotado activa su Switch Local A (self switch "A")
#===============================================================================

module DailyTrainers
  # Rango global de entrenadores a spawnear por mapa
  SPAWN_MIN = 4
  SPAWN_MAX = 8

  # Prefijo en el nombre del evento para identificarlos como dinámicos
  EVENT_NAME_PREFIX = "Trainer"

  #-----------------------------------------------------------------------------
  # Elimina todos los eventos dinámicos de entrenadores del mapa actual.
  # Se llama antes de generar los nuevos al rotar el día.
  #-----------------------------------------------------------------------------
def self.clear_dynamic_events(map_id = nil)
  map_id ||= $game_map.map_id
  # Eliminar de $game_map.events los que tengan nuestro prefijo
  if $game_map && $game_map.map_id == map_id
    keys_to_delete = []
    $game_map.events.each do |id, event|
      keys_to_delete.push(id) if event.name.start_with?(EVENT_NAME_PREFIX)
    end
    keys_to_delete.each { |id| $game_map.events.delete(id) }
  end
  # Limpiar Self Switches de los eventos dinámicos de este mapa
  $PokemonGlobal.daily_trainer_events ||= {}
  event_data_list = $PokemonGlobal.daily_trainer_events[map_id] || []
  event_data_list.each do |data|
    ["A", "B", "C", "D"].each do |sw|
      $game_self_switches[[map_id, data[:id], sw]] = false
    end
  end
  # Eliminar también del registro persistente de este mapa
  $PokemonGlobal.daily_trainer_events.delete(map_id)
end

  #-----------------------------------------------------------------------------
  # Genera los entrenadores diarios para el mapa indicado.
  # Selecciona trainer_types válidos ponderados por Rarity, busca tiles
  # válidos y crea los eventos dinámicos.
  #-----------------------------------------------------------------------------
  def self.spawn_for_map(map_id)
    clear_dynamic_events(map_id)

    # Recopilar todos los trainer_types válidos para este mapa
    candidates = []
    GameData::TrainerType.each do |tr_type|
      next if !tr_type.daily_available?(map_id)
      next if tr_type.id == $player.trainer_type   # Evitar spawnear el mismo trainer_type del jugador
      trainers = GameData::Trainer::DATA.values.select { |t| t.trainer_type == tr_type.id && t.daily_available?}
      next if trainers.empty?
      for trainer in trainers
        Console.echo_li("#{trainer.name} (#{trainer.id}) #{trainer.version}\n")
      end
      tr_type.daily_weight.times { candidates.push(tr_type.id)}
    end
    return if candidates.empty?

    Console.echo_li("\n" + candidates.to_s + " son los trainer types candidatos para el mapa {"+map_id.to_s+"}...")
    # Determinar cuántos entrenadores spawnear
    count = SPAWN_MIN + rand(SPAWN_MAX - SPAWN_MIN + 1)

    # Obtener tiles válidos del mapa
    valid_tiles = get_valid_spawn_tiles(map_id)
    return if valid_tiles.empty?

    # Seleccionar posiciones únicas aleatorias
    count = [count, valid_tiles.length].min
    spawn_positions = valid_tiles.sample(count)

    Console.echo_li("\nSpawneando #{count} entrenadores en el mapa {"+map_id.to_s+"} en las posiciones #{spawn_positions.to_s}...")
    # Registrar los eventos a crear (para recargarlos si el jugador
    # sale y vuelve al mapa el mismo día)
    $PokemonGlobal.daily_trainer_events ||= {}
    $PokemonGlobal.daily_trainer_events[map_id] = []

    spawn_positions.each_with_index do |pos, i|
      tr_type_id = candidates.sample
      trainer = GameData::Trainer::DATA.values.select { |t| t.trainer_type == tr_type_id && t.daily_available?}.sample
      event_id   = 50000 + (map_id * 100) + i   # ID único fuera del rango normal
      Console.echo_li("Preparando evento para trainer_type #{tr_type_id} (#{GameData::TrainerType.get(tr_type_id).name}) #{trainer.name} en (#{pos[0]}, #{pos[1]}) con event ID #{event_id}...")
      # Guardar datos del evento para poder recargarlo
      $PokemonGlobal.daily_trainer_events[map_id].push({
        id:         event_id,
        x:          pos[0],
        y:          pos[1],
        tr_type_id: tr_type_id,
        tr_id:      trainer
      })

      # Crear el evento en el mapa si está cargado ahora mismo
      inject_event(event_id, pos[0], pos[1], tr_type_id, trainer) if $game_map&.map_id == map_id
    end
  end

  #-----------------------------------------------------------------------------
  # Recarga los eventos dinámicos en el mapa actual desde el registro guardado.
  # Se llama desde on_game_map_setup cuando se entra a un mapa.
  #-----------------------------------------------------------------------------
  def self.reload_events_for_current_map
    map_id = $game_map.map_id
    Console.echo_li("Recargando eventos dinámicos de entrenadores para el mapa {"+map_id.to_s+"}...\n") 
    $PokemonGlobal.daily_trainer_events ||= {}
    event_data_list = $PokemonGlobal.daily_trainer_events[map_id]
    Console.echo_li("Datos de eventos a recargar: #{event_data_list.to_s}...\n")
    return if !event_data_list || event_data_list.empty?

    event_data_list.each do |data|
      # No recargar si ya fue derrotado hoy (self switch A activo)
      self_switch_key = [map_id, data[:id], "A"]
      next if $game_self_switches[self_switch_key]
      inject_event(data[:id], data[:x], data[:y], data[:tr_type_id], data[:tr_id])
    end
  end

  #-----------------------------------------------------------------------------
  # Crea un RPG::Event dinámico y lo inyecta en $game_map.events.
  #-----------------------------------------------------------------------------
  def self.inject_event(event_id, x, y, tr_type_id, trainer) 
    tr_type = GameData::TrainerType.get(tr_type_id)
    Console.echo_li("Creando evento para trainer_type #{tr_type_id} (#{tr_type.name}) #{trainer.name} en (#{x}, #{y})...\n")
    # Construir el RPG::Event base
    event        = RPG::Event.new(x, y)
    event.id     = event_id
    event.name   = "#{EVENT_NAME_PREFIX}(#{rand(4..9)})"

    # Página del evento
    page               = RPG::Event::Page.new
    page.condition     = RPG::Event::Page::Condition.new

    # Gráfico: sprite del trainer_type
    page.graphic               = RPG::Event::Page::Graphic.new
    page.graphic.character_name = ("trainer_" + tr_type_id.to_s) rescue ""
    page.graphic.character_hue  = 0
    page.graphic.direction      = 2   # Mirando hacia abajo por defecto
    page.graphic.pattern        = 0

    # Movimiento: girar hacia el jugador constantemente
    page.move_type      = 2   # Aleatorio (para que parezca que deambula)
    page.move_speed     = 3
    page.move_frequency = 3
    page.walk_anime     = true
    page.step_anime     = false
    page.direction_fix  = false
    page.through        = false
    page.always_on_top  = false

    # Trigger: al tocar al jugador (event touch = 2)
    page.trigger = 2

    # Comandos del evento: iniciar batalla con el trainer_type
    page.list = build_event_commands(tr_type_id, trainer)



    page2               = RPG::Event::Page.new
    page2.condition     = RPG::Event::Page::Condition.new
    page2.condition.self_switch_valid = true
    page2.condition.self_switch_ch    = "A"

    # Gráfico: sprite del trainer_type
    page2.graphic               = RPG::Event::Page::Graphic.new
    page2.graphic.character_name = ("trainer_" + tr_type_id.to_s) rescue ""
    page2.graphic.character_hue  = 0
    page2.graphic.direction      = 2   # Mirando hacia abajo por defecto
    page2.graphic.pattern        = 0
    page2.list = [
      cmd(355, 0, "pbMessage(\"#{trainer.lose_text}\")"),
      cmd(0, 0)
    ]
    event.pages = [page,page2]

    Console.echo_li("Inyectando evento dinámico #{event.name} en (#{x}, #{y}) con trainer_type #{tr_type_id}...\n")
    # Crear el Game_Event correspondiente y añadirlo al mapa
    return if !$game_map || !$game_map.events
    game_event = Game_Event.new($game_map.map_id, event)
    Console.echo_li("Añadiendo evento dinámico #{event.name} en (#{x}, #{y}) con trainer_type #{tr_type_id}...\n")    
    $game_map.events[event_id] = game_event
    game_event.refresh
    Console.echo_li("Añadido evento dinámico #{event.name} en (#{x}, #{y}) con trainer_type #{tr_type_id}, #{$game_map.events[event_id].to_s}...\n")
    game_event.moveto(x, y)
  end

  #-----------------------------------------------------------------------------
  # Construye la lista de comandos RPG para el evento del entrenador.
  # El evento iniciará una batalla de entrenador y activará Self Switch A
  # al terminar (independientemente del resultado, siguiendo la convención
  # de Essentials para entrenadores ya derrotados).
  #-----------------------------------------------------------------------------
  def self.build_event_commands(tr_type_id, tr)
    list = []

    def self.cmd(code, indent, *params)
      c = RPG::EventCommand.new
      c.code   = code
      c.indent = indent
      c.parameters = params
      return c
    end

    # Usamos pbTrainerBattle con el trainer_type para iniciar la batalla
    # Script: pbTrainerIntro(:TR_TYPE)
    list.push(cmd(355, 0, "pbTrainerIntro(:#{tr_type_id})"))
    list.push(cmd(355, 0, "pbNoticePlayer(get_self)"))
    # Conditional Branch: Script: TrainerBattle.start(:TR_TYPE, "Nombre")
    # code 111 = Conditional Branch, parameters[0] = 12 (script), parameters[1] = script string
    list.push(cmd(111, 0, 12, "TrainerBattle.start([:#{tr_type_id}, \"#{tr.name}\",#{tr.version}])"))
    #   Control Self Switch: A = ON
    # code 405 = Control Self Switch, parameters = ["A", 0] (0=ON)
    list.push(cmd(355, 1, 'Console.echo_li($game_self_switches.instance_variable_get(:@data).to_s)'))
    list.push(cmd(355, 1, '$game_self_switches[[$game_map.map_id, get_self.id, "A"]] = true'))
    list.push(cmd(355, 1, '$game_map.need_refresh = true'))
    list.push(cmd(355, 1, 'Console.echo_li($game_self_switches.instance_variable_get(:@data).to_s)'))
    #list.push(cmd(355, 1, "$game_map.need_refresh = true"))
    # Branch End (code 412)
    list.push(cmd(412, 0))
 
    # Script: pbTrainerEnd
    list.push(cmd(355, 0, "pbTrainerEnd"))
 
    # Fin de lista
    list.push(cmd(0, 0))

    return list
  end

  #-----------------------------------------------------------------------------
  # Inicia la batalla con el entrenador dinámico.
  # Tras la batalla, activa Self Switch A para que el evento desaparezca.
  #-----------------------------------------------------------------------------
  def self.start_battle(tr_type_id, event_id)
    # Obtener el evento que disparó la batalla
    event = $game_map.events[event_id]
    return if !event

    # Generar un nombre aleatorio para el entrenador
    tr_type  = GameData::TrainerType.get(tr_type_id)
    gender   = tr_type.gender
    tr_name  = getRandomNameEx(gender, nil, 0, 12)

    # Buscar si hay un entrenador definido en trainers.txt con este tipo
    # Si no existe, crear uno con un equipo generado básico
    trainer = nil
    if GameData::Trainer.exists?(tr_type_id)
      trainer = pbLoadTrainer(tr_type_id, tr_name)
    end

    outcome = 0
    if trainer
      outcome = pbTrainerBattle(tr_type_id, tr_name)
    else
      # Fallback: batalla genérica con Pokémon aleatorios del nivel sugerido
      outcome = pbTrainerBattle(tr_type_id, tr_name, nil, false, 1)
    end

    # Activar Self Switch A independientemente del resultado
    # (el entrenador no vuelve a aparecer hasta el día siguiente)
    self_switch_key = [$game_map.map_id, event_id, "A"]
    $game_self_switches[self_switch_key] = true

    # Ocultar el evento visualmente
    event.erase
  end

  #-----------------------------------------------------------------------------
  # Devuelve un array de [x, y] con los tiles válidos para spawn en el mapa.
  # Un tile es válido si:
  #   1. Es caminable (passage disponible)
  #   2. No tiene ningún evento ya colocado encima
  #-----------------------------------------------------------------------------
  def self.get_valid_spawn_tiles(map_id)
    # Cargar los datos del mapa desde el archivo
    map = load_data(sprintf("Data/Map%03d.rxdata", map_id)) rescue nil
    return [] if !map

    tileset_id = map.tileset_id
    tileset    = load_data("Data/Tilesets.rxdata")[tileset_id] rescue nil
    return [] if !tileset

    # Obtener las posiciones ya ocupadas por eventos estáticos del mapa
    occupied = {}
    map.events.each_value do |ev|
      occupied["#{ev.x},#{ev.y}"] = true
    end

    valid_tiles = []
    map.width.times do |x|
      map.height.times do |y|
        next if occupied["#{x},#{y}"]
        next if !tile_passable?(map, tileset, x, y)
        valid_tiles.push([x, y])
      end
    end

    return valid_tiles
  end

  #-----------------------------------------------------------------------------
  # Comprueba si un tile es caminable consultando los datos de pasaje del tileset.
  # tileset.passages es un objeto RPG Maker Table, no un Array:
  #   - Se accede con passages[tile_id] (sin .size)
  #   - xsize devuelve el número de entradas
  #   - Flag 0x0F = bloqueado en todas las direcciones
  #   - Flag 0x01 (DIRECTION_DOWN) como bit de "infranqueable general" en Essentials
  #-----------------------------------------------------------------------------
  def self.tile_passable?(map, tileset, x, y)
    passages = tileset.passages
    [0, 1, 2].each do |layer|
      tile_id = map.data[x, y, layer]
      next if tile_id.nil? || tile_id == 0
      # Comprobar que el tile_id está dentro del rango de la Table
      next if tile_id >= passages.xsize
      passage = passages[tile_id]
      # 0x0F = bloqueado en todas las direcciones
      return false if passage == 0x0F
      # 0x01 = bit de bloqueo general (usado por Essentials para tiles sólidos)
      return false if (passage & 0x01) != 0
    end
    return true
  end
end

#===============================================================================
# Hook: al terminar la transferencia de mapa, reinyectar los eventos dinámicos.
# on_map_transfer_end se dispara cuando el mapa ya está completamente
# inicializado y $game_map.events está disponible.
#===============================================================================
EventHandlers.add(:on_enter_map, :daily_trainers_reload,
  proc {
    DailyTrainers.reload_events_for_current_map
  }
)