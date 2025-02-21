#===============================================================================
# Contact registrations
#
# These are individual NPCs that the player chats with in conversations.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID used to add the contact to groups 
#   - :name => String - The name of the contact the player will see
#   - :image => String - The filename of the image used to represent the contact. 
#               File location: UI/Instant Messages/Characters
#   - :bubble => String - The filename of the windowskin used by the contact. 
#               File location: UI/Instant Messages/Bubbles
#===============================================================================

GameData::InstantMessageContact.register({
    :id             => :ADVERTISEMENT,
    :name		    => _INTL("Advertisement"),
    :image		    => "Advertisement",
    :bubble         => "Blue"
})

GameData::InstantMessageContact.register({
    :id             => :HERMI,
    :name		    => _INTL("Hermi"),
    :image		    => "Hermi",
    :bubble         => "Yellow"
})

GameData::InstantMessageContact.register({
    :id             => :IRIA,
    :name		    => _INTL("Iria"),
    :image		    => "Iria",
    :bubble         => "Blue"
})

GameData::InstantMessageContact.register({
    :id             => :ISA,
    :name		    => _INTL("Isa"),
    :image		    => "Isa",
    :bubble         => "Blue"
})

GameData::InstantMessageContact.register({
    :id             => :PABLO,
    :name		    => _INTL("Pablo"),
    :image		    => "Pablo",
    :bubble         => "Red"
})

GameData::InstantMessageContact.register({
    :id             => :BRA,
    :name		    => _INTL("Bra"),
    :image		    => "Bra",
    :bubble         => "Green"
})

GameData::InstantMessageContact.register({
    :id             => :SAMER,
    :name		    => _INTL("Samer"),
    :image		    => "Samer",
    :bubble         => "Purple"
})

GameData::InstantMessageContact.register({
    :id             => :RODRI,
    :name		    => _INTL("Rodri"),
    :image		    => "Rodri",
    :bubble         => "Yellow"
})

GameData::InstantMessageContact.register({
    :id             => :ANA,
    :name		    => _INTL("Ana"),
    :image		    => "Ana",
    :bubble         => "White"
})

GameData::InstantMessageContact.register({
    :id             => :SABO,
    :name		    => _INTL("Sabo"),
    :image		    => "Sabo",
    :bubble         => "Dark"
})

GameData::InstantMessageContact.register({
    :id             => :BRAIS,
    :name		    => _INTL("Brais"),
    :image		    => "Brais",
    :bubble         => "Purple"
})

GameData::InstantMessageContact.register({
    :id             => :JESS,
    :name		    => _INTL("Jess"),
    :image		    => "Jess",
    :bubble         => "Dark"
})

GameData::InstantMessageContact.register({
    :id             => :NEREA,
    :name		    => _INTL("Nerea"),
    :image		    => "Nerea",
    :bubble         => "Green"
})

GameData::InstantMessageContact.register({
    :id             => :ELDAR,
    :name		    => _INTL("Eldar"),
    :image		    => "Eldar",
    :bubble         => "Blue"
})

GameData::InstantMessageContact.register({
    :id             => :BILL,
    :name		    => _INTL("Bill"),
    :image		    => "Bill",
    :bubble         => "Green"
})

GameData::InstantMessageContact.register({
    :id             => :SWOLIO,
    :name		    => _INTL("Papi Swolio"),
    :image		    => "Swolio",
    :bubble         => "Dark"
})

GameData::InstantMessageContact.register({
    :id             => :JORDIWILD,
    :name		    => _INTL("Jordi Wild"),
    :image		    => "jordiwild",
    :bubble         => "Blue"
})
#===============================================================================
# Group registrations
#
# These are the groups/containers/threads that can contain several conversations.
# These are what appear in the selection menu, and will load conversations once
# opened.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID used to house specific conversations
#   - :title => String - The name of the group as seen by the player
#   - :members => Hash - Contains contacts included in the group and their
#                 reference numbers used when creating conversation messages.
#                 { <Interger - Reference Number => <Symbol - :id of a contact}         
#   - :hide_old => (Optional) Boolean - Set to false to hide already read message
#===============================================================================

GameData::InstantMessageGroup.register({
    :id             => :MANZIDADAS,
    :title		    => _INTL("Manzidadas"),
    :members		=> {1 => :IRIA, 2 => :PABLO, 3 => :BRA, 4 => :ISA, 5 => :SAMER,
                        6 => :RODRI, 7 => :ANA, 8 => :SABO, 9 => :BRAIS, 10 => :HERMI,
                        11 => :JESS, 12 => :NEREA}
})

GameData::InstantMessageGroup.register({
    :id             => :ROL,
    :title		    => _INTL("Gremio de aventureros del plano nº 3"),
    :members		=> {1 => :ELDAR, 2 => :DEVERE, 3 => :LYLGIVUNT, 4 => :YURIAN, 5 => :DRALDVYR,
                        6 => :SATARI, 7 => :THORIN, 8 => :HIRO}
})

GameData::InstantMessageGroup.register({
    :id             => :BILL,
    :title		    => _INTL("Bill"),
    :members		=> {1 => :BILL}
})

GameData::InstantMessageGroup.register({
    :id             => :PAPISWOLIO,
    :title		    => _INTL("Papi Swolio"),
    :members		=> {1 => :SWOLIO}
})

GameData::InstantMessageGroup.register({
    :id             => :JORDIWILD,
    :title		    => _INTL("Dijo que me iba a invitar al Podcast"),
    :members		=> {1 => :JORDIWILD}
})