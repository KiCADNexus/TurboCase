
/* [Gridfinity] */
gridx = {{ (case.width / 42.0)|round(method='ceil') }}; // [1:1:8]
gridy = {{ (case.height / 42.0)|round(method='ceil') }}; // [1:1:8]

include <turbocase/templates/gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>

{% include "turbocase/templates/baseConstants.scad" %}

/* [Features] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

// Forces the walls to be 0 height
// inner_height = 0;

/* [Base] */
style_hole = 1; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit, 4: Gridfinity Refined hole - no glue needed]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0;

/* [Compatibility] */
h_offset = bp_h_bot;

{% include "turbocase/templates/baseModules.scad" %}

module __end_customizer_options__() { }

// Modules //

module gf_init(bin=false) {

    $gxx = gridx;
    $gyy = gridy;
    $ll = l_grid;

    if (bin) {
        difference() {
            union() {
                gridfinityBase(
                    $gxx, $gyy, $ll,
                    div_base_x, div_base_y,
                    style_hole, only_corners=only_corners
                );
            }
            children();
        }
    } else {
        children();
    }
}

module gf_bin() {
    gf_init(bin=true)
    children();
}

// Main Module //

gf_init() {
    // color("cornflowerblue", 0.8)
    render(convexity=4)
    gf_bin();
}

{% include "turbocase/templates/baseContainer.scad" %}
