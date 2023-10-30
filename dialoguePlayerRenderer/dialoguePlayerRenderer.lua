import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialoguePlayer/dialoguePlayer"


local ds<const> = dialogueSystem 


class("DialoguePlayerRenderer", {}, ds).extends()


function ds.DialoguePlayerRenderer:init()
    self.dialogue = nil
    self.actorsImplementation = nil
    self.blackboardsImplementation = nil

    self.showSayOptionsImmidiately = false
    self.continueBeforeEnd = false

    self._dialoguePlayer = ds.DialoguePlayer()
end


function ds.DialoguePlayerRenderer:setDialogue(newDialogue)
    self.dialogue = newDialogue
end


function ds.DialoguePlayerRenderer:startDialogue()
    self:_clear()

    if not self.dialogue then
        return
    end

    if not self.actorsImplementation then
        self.actorsImplementation = self:_generateActorsImplementation(self.dialogue.actors)
    end
    if not self.blackboardsImplementation then
        self.blackboardsImplementation = self:_generateBlackboardsImplementation(self.dialogue.blackboards)
    end

    self._dialoguePlayer:play(self.dialogue, self.actorsImplementation, self.blackboardsImplementation)

    self:_setNextNode()
end


function ds.DialoguePlayerRenderer:endDialogue()
    self._dialoguePlayer:stop()
    self:_clear()
end


function ds.DialoguePlayerRenderer:_getActorName(actor)
    local actorImpl = self._dialoguePlayer:getActorImplementation(actor)
    if actorImpl then
        return tostring(actorImpl)
    end
    return "NONE"
end


function ds.DialoguePlayerRenderer:_getActorImplementation(actor)
    return self._dialoguePlayer:getActorImplementation(actor)
end


function ds.DialoguePlayerRenderer:_getActorImplementationByName(actorName)
    return self._dialoguePlayer:getActorImplementationByName(actorName)
end


function ds.DialoguePlayerRenderer:_generateBlackboardsImplementation(blackboardTemplates)
    -- generate dummy implementations for blackboards
    local blackboards = ds.StorageImplementation(blackboardTemplates)
    for i, template in ipairs(blackboardTemplates:items()) do
        local implementation = ds.StorageImplementation(template, false)
        blackboards:set(template, implementation)
    end
    return blackboards
end


function ds.DialoguePlayerRenderer:_generateActorsImplementation(dialogueActors)
    -- generate dummy implementations for actors
    local actors = ds.StorageImplementation(dialogueActors)
    for i, actorItem in ipairs(dialogueActors:items()) do
        local actor = {}
        actor.name = tostring(actorItem)
        actors:set(actorItem, actor)
    end
    return actors
end


-- virtual
function ds.DialoguePlayerRenderer:_onSayOptionSelected(sayNode)
    self:_clearSayOptions()
    self._dialoguePlayer:say(sayNode)
    self:_setNextNode()
end


-- virtual
function ds.DialoguePlayerRenderer:_setSayOptions(sayOptions)
    for i, sayNode in ipairs(sayOptions) do
        self:_spawnSayButton(i, sayNode)
    end
end


function ds.DialoguePlayerRenderer:_setNextNode()
    self:_clearCurrentNode()

    -- try hear 
    local hearNode = self._dialoguePlayer:hear()
    if hearNode then
        self:_setHearNode(hearNode)
    end

    local showContinue = true

    if not hearNode or self.showSayOptionsImmidiately then
        local canSay = self:_trySay()
        showContinue = not canSay
    end

    if showContinue then
        self:_tryContinue(hearNode ~= nil)
    end
end


function ds.DialoguePlayerRenderer:_trySay()
    local sayOptions = self._dialoguePlayer:getSayOptions()
    if #sayOptions == 0 then
        return false
    end
    self:_setSayOptions(sayOptions)
    return true
end


function ds.DialoguePlayerRenderer:_tryContinue(wasHearNode)
    if (self.continueBeforeEnd and wasHearNode) or self._dialoguePlayer:canContinue() then
        self:_setContinue()
    else
        self:endDialogue()
    end
end


-- virtual
function ds.DialoguePlayerRenderer:_setHearNode(hearNode)
end


-- virtual
function ds.DialoguePlayerRenderer:_setContinue()
end


-- virtual
function ds.DialoguePlayerRenderer:_spawnSayButton(index, sayNode)
end


-- virtual
function ds.DialoguePlayerRenderer:_clearSayOptions()
end


-- virtual
function ds.DialoguePlayerRenderer:_clearCurrentNode()
end


-- virtual
function ds.DialoguePlayerRenderer:_clear()
end
