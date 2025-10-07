#===============================================================================
# Sistema global de acumulación de monedas
#===============================================================================
class GlobalCoinGenerator
  attr_accessor :coins
  attr_accessor :time_last_updated

  COINS_PER_HOUR = 2   # cantidad de monedas acumuladas por hora

  def initialize
    reset
  end

  def reset
    @coins = 0
    @time_last_updated = pbGetTimeNow.to_i
  end

  # Calcula cuántas monedas se han acumulado desde la última vez
  def update
    time_now = pbGetTimeNow.to_i
    time_delta = time_now - @time_last_updated
    return if time_delta <= 0
    hours_passed = time_delta / 3600
    if hours_passed > 0 && hours_passed <= 48
      @coins += hours_passed * COINS_PER_HOUR
      @time_last_updated += hours_passed * 3600
      @time_last_updated = time_now
    elsif hours_passed > 48 && hours_passed <= (24*7)
      @coins += 48 + (hours_passed-48* (COINS_PER_HOUR/2).floor)
      @time_last_updated = time_now
    else
      @time_last_updated = 100
    end
  end

  # Recoge todas las monedas acumuladas y las suma al dinero del jugador
  def collect
    update
    if @coins > 0
      amount = @coins
      $player.battle_points += amount
      @coins = 0
      pbMessage(_INTL("¡Has recogido {1} monedas!", amount))
    else
      pbMessage(_INTL("No hay monedas acumuladas."))
    end
    
  end

  # Solo consultar cuántas hay acumuladas
  def check
    update
    return @coins
  end
end

#===============================================================================
# Crear acceso global
#===============================================================================
def pbCoinGenerator
  $PokemonGlobal.coinGenerator = GlobalCoinGenerator.new if !$PokemonGlobal.coinGenerator
  return $PokemonGlobal.coinGenerator
end