-- This is an Elm reimplementation of the ForeignObject D3.js example. The original can be found here:
--
--   https://gist.github.com/mbostock/1424037
--
-- From the root directory of the elm-d3 project, compile it using the
-- following commands:
--
--   elm-make examples/ForeignObject.elm --output=foreignObject.html
--
-- On OS X, you can then open the file in the browser using the following
-- command:
--
--   open foreignObject.html
--
-- Note that due to recent changes in the Elm compiler, it is no longer
-- possible to linking of external JavaScript code while building projects. So,
-- you will have to manually link D3.js into this HTML file.
--
module ForeignObject where

import D3 exposing (..)

width = 960
height = 500

loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec eu enim quam. Quisque nisi risus, sagittis quis tempor nec, aliquam eget neque. Nulla bibendum semper lorem non ullamcorper. Nulla non ligula lorem. Praesent porttitor, tellus nec suscipit aliquam, enim elit posuere lorem, at laoreet enim ligula sed tortor. Ut sodales, urna a aliquam semper, nibh diam gravida sapien, sit amet fermentum purus lacus eget massa. Donec ac arcu vel magna consequat pretium et vel ligula. Donec sit amet erat elit. Vivamus eu metus eget est hendrerit rutrum. Curabitur vitae orci et leo interdum egestas ut sit amet dui. In varius enim ut sem posuere in tristique metus ultrices.<p>Integer mollis massa at orci porta vestibulum. Pellentesque dignissim turpis ut tortor ultricies condimentum et quis nibh. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer euismod lorem vulputate dui pharetra luctus. Sed vulputate, nunc quis porttitor scelerisque, dui est varius ipsum, eu blandit mauris nibh pellentesque tortor. Vivamus ultricies ante eget ipsum pulvinar ac tempor turpis mollis. Morbi tortor orci, euismod vel sagittis ac, lobortis nec est. Quisque euismod venenatis felis at dapibus. Vestibulum dignissim nulla ut nisi tristique porttitor. Proin et nunc id arcu cursus dapibus non quis libero. Nunc ligula mi, bibendum non mattis nec, luctus id neque. Suspendisse ut eros lacus. Praesent eget lacus eget risus congue vestibulum. Morbi tincidunt pulvinar lacus sed faucibus. Phasellus sed vestibulum sapien."

html' = "<h1>An HTML Foreign Object in SVG</h1><p>"

document : D3 () ()
document =
  static "svg"
  |. num attr "width" width
  |. num attr "height" height
  |. static "foreignObject"
    |. num attr "width" 480
    |. num attr "height" height
    |. static "xhtml:body"
      |. str style "font" "14px 'Helvetica Neue'"
      |- static "h1"
         |. text (\_ _ -> "An HTML Foreign Object in SVG")
      |- static "p"
         |. text (\_ _ -> loremIpsum)

main = render width height document ()
