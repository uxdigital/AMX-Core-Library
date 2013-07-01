PROGRAM_NAME='Core Library v1-02'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2013  AT: 10:48:10        *)
(*******************************************************************************)
(*                                                                             *)
(*     _____            _              _  ____             _                   *)
(*    |     | ___  ___ | |_  ___  ___ | ||    \  ___  ___ |_| ___  ___  ___    *)
(*    |   --|| . ||   ||  _||  _|| . || ||  |  || -_||_ -|| || . ||   ||_ -|   *)
(*    |_____||___||_|_||_|  |_|  |___||_||____/ |___||___||_||_  ||_|_||___|   *)
(*                                                           |___|             *)
(*                                                                             *)
(*             _______  _____   ______ _______                                 *)
(*             |       |     | |_____/ |______                                 *)
(*             |_____  |_____| |    \_ |______                                 *)
(*                                                                             *)
(*                    _____ ______   ______ _______  ______ __   __            *)
(*             |        |   |_____] |_____/ |_____| |_____/   \_/              *)
(*             |_____ __|__ |_____] |    \_ |     | |    \_    |               *)
(*                                                                             *)
(*                                                                             *)
(*                   © Control Designs Software Ltd (2012)                     *)
(*                         www.controldesigns.co.uk                            *)
(*                                                                             *)
(*      Tel: +44 (0)1753 208 490     Email: support@controldesigns.co.uk       *)
(*                                                                             *)
(*******************************************************************************)
(*                                                                             *)
(*                           Core Library v1-01                                *)
(*                                                                             *)
(*            Written by Mike Jobson (Control Designs Software Ltd)            *)
(*                                                                             *)
(** REVISION HISTORY ***********************************************************)
(*                                                                             *)
(*  v1-02 (beta)                                                               *)
(*  Added SNAPI processing functions                                           *)
(*       --------------------------------------------------------------        *)
(*  v1-01 (beta 2)                                                             *)
(*  First release developed in beta only at this point in time                 *)
(*  No known issues - Notes to follow in coming update                         *)
(*                                                                             *)
(*******************************************************************************)
(*                                                                             *)
(*  Permission is hereby granted, free of charge, to any person obtaining a    *)
(*  copy of this software and associated documentation files (the "Software"), *)
(*  to deal in the Software without restriction, including without limitation  *)
(*  the rights to use, copy, modify, merge, publish, distribute, sublicense,   *)
(*  and/or sell copies of the Software, and to permit persons to whom the      *)
(*  Software is furnished to do so, subject to the following conditions:       *)
(*                                                                             *)
(*  The above copyright notice and this permission notice and header shall     *)
(*  be included in all copies or substantial portions of the Software.         *)
(*                                                                             *)
(*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS    *)
(*  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                 *)
(*  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.     *)
(*  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY       *)
(*  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT  *)
(*  OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR   *)
(*  THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                 *)
(*                                                                             *)
(*******************************************************************************)

#INCLUDE 'SNAPI'

//SNAPI FUNCTIONS

DEFINE_CONSTANT

INTEGER DUET_MAX_PARAM_ARRAY_SIZE				= 10

DEFINE_TYPE

STRUCT _SNAPI_DATA {
    CHAR cmd[DUET_MAX_CMD_LEN]
    CHAR param[DUET_MAX_PARAM_ARRAY_SIZE][DUET_MAX_PARAM_LEN]
    INTEGER numberOfParams
}

DEFINE_FUNCTION SNAPI_InitData(_SNAPI_DATA snapiData) {
    STACK_VAR INTEGER n
    
    snapiData.cmd = ''
    for(n = 1; n <= MAX_LENGTH_ARRAY(snapiData.param); n ++) {
	snapiData.param[n] = ''
    }
    //SET_LENGTH_ARRAY(snapiData.param, 0)
    snapiData.numberOfParams = 0
}

