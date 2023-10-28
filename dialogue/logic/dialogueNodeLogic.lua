import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/dialogueNodeLogicInput"


local ds<const> = dialogueSystem


class("DialogueNodeLogic", {}, ds).extends()


function ds.DialogueNodeLogic:init()
    flags = {}
    autoFlags = {}
end


function ds.DialogueNodeLogic:check(input)
    -- check auto-flags
    for i, flag in ipairs(self.autoFlags) do
        if not flag:check(input) then
            return false
        end
    end

    -- check flags
    for i, flag in ipairs(self.flags) do
        if not flag:check(input) then
            return false
        end
    end

    return true
end


function ds.DialogueNodeLogic:doAction(input)
    for i, autoFlag in ipairs(self.autoFlags) do
        assert(autoFlag:isa(ds.ActionableDialogueFlag))
        autoFlag:doAction(input)
    end

    for i, flag in ipairs(self.flags) do
        assert(flag:isa(ds.ActionableDialogueFlag))
        flag:doAction(input)
    end
end
