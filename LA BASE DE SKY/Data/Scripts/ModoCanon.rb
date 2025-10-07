

def pbGiveModoCanonMons(legendarios = false)
  Console.echo_li("=== INICIANDO FUNCIÓN DE MODO CANON ===")
  mons = [
  #Hermi
  [:ARTICUNO, :AMPHAROS, :BRELOOM, :EMPOLEON, :SERPERIOR, :GOODRA, :SOLGALEO, :EISCUE, :SKELEDIRGE, 
  :TERAPAGOS, :RESHIRAM, :LAPRAS, :VENUSAUR, :RAICHU, :AURORUS, :BEWEAR, :IRONMOTH, :GASTRODON, :TOGEKISS, 
  :AZELF, :VOLCARONA, :MINIOR, :DECIDUEYE, :DRAGONITE, :MABOSSTIFF, :COBALION, :ALTROPARIA],
  #Iria
  [],
  #¿Quien?
  [],
  #Brais
  [],
  #Isa
  [],
  #Samer
  [],
  #Bra
  [],
  #Ana
  [],
  #Pablo
  [],
  #Sabo
  [],
  #Nerea
  [],
  ]
  team = mons[$player.character_ID - 1]
  Console.echo_li("Equipo seleccionado: #{team}")
    # Pausa 1 segundo (60 frames)
  Console.echo_li("Tamaño del equipo: #{team.length}")
  
  
  team.each_with_index do |mon, index|
    Console.echo_li("=== Procesando índice #{index}: #{mon} ===")

    
    Console.echo_li("1. Creando Pokemon: #{mon}...")
    
    poke = Pokemon.new(mon)
    next if poke.species_data.flags.include?("Legendary") ||  poke.species_data.flags.include?("Mythical")
    Console.echo_li("2. Pokemon creado exitosamente")
    
    
    Console.echo_li("3. Estableciendo texto...")
    
    poke.obtain_text = "Lo tenías antes de llegar."
    Console.echo_li("4. Texto establecido")
    
    
    Console.echo_li("5. Reset moves...")
    
    poke.reset_moves
    Console.echo_li("6. Moves reseteados")
    
    
    Console.echo_li("7. Calc stats...")
    
    poke.calc_stats
    Console.echo_li("8. Stats calculados")
    
    
    Console.echo_li("9. Estableciendo level...")
    
    poke.level = 100
    Console.echo_li("10. Level establecido")
    
    
    Console.echo_li("11. Estableciendo IV...")
    
    poke.iv = 31
    Console.echo_li("12. IV establecido")
    
    
    Console.echo_li("13. Recibiendo Pokemon...")
    
    pbReceivePokemon(poke)
    Console.echo_li("14. Pokemon recibido - FIN índice #{index}")
  end
  
  Console.echo_li("=== FUNCIÓN COMPLETADA ===")
end