DEFINE_FUNCTION SNAPI_InitDataFromString(_SNAPI_DATA snapiData, CHAR snapiString[]) {
    STACK_VAR INTEGER n
    STACK_VAR CHAR param[DUET_MAX_PARAM_LEN]
    
    SNAPI_InitData(snapiData)
    snapiData.cmd = DuetParseCmdHeader(snapiString)
    DuetParseParamsToArray(snapiString, snapiData.param)
    snapiData.numberOfParams = LENGTH_ARRAY(snapiData.param)
}

DEFINE_FUNCTION SNAPI_SendDataToDevice(DEV device, CHAR cmd[], CHAR params[][]) {
    STACK_VAR CHAR commandToSend[255]
    commandToSend = DuetPackCmdHeader(cmd)
    commandToSend = DuetPackCmdParamArray(commandToSend, params)
    SEND_COMMAND device, commandToSend
}

DEFINE_FUNCTION INTEGER DuetParseParamsToArray(CHAR paramString[], CHAR paramArray[][]) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result
    
    result = 0
    for(n = 1; n <= MAX_LENGTH_ARRAY(paramArray); n ++) {
	if(LENGTH_STRING(paramString)) {
	    paramArray[n] = DuetParseCmdParam(paramString)
	    result = result + 1
	} else {
	    break
	}
    }
    SET_LENGTH_ARRAY(paramArray, result)
    return result
}

DEFINE_CONSTANT

INTEGER ROOM_NAME_MAX_LENGTH					= 50

INTEGER DEBUG_ARRAY_MAX_SIZE					= 10
INTEGER DEBUG_ARRAY_DATA_LOG_MAX_SIZE				= 50

INTEGER MAX_STRING_LENGTH_FROM_DEVICE				= 1000

INTEGER TIME_STAMP_LENGTH					= 16
// YYYY-MM-DD HH:MM

INTEGER TIME_STAMP_WITH_SECONDS_LENGTH				= 19
// YYYY-MM-DD HH:MM:SS

DEFINE_TYPE

STRUCT _TIME {
    SINTEGER year
    SINTEGER month
    SINTEGER day
    SINTEGER hours
    SINTEGER minutes
    SINTEGER seconds
}

STRUCT _DEBUG_ENTRY {
    INTEGER id
    CHAR dataString[255]
    _TIME entryTime
    CHAR header[50]
    INTEGER headerLength
    CHAR headerPadded[50]
}

STRUCT _DEBUGDATA {
    INTEGER id
    CHAR key[50]
    _TIME createTime
    _DEBUG_ENTRY logEntry[DEBUG_ARRAY_DATA_LOG_MAX_SIZE]
    INTEGER maxHeaderLength
}



DEFINE_VARIABLE

VOLATILE _DEBUGDATA debugDataArray[DEBUG_ARRAY_MAX_SIZE]

DEFINE_FUNCTION TimeTypeInit(_TIME t) {
    t.day = 1
    t.month = 1
    t.year = 2000
    t.hours = 0
    t.minutes = 0
    t.seconds = 0
}

DEFINE_FUNCTION TimeCreate(_TIME t) {
    STACK_VAR CHAR timeAsString[8]
    STACK_VAR CHAR dateAsString[10]

    timeAsString = TIME
    dateAsString = LDATE
    t.year = DATE_TO_YEAR(dateAsString)
    t.month = DATE_TO_MONTH(dateAsString)
    t.day = DATE_TO_DAY(dateAsString)
    t.hours = TIME_TO_HOUR(timeAsString)
    t.minutes = TIME_TO_MINUTE(timeAsString)
    t.seconds = TIME_TO_SECOND(timeAsString)
}
/*
DEFINE_FUNCTION TimeFromSeconds(_TIME t, LONG seconds) {
    STACK_VAR SINTEGER temp
    
    t.seconds = TYPE_CAST(seconds MOD 3600)
    t.hours = TYPE_CAST((seconds - t.seconds) / 3600)
    temp = t.seconds
    t.seconds = temp MOD 60
    t.minutes = (temp - t.seconds) / 60
}
*/


