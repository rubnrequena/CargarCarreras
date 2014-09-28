package utils
{
	import mx.resources.ResourceManager;

	public class DateUtil
	{
		static public function toggleDate (date:String):String {
			if (date.indexOf("/")>-1)
				return date.split("/").reverse().join("-");
			else
				return date.split("-").reverse().join("/");
		}
		
		/**
		 *  Parses a String object that contains a date, and returns a Date
		 *  object corresponding to the String.
		 *  The <code>inputFormat</code> argument contains the pattern
		 *  in which the <code>valueString</code> String is formatted.
		 *  It can contain <code>"M"</code>, <code>"MM"</code>, 
		 *  <code>"MMM"</code> (3 letter month names), <code>"MMMM"</code> (month names),
		 *  <code>"D"</code>,  <code>"DD"</code>, <code>"YY"</code>, <code>"YYYY"</code>
		 *  and delimiter and punctuation characters.
		 * 
		 *  <p>Only upper case characters are supported.</p>
		 *
		 *  <p>The function does not check for the validity of the Date object.
		 *  If the value of the date, month, or year is NaN, this method returns null.</p>
		 * 
		 *  <p>For example:
		 *  <pre>var dob:Date = DateField.stringToDate("06/30/2005", "MM/DD/YYYY");</pre>        
		 *  </p>
		 *
		 *  @param valueString Date value to format.
		 *
		 *  @param inputFormat String defining the date format.
		 *
		 *  @return The formatted date as a Date object.
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function stringToDate(valueString:String, inputFormat:String):Date
		{
			var maskChar:String
			var dateChar:String;
			var dateString:String;
			var monthString:String;
			var yearString:String;
			var hourString:String;
			var minuteString:String;
			var secondString:String;
			var horarioString:String;
			
			var dateParts:Array = [];
			var maskParts:Array = [];
			var part:int = 0;
			var length:int;
			var position:int = 0;
			
			if (valueString == null || inputFormat == null)
				return null;
			
			var monthNames:Array = ResourceManager.getInstance()
				.getStringArray("SharedResources", "monthNames");
			
			var noMonths:int = monthNames.length;
			for (var i:int = 0; i < noMonths; i++) {
				valueString = valueString.replace(monthNames[i], (i+1).toString());
				valueString = valueString.replace(monthNames[i].substr(0,3), (i+1).toString());
			}
			
			length = valueString.length;
			
			dateParts[part] = "";
			for (i = 0; i < length; i++)
			{
				dateChar = valueString.charAt(i);
				
				if (isNaN(Number(dateChar)) || dateChar == " ")
				{
					part++;
					dateParts[part] = dateChar;
					part++;
					dateParts[part] = "";
				}
				else
				{
					dateParts[part] += dateChar;	
				}
			}
			
			length = inputFormat.length;
			part = -1;
			var lastChar:String;
			for (i = 0; i < length; i++)
			{
				maskChar = inputFormat.charAt(i);
				
				if (maskChar == "Y" || maskChar == "M" || maskChar == "D" || maskChar == "H" || maskChar == "h" || maskChar == "n" || maskChar == "s" || maskChar == "a")
				{
					if (maskChar != lastChar)
					{
						part++;
						maskParts[part] = "";
					}
					maskParts[part] += maskChar;
				}
				else
				{
					part++;
					maskParts[part] = maskChar;
				}
				
				lastChar = maskChar;
			}
			length = maskParts.length;
			
			if (dateParts.length != length)
			{
				if (valueString.length != inputFormat.length) {
					return null;
				}
				
				for (i = 0; i < length; i++) {
					dateParts[i] = valueString.substr(position, maskParts[i].length);
					position += maskParts[i].length;
				}
				
			}
			if (dateParts.length != length)
			{
				return null;
			}
			
			for (i = 0; i < length; i++) {
				maskChar = maskParts[i].charAt(0);
				if (maskChar == "D") {
					dateString = dateParts[i];
				}
				else if (maskChar == "M") {
					monthString = dateParts[i];
				}
				else if (maskChar == "Y") {
					yearString = dateParts[i];
				}
				else if (maskChar == "h") {
					hourString = dateParts[i];
				}
				else if (maskChar == "n") {
					minuteString = dateParts[i];
				}					
				else if (maskChar == "s") {
					secondString = dateParts[i];
				}
				else if (maskChar == "aa") {
					horarioString = dateParts[i];
				}
			}
			if (dateString == null || monthString == null || yearString == null)
				return null;
			
			var dayNum:Number = Number(dateString);
			var monthNum:Number = Number(monthString);
			var yearNum:Number = Number(yearString);
			var hourNum:Number = Number(hourString);
			var minuteNum:Number = Number(minuteString);
			var secondNum:Number = Number(secondString);
			
			if (isNaN(yearNum) || isNaN(monthNum) || isNaN(dayNum))
				return null;
			
			if (yearString.length == 2)
				yearNum += 2000;
			
			var newDate:Date = new Date(yearNum, monthNum - 1, dayNum,hourNum,minuteNum,secondNum);
			
			if (dayNum != newDate.getDate() || (monthNum - 1) != newDate.getMonth())
				return null;
			
			return newDate;
		}
		
		/**
		 *  Formats a Date into a String according to the <code>outputFormat</code> argument.
		 *  The <code>outputFormat</code> argument contains a pattern in which
		 *  the <code>value</code> String is formatted.
		 *  It can contain <code>"M"</code>, <code>"MM"</code>,
		 *  <code>"MMM"</code> (3 letter month names), <code>"MMMM"</code> (month names),
		 *  <code>"D"</code>, <code>"DD"</code>, <code>"YY"</code>, <code>"YYYY"</code>
		 *  and delimiter and punctuation characters.
		 * 
		 *  <p>Only upper case characters are supported.</p>
		 *
		 *  @param value Date value to format.
		 *
		 *  @param outputFormat String defining the date format.
		 *
		 *  @return The formatted date as a String.
		 *
		 *  @example <pre>var todaysDate:String = DateField.dateToString(new Date(), "MM/DD/YYYY");</pre>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function dateToString(value:Date, outputFormat:String):String
		{
			var maskChar:String;
			var maskParts:Array = [];
			var part:int = -1;
			var length:int;
			var lastChar:String;
			
			if (!value || isNaN(value.getTime()) || !outputFormat)
				return "";
			
			length = outputFormat.length;
			
			for (var i:int = 0; i < length; i++)
			{
				maskChar = outputFormat.charAt(i);
				
				if (maskChar == "Y" || maskChar == "M" || maskChar == "D" || maskChar == "H" || maskChar == "h" || maskChar == "n" || maskChar == "s" || maskChar == "a")
				{
					if (maskChar != lastChar)
					{
						part++;
						maskParts[part] = "";
					}
					maskParts[part] += maskChar;
				}
				else
				{
					part++;
					maskParts[part] = maskChar;
				}
				
				lastChar = maskChar;
			}
			
			var date:String = String(value.getDate());
			var month:String = String(value.getMonth() + 1);
			var year:String = String(value.getFullYear());
			var hour24:String = String(value.hours);
			var hour12:String = String(value.hours>12?value.hours-12:value.hours);
			var minute:String = String(value.minutes);
			var second:String = String(value.seconds);
			var horario:String = value.hours>12?"pm":"am";
			
			var mask:String;
			var fullMask:String;
			var maskLength:int
			var output:String = "";
			
			//TODO Support changing locale at runtime
			var monthNames:Array =
				ResourceManager.getInstance().getStringArray(
					"SharedResources", "monthNames");
			
			length = maskParts.length;
			for (i = 0; i < length; i++)
			{
				fullMask = maskParts[i];
				mask = fullMask.charAt(0);
				maskLength = maskParts[i].length;
				
				if (mask == "D")
				{
					if (maskLength > 1 && date.length == 1)
						date = "0" + date;
					
					output += date;
				}
				else if (fullMask == "MMM")
				{
					output += monthNames[value.getMonth()].substr(0,3);
				}
				else if (fullMask == "MMMM")
				{	
					output += monthNames[value.getMonth()];
				}
				else if (mask == "M")
				{
					if (maskLength > 1 && month.length == 1)
						month = "0" + month;
					
					output += month;
				}
				else if (mask == "Y")
				{
					if (maskLength == 2)
						output += year.substr(2,2);
					else
						output += year;
				}
				else if (mask == "H")
				{
					if (maskLength > 1 && hour24.length == 1)
						hour24 = "0" + hour24;
					
					output += hour24;
				}
				else if (mask == "h")
				{
					if (maskLength > 1 && hour12.length == 1)
						hour12 = "0" + hour12;
					
					output += hour12;
				}
				else if (mask == "n")
				{
					if (maskLength > 1 && minute.length == 1)
						minute = "0" + minute;
					
					output += minute;
				}
				else if (mask == "s")
				{
					if (maskLength > 1 && second.length == 1)
						second = "0" + second;
					
					output += second;
				}
				else if (mask == "a")
				{
					output += horario;
				}
				else
				{
					output += mask;
				}
			}
			
			return output;
		}
	}
}