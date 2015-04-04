# DOMy Preliminary Specification Sheet

**All objects have the following specification:**

* The first value in sequential pairs must always be the object type
* The second value in sequential pairs will be the object value given an object is expected to have an explicit value (such as a text box) and that the value is not a function or a table that contains an object type declaration. This allows for formatted text to be written in a table so long as the first value of that table is not "textbox", "button", et cetera
* All sequential pairs thereafter will be assumed to be child objects and any pair that is not formatted correctly will be discarded


## Global

* **style**
    * Style Documents list in reverse order of priority (third overwrites second overwrites first)
* **document**
    * Document Object Model (DOM)


## Block Level Object Types

***Block level object type is defines as and object whose next sibling is displayed below it.***

* **block**
    * Contains other objects
* **tab**
    * Display information based on selected tab
* **grid**
    * Displays objects in grid cells
* **list**
    * Displays objects in a bulleted list
* **radio_list**
    * Displays options in an interactive bulleted list
    * Only one option selectable at a time
* **check_list**
    * Displays options in an interactive bulleted list
    * Multiple options selectable at the same time
* **multi_list**
    * Displays a single selected option
    * Interact with multi_list to display all other options


## Inline Level Object Types

***Inline level object type is defines as and object whose next sibling is displayed beside it.***

* **inline**
    * Contains other objects
* **text**
    * Contains text
* **image**
    * Displays an image
* **button**
    * Interactive object
* **input**
    * Interactive object
    * Allows user to input text
* **slider**
    * Interactive object
    * Move indicator to determine value
* **progress**
    * Indicates percentage between two numbers


## Input Events

***Virtual Input Events™ is a processing layer for events that can take in raw input from love or from any other source (e.g. network). VIE can be toggled in part or in full to allow full customization of if and when the GUI should be accepting input, and from where (e.g. only enable mouse events if some flag is set).***

**Bubble:** Event propagates up through document hierarchy from the target object to the root ancestor.

**Capture:** Event propagates down through document hierarchy from the root ancestor to the target object.

**Catch:** Object takes over event and stops propagation from going further.

### Mouse Events

* **on_mouse_enter**
    * Mouse cursor begins hovering over object
    * No propagation
* **on_mouse_over**
    * Mouse cursor is hovering over object
    * No propagation
* **on_mouse_leave**
    * Mouse cursor stops hovering over object
    * No propagation
* **on_mouse_pressed**
    * Mouse button is pressed while hovering over object
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_mouse_released**
    * Mouse button is released while hovering over object
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_mouse_clicked**
    * Mouse button is both pressed and released while hovering over object
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_mouse_down**
    * Mouse button is held down
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch


### Keyboard Events

* **on_key_pressed**
    * A key is pressed
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_key_released**
    * A key is released
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_key_down**
    * A key is held down
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_text_input**
    * Text is inputted into LOVE


### Touch Events

* **on_touch_pressed**
    * A finger has been placed on a touch screen
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_touch_released**
    * A finger has been removed from a touch screen
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_touch_moved**
    * A finger that has been pressed but not released has moved to a new point on the touch screen
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_touch_gestured**
    * Predefined list of general on_touch_moved events
        * "Finger moved left 10% then up 15% then down 25%"
    * Probably requires a precision tolerance
    * Probably requires an optional starting and ending point
        * if on_touch_pressed is on Object 1
        * if on_touch_released is on Object 2
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch


### Joystick Events

* **on_joystick_added**
    * A joystick is added
* **on_joystick_removed**
    * A joystick is removed
* **on_joystick_pressed**
    * A joystick button is pressed
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_joystick_released**
    * A joystick button is released
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_joystick_down**
    * A joystick button is held down
    * Includes axis and hat checks
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_joystick_axis**
    * A joystick axis value changes
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_joystick_hat**
    * A joystick hat value changes
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch


### Gamepad Events

***A virtual gamepad is a joystick that emulates an Xbox 360 controller.***

* **on_gamepad_pressed**
    * A gamepad button is pressed
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_gamepad_released**
    * A gamepad button is released
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
* **on_gamepad_down**
    * A gamepad button is held down
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch
    * Includes axis checks
* **on_gamepad_axis**
    * A gamepad axis value changes
    * Bubble propagation until Catch
    * If no Catch, Capture propagation until Catch


### Window Events

* **on_resize**
    * The LOVE window has been resized


### Object Specific Events

#### multi_list, radio_list, check_list

* **on_select**
    * When a child object is selected


## Object Attributes

### Global

* **id**
    * Unique identifer
* **type**
    * Type of object
* **class**
    * Predefined styles and scripts
    * Classes list in reverse order of priority
* **_UNNAMED**
    * Content/Value within object


### slider, progress

* **min**
    * Minimum value
* **max**
    * Maximum value


## Object Properties

### Color Properties

* **color**
    * Sets the color of text
* **opacity**
    * Sets the opacity level for an element


### Background Properties

* **background-color**
    * Sets the background color of an element
* **background-image**
    * Sets the background image for an element
* **background-position**
    * Sets the starting position of a background image
* **background-repeat**
    * Sets how a background image will be repeated
* **background-clip**
    * Specifies the painting area of the background
* **background-origin**
    * Specifies the positioning area of the background images