(*******************************************************************************)
(*  TimeAsTimeStamp                                                            *)
(*  Arguments: _TIME struct t                                                  *)
(*             Time struct to convert to time stamp string                     *)
(*  Returns:   CHAR[TIME_STAMP_WITH_SECONDS_LENGTH]                            *)
(*             Returns string in format YYYY-MM-DD HH:MM                       *)
(*             for example: "2013-12-20 13:55"                                 *)
(*******************************************************************************)
DEFINE_FUNCTION CHAR[TIME_STAMP_LENGTH] TimeAsTimeStamp(_TIME t) {
    STACK_VAR CHAR timeStamp[TIME_STAMP_LENGTH]

    timeStamp = "FORMAT('%04d', t.year)"
    timeStamp = "timeStamp, FORMAT('-%02d', t.month)"
    timeStamp = "timeStamp, FORMAT('-%02d', t.day)"
    timeStamp = "timeStamp, FORMAT(' %02d', t.hours)"
    timeStamp = "timeStamp, FORMAT(':%02d', t.minutes)"
    return timeStamp
}


(*******************************************************************************)
(*  TimeCreateFromStamp                                                        *)
(*  Arguments: CHAR timeStamp[]                                                *)
(*             Timestamp to convert to time struct                             *)
(*             _TIME struct t                                                  *)
(*             Time struct which will receive the result (passsed by ref)      *)
(*******************************************************************************)
DEFINE_FUNCTION TimeCreateFromStamp(CHAR timeStamp[], _TIME t) {
    if(LENGTH_STRING(timeStamp) >= 10) {
	t.year = AtoI(MID_STRING(timeStamp, 1, 4))
	t.month = AtoI(MID_STRING(timeStamp, 6, 2))
	t.day = AtoI(MID_STRING(timeStamp, 9, 2))
    }
    if(LENGTH_STRING(timeStamp) >= 16) {
	t.hours = AtoI(MID_STRING(timeStamp, 12, 2))
	t.minutes = AtoI(MID_STRING(timeStamp, 15, 2))
    }
    if(LENGTH_STRING(timeStamp) >= 19) {
	t.seconds = AtoI(MID_STRING(timeStamp, 18, 2))
    }
}

(*******************************************************************************)
(*  TimeAsTimeStampWithSeconds                                                 *)
(*  Arguments: _TIME struct t                                                  *)
(*             Time struct to convert to time stamp string with seconds        *)
(*  Returns:   CHAR[TIME_STAMP_WITH_SECONDS_LENGTH]                            *)
(*             Returns string in format YYYY-MM-DD HH:MM:SS                    *)
(*             for example: "2013-12-20 13:55:55"                              *)
(*******************************************************************************)
DEFINE_FUNCTION CHAR[TIME_STAMP_WITH_SECONDS_LENGTH] TimeAsTimeStampWithSeconds(_TIME t) {
    STACK_VAR CHAR timeStamp[TIME_STAMP_WITH_SECONDS_LENGTH]

    timeStamp = "FORMAT('%04d', t.year)"
    timeStamp = "timeStamp, FORMAT('-%02d', t.month)"
    timeStamp = "timeStamp, FORMAT('-%02d', t.day)"
    timeStamp = "timeStamp, FORMAT(' %02d', t.hours)"
    timeStamp = "timeStamp, FORMAT(':%02d', t.minutes)"
    timeStamp = "timeStamp, FORMAT(':%02d', t.seconds)"
    return timeStamp
}

(*******************************************************************************)
(*  TimeStampsSort                                                             *)
(*  Arguments: CHAR ts[][]                                                     *)
(*             Array of timestamp strings to sort chronologically              *)
(*******************************************************************************)
DEFINE_FUNCTION TimeStampsSort(CHAR ts[][]) {
    STACK_VAR INTEGER x
    STACK_VAR INTEGER y
    STACK_VAR INTEGER z
    STACK_VAR CHAR tsTemp[TIME_STAMP_WITH_SECONDS_LENGTH]
    
    z = MAX_LENGTH_ARRAY(ts) - 1
    for(x = 1; x <= MAX_LENGTH_ARRAY(ts); x ++) {
	for(y = 1; y <= z; y ++) {
	    if(ts[y] > ts[y + 1]) {
		tsTemp = ts[y + 1]
		ts[y + 1] = ts[y]
		ts[y] = tsTemp
	    }
	}
	z --
    }
}


