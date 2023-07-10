--[[

/////////////////////////////////////////

Copyright © 2023-2023 BouiBot LLC. All right reversed. 11:11.

/////////////////////////////////////////

Notes:
    > No documentation. (Maybe in future.);

]]

local tweenUtility = {};

local tweenService = game:GetService("TweenService"); -- // Used for values;
local runService = game:GetService("RunService"); -- // For loops;

-- // Misc. functions

do

	function tweenUtility:Lerp(start, goal, delta)

		if type(start) == "number" then

			return (1 - delta) * start + delta * goal;

		end;

		return start:Lerp(goal, delta);

	end;

end;

-- // Tween class

do

	tweenUtility._objectClass = {};

	local objectClass = tweenUtility._objectClass;

	objectClass.__index = objectClass;

	function objectClass:get(delta: number)

		return tweenService:GetValue(delta, self.info.EasingStyle, self.info.EasingDirection);

	end;

	function objectClass:play()

		assert((self.connection == nil) and (not self.connection.Connected), "It's already running.");

		self.connection = runService.Heartbeat:Connect(function(deltaTime)

			self.elapsed = math.clamp(self.elapsed + deltaTime, 0, self.info.Time);

			if self.elapsed > self.info.Time then

				for key, value in next, self.goal do

					self.setMethod(self.object, key, value); -- // Cause of my drawing utility;

				end;

				self.connection:Disconnect();

			end;

			local delta = self:get(self.elapsed / self.info.Time);

			for key, value in next, self.goal do

				self.setMethod(self.object, key, tweenUtility:Lerp(self.getMethod(self.object, key), value, delta));

			end;

		end);

	end;

	function objectClass:stop()

		assert((self.connection ~= nil) and (self.connection.Connected), "There's nothing to stop.");

		self.connection:Disconnect();

	end;

end;

-- // Tween creating

do

	function tweenUtility:new(object: any, tweenInfo: TweenInfo, goal: table, getMethod: general_function, setMethod: general_function)

		assert(object ~= nil, "Object must be set.");
		assert(typeof(tweenInfo) == "TweenInfo", "TweenInfo must be TweenInfo.");
		assert(type(goal) == "table", "Goal must be a table.");

		getMethod = (getMethod ~= nil) and getMethod or function(object, key) return object[key]; end;
		setMethod = (setMethod ~= nil) and setMethod or function(object, key, value) object[key] = value; end;

		local start = {};

		for key, value in next, goal do

			start[key] = getMethod(start, key);

		end;

		local tweenObject = setmetatable({
			elapsed = 0;
			info = tweenInfo;
			start = start;
			goal = goal;
			getMethod = getMethod;
			setMethod = setMethod;
		}, self._objectClass);

		return tweenObject;

	end;

end;

return tweenUtility;
