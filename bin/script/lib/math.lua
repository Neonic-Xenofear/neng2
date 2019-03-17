CMath = {}

function CMath.lerp( a, b, t )
    return a + ( b - a ) * t;
end

return CMath