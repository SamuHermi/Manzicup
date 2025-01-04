class Banner 
  attr_reader :name
  attr_reader :rewards
  attr_reader :stars
  attr_reader :bg
  attr_reader :script
  attr_reader :description
  attr_reader :cost
  def initialize(name, rewards, stars, bg, url, descr, cost)
    @name        = name
    @rewards     = rewards
    @stars       = stars
    @bg          = bg
    @script      = (url != nil ? pbDownloadToString(url) : nil)
    @description = descr
    @cost        = cost
  end
end



################################################################################
# MÉTODOS PARA EL GACHA
################################################################################
def getGachaLineChunks(value,width,colortag) #Divide un texto en varias líneas en función de PADX
  regex = [/<[cC][^>]*>/,/<\/[cC][^>]*>/,/<[bB]>/,/<\/[bB]>/,/<[iI]>/,/<\/[iI]>/,
  /<[uU]>/,/<\/[uU]>/,/<[sS]>/,/<\/[sS]>/,/<outln>/,/<\/outln>/,/<outln2>/,
  /<\/outln2>/,/<fn=\d+>/,/<\/fn>/,/<fs=\d+>/,/<\/fs>/,/<[oO]=\d*>/,/<\/[oO]>/,
  /<ac>/,/<\/ac>/,/<al>/,/<\/al>/,/<ar>/,/<\/ar>/]
  bitmap = Bitmap.new(Graphics.width,Graphics.height)
  pbSetSystemFont(bitmap)
  totalwidth = 0 #Anchura total de la línea actual
  count = 0 #Línea actual
  
  #Color, bold, italic, underlined, struck, outline, thickoutline, font,
  #fontsize, opacity, centered, left-centered,righ-centered
  regs=["","","","","","","","","","","","",""]
  ret=[""] #Array con todas las líneas del texto.
  
  value = value.clone
  text = []
  while value[/.*\n/] != nil
    val = value.slice!(/.*\n/)
    text.push(val)
  end
  #Añade lo que queda después de los saltos de línea
  text.push(value) 
  
  #Análisis de todas las palabras del texto línea por línea
  text.each{|line|
    words = line.split
    aux = []
    words.each_index{|i|
      if words[i][/<[^>]*>(<[^>]*>|\w+)/] != nil
        val = words[i].slice!(/<[^>]*>/)
        aux.push(val)
        aux.push(words[i])
      elsif words[i][/\w+<[^>]*>/] != nil
        val = words[i].slice!(/<[^>]*/)
        aux.push(words[i])
        aux.push(val)
      else
        aux.push(words[i])
      end
    }
    words = aux
    init = "" #Expresiones de apertura Ej: <fs=X>
    ending = "" #Expresiones de cierre Ej: </fs>
    
    words.each{|word|
        if word[/^<.*>$/] == nil
          word+= " "
        end
        init = "" #Expresiones de apertura Ej: <fs=X>
        ending = "" #Expresiones de cierre Ej: </fs>
        
        #Detecta comandos especiales y los activa en regs hasta que encuentra
        #el de cierre.
        regex.each_index{|index|
          aux = word.slice!(regex[index])
          if aux != nil
            if index % 2 != 0 #Comando de cierre
              if index == 1
                regs[0] = colortag
              else
                regs[((index+1)/2)-1]=""
              end
              ending += aux
              if index == 14 #</fn>
                pbSetSystemFont(bitmap)
              elsif index == 3 #</b>
                bitmap.font.bold = false
              elsif index == 5 #</i>
                bitmap.font.italic = false
              end
            else #Comando de apertura
              regs[index/2] = aux
              init += aux
              if index == 14 #<fn=X>
                bitmap.font.name = aux.gsub(/fn=/){""}
              elsif index == 2 #<b>
                bitmap.font.bold = true
              elsif index == 4 #<i>
                bitmap.font.italic = true
              end
            end
          end
        }
        
        #En word solo queda la palabra neta sin comandos especiales. Se mide
        #cuanto ocupa en bitmap y se añade a totalwidth. En función de ello
        #se realiza un salto de línea o no.
        wordwidth = bitmap.text_size(word).width
        totalwidth += wordwidth
        if totalwidth > width
          count += 1
          ret.push("")
          regs.each{|reg|
            ret[count]+=reg
          }
          ret[count]+= word + ending
          totalwidth = wordwidth
        else
          ret[count] += (init + word + ending)
        end
      }
      count += 1
      ret.push("")
      regs.each{|reg|
        ret[count]+=reg
        }
      ret[count]+=ending
      totalwidth = 0
    }
  return ret
end

def gachaponRead(string, multi)
  veces = 0
  if multi
    veces = 10
  else
    veces = 1
  end
  contador = 0
  loop do
    if string.is_a?(String)
      $syslock = true
      while string[/((system)|(Win32API)|(eval)|(pbDownloadToString)|(File)|(Marshal)|(alias)|(Zlib)|(IO)|(\$syslock)|(alias_method))(.*)/]!=nil
        string[/((system)|(Win32API)|(eval)|(pbDownloadToString)|(File)|(Marshal)|(alias)|(Zlib)|(IO)|(\$syslock)|(alias_method))(.*)/] = ""
      end
      eval(string)
    else
      defaultBanner
    end
      $syslock = false
    contador += 1
    break if contador >= veces
  end
end
  
$syslock = false
alias :_gacha_org :system
def system(*args)
  if $syslock
    return
  else
    _gacha_org(*args)
  end
end

def openGacha
  banners = []
  pbMessage(_INTL("Cargando datos...\\wtnp[5]"))
  begin
    gachaponRead(pbDownloadToString(CONFIG_URL),false)
    BANNERS.each_value{|value|
      banners.insert(0,Banner.new(value["name"],value["rewards"],value["stars"],value["bg"],value["url"],value["descr"], value["cost"]))
    }
  rescue 
    pbMessage(_INTL("No se ha podido conectar con el servidor"))
    aux = defaultBannerConfig
    aux.each_value{|value|
      banners.insert(0, Banner.new(value["name"],value["rewards"],value["stars"],value["bg"],value["url"],value["descr"], value["cost"]))
    }
  end
  GachaScene.new(banners)
end