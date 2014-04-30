module Todo where

import Json
import String

import D3(..)
import D3.Event(..)

import Native.Error

data Filter
  = All
  | Active
  | Completed

data Event
  = AddInput
  | ChangeInput String
  | Delete Int
  | Edit Int
  | CancelEdit
  | ChangeEdit String
  | CommitEdit
  | Check Int
  | Uncheck Int
  | Filter Filter
  | Toggle Bool
  | Noop

type Model = {
  input : String,
  items : [(String, Bool)],
  filter : Filter,
  editing : Maybe (String, Int)
}

events : Stream Event
events = stream ()

imap f l =
  let loop i l =
    case l of
      [] -> []
      x::xs -> (f x i)::(loop (i + 1) xs) in
  loop 0 l

ifilter f l =
  let loop i l =
    case l of
      [] -> []
      x::xs -> if f x i then x::(loop (i + 1) xs) else loop (i + 1) xs in
  loop 0 l

ifilterMap f l =
  let loop i l =
    case l of
      [] -> []
      x::xs ->
        case f x i of
          Nothing -> loop (i + 1) xs
          Just x' -> x'::(loop (i + 1) xs)
  in loop 0 l

transform : Event -> Model -> Model
transform e m =
  let set_b i b =
    { m | items <- imap (\(t, s) j -> (t, if j == i then b else s)) m.items }
  in
  let set_t i t =
    { m | items <- imap (\(u, s) j -> (if j == i then t else u, s)) m.items }
  in
  let change e =
    case m.editing of
      Nothing -> Native.Error.throw "trying to edit while not editing"
      Just (_, i) -> Just (e, i)
  in
  let commit () =
    case m.editing of
      Nothing -> Native.Error.throw "trying to finishing editing while not editing"
      Just (t, i) -> let m' = set_t i t in { m' | editing <- Nothing }
  in
  let gettext i = fst (head (drop i m.items)) in
  case e of
    AddInput -> { m | input <- ""
                    , items <- (m.input, False)::m.items }
    ChangeInput i -> { m |   input <- i }
    Filter filter -> { m |  filter <- filter }
    Toggle  onoff -> { m |   items <- map (\(t,_) -> (t, onoff)) m.items }
    Delete  index -> { m |   items <- ifilter (\_ j -> j /= index) m.items }
    Edit    index -> { m | editing <- Just (gettext index, index) }
    CancelEdit    -> { m | editing <- Nothing }
    ChangeEdit  e -> { m | editing <- change e }
    CommitEdit    -> commit ()
    Check   index -> set_b index True
    Uncheck index -> set_b index False
    Noop          -> m

todoList : Model -> [{ text : String, completed : Bool, editing : Bool }]
todoList m =
  let display b = case m.filter of
    All -> True
    Active -> not b
    Completed -> b
  in
  ifilterMap (\(t, b) i ->
     if display b
       then case m.editing of
         Just (t', j) ->
           let editing = i == j
               text = if i == j then t' else t
           in Just { text = text, completed = b, editing = editing }
         Nothing ->
           Just { text = t, completed = b, editing = False }
       else Nothing)
     m.items

content : Selection Model
content =
  let header =
    static "header"
    |. str attr "id" "header"
    |^ static "h1"
       |. text (\_ _ -> "todo")
    |^ static "input"
       |. str attr "id" "new-todo"
       |. str attr "autofocus" ""
       |. str attr "placeholder" "What needs to be done?"
       |. property "value" (\d _ -> Json.String d.input)
       |. input events (\v d i -> ChangeInput v)
       |. keyup events (\k d i ->
            if k.keyCode == 13 && d.input /= ""
              then AddInput
              else Noop)
  in
  let view =
    static "div"
    |. str attr "class" "view"
    |^ static "input"
       |. str attr "class" "toggle"
       |. str attr "type" "checkbox"
       |. property "checked" (\d _ -> Json.Boolean d.completed)
       |. click events (\_ d i -> if d.completed then Uncheck i else Check i)
    |^ static "label"
       |. text (\d _ -> d.text)
    |^ static "button"
       |. str attr "class" "destroy"
       |. click events (\_ _ i -> Delete i)
  in
  let edit =
    static "input"
    |. str attr "class" "edit"
    |. property "value" (\d _ -> Json.String d.text)
    |. input events (\v d i -> ChangeEdit v)
    |. keyup events (\k d i ->
         case k.keyCode of
           27 -> CancelEdit -- ESC_KEY
           13 -> CommitEdit -- ENTER_KEY
           _  -> Noop)
    |. blur events (\d i -> CancelEdit)
  in
  let items =
    selectAll "li"
    |= todoList
       |- enter <.> append "li"
          |. dblclick events (\_ _ i -> Edit i)
       |- update
          |. classed "editing" (\d _ -> d.editing)
          |. classed "completed" (\d _ -> d.completed)
          |. (sequence view edit)
       |- exit
          |. remove
  in
  update
  |^ header
  |^ (static "section" <.> str attr "id" "main"
     |^ static "input"
        |. str attr "id" "toggle-all"
        |. str attr "type" "checkbox"
     |^ static "ul"
        |. str attr "id" "todo-list"
        |. embed items)

footer : Selection Model
footer =
  let count =
    static "span"
    |. str attr "id" "todo-count"
    |. html (\m _ ->
      let undone_count = length (filter (\(_, b) -> not b) m.items) in
      "<strong>" ++ (show undone_count) ++ "</strong> items left")
  in
  let filters =
    selectAll "li"
    |= (\m -> [ (All      , m.filter == All      , "#/")
              , (Active   , m.filter == Active   , "#/active")
              , (Completed, m.filter == Completed, "#/completed")
              ])
       |- enter <.> append "li" <.> append "a"
          |. fun attr "href" (\(_, _, href) _ -> href)
          |. text (\(f, _, _) _ -> show f)
          |. click events (\_ (f, _, _) _ -> Filter f)
       |- update <.> select "a"
          |. classed "selected" (\(_, active, _) _ -> active)
       |- exit
          |. remove
  in
  static "footer" <.> str attr "id" "footer"
  |^ count
  |^ static "ul" <.> str attr "id" "filters"
     |. embed filters

todoapp : Selection Model
todoapp =
  static "section" <.> str attr "id" "todoapp"
  |^ content
  |^ footer

low_footer : Selection a
low_footer =
  let content ="
  <p>Double-click to edit a todo</p>
  <p>Created by <a href='http://computationallyendowed.com'>Spiros Eliopoulos</a></p>
  <p>Part of <a href='http://todomvc.com'>TodoMVC</a></p>
" in static "footer"
     |. str attr "id" "info"
     |. html (\_ _ -> content)

view = sequence todoapp low_footer

controller : Signal Model
controller =
  let initial = { input="", items=[], filter=All, editing=Nothing } in
  folde transform initial events

main : Signal Element
main = render 800 600 view <~ controller
