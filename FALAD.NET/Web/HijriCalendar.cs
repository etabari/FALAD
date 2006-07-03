using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.ComponentModel.Design.Serialization;

namespace FALAD.Web {
	/// <summary>
	/// Summary description for WebCustomControl1.
	/// </summary>
	[DefaultProperty("Text"), ToolboxData("<{0}:HijriCalendar runat=server></{0}:HijriCalendar>")]
	public class HijriCalendar : System.Web.UI.WebControls.WebControl, System.Web.UI.IPostBackEventHandler  {
		
		// Misc Private Variables
//		private System.DateTime visibleDate; 
//		private System.DateTime selectedDate;

		// Appearance Private Variables
		private System.Web.UI.WebControls.DayNameFormat dayNameFormat = System.Web.UI.WebControls.DayNameFormat.Full;
		private string nextMonthText = "&gt;";
		private string registerText = "";
		private System.Web.UI.WebControls.NextPrevFormat nextPrevFormat = System.Web.UI.WebControls.NextPrevFormat.CustomText;
		private string prevMonthText = "&lt;";
		private bool showDayHeader = true;
		private bool showNextPrevMonth = true;
		private bool showTitle = true;
		private System.Web.UI.WebControls.TitleFormat titleFormat = System.Web.UI.WebControls.TitleFormat.MonthYear;
		
		// Layout Private Variables
		private int cellPadding = 2;
		private int cellSpacing = 0;

		// Style Private Variables
		private System.Web.UI.WebControls.TableItemStyle dayHeaderStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle dayStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle nextPrevStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle otherMonthDayStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle selectedDayStyle = new System.Web.UI.WebControls.TableItemStyle();
//		private System.Web.UI.WebControls.TableItemStyle selectorStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle titleStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle todayDayStyle = new System.Web.UI.WebControls.TableItemStyle();
		private System.Web.UI.WebControls.TableItemStyle weekendDayStyle = new System.Web.UI.WebControls.TableItemStyle();

		public HijriCalendar() {
			BorderWidth = 1;
			TitleStyle.BackColor = System.Drawing.Color.Silver;
		}

		// Public Properties 
		#region Properties


		[Description("Registration String")]
		public string RegisterString {
			get {
				if (ViewState["RegisterString"] == null) 
					ViewState["RegisterString"] = "";
				return (string) ViewState["RegisterString"];
			}
			set { ViewState["RegisterString"] = value; }
		}

		[Bindable(true), Description("The month to be displayed.")]
		public System.DateTime VisibleDate {
			get {
				if (ViewState["VisibleDate"] == null) 
					ViewState["VisibleDate"] = System.DateTime.Today;
				return (System.DateTime) ViewState["VisibleDate"];
			}
			set { ViewState["VisibleDate"] = value; }
		}

		[Bindable(true), Description("The currently selected date.")]
		public System.DateTime SelectedDate {
			get {
				if (ViewState["SelectedDate"] == null) 
					ViewState["SelectedDate"] = System.DateTime.Today;
				return (System.DateTime) ViewState["SelectedDate"];
			}
			set { ViewState["SelectedDate"] = value; }
		}

		[Bindable(true), Category("Appearance"), Description("Format for day header text."),
		DefaultValue(System.Web.UI.WebControls.DayNameFormat.Full)]
		public System.Web.UI.WebControls.DayNameFormat DayNameFormat {
			get {return dayNameFormat;}
			set {dayNameFormat = value;}
		}

		[Bindable(true), Category("Appearance"), Description("Text for the next month button."),
		DefaultValue("&gt;")]
		public string NextMonthText {
			get {return nextMonthText;}
			set {nextMonthText = value;}
		}

		[Bindable(true), Category("Appearance"), Description("Format for month navigation buttons."),
		DefaultValue(System.Web.UI.WebControls.NextPrevFormat.CustomText)]
		public System.Web.UI.WebControls.NextPrevFormat NextPrevFormat {
			get {return nextPrevFormat;}
			set {nextPrevFormat = value;}
		}

		[Bindable(true), Category("Appearance"), Description("Text for the previous month button."),
		DefaultValue("&lt;")]
		public string PrevMonthText {
			get {return prevMonthText;}
			set {prevMonthText = value;}
		}

