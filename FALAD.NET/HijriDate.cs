using System;
/// <remark>
///  FALAD is a collection off tools. It stands for Farsi/Arabic Language Develoment. 
///  These Tools were first published in Object Pascal for Borland Delphi through 
///  http://www.delphi7.net. Now, It is being redistributed for Microsoft .NET Framework
///  in C# Language.
/// </remark>

namespace FALAD {


	/// <summary>
	///  <code>HijriDate</code> is Object Oriented reimplementation of FarsiDateTime 
	///  in FALAD for Delphi. 
	/// </summary>
	sealed public class HijriDate {
		public static readonly string[] FarsiMonthNames = new string [] {"فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور", "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"};

		public static readonly string[] FarsiDayNamesFull = new string [] {"شنبه", "یك شنبه", "دوشنبه", "سه شنبه", "چهار شنبه", "پنج شنبه", "جمعه" };
		public static readonly string[] FarsiDayNamesShort = new string [] {"ش", "ی", "د", "س", "چ", "پ", "ج" };

		private long m_Value;
		private long m_Month, m_Year, m_Day;

		/// <summary>
		/// Initializes a new instance of the HijriDate structure to the specified HijriDate parameter.
		/// </summary>
		/// <param name="date"> Hijri DateTime from which the HijriDate instance is created.</param>
		public  HijriDate(HijriDate date) {
			this.m_Value = date.m_Value;
			this.m_Day = date.m_Day;
			this.m_Month = date.m_Month;
			this.m_Year = date.m_Year;
		}

		public HijriDate(int Value) {
			m_Value = Value;
			CalculatePartsFromValue();
		}

		/// <summary>
		/// Initializes a new instance of the HijriDate structure to the specified Georgian DateTime.
		/// </summary>
		/// <param name="date"> Georgian DateTime from which the HijriDate instance is created.</param>
		public HijriDate(System.DateTime date) {
			long AYear = date.Year;
			long AMonth = date.Month;
			long ADay = date.Day;
			C2I_N(AYear, AMonth, ADay, 0);
		}

		/// <summary>
		/// Initializes a new instance of the HijriDate structure to today.
		/// </summary>
		public HijriDate() : this(System.DateTime.Now){
		}

		/// <summary>
		/// Initializes a new instance of the HijriDate structure to the specified Hijri year, month, and day.
		/// </summary>
		/// <param name="HijriDay"> The 4 digit Hijri year (1 through 9999). Use 1383 not 83</param>
		/// <param name="HijriMonth"> The month (1 through 12). </param>
		/// <param name="HijriYear"> The day (1 through the number of days in month). </param>
		public HijriDate(long HijriYear, long HijriMonth, long HijriDay) {
			m_Year = HijriYear;
			m_Month = HijriMonth;
			m_Day = HijriDay;
			CalculateValueFromParts();
		}
		
		public override int GetHashCode() {
			return (int)m_Value;
		}

		/// <summary>
		/// Gets and sets the Hijri day of the Hijri month represented by this instance.
		/// </summary>
		public long Day {
			get { return m_Day; }
			set { m_Day = value; CalculateValueFromParts();}
		}

		/// <summary>
		/// Gets and sets the Hijri month component of the date represented by this instance.
		/// </summary>
		public long Month {
			get { return m_Month; }
			set { m_Month = value; CalculateValueFromParts(); }
		}

		/// <summary>
		/// Gets and sets the Hijri year component of the date represented by this instance.
		/// </summary>
		public long Year {
			get { return m_Year; }
			set { m_Year = value; CalculateValueFromParts(); }
		}
		/// <summary>
		/// Gets the day of the week represented by this instance.
		/// </summary>
		public int DayOfWeek {
			get {
				System.DateTime date = GDate;
				if ((int)date.DayOfWeek==6) return 0;
				else return (int)date.DayOfWeek + 1;
			}
		}


		/// <summary>
		/// Gets and sets the Georgian date represented by this instance.
		/// </summary>
		public System.DateTime GDate {
			get {return I2C_N(m_Year, m_Month, m_Day, 0);}
			set {m_Value = (new HijriDate(value)).m_Value; CalculatePartsFromValue(); }
		}

