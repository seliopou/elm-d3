-- This is an Elm implementation of TodoMVC using elm-d3 to construct views.
-- For information about the TodoMVC project and the functionality that's
-- implemented below, go here:
--
--   http://todomvc.com
--
-- To build this app, from the root directory of the elm-d3 project, compile it
-- using the following commands:
--
--   make
--   elm --make --src-dir=src `./scripts/build-flags` `./scripts/include-css examples/todo.css` examples/Todo.elm
--
-- On OS X, you can then open the file in the browser using the following command:
--
--   open build/examples/Todo.html
--
module Todo where

-- Import D3 and dump all its names into the current scope. Also import event
-- handlers.
--
import D3(..)
import D3.Event(..)

-- Import Json to set DOM element properties in the view code. Import String to
-- use Elm's fast string library. Is this still necessary? I have no idea.
--
import Json
import String

-- There are some cases in the code below that should never happen and in fact
-- cannot ever happen. In other languages, you'd use an `asset false`
-- expression, or `undefined` to indicate that the case is impossible. In Elm,
-- you can call `Native.Error.raise`.
--
import Native.Error


-------------------------------------------------------------------------------
-- The Model
--
-- This section contains data type definitions for storing the state of the
-- application. It also contains several operations defined over those data
-- types that will come in handy later in the application.
--

-- The Filter data type represents the three different ways that you can filter
-- items in the Todo list.
--
data Filter
  = All         -- * Show all items.
  | Active      -- * Show active (incomplete) items.
  | Completed   -- * Show completed items.

-- The model for the Todo application. The entire state of the application is
-- contained in a record of this type. elm-d3 prohibits and statically enforces
-- the inability to read arbitrary information from the DOM. The only way to
-- read information from the DOM is through events. As a result, this will
-- serve not just as a record, but as an authoritative record of the
-- application state.
--
type Model = {
  input : String,               -- * The input for a new task description. Note
                                -- that this will be kept up-to-date with the
                                -- content of the <input> element the user
                                -- interacts with, but this is the authoritative
                                -- record of that input.

  items : [(String, Bool)],     -- * The items in the Todo list. Each item
                                -- includes a description and a 'status bit'
                                -- indicating whether the item has been
                                -- completed (True) or not (False).

  filter : Filter,              -- * The current filter that should be applied
                                -- to the view.

  editing : Maybe (String, Int) -- * When an item is being edited, this contains
                                -- its description and its index into the items
                                -- list. The None value indicates no item is
                                -- being edited
}

-- Sets that status bit of the item at index `i` to the value `b`.
--
setStatus : Model -> Int -> Bool -> Model
setStatus m i b =
  { m | items <- imap (\(t, s) j -> (t, if j == i then b else s)) m.items }

-- Sets the description of the item at index `i` to the value `d`.
--
setDescription : Model -> Int -> String -> Model
setDescription m i d =
  { m | items <- imap (\(t, s) j -> (if j == i then d else t, s)) m.items }

-- Start editing the item at index `i`.
--
startEdit : Model -> Int -> Model
startEdit m i =
  let description = fst (head (drop i m.items)) in
  { m | editing <- Just (description, i) }

-- Change the description of the current edit item to the value `d`.
--
changeEdit : Model -> String -> Model
changeEdit m d =
  case m.editing of
    Nothing -> Native.Error.raise "trying to edit while not editing"
    Just (_, i) -> { m | editing <- Just (d, i) }

-- Complete editing by setting the description of the current edit item to the
-- modified description, and returning the model to  non-edit state.
--
commitEdit : Model -> Model
commitEdit m =
  case m.editing of
    Nothing -> Native.Error.raise "trying to finishing editing while not editing"
    Just (t, i) -> let m' = setDescription m i t in { m' | editing <- Nothing }


