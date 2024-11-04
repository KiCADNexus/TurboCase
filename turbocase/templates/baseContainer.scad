rotate([render == "lid" ? 180   : 0, 0, 0])
scale([1, -1, 1])
translate([-{{center[0]}}, -{{center[1]}}, h_offset]) {
    pcb_top = floor_height + standoff_height + pcb_thickness;
    difference() {
        box(wall_thickness, floor_height, inner_height) {
            case_outline();
        }

        // Cutouts
    {% for cutout in case.cutouts %}
        {% if cutout.is_circle -%}
            translate([{{ cutout.point[0] }}, {{ cutout.point[1] }}, -1])
                cylinder(floor_height+2, {{ cutout.radius }}, {{ cutout.radius }});
        {% elif cutout.is_rect -%}
            translate([{{ cutout.point[0] }}, {{ cutout.point[1] }}, 0])
                cube([{{ cutout.width }}, {{ cutout.height }}, floor_height + 2], center=true);
        {% else -%}
            translate([0, 0, -1])
                linear_extrude(floor_height+2, convexity=10)
                polygon(points = {{ cutout.points }});
        {% endif -%}
    {% endfor %}

        // Lid holes
    {% for lid_hole in case.lid_holes %}
        {% if lid_hole.is_circle -%}
            translate([{{ lid_hole.point[0] }}, {{ lid_hole.point[1] }}, inner_height])
                cylinder(floor_height+2, {{ lid_hole.radius }}, {{ lid_hole.radius }});
        {% elif lid_hole.is_rect -%}
            translate([{{ lid_hole.point[0] }}, {{ lid_hole.point[1] }}, inner_height+floor_height])
                cube([{{ lid_hole.width }}, {{ lid_hole.height }}, floor_height + 2], center=true);
        {% else -%}
            translate([0, 0, inner_height])
                linear_extrude(floor_height+2)
                polygon(points = {{ lid_hole.points }});
        {% endif -%}
    {% endfor %}

        // Connectors
    {% for connector in case.connectors %}
        // {{ connector.reference }} {{ connector.footprint }} {{ connector.description }} 
        translate([{{ connector.position[0] }}, {{ connector.position[1] }}, pcb_top])
        rotate([0, 0, -{{ connector.position[2] }}])
            #connector({{ connector.bounds[0] }}, {{ connector.bounds[1] }}, {{ connector.bounds[2] }}, {{ connector.bounds[3] }}, {{ connector.prop_height + 0.2 }});
    {% endfor %}

        // Parts
    {% for part in case.parts -%}
    {% if part.substract != None %}
        // Substract: {{ part.description }}
        translate([{{ part.position[0] }}, {{ part.position[1] }}, {% if part.offset_pcb %}pcb_top{% else %}floor_height{% endif %}])
        {% if part.position|length == 3 %}rotate([0, 0, -{{ part.position[2] }}]){% endif %}
            {{ part.substract }};
    {% endif -%}
    {% endfor %}
    }

    if (show_pcb && $preview) {
        translate([0, 0, floor_height + standoff_height])
            pcb();
    }

    if (render == "all" || render == "case") {
        {% for mount in case.pcb_mount -%}
        // {{ mount.ref }} [{{ mount.insert }}]
        translate([{{ mount.position[0] }}, {{ mount.position[1] }}, floor_height])
        mount({{ mount.drill }}, {{ mount.size }}, standoff_height)
            Insert_{{ mount.insert[0] | replace(".","_") }}();
        {% endfor %}
    }
    
{% if has_contrained %}
    // Constrained parts
    intersection() {
        translate([0, 0, floor_height])
        linear_extrude(inner_height)
            case_outline();

        union() {
{% for part in case.parts -%}
    {% if part.constrain and part.add %}
            // {{ part.description }}
            translate([{{ part.position[0] }}, {{ part.position[1] }}, {% if part.offset_pcb %}pcb_top{% else %}floor_height{% endif %}])
            {% if part.position|length == 3 %}rotate([0, 0, -{{ part.position[2] }}]){% endif %}
            {% if part.insert_module -%}
                {{ part.add }}
                Insert_{{part.insert_module[0]}}();
            {% else -%}
                {{ part.add }};
            {% endif -%}
    {% endif -%}
{% endfor %}
        }
    }
{% endif -%}

{% for part in case.parts -%}
{% if not part.constrain and part.add != None %}
    // {{ part.description }}
    translate([{{ part.position[0] }}, {{ part.position[1] }}, {% if part.offset_pcb %}pcb_top{% else %}floor_height{% endif %}])
    {% if part.position|length == 3 %}rotate([0, 0, -{{ part.position[2] }}]){% endif %}
    {% if part.insert_module -%}
        {{ part.add }}
        Insert_{{part.insert_module[0]}}();
    {% else -%}
        {{ part.add }};
    {% endif -%}
{% endif -%}
{% endfor -%}

{% for part in case.parts -%}
{% if part.lid %}
    // {{ part.description }}
    translate([{{ part.position[0] }}, {{ part.position[1] }}, {% if part.offset_pcb %}pcb_top{% else %}floor_height{% endif %}])
    {% if part.position|length == 3 %}rotate([0, 0, -{{ part.position[2] }}]){% endif %}
        {{ part.lid }};
{% endif -%}
{% endfor %}
}
