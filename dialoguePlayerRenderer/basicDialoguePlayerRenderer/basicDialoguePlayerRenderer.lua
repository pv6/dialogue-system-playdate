import "CoreLibs/object"
import "CoreLibs/graphics"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialoguePlayerRenderer/dialoguePlayerRenderer"

dialogueSystem.basicDialoguePlayerRenderer = {}
local basicRenderer<const> = dialogueSystem.basicDialoguePlayerRenderer

import "DialogueSystem/dialoguePlayerRenderer/basicDialoguePlayerRenderer/sayOptionsButton"


local ds<const> = dialogueSystem
local pd<const> = playdate
local gfx<const> = pd.graphics
local math<const> = math


class("BasicDialoguePlayerRenderer", {}, ds).extends(ds.DialoguePlayerRenderer)


function ds.BasicDialoguePlayerRenderer:init()
    ds.BasicDialoguePlayerRenderer.super.init(self)
    self.continueBeforeEnd = true
    self.font = gfx.getFont()
    self.sayButtons = {}
    self.selectedSayOption = 0

    self.canContinue = false
end


function ds.BasicDialoguePlayerRenderer:input(inputEvent)
    if self.canContinue and inputEvent:isAButton() and inputEvent:isDown() then
        self:_setNextNode()
    end

    if #self.sayButtons > 0 then
        local prevSelectedOption = self.selectedSayOption

        if inputEvent:isDownButton() and inputEvent:isDown() then
            self.selectedSayOption += 1
        end
        if inputEvent:isUpButton() and inputEvent:isDown() then
            self.selectedSayOption -= 1
        end

        self.selectedSayOption = math.cycle(self.selectedSayOption, #self.sayButtons)

        if prevSelectedOption ~= self.selectedSayOption then
            self.sayButtons[prevSelectedOption + 1].isSelected = false
            self.sayButtons[self.selectedSayOption + 1].isSelected = true

            gfx.clear()
            for i, button in ipairs(self.sayButtons) do
                button:draw()
            end
        end
    end
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_setHearNode(hearNode)
    gfx.drawText(hearNode.text, 0, 0)
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_setContinue()
    self.canContinue = true
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_spawnSayButton(index, sayNode)
    local sayButton = basicRenderer.SayOptionButton(index, sayNode)
    if index == 1 then
        sayButton.isSelected = true
    end
    sayButton:draw()
    sayButton.pressed:connect(self, self._onSayOptionSelected, sayNode)
    table.insert(self.sayButtons, sayButton)
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_clearSayOptions()
    self.sayButtons = {}
    self.selectedSayOption = 0
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_clearCurrentNode()
    gfx.clear()
    self.canContinue = false
end


-- virtual
function ds.BasicDialoguePlayerRenderer:_clear()
    gfx.clear()
end
