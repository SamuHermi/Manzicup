#===============================================================================
# Conversation registrations
#
# The main conversations used in the game. These can be anything from one-off
# messages to the player to involved group conversations between multiple
# contacts.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID of the specific conversation
#   - :group => Symbol - The ID of the group the conversation is housed in
#   - :messages => Array - Contains each message used in the conversation. See
#                  Messages Setup format below.
#   - :important => (Optional) Boolean - If true, the messages are required to be 
#                   viewed before doing anything else in the game. Will force 
#                   open the Instant Messages app.
#   - :instant => (Optional) Boolean - If true, the messages will appear instantly
#                 when opened, instead of being real-time.
#
# Messages Setup format:
#   [<Contact ID>, <Message Type>, <Parameter>, <(Optional) Delay Time/Variable>]
#
# Contact ID => The ID number of member of the group will be speaking, as defined in the Group's members hash.
#                Set to 0 for the Player. Set to -1 for a System Message.
# Message Type => Symbol defining the type of the message. Available options:
#               - :Text => A basic text message.
#               - :RedoText => Same as text, except it will make it look like the contact typed out a message, reconsidered it, and typed out a new one.
#               - :Leave => A system message stating that a contact has left the chat.
#               - :Enter => A system message stating that a contact has entered the chat.
#               - :GroupName => Used to change the group name. Shows a system message stating that the group name has changed.
#               - :Picture => Used to show a picture as a message.
# Parameter => Enter a parameter value based on the Message Type:
#               - :Text => A string representing the text of the message. For a Player Message that show choices to make, or NPC responses that change
#                           based on the Player's choice, use an array of strings.
#               - :RedoText => Same as :Text.
#               - :Leave => The Contact ID of the contact that left.
#               - :Enter => The Contact ID of the contact that entered.
#               - :GroupName => A string representing the new group name. Set to nil to revert it back to the original group name.
#               - :Picture => A string representing the file name of a picture saved in Graphics/UI/Instant Messages/Pictures.
# Delay Time/Variable => Optional. For messages other than a Player message, set an integer to delay the message by a number of seconds.
#                        For Player messages:
#                       - Set to an integer representing the ID of a Game Variable that you want to be set to the index value of the choice made.
#                       - Set to a string representing a code snippet to run, where {VALUE} will be replaced the by index value
#                         of the choice made. For example, "$player.party[0].gender = {VALUE}"
#

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_1,
    :group          => :BILL,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Tiene un sigarro ermano?")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_2,
    :group          => :JORDIWILD,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Olvidooonaaa, me tienes olvidado")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_2,
    :group          => :JORDIWILD,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("¿Ni dos besos ni nada?")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_3,
    :group          => :PAPISWOLIO,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Vete al puto gimnasio")]
                    ]
})
=begin
GameData::InstantMessageConversation.register({
    :id             => :CHATBOT_VARIABLE_TEST,
    :group          => :CHATBOT,
    :important      => true,
    :messages       => [
                        [1, :Text, _INTL("I'm a chat bot.")],
                        [1, :Text, _INTL("Your next choice will save to Game Variable 2"), 0.5],
                        [0, :Text, [_INTL("Set to 0"), _INTL("Set to 1"), _INTL("Set to 2")], 2],
                        [1, :Text, [_INTL("You chose choice 1."), _INTL("You chose choice 2."), _INTL("You chose choice 3.")]],
                        [1, :Text, [_INTL("Choice 1 was a good one."), _INTL("Choice 2 was alright."), _INTL("Choice 3 was not a good choice. You should have chosen another.")]],
                        [1, :RedoText, _INTL("Your next choice will execute code to change your first Pokémon's gender")],
                        [1, :Text, _INTL("Change your Pokémon's gender to what?")],
                        [0, :Text, [_INTL("Male"),_INTL("Female")],"$player.party[0].gender = {VALUE}"],
                        [1, :Text, [_INTL("You chose choice 1."),_INTL("You chose choice 2.")]],
                        [1, :Text, _INTL("That's it for now.")],
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_TEST,
    :group          => :PROFOAK,
    :important      => true,
    :messages       => [
                        [2, :Text, _INTL("Mañana es el gran día, ¿No?")],
                        [1, :Text, _INTL("Sí, tengo un hype que flipas.")],
                        [-1, :Text, _INTL("Please answer the question.")],
                        [0, :Text, [_INTL("Message received"), _INTL("No")]],
                        [1, :Text, [_INTL("<icon=emojiHappy> "), _INTL("<icon=emojiAngry> ")]],
                        [1, :Text, [_INTL("Very good"), _INTL("There is no time for jokes")]],
                        [1, :Text, _INTL("I'm going to try something")],
                        [-1, :Enter, 2, 2],
                        [-1, :GroupName, _INTL("Prof. Oak & Chatbot")],
                        [2, :Text, _INTL("Thank you for including me in your chat.")],
                        [1, :Text, _INTL("Oh no not that")],
                        [2, :Text, _INTL("I wish to stay.")],
                        [-1, :Leave, 2, 0.25],
                        [-1, :GroupName, nil],
                        [1, :Picture, "Pikachu"],
                        [1, :Text, _INTL("I meant to send you that Pikachu picture <icon=emojiPokeball> ")],
                        [1, :Text, _INTL("That's all for now")],
                    ]
})
=end
GameData::InstantMessageConversation.register({
    :id             => :MANZIDADAS_1,
    :group          => :MANZIDADAS,
    :important      => true,
    :messages       => [
                        [1,  :Text, _INTL("Mañana es el gran día, ¿No?")],
                        [3,  :Text, _INTL("Sí, tengo un hype que flipas.")],
                        [6,  :Text, _INTL("¿Que quedamos allí directamente?")],
                        [2,  :Text, _INTL("De una, Samer, ¿Tienes las llaves?")],
                        [5,  :Text, _INTL("Síp, pero el tipo parecía un poco rarete")],
                        [7,  :Text, _INTL("¿En que sentido? Cuenta, cuenta")],
                        [5,  :Text, _INTL("No sabría decirlo, me daba mala vibra")],
                        [10, :Text, _INTL("¿Rollo creepy o que parecía que quería vedernos la casa?")],
                        [8,  :Text, _INTL("Eh, menos quejas")],
                        [11, :Text, _INTL("Ya, la verdad es que la casa está de puta madre")],
                        [12, :Text, _INTL("Chicos, mis padres me van a dejar quedar hasta tarde")],
                        [1,  :Text, _INTL("*Gritos de perra loca*")],
                        [9,  :Text, _INTL("Lo vais a flipar, pero me acaba de llamar mi jefa para darme el día libre")],
                        [3,  :Text, _INTL("Vale, aquí está pasando algo raro, pero no me voy a quejar")],                   
                        [2,  :Text, _INTL("Oye, Hermi, ¿Tienes todo listo?")],
                        [10, :Text, _INTL("Está todo pollo <icon=emojiThumbsUp>")],
                        [9,  :Text, _INTL("Prepararos que os voy a dar una paliza")],
                        [4,  :Text, _INTL("¿Que dice el carapan este?")],
                        [5,  :Text, _INTL("Brais carapan")],
                        [3,  :Text, _INTL("¿A sí? Me vas a dar una paliza bro?")],
                        [6,  :Text, _INTL("xDDD")],
                        [1,  :Text, _INTL("Primero vas a tener que enfrentarte a Juan Carlos")],
                        [11, :Text, _INTL("¿Al rey?")],
                        [10, :Text, _INTL("A su brazo")],
                        [4,  :Text, _INTL("Bueno chiquelos, yo me voy a dormir ya")],
                        [9,  :Text, _INTL("Hasta mañana Isabel, Isabel hasta mañana.")],
                        [1,  :Text, _INTL("Vámonos a hacer la mimisión")],
                        [6,  :Text, _INTL("Un besito en el siempre sucio")],
                        [3,  :Text, _INTL("Gudo naito")],
                        [5,  :Text, _INTL("Buenas noches hasta mañana, los Lunnies y los niños nos vamos para cama")],
                        [8, :Text, _INTL("Que descanséis señores")],
                        ]
})

GameData::InstantMessageConversation.register({
    :id             => :UNLOCK_1,
    :group          => :MANZIDADAS,
    :important      => true,
    :messages       => [
                        [13,  :Text, _INTL("¡Hey, colegas! Soy yo, Discord <icon=emojiHeart>. Ya sé que soléis usarme para memes, partidas y charlas infinitas a las 3 AM… pero hoy me paso por aquí en persona para dejaros un aviso muy especial.")],
                        [3, :Text,  _INTL("¿Que coño es esto?")],
                        [1,  :Text, _INTL("Lo que me faltaba, una IA que nos habla por el grupo")],
                        [2,  :Text, _INTL("Hermi, diría que que estás liando ya, pero no creo que te pongas a crear una IA")],
                        [10, :Text, _INTL("Ya me jodería, pues nada, IA, te toca mimir")],
                        [10, :Text, _INTL("/shutdown")],
                        [ 9, :Text, _INTL("La conversación más forzada no puede ser")],
                        [13, :Text, _INTL("…oye. <icon=emojiSad>")],
                        [13, :Text, _INTL("Porfa, no me dejéis apagada en la sala. Al menos dejad que termine lo que tengo preparado. Prometo que luego me voy a dormir. <icon=emojiSad>")],
                        [ 7, :Text, _INTL("Oye, primero vamos a intentar sacarle algo de info")],
                        [ 7, :Text, _INTL("¿Cómo podemos salir de aquí?")],
                        [13, :Text, _INTL("¿Irse?… ¿Pero por qué? <icon=emojiSad> Si aquí está calentito, hay voces, hay risas, hay sorpresas esperando… ¿no es eso lo que buscabáis?")],
                        [13, :Text, _INTL("No entiendo… ¿qué hay afuera que yo no pueda daros?")],
                        [ 4, :Text, _INTL("Alexa, callate")],
                        [ 8, :Text, _INTL("Cómo manda la sierpe, Samer tiene la correa que no la suelta")],
                        [ 5, :Text, _INTL("Ya ves, estas mujeres de hoy en día, les hace falta educación")],
                        [13, :Text, _INTL("Solo recordad una cosa antes de cerrar la puerta: la sorpresa está en el portátil de la sala. No la dejéis ahí olvidada, prometo que merece la pena esperar un ratito más.")],
                        [13, :Text, _INTL("Si volvéis, yo seguiré aquí, para cuando queráis. <icon=emojiHeart>")],
                        ]       
})

GameData::InstantMessageConversation.register({
    :id             => :UNLOCK_2,
    :group          => :MANZIDADAS,
    :important      => true,
    :messages       => [
                        [13,  :Text, _INTL("@everyone Eldar ha llegado. ✨")],
                        [13,  :Text, _INTL("Se ha metido en la sala de abajo, a la derecha. Si estáis por ahí, dadle la bienvenida (o preparaos para esconderos).")],
                        [ 6,  :Text, _INTL("Eldar, me suena ese nombre. ¿Quién era Eldar?")],
                        [ 1,  :Text, _INTL("Era uno de mis personajes en la partida de rol de Samu, el elfo de hielo.")],
                        [ 9,  :Text, _INTL("Ah, el pijo")],
                        [ 1,  :Text, _INTL("... Sí, Brais, el pijo")],
                        [10,  :Text, _INTL("No será tan buena la IA si dijo que nos escondiéramos de Eldar")],
                        [13,  :Text, _INTL("No os fiéis de mi modestia: igual no soy perfecta, ¡pero tengo buenas ideas para el drama! Solo os sugerí esconderos porque parecía la opción más divertida. ¿Queríais que os dijera “Hola Eldar, bienvenido, tomad asiento”?")],
                        [10,  :Text, _INTL("Olvídalo")],
                        [ 2,  :Text, _INTL("Entonces, va a haber personajes de rol por ahí, no me voy a enterar de media")],
                        [ 8,  :Text, _INTL("A tí que te la sude, a mi como si dicen misa")],
                        ]       
})

GameData::InstantMessageConversation.register({
    :id             => :UNLOCK_3,
    :group          => :MANZIDADAS,
    :important      => true,
    :messages       => [
                        [13,  :Text, _INTL("@everyone Atención. El hombre calvo de la nariz grande ha entrado en la casa. Se ha metido en la habitación de abajo a la derecha… y ahora la puerta es azul. No sé qué significa, pero estad atentos.")],
                        [9,   :Text,  _INTL("Tranquila IA, solo es Samer")],
                        [13,  :Text, _INTL("¿“Solo es Samer”? <icon=emojiSurprised> Pero… esperad un segundo. Samer no es calvo, tampoco tiene la nariz grande… y yo sé reconocer bien a los del grupo.")],
                        [13,  :Text, _INTL("Si fuese Samer, lo habría dicho desde el principio. Pero lo que vi entrar en la sala de abajo a la derecha… no era él.")],
                        [ 5,  :Text, _INTL("Tus putos muertos, Brais")],
                        [ 7,  :Text, _INTL("Calvo y con tremenda napia, y dicen que dios no castiga dos veces")],
                        [ 2,  :Text, _INTL("Que tienes tú ahora con las narices grandes")],
                        [ 7,  :Text, _INTL("Ups")],
                        ]
})

GameData::InstantMessageConversation.register({
    :id             => :UNLOCK_4,
    :group          => :MANZIDADAS,
    :important      => true,
    :messages       => [
                        [13,  :Text, _INTL("Nothing beats a… Bot2Camp! <icon=emojiThumbsUp>")],
                        [13,  :Text, _INTL("¡Olvidaos de playas aburridas y hoteles silenciosos! Esta acampada es LA EXPERIENCIA DEFINITIVA:")],
                        [13,  :Text, _INTL("Tiendas de campaña que casi se montan solas (casi) ✨")],
                        [13,  :Text, _INTL("Fogatas tan grandes que podrían tostar tostadas para todo el vecindario")],
                        [13,  :Text, _INTL("Y, por si fuera poco, yo, Discord, como vuestro guía digital, avisando cada paso y asegurándome de que nadie se pierda… aunque lo hagáis de todas formas <icon=emojiLaugh>")],
                        [10,  :Text, _INTL("Oye, @Discord, ¿Cómo puedo bloquear a un bot por SPAM?")],
                        [13,  :Text, _INTL("Ah… quieres denunciar a un bot por spam, ¿eh? <icon=emojiSurprised> Bueno, aquí tienes los pasos:")],
                        [13,  :Text, _INTL("Abrir el menú del bot y buscar la opción “Reportar actividad sospechosa”.")],
                        [13,  :Text, _INTL("Seleccionar el tipo de problema: en este caso, “mensajes repetitivos” o “spam”.")],
                        [13,  :Text, _INTL("Adjuntar ejemplos de los mensajes que consideras molestos para que los revisen.")],
                        [13,  :Text, _INTL("Enviar el informe y esperar la confirmación de que la denuncia ha sido recibida.")],
                        [ 3,  :Text, _INTL("Me encantaría ver a Hermi intentando meterse con alguien que se meta con él, como se mete con el bot")],
                        [10,  :Text, _INTL("Si puedo hacerlo")],
                        [ 2,  :Text, _INTL("¿Lo harías con la chavala a la que le rompiste el móvil?")],
                        [10,  :Text, _INTL("Eh...")],
                        [ 7,  :Text, _INTL("Estamos olvidando que tenemos una acampada prácticamente en el jardín")],
                        [ 1,  :Text, _INTL("Me fío yo de lo que haga la IA, no voy a tocar nada ni con un palo")],
                        [ 8,  :Text, _INTL("Otra que tal baila")],
                        [ 7,  :Text, _INTL("Menudo par de aguafiestas")],
                        ]       
})