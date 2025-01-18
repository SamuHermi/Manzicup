#===============================================================================
# Player
#===============================================================================
class Player < Trainer
    attr_accessor :instant_messages
    attr_accessor :im_passive

    alias tdw_im_player_init initialize
    def initialize(name, trainer_type)
        tdw_im_player_init(name, trainer_type)
        @instant_messages = InstantMessages.new
        @im_passive = {
            :RandomsReceived => [],
            :PendedRandoms => [],
            :PendedDelayed => [],
            :SequencialIndex => 0,
            :StepCount => 0,
            :LastTimeReceieved => nil
        }
    end

    def instant_messages
        @instant_messages = InstantMessages.new if !@instant_messages
        return @instant_messages
    end

    def im_passive
        if !@im_passive
            @im_passive = {
                :RandomsReceived => [],
                :PendedRandoms => [],
                :PendedDelayed => [],
                :SequencialIndex => 0,
                :StepCount => 0,
                :LastTimeReceieved => nil
            }
        end

        #Upgrade Handling
        @im_passive[:PendedRandoms] = [] if @im_passive[:PendedRandoms].nil?
        @im_passive[:PendedDelayed] = [] if @im_passive[:PendedDelayed].nil?

        return @im_passive
    end

    class InstantMessages
        attr_accessor :saved_messages
        attr_accessor :theme_color

        def initialize
            @saved_messages = {} #groups
            @theme_color = InstantMessagesSettings::DEFAULT_THEME_COLOR
        end

        def pbReceiveMessage(conversation_id)
            return false if pbHasReceivedMessage?(conversation_id)
            message = IMConversation.new(conversation_id)
            # if !@saved_messages[message.group]
            #     @saved_messages[message.group] = IMGroup.new(message.group)
            # end

            array = @saved_messages.to_a
            if !@saved_messages[message.group]
                array.unshift([message.group, IMGroup.new(message.group)])
                @saved_messages = array.to_h
            elsif array[0][0] != message.group
                existing = nil
                array.each_with_index do |val, i|
                    if val[0] == message.group
                        existing = i
                        break
                    end
                end
                deleted = array.delete_at(existing)
                array.unshift(deleted)
                @saved_messages = array.to_h
            end
            @saved_messages[message.group].last_received = pbGetTimeNow
            @saved_messages[message.group].convo_list.push(message)
            @saved_messages[message.group].has_unread = true
            @saved_messages[message.group].has_important = true if message.important
            return true
        end

        def pbHasReceivedMessage?(conversation_id)
            convo = pbIMGetConversation(conversation_id)
            group = convo.group
            return false if @saved_messages[group].nil?
            @saved_messages[group].convo_list.each { |c| return true if c.id == conversation_id }
            return false
        end

        def pbHasUnreadMessages?
            @saved_messages.each { |group| return true if group[1].has_unread}
            return false
        end

    end

end

def pbPlayerIMSaved
    return $player.instant_messages
end



# class InstantMessageConversation
#     def initialize(text)
#         @text = text
#         @bubble_color       = "White"
#         @viewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
#         @sprites = {}
#         @width = 350
#         @height = 128
#         # @sprites["background"] = IconSprite.new(0, 0, @viewport)
#         # @sprites["background"].setBitmap("Graphics/UI/Instant Messages/Bubbles/#{@bubble_color}")
#         # @width              = @sprites["background"].width
#         # @height             = @sprites["background"].height
#         # @sprites["overlay"] = BitmapSprite.new(@width, @height, @viewport)
#         # @sprites["overlay"].x = @x
#         # @sprites["overlay"].y = @y
#         # pbSetSystemFont(@sprites["overlay"].bitmap)
#     end

#     # def pbCreateMessageBG
#     #     @sprites = {}
#     #     # Body = X, Y, width, height of body rectangle within windowskin
#     #     @skinrect.set(32, 16, 16, 16)
#     #     # Trim = X, Y, width, height of trim rectangle within windowskin
#     #     @trim = [32, 16, 16, 16]
#     #     4.times do |i|
#     #         @sprites["corner#{i}"].bitmap = @_windowskin
#     #         @sprites["scroll#{i}"].bitmap = @_windowskin
#     #     end

#     # end

#     def update
#         # @sprites["background"].x = @x
#         # @sprites["background"].y = @y
#         # @sprites["overlay"].x = @x
#         # @sprites["overlay"].y = @y
#     end

#     def dispose
#         pbDisposeSpriteHash(@sprites)
#     end

# end