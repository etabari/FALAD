package falad;

import java.util.GregorianCalendar;

/**
 * <p>Title: FALAD</p>
 * <p>Description: Farsi Arabic Language Applucation Development</p>
 *
 * <code>HijriCalendar</code> is a concrete subclass of
 * {@link GeorgianCalendar}
 * and provides the standard Hijri calendar used in Iran.
 *
 * @see          GeorgianCalendar
 * @see          Calendar
 * @see          TimeZone
 * @version      1.0
 * @author Ehsan Tabari
 */
public class HijriCalnedar extends GregorianCalendar {

    /**
     * Field number for <code>get</code> and <code>set</code> indicating the
     * Hijri year. This is a 4 digit value;
     */
    public final static int HIJRI_YEAR = 1001;
    /**
     * Field number for <code>get</code> and <code>set</code> indicating the
     * Hijri month. This is One-based value;
     * @see     FARVARDIN, ORDIBEHESHT, KHORDAD, TIR, MORDAD, SHAHRIVAR, MEHR, ABAN, AZAR, DEY, BAHMAN, ESFAND
     */
    public final static int HIJRI_MONTH = 1002;
    /**
     * Field number for <code>get</code> and <code>set</code> indicating the
     * Hijri day of month. This is One-based value;
     */
    public final static int HIJRI_DATE = 1005;

    /**
     * Value of the <code>MONTH</code> field indicating the
     * first month of the hijri year.
     */
    public final static int FARVARDIN = 1;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * second month of the hijri year.
     */
    public final static int ORDIBEHESHT = 2;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * third month of the hijri year.
     */
    public final static int KHORDAD = 3;
    /**
     * Value of the <code>MONTH</code> field indicating the
     *  forth month of the hijri year.
     */
    public final static int TIR = 4;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * fifth month of the hijri year.
     */
    public final static int MORDAD = 5;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * sixth month of the hijri year.
     */
    public final static int SHAHRIVAR = 6;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * seventh month of the hijri year.
     */
    public final static int MEHR = 7;
    /**
     * Value of the <code>MONTH</code> field indicating the
     *  eighth month of the hijri year.
     */
    public final static int ABAN = 8;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * ninth month of the hijri year.
     */
    public final static int AZAR = 9;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * tenth month of the hijri year.
     */
    public final static int DEY = 10;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * eleventh month of the hijri year.
     */
    public final static int BAHMAN = 11;
    /**
     * Value of the <code>MONTH</code> field indicating the
     * twelfth month of the hijri year.
     */
    public final static int ESFAND = 12;


    private int hDay;
    private int hYear;
    private int hMonth;
    private int hValue;

    public HijriCalnedar() {
        super();
        calculateAllFromG();
    }

    public HijriCalnedar(int hYear, int hMonth, int hDate) {
        this.hYear = hYear;
        this.hMonth = hMonth;
        this.hDay = hDate;
        calculateAllFromH();
    }

    private void calculateAllFromG() {
        int gYear = this.get(YEAR);
        int gMonth = this.get(MONTH);
        int gDate = this.get(DATE);
        G2H_N(gYear, gMonth, gDate, 0);
    }

    private void calculateAllFromH() {
        java.util.GregorianCalendar gc = H2G_N(hYear, hMonth, hDay, 0);
        set(gc.get(YEAR), gc.get(MONTH), gc.get(DATE));
    }

