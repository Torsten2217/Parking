package com.dashang.park.model;

import java.util.Arrays;
import java.util.List;

public class MarkModel {

    private String[] sMarks1 = {"L2-A01", "L2-A11", "L2-A10", "L2-A04", "L2-A14", "L2-A07", "L2-A17", "L2-A20", "L2-A23", "L2-A24", "L2-A26", "L2-A29", "L2-A31", "L2-A34", "L2-A36", "L2-B01", "L2-B15", "L2-B02", "L2-B16", "L2-B02", "L2-B05", "L2-B08", "L2-B11", "L2-B21", "L2-B14", "L2-B24", "L2-E03", "L2-E06", "L2-C01", "L2-C11", "L2-C02", "L2-C12", "L2-C15", "L2-C18", "L2-C21", "L2-C24", "L2-D14", "L2-D16", "L2-D19", "L2-D43", "L2-D41", "L2-D39", "L2-D37", "L2-D34", "L2-D01", "L2-D20", "L2-D02", "L2-D21", "L2-D04", "L2-D24", "L2-D07", "L2-D27", "L2-D10", "L2-D30", "L2-D13", "L2-D33"};

    private String[] sMarks2 = {"L3-A01","L3-A04","L3-A07","L3-A10","L3-A12","L3-D14","L3-D11","L3-D08","L3-D05","L3-D03","L3-B01","L3-B02","L3-B03","L3-B05","L3-B10","L3-B07","L3-B08","L3-C02","L3-C23","L3-C04","L3-C26","L3-C07","L3-C29","L3-C10","L3-C32","L3-C11","L3-C20","L3-C14","L3-C16","L3-C22","L3-C39","L3-C37","L3-C35","L3-C33"};

    private List<String> mMarks1;
    private List<String> mMarks2;

    public MarkModel() {
        mMarks1 = Arrays.asList(sMarks1);
        mMarks2 = Arrays.asList(sMarks2);
    }

    public boolean exist(String loc) {
        return mMarks1.contains(loc) || mMarks2.contains(loc);
    }


}
