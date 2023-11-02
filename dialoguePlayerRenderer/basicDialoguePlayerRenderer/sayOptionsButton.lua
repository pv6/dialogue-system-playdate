import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "Input/handler"
import "DialogueSystem/support/signal"


local ds<const> = dialogueSystem
local pd<const> = playdate
local gfx<const> = pd.graphics
local basicRenderer<const> = ds.basicDialoguePlayerRenderer


class("SayOptionButton", {}, basicRenderer).extends()


local font<const> = gfx.getFont()
local height<const> = font:getHeight()


function basicRenderer.SayOptionButton:init(index, sayNode)
    self.index = index
    self.sayNode = sayNode
    self.isSelected = false

    input.handler.addListener(self)

    self.pressed = Signal()
end


function basicRenderer.SayOptionButton:draw()
    local y = (self.index - 1) * height
    local text = string.format("%d. ", self.index) .. self.sayNode.text
    gfx.drawText(text, 0, y)
    if self.isSelected then
        gfx.drawRect(0, y, 400, height)
    end
end


function basicRenderer.SayOptionButton:input(event)
    if self.isSelected and event:isAButton() and event:isDown() then
        self.pressed:emit()
    end
end
