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


color([0.75, 0.75, 0.75]) {
    translate([0, 0, 0]) brick([1,0,1,1,1,1]); // y
    translate([30, 0, 0]) brick([1,1,1,0,1,0]); // r
    translate([60, 0, 0]) brick([0,1,1,1,1,0]); // t
    translate([90, 0, 0]) brick([1,1,0,0,0,0]); // b
    translate([120, 0, 0]) brick([0,0,0,0,0,0]); //  
    translate([150, 0, 0]) brick([1,0,1,0,1,1]); // z
    translate([180, 0, 0]) brick([1,1,0,0,0,0]); // b
    translate([210, 0, 0]) brick([0,1,0,1,0,0]); // i
    translate([240, 0, 0]) brick([1,1,1,0,0,1]); // v
    translate([270, 0, 0]) brick([1,1,1,0,1,0]); // r
    translate([300, 0, 0]) brick([0,0,0,0,0,0]); //  
    translate([330, 0, 0]) brick([0,1,0,1,1,0]); // j
    translate([360, 0, 0]) brick([1,1,1,0,0,1]); // v
    translate([390, 0, 0]) brick([1,0,1,1,0,0]); // m
    translate([420, 0, 0]) brick([1,0,1,1,1,0]); // n
    translate([450, 0, 0]) brick([1,0,0,0,1,0]); // e
    translate([480, 0, 0]) brick([1,1,1,1,1,0]); // q
}



