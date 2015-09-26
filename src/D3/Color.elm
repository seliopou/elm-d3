module D3.Color
  ( fromRGB     -- : Int -> Int -> Int -> Color
  , toRGB       -- : Color -> (Int, Int, Int)
  , fromHSL     -- : Int -> Float -> Float -> Color
  , toHSL       -- : Color -> (Int, Float, Float)
  , fromHCL     -- : Float -> Float -> Float -> Color
  , toHCL       -- : Color -> (Float, Float, Float)
  , fromLAB     -- : Float -> Float -> Float -> Color
  , toLAB       -- : Color -> (Float, Float, Float)
  , brighter    -- : Color -> Color
  , darker      -- : Color -> Color
  , fromString  -- : String -> Color
  , toString    -- : Color -> String
  ) where

import Native.D3.Color

type Color = Color


fromRGB : Int -> Int -> Int -> Color
fromRGB = Native.D3.Color.create "rgb"

toRGB : Color -> (Int, Int, Int)
toRGB color =
  let rgb = Native.D3.Color.convert "rgb" color
    in (rgb.r, rgb.g, rgb.b)

fromHSL : Int -> Float -> Float -> Color
fromHSL = Native.D3.Color.create "hsl"

toHSL : Color -> (Int, Float, Float)
toHSL color =
  let hsl = Native.D3.Color.convert "hsl" color
    in (hsl.h, hsl.s, hsl.l)

fromHCL : Float -> Float -> Float -> Color
fromHCL = Native.D3.Color.create "hcl"

toHCL : Color -> (Float, Float, Float)
toHCL color =
  let hcl = Native.D3.Color.convert "hcl" color
    in (hcl.h, hcl.c, hcl.l)

fromLAB : Float -> Float -> Float -> Color
fromLAB = Native.D3.Color.create "lab"

toLAB : Color -> (Float, Float, Float)
toLAB color =
  let lab = Native.D3.Color.convert "lab" color
    in (lab.l, lab.a, lab.b)

brighter : Float -> Color -> Color
brighter = Native.D3.Color.brighter

darker : Float -> Color -> Color
darker = Native.D3.Color.darker

fromString : String -> Color
fromString = Native.D3.Color.fromString

toString : Color -> String
toString = Native.D3.Color.toString
