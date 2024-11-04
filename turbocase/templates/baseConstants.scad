/* [Rendering options] */
// Show placeholder PCB in OpenSCAD preview
show_pcb = {% if show_pcb == True %}true{% else %}false{% endif %};
// Lid mounting method
lid_model = "{{ case.lid_model }}"; // [cap, inner-fit]
// Conditional rendering
render = "case"; // [all, case, lid]


/* [Dimensions] */
// Height of the PCB mounting stand-offs between the bottom of the case and the PCB
standoff_height = {{ case.standoff_height }};
// PCB thickness
pcb_thickness = {{ case.pcb_thickness }};
// Bottom layer thickness
floor_height = {{ case.floor_thickness }};
// Case wall thickness
wall_thickness = {{ case.wall_thickness }};
// Offset from the bottom of space
h_offset = 0;
// Space between the top of the PCB and the top of the case
headroom = {{ [case.max_connector_height, case.max_part_height - case.standoff_height - case.pcb_thickness]|max }};

{% for insert in inserts -%}
/* [{{insert[0]}} screws] */
// Outer diameter for the insert
// 0.77 is added partially as a sane-ish default, but also to force OpenSCAD to allow 2 positions of floating point
// precision in the customizer for this value
insert_{{insert[0]}}_diameter = {{insert[1] + 0.77}};
// Depth of the insert
insert_{{insert[0]}}_depth = {{insert[1] * 1.5}};
{% endfor %}

/* [Hidden] */
$fa=$preview ? 10 : 4;
$fs=0.2;
inner_height = floor_height + standoff_height + pcb_thickness + headroom;
