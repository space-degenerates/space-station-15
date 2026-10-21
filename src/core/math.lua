local emath = {}

function emath.getAngleBetweenPoints(pointA, pointB)
	local tangent = (pointB.y - pointA.y) / (pointB.x - pointA.x)

	local arctangent = math.atan(tangent)

	return math.deg(arctangent) + 90, math.tan(math.deg(arctangent) + 90) -- fixed tangent, for some reason it's 90 degrees less
end

function emath.lerp(a, b, c)
	return a + (b - a) * c
end

return emath
