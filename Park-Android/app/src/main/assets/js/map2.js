var x1;
var y1;
var x2;
var y2;
var parkLoc;

var context;
var a0 = 940;
var a1 = 1110;
var a2 = 1600;
var b0 = 690;
var b1 = 1150;
var b2 = 1370;
var b3 = 1480;
var b4 = 1595;
var loc1;
var loc2;
var deg = 1;
var ax = 1330;
var ay = 1150;
var bx = 1280;
var by = 1300;
var cx = 1035;
var cy = 1360;
var isFrom = false;
var curTooltip = "";

$(document).ready(function(){
    window.scrollTo(700,500);
});

function drawFrom(curLoc) {
    var canvas = document.getElementById('canvas');

    context = canvas.getContext('2d');
    context.beginPath();
    context.lineWidth = 10;
    context.strokeStyle = '#2979FF';

    $.each(marks, function (i, v) {
        if (v.id == curLoc) {
            x2 = v.x;
            y2 = v.y;
        }
    });

    loc1 = getLoc(x2, y2);

    if (loc1 == 2 || loc1 == 3 || loc1 == 4 || loc1 == 8) {
        var $p1 = $('#p1');

        $p1.click(function () {
            Android.change('a');
        });
        $p1.hover(function () {

            $('#s1').addClass('sHover');
        }, function () {
            $('#s1').removeClass('sHover');
        });
        $p1.show();
        $('#s1').show();
        $('#tooltip1').show();

        curTooltip = '#tooltip1';
    } else if (loc1 == 5 || loc1 == 7) {
        var $p2 = $('#p2');

        $p2.click(function () {
            Android.change('b');
        });

        $p2.hover(function () {

            $('#s2').addClass('sHover');
        }, function () {
            $('#s2').removeClass('sHover');
        });

        $p2.show();
        $('#s2').show();
        $('#tooltip2').show();
        curTooltip = '#tooltip2';
    } else if (loc1 == 1 || loc1 == 6) {
        var $p3 = $('#p3');

        $p3.click(function () {
            Android.change('c');
        });

        $p3.hover(function () {

            $('#s3').addClass('sHover');
        }, function () {
            $('#s3').removeClass('sHover');
        });

        $p3.show();
        $('#s3').show();
        $('#tooltip3').show();
        curTooltip = '#tooltip3';
    }


    switch (loc1) {
        case 1:
            drawCto1();
            deg = 1;
            break;
        case 2:
            drawAtoLeft();
            deg = 3;
            break;
        case 3:
            drawAtoLeft();
            deg=2;
            break;
        case 4:
            drawAto4();
            deg = 1;
            break;
        case 5:
            drawBto5();
            if (x2 > bx) {
                deg = 3;
            } else {
                deg = 1;
            }
            break;
        case 6:
            drawCtoLeft();
            deg = 3;
            break;
        case 7:
            drawBtoRight();
            deg = 1;
            break;
        case 8:
            drawAto8();
            deg = 3;
            break;
    }

    drawNav(x2, y2, deg);
    isFrom = true;
}

function drawTo(curLoc1, curLoc2) {

    var canvas = document.getElementById('canvas');

    context = canvas.getContext('2d');
    context.beginPath();
    context.lineWidth = 10;
    context.strokeStyle = '#2979FF';
    $.each(marks, function (i, v) {
        if (v.id == curLoc2) {
            x2 = v.x;
            y2 = v.y;
        }
    });

    loc1 = getLoc(x2, y2);

    if (curLoc1 == "a") {
        x1 = ax;
        y1 = ay;
        switch (loc1) {
            case 1:
                drawAto1();
                break;
            case 2:
            case 3:
            case 5:
            case 6:
                drawAtoLeft();
                break;
            case 4:
                drawAto4();
                break;
            case 7:
                drawAto7();
                break;
            case 8:
                drawAto8();
                break;
        }

    } else if (curLoc1 == "b") {
        x1 = bx;
        y1 = by;

        switch (loc1) {
            case 1:
                drawBto1();
                break;
            case 2:
            case 3:
            case 4:
            case 6:
                drawBtoLeft();
                break;
            case 5:
                drawBto5();
                break;
            case 7:
            case 8:
                drawBtoRight();
                break;
        }


        deg = 2;
    } else if (curLoc1 == "c") {
        x1 = cx;
        y1 = cy;

        switch (loc1) {
            case 1:
                drawCto1();
                break;
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
                drawCtoLeft();
                break;
            case 7:
            case 8:
                drawCtoRight();
                break;
        }
        deg = 2;
    }

    drawNav(x1, y1, deg);
    drawCar(x2, y2);

}


function rotateMap(rotation) {
    $(document.body).css('-webkit-transform', 'rotate(' + rotation + 'deg)');

    if(isFrom){
        $(curTooltip).css('-webkit-transform', 'rotate(' + -rotation + 'deg)');
    }
}

