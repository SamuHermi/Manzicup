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
    :id             => :ADVERTISEMENT_RANDOM_3,
    :group          => :PAPISWOLIO,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Vete al puto gimnasio")]
                    ]
})

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
                        [10, :Text, _INTL("Está todo pollo")],
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
