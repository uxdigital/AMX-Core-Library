PROGRAM_NAME='Core Debug'

#IF_DEFINED DEBUG

#WARN 'DEBUG ENABLED !!'

DEFINE_CONSTANT

INTEGER DEBUG_ARRAY_MAX_SIZE					= 10

INTEGER DEBUG_ARRAY_DATA_LOG_MAX_SIZE				= 50


DEFINE_TYPE

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

#END_IF

DEFINE_FUNCTION INTEGER DebugAddDataToArray(CHAR key[50], CHAR header[50], CHAR dataString[255]) {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER arrayIndex
    STACK_VAR INTEGER n
    
    #IF_DEFINED DEBUG
    
    result = 0
    result = DebugFindkeyInArray(key)
    
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
    
    #END_IF
    
    return result
}

DEFINE_FUNCTION INTEGER DebugAddNumberToArray(CHAR key[50], CHAR header[50], INTEGER number) {
    #IF_DEFINED DEBUG
    DebugAddDataToArray(key, header, ItoA(number))
    #END_IF
}

DEFINE_FUNCTION INTEGER DebugAddSignedNumberToArray(CHAR key[50], CHAR header[50], SINTEGER number) {
    #IF_DEFINED DEBUG
    DebugAddDataToArray(key, header, ItoA(number))
    #END_IF
}

DEFINE_FUNCTION DebugSendArrayToConsole(CHAR key[50]) {
    STACK_VAR INTEGER id
    STACK_VAR INTEGER arrayIndex
    STACK_VAR CHAR textToSend[255]
    STACK_VAR INTEGER n
    
    #IF_DEFINED DEBUG
    
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
    
    #END_IF
}

DEFINE_FUNCTION DebugSendStringToConsole(CHAR stringToSend[255]) {
    #IF_DEFINED DEBUG
    SEND_STRING 0, "'DEBUG: ', stringToSend"
    #END_IF
}

DEFINE_FUNCTION DebugSendEndStringToConsole(CHAR stringToSend[255]) {
    #IF_DEFINED DEBUG
    SEND_STRING 0, "'DEBUG: ', stringToSend"
    SEND_COMMAND 0, "'END'"
    #END_IF
}

DEFINE_FUNCTION SNAPI_Debug(_SNAPI_DATA snapi) {
    STACK_VAR INTEGER n
    
    DebugAddDataToArray("'SNAPI Debug (', snapi.cmd, ')'", 'snapi.device', DeviceToString(snapi.device))
    DebugAddDataToArray("'SNAPI Debug (', snapi.cmd, ')'", 'snapi.cmd', snapi.cmd)
    DebugAddNumberToArray("'SNAPI Debug (', snapi.cmd, ')'", 'snapi.numberOfParams', snapi.numberOfParams)
    for(n = 1; n <= snapi.numberOfParams; n ++) {
	DebugAddDataToArray("'SNAPI Debug (', snapi.cmd, ')'", "'snapi.param[', ItoA(n), ']'", snapi.param[n])
    }
    DebugSendArrayToConsole("'SNAPI Debug (', snapi.cmd, ')'")
}

#IF_DEFINED DEBUG
    
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

DEFINE_START {
    DebugInitStorage(0)
}

#END_IF
