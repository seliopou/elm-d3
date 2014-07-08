module D3.Scales.Quantitative where
{-| Quantitative Scales in elm-d3. These are for scales that take a value
from the Reals and map it to the Reals

# Make a scale
@docs linear, identity, pow, sqrt, log

# Change the properties of a scale
@docs domain, range, nice, clamp

# Do things with a scale
@docs convert, invert, ticks
-}
import Native.D3.Scales.Quantitative

data Scale a = Scale
{-| Make a linear scale. Nothing fancy here. The default is the identity mapping.
-}
linear : Scale Float
linear = Native.D3.Scales.Quantitative.linear

identity : Scale Float
identity = Native.D3.Scales.Quantitative.identity

{-| Make a sqrt scale.
-}
sqrt : Scale Float
sqrt = Native.D3.Scales.Quantitative.sqrt

{-| Make a power scale. You must specify the exponent.
-}
pow : Float -> Scale Float
pow = Native.D3.Scales.Quantitative.pow

{-| Make a log scale. You must specify the base.
-}
log : Float -> Scale Float
log = Native.D3.Scales.Quantitative.log


{-| Change the domain of the function. You may pass in any number of values into
the list and they will be interpolated between.

      yScale = linear |> domain [0,100] |> range [-150,150]
-}
domain : [Float] -> Scale a -> Scale a
domain = Native.D3.Scales.Quantitative.domain

{-| Change the range of the function. You may pass in any number of values into
the list and they will be interpolated between.
-}
range : [a] -> Scale a -> Scale a
range = Native.D3.Scales.Quantitative.range

{-| Extend the domain to start and end on "nice" values.

      linear |> domain [0.201, 0.934] |> nice == linear |> domain [0.2, 1]
-}
nice : Scale Float -> Scale Float
nice = Native.D3.Scales.Quantitative.nice

{-| Clamp the domain so that values beyond the domain will be brough back to the
most extreme value specified in the domain.

      linear |> clamp |> convert 3 == 1
-}
clamp : Scale Float -> Scale Float
clamp = Native.D3.Scales.Quantitative.clamp


{-| Apply the scale to a value and it will map the input value to the output range.

      linear |> domain [0,1] |> range [0,100] |> convert 0.5 == 50
-}
convert : Float -> Scale b -> b
convert = Native.D3.Scales.Quantitative.convert

{-| Apply the scale to a value in its range to get the corresponding value in
the domain.
-}
invert : Float -> Scale Float -> Float
invert = Native.D3.Scales.Quantitative.invert

{-| Get a list of where the ticks are on the scale, given a number of ticks you want.

      linear |> domain [0,10] |> ticks 3 == [0, 5, 10]
-}
ticks : Int -> Scale Float -> [Float]
ticks = Native.D3.Scales.Quantitative.ticks