(*******************************************************************************)
(*  TimeCurrentIsBetweenTime                                                   *)
(*  Arguments: _TIME struct t1                                                 *)
(*             1st time element to compare                                     *)
(*             _TIME struct t2                                                 *)
(*             2nd time element to compate                                     *)
(*  Returns:   INTEGER                                                         *)
(*             Returns TRUE if current time is between the two given times     *)
(*******************************************************************************)
DEFINE_FUNCTION INTEGER TimeCurrentIsBetweenTimes(_TIME t1, _TIME t2) {
    STACK_VAR _TIME t
    STACK_VAR CHAR ts[3][TIME_STAMP_LENGTH]
    STACK_VAR CHAR tsNow[TIME_STAMP_LENGTH]

    TimeCreate(t)
    tsNow = TimeAsTimeStamp(t)
    ts[1] = tsNow
    ts[2] = TimeAsTimeStamp(t1)
    ts[3] = TimeAsTimeStamp(t2)
    TimeStampsSort(ts)
    if(ts[2] == ts[3]) {
	return FALSE
    } else if(ts[2] == tsNow) {
	return TRUE
    } else {
	return FALSE
    }
}


(*******************************************************************************)
(*  TimeIsBeforeCurrentTime                                                    *)
(*  Arguments: _TIME struct t                                                  *)
(*             Time element to compare                                         *)
(*  Returns:   INTEGER                                                         *)
(*             Returns TRUE if current time is before the given time           *)
(*******************************************************************************)
DEFINE_FUNCTION INTEGER TimeIsBeforeCurrentTime(_TIME t) {
    STACK_VAR _TIME tNow
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsNow[TIME_STAMP_WITH_SECONDS_LENGTH]

    TimeCreate(tNow)
    tsNow = TimeAsTimeStampWithSeconds(tNow)
    ts[1] = tsNow
    ts[2] = TimeAsTimeStampWithSeconds(t)
    TimeStampsSort(ts)
    if(ts[1] == ts[2]) {
	return FALSE
    } else if(ts[2] == tsNow) {
	return TRUE
    } else {
	return FALSE
    }
}


