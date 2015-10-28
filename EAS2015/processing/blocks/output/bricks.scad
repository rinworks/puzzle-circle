module brick(dots) {
    cube([14, 26, 8]);
    // dots are numbered like this:
    //  1 4
    //  2 5
    //  3 6
    for (i=[0,1]) {
        for (j=[0:1:2]) {
            // (2-j) makes the dots drawn from top towards bottom
            if (dots[i*3+(2-j)]>0.5) {
                translate ([3.5+i*7, 4.75+j*8, 0]) {
                    cylinder(r=2.5, h=10, $fn=30);
                    translate ([0,0,10])
                        cylinder(r1=2.5, r2=2.4, h=0.1, $fn=30);
                }
            }
        }
    }
}