* **background-size**
    * Specifies the size of the background images


### Border Properies

* **border-color**
    * Sets the color of the border
* **border-radius**
    * Defines the shape of the border's corners
* **border-style**
    * Sets the style of the border
* **border-width**
    * Sets the width of the border
* **border-image-repeat**
    * Specifies whether the image-border should be repeated, rounded or stretched
* **border-image-slice**
    * Specifies the inward offsets of the image-border
* **border-image-source**
    * Specifies an image to be used as a border
* **border-image-width**
    * Specifies the widths of the image-border


### Basic Box Properties

* **bottom**
    * Specifies the bottom position of a positioned element
* **box-shadow**
    * Attaches one or more drop-shadows to the box
* **clip**
    * Clips an absolutely positioned element
* **display**
    * Specifies how a certain HTML element should be displayed
* **height**
    * Sets the height of an element
* **left**
    * Specifies the left position of a positioned element
* **margin**
    * Sets margins around object
* **overflow**
    * Specifies what happens if content overflows an element's box
* **padding**
    * Sets padding within object
* **position**
    * Specifies the type of positioning method used for an element
* **right**
    * Specifies the right position of a positioned element
* **top**
    * Specifies the top position of a positioned element
* **visibility**
    * Specifies whether or not an element is visible
* **width**
    * Sets the width of an element
* **vertical-align**
    * Sets the vertical alignment of an element
* **z-index**
    * Sets the stack order of a positioned element
* **tab-index**
    * Sets the order of interaction of an element (relative to siblings)


### Flexible Box Layout

* **align-content**
    * Specifies the alignment between the lines inside a flexible container when the items do not use all available space
* **align-items**
    * Specifies the alignment for items inside a flexible container
* **align-self**
    * Specifies the alignment for selected items inside a flexible container
* **display**
    * Specifies how a certain HTML element should be displayed
* **flex**
    * Specifies the length of the item, relative to the rest
* **flex-basis**
    * Specifies the initial length of a flexible item
* **flex-direction**
    * Specifies the direction of the flexible items
* **flex-flow**
    * A shorthand property for the flex-direction and the flex-wrap properties
* **flex-grow**
    * Specifies how much the item will grow relative to the rest
* **flex-shrink**
    *Specifies how the item will shrink relative to the rest
* **flex-wrap**
    * Specifies whether the flexible items should wrap or not
* **max-height**
    * Sets the maximum height of an element
* **max-width**
    * Sets the maximum width of an element
* **min-height**
    * Sets the minimum height of an element
* **min-width**
    * Sets the minimum width of an element


### Text Properties

* **overflow-wrap**
    * Determine if overflow is wrapped or clipped
* **text-align**
    * Specifies the horizontal alignment of text
* **text-justify**
    * Specifies the justification method used when text-align is "justify"
* **word-wrap**
    * Allows long, unbreakable words to be broken and wrap to the next line
* **line-height**
    * Adjust how close lines of text are drawn together


### Text Decoration Properties

* **text-decoration**
    * Specifies the decoration added to text
* **text-decoration-color**
    * Specifies the color of the text-decoration
* **text-shadow**
    * Adds shadow to text


### Font Properties

* **font-face**
    * Specifies the font to use
* **font-size**
    * Specifies the font size


### List Properties

* **list-style-image**
    * Specifies an image as the list-item marker
* **list-style-type**
    * Specifies the type of list-item marker
* **list-style-flow**
    * Specifies if list items flow horizontally or vertically


### Basic User Interface Properties

* **cursor**
    * Specifies the cursor to be displayed
* **resize**
    * Specifies whether or not an element is resizable by the user
* **text-overflow**
    * Specifies what should happen when text overflows the containing element
* **scrollable**
    * Specifies whether an object is scrollable


### Grid Properties
* **column**
    * Specifies the number of columns an element should be divided into
* **column-span**
    * Specifies how many columns an element should span across
* **cell-height**
    * Specifies the height of the cells
* **cell-margin**
    * Sets margins around cells
* **cell-padding**
    * Sets padding around cells
* **cell-width**
    * Specifies the width of the cells
* **row**
    * Specifies the number of rows an element should be divided into
* **row-span**
    * Specifies how many rows an element should span across


### Animation Properties
* **@keyframes**
    * Specifies the animation
* **animation**
    * A shorthand property for all the animation properties below, except the animation-play-state property
* **animation-delay**
    * Specifies when the animation will start
* **animation-direction**
    * Specifies whether or not the animation should play in reverse on alternate cycles
* **animation-duration**
    * Specifies how many seconds or milliseconds an animation takes to complete one cycle
* **animation-fill-mode**
    * Specifies what values are applied by the animation outside the time it is executing
* **animation-iteration-count**
    * Specifies the number of times an animation should be played
* **animation-name**
    * Specifies a name for the @keyframes animation
* **animation-timing-function**
    * Specifies the speed curve of the animation
* **animation-play-state**
    * Specifies whether the animation is running or paused


### Masking Properties

* **mask**
    * Uses an alpha image to mask parts of an object


## Scripts

### Document


### Node


### Element


### Event

https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
http://balpha.de/2013/07/android-development-what-i-wish-i-had-known-earlier/
http://en.wikipedia.org/wiki/VRPN
