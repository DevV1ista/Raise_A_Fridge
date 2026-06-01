local Util = {}

function Util.formatNumber(value)
	if value >= 1e9 then
		return string.format("%.1fB", value / 1e9)
	end
	if value >= 1e6 then
		return string.format("%.1fM", value / 1e6)
	end
	if value >= 1e3 then
		return string.format("%.1fK", value / 1e3)
	end
	return tostring(math.floor(value))
end

return Util
