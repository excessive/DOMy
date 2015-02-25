# Flexbox Properties

## Container

### display

* flex: acts like a block element for positioning purposes
* inline_flex: acts like an inline element for positioning purposes

### flex_direction

* row: children are place left-to-right in order
* row_reverse: children are placed right-to-left in reverse order
* column: children are placed top-to-bottom in order
* column_reverse: children are placed bottom-to-top in reverse order

### flex_wrap

* no_wrap: children will shrink in size to fit on a single line
* wrap: children will wrap like inline elements
* wrap_reverse: children are placed in reverse-minor-direction (row = row,column -> row = row,column_reverse) and wrapped accordingly

### justify_content

*Each row of elements is justified as a separate group.*

*Justify is specifically used for aligning elements along the MAIN axis.*

* start: children are grouped to the start of the line according to the flex_direction area (if direction is row, group to the left)
* end: children are grouped to the end of the line according to the flex_direction area (if direction is row, group to the right)
* center: children are grouped in the centre of the line
* space_between: children are spaced evenly across the line where the first child is on the start and the last child is on the end
	* Divided any extra space in the flex container by `children * 2`
	* Take that value and multiply it by two, then divide that amongst `children * 2 - 2`
	* E.g. If an element has 5 elements and 100 extra pixels of space, divide `100 / 10` to get `10px`. Now take `(10 * 2) / 8` (2.5) and add that to the remaining margins to get `12.5px` pe rmargin for 8 margins
* space_around:children are spaced evenly across the line
	* Divided any extra space in the flex container by `children * 2`
	* Apply this value as the left and right margins of each child element
	* E.g. If an element has 5 children and 100 extra pixels of space, divide `100 / 10` to get `10px` per margin for 10 margins.

### align_items

*Each row of elements is aligned as a separate group.*

*Align is specifically used for aligning elements along the CROSS axis.*

* start: children are aligned to the start of the column according to the flex_direction area (if direction is column, align to the top)
* end: children are aligned to the end of the column according to the flex_direction area (if direction is column, align to the bottom)
* center: children are aligned along the CROSS axis
* stretch: children's heights are proportionally increased to fill vertical space
* baseline: baselines (bottom of text on first line) are aligned

### align_content

*Align is specifically used for aligning elements along the CROSS axis.*

* See: justify_content.*


## Item

### order

### flex_grow

### flex_shrink

### flex_basis

### align_self