-------------------------------------------------------------------------------
-- The Events
--
-- This section contains a data type definition high-level application events.
-- These events are semantically meaningful in the application's domain and
-- make no reference to how the user triggered the events. For example, the
-- `ChangeInput` event below was caused by a user keypress, but that's not
-- relevant to the "business logic" of the application. The view code to follow
-- takes care of mapping low-level DOM events to these high-level application
-- events, allowing the event handling code, i.e., the `transform` function, to
-- be written in the language of the application, rather than the langauge of
-- the DOM.
--

-- These are the high-level events that the Todo application must handle. In
-- the view code below, you'll map DOM events to this data type.
--
data Event
  = AddInput            -- * Create a new item out of the current input.
  | ChangeInput String  -- * Update the current input to have the given value.
  | Delete Int          -- * Remove the item from the given index.
  | Edit Int            -- * Edit the item with the given index.
  | ChangeEdit String   -- * Update the current edit with the given value.
  | CommitEdit          -- * Commit the edit to the given editing item.
  | CancelEdit          -- * Cancel the current edit.
  | Check Int           -- * Mark the item with the given index as completed.
  | Uncheck Int         -- * Mark the item with the given index as not completed.
  | Filter Filter       -- * Update the current Filter to the given value
  | Toggle Bool         -- * Mark all as items as complete (True) or incomplete
                        --   (False). This is not implemented.
  | Noop                -- * NOOP (do nothing).

-- This is an event handler. It specifies how the model should be modified
-- based on a high-level Event. Note that becuase events are represented as a
-- variant of an algebraic data type, the type system requires you to put
-- event-handling code all in one place. This will serve as the body of the
-- application's event loop.
--
transform : Event -> Model -> Model
transform e m =
  case e of
    AddInput -> { m | input <- ""
                    , items <- (m.input, False)::m.items }
    ChangeInput i -> { m |  input <- i }
    Filter      f -> { m | filter <- f }
    Toggle  onoff -> { m |  items <- map (\(d,_) -> (d, onoff)) m.items }
    Delete  index -> { m |  items <- ifilter (\_ j -> j /= index) m.items }
    Edit    index -> startEdit  m index
    ChangeEdit  d -> changeEdit m d
    CommitEdit    -> commitEdit m
    CancelEdit    -> { m | editing <- Nothing }
    Check   index -> setStatus m index True
    Uncheck index -> setStatus m index False
    Noop          -> m

-- This is the event stream that your DOM event handlers will push Events into
-- in your view code. Later, you'll loop over this stream using the transform
-- function above to produce a time-varying model.
--
events : Stream Event
events = stream ()


-------------------------------------------------------------------------------
-- Views
--
-- NOTE: By far, the majority of the code in this example is view code. Not all
-- of it will be commented as thoroughly as above, but enough will be in order
-- to get the point across. That is the hope, at least.
--

type Item = { text : String, completed : Bool, editing : Bool }

