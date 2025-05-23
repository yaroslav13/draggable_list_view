# Draggable List View

A custom Flutter widget that dynamically calculates item heights and supports _peek-and-reveal_ behavior with drag-to-expand functionality. New items can be added or removed at runtime, and the list updates accordingly.

## Demo

![Example](https://raw.githubusercontent.com/yaroslav13/draggable_list_view/main/assets/example.gif)

## Features

- **Dynamic Item Sizing:**  
  Measures and adjusts for items of varying heights.

- **Peek Preview:**  
  Shows a configurable number of last items (and an optional fraction of the next item) in collapsed state.

- **Drag-to-Reveal:**  
  User can drag the list up or down to reveal more items, smoothly transitioning between states.

- **Programmatic Control:**  
  Exposes a `DraggableListController` for `expand()`, `collapse()`, and end-reached callbacks via listener registration.

- **Automatic Updates:**  
  Handles changes to item count, peek settings, and preview fraction without losing measurements.  