		/// <summary>
		/// Gets the current date in Hijri Shamsi.
		/// </summary>
		static public HijriDate Today {
			get {return new HijriDate(System.DateTime.Today); }
		}


		
		private long Months_C(long Y, long M) {
			switch (M) {
				case 1: case 3:	
				case 5:	case 7: 
				case 8: case 10: 
				case 12: return 31;
				case 2: if (Y %4 == 0) return 29;
						else return 28;
				default: return 30;
			}
		}

		static public long DaysInMonth(long Year, long Month) {
			if (Month==0) {
				Month = 12;
				Year = Year-1;
			}

			if (Month>=1 && Month<=6) 
				return 31;
			else if (Month==12) {
				if (( ((Year%4)==2) && (Year<1374)) || (((Year % 4)==3) && (Year>=1374)))
					return 30;
				else 
					return 29;
			}
			else return 30;
		}

		private void CalculateValueFromParts() {
			long v = 0 , AYear = m_Year, AMonth = m_Month, ADay = m_Day;
			if (AYear>=1) {
				for( int i=1;  i<AYear; i++)
					for( int j=1 ; j<=12; j++) 
						v += DaysInMonth(i, j);
				for (int i=1; i<AMonth; i++)
					v += DaysInMonth(AYear, i);
				m_Value = v+ADay;
			} else
				m_Value = 0;
		}

		private void CalculatePartsFromValue() {
			long i;
			i = m_Year = m_Day = 1;
			long ADate = m_Value;
			while (ADate > DaysInMonth(m_Year, i)){
				for (i=1; i<=12; i++){
					if (ADate>DaysInMonth(m_Year, i)) 
						ADate -= DaysInMonth(m_Year, i);
					else break;
				}
				if (i>12) {
					m_Year++;
					i = 1;
				}
			}
			m_Month = i;
			m_Day = ADate;
		}

		private void C2I_N(long AYear4, long AMonth, long ADay, int N) {
			long Yd, M;
			Yd = ADay+N;
			M = AMonth;
			for (int i=1; i<M; i++)  
				Yd = Yd + Months_C(AYear4, i);

			AYear4 -= 621;
			Yd -= DaysInMonth(AYear4-1, 12) + DaysInMonth(AYear4-1, 11) +20 ;
		
			if (DaysInMonth(AYear4-1, 12)==30) 
				Yd++;

			if (Yd>0){
				AMonth = 1;
				while (Yd>DaysInMonth(AMonth, AMonth)) {
					Yd -= DaysInMonth(AYear4, AMonth);
					AMonth++;
				}
				ADay = Yd;
			} else if (Yd<=0) {
				AYear4--;
				AMonth = 12;
				while (-Yd>=DaysInMonth(AYear4, AMonth)) {
					Yd += DaysInMonth(AYear4, AMonth);
					AMonth--;
				}
				ADay = DaysInMonth(AYear4, AMonth)+Yd;
			}
			m_Day = ADay;
			m_Month = AMonth;
			m_Year = AYear4;
			CalculateValueFromParts();
		}

		private System.DateTime I2C_N(long AYear, long AMonth, long ADay, int N) { 
			long Yd, M;
			Yd = ADay+N;
			M = AMonth;
			for (M=1; M<AMonth; M++) 
				Yd += DaysInMonth(AYear, M);

			if (AYear<1000) AYear += 1300;
			AYear += 621;
			Yd +=  Months_C(AYear-1, 12)+Months_C(AYear-1, 11)+18;

			if (Yd>0) {
				AMonth = 1;
				while (Yd>Months_C(AYear, AMonth)){
					Yd -= Months_C(AYear, AMonth);
					if (AMonth<12) AMonth++;
					else {
						AYear++;
						AMonth = 1;
					}
				}
				ADay = Yd;
			} else if (Yd<=0) {
				AYear--;
				AMonth = 12;
				while (-Yd>=Months_C(AYear, AMonth)){
					Yd += Months_C(AYear, AMonth);
					AMonth--;
				}
				ADay = Months_C(AYear, AMonth)+Yd;
			}
			return new System.DateTime((int)AYear, (int)AMonth, (int)ADay);
		}

		/// <summary>
		/// Converts the value of this instance to its equivalent short Hijri date string representation.
		/// </summary>
		/// <returns>A string containing the numeric month, the numeric day of the month, and the year equivalent to the Hijri date value of this instance.</returns>
		public override string ToString() {
			if (m_Value==0)
				return "Not Valid";
			else
				return m_Year.ToString() + "/" + m_Month.ToString() + "/" + m_Day.ToString();
		}

	}
}