-- Turn the model into a list of items to be rendered, taking into account the
-- Filter mode. The record representing each item includes all the information
-- necessary to render the item. That information is in a form that can be
-- easily used by whatever mechanism is being used to render them to the
-- screen.
--
-- Most people think of a view as a template and nothing else. What about the
-- computation that goes into generating the parameters for the template? Is
-- that part of the view? In fact, it is. A view is not a template. It is a
-- computation turns the Model into something that a computer can draw on the
-- screen.
--
todoList : Model -> [Item]
todoList m =
  let display = case m.filter of
    All       -> \_ -> True
    Active    -> not
    Completed -> \x -> x
  in
  ifilterMap (\(t, b) i ->
    case (display b, m.editing) of
      (True , Just (t', j)) ->
        let editing = i == j
            text = if i == j then t' else t in
        Just { text = text, completed = b, editing = editing }
      (True , Nothing) ->
        Just { text = t, completed = b, editing = False }
      (False, _) ->
        Nothing)
     m.items

-- A D3 selection that, when rendered, will create an HTML fragment to display
-- and interact with an Item. The type `D3 Item Item` indicates that a list
-- of `Item`s is bound to current document subtree. This selection will
-- therefor have access to the `Item` that is bound to its parent element, or
-- "context", as well as its index.
--
-- To break this down, consider just the first two lines of the selection:
--
--   static "div"
--   |. str attr "class" "view"
--
-- This expression, when rendered, will produce the following HTML fragment:
--
--   <div class="view"></div>
--
-- Note that the expression in no way depends on the data bound to it. This
-- expression could in fact be used in any context, so it has the type
-- `D3 a a`. The use of the "static" operator indicates that a div element
-- should be added once and only once for the current datum. What this means is
-- clearer when considering the subexpression that creates a <label> element:
--
--   static "label"
--   |. text (\d i -> d.text)
--
-- This expression, when rendered, will produce the following HTML fragment:
--
--   <label>{{d.text}}</label>
--
-- The text of the label depends on the text of the item, represented here as
-- the argument `d` to the function. The text of the element will update
-- whenever the data bound to the subtree changes to reflect the current text
-- of the item.The unused argument `i` is the item's index in the list of data
-- bound the current document subtree. The "static" keyword ensures that there
-- is only one <label> added for item. If "append" were used here instead, then
-- the selection would create a new element every time it was rerendered.
--
-- Event handlers are not written inline. The expression:
--
--   click events (\e d i -> Delete i)
--
-- will call the function and pass it the click event `e`, the datum bound to
-- the element `d`, and the datum's index `i`. The result of the function call
-- is an application-level event that will be inserted into the `events` event
-- stream. This application-level event will then be handled by an explict
-- event loop involving the `transform` function defined above.
--
-- When this selection is rendered, it will create a document fragment that looks
-- something like this, with event handlers and properties omitted:
--
--   <div class="view">
--     <input class="toggle" type="checkbox" />
--     <label>{{item.text}}</label>
--     <button class="destroy" />
--   </div>
--
item_view : D3 Item Item
item_view =
  static "div"
  |. str attr "class" "view"
  |- static "input"
     |. str attr "class" "toggle"
     |. str attr "type" "checkbox"
     |. property "checked" (\d i -> Json.Boolean d.completed)
     |. click events (\e d i -> if d.completed then Uncheck i else Check i)
  |- static "label"
     |. text (\d _ -> d.text)
  |- static "button"
     |. str attr "class" "destroy"
     |. click events (\e d i -> Delete i)

-- A D3 selection that, when rendered, will create an HTML fragment to edit an
-- item. This uses the same general concepts as item_view above, while making
-- use of the new `keyup` and `blur` event handlers.
--
item_edit : D3 Item Item
item_edit =
  static "input"
  |. str attr "class" "edit"
  |. property "value" (\d i -> Json.String d.text)
  |. input events (\e d i -> ChangeEdit e)
  |. keyup events (\e d i ->
       case e.keyCode of
         27 -> CancelEdit -- ESC_KEY
         13 -> CommitEdit -- ENTER_KEY
         _  -> Noop)
  |. blur events (\d i -> CancelEdit)

-- A D3 Widget that will bind a new set of data to its subtree based on the
-- data bound to the parent selection. The breakdown:
--
--   selectAll "li"
--   |= todoList
--
-- is the code that creates the Widget. This will create a list of `Item`s from
-- the `Model` that's bound to the parent, and assert that each one of those
-- `Item`s should be in one-to-one correspondence with the <li> elements that
-- are children of the current parent. The rest of the code handles the
-- different cases that may arise while maintaining this one-to-one
-- correspondence: creating, updating, and removing elements.
--
--    enter <.> append "li"
--    |. dblclick events (\e d i -> Edit i)
--
-- Handles the case when an <li> must be created to for an item. It appends an
-- <li> elemnent to the parent and registers a signal handler. In this case,
-- the signal handler interprets a user's double-click on the element as
-- indicating that user wants to edit the `Item` with index `i`.
--
-- In both the update and exit, case, the element already exists, and all
-- operations are applied to that element. For example,
--
--   exit
--   |. remove
--
-- indicates that the remove operation should be applied to all <li> elements
-- that no longer have a corresponding `Item` in the data bind. The update
-- operations
--
--   update
--   |. classed "editing"   (\d i -> d.editing)
--   |. classed "completed" (\d i -> d.completed)
--   |. (sequence item_view item_edit)
--
-- will be applied to an existing <li> element. The `classed` operations will
-- set the classes of the <li> element appropriately, depending on `d`: the
-- `Item` associated with the current element. The final line applies
-- previously-defined selections to the element, which may in general modify
-- element attributes and add children to the element. In this case, the
-- behavior of the selections is know, as they're defined above: `item_view`
-- will display the actual content of each `Item`, and `item_edit` adds editing
-- functionality to each `Item`.
--
items : D3 Model Item
items =
  selectAll "li"
  |= todoList
     |- enter <.> append "li"
        |. dblclick events (\e d i -> Edit i)
     |- update
        |. classed "editing"   (\d i -> d.editing)
        |. classed "completed" (\d i -> d.completed)
        |. (sequence item_view item_edit)
     |- exit
        |. remove

-- The remainder of the view code uses concepts previously described, so the
-- explanations will be omitted. Continue down to "The Application" section to
-- see how everything fits together.
--
content : D3 Model Model
content =
  let header =
    static "header"
    |. str attr "id" "header"
    |- static "h1"
       |. text (\_ _ -> "todo")
    |- static "input"
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
  let main =
    static "section" <.> str attr "id" "main"
    |- static "input"
       |. str attr "id" "toggle-all"
       |. str attr "type" "checkbox"
    |- static "ul"
       |. str attr "id" "todo-list"
       |. items
  in
  sequence header main

footer : D3 Model Model
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
  |- count
  |- static "ul" <.> str attr "id" "filters"
     |. filters

todoapp : D3 Model Model
todoapp =
  static "section" <.> str attr "id" "todoapp"
  |- content
  |- footer

low_footer : D3 a a
low_footer =
  let content ="
  <p>Double-click to edit a todo</p>
  <p>Created by <a href='http://computationallyendowed.com'>Spiros Eliopoulos</a></p>
  <p>Part of <a href='http://todomvc.com'>TodoMVC</a></p>
" in static "footer"
     |. str attr "id" "info"
     |. html (\_ _ -> content)


-------------------------------------------------------------------------------
-- The Application
--

-- The view is the composition of two D3 selections defined above, each
-- rendered as children of the root element provided by the Elm runtime.
--
view = sequence todoapp low_footer

-- A controller mediates user interactions with model updates. In other words,
-- it can take a Stream Event and transform that into a Signal Model. It does
-- this by using the folde function, which given an initial Model and a
-- function that can transform that Model given an Event, will produce a Signal
-- Model. The transform function is the one defined above, and the initial
-- Model contains no items and an empty input box.
--
controller : Stream Event -> Signal Model
controller =
  let initial = { input="", items=[], filter=All, editing=Nothing } in
  folde transform initial

-- This is the 'entry-point' of the application. It's also where the
-- controller's wired up to the view. The view pushes its Events to the events
-- stream, which is fed into the controller to produce a Signal of Models.
--
-- The render function serves two purposes. First, it performs the initial data
-- binding to the view, which provides data bindings in the model an input from
-- which to derive new data. Second, it passes the view representation to the
-- runtime to render it as a document fragment.
--
-- In the use of render below, it is lifted to a Signal of Models. This will
-- cause the view to be rerendered every time the Model changes.
--
main : Signal Element
main = render 800 600 view <~ (controller events)


-------------------------------------------------------------------------------
-- Helper functions (undocumented)
--

imap f l =
  let loop i l =
    case l of
      [] -> []
      x::xs -> (f x i)::(loop (i + 1) xs)
  in
  loop 0 l

ifilter f l =
  let loop i l =
    case l of
      [] -> []
      x::xs ->
        if f x i
          then x::(loop (i + 1) xs)
          else loop (i + 1) xs
  in
  loop 0 l

ifilterMap f l =
  let loop i l =
    case l of
      [] -> []
      x::xs ->
        case f x i of
          Nothing -> loop (i + 1) xs
          Just x' -> x'::(loop (i + 1) xs)
  in
  loop 0 l
