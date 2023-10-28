import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"


local ds<const> = dialogueSystem


class("DialogueFlag", {}, ds).extends()


function ds.DialogueFlag:init()
    value = true
end


function ds.DialogueFlag:__tostring()
    return ""
end


-- virtual
function ds.DialogueFlag:check(input)
    return true
end
