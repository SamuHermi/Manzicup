#===============================================================================
# Game data for cheers.
#===============================================================================
module GameData
  class Cheer
    attr_reader :id
    attr_reader :real_name
	attr_reader :icon_position
    attr_reader :command_index
    attr_reader :mode
    attr_reader :cheer_text
	attr_reader :description

    DATA = {}
    
    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || "Unnamed"
	  @icon_position = hash[:icon_position] || 0
	  @command_index = hash[:command_index] || -1
      @mode          = hash[:mode]          || 0
      @cheer_text    = hash[:cheer_text]    || ""
	  @description   = hash[:description]
    end

    def name;        return _INTL(@real_name);   end
    def cheer_text;  return _INTL(@cheer_text);  end
	
	def description(level)
	  return _INTL("") if !@description
	  return @description[level]
	end
    
    def self.get_cheer_for_index(index, mode = 0)
      cheer = self.get(:None)
	  self.each do |c|
        next if c.command_index != index
        cheer = c if c.mode == 0
		if c.mode == mode
		  cheer = c
		  break
		end
      end
      return cheer
    end
  end
end

#===============================================================================

GameData::Cheer.register({
  :id            => :None,
  :name          => _INTL("None")
})

GameData::Cheer.register({
  :id            => :Offense,
  :name          => _INTL("Ánimo ofensivo"),
  :icon_position => 1,
  :command_index => 0,
  :cheer_text    => _INTL("¡Dale con todo!"),
  :description   => [_INTL("Requiere Ánimo nivel 1 o más."),
                     _INTL("Aumenta el daño inflingido."),
					 _INTL("Aumenta la potencia de los movimientos."),
					 _INTL("Los movimientos pueden penetrar las barreras.")]
})

GameData::Cheer.register({
  :id            => :Defense,
  :name          => _INTL("Ánimo defensivo"),
  :icon_position => 2,
  :command_index => 1,
  :cheer_text    => _INTL("¡Aguanta que voy!"),
  :description   => [_INTL("Requiere Ánimo nivel 1 o más."),
                     _INTL("Reduce el daño recibido."),
					 _INTL("Es inmune a los efectos de los movimientos."),
					 _INTL("Aguanta golpes fatales.")]
})

GameData::Cheer.register({
  :id            => :Healing,
  :name          => _INTL("Ánimo curativo"),
  :icon_position => 3,
  :command_index => 2,
  :cheer_text    => _INTL("¡Curitas!"),
  :description   => [_INTL("Requiere Ánimo nivel 1 o más."),
                     _INTL("Cura unos pocos PS."),
					 _INTL("Cura los estados y unos pocos PS."),
					 _INTL("Cura completamente al equipo.")]
})

GameData::Cheer.register({
  :id            => :Counter,
  :name          => _INTL("Ánimo de gambito"),
  :icon_position => 4,
  :command_index => 3,
  :cheer_text    => _INTL("Dale la vuelta a esto!"),
  :description   => [_INTL("Requiere Ánimo nivel 1 o más."),
                     _INTL("Invierte los cambios en las estadísticas."),
					 _INTL("Cambia los efectos de campo."),
					 _INTL("Elimina y baplica Anticura.")]
})

GameData::Cheer.register({
  :id            => :BasicRaid,
  :name          => _INTL("Ánimo básico"),
  :icon_position => 5,
  :command_index => 3,
  :mode          => 1,
  :cheer_text    => _INTL("Keep it going!"),
  :description   => [_INTL("Requiere Ánimo nivel 2 o más."),
                     _INTL("Requiere Ánimo nivel 2 o más."),
					 _INTL("Aumenta el número máximo de turnos."),
					 _INTL("Aumenta el número máximo de turnos y KOs.")]
})

GameData::Cheer.register({
  :id            => :UltraRaid,
  :name          => _INTL("Ultra ánimo"),
  :icon_position => 6,
  :command_index => 3,
  :mode          => 2,
  :cheer_text    => _INTL("¡Enséñales tu burst!"),
  :description   => [_INTL("Requiere Ánimo nivel MÁX."),
                     _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Te permite usar un movimiento Z.")]
})

GameData::Cheer.register({
  :id            => :MaxRaid,
  :name          => _INTL("Max Raid Cheer"),
  :icon_position => 7,
  :command_index => 3,
  :mode          => 3,
  :cheer_text    => _INTL("Let's Dynamax!"),
  :description   => [_INTL("Requiere Ánimo nivel MÁX."),
                     _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Te permite usar el Dinamax.")]
})

GameData::Cheer.register({
  :id            => :TeraRaid,
  :name          => _INTL("Tera Raid Cheer"),
  :icon_position => 8,
  :command_index => 3,
  :mode          => 4,
  :cheer_text    => _INTL("¡Te falta brilli brilli!"),
  :description   => [_INTL("Requiere Ánimo nivel MÁX."),
                     _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Requiere Ánimo nivel MÁX."),
					 _INTL("Te permite usar la Terastalización.")]
})