    private int daysInMonthG(int year, int month) {
        switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 2:
            if (year % 4 == 0)return 29;
            else return 28;
        default:
            return 30;
        }
    }

    static public int daysInMonth(int hYear, int hMonth) {
        if (hMonth == 0) {
            hMonth = 12;
            hYear = hYear - 1;
        }

        if (hMonth >= 1 && hMonth <= 6)
            return 31;
        else if (hMonth == 12) {
            if ((((hYear % 4) == 2) && (hYear < 1374)) ||
                (((hYear % 4) == 3) && (hYear >= 1374)))
                return 30;
            else
                return 29;
        } else return 30;
    }


    private void CalculateValueFromParts() {
        int v = 0, AYear = hYear, AMonth = hMonth, ADay = hDay;
        if (AYear >= 1) {
            for (int i = 1; i < AYear; i++)
                for (int j = 1; j <= 12; j++)
                    v += daysInMonth(i, j);
            for (int i = 1; i < AMonth; i++)
                v += daysInMonth(AYear, i);
            hValue = v + ADay;
        } else
            hValue = 0;
    }

    private void CalculatePartsFromValue() {
        int i;
        i = hYear = hDay = 1;
        int ADate = hValue;
        while (ADate > daysInMonth(hYear, i)) {
            for (i = 1; i <= 12; i++) {
                if (ADate > daysInMonth(hYear, i))
                    ADate -= daysInMonth(hYear, i);
                else break;
            }
            if (i > 12) {
                hYear++;
                i = 1;
            }
        }
        hMonth = i;
        hDay = ADate;
    }

    private void G2H_N(int aYear4, int aMonth, int aDay, int N) {
        int yD, m;
        yD = aDay + N;
        m = aMonth;
        for (int i = 1; i < m; i++)
            yD = yD + daysInMonthG(aYear4, i);

        aYear4 -= 621;
        yD -= daysInMonth(aYear4 - 1, 12) + daysInMonth(aYear4 - 1, 11) + 20;

        if (daysInMonth(aYear4 - 1, 12) == 30)
            yD++;

        if (yD > 0) {
            aMonth = 1;
            while (yD > daysInMonth(aMonth, aMonth)) {
                yD -= daysInMonth(aYear4, aMonth);
                aMonth++;
            }
            aDay = yD;
        } else if (yD <= 0) {
            aYear4--;
            aMonth = 12;
            while ( -yD >= daysInMonth(aYear4, aMonth)) {
                yD += daysInMonth(aYear4, aMonth);
                aMonth--;
            }
            aDay = daysInMonth(aYear4, aMonth) + yD;
        }
        hDay = aDay;
        hMonth = aMonth;
        hYear = aYear4;
        CalculateValueFromParts();
    }

    private java.util.GregorianCalendar H2G_N(int aYear, int aMonth, int aDay,
                                              int n) {
        int yD, m;
        yD = aDay + n;
        m = aMonth;
        for (m = 1; m < aMonth; m++)
            yD += daysInMonth(aYear, m);

        if (aYear < 1000) aYear += 1300;
        aYear += 621;
        yD += daysInMonthG(aYear - 1, 12) + daysInMonthG(aYear - 1, 11) + 18;

        if (yD > 0) {
            aMonth = 1;
            while (yD > daysInMonthG(aYear, aMonth)) {
                yD -= daysInMonthG(aYear, aMonth);
                if (aMonth < 12) aMonth++;
                else {
                    aYear++;
                    aMonth = 1;
                }
            }
            aDay = yD;
        } else if (yD <= 0) {
            aYear--;
            aMonth = 12;
            while ( -yD >= daysInMonthG(aYear, aMonth)) {
                yD += daysInMonthG(aYear, aMonth);
                aMonth--;
            }
            aDay = daysInMonthG(aYear, aMonth) + yD;
        }
        return new java.util.GregorianCalendar(aYear, aMonth, aDay);
    }

    public int get(int field) {
        switch (field) {
        case HIJRI_DATE:
            return hDay;
        case HIJRI_MONTH:
            return hMonth;
        case HIJRI_YEAR:
            return hYear;
        default:
            return super.get(field);
        }
    }

    public void set(int field, int value) {
        switch (field) {
        case HIJRI_DATE:
            hDay = value;
            calculateAllFromH();
            break;
        case HIJRI_MONTH:
            hMonth = value;
            calculateAllFromH();
            break;
        case HIJRI_YEAR:
            hYear = value;
            calculateAllFromH();
            break;
        default:
            super.set(field, value);
        }
    }

    public String toString() {
        String old = super.toString();
        old.substring(0, old.length() - 2);
        return old + ",HIJRI_YEAR=" + hYear + ",HIJRI_MONTH=" + hMonth +
                ",HIJRI_DAY_OF_MONTH=" + hDay + "]";
    }

    public boolean equals(Object obj) {
    }

    public void add(int field, int amount) {

    }


    public void roll(int field, int amount) {

    }

    public int getMinimum(int field) {

    }

    public int getMaximum(int field) {

    }
    public int getGreatestMinimum(int field) {

    }

}
