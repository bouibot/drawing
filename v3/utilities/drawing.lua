--[[

/////////////////////////////////////////

Copyright © 2023-2023 BouiBot LLC. All right reversed.

/////////////////////////////////////////

]]

local drawingUtility = {};

-- // Misc. functions

do

    --[[

    /////////////////////////////////////////

    There:
        drawingUtility.combine( firstValue: table, secondValue: table ) | table -> combine (table.insert) two tables;
        drawingUtility.combineOverriding( firstValue: table, secondValue: table ) | table -> combine (could override indexes) two tables;

    /////////////////////////////////////////

    ]]

    function drawingUtility.combine(self, firstValue: table, secondValue: table)

        local finishedTable = {};

        for _, objectValue in next, firstValue do

            table.insert(finishedTable, objectValue)

        end

        for _, objectValue in next, secondValue do

            table.insert(finishedTable, objectValue)

        end

        return finishedTable;

    end

    function drawingUtility.combineOverriding(self, firstValue: table, secondValue: table)

        local finishedTable = {};

        for objectName, objectValue in next, firstValue do

            finishedTable[objectName] = objectValue

        end

        for objectName, objectValue in next, secondValue do

            finishedTable[objectName] = objectValue

        end

        return finishedTable;

    end

end

-- // Object class

do
    
    --[[

    /////////////////////////////////////////

    There:

        objectClass.update () | nil -> updates object;
        objectClass.modify ( objectProperty: string, objectValue: any ) | object -> modify object's value;
        objectClass.get ( objectProperty: string ) | any -> get object's value;
        objectClass.clone (  ) | nil -> clones object with updated properties;
        objectClass.cloneRaw (  ) | nil -> clones object with original properties;
        objectClass.remove (  ) | nil -> removes the object;

    /////////////////////////////////////////

    ]]

    drawingUtility._objectClass = {};

    local objectClass = drawingUtility._objectClass;

    objectClass.__index = objectClass;
    objectClass.__newindex = function() error("fuck off math.hugog") end;

    function objectClass.update(self)

    end

    function objectClass.modify(self, objectProperty: string, objectValue: any)

        self._updatedProperties[objectProperty] = objectValue;
        self._originalObject[objectProperty] = objectValue;

        do

            self:update()

        end

        return self;

    end

    function objectClass.get(self, objectProperty: string)

        return self._originalObject[objectProperty];

    end

    function objectClass.clone(self)

        local objectClone = drawingUtility:draw(self._objectType, self._objectArguments, drawingUtility:combineOverriding(self._updatedProperties, self._customProperties));

        return objectClone;

    end

    function objectClass.cloneRaw(self)

        local rawClone = drawingUtility:draw(self._objectType, self._objectArguments, drawingUtility:combineOverriding(self._clearProperties, self._customProperties));

        return rawClone;

    end

    function objectClass.remove(self)

        self._originalObject:Remove();

    end

end

-- // Object draw

do

    --[[

    /////////////////////////////////////////

    There:
        drawingUtility:setDefaultProperties ( self, objectType: DrawEntry, defaultProperties: table ) | nil -> set default properties for draw entry class;
        drawingUtility:drawRaw( objectType: DrawEntry, objectArguments: table, objectProperties: table ) | DrawEntry -> create a draw entry;
        drawingUtility:draw( objectType: DrawEntry, objectArguments: table, objectProperties: table ) | table -> create a draw entry with a metatable;

    /////////////////////////////////////////

    ]]

    drawingUtility._customProperties = {};
    drawingUtility._defaultProperties = {};

    function drawingUtility.setDefaultProperties(self, objectType: DrawEntry, defaultProperties: table)

        self._defaultProperties[objectType] = defaultProperties

    end

    function drawingUtility.drawRaw(self, objectType: DrawEntry, objectArguments: table, objectProperties: table)

        local drawEntry = objectType.new(unpack(objectArguments));

        do

            for key, value in next, objectProperties or {} do

                drawEntry[key] = value;
    
            end

        end

        return drawEntry;

    end

    function drawingUtility.draw(self, objectType: DrawEntry, objectArguments: table, objectProperties: table)

        local objectMetatable = {};

        local clearProperties = {};
        local customProperties = {};

        do

            objectMetatable._objectType = objectType;
            objectMetatable._objectArguments = objectArguments;

            do

                for defaultName, defaultValue in next, self._defaultProperties[objectType] or {} do

                    if objectProperties[defaultName] == nil then

                        objectProperties[defaultName] = defaultValue;

                    end

                end

                for propertyName, propertyValue in next, objectProperties do

                    if not table.find(self._customProperties, propertyName) then

                        clearProperties[propertyName] = propertyValue;

                    else

                        customProperties[propertyName] = propertyValue;

                    end

                end

                objectMetatable._customProperties = customProperties;
                objectMetatable._clearProperties = clearProperties;

                objectMetatable._updatedProperties = objectMetatable._clearProperties;

            end

            do

                local drawEntry = self:drawRaw(objectType, objectArguments, clearProperties);

                objectMetatable._originalObject = drawEntry;

                setmetatable(objectMetatable, self._objectClass);

            end

            do

                for clearName, clearValue in next, objectMetatable._clearProperties do

                    objectMetatable:modify(clearName, clearValue);

                end

            end

        end

        return objectMetatable;

    end

end

return drawingUtility;
