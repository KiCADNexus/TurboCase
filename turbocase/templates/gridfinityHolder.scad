/*
 * Gridfinity Rebuilt Bins
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 *
 * Remix of Gridfinity Rebuilt in OpenSCAD by kennetek
 * https://github.com/kennetek/gridfinity-rebuilt-openscad
 * https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad
 */

include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>

/* [General Settings] */
// number of bases along x-axis
gridx = 2; // [1:1:8]
// number of bases along y-axis
gridy = 2; // [1:1:8]

/* [Features] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

/* [Base] */
style_hole = 1; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit, 4: Gridfinity Refined hole - no glue needed]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0;

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

module main() {
    gf_init() {
        color("cornflowerblue", 0.8)
        render(convexity=4)
        gf_bin();
    }
}

main();
