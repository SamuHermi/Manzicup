class PokemonGlobalMetadata
  attr_accessor :achievements, :total_level

  def achievements
    @achievements ||= {}
    @achievements
  end
end

module Achievements
  # IDs determine the order that achievements appear in the menu.
  @achievementList = {
    'STEPS' => {
      'id' => 1,
      'name' => 'Caminante no hay camino',
      'description' => 'Camina por el mundo.',
      'goals' => [10_000, 50_000, 100_000],
      'type' => :DEFENSIVE
    },
    'POKEMON_CAUGHT' => {
      'id' => 2,
      'name' => 'Hazte con todos',
      'description' => 'Captura Pokémon.',
      'goals' => [100, 250, 500],
      'type' => :DEFENSIVE
    },
    'WILD_ENCOUNTERS' => {
      'id' => 3,
      'name' => 'Un Pokémon salvaje apareció',
      'description' => 'Encuentra Pokémon salvajes.',
      'goals' => [250, 500, 1000],
      'type' => :DEFENSIVE
    },
    'TRAINER_BATTLES' => {
      'id' => 4,
      'name' => 'Duelo a muerte con Pokémon',
      'description' => 'Haz peleas contra entrenadores.',
      'goals' => [100, 250, 500],
      'type' => :OFFENSIVE
    },
    'MEGA_EVOLUTIONS' => {
      'id' => 5,
      'name' => 'Experto en la Mega Evolución',
      'description' => 'Mega Evoluciona Pokémon.',
      'goals' => [1, 25, 100],
      'type' => :DEFENSIVE
    },
    'ITEM_BALL_ITEMS' => {
      'id' => 6,
      'name' => 'Acaparando',
      'description' => 'Encuentra objetos.',
      'goals' => [50, 100, 250],
      'type' => :DEFENSIVE
    },
    'GACHA' => {
      'id' => 7,
      'name' => 'Adicto al gachapón',
      'description' => 'Haz tiradas en un gacha.',
      'goals' => [50, 100, 250],
      'type' => :DEFENSIVE
    },
    'DUELO' => {
      'id' => 10,
      'name' => 'Es hora del duelo',
      'description' => 'Gana duelos de Triple Triad.',
      'goals' => [1],
      'type' => :DEFENSIVE
    },
    'OTAKA' => {
      'id' => 11,
      'name' => 'Onii-chan, aishiteruyo',
      'description' => 'Obtén la primera medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'BBEG' => {
      'id' => 12,
      'name' => 'Juego cortito, ¿No?',
      'description' => 'Obtén la segunda medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'KNEKRO' => {
      'id' => 12,
      'name' => 'Variety god',
      'description' => 'Obtén la tercera medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'AMONGUS' => {
      'id' => 13,
      'name' => 'Un poco sus',
      'description' => 'Obtén la cuarta medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'GYM' => {
      'id' => 14,
      'name' => 'Gymrat',
      'description' => 'Obtén la quinta medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'MONSTRUO' => {
      'id' => 15,
      'name' => "It's a Wild World",
      'description' => 'Obtén la sexta medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'CR7' => {
      'id' => 16,
      'name' => 'Ancara, ancara',
      'description' => 'Obtén la séptima medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'MUSTIO' => {
      'id' => 17,
      'name' => 'PEAK fiction',
      'description' => 'Obtén la octava medalla.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'BEATO' => {
      'id' => 19,
      'name' => 'Ooooh, Beatooooricheeeee',
      'description' => 'Derrota a Iria-BEATRICE en el estudio de Kinzo.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'SAKU' => {
      'id' => 20,
      'name' => 'Best Loli Ilegal',
      'description' => 'Derrota a Saku en la cárcel.',
      'goals' => [1],
      'type' => :OFFENSIVE
    },
    'THIRTREP' => {
      'id' => 21,
      'name' => 'Ara ara',
      'description' => 'Derrota a Thirtrep en la sauna.',
      'goals' => [1],
      'type' => :DEFENSIVE
    },
    'ISSSABEL' => {
      'id' => 22,
      'name' => 'No hay antídoto contra mí',
      'description' => 'Derrota a Issabel en la cueva de la sierpe.',
      'goals' => [1]
    },
    'COLON' => {
      'id' => 23,
      'name' => 'Mentalidad de tiburón',
      'description' => 'Derrota a Sabo Colón en La Niña.',
      'goals' => [1]
    },
    'MERMI' => {
      'id' => 24,
      'name' => 'Como luciérnagas a la luz',
      'description' => 'Derrota a Mermi en Colonipenal.',
      'goals' => [1]
    },
    'BABATUNDE' => {
      'id' => 25,
      'name' => 'Larga vida al rey',
      'description' => 'Derrota a Babatunde en Babatundra.',
      'goals' => [1]
    },
    'PAXAXA' => {
      'id' => 26,
      'name' => 'Amiga soy vegana',
      'description' => 'Derrota a Paxaxa en la granja.',
      'goals' => [1]
    },
    'LIANTE' => {
      'id' => 27,
      'name' => 'El cubata no volverá',
      'description' => 'Derrota al Liante en Churruca.',
      'goals' => [1]
    },
    'NEREA' => {
      'id' => 28,
      'name' => 'El cubata no volverá',
      'description' => 'Derrota a  en .',
      'goals' => [1]
    },
    'DUNGEONS' => {
      'id' => 29,
      'name' => 'Mamones y mazmorras',
      'description' => 'Adentráte en la mazmorra',
      'goals' => [10, 25]
    },
    'EVOLUTION' => {
      'id' => 30,
      'name' => 'Aktuali, ez una metamorfozi',
      'description' => 'Evoluciona Pokémon',
      'goals' => [13, 50]
    }
  }
  def self.list
    Achievements.fixAchievements
    @achievementList
  end

  def self.fixAchievements
    @achievementList.keys.each do |a|
      $PokemonGlobal.achievements[a] = {} if $PokemonGlobal.achievements[a].nil?
      $PokemonGlobal.achievements[a]['progress'] = 0 if $PokemonGlobal.achievements[a]['progress'].nil?
      $PokemonGlobal.achievements[a]['level'] = 0 if $PokemonGlobal.achievements[a]['level'].nil?
    end
    $PokemonGlobal.achievements.keys.each do |k|
      $PokemonGlobal.achievements.delete(k) unless @achievementList.keys.include? k
    end
  end

  def self.incrementProgress(name, amount)
    Achievements.fixAchievements
    raise 'Undefined achievement: ' + name.to_s unless @achievementList.keys.include? name

    if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]['progress'].nil?
      $PokemonGlobal.achievements[name]['progress'] += amount
      checkIfLevelUp(name)
      true
    else
      false
    end
  end

  def self.decrementProgress(name, amount)
    Achievements.fixAchievements
    raise 'Undefined achievement: ' + name.to_s unless @achievementList.keys.include? name

    if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]['progress'].nil?
      $PokemonGlobal.achievements[name]['progress'] -= amount
      $PokemonGlobal.achievements[name]['progress'] = 0 if $PokemonGlobal.achievements[name]['progress'] < 0
      true
    else
      false
    end
  end

  def self.setProgress(name, amount)
    Achievements.fixAchievements
    raise 'Undefined achievement: ' + name.to_s unless @achievementList.keys.include? name

    if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]['progress'].nil?
      $PokemonGlobal.achievements[name]['progress'] = amount
      $PokemonGlobal.achievements[name]['progress'] = 0 if $PokemonGlobal.achievements[name]['progress'] < 0
      checkIfLevelUp(name)
      true
    else
      false
    end
  end

  def self.checkIfLevelUp(name)
    Achievements.fixAchievements
    raise 'Undefined achievement: ' + name.to_s unless @achievementList.keys.include? name

    if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]['progress'].nil?
      level = @achievementList[name]['goals'].length
      @achievementList[name]['goals'].each_with_index do |g, i|
        if $PokemonGlobal.achievements[name]['progress'] < g
          level = i
          break
        end
      end
      if level > $PokemonGlobal.achievements[name]['level']
        $PokemonGlobal.achievements[name]['level'] = level
        pbSEPlay('Mining reveal full')
        $PokemonGlobal.total_level += 1
        queueMessage(_INTL("¡Logro actualizado!\n{1}", @achievementList[name]['name']))
        Console.echo_li($PokemonGlobal.total_level.to_s)
        if $PokemonGlobal.achievements[name]

        else

        end
        true
      else
        false
      end
    else
      false
    end
  end

  def self.getCurrentGoal(name)
    Achievements.fixAchievements
    raise 'Undefined achievement: ' + name.to_s unless @achievementList.keys.include? name

    if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]['progress'].nil?
      @achievementList[name]['goals'].each_with_index do |g, i|
        return g if $PokemonGlobal.achievements[name]['progress'] < g
      end
      nil
    else
      0
    end
  end

  def self.queueMessage(msg)
    $achievementmessagequeue = [] if $achievementmessagequeue.nil?
    $achievementmessagequeue.push(msg)
  end
end
