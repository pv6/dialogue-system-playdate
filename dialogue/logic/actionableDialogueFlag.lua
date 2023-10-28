import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/dialogueFlag"


local ds<const> = dialogueSystem


class("ActionableDialogueFlag", {}, ds).extends(ds.DialogueFlag)


function ds.ActionableDialogueFlag:init()
    ds.ActionableDialogueFlag.super.init(self)
end


-- virtual
function ds.ActionableDialogueFlag:doAction(input)
end
