var x1;
var y1;
var x2;
var y2;
var parkLoc;

var context;
var a0 = 950;
var a1 = 1110;
var a2 = 1700;
var a3 = 1915;
var b1 = 705;
var b2 = 930;
var b3 = 1150;
var b4 = 1375;
var b5 = 1475;
var b6 = 1600;
var loc1;
var loc2;
var deg = 1;
var ax = 1325;
var ay = 1035;
var bx = 1275;
var by = 1300;
var cx = 1037;
var cy = 1360;
var isFrom = false;
var curTooltip = "";



$(document).ready(function(){
    window.scrollTo(800,500);
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

    if (loc1 == 2 || loc1 == 3 || loc1 == 4 || loc1 == 7) {
        var $p1 = $('#p1');

        $p1.show();

        $p1.click(function () {
            Android.change('a');
        });


        $p1.hover(function () {

            $('#s1').addClass('sHover');
        }, function () {
            $('#s1').removeClass('sHover');
        });


        $('#s1').show();
        $('#tooltip1').show();

        curTooltip = '#tooltip1';
    } else if (loc1 == 5 || loc1 == 6 || loc1 == 8) {
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
    } else if (loc1 == 1) {
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
            drawAto2();
            deg = 3;
            break;
        case 3:
            drawAto3();
            if (x2 > ax) {
                deg = 3;
            } else {
                deg = 1;
            }
            break;
        case 4:
            drawAto4();
            if (x2 > ax) {
                deg = 3;
            } else {
                deg = 1;
            }
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
            drawBtoRight();
            deg = 1;
            break;
        case 7:
            drawAto7();
            if ((y2 < ay && y2 > b2) || y2 > b3) {
                deg = 0;
            } else if ((y2 < b2) || (y2 > ay && y2 < b3)) {
                deg = 2;
            }
            break;
        case 8:
            drawBto8();
            deg = 2;
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
                drawAto2();
                break;
            case 3:
                drawAto3();
                break;
            case 4:
                drawAto4();
                break;
            case 5:
                drawAto5();
                break;
            case 6:
                drawAto6();
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
                drawBtoLeft();
                break;
            case 5:
                drawBto5();
                break;
            case 6:
            case 7:
                drawBtoRight();
                break;
            case 8:
                drawBto8();
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
                drawCtoCenter();
                break;
            case 6:
                drawCto6();
                break;
            case 7:
                drawCto7();
                break;
            case 8:
                drawCto8();
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
    } else if ((loc1 == 1 && loc2 == 2) || (loc1 == 2 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to2(x1, y1, x2, y2);
        } else {
            deg = 3;
            drawPath1to2(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 3) || (loc1 == 3 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to3(x1, y1, x2, y2);
        } else {
            deg = 3;
            drawPath1to3(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 4) || (loc1 == 4 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to4(x1, y1, x2, y2);
        } else {
            deg = 3;
            drawPath1to4(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 5) || (loc1 == 5 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to5(x1, y1, x2, y2);
        } else {
            deg = 3;
            drawPath1to5(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 6) || (loc1 == 6 && loc2 == 1)) {
        deg = 1;
        if (loc1 < loc2) {
            drawPath1to6(x1, y1, x2, y2);
        } else {
            drawPath1to6(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 7) || (loc1 == 7 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to7(x1, y1, x2, y2);
        } else {
            deg = 2;
            drawPath1to7(x2, y2, x1, y1);
        }
    } else if ((loc1 == 1 && loc2 == 8) || (loc1 == 8 && loc2 == 1)) {
        if (loc1 < loc2) {
            deg = 1;
            drawPath1to8(x1, y1, x2, y2);
        } else {
            deg = 2;
            drawPath1to8(x2, y2, x1, y1);
        }
    } else if (loc1 >= 2 && loc1 <= 5 && loc2 >= 2 && loc2 <= 5) {

        drawPathCenter(x1, y1, x2, y2);

    }  else if (loc1 == 8 || loc2 == 8) {
        if (loc1 < loc2) {
            drawPathSide(x1, y1, x2, y2);
            if (loc1 == 7) {
                deg = 2;
            } else {
                deg = 1;
            }
        } else {
            deg = 2;
            drawPathSide(x2, y2, x1, y1);
        }
    }else if (loc1 == 6 || loc1 == 7 || loc2 == 6 || loc2 == 7) {
        if (loc1 < loc2) {
            deg = 1;
            drawPathRight(x1, y1, x2, y2);
        } else {

            drawPathRight(x2, y2, x1, y1);
            if (loc1 == 8) {
                deg = 1;
            }else if(loc1==6){
                deg=1;
            } else {
                if (y1 > y2) {
                    deg = 0;
                } else if (y1 < y2) {
                    deg = 2;
                } else {
                    deg = 3;
                }
            }
        }
    }

    drawCar(x2, y2);
    drawNav(x1, y1, deg);
}


function drawAto1() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, b5);
    context.lineTo(a0, b5);
    context.lineTo(a0, b4);
    context.lineTo(x2, y2);
    context.stroke();

    deg = 2;
}

function drawAto2() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b2);
    context.lineTo(a1, b2);
    context.lineTo(a1, b1);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 0;
}

function drawAto3() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b2);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 0;
}

