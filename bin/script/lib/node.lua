CNode = {
}

function CNode:new()
    local data = {
        --node = sceneObj
    }

    setmetatable( data, self );
    self.__index = self;

    return self;
end

function CNode:update( delta )
    
end

function CNode:getClassName()
    return "CNode";
end

function extended( child, parent )
    setmetatable( child, { __index = CNode } );
    child.__nativeClass = parent;
end

return CNode