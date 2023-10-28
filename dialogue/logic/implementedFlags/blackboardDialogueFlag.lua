import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/actionableDialogueFlag"


local ds<const> = dialogueSystem


class("BlackboardDialogueFlag", {}, ds).extends(ds.ActionableDialogueFlag)


function ds.BlackboardDialogueFlag:init()
    ds.BlackboardDialogueFlag.super.init(self)

    self.blackboardField = nil
end


function ds.BlackboardDialogueFlag:__tostring()
    if self.blackboardField then
        return tostring(self.blackboardField)
    end
    return ""
end


function ds.BlackboardDialogueFlag:getBlackboard()
    if self.blackboardField then
        return blackboardField.storage
    end
    return nil
end


-- virtual
function ds.BlackboardDialogueFlag:check(input)
    local blackboard = self:getBlackboard()
    return blackboard and input.blackboards:get(blackboard):get(self) == value
end


-- virtual
function ds.BlackboardDialogueFlag:doAction(input)
    input.blackboards:get(self:getBlackboard()):set(self, value)
end