		[Bindable(true), Category("Appearance"), Description("True if showing days of week header."),
		DefaultValue(true)]
		public bool ShowDayHeader {
			get {return showDayHeader;}
			set {showDayHeader= value; }
		}


		[Bindable(true), Category("Appearance"), DefaultValue(true)]
		public bool ShowNextPrevMonth {
			get {return showNextPrevMonth;}
			set {showNextPrevMonth= value; }
		}

		[Bindable(true), Category("Appearance"), DefaultValue(true)]
		public bool ShowTitle {
			get {return showTitle;}
			set {showTitle = value;}
		}

		[Bindable(true), Category("Appearance"), DefaultValue(System.Web.UI.WebControls.TitleFormat.MonthYear)]
		public System.Web.UI.WebControls.TitleFormat TitleFormat {
			get {return titleFormat;}
			set {titleFormat = value;}
		}



		[Bindable(true), Category("Layout"), DefaultValue(2)]
		public int CellPadding {
			get {return cellPadding;}
			set {cellPadding = value;}
		}

		[Bindable(true), Category("Layout"), DefaultValue(0)]
		public int CellSpacing {
			get {return cellSpacing;}
			set {cellSpacing = value;}
		}




		[Category("Style"),	
		DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
		NotifyParentProperty(true),	
		PersistenceMode(PersistenceMode.InnerProperty)]
		public virtual System.Web.UI.WebControls.TableItemStyle DayHeaderStyle {
			get {return dayHeaderStyle;	}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle DayStyle {
			get {return dayStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle NextPrevStyle {
			get {return nextPrevStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle OtherMonthDayStyle {
			get {return otherMonthDayStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle SelectedDayStyle {
			get {return selectedDayStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle TitleStyle {
			get {return titleStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle TodayDayStyle {
			get {return todayDayStyle;}
		}

		[Category("Style"),
		NotifyParentProperty(true),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Visible),
		PersistenceMode(PersistenceMode.InnerProperty)]
		public System.Web.UI.WebControls.TableItemStyle WeekendDayStyle {
			get {return weekendDayStyle;}
		}
		#endregion

		// Event Handling Objects 
		
		private static readonly object ClickEvent = new object();

		[Category("Action"), Description("Fires when selection is changed by user.")]
		public event EventHandler SelectionChanged {
			add { Events.AddHandler(ClickEvent, value); }
			remove { Events.RemoveHandler(ClickEvent, value); }
		}

		protected virtual void OnClick(EventArgs e) {
			EventHandler clickEventDelegate = (EventHandler)Events[ClickEvent];
			if (clickEventDelegate != null) {
				clickEventDelegate(this, e);
			}  
		}

		public void RaisePostBackEvent(string eventArgument) {    
			if (eventArgument=="Prev") {
				HijriDate d = new HijriDate(VisibleDate);
				if (d.Month>1)
					d.Month -= 1;
				else {
					d.Month = 12;
					d.Year -= 1;
				}
				VisibleDate = d.GDate;
			} 
			else if(eventArgument=="Next") {
				HijriDate d = new HijriDate(VisibleDate);
				if (d.Month<12) 
					d.Month += 1;
				else {
					d.Month = 1;
					d.Year +=1;
				}
				VisibleDate = d.GDate;
			} 
			else {
				SelectedDate = (new HijriDate(Int32.Parse(eventArgument))).GDate;
			}
			OnClick(EventArgs.Empty);
		}

		

		#region Render Method
		/// <summary>
		/// Render this control to the output parameter specified.
		/// </summary>
		/// <param name="output"> The HTML writer to write out to </param>
		protected override void Render(HtmlTextWriter output) {
			HijriDate date;
			if (VisibleDate.ToShortDateString().Length > 0)
				date = new HijriDate(VisibleDate);
			else date = new HijriDate();
			
			// TABLE START
			output.AddAttribute(HtmlTextWriterAttribute.Name,this.UniqueID);
			output.AddAttribute("dir","rtl");
			output.AddAttribute(HtmlTextWriterAttribute.Cellpadding, cellPadding.ToString(), true);
			output.AddAttribute(HtmlTextWriterAttribute.Cellspacing, cellSpacing.ToString(), true);
			AddAttributesToRender(output);
			output.RenderBeginTag(HtmlTextWriterTag.Table);
			output.WriteLine();
			
			
			if (showTitle) {// First Row (Title)
				output.RenderBeginTag(HtmlTextWriterTag.Tr);
				output.AddAttribute(HtmlTextWriterAttribute.Colspan, "7", false);
				titleStyle.AddAttributesToRender(output);
				output.RenderBeginTag(HtmlTextWriterTag.Td); 
				output.WriteLine();
				if (true){ // Title Table 
					output.AddAttribute(HtmlTextWriterAttribute.Width,"100%", false);
					output.RenderBeginTag(HtmlTextWriterTag.Table);
					output.WriteLine();
					output.RenderBeginTag(HtmlTextWriterTag.Tr);

					if (showNextPrevMonth) { // Previous 
						nextPrevStyle.AddAttributesToRender(output);
						output.AddAttribute(HtmlTextWriterAttribute.Align,"right",false); 
						output.AddAttribute(HtmlTextWriterAttribute.Width,"15%",false); 
						output.RenderBeginTag(HtmlTextWriterTag.Td);

						output.AddAttribute(HtmlTextWriterAttribute.Href, "javascript:" + Page.GetPostBackEventReference(this, "Prev"), true);
						nextPrevStyle.AddAttributesToRender(output);
						output.RenderBeginTag(HtmlTextWriterTag.A);
						switch(nextPrevFormat) {
							case NextPrevFormat.CustomText:	output.Write(prevMonthText); break;
							default: output.Write(HijriDate.FarsiMonthNames[date.Month>1?date.Month-2:11]); break;
						}
						output.RenderEndTag(); // A

						output.RenderEndTag();
						output.WriteLine();
					} // Previous 

					output.AddAttribute(HtmlTextWriterAttribute.Width,"70%",false); 
					output.AddAttribute(HtmlTextWriterAttribute.Align,"middle",false); 
					output.RenderBeginTag(HtmlTextWriterTag.Td);
					output.Write(HijriDate.FarsiMonthNames[date.Month-1]);
					if (titleFormat == System.Web.UI.WebControls.TitleFormat.MonthYear)
						output.Write(" " + date.Year.ToString());
					if (ViewState["test"]!= null)
						output.Write(ViewState["test"]);
					output.RenderEndTag();
					output.WriteLine();

					if (showNextPrevMonth) { // Next
						nextPrevStyle.AddAttributesToRender(output);
						output.AddAttribute(HtmlTextWriterAttribute.Align,"left",false); 
						output.AddAttribute(HtmlTextWriterAttribute.Width,"15%",false); 
						output.RenderBeginTag(HtmlTextWriterTag.Td);

						nextPrevStyle.AddAttributesToRender(output);
						output.AddAttribute(HtmlTextWriterAttribute.Href, "javascript:" + Page.GetPostBackEventReference(this, "Next"), true);
						output.RenderBeginTag(HtmlTextWriterTag.A);
						switch(nextPrevFormat) {
							case NextPrevFormat.CustomText:	output.Write(nextMonthText); break;
							default: output.Write(HijriDate.FarsiMonthNames[date.Month<12?date.Month:0]);break;
						}
						output.RenderEndTag(); // A

						output.RenderEndTag();
						output.WriteLine();
					} // Next

					output.RenderEndTag(); // Tr
					output.RenderEndTag(); // Table
					output.WriteLine();

				}	
				output.RenderEndTag(); // td
				output.RenderEndTag(); // tr
				output.WriteLine();
			} 

			if(showDayHeader) {// Day Header Row 
				output.RenderBeginTag(HtmlTextWriterTag.Tr);
				for(int i=0; i<7; i++) {
					dayHeaderStyle.AddAttributesToRender(output);

					output.AddAttribute(HtmlTextWriterAttribute.Align, "middle", false);
					output.AddAttribute(HtmlTextWriterAttribute.Nowrap, "true", false);
					
					output.RenderBeginTag(HtmlTextWriterTag.Td);
					if (dayNameFormat == DayNameFormat.Full)
						output.Write(HijriDate.FarsiDayNamesFull[i]);
					else 
						output.Write(HijriDate.FarsiDayNamesShort[i]);
					output.RenderEndTag(); // td
				}
				output.RenderEndTag(); // tr
				output.WriteLine();
			 }// Day Names Row

			if (true) {// Day Counter
				HijriDate  firstDayOfMonth = new HijriDate(date);
				firstDayOfMonth.Day = 1;
				int DayCounter = - firstDayOfMonth.DayOfWeek;
				int MaxDayCounter = (int) HijriDate.DaysInMonth(firstDayOfMonth.Year, firstDayOfMonth.Month);
				
				while(DayCounter<MaxDayCounter) {
					output.RenderBeginTag(HtmlTextWriterTag.Tr);
					for(int d=0; d<7; d++) {
						DayCounter++;

						if (SelectedDate.ToShortDateString() == 
							(new HijriDate(firstDayOfMonth.Year, firstDayOfMonth.Month,DayCounter).GDate.ToShortDateString()))
							selectedDayStyle.AddAttributesToRender(output);
						else if (System.DateTime.Today.ToShortDateString() == 
							(new HijriDate(firstDayOfMonth.Year, firstDayOfMonth.Month,DayCounter).GDate.ToShortDateString()))
							todayDayStyle.AddAttributesToRender(output);
						else 
							dayStyle.AddAttributesToRender(output);

						output.AddAttribute(HtmlTextWriterAttribute.Align, "middle", false);
						output.RenderBeginTag(HtmlTextWriterTag.Td);

						if (DayCounter>0 && DayCounter<=MaxDayCounter) {
							if (dayStyle.ForeColor.IsEmpty)
								output.AddStyleAttribute(HtmlTextWriterStyle.Color, ForeColor.Name);
							else
								output.AddStyleAttribute(HtmlTextWriterStyle.Color, dayStyle.ForeColor.Name);

							output.AddAttribute(HtmlTextWriterAttribute.Href, "javascript:" + Page.GetPostBackEventReference(this, (firstDayOfMonth.GetHashCode()+DayCounter-1).ToString()), true);
							output.RenderBeginTag(HtmlTextWriterTag.A);
							output.Write(DayCounter.ToString());
							output.RenderEndTag();
						}else
							output.Write("&nbsp;");
						output.RenderEndTag();
					}
					output.RenderEndTag();
				}
			}// Day Counter
			if (RegisterString!="D19D18D8") {
				output.RenderBeginTag(HtmlTextWriterTag.Tr);
				output.AddAttribute(HtmlTextWriterAttribute.Colspan, "7", false);
				output.AddAttribute(HtmlTextWriterAttribute.Align, "left", false);
				output.RenderBeginTag(HtmlTextWriterTag.Td); 
				output.AddAttribute(HtmlTextWriterAttribute.Size, "-2", false);
				output.RenderBeginTag(HtmlTextWriterTag.Font); 
				output.RenderBeginTag(HtmlTextWriterTag.I); 
				output.Write("Unregistered version, (C) copyright 2005 "); 
				output.AddAttribute(HtmlTextWriterAttribute.Href, "mailto:ehsan@tabari-home.de", true);
				output.RenderBeginTag(HtmlTextWriterTag.A);
				output.Write("Ehsan Tabari");
				output.RenderEndTag(); // A
				output.RenderEndTag(); // I
				output.RenderEndTag(); // Font
				output.RenderEndTag(); // Td
				output.RenderEndTag(); // Tr
			}
			output.RenderEndTag(); // Table
		}
		#endregion
	
		protected override void LoadViewState(object savedState) {
			if (savedState != null) {
				object[] myState = (object[])savedState;

				if (myState[0] != null)
					base.LoadViewState(myState[0]);
//				if (myState[2] != null)
//					((IStateManager)SelectedItemStyle).LoadViewState(myState[2]);
			}
		}

		protected override object SaveViewState() {
			// Customized state management to handle saving state of contained objects such as styles.

			object baseState = base.SaveViewState();
//			object dayHeaderStyleState = (dayHeaderStyle != null) ? ((IStateManager)dayHeaderStyle).SaveViewState() : null;

			object[] myState = new object[2];
			myState[0] = baseState;
//			myState[1] = itemStyleState;

			return myState;
		}

		protected override void TrackViewState() {
			base.TrackViewState();

//			if (dayHeaderStyle != null)
//				((IStateManager)dayHeaderStyle).TrackViewState();
//			if (selectedItemStyle != null)
//				((IStateManager)selectedItemStyle).TrackViewState();
//			if (alternatingItemStyle != null)
//				((IStateManager)alternatingItemStyle).TrackViewState();
		}

	}
}
