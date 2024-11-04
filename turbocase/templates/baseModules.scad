
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
// Space between the top of the PCB and the top of the case
headroom = {{ [case.max_connector_height, case.max_part_height - case.standoff_height - case.pcb_thickness]|max }};

{% for insert in inserts %}

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

module wall (thickness, height) {
    linear_extrude(height, convexity=10) {
        difference() {
            offset(r=thickness)
                children();
            children();
        }
    }
}

module bottom(thickness, height) {
    linear_extrude(height, convexity=3) {
        offset(r=thickness)
            children();
    }
}

module lid(thickness, height, edge) {
    linear_extrude(height, convexity=10) {
        offset(r=thickness)
            children();
    }
    translate([0,0,-edge])
    difference() {
        linear_extrude(edge, convexity=10) {
                offset(r=-0.2)
                children();
        }
        translate([0,0, -0.5])
         linear_extrude(edge+1, convexity=10) {
                offset(r=-1.2)
                children();
        }
    }
}


module box(wall_thick, bottom_layers, height) {
    if (render == "all" || render == "case") {
        translate([0,0, bottom_layers])
            wall(wall_thick, height) children();
        bottom(wall_thick, bottom_layers) children();
    }
    
    if (render == "all" || render == "lid") {
        translate([0, 0, height+bottom_layers+0.1])
        lid(wall_thick, bottom_layers, lid_model == "inner-fit" ? headroom-2.5: bottom_layers) 
            children();
    }
}

module mount(drill, space, height) {
    translate([0,0,height/2])
        difference() {
            cylinder(h=height, r=(space/2), center=true);
            cylinder(h=(height*2), r=(drill/2), center=true);
            
            translate([0, 0, height/2+0.01])
                children();
        }
        
}

module connector(min_x, min_y, max_x, max_y, height) {
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    translate([(min_x + max_x)/2, (min_y + max_y)/2, height/2])
        cube([size_x, size_y, height], center=true);
}

{% for extraModule in case.modules -%}
    {{ extraModule }}
{% endfor -%}

module pcb() {
    color("#009900")

    difference() {
        linear_extrude(pcb_thickness) {
            polygon(points = {{ points_edge_cuts }});
        }
    {% for pcb_hole in case.pcb_holes %}
        {% if pcb_hole.is_circle -%}
            translate([{{ pcb_hole.point[0] }}, {{ pcb_hole.point[1] }}, -1])
                cylinder(pcb_thickness+2, {{ pcb_hole.radius }}, {{ pcb_hole.radius }});
        {% elif pcb_hole.is_rect -%}
            translate([{{ pcb_hole.point[0] }}, {{ pcb_hole.point[1] }}, 0])
                cube([{{ pcb_hole.width }}, {{ pcb_hole.height }}, pcb_thickness + 2], center=true);
        {% else -%}
            translate([0, 0, -1])
                linear_extrude(pcb_thickness+2)
                    {{ pcb_hole.points }}
        {% endif -%}
    {% endfor %}
    }
}

module case_outline() {
    polygon(points = {{ points_outline }});
}

{% for insert in inserts -%}
module Insert_{{insert[0]}}() {
    translate([0, 0, -insert_{{insert[0]}}_depth])
        cylinder(insert_{{insert[0]}}_depth, insert_{{insert[0]}}_diameter/2, insert_{{insert[0]}}_diameter/2);
    translate([0, 0, -0.3])
        cylinder(0.3, insert_{{insert[0]}}_diameter/2, insert_{{insert[0]}}_diameter/2+0.3);
}
{% endfor -%}
