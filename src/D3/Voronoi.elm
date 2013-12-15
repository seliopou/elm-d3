module D3.Voronoi
  ( cells
  , cellsWithClipping
  ) where

import Native.D3.Voronoi
import String

type Point = { x : number, y : number }

cells : [Point] -> [[Point]]
cells = Native.D3.Voronoi.cells

cellsWithClipping : number -> number -> number -> number -> [Point] -> [[Point]]
cellsWithClipping = Native.D3.Voronoi.cellsWithClipping