function drawAto4() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b3);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 2;
}

function drawAto5() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b3);
    context.lineTo(a1, b3);
    context.lineTo(a1, b4);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 2;
}

function drawAto6() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b3);
    context.lineTo(a2, b3);
    context.lineTo(a2, b6);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 2;
}

function drawAto7() {
    context.moveTo(ax, ay);
    if (y2 > ay) {
        context.lineTo(ax, b3);
        context.lineTo(a2, b3);
        deg = 2;
    } else {
        context.lineTo(ax, b2);
        context.lineTo(a2, b2);
        deg = 0;
    }
    context.lineTo(x2, y2);
    context.stroke();
}

function drawAto8() {
    context.moveTo(ax, ay);
    context.lineTo(ax, b3);
    context.lineTo(a2, b3);
    context.lineTo(a2, b4);
    context.lineTo(a3, b4);
    context.lineTo(x2, y2);
    context.stroke();
    deg = 2;
}

function drawBto1() {
    context.moveTo(bx, by);
    context.lineTo(bx, b4);
    context.lineTo(a1, b4);
    context.lineTo(a1, b5);
    context.lineTo(a0, b5);
    context.lineTo(a0, b4);
    context.lineTo(x2, y2);
    context.stroke();
}
function drawBto5() {
    context.moveTo(bx, by);
    context.lineTo(bx, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBtoLeft() {
    context.moveTo(bx, by);
    context.lineTo(bx, b4);
    context.lineTo(a1, b4);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBtoRight() {
    context.moveTo(bx, by);
    context.lineTo(bx, b4);
    context.lineTo(a2, b4);
    context.lineTo(a2, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawBto8() {
    context.moveTo(bx, by);
    context.lineTo(bx, b4);
    context.lineTo(a3, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCto1() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b5);
    context.lineTo(a0, b5);
    context.lineTo(a0, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCtoCenter() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, y2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCto6() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a2, b4);
    context.lineTo(a2, b6);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCto7() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a2, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawCto8() {
    context.moveTo(cx, cy);
    context.lineTo(cx, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a3, b4);
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

function drawPathRight(x1, y1, x2, y2) {
    context.moveTo(x1, y1);

    context.lineTo(a2, y1);


    context.lineTo(a2, y2);

    context.lineTo(x2, y2);
    context.stroke();
}


function drawPathCenter(x1, y1, x2, y2) {
    context.moveTo(x1, y1);

    var dist1 = x1 - a1 + x2 - a1;

    var dist2 = a2 - x1 + a2 - x2;

    if (dist1 > dist2) {
        deg = 1;
        context.lineTo(a2, y1);
        context.lineTo(a2, y2);
    } else {
        deg = 3;
        context.lineTo(a1, y1);
        context.lineTo(a1, y2);
    }


    context.lineTo(x2, y2);
    context.stroke();
}

function drawPathSide(x1, y1, x2, y2) {

    context.moveTo(x1, y1);

    context.lineTo(a2, y1);
    context.lineTo(a2, b4);
    context.lineTo(a3, b4);

    context.lineTo(x2, y2);
    context.stroke();
}


function drawPath1to8(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a3, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to7(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a2, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to6(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(a2, b4);
    context.lineTo(a2, b6);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to5(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b4);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to4(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b3);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to3(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b2);
    context.lineTo(x2, y2);
    context.stroke();
}

function drawPath1to2(x1, y1, x2, y2) {
    context.moveTo(x1, y1);
    context.lineTo(a0, b4);
    context.lineTo(a0, b5);
    context.lineTo(a1, b5);
    context.lineTo(a1, b1);
    context.lineTo(x2, y2);
    context.stroke();
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

    if (y == b4 && x < a0) {
        return 1;
    }

    if (x == a2) {
        return 7;
    }

    if (x == a3) {
        return 8;
    }

    if (y == b1) {
        return 2;
    }

    if (y == b2) {
        return 3;
    }

    if (y == b3) {
        return 4;
    }

    if (y == b4 && x > a0) {
        return 5;
    }

    if (y == b6) {
        return 6;
    }
}


