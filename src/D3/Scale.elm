module D3.Scale where

import Native.D3.Scale


data Scale a = Scale

linear : Scale Float
linear = Native.D3.Scale.linear

identity : Scale Float
identity = Native.D3.Scale.identity

pow : Float -> Scale Float
pow = Native.D3.Scale.pow

sqrt : Scale Float
sqrt = Native.D3.Scale.sqrt

log : Float -> Scale Float
log = Native.D3.Scale.log

domain : Scale a -> [Float] -> Scale a
domain = Native.D3.Scale.domain

range : Scale a -> [a] -> Scale a
range = Native.D3.Scale.range

ticks : Scale Float -> Int -> [String]
ticks = Native.D3.Scale.ticks

tickFormat : Scale Float -> (Float -> String) -> Scale Float
tickFormat = Native.D3.Scale.tickFormat

nice : Scale Float -> Scale Float
nice = Native.D3.Scale.nice

clamp : Scale Float -> Scale Float
clamp = Native.D3.Scale.clamp

convert : Scale b -> Float -> b
convert = Native.D3.Scale.convert

invert : Scale Float -> Float -> Float
invert = Native.D3.Scale.invert
