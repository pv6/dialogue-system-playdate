import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"


local ds<const> = dialogueSystem


class("DialogueFlag", {}, ds).extends()


function ds.DialogueFlag:init()
    self.value = true
end


function ds.DialogueFlag:__tostring()
    return ""
end


-- virtual
function ds.DialogueFlag:check(input)
    return true
end
