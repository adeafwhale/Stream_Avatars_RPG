function yourEvent(user, block)

    log('block hit by avatar! block id is:' .. block.id);
    
end
 
return function()
    addEvent('scriptableBlocks', 'yourEvent'); --attaches the event to yourEvent()
    keepAlive(); --this is needed.
end