function drawMap(curLoc1, curLoc2) {


    var currentLoc = curLoc1;
    parkLoc = curLoc2;


    $.each(marks, function (i, v) {
        if (v.id == currentLoc) {
            x1 = v.x;
            y1 = v.y;
        }
    });


    loadCar();

    getPart();

    var canvas = document.getElementById('canvas');
    var image = document.getElementById('image');

    context = canvas.getContext('2d');
    context.beginPath();
    context.lineWidth = 10;
    context.strokeStyle = '#2979FF';


    if (loc1 == loc2) {
        drawPath(x1, y1, x2, y2);
        getDeg(x1, y1, x2, y2)
    } else if ((loc1 == 1 && loc2 < 7) || (loc2 == 1 && loc1 < 7)) {
        if (loc1 < loc2) {
            draw1toLeft(x1, y1, x2, y2);
            deg = 1;
        } else {
            draw1toLeft(x2, y2, x1, y1);
            if (loc1 == 3) {
                deg = 2;
            } else {
                deg = 3;
            }
        }
    } else if ((loc1 == 1 && loc2 > 6) || (loc2 == 1 && loc1 > 6)) {
        if (loc1 < loc2) {
            draw1toRight(x1, y1, x2, y2);
        } else {
            draw1toRight(x2, y2, x1, y1);
        }
        deg = 1;
    } else if (loc1 > 6 && loc2 > 6) {
        draw7To8();
        deg = 1;
    } else if (loc1 < 7 && loc2 < 7) {
        drawCenterToLeft();
        if (loc1 == 6) {
            deg = 1;
        } else if (loc1 == 3) {
            if (loc2 > loc1) {
                deg = 2;
            } else {
                deg = 0;
            }
        } else {
            deg = 3;
        }
    } else if(loc1==5||loc2==5){

        if (loc1 < loc2) {
            draw5toRight(x1, y1, x2, y2);
        } else {
            draw5toRight(x2, y2, x1, y1);
        }
        deg=1;
    } else{
        if (loc1 < loc2) {
            drawCenterToRight(x1, y1, x2, y2);
            if (loc1 == 3) {
                deg = 2;
            } else if (loc1 == 6) {
                deg = 1;
            } else if (loc1 == 5) {
                deg = 1;
            } else {
                deg = 3;
            }
        } else {
            drawCenterToRight(x2, y2, x1, y1);
            deg = 1;
        }
    }

    drawCar(x2, y2);
    drawNav(x1, y1, deg);
}

function draw1toLeft(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b2);
    context.lineTo(a0, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function draw1toRight(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b2);
    context.lineTo(a0, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, b2);
    context.lineTo(a2, b2);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCenterToLeft() {
    context.moveTo(x1, y1);
    context.lineTo(a1, y1);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCenterToRight(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a1, y1);
    context.lineTo(a1, b2);
    context.lineTo(a2, b2);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function draw5toRight(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a2, b2);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function draw7To8() {
    context.moveTo(x1, y1);
    context.lineTo(a2, y1);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCto1() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b3);
    context.lineTo(a0, b3);
    context.lineTo(a0, b2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCtoLeft() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCtoRight() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, b2);
    context.lineTo(a2, b2);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawAto1() {
    context.moveTo(ax, b1);
    context.lineTo(a1, b1);
    context.lineTo(a1, b3);
    context.lineTo(a0, b3);
    context.lineTo(a0, b2);
    context.lineTo(x2, y2);
    context.stroke();
}
function drawAto1() {
    context.moveTo(ax, b1);
    context.lineTo(a1, b1);
    context.lineTo(a1, b3);
    context.lineTo(a0, b3);
    context.lineTo(a0, b2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawAto1() {
    context.moveTo(ax, b1);
    context.lineTo(a1, b1);
    context.lineTo(a1, b3);
    context.lineTo(a0, b3);
    context.lineTo(a0, b2);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 3;
}

function drawAto4() {
    context.moveTo(ax, b1);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 3;
}

function drawAto8() {
    context.moveTo(ax, b1);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 1;
}

function drawAtoLeft() {
    context.moveTo(ax, b1);
    context.lineTo(a1, b1);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 3;
}

function drawAto7() {
    context.moveTo(ax, b1);
    context.lineTo(a2, b1);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 1;
}

function drawBto1() {
    context.moveTo(bx, by);
    context.lineTo(bx, b2);
    context.lineTo(a1, b2);
    context.lineTo(a1, b3);
    context.lineTo(a0, b3);
    context.lineTo(a0, b2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBtoLeft() {
    context.moveTo(bx, by);
    context.lineTo(bx, b2);
    context.lineTo(a1, b2);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBtoRight() {
    context.moveTo(bx, by);
    context.lineTo(bx, b2);
    context.lineTo(a2, b2);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBto5() {
    context.moveTo(bx, by);
    context.lineTo(bx, b2);
    context.lineTo(x2, y2);
    context.stroke();
}

function getDeg(x1, y1, x2, y2) {
    if (x1 == x2) {
        if (y1 > y2) {
            deg = 0;
        } else {
            deg = 2;
        }
    } else {
        if (x1 > x2) {
            deg = 3;
        } else {
            deg = 1;
        }
    }
}


function drawPath(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(x2, y2);
    context.stroke();
}


function drawCar(x, y) {
    var car = $('#car');
    car.css('left', x - 30);
    car.css('top', y - 30);
    car.show();
}


function drawNav(x, y, deg) {
    var nav = $('#loc');
    nav.css('left', x - 30);
    nav.css('top', y - 30);
    nav.css('transform', 'rotate(' + (90 * deg) + 'deg)');
    nav.show();
}


function getPart() {
    loc1 = getLoc(x1, y1);
    loc2 = getLoc(x2, y2);
}

function loadCar() {
    $.each(marks, function (i, v) {
        if (v.id == parkLoc) {
            x2 = v.x;
            y2 = v.y;
            return;
        }
    });
}


function getLoc(x, y) {

    if (y == b2 && x < a0) {
        return 1;
    }
    if (y == b3) {
        return 6;
    }

    if (x == a1) {
        return 3;
    }


    if (y == b0) {
        return 2;
    }


    if (y == b1 && x < ax) {
        return 4;
    }

    if (y == b1 && x > ax) {
        return 8;
    }


    if (y == b2 && x > a0) {
        return 5;
    }


    if (y == b4) {
        return 7;
    }
}


