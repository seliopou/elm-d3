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

import JavaScript as JS
import Native.D3.Color

data Color = Color


fromRGB : Int -> Int -> Int -> Color
fromRGB r g b = Native.D3.Color.rgb (JS.fromInt r) (JS.fromInt g) (JS.fromInt b)

toRGB : Color -> (Int, Int, Int)
toRGB color =
  let rgb  = Native.D3.Color.rgb color
    in (geti rgb "r", geti rgb "g", geti rgb "b")

fromHSL : Int -> Float -> Float -> Color
fromHSL h s l = Native.D3.Color.rgb (JS.fromInt h) (JS.fromFloat s) (JS.fromFloat l)

toHSL : Color -> (Int, Float, Float)
toHSL color =
  let hsl = Native.D3.Color.hsl color
    in (geti hsl "h", getf hsl "s", getf hsl "l")

fromHCL : Float -> Float -> Float -> Color
fromHCL h c l = Native.D3.Color.hcl (JS.fromFloat h) (JS.fromFloat c) (JS.fromFloat l) 

toHCL : Color -> (Float, Float, Float)
toHCL color =
  let hcl = Native.D3.Color.hcl color
    in (getf hcl "h", getf hcl "c", getf hcl "l")

fromLAB : Float -> Float -> Float -> Color
fromLAB l a b = Native.D3.Color.lab (JS.fromFloat l) (JS.fromFloat a) (JS.fromFloat b)

toLAB : Color -> (Float, Float, Float)
toLAB color =
  let lab = Native.D3.Color.lab color
    in (getf lab "l", getf lab "a", getf lab "b")

brighter : Float -> Color -> Color
brighter = Native.D3.Color.brighter . JS.fromFloat

darker : Float -> Color -> Color
darker = Native.D3.Color.darker . JS.fromFloat

fromString : String -> Color
fromString = Native.D3.Color.fromString . JS.fromString

toString : Color -> String
toString = JS.toString . Native.D3.Color.toString


-------------------------------------------------------------------------------
-- Internal functions

geti xyz a = JS.toInt (Native.D3.Color.get a xyz)
getf xyz a = JS.toFloat (Native.D3.Color.get a xyz)