(*******************************************************************************)
(*  TimeIsBeforeTime                                                           *)
(*  Arguments: _TIME struct t1                                                 *)
(*             1st time element to compare                                     *)
(*             _TIME struct t2                                                 *)
(*             2nd time element to compate                                     *)
(*  Returns:   INTEGER                                                         *)
(*             Returns TRUE if t1 is before t2                                 *)
(*******************************************************************************)
DEFINE_FUNCTION INTEGER TimeIsBeforeTime(_TIME t1, _TIME t2) {
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsToCheck[TIME_STAMP_WITH_SECONDS_LENGTH]

    tsToCheck = TimeAsTimeStampWithSeconds(t2)
    ts[1] = tsToCheck
    ts[2] = TimeAsTimeStampWithSeconds(t1)
    TimeStampsSort(ts)
    if(ts[1] == ts[2]) {
	return FALSE
    } else if(ts[2] == tsToCheck) {
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER TimeIsBeforeOrEqualToTime(_TIME t1, _TIME t2) {
    STACK_VAR _TIME tNow
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsToCheck[TIME_STAMP_WITH_SECONDS_LENGTH]

    tsToCheck = TimeAsTimeStampWithSeconds(t2)
    ts[1] = tsToCheck
    ts[2] = TimeAsTimeStampWithSeconds(t1)
    TimeStampsSort(ts)
    if(ts[2] == tsToCheck) {
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER TimeIsAfterCurrentTime(_TIME t) {
    STACK_VAR _TIME tNow
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsNow[TIME_STAMP_WITH_SECONDS_LENGTH]

    TimeCreate(tNow)
    tsNow = TimeAsTimeStampWithSeconds(tNow)
    ts[1] = tsNow
    ts[2] = TimeAsTimeStampWithSeconds(t)
    TimeStampsSort(ts)
    if(ts[1] == ts[2]) {
	return FALSE
    } else if(ts[1] == tsNow) {
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER TimeIsAfterTime(_TIME t1, _TIME t2) {
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsToCheck[TIME_STAMP_WITH_SECONDS_LENGTH]

    tsToCheck = TimeAsTimeStampWithSeconds(t2)
    ts[1] = tsToCheck
    ts[2] = TimeAsTimeStampWithSeconds(t1)
    TimeStampsSort(ts)
    if(ts[1] == ts[2]) {
	return FALSE
    } else if(ts[1] == tsToCheck) {
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER TimeIsAfterOrEqualToTime(_TIME t1, _TIME t2) {
    STACK_VAR CHAR ts[2][TIME_STAMP_WITH_SECONDS_LENGTH]
    STACK_VAR CHAR tsToCheck[TIME_STAMP_WITH_SECONDS_LENGTH]

    tsToCheck = TimeAsTimeStampWithSeconds(t2)
    ts[1] = tsToCheck
    ts[2] = TimeAsTimeStampWithSeconds(t1)
    TimeStampsSort(ts)
    if(ts[1] == tsToCheck) {
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER TimeMatches(_TIME t1, _TIME t2) {
    STACK_VAR INTEGER result

    result = 0
    if(t1.year == t2.year) {
	if(t1.month == t2.month) {
	    if(t1.day == t2.day) {
		if(t1.hours == t2.hours) {
		    if(t1.minutes == t2.minutes) {
			if(t1.seconds == t2.seconds) {
			    result = TRUE
			}
		    }
		}
	    }
	}
    }
    return result
}


DEFINE_FUNCTION INTEGER DebugFindkeyInArray(CHAR key[50]) {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER x

    result = 0
    for(x = 1; x <= MAX_LENGTH_ARRAY(debugDataArray); x ++) {
	if(debugDataArray[x].key == key) {
	    result = debugDataArray[x].id
	    break
	}
    }
    return result
}

DEFINE_FUNCTION INTEGER DebugFindNextEmptyArray() {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER x

    result = 0
    for(x = 1; x <= MAX_LENGTH_ARRAY(debugDataArray); x ++) {
	if(debugDataArray[x].key == '') {
	    result = debugDataArray[x].id
	    break
	}
    }
    return result
}

DEFINE_FUNCTION INTEGER DebugFindIndexOfArrayFromID(INTEGER id) {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER x

    result = 0
    for(x = 1; x <= MAX_LENGTH_ARRAY(debugDataArray); x ++) {
	if(debugDataArray[x].id == id) {
	    result = x
	    break
	}
    }
    return result
}

DEFINE_FUNCTION INTEGER DebugAddDataToArray(CHAR key[50], CHAR header[50], CHAR dataString[255]) {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER arrayIndex
    STACK_VAR INTEGER n

    result = 0
    result = DebugFindkeyInArray(key)
    if(DEBUG) {
	if(!result) {
	    result = DebugFindNextEmptyArray()
	    if(result) {
		arrayIndex = DebugFindIndexOfArrayFromID(result)
		TimeCreate(debugDataArray[arrayIndex].createTime)
		debugDataArray[arrayIndex].key = key
	    }
	}
	if(result) {
	    arrayIndex = DebugFindIndexOfArrayFromID(result)
	    for(n = 1; n <= MAX_LENGTH_ARRAY(debugDataArray[arrayIndex].logEntry); n ++) {
		if(debugDataArray[arrayIndex].logEntry[n].dataString == '') {
		    debugDataArray[arrayIndex].logEntry[n].dataString = dataString
		    TimeCreate(debugDataArray[arrayIndex].logEntry[n].entryTime)
		    debugDataArray[arrayIndex].logEntry[n].header = header
		    debugDataArray[arrayIndex].logEntry[n].headerLength = LENGTH_STRING(header)
		    if(debugDataArray[arrayIndex].maxHeaderLength < debugDataArray[arrayIndex].logEntry[n].headerLength) {
			debugDataArray[arrayIndex].maxHeaderLength = debugDataArray[arrayIndex].logEntry[n].headerLength
		    }
		    break
		}
	    }
	}
    }
    return result
}

DEFINE_FUNCTION CHAR[255] DebugPadTextRight(CHAR text[255], INTEGER padding) {
    STACK_VAR INTEGER pos
    STACK_VAR CHAR result[255]

    result = ''
    for(pos = 1; pos <= padding; pos ++) {
	result = "result, $20"
    }
    result = "result, text"
    return result
}

DEFINE_FUNCTION CHAR[255] DebugPadTextLeft(CHAR text[255], INTEGER padding) {
    STACK_VAR INTEGER pos
    STACK_VAR CHAR result[255]

    result = ''
    for(pos = 1; pos <= padding; pos ++) {
	result = "result, $20"
    }
    result = "text, result"
    return result
}

DEFINE_FUNCTION DebugFormatDataHeaders(INTEGER arrayIndex) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER padding

    if(arrayIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(debugDataArray[arrayIndex].logEntry); n ++) {
	    if(debugDataArray[arrayIndex].logEntry[n].headerLength) {
		padding = debugDataArray[arrayIndex].maxHeaderLength - debugDataArray[arrayIndex].logEntry[n].headerLength
		debugDataArray[arrayIndex].logEntry[n].headerPadded = DebugPadTextLeft(debugDataArray[arrayIndex].logEntry[n].header, padding)
	    }
	}
    }
}

DEFINE_FUNCTION DebugSendArrayToConsole(CHAR key[50]) {
    STACK_VAR INTEGER id
    STACK_VAR INTEGER arrayIndex
    STACK_VAR CHAR textToSend[255]
    STACK_VAR INTEGER n
    
    if(DEBUG) {
	id = DebugFindkeyInArray(key)
	if(id) {
	    arrayIndex = DebugFindIndexOfArrayFromID(id)
	    DebugFormatDataHeaders(arrayIndex)
	    textToSend = ''
	    DebugSendStringToConsole(debugDataArray[arrayIndex].key)
	    for(n = 1; n <= MAX_LENGTH_ARRAY(debugDataArray[arrayIndex].logEntry); n ++) {
		if(LENGTH_STRING(debugDataArray[arrayIndex].logEntry[n].dataString)) {
		    if(debugDataArray[arrayIndex].logEntry[n].headerLength) {
			textToSend = "$20, $20, debugDataArray[arrayIndex].logEntry[n].headerPadded, $20, $20, $20, $22"
		    }
		    textToSend = "textToSend, debugDataArray[arrayIndex].logEntry[n].dataString"
		    if(debugDataArray[arrayIndex].logEntry[n].headerLength) {
			textToSend = "textToSend, $22"
		    }
		    SEND_STRING 0, "'     ', textToSend"
		}
	    }
	    //DebugSendEndStringToConsole(debugDataArray[arrayIndex].key)
	    DebugInitStorage(arrayIndex)
	}
    }
}

DEFINE_FUNCTION DebugSendStringToConsole(CHAR stringToSend[255]) {
    if(DEBUG) {
	SEND_STRING 0, "'DEBUG: ', stringToSend"
    }
}

DEFINE_FUNCTION DebugSendEndStringToConsole(CHAR stringToSend[255]) {
    if(DEBUG) {
	SEND_STRING 0, "'DEBUG: ', stringToSend"
	SEND_COMMAND 0, "'END'"
    }
}

DEFINE_FUNCTION DebugInitStorage(INTEGER index) {
    STACK_VAR INTEGER x
    STACK_VAR INTEGER y
    STACK_VAR INTEGER startIndex
    STACK_VAR INTEGER endIndex

    startIndex = 0
    endIndex = 0
    if(index && index <= MAX_LENGTH_ARRAY(debugDataArray)) {
	startIndex = index
	endIndex = index
    } else if(!index) {
	startIndex = 1
	endIndex = MAX_LENGTH_ARRAY(debugDataArray)
    }
    if(startIndex && endIndex) {
	for(x = startIndex; x <= endIndex; x ++) {
	    debugDataArray[x].id = x
	    debugDataArray[x].key = ''
	    for(y = 1; y <= MAX_LENGTH_ARRAY(debugDataArray[x].logEntry); y ++) {
		debugDataArray[x].logEntry[y].id = y
		debugDataArray[x].logEntry[y].dataString = ''
		debugDataArray[x].logEntry[y].entryTime.year = 0
		debugDataArray[x].logEntry[y].entryTime.month = 0
		debugDataArray[x].logEntry[y].entryTime.day = 0
		debugDataArray[x].logEntry[y].entryTime.hours = 0
		debugDataArray[x].logEntry[y].entryTime.minutes = 0
		debugDataArray[x].logEntry[y].entryTime.seconds = 0
		debugDataArray[x].logEntry[y].header = ''
		debugDataArray[x].logEntry[y].headerLength = 0
		debugDataArray[x].logEntry[y].headerPadded = ''
	    }
	}
    }
}

/* STANDARD NUMBERS ********************************************************/

DEFINE_CONSTANT

INTEGER DECIMALNUMBERS[13] = {
    1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000
}

CHAR DECIMALCHARACTERS[13][2] = {
    'I','IV','V','IX','X','XL','L','XC','C','CD','D','CM','M'
}

CHAR DAYSOFWEEKLONG[7][9] = {
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
}

CHAR MONTHSOFYEARLONG[12][9] = {
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
}

DEFINE_FUNCTION CHAR[100] DecimalToRoman(LONG decimalVal) {
    STACK_VAR INTEGER tempVal
    STACK_VAR CHAR resultChar[100]

    for(tempVal = 13; tempVal >= 1; tempVal--) {
        while(decimalVal >= DECIMALNUMBERS[tempVal]) {
            decimalVal = decimalVal - DECIMALNUMBERS[tempVal]
            resultChar = "resultChar, DECIMALCHARACTERS[tempVal]"
        }
    }

    return resultChar
}

DEFINE_FUNCTION SLONG ScaleRange(SLONG slNum_In, SLONG slMin_In, SLONG slMax_In, SLONG slMin_Out, SLONG slMax_Out) {
    SLONG slRange_In
    SLONG slRange_Out
    SLONG slNum_Out
    SLONG slPassByReferenceBug

    //this function used to change the value of parameter 1: slNum_In.  added slPassByReferenceBug to
    //get over this
    slPassByReferenceBug = slNum_In
    if(slPassByReferenceBug < slMin_In OR slPassByReferenceBug > slMax_In) {
        SEND_STRING 0, "'ScaleRange() Error: Invalid value. Enter a value between ',ITOA(slMin_In),' and ',ITOA(slMax_In),'.'"
        return -1
    }
    else{
        slRange_In = slMax_In - slMin_In      // Establish input range
        slRange_Out = slMax_Out - slMin_Out   // Establish output range
        slPassByReferenceBug = slPassByReferenceBug - slMin_In        // Remove input offset
        slNum_Out = slPassByReferenceBug * slRange_Out    // Multiply by max out range
        slNum_Out = slNum_Out / slRange_In    // Then divide by max in range
        slNum_Out = slNum_Out + slMin_Out     // Add in minimum output value
        return slNum_Out
    }
}

DEFINE_FUNCTION CHAR[255] PrintDate(INTEGER nFormat, CHAR sDate[10]) {
    STACK_VAR CHAR result[255]
    STACK_VAR INTEGER nWeekDay,nDay,nMonth,nYear

    nWeekDay = TYPE_CAST(DAY_OF_WEEK(sDate))
    nDay = TYPE_CAST(DATE_TO_DAY(sDate))
    nMonth = TYPE_CAST(DATE_TO_MONTH(sDate))
    nYear = TYPE_CAST(DATE_TO_YEAR(sDate))
    if(nFormat == 1) { // "Monday 1 December 1999"
	result = "DAYSOFWEEKLONG[nWeekDay],' ',
	ItoA(nDay),' ',
	MONTHSOFYEARLONG[nMonth],' ',
	ItoA(nYear)"
    }
    return result
}

DEFINE_FUNCTION CHAR[255] StringAsHex(CHAR text[255]) {
    STACK_VAR CHAR result[255]
    STACK_VAR INTEGER n

    result = ''
    for(n = 1; n <= LENGTH_STRING(text); n ++) {
	result = "result, FORMAT('%02X', text[n])"
	if(n < LENGTH_STRING(text)) {
	    result = "result, ','"
	}
    }
    return result
}

DEFINE_FUNCTION CHAR[255] FormatHiddenPassword(CHAR text[], INTEGER maskLastChar) {
    STACK_VAR CHAR result[255]
    STACK_VAR INTEGER n
    STACK_VAR INTEGER len

    result = ''
    len = LENGTH_STRING(text)
    for(n = 1; n <= len; n++) {
	if(n == len && !maskLastChar) {
	    result = "result, RIGHT_STRING(text, 1)"
	} else {
	    result = "result, '*'"
	}
    }
    return result
}

DEFINE_FUNCTION CHAR[255] FormatPossibleIPAddress(CHAR stringToCheck[]) {
    STACK_VAR INTEGER stringLength
    STACK_VAR INTEGER n
    STACK_VAR INTEGER tempCount
    STACK_VAR INTEGER dotCount
    STACK_VAR CHAR result[255]

    stringLength = LENGTH_STRING(stringToCheck)
    tempCount = 0
    dotCount = 0
    result = ''
    if(stringLength <= 15) {
	for(n = 1; n <= stringLength; n++) {
	    tempCount ++
	    if(tempCount <= 4) {
		if(MID_STRING(stringToCheck,n,1) == '*') {
		    dotCount ++
		    tempCount = 0
		}
	    } else {
		dotCount = 0
		break
	    }
	}
	if(dotCount == 3) {
	    for(n = 1; n <= stringLength; n++) {
		if(MID_STRING(stringToCheck,n,1) == '*') {
		    result = "result,'.'"
		} else {
		    result = "result,MID_STRING(stringToCheck,n,1)"
		}
	    }
	} else {
	    result = stringToCheck
	}
    } else {
	result = stringToCheck
    }
    return result
}

DEFINE_FUNCTION CHAR[MAX_STRING_LENGTH_FROM_DEVICE] StringFromTwoDelimiters(CHAR stringToProcess[], CHAR delimiterA[], CHAR delimiterB[], INTEGER startPos) {
    STACK_VAR CHAR resultString[MAX_STRING_LENGTH_FROM_DEVICE]
    STACK_VAR INTEGER m1
    STACK_VAR INTEGER m2

    m1 = FIND_STRING(stringToProcess, delimiterA, startPos)
    m2 = FIND_STRING(stringToProcess, delimiterB, m1 + LENGTH_STRING(delimiterA))
    if(m1 && m2) {
	resultString = MID_STRING(stringToProcess, m1 + LENGTH_STRING(delimiterA), m2 - m1 - LENGTH_STRING(delimiterA))
    } else {
	resultString = ''
    }
    return resultString
}

DEFINE_FUNCTION CHAR[20] DeviceToString(DEV device) {
    return "ItoA(device.Number),':',ItoA(device.Port),':',ItoA(device.System)"
}


DEFINE_START {
    DebugInitStorage(0)
}


