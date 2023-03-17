#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

#ifdef AUTOMATED_TESTING
#pragma ModuleName=MIES_GUI
#endif

/// @file MIES_GuiUtilities.ipf
/// @brief Helper functions related to GUI controls

static StrConstant USERDATA_PREFIX = "userdata("
static StrConstant USERDATA_SUFFIX = ")"

static Constant AXIS_MODE_NO_LOG = 0

/// @brief Show a GUI control in the given window
Function ShowControl(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	if((V_disable & HIDDEN_CONTROL_BIT) == 0)
		return NaN
	endif

	ModifyControl $control win=$win, disable=(V_disable & ~HIDDEN_CONTROL_BIT)
End

/// @brief Show a list of GUI controls in the given window
Function ShowControls(win, controlList)
	string win, controlList

	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		ShowControl(win,ctrl)
	endfor
End

/// @brief Hide a GUI control in the given window
Function HideControl(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	if(V_disable & HIDDEN_CONTROL_BIT)
		return NaN
	endif

	ModifyControl $control win=$win, disable=(V_disable | HIDDEN_CONTROL_BIT)
End

/// @brief Hide a list of GUI controls in the given window
Function HideControls(win, controlList)
	string win, controlList

	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		HideControl(win,ctrl)
	endfor
End

/// @brief Enable a GUI control in the given window
Function EnableControl(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	if( (V_disable & DISABLE_CONTROL_BIT) == 0)
		return NaN
	endif

	ModifyControl $control win=$win, disable=(V_disable & ~DISABLE_CONTROL_BIT)
End

/// @brief Enable a list of GUI controls in the given window
Function EnableControls(win, controlList)
	string win, controlList

	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		EnableControl(win,ctrl)
	endfor
End

/// @brief Disable a GUI control in the given window
Function DisableControl(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	if(V_disable & DISABLE_CONTROL_BIT)
		return NaN
	endif

	ModifyControl $control win=$win, disable=(V_disable | DISABLE_CONTROL_BIT)
End

/// @brief Disable a list of GUI controls in the given window
Function DisableControls(win, controlList)
	string win, controlList

	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		DisableControl(win,ctrl)
	endfor
End

/// @brief Set the title of a list of controls
Function SetControlTitles(win, controlList, controlTitleList)
	string win, controlList, controlTitleList

	variable i
	variable numItems = ItemsInList(controlList)
	ASSERT(numItems <= ItemsInList(controlTitleList), "List of control titles is too short")
	string controlName, newTitle
	for(i=0; i < numItems; i+=1)
		controlName = StringFromList(i,controlList)
		newTitle = StringFromList(i,controlTitleList)
		SetControlTitle(win, controlName, newTitle)
	endfor
End

/// @brief Set the title of a control
Function SetControlTitle(win, controlName, newTitle)
	string win, controlName, newTitle

	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, title = newTitle
End

/// @brief Set the procedure of a list of controls
Function SetControlProcedures(win, controlList, newProcedure)
	string win, controlList, newProcedure

	variable i
	string controlName
	variable numItems = ItemsInList(controlList)

	for(i = 0; i < numItems; i += 1)
		controlName = StringFromList(i, controlList)
		SetControlProcedure(win, controlName, newProcedure)
	endfor
End

/// @brief Set the procedure of a control
Function SetControlProcedure(win, controlName, newProcedure)
	string win, controlName, newProcedure

	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, proc = $newProcedure
End

/// @brief Return the title of a control
///
/// @param recMacro     recreation macro for ctrl
/// @param supress      supress assertion that ctrl must have a title
/// @return Returns     the title or an empty string
Function/S GetTitle(recMacro, [supress])
	string recMacro
	variable supress

	string title, errorMessage

	if(ParamIsDefault(supress))
		supress = 0
	endif

	// [^\"\\\\] matches everything except escaped quotes
	// \\\\.     eats backslashes
	// [^\"\\\\] up to the next escaped quote
	// does only match valid strings
	SplitString/E="(?i)title=\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"" recMacro, title

	if(!V_Flag)
		sprintf errorMessage, "recreation macro %.30s does not contain a title", recMacro
		ASSERT(supress, errorMessage)
	endif

	return title
End

/// @brief Change color of the title of mulitple controls
Function SetControlTitleColors(win, controlList, R, G, B)
	string win, controlList
	variable R, G, B

	variable i
	variable numItems = ItemsInList(controlList)
	string controlName
	for(i=0; i < numItems; i+=1)
		controlName = StringFromList(i,controlList)
		SetControlTitleColor(win, controlName, R, G, B)
	endfor
End

/// @brief Change color of a control
Function SetControlTitleColor(win, controlName, R, G, B) ///@todo store color in control user data, check for color change before applying change
	string win, controlName
	variable R, G, B

	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, fColor = (R,G,B)
End

/// @brief Change color of a control
Function ChangeControlColor(win, controlName, R, G, B)
	string win, controlName
	variable R, G, B

	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, fColor = (R,G,B)

End

/// @brief Change the font color of a control
Function ChangeControlValueColor(win, controlName, R, G, B)
	string win, controlName
	variable R, G, B

	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, valueColor = (R,G,B)

End

/// @brief Change the font color of a list of controls
Function ChangeControlValueColors(win, controlList, R, G, B)
	string win, controlList
	variable R, G, B
	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		ControlInfo/W=$win $ctrl
		ASSERT(V_flag != 0, "Non-existing control or window")
	//	ChangeControlValueColor(win, ctrl, R, G, B)
	endfor

	ModifyControlList controlList, WIN = $win, valueColor = (R,G,B)

End

/// @brief Changes the background color of a control
///
/// @param win         panel
/// @param controlName GUI control name
/// @param R           red
/// @param G           green
/// @param B           blue
/// @param Alpha defaults to opaque if not provided
Function SetControlBckgColor(win, controlName, R, G, B, [Alpha])
	string win, controlName
	variable R, G, B, Alpha

	if(paramIsDefault(Alpha))
		Alpha = 1
	Endif
	ASSERT(Alpha > 0 && Alpha <= 1, "Alpha must be between 0 and 1")
	Alpha *= 65535
	ControlInfo/W=$win $controlName
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $ControlName WIN = $win, valueBackColor = (R,G,B,Alpha)
End

/// @brief Change the background color of a list of controls
Function ChangeControlBckgColors(win, controlList, R, G, B)
	string win, controlList
	variable R, G, B
	variable i
	variable numItems = ItemsInList(controlList)
	string ctrl
	for(i=0; i < numItems; i+=1)
		ctrl = StringFromList(i,controlList)
		ControlInfo/W=$win $ctrl
		ASSERT(V_flag != 0, "Non-existing control or window")
	//	ChangeControlValueColor(win, ctrl, R, G, B)
	endfor

	ModifyControlList controlList, WIN = $win, valueBackColor = (R,G,B)

End

/// @brief Returns one if the checkbox is selected or zero if it is unselected
Function GetCheckBoxState(win, control)
	string win, control
	variable allowMissingControl

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(V_flag == CONTROL_TYPE_CHECKBOX, "Control is not a checkbox")
	return V_Value
End

/// @brief Set the internal number in a setvariable control
Function SetSetVariable(win,Control, newValue, [respectLimits])
	string win, control
	variable newValue
	variable respectLimits

	if(ParamIsDefault(respectLimits))
		respectLimits = 0
	endif

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SETVARIABLE, "Control is not a setvariable")

	if(respectLimits)
		newValue = GetLimitConstrainedSetVar(S_recreation, newValue)
	endif

	if(newValue != v_value)
		SetVariable $control, win = $win, value =_NUM:newValue
	endif

	return newValue
End

/// @brief Set the SetVariable contents as string
///
/// @param win     window
/// @param control control of type SetVariable
/// @param str     string to set
/// @param setHelp [optional, defaults to false] set the help string as well.
///                Allows to work around long text in small controls.
Function SetSetVariableString(string win, string control, string str, [variable setHelp])

	if(ParamIsDefault(setHelp))
		setHelp = 0
	else
		setHelp = !!setHelp
	endif

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SETVARIABLE, "Control is not a setvariable")

	if(setHelp)
		SetVariable $control, win = $win, value =_STR:str, help={str}
	else
		SetVariable $control, win = $win, value =_STR:str
	endif
End

/// @brief Set the state of the checkbox
Function SetCheckBoxState(win,control,state)
	string win, control
	variable state

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_CHECKBOX, "Control is not a checkbox")

	state = !!state

	if(state != V_Value)
		CheckBox $control, win=$win, value=(state==CHECKBOX_SELECTED)
	endif

End

/// @brief Set the input limits for a setVariable control
Function SetSetVariableLimits(win, Control, low, high, increment)
	string win, control
	variable low, high, increment

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SETVARIABLE, "Control is not a setvariable")

	SetVariable $control, win = $win, limits={low,high,increment}
End

/// @brief Returns the contents of a SetVariable
Function GetSetVariable(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SETVARIABLE, "Control is not a setvariable")
	return V_Value
end

/// @brief Returns the contents of a SetVariable with an internal string
Function/S GetSetVariableString(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SETVARIABLE, "Control is not a setvariable")
	return S_Value
end

/// @brief Returns the current PopupMenu item as string
Function/S GetPopupMenuString(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_POPUPMENU, "Control is not a popupmenu")
	return S_Value
End

/// @brief Returns the zero-based index of a PopupMenu
Function GetPopupMenuIndex(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_POPUPMENU, "Control is not a popupmenu")
	ASSERT(V_Value >= 1,"Invalid index")
	return V_Value - 1
End

/// @brief Sets the zero-based index of the PopupMenu
Function SetPopupMenuIndex(win, control, index)
	string win, control
	variable index
	index += 1

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_POPUPMENU, "Control is not a popupmenu")
	ASSERT(index >= 0,"Invalid index")
	PopupMenu $control win=$win, mode=index
End

/// @brief Sets the popupmenu value
Function SetPopupMenuVal(string win, string control, [string list, string func])
	string output, allEntries

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_POPUPMENU, "Control is not a popupmenu")

	if(!ParamIsDefault(list))
		sprintf output, "\"%s\"" List
		ASSERT(strlen(output) < MAX_COMMANDLINE_LENGTH, "Popup menu list is greater than MAX_COMMANDLINE_LENGTH characters")
	elseif(!ParamIsDefault(func))
		output = func
		allEntries = GetPopupMenuList(func, POPUPMENULIST_TYPE_OTHER)
		ASSERT(!IsEmpty(allEntries), "func does not generate a non-empty string list.")
	endif

	PopupMenu $control win=$win, value=#output
End

/// @brief Sets the popupmenu string
///
/// @param win     target window
/// @param control target control
/// @param str     popupmenu string to select. Supports wildcard character(*)
///
/// @return set string with wildcard expanded
Function/S SetPopupMenuString(win, control, str)
	string win, control
	string str

	string result

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_POPUPMENU, "Control is not a popupmenu")
	PopupMenu $control win=$win, popmatch = str

	result = GetPopupMenuString(win, control)

	ASSERT(stringMatch(result, str), "str: \"" + str + "\" is not in the popupmenus \"" + control + "\" list")

	return result
End

/// @brief Returns the contents of a ValDisplay
Function/S GetValDisplayAsString(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_VALDISPLAY, "Control is not a val display")
	return S_value
End

/// @brief Returns the contents of a ValDisplay as a number
Function GetValDisplayAsNum(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_VALDISPLAY, "Control is not a val display")
	return V_Value
End

/// @brief Returns the slider position
Function GetSliderPositionIndex(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SLIDER, "Control is not a slider")
	return V_value
End

/// @brief Sets the slider position
Function SetSliderPositionIndex(win, control, index)
	string win, control
	variable index

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_SLIDER, "Control is not a slider")
	Slider $control win=$win, value = index
End

/// @brief Set a ValDisplay
///
/// @param win     panel
/// @param control GUI control
/// @param var     numeric variable to set
/// @param format  format string referencing the numeric variable `var`
/// @param str     path to global variable or wave element
///
/// The following parameter combinations are valid:
/// - `var`
/// - `var` and `format`
/// - `str`
Function SetValDisplay(win, control, [var, str, format])
	string win, control
	variable var
	string str, format

	string formattedString

	if(!ParamIsDefault(format))
		ASSERT(ParamIsDefault(str), "Unexpected parameter combination")
		ASSERT(!ParamIsDefault(var), "Unexpected parameter combination")
		sprintf formattedString, format, var
	elseif(!ParamIsDefault(var))
		ASSERT(ParamIsDefault(str), "Unexpected parameter combination")
		ASSERT(ParamIsDefault(format), "Unexpected parameter combination")
		sprintf formattedString, "%g", var
	elseif(!ParamIsDefault(str))
		ASSERT(ParamIsDefault(var), "Unexpected parameter combination")
		ASSERT(ParamIsDefault(format), "Unexpected parameter combination")
		formattedString = str
	else
		ASSERT(0, "Unexpected parameter combination")
	endif

	// Don't update if the content does not change, prevents flickering
	if(CmpStr(GetValDisplayAsString(win, control), formattedString) == 0)
		return NaN
	endif

	ValDisplay $control win=$win, value=#formattedString
End

/// @brief Check if a given control exists
Function ControlExists(win, control)
	string win, control

	ControlInfo/W=$win $control
	return V_flag != 0
End

/// @brief Return the full subwindow path to the windows the control belongs to
Function/S FindControl(control)
	string control

	string windows, childWindows, childWindow, win
	variable i, j, numWindows, numChildWindows
	string matches = ""

	// search in all panels and graphs
	windows = WinList("*", ";", "WIN:65")

	numWindows = ItemsInList(windows)
	for(i = 0; i < numWindows; i += 1)
		win = StringFromList(i, windows)

		childWindows = GetAllWindows(win)

		numChildWindows = ItemsInList(childWindows)
		for(j = 0; j < numChildWindows; j += 1)
			childWindow = StringFromList(j, childWindows)

			if(ControlExists(childWindow, control))
				matches = AddListItem(childWindow, matches, ";", Inf)
			endif
		endfor
	endfor

	return matches
End

/// @brief Return the full subwindow path to the given notebook
Function/S FindNotebook(nb)
	string nb

	string windows, childWindows, childWindow, win, leaf
	variable i, j, numWindows, numChildWindows
	string matches = ""

	// search in all panels and graphs
	windows = WinList("*", ";", "WIN:65")

	numWindows = ItemsInList(windows)
	for(i = 0; i < numWindows; i += 1)
		win = StringFromList(i, windows)

		childWindows = GetAllWindows(win)

		numChildWindows = ItemsInList(childWindows)
		for(j = 0; j < numChildWindows; j += 1)
			childWindow = StringFromList(j, childWindows)

			leaf = StringFromList(ItemsInList(childWindow, "#") - 1, childWindow, "#")

			if(!cmpstr(leaf, nb))
				matches = AddListItem(childWindow, matches, ";", Inf)
			endif
		endfor
	endfor

	return matches
End

/// @brief Returns the number of the current tab
///
/// @param win	window name
/// @param ctrl	name of the control
Function GetTabID(win, ctrl)
	string win, ctrl

	ControlInfo/W=$win $ctrl
	ASSERT(V_flag != 0, "Non-existing control or window")
	ASSERT(abs(V_flag) == CONTROL_TYPE_TAB, "Control is not a tab")
	return V_value
End

/// @brief Set value as the user data named key
///
/// @param win     window name
/// @param control name of the control
/// @param key     user data identifier
/// @param value   user data value
Function SetControlUserData(win, control, key, value)
	string win, control, key, value

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	ModifyControl $control win=$win, userdata($key)=value
End

/// @brief Get distinctive trace colors for a given index
///
/// Holds 21 different trace colors, code originally from
/// http://www.igorexchange.com/node/6532 but completely rewritten and bug-fixed.
///
/// The colors are "Twenty two colors of maximum contrast" by L. Kelly, see http://www.iscc.org/pdf/PC54_1724_001.pdf,
/// where the color white has been removed.
Function [STRUCT RGBColor s] GetTraceColor(variable index)

	index = mod(index, 21)
	switch(index)
		case 0:
			s.red = 7967; s.green=7710; s.blue=7710
			break

		case 1:
			s.red = 60395; s.green=52685; s.blue=15934
			break

		case 2:
			s.red = 28527; s.green=12336; s.blue=35723
			break

		case 3:
			s.red = 56283; s.green=27242; s.blue=10537
			break

		case 4:
			s.red = 38807; s.green=52942; s.blue=59110
			break

		case 5:
			s.red = 47545; s.green=8224; s.blue=13878
			break

		case 6:
			s.red = 49858; s.green=48316; s.blue=33410
			break

		case 7:
			s.red = 32639; s.green=32896; s.blue=33153
			break

		case 8:
			s.red = 25186; s.green=42662; s.blue=18247
			break

		case 9:
			s.red = 54227; s.green=34438; s.blue=45746
			break

		case 10:
			s.red = 17733; s.green=30840; s.blue=46003
			break

		case 11:
			s.red = 56540; s.green=33924; s.blue=25957
			break

		case 12:
			s.red = 18504; s.green=14392; s.blue=38550
			break

		case 13:
			s.red = 57825; s.green=41377; s.blue=12593
			break

		case 14:
			s.red = 37265; s.green=10023; s.blue=35723
			break

		case 15:
			s.red = 59881; s.green=59624; s.blue=22359
			break

		case 16:
			s.red = 32125; s.green=5911; s.blue=5654
			break

		case 17:
			s.red = 37779; s.green=44461; s.blue=15420
			break

		case 18:
			s.red = 28270; s.green=13621; s.blue=5397
			break

		case 19:
			s.red = 53713; s.green=11565; s.blue=10023
			break

		case 20:
			s.red = 11308; s.green=13878; s.blue=5911
			break

		default:
			ASSERT(0, "Invalid index")
			break
	endswitch
End

/// @brief Query the axis minimum and maximum values
///
/// For none existing graph or axis
/// NaN is returned for minimum and high.
///
/// The return value for autoscale axis depends on the mode flag:
/// AXIS_RANGE_INC_AUTOSCALED -> [0, 0]
/// AXIS_RANGE_DEFAULT -> [NaN, NaN]
///
/// @param[in] graph graph name
/// @param[in] axis  axis name
/// @param[in] mode  [optional:default #AXIS_RANGE_DEFAULT] optional mode option, see @ref AxisPropModeConstants
///
/// @return minimum and maximum value of the axis range
Function [variable minimum, variable maximum] GetAxisRange(string graph, string axis, [variable mode])
	string info

	if(!windowExists(graph))
		return [NaN, NaN]
	endif

	if(ParamIsDefault(mode))
		mode = AXIS_RANGE_DEFAULT
	endif

	info = AxisInfo(graph, axis)

	// axis does not exist
	if(isEmpty(info))
		return [NaN, NaN]
	endif

	[minimum, maximum] = GetAxisRangeFromInfo(graph, info, axis, mode)
End

static Function [variable minimum, variable maximum] GetAxisRangeFromInfo(string graph, string info, string axis, variable mode)

	string flags

	if(mode == AXIS_RANGE_DEFAULT)
		flags = StringByKey("SETAXISFLAGS", info)
		if(!isEmpty(flags))
			// axis is in auto scale mode
			return [NaN, NaN]
		endif
	elseif(mode & AXIS_RANGE_INC_AUTOSCALED)
		// do nothing
	else
		ASSERT(0, "Unknown mode from AxisPropModeConstants for this function")
	endif

	GetAxis/W=$graph/Q $axis
	return [V_min, V_max]
End

/// @brief Return the orientation of the axis as numeric value
/// @returns one of @ref AxisOrientationConstants
Function GetAxisOrientation(graph, axes)
	string graph, axes

	string orientation

	orientation = StringByKey("AXTYPE", AxisInfo(graph, axes))

	strswitch(orientation)
		case "left":
			return AXIS_ORIENTATION_LEFT
			break
		case "right":
			return AXIS_ORIENTATION_RIGHT
			break
		case "bottom":
			return AXIS_ORIENTATION_BOTTOM
			break
		case "top":
			return AXIS_ORIENTATION_TOP
			break
	endswitch

	DoAbortNow("unknown axis type")
End

/// @brief Return the recreation macro for an axis
static Function/S GetAxisRecreationMacro(string info)

	string key
	variable index

	// straight from the AxisInfo help
	key = ";RECREATION:"
	index = strsearch(info,key,0)

	return info[index + strlen(key), inf]
End

/// @brief Return the logmode of the axis
///
/// @return One of @ref ModifyGraphLogModes
Function GetAxisLogMode(string graph, string axis)
	string info

	info = AxisInfo(graph, axis)

	if(IsEmpty(info))
		return NaN
	endif

	return GetAxisLogModeFromInfo(info)
End

static Function GetAxisLogModeFromInfo(string info)
	string recMacro

	recMacro = GetAxisRecreationMacro(info)
	return NumberByKey("log(x)", recMacro, "=")
End

/// @brief Returns a wave with the minimum and maximum
/// values of each axis
///
/// Use SetAxesRanges to set the minimum and maximum values
/// @see GetAxisRange
/// @param[in] graph Name of graph
/// @param[in] axesRegexp [optional: default not set] filter axes names list by this optional regular expression
/// @param[in] orientation [optional: default not set] filter orientation of axes see @ref AxisOrientationConstants
/// @param[in] mode [optional: default #AXIS_RANGE_DEFAULT] filter returned axis information by mode see @ref AxisPropModeConstants
/// @return free wave with rows = axes, cols = axes info, dimlabel of rows is axis name
Function/Wave GetAxesProperties(graph[, axesRegexp, orientation, mode])
	string graph, axesRegexp
	variable orientation, mode

	string list, axis, recMacro, info
	variable numAxes, i, countAxes, minimum, maximum, axisOrientation, logMode

	if(ParamIsDefault(mode))
		mode = AXIS_RANGE_DEFAULT
	endif

	list = AxisList(graph)

	if(!ParamIsDefault(axesRegexp))
		list = GrepList(list, axesRegexp)
	endif

	list    = SortList(list)
	numAxes = ItemsInList(list)

	Make/FREE/D/N=(numAxes, 4) props = 0
	SetDimLabel COLS, 0, minimum , props
	SetDimLabel COLS, 1, maximum , props
	SetDimLabel COLS, 2, axisType, props
	SetDimLabel COLS, 3, logMode, props

	for(i = 0; i < numAxes; i += 1)
		axis = StringFromList(i, list)
		axisOrientation = GetAxisOrientation(graph, axis)
		if(!ParamIsDefault(orientation) && !(axisOrientation & orientation))
			continue
		endif

		info = AxisInfo(graph, axis)

		[minimum, maximum] = GetAxisRangeFromInfo(graph, info, axis, mode)
		props[countAxes][%axisType] = axisOrientation
		props[countAxes][%minimum] = minimum
		props[countAxes][%maximum] = maximum

		props[countAxes][%logMode] = GetAxisLogModeFromInfo(info)

		SetDimLabel ROWS, countAxes, $axis, props
		countAxes += 1
	endfor

	if(countAxes != numAxes)
		Redimension/N=(countAxes, -1) props
	endif

	return props
End

/// @brief Set the properties of all axes as stored by GetAxesProperties
///
/// Includes a heuristic if the name of the axis changed after GetAxesProperties.
/// The axis range is also restored if its index in the sorted axis list and its
/// orientation is the same.
///
/// @see GetAxisProps
/// @param[in] graph Name of graph
/// @param[in] props wave with graph props as set in @ref GetAxesProperties
/// @param[in] axesRegexp [optional: default not set] filter axes names list by this optional regular expression
/// @param[in] orientation [optional: default not set] filter orientation of axes see @ref AxisOrientationConstants
/// @param[in] mode [optional: default 0] axis set mode see @ref AxisPropModeConstants
Function SetAxesProperties(graph, props[, axesRegexp, orientation, mode])
	string graph
	Wave props
	string axesRegexp
	variable orientation, mode

	variable numRows, numAxes, i, minimum, maximum, axisOrientation
	variable col, row, prevAxisMin, prevAxisMax, logMode
	string axis, list

	ASSERT(windowExists(graph), "Graph does not exist")

	if(ParamIsDefault(mode))
		mode = AXIS_RANGE_DEFAULT
	endif

	prevAxisMin = NaN

	numRows = DimSize(props, ROWS)

	list = AxisList(graph)

	if(!ParamIsDefault(axesRegexp))
		list = GrepList(list, axesRegexp)
	endif

	list    = SortList(list)
	numAxes = ItemsInList(list)

	for(i = 0; i < numAxes; i += 1)
		axis = StringFromList(i, list)
		axisOrientation = GetAxisOrientation(graph, axis)
		if(!ParamIsDefault(orientation) && axisOrientation != orientation)
			continue
		endif

		row = FindDimLabel(props, ROWS, axis)

		if(row >= 0)
			minimum = props[row][%minimum]
			maximum = props[row][%maximum]
			logMode = props[row][%logMode]
		else
			// axis does not exist
			if(mode & AXIS_RANGE_USE_MINMAX)
				// use MIN/MAX of previous axes
				if(isNaN(prevAxisMin))
					// need to retrieve once
					col = FindDimLabel(props, COLS, "maximum")
					WaveStats/Q/M=1/RMD=[][col] props
					prevAxisMax = V_Max
					col = FindDimLabel(props, COLS, "minimum")
					WaveStats/Q/M=1/RMD=[][col] props
					prevAxisMin = V_Min
				endif
				minimum = prevAxisMin
				maximum = prevAxisMax
				logMode = AXIS_MODE_NO_LOG
			elseif(mode == AXIS_RANGE_DEFAULT)
				// probably just name has changed, try the axis at the current index and check if the orientation is correct
				if(i < numRows && axisOrientation == props[i][%axisType])
					minimum = props[i][%minimum]
					maximum = props[i][%maximum]
					logMode = props[i][%logMode]
				else
					continue
				endif
			else
				ASSERT(0, "Unknown mode from AxisPropModeConstants for this function")
			endif
		endif

		if(IsFinite(minimum) && IsFinite(maximum))
			SetAxis/W=$graph $axis, minimum, maximum
		endif

		ModifyGraph/W=$graph log($axis)=logMode
	endfor
End

/// @brief Returns the next axis name in a row of *consecutive*
/// and already existing axis names
Function/S GetNextFreeAxisName(graph, axesBaseName)
	string graph, axesBaseName

	variable numAxes

	numAxes = ItemsInList(ListMatch(AxisList(graph), axesBaseName + "*"))

	return axesBaseName + num2str(numAxes)
End

/// @brief Return a unique axis name
Function/S GetUniqueAxisName(graph, axesBaseName)
	string graph, axesBaseName

	variable numAxes, count, i
	string list, axis

	list = AxisList(graph)
	axis = axesBaseName

	for(i = 0; i < 10000; i += 1)
		if(WhichListItem(axis, list) == -1)
			return axis
		endif

		axis = axesBaseName + num2str(count++)
	endfor

	ASSERT(0, "Could not find a free axis name")
End

/// @brief Generic wrapper for setting a control's value
/// pass in the value as a string, and then decide whether to change to a number based on the type of control
Function SetGuiControlValue(win, control, value)
	string win, control
	string value

	variable controlType, variableType
	string recMacro

	[recMacro, controlType] = GetRecreationMacroAndType(win, control)

	if(controlType == CONTROL_TYPE_CHECKBOX)
		SetCheckBoxState(win, control, str2num(value))
	elseif(controlType == CONTROL_TYPE_SETVARIABLE)
		variableType = GetInternalSetVariableType(recMacro)
		if(variableType == SET_VARIABLE_BUILTIN_STR)
			SetSetVariableString(win, control, value)
		elseif(variableType == SET_VARIABLE_BUILTIN_NUM)
			SetSetVariable(win, control, str2num(value))
		else
			ASSERT(0, "SetVariable globals are not supported")
		endif
	elseif(controlType == CONTROL_TYPE_POPUPMENU)
		SetPopupMenuIndex(win, control, str2num(value))
	elseif(controlType == CONTROL_TYPE_SLIDER)
		Slider $control, win = $win, value = str2num(value)
	else
		ASSERT(0, "Unsupported control type") // if I get this, something's really gone pear shaped
	endif
End

/// @brief Generic wrapper for getting a control's value
Function/S GetGuiControlValue(win, control)
	string win, control

	string value
	variable controlType, variableType

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	controlType = abs(V_flag)

	if(controlType == CONTROL_TYPE_CHECKBOX)
		value = num2str(GetCheckBoxState(win, control))
	elseif(controlType == CONTROL_TYPE_SLIDER)
		value = num2str(V_value)
	elseif(controlType == CONTROL_TYPE_SETVARIABLE)
		variableType = GetInternalSetVariableType(S_recreation)
		if(variableType == SET_VARIABLE_BUILTIN_STR)
			value = GetSetVariableString(win, control)
		elseif(variableType == SET_VARIABLE_BUILTIN_NUM)
			value = num2str(GetSetVariable(win, control))
		else
			ASSERT(0, "SetVariable globals are not supported")
		endif
	elseif(controlType == CONTROL_TYPE_POPUPMENU)
		value = num2str(GetPopupMenuIndex(win, control))
	elseif(controlType == CONTROL_TYPE_TAB)
		value = num2istr(V_value)
	else
		value = ""
	endif

	return value
End

/// @brief Generic wrapper for getting a controls state (enabled, hidden, disabled)
Function/S GetGuiControlState(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	return num2str(V_disable)
End

/// @brief Generic wrapper for setting a controls state (enabled, hidden, disabled)
Function SetGuiControlState(win, control, controlState)
	string win, control
	string controlState
	variable controlType

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	ModifyControl $control, win=$win, disable=str2num(controlState)
End

/// @brief Return one if the given control is disabled,
/// zero otherwise
Function IsControlDisabled(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	return V_disable & DISABLE_CONTROL_BIT
End

/// @brief Return one if the given control is hidden,
/// zero otherwise
Function IsControlHidden(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")

	return V_disable & HIDDEN_CONTROL_BIT
End

/// @brief Return the main window name from a full subwindow specification
///
/// @param subwindow window name including subwindows, e.g. `panel#subWin1#subWin2`
Function/S GetMainWindow(subwindow)
	string subwindow

	return StringFromList(0, subwindow, "#")
End

/// @brief Return the currently active window
Function/S GetCurrentWindow()

	GetWindow kwTopWin activesw
	return s_value
End

/// @brief Return a 1D text wave with all infos about the cursors
///
/// Returns an invalid wave reference when no cursors are present. Counterpart
/// to RestoreCursors().
///
/// The data is sorted like `CURSOR_NAMES`.
Function/WAVE GetCursorInfos(graph)
	string graph

	Make/T/FREE/N=(ItemsInList(CURSOR_NAMES)) wv = CsrInfo($StringFromList(p, CURSOR_NAMES), graph)

	if(!HasOneValidEntry(wv))
		return $""
	endif

	return wv
End

/// @brief Restore the cursors from the info of GetCursorInfos().
Function RestoreCursors(graph, cursorInfos)
	string graph
	WAVE/T/Z cursorInfos

	string traceList, cursorTrace, info, replacementTrace
	variable i, numEntries, numTraces

	if(!WaveExists(cursorInfos))
		return NaN
	endif

	traceList = TraceNameList(graph, ";", 0 + 1)
	numTraces = ItemsInList(traceList)

	if(numTraces == 0)
		return NaN
	endif

	numEntries = DimSize(cursorInfos, ROWS)
	for(i = 0; i < numEntries; i += 1)
		info = cursorInfos[i]

		if(IsEmpty(info)) // cursor was not active
			continue
		endif

		cursorTrace = StringByKey("TNAME", info)

		if(FindListItem(cursorTrace, traceList) == -1)
			// trace is not present anymore, use the first one instead
			replacementTrace = StringFromList(0, traceList)
			info = ReplaceWordInString(cursorTrace, info, replacementTrace)
		endif

		Execute StringByKey("RECREATION", info)
	endfor
End

/// @brief Return the infos for all annotations on the graph
Function/WAVE GetAnnotationInfo(string graph)

	variable numEntries
	string annotations

	annotations = AnnotationList(graph)
	numEntries = ItemsInList(annotations)

	if(numEntries == 0)
		return $""
	endif

	Make/FREE/N=(numEntries)/T annoInfo = AnnotationInfo(graph, StringFromList(p, annotations))

	SetDimensionLabels(annoInfo, annotations, ROWS)

	return annoInfo
End

/// @brief Restore annotation positions
Function RestoreAnnotationPositions(string graph, WAVE/T annoInfo)

	variable i, idx, numEntries, xPos, yPos
	string annotations, name, infoStr, flags, anchor

	annotations = AnnotationList(graph)
	numEntries = ItemsInList(annotations)

	if(numEntries == 0)
		return NaN
	endif

	for(i = 0; i < numEntries; i += 1)

		name = StringFromList(i, annotations)
		idx = FindDimLabel(annoInfo, ROWS, name)

		if(idx < 0)
			continue
		endif

		infoStr = annoInfo[idx]

		flags = StringByKey("FLAGS", infoStr)

		xPos   = NumberByKey("X", flags, "=", "/")
		yPos   = NumberByKey("Y", flags, "=", "/")
		anchor = StringByKey("A", flags, "=", "/")

		TextBox/W=$graph/N=$name/C/X=(xPos)/Y=(yPos)/A=$anchor
	endfor
End

/// @brief Autoscale all vertical axes in the visible x range
Function AutoscaleVertAxisVisXRange(graph)
	string graph

	string axList, axis
	variable i, numAxes, axisOrient

	axList = AxisList(graph)
	numAxes = ItemsInList(axList)
	for(i = 0; i < numAxes; i += 1)
		axis = StringFromList(i, axList)

		axisOrient = GetAxisOrientation(graph, axis)
		if(axisOrient == AXIS_ORIENTATION_LEFT || axisOrient == AXIS_ORIENTATION_RIGHT)
			SetAxis/W=$graph/A=2 $axis
		endif
	endfor
End

/// @brief Return the type of the variable of the SetVariable control
///
/// @return one of @ref GetInternalSetVariableTypeReturnTypes
Function GetInternalSetVariableType(recMacro)
	string recMacro

	ASSERT(strsearch(recMacro, "SetVariable", 0) != -1, "recreation macro is not from a SetVariable")

	variable builtinString = (strsearch(recMacro, "_STR:\"", 0) != -1)
	variable builtinNumber = (strsearch(recMacro, "_NUM:", 0) != -1)

	ASSERT(builtinString + builtinNumber != 2, "SetVariable can not hold both numeric and string contents")

	if(builtinString)
		return SET_VARIABLE_BUILTIN_STR
	elseif(builtinNumber)
		return SET_VARIABLE_BUILTIN_NUM
	endif

	return SET_VARIABLE_GLOBAL
End

Function ExtractLimitsFromRecMacro(string recMacro, variable& minVal, variable& maxVal, variable& incVal)
	string minStr, maxStr, incStr

	minVal = NaN
	maxVal = NaN
	incVal = NaN

	SplitString/E="(?i).*limits={([^,]+),([^,]+),([^,]+)}.*" recMacro, minStr, maxStr, incStr

	if(V_flag != 3)
		return 1
	endif

	minVal = str2num(minStr)
	maxVal = str2num(maxStr)
	incVal = str2num(incStr)

	return 0
End

/// @brief Extract the limits specification of the control and return it in `minVal`, `maxVal` and `incVal`
///
/// @return 0 on success, 1 if no specification could be found
///
/// @sa ExtractLimitsFromRecMacro for a faster way if you already have the recreation macro
Function ExtractLimits(string win, string control, variable& minVal, variable& maxVal, variable& incVal)
	string minStr, maxStr, incStr

	string recMacro
	variable controlType
	[recMacro, controlType] = GetRecreationMacroAndType(win, control)

	return ExtractLimitsFromRecMacro(recMacro, minVal, maxVal, incVal)
End

/// @brief Check if the given value is inside the limits defined by the control
///
/// @return - 0: outside limits
///         - 1: inside limits, i.e. val lies in the range [min, max]
///         - NaN: no limits could be found
///
Function CheckIfValueIsInsideLimits(win, control, val)
	string win, control
	variable val

	variable minVal, maxVal, incVal

	if(ExtractLimits(win, control, minVal, maxVal, incVal))
		return NaN
	endif

	return val >= minVal && val <= maxVal
End

/// @brief Returns a value that is constrained by the limits defined by the control
///
/// @return val <= control max and val >= contorl min
Function GetLimitConstrainedSetVar(string recMacro, variable val)

	variable minVal, maxVal, incVal
	if(!ExtractLimitsFromRecMacro(recMacro, minVal, maxVal, incVal))
		val = limit(val, minVal, maxVal)
	endif

	return val
End

/// @brief Return the parameter type a function parameter
///
/// @param func       name of the function
/// @param paramIndex index of the parameter
Function GetFunctionParameterType(func, paramIndex)
	string func
	variable paramIndex

	string funcInfo, param
	variable numParams

	funcInfo = FunctionInfo(func, "")

	ASSERT(paramIndex < NumberByKey("N_PARAMS", funcInfo), "Requested parameter number does not exist.")
	sprintf param, "PARAM_%d_TYPE", paramIndex

	return NumberByKey(param, funcInfo)
End

/// @brief Return an entry from the given recreation macro
///
/// The recreation macro of a single GUI control looks like:
/// \rst
/// .. code-block:: igorpro
///
///		PopupMenu popup_ctrl,pos={1.00,1.00},size={55.00,19.00},proc=PGCT_PopMenuProc
///		PopupMenu popup_ctrl,mode=1,popvalue="Entry1",value= #"\"Entry1;Entry2;Entry3\""
/// \endrst
///
/// This function allows to extract key/value pairs from it.
///
/// @param key      non-empty string (must be followed by `=` in the recreation macro)
/// @param recMacro GUI control recreation macro as returned by `ControlInfo`
Function/S GetValueFromRecMacro(key, recMacro)
	string key, recMacro

	variable last, first
	variable comma, cr
	string procedure

	ASSERT(!IsEmpty(key), "Invalid key")

	key += "="

	first = strsearch(recMacro, key, 0)

	if(first == -1)
		return ""
	endif

	comma = strsearch(recMacro, ",", first + 1)
	cr    = strsearch(recMacro, "\r", first + 1)

	if(comma > 0 && cr > 0)
		last = min(comma, cr)
	elseif(comma == -1)
		last = cr
	elseif(cr == -1)
		last = comma
	else
		ASSERT(0, "impossible case")
	endif

	procedure = recMacro[first + strlen(key), last - 1]

	return procedure
End

/// @brief Search for invalid control procedures in the given panel or graph
///
/// Searches recursively in all subwindows.
///
/// @param win         panel or graph
/// @param warnOnEmpty [optional, default to false] print out controls which don't have a control procedure
///                    but can have one.
///
/// @returns 1 on error, 0 if everything is fine.
Function SearchForInvalidControlProcs(win, [warnOnEmpty])
	string win
	variable warnOnEmpty

	string controlList, control, controlProc
	string subTypeStr, helpEntry, recMacro
	variable result, numEntries, i, subType, controlType
	string funcList, subwindowList, subwindow

	if(!windowExists(win))
		printf "SearchForInvalidControlProcs: Panel \"%s\" does not exist.\r", win
		ControlWindowToFront()
		return 1
	endif

	if(ParamIsDefault(warnOnEmpty))
		warnOnEmpty = 0
	else
		warnOnEmpty = !!	warnOnEmpty
	endif

	if(WinType(win) != 7 && WinType(win) != 1) // ignore everything except panels and graphs
		return 0
	endif

	subwindowList = ChildWindowList(win)
	numEntries = ItemsInList(subwindowList)
	for(i = 0; i < numEntries; i += 1)
		subwindow = win + "#" + StringFromList(i, subWindowList)
		result = result || SearchForInvalidControlProcs(subwindow, warnOnEmpty = warnOnEmpty)
	endfor

	funcList    = FunctionList("*", ";", "NPARAMS:1,KIND:2")
	controlList = ControlNameList(win)
	numEntries  = ItemsInList(controlList)

	for(i = 0; i < numEntries; i += 1)
		control = StringFromList(i, controlList)

		[recMacro, controlType] = GetRecreationMacroAndType(win, control)

		if(controlType == CONTROL_TYPE_VALDISPLAY || controlType == CONTROL_TYPE_GROUPBOX)
			continue
		endif

		helpEntry = GetValueFromRecMacro("help", recMacro)

		if(IsEmpty(helpEntry))
			printf "SearchForInvalidControlProcs: Panel \"%s\" has the control \"%s\" which does not have a help entry.\r", win, control
		endif

		controlProc = GetValueFromRecMacro(REC_MACRO_PROCEDURE, recMacro)

		if(IsEmpty(controlProc))
			if(warnOnEmpty)
				printf "SearchForInvalidControlProcs: Panel \"%s\" has the control \"%s\" which does not have a GUI procedure.\r", win, control
			endif
			continue
		endif

		if(WhichListItem(controlProc, funcList, ";", 0, 0) == -1)
			printf "SearchForInvalidControlProcedures: Panel \"%s\" has the control \"%s\" which refers to the non-existing GUI procedure \"%s\".\r", win, control, controlProc
			ControlWindowToFront()
			result = 1
			continue
		endif

		subTypeStr = StringByKey("SUBTYPE", FunctionInfo(controlProc))
		subType    = GetNumericSubType(subTypeStr)
		ControlInfo/W=$win $control

		if(abs(V_Flag) != subType)
			printf "SearchForInvalidControlProcs: Panel \"%s\" has the control \"%s\" which refers to the GUI procedure \"%s\" which is of an incorrect subType \"%s\".\r", win, control, controlProc, subTypeStr
			ControlWindowToFront()
			result = 1
			continue
		endif
	endfor

	if(!result)
		printf "Congratulations! Panel \"%s\" references only valid GUI control procedures.\r", win
	endif

	return result
End

/// @brief Convert the function subType names for GUI control procedures
///        to a numeric value as used by `ControlInfo`
Function GetNumericSubType(subType)
	string subType

	strswitch(subType)
		case "ButtonControl":
			return CONTROL_TYPE_BUTTON
			break
		case "CheckBoxControl":
			return CONTROL_TYPE_CHECKBOX
			break
		case "ListBoxControl":
			return CONTROL_TYPE_LISTBOX
			break
		case "PopupMenuControl":
			return CONTROL_TYPE_POPUPMENU
			break
		case "SetVariableControl":
			return CONTROL_TYPE_SETVARIABLE
			break
		case "SliderControl":
			return CONTROL_TYPE_SLIDER
			break
		case "TabControl":
			return CONTROL_TYPE_TAB
			break
		default:
			ASSERT(0, "Unsupported control subType")
			break
	endswitch
End

/// @brief Return the numeric control type
///
/// @return one of @ref GUIControlTypes
Function GetControlType(win, control)
	string win, control

	ControlInfo/W=$win $control
	ASSERT(V_flag != 0, "Non-existing control or window")
	return abs(V_flag)
End

/// @brief Determines if control stores numeric or text data
Function DoesControlHaveInternalString(string recMacro)
	return strsearch(recMacro, "_STR:", 0) != -1
End

/// @brief Returns checkbox mode
Function GetCheckBoxMode(win, checkBoxName)
	string win, checkBoxName

	variable first, mode
	string modeString
	ControlInfo/W=$win $checkBoxName
	ASSERT(V_flag == 2, "not a checkBox control")
	first = strsearch(S_recreation, "mode=", 0,2)
	if(first == -1)
		return 0
	else
		sscanf S_recreation[first, first + 5], "mode=%d", mode
	endif
	ASSERT(IsFinite(mode), "Unexpected checkbox mode")
	return mode
End

/// @brief Returns the selected row of the ListBox for some modes
///        without selection waves
Function GetListBoxSelRow(win, ctrl)
	string win, ctrl

	ControlInfo/W=$win $ctrl
	ASSERT(V_flag == 11, "Not a listbox control")

	return V_Value
End

/// @brief Check if the location `loc` is inside the rectangle `r`
Function IsInsideRect(loc, r)
	STRUCT Point& loc
	STRUCT RectF& r

	return loc.h >= r.left      \
		   && loc.h <= r.right  \
		   && loc.v >= r.top    \
		   && loc.v <= r.bottom
End

/// @brief Return the coordinates of the control borders
///        relative to the top left corner in pixels
Function GetControlCoordinates(win, ctrl, s)
	string win, ctrl
	STRUCT RectF& s

	ControlInfo/W=$win $ctrl
	ASSERT(V_flag != 0, "Not an existing control")

	s.top    = V_top
	s.bottom = V_top + V_height
	s.left   = V_left
	s.right  = V_left + V_width
End

/// @brief Get the text (plain or formatted) from the notebook
Function/S GetNotebookText(string win, [variable mode])

	ASSERT(WinType(win) == 5, "Passed win is not a notebook")

	if(ParamIsDefault(mode))
		mode = 1
	endif

	Notebook $win getData=mode

	return S_Value
End

/// @brief Replace the contents of the notebook
Function ReplaceNotebookText(win, text)
	string win, text

	ASSERT(WinType(win) == 5, "Passed win is not a notebook")

	Notebook $win selection={startOfFile, endOfFile}
	ASSERT(!V_Flag, "Illegal selection")

	Notebook $win setData=text
End

/// @brief Append to a notebook
Function AppendToNotebookText(win, text)
	string win, text

	ASSERT(WinType(win) == 5, "Passed win is not a notebook")

	Notebook $win selection={endOfFile, endOfFile}
	ASSERT(!V_Flag, "Illegal selection")

	Notebook $win setData=text
End

/// @brief Select the end in the given notebook.
///
/// The selection is the place where the user would naïvely enter new text.
Function NotebookSelectionAtEnd(win)
	string win

	ASSERT(WinType(win) == 5, "Passed win is not a notebook")

	Notebook $win selection={endOfFile,endOfFile}, findText={"",1}
End

/// @brief Retrieves named userdata keys from a recreation macro string
///
/// @param recMacro recreation macro string
///
/// @returns Textwave with all unqiue entries or `$""` if nothing could be found.
Function/WAVE GetUserdataKeys(string recMacro)

	variable pos1, pos2, count
	variable prefixLength = strlen(USERDATA_PREFIX)

	Make/T/FREE userKeys

	do
		pos1 = strsearch(recMacro, USERDATA_PREFIX, pos1)

		if(pos1 == -1)
			break
		endif

		pos2 = strsearch(recMacro, USERDATA_SUFFIX, pos1)
		ASSERT(pos2 != -1, "Invalid recreation macro")

		EnsureLargeEnoughWave(userKeys, minimumSize = count)
		userKeys[count++] = recMacro[pos1 + prefixLength, pos2 - 1]

		pos1 = pos2
	while(1)

	if(count == 0)
		return $""
	endif

	Redimension/N=(count) userKeys

	return GetUniqueEntries(userKeys)
End

/// @brief Converts an Igor control type number to control name
///
/// @param ctrlType ctrl type of Igor control
/// @returns Igor name of control type
Function/S ControlTypeToName(ctrlType)
	variable ctrlType

	variable pos
	if(numtype(ctrlType) == 2)
		return ""
	endif
	pos = WhichListItem(num2str(abs(ctrlType)), EXPCONFIG_GUI_CTRLTYPES)
	if(pos < 0)
	  return ""
	endif
	return StringFromList(pos, EXPCONFIG_GUI_CTRLLIST)
End

/// @brief Converts an Igor control name to control type number
///
/// @param ctrlName Name of Igor control
/// @returns Igor control type number
Function Name2ControlType(ctrlName)
	string ctrlName

	variable pos
	pos = WhichListItem(ctrlName, EXPCONFIG_GUI_CTRLLIST)
	if(pos < 0)
	  return NaN
	endif
	return str2num(StringFromList(pos, EXPCONFIG_GUI_CTRLTYPES))
End

/// @brief Checks if a certain window can act as valid host for subwindows
///        developer note: The only integrated Igor function that does this is ChildWindowList.
///        Though, ChildWindowList generates an RTE for non-valid windows, where this check function does not.
///
/// @param wName window name that should be checked to be a valid host for subwindows
/// @returns 1 if window is a valid host, 0 otherwise
Function WindowTypeCanHaveChildren(wName)
	string wName

	Make/FREE/I typeCanHaveChildren = {WINTYPE_GRAPH, WINTYPE_PANEL}
	FindValue/I=(WinType(wName)) typeCanHaveChildren

	return V_value != -1
End

/// @brief Recursively build a list of windows, including all child
///        windows, starting with wName.
///
/// @param wName parent window name to start with
/// @return A string containing names of windows.  This list is a semicolon separated list.  It will include the window
///         wName and all of its children and children of children, etc.
Function/S GetAllWindows(wName)
	string wName

	string windowList = ""
	GetAllWindowsImpl(wName, windowList)

	return windowList
End

static Function GetAllWindowsImpl(wName, windowList)
	string wName
	string &windowList

	string children
	variable i, numChildren, err

	windowList = AddListItem(wName, windowList, ";", inf)

	if(!WindowTypeCanHaveChildren(wName))
		return NaN
	endif

	children = ChildWindowList(wName)
	numChildren = ItemsInList(children, ";")
	for(i = 0; i < numChildren; i += 1)
		GetAllWindowsImpl(wName + "#" + StringFromList(i, children, ";"), windowList)
	endfor
End

/// @brief Checks if a window is tagged as certain type
///
/// @param[in] device Window name to check
/// @param[in] typeTag one of PANELTAG_* constants @sa panelTags
/// returns 1 if window is a DA_Ephys panel
Function PanelIsType(device, typeTag)
	string device
	string typeTag

	if(!WindowExists(device))
		return 0
	endif

	return !CmpStr(GetUserData(device, "", EXPCONFIG_UDATA_PANELTYPE), typeTag)
End

/// @brief Show a contextual popup menu which allows the user to change the set variable limit's increment
///
/// - Expects the ctrl to have the named user data "DefaultIncrement"
/// - Works only on right mouse click on the title or the value field, *not* the up/down arrow buttons
Function ShowSetVariableLimitsSelectionPopup(sva)
	STRUCT WMSetVariableAction &sva

	string win, ctrl, items, defaultIncrementStr, elem
	variable minVal, maxVal, incVal, defaultIncrement, index

	win = sva.win
	ctrl = sva.ctrlName

	ASSERT(sva.eventCode == 9, "Unexpected event code")

	if(sva.eventMod != 16)
		// not the right mouse button
		return NaN
	endif

	if(sva.mousePart == 1 || sva.mousePart == 2)
		// clicked at the up/down arrow buttons
		return NaN
	endif

	defaultIncrementStr = GetUserData(win, ctrl, "DefaultIncrement")
	defaultIncrement = str2numSafe(defaultIncrementStr)
	ASSERT(IsFinite(defaultIncrement), "Missing DefaultIncrement user data")

	Make/D/FREE increments = {1e-3, 1e-2, 0.1, 1.0, 10, 1e2, 1e3}

	// find the default value or add it
	FindValue/V=(defaultIncrement) increments
	index = V_Value

	items = NumericWaveToList(increments, ";")

	if(index != -1)
		elem  = StringFromList(index, items)
		items = RemoveFromList(elem, items)
	else
		index = Inf
	endif

	items = AddListItem(defaultIncrementStr + " (default)", items, ";", index)

	// highlight the current value
	ExtractLimits(win, ctrl, minVal, maxVal, incVal)
	ASSERT(!IsNaN(minVal) && !IsNaN(maxVal) && !IsNaN(incVal), "Invalid limits")
	FindValue/V=(incVal) increments
	index = V_Value

	if(index != -1)
		elem  = StringFromList(index, items)
		items = RemoveFromList(elem, items)
		items = AddListItem("\\M1! " + elem, items, ";", index)
	endif

	PopupContextualMenu items
	if(V_flag != 0)
		SetSetVariableLimits(win, ctrl, minVal, maxVal, increments[V_flag - 1])
	endif
End

/// @brief Draw a scale bar on a graph
///
/// @param graph graph
/// @param x0                horizontal coordinate of first point
/// @param y0                vertical coordinate of first point
/// @param x1                horizontal coordinate of second point
/// @param y1                vertical coordinate of second point
/// @param unit              [optional] data unit when drawing the label
/// @param drawLength        [optional, defaults to false] true/false for outputting the label
/// @param labelOffset       [optional] offset in current coordinates of the label
/// @param newlineBeforeUnit [optional] Use a newline before the unit instead of a space
Function DrawScaleBar(string graph, variable x0, variable y0, variable x1, variable y1, [string unit, variable drawLength, variable labelOffset, variable newlineBeforeUnit])

	string msg, str
	variable length, xPos, yPos, subDigits

	if(ParamIsDefault(drawLength))
		drawLength = 0
	else
		drawLength = !!drawLength

		if(ParamIsDefault(unit))
			unit = ""
		endif

		if(ParamIsDefault(labelOffset))
			labelOffset = 0
		endif

		if(ParamIsDefault(newlineBeforeUnit))
			newlineBeforeUnit = 0
		endif
	endif

	sprintf msg, "(%g, %g), (%g, %g)\r", x0, y0, x1, y1
	DEBUGPRINT(msg)

	if(drawLength)

		if(x0 == x1)
			length = abs(y0 - y1)

			ASSERT(!IsEmpty(unit), "empty unit")
			subDigits = length > 1 ? 0 : abs(floor(log(length)/log(10)))
			sprintf str, "%.*f%s%s", subDigits, length, SelectString(newlineBeforeUnit, NUMBER_UNIT_SPACE, "\r"), unit

			xPos = x0 - labelOffset
			yPos = min(y0, y1) + abs(y0 - y1) / 2

			sprintf msg, "Text: (%g, %g)\r", xPos, yPos
			DEBUGPRINT(msg)

			SetDrawEnv/W=$graph textxjust = 2,textyjust = 1
		elseif(y0 == y1)
			length = abs(x0 - x1)

			ASSERT(!IsEmpty(unit), "empty unit")
			subDigits = length > 1 ? 0 : abs(floor(log(length)/log(10)))
			sprintf str, "%.*f%s%s", subDigits, length, SelectString(newlineBeforeUnit, NUMBER_UNIT_SPACE, "\r"), unit

			xPos = min(x0, x1) + abs(x0 - x1) / 2
			yPos = y0 - labelOffset

			sprintf msg, "Text: (%g, %g)\r", xPos, yPos
			DEBUGPRINT(msg)

			SetDrawEnv/W=$graph textxjust = 1,textyjust = 2
		else
			ASSERT(0, "Unexpected combination")
		endif

		DrawText/W=$graph xPos, yPos, str
	endif

	DrawLine/W=$graph x0, y0, x1, y1
End

/// @brief Accelerated setting of multiple traces in a graph to un/hidden
//
/// @param[in] graph name of graph window
/// @param[in] w 1D text wave with trace names
/// @param[in] h number of traces in text wave
/// @param[in] s new hidden state
Function AccelerateHideTraces(string graph, WAVE/T w, variable h, variable s)

	variable step

	if(!h)
		return NaN
	endif

	s = !!s

	do
		step = min(2 ^ trunc(log(h) / log(2)), 112)
		h -= step
		switch(step)
			case 112:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s,hideTrace($w[h+4])=s,hideTrace($w[h+5])=s,hideTrace($w[h+6])=s,hideTrace($w[h+7])=s,hideTrace($w[h+8])=s,hideTrace($w[h+9])=s,hideTrace($w[h+10])=s,hideTrace($w[h+11])=s,hideTrace($w[h+12])=s,hideTrace($w[h+13])=s,hideTrace($w[h+14])=s,hideTrace($w[h+15])=s,hideTrace($w[h+16])=s,hideTrace($w[h+17])=s,hideTrace($w[h+18])=s,hideTrace($w[h+19])=s,hideTrace($w[h+20])=s,hideTrace($w[h+21])=s,hideTrace($w[h+22])=s,hideTrace($w[h+23])=s,hideTrace($w[h+24])=s,hideTrace($w[h+25])=s,hideTrace($w[h+26])=s,hideTrace($w[h+27])=s,hideTrace($w[h+28])=s,hideTrace($w[h+29])=s,hideTrace($w[h+30])=s,hideTrace($w[h+31])=s,hideTrace($w[h+32])=s,hideTrace($w[h+33])=s,hideTrace($w[h+34])=s,hideTrace($w[h+35])=s,hideTrace($w[h+36])=s,hideTrace($w[h+37])=s,hideTrace($w[h+38])=s,hideTrace($w[h+39])=s,hideTrace($w[h+40])=s,hideTrace($w[h+41])=s,hideTrace($w[h+42])=s,hideTrace($w[h+43])=s,hideTrace($w[h+44])=s,hideTrace($w[h+45])=s,hideTrace($w[h+46])=s,hideTrace($w[h+47])=s,hideTrace($w[h+48])=s,hideTrace($w[h+49])=s,hideTrace($w[h+50])=s,hideTrace($w[h+51])=s,hideTrace($w[h+52])=s,hideTrace($w[h+53])=s,hideTrace($w[h+54])=s,hideTrace($w[h+55])=s,hideTrace($w[h+56])=s,hideTrace($w[h+57])=s,hideTrace($w[h+58])=s,hideTrace($w[h+59])=s,hideTrace($w[h+60])=s,hideTrace($w[h+61])=s,hideTrace($w[h+62])=s,hideTrace($w[h+63])=s,hideTrace($w[h+64])=s,hideTrace($w[h+65])=s,hideTrace($w[h+66])=s,hideTrace($w[h+67])=s,hideTrace($w[h+68])=s,hideTrace($w[h+69])=s,hideTrace($w[h+70])=s,hideTrace($w[h+71])=s,hideTrace($w[h+72])=s,hideTrace($w[h+73])=s,hideTrace($w[h+74])=s,hideTrace($w[h+75])=s,hideTrace($w[h+76])=s,hideTrace($w[h+77])=s,hideTrace($w[h+78])=s,hideTrace($w[h+79])=s,hideTrace($w[h+80])=s,hideTrace($w[h+81])=s,hideTrace($w[h+82])=s,hideTrace($w[h+83])=s,hideTrace($w[h+84])=s,hideTrace($w[h+85])=s,hideTrace($w[h+86])=s,hideTrace($w[h+87])=s,hideTrace($w[h+88])=s,hideTrace($w[h+89])=s,hideTrace($w[h+90])=s,hideTrace($w[h+91])=s,hideTrace($w[h+92])=s,hideTrace($w[h+93])=s,hideTrace($w[h+94])=s,hideTrace($w[h+95])=s,hideTrace($w[h+96])=s,hideTrace($w[h+97])=s,hideTrace($w[h+98])=s,hideTrace($w[h+99])=s,hideTrace($w[h+100])=s,hideTrace($w[h+101])=s,hideTrace($w[h+102])=s,hideTrace($w[h+103])=s,hideTrace($w[h+104])=s,hideTrace($w[h+105])=s,hideTrace($w[h+106])=s,hideTrace($w[h+107])=s,hideTrace($w[h+108])=s,hideTrace($w[h+109])=s,hideTrace($w[h+110])=s,hideTrace($w[h+111])=s
				break
			case 64:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s,hideTrace($w[h+4])=s,hideTrace($w[h+5])=s,hideTrace($w[h+6])=s,hideTrace($w[h+7])=s,hideTrace($w[h+8])=s,hideTrace($w[h+9])=s,hideTrace($w[h+10])=s,hideTrace($w[h+11])=s,hideTrace($w[h+12])=s,hideTrace($w[h+13])=s,hideTrace($w[h+14])=s,hideTrace($w[h+15])=s,hideTrace($w[h+16])=s,hideTrace($w[h+17])=s,hideTrace($w[h+18])=s,hideTrace($w[h+19])=s,hideTrace($w[h+20])=s,hideTrace($w[h+21])=s,hideTrace($w[h+22])=s,hideTrace($w[h+23])=s,hideTrace($w[h+24])=s,hideTrace($w[h+25])=s,hideTrace($w[h+26])=s,hideTrace($w[h+27])=s,hideTrace($w[h+28])=s,hideTrace($w[h+29])=s,hideTrace($w[h+30])=s,hideTrace($w[h+31])=s,hideTrace($w[h+32])=s,hideTrace($w[h+33])=s,hideTrace($w[h+34])=s,hideTrace($w[h+35])=s,hideTrace($w[h+36])=s,hideTrace($w[h+37])=s,hideTrace($w[h+38])=s,hideTrace($w[h+39])=s,hideTrace($w[h+40])=s,hideTrace($w[h+41])=s,hideTrace($w[h+42])=s,hideTrace($w[h+43])=s,hideTrace($w[h+44])=s,hideTrace($w[h+45])=s,hideTrace($w[h+46])=s,hideTrace($w[h+47])=s,hideTrace($w[h+48])=s,hideTrace($w[h+49])=s,hideTrace($w[h+50])=s,hideTrace($w[h+51])=s,hideTrace($w[h+52])=s,hideTrace($w[h+53])=s,hideTrace($w[h+54])=s,hideTrace($w[h+55])=s,hideTrace($w[h+56])=s,hideTrace($w[h+57])=s,hideTrace($w[h+58])=s,hideTrace($w[h+59])=s,hideTrace($w[h+60])=s,hideTrace($w[h+61])=s,hideTrace($w[h+62])=s,hideTrace($w[h+63])=s
				break
			case 32:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s,hideTrace($w[h+4])=s,hideTrace($w[h+5])=s,hideTrace($w[h+6])=s,hideTrace($w[h+7])=s,hideTrace($w[h+8])=s,hideTrace($w[h+9])=s,hideTrace($w[h+10])=s,hideTrace($w[h+11])=s,hideTrace($w[h+12])=s,hideTrace($w[h+13])=s,hideTrace($w[h+14])=s,hideTrace($w[h+15])=s,hideTrace($w[h+16])=s,hideTrace($w[h+17])=s,hideTrace($w[h+18])=s,hideTrace($w[h+19])=s,hideTrace($w[h+20])=s,hideTrace($w[h+21])=s,hideTrace($w[h+22])=s,hideTrace($w[h+23])=s,hideTrace($w[h+24])=s,hideTrace($w[h+25])=s,hideTrace($w[h+26])=s,hideTrace($w[h+27])=s,hideTrace($w[h+28])=s,hideTrace($w[h+29])=s,hideTrace($w[h+30])=s,hideTrace($w[h+31])=s
				break
			case 16:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s,hideTrace($w[h+4])=s,hideTrace($w[h+5])=s,hideTrace($w[h+6])=s,hideTrace($w[h+7])=s,hideTrace($w[h+8])=s,hideTrace($w[h+9])=s,hideTrace($w[h+10])=s,hideTrace($w[h+11])=s,hideTrace($w[h+12])=s,hideTrace($w[h+13])=s,hideTrace($w[h+14])=s,hideTrace($w[h+15])=s
				break
			case 8:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s,hideTrace($w[h+4])=s,hideTrace($w[h+5])=s,hideTrace($w[h+6])=s,hideTrace($w[h+7])=s
				break
			case 4:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s,hideTrace($w[h+2])=s,hideTrace($w[h+3])=s
				break
			case 2:
				ModifyGraph/W=$graph hideTrace($w[h])=s,hideTrace($w[h+1])=s
				break
			case 1:
				ModifyGraph/W=$graph hideTrace($w[h])=s
				break
			default:
				ASSERT(0, "Fail")
				break
		endswitch
	while(h)
End

static Constant ACCELERATE_MAX = 1024

#if 0

/// ModifyGraph keyword expects a plain number
static Constant GEN_TYPE_NUMBER = 0x1
/// ModifyGraph keyword expects multiple entries (A, B, ...)
/// numEntryCols denotes how many entries are inside (..)
static Constant GEN_TYPE_WAVE   = 0x2

/// Generate code for ModifyGraph acceleration, needs whitespace cleanup
Function GenerateAcceleratedModifyGraphCase()

	variable i

	// BEGIN CHANGE ME
	variable power = 10
	/// @todo workaround IP bug as we can't break the line after rgb but only after hideTrace #4375
	Make/FREE/T keyword    = {"rgb", "hideTrace"}
	Make/FREE type         = {GEN_TYPE_WAVE, GEN_TYPE_NUMBER}
	Make/FREE numEntryCols = {4, NaN}
	// END CHANGE ME

	for(i = power; i >= 0; i -= 1)
		GenerateAcceleratedModifyGraphCaseImpl(keyword, i, type, numEntryCols)
	endfor
End

static Function/S GenerateValueString(variable type, variable keywordIndex, variable numEntryCols, string indexStr)

	variable i
	string result = "("
	string str

	switch(type)
		case GEN_TYPE_NUMBER:
			sprintf str, "(s%d[h%s])", keywordIndex, indexStr

			result = str
			break
		case GEN_TYPE_WAVE:
			for(i = 0; i < numEntryCols; i += 1)
				sprintf str "s%d[h%s][%d]%s", keywordIndex, indexStr, i, SelectString(i < numEntryCols - 1, "", ",")
				result += str
			endfor

			result += ")"
			break
		default:
			ASSERT(0, "Unknown type")
	endswitch

	return result
End

static Function GenerateAcceleratedModifyGraphCaseImpl(WAVE/T keyword, variable power, WAVE type, WAVE numEntryCols)

	string indexStr
	variable i, j, numEntries, numKeywords

	numEntries  = 2^(power)
	numKeywords = DimSize(keyword, ROWS)

	printf "case %d:\r", numEntries
	printf "ModifyGraph/W=$graph \\\r"

	for(i = 0; i < numEntries; i += 1)

		if(i == 0)
			printf " "
		else
			printf ","
		endif

		sprintf indexStr, "+% 5d", i
		indexStr = ReplaceString("+", indexStr, " + ")
		for(j = 0; j < numKeywords; j += 1)
			printf "%s($w[h%s])=%s", keyword[j], indexStr, GenerateValueString(type[j], j, numEntryCols[j], indexStr)

			if(j < numKeywords - 1)
				printf ","
			endif
		endfor

		if(mod(i + 1, 8) == 0)
			if(i + 1 != numEntries)
				printf " \\"
			endif

			printf "\r"
		endif
	endfor

	printf "\r\tbreak\r"
End

#endif

/// @brief Accelerated setting of multiple traces in a graph to un/hidden with per trace hide state
///
/// See GenerateAcceleratedModifyGraphCase() for how to generate the code between `BEGIN/END AUTOMATED CODE`.
///
/// @param[in] graph name of graph window
/// @param[in] w 1D text wave with trace names
/// @param[in] h number of traces in text wave
/// @param[in] s new hidden state
Function AccelerateHideTracesPerTrace(string graph, WAVE/T w, variable h, WAVE s)

	variable step

	if(!h)
		return NaN
	endif

	do
		step = min(2 ^ trunc(log(h) / log(2)), ACCELERATE_MAX)
		h -= step
		switch(step)
			// BEGIN AUTOMATED CODE
			case ACCELERATE_MAX:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]\
				,hideTrace($w[h +    32])=s[h +    32],hideTrace($w[h +    33])=s[h +    33],hideTrace($w[h +    34])=s[h +    34],hideTrace($w[h +    35])=s[h +    35],hideTrace($w[h +    36])=s[h +    36],hideTrace($w[h +    37])=s[h +    37],hideTrace($w[h +    38])=s[h +    38],hideTrace($w[h +    39])=s[h +    39]\
				,hideTrace($w[h +    40])=s[h +    40],hideTrace($w[h +    41])=s[h +    41],hideTrace($w[h +    42])=s[h +    42],hideTrace($w[h +    43])=s[h +    43],hideTrace($w[h +    44])=s[h +    44],hideTrace($w[h +    45])=s[h +    45],hideTrace($w[h +    46])=s[h +    46],hideTrace($w[h +    47])=s[h +    47]\
				,hideTrace($w[h +    48])=s[h +    48],hideTrace($w[h +    49])=s[h +    49],hideTrace($w[h +    50])=s[h +    50],hideTrace($w[h +    51])=s[h +    51],hideTrace($w[h +    52])=s[h +    52],hideTrace($w[h +    53])=s[h +    53],hideTrace($w[h +    54])=s[h +    54],hideTrace($w[h +    55])=s[h +    55]\
				,hideTrace($w[h +    56])=s[h +    56],hideTrace($w[h +    57])=s[h +    57],hideTrace($w[h +    58])=s[h +    58],hideTrace($w[h +    59])=s[h +    59],hideTrace($w[h +    60])=s[h +    60],hideTrace($w[h +    61])=s[h +    61],hideTrace($w[h +    62])=s[h +    62],hideTrace($w[h +    63])=s[h +    63]\
				,hideTrace($w[h +    64])=s[h +    64],hideTrace($w[h +    65])=s[h +    65],hideTrace($w[h +    66])=s[h +    66],hideTrace($w[h +    67])=s[h +    67],hideTrace($w[h +    68])=s[h +    68],hideTrace($w[h +    69])=s[h +    69],hideTrace($w[h +    70])=s[h +    70],hideTrace($w[h +    71])=s[h +    71]\
				,hideTrace($w[h +    72])=s[h +    72],hideTrace($w[h +    73])=s[h +    73],hideTrace($w[h +    74])=s[h +    74],hideTrace($w[h +    75])=s[h +    75],hideTrace($w[h +    76])=s[h +    76],hideTrace($w[h +    77])=s[h +    77],hideTrace($w[h +    78])=s[h +    78],hideTrace($w[h +    79])=s[h +    79]\
				,hideTrace($w[h +    80])=s[h +    80],hideTrace($w[h +    81])=s[h +    81],hideTrace($w[h +    82])=s[h +    82],hideTrace($w[h +    83])=s[h +    83],hideTrace($w[h +    84])=s[h +    84],hideTrace($w[h +    85])=s[h +    85],hideTrace($w[h +    86])=s[h +    86],hideTrace($w[h +    87])=s[h +    87]\
				,hideTrace($w[h +    88])=s[h +    88],hideTrace($w[h +    89])=s[h +    89],hideTrace($w[h +    90])=s[h +    90],hideTrace($w[h +    91])=s[h +    91],hideTrace($w[h +    92])=s[h +    92],hideTrace($w[h +    93])=s[h +    93],hideTrace($w[h +    94])=s[h +    94],hideTrace($w[h +    95])=s[h +    95]\
				,hideTrace($w[h +    96])=s[h +    96],hideTrace($w[h +    97])=s[h +    97],hideTrace($w[h +    98])=s[h +    98],hideTrace($w[h +    99])=s[h +    99],hideTrace($w[h +   100])=s[h +   100],hideTrace($w[h +   101])=s[h +   101],hideTrace($w[h +   102])=s[h +   102],hideTrace($w[h +   103])=s[h +   103]\
				,hideTrace($w[h +   104])=s[h +   104],hideTrace($w[h +   105])=s[h +   105],hideTrace($w[h +   106])=s[h +   106],hideTrace($w[h +   107])=s[h +   107],hideTrace($w[h +   108])=s[h +   108],hideTrace($w[h +   109])=s[h +   109],hideTrace($w[h +   110])=s[h +   110],hideTrace($w[h +   111])=s[h +   111]\
				,hideTrace($w[h +   112])=s[h +   112],hideTrace($w[h +   113])=s[h +   113],hideTrace($w[h +   114])=s[h +   114],hideTrace($w[h +   115])=s[h +   115],hideTrace($w[h +   116])=s[h +   116],hideTrace($w[h +   117])=s[h +   117],hideTrace($w[h +   118])=s[h +   118],hideTrace($w[h +   119])=s[h +   119]\
				,hideTrace($w[h +   120])=s[h +   120],hideTrace($w[h +   121])=s[h +   121],hideTrace($w[h +   122])=s[h +   122],hideTrace($w[h +   123])=s[h +   123],hideTrace($w[h +   124])=s[h +   124],hideTrace($w[h +   125])=s[h +   125],hideTrace($w[h +   126])=s[h +   126],hideTrace($w[h +   127])=s[h +   127]\
				,hideTrace($w[h +   128])=s[h +   128],hideTrace($w[h +   129])=s[h +   129],hideTrace($w[h +   130])=s[h +   130],hideTrace($w[h +   131])=s[h +   131],hideTrace($w[h +   132])=s[h +   132],hideTrace($w[h +   133])=s[h +   133],hideTrace($w[h +   134])=s[h +   134],hideTrace($w[h +   135])=s[h +   135]\
				,hideTrace($w[h +   136])=s[h +   136],hideTrace($w[h +   137])=s[h +   137],hideTrace($w[h +   138])=s[h +   138],hideTrace($w[h +   139])=s[h +   139],hideTrace($w[h +   140])=s[h +   140],hideTrace($w[h +   141])=s[h +   141],hideTrace($w[h +   142])=s[h +   142],hideTrace($w[h +   143])=s[h +   143]\
				,hideTrace($w[h +   144])=s[h +   144],hideTrace($w[h +   145])=s[h +   145],hideTrace($w[h +   146])=s[h +   146],hideTrace($w[h +   147])=s[h +   147],hideTrace($w[h +   148])=s[h +   148],hideTrace($w[h +   149])=s[h +   149],hideTrace($w[h +   150])=s[h +   150],hideTrace($w[h +   151])=s[h +   151]\
				,hideTrace($w[h +   152])=s[h +   152],hideTrace($w[h +   153])=s[h +   153],hideTrace($w[h +   154])=s[h +   154],hideTrace($w[h +   155])=s[h +   155],hideTrace($w[h +   156])=s[h +   156],hideTrace($w[h +   157])=s[h +   157],hideTrace($w[h +   158])=s[h +   158],hideTrace($w[h +   159])=s[h +   159]\
				,hideTrace($w[h +   160])=s[h +   160],hideTrace($w[h +   161])=s[h +   161],hideTrace($w[h +   162])=s[h +   162],hideTrace($w[h +   163])=s[h +   163],hideTrace($w[h +   164])=s[h +   164],hideTrace($w[h +   165])=s[h +   165],hideTrace($w[h +   166])=s[h +   166],hideTrace($w[h +   167])=s[h +   167]\
				,hideTrace($w[h +   168])=s[h +   168],hideTrace($w[h +   169])=s[h +   169],hideTrace($w[h +   170])=s[h +   170],hideTrace($w[h +   171])=s[h +   171],hideTrace($w[h +   172])=s[h +   172],hideTrace($w[h +   173])=s[h +   173],hideTrace($w[h +   174])=s[h +   174],hideTrace($w[h +   175])=s[h +   175]\
				,hideTrace($w[h +   176])=s[h +   176],hideTrace($w[h +   177])=s[h +   177],hideTrace($w[h +   178])=s[h +   178],hideTrace($w[h +   179])=s[h +   179],hideTrace($w[h +   180])=s[h +   180],hideTrace($w[h +   181])=s[h +   181],hideTrace($w[h +   182])=s[h +   182],hideTrace($w[h +   183])=s[h +   183]\
				,hideTrace($w[h +   184])=s[h +   184],hideTrace($w[h +   185])=s[h +   185],hideTrace($w[h +   186])=s[h +   186],hideTrace($w[h +   187])=s[h +   187],hideTrace($w[h +   188])=s[h +   188],hideTrace($w[h +   189])=s[h +   189],hideTrace($w[h +   190])=s[h +   190],hideTrace($w[h +   191])=s[h +   191]\
				,hideTrace($w[h +   192])=s[h +   192],hideTrace($w[h +   193])=s[h +   193],hideTrace($w[h +   194])=s[h +   194],hideTrace($w[h +   195])=s[h +   195],hideTrace($w[h +   196])=s[h +   196],hideTrace($w[h +   197])=s[h +   197],hideTrace($w[h +   198])=s[h +   198],hideTrace($w[h +   199])=s[h +   199]\
				,hideTrace($w[h +   200])=s[h +   200],hideTrace($w[h +   201])=s[h +   201],hideTrace($w[h +   202])=s[h +   202],hideTrace($w[h +   203])=s[h +   203],hideTrace($w[h +   204])=s[h +   204],hideTrace($w[h +   205])=s[h +   205],hideTrace($w[h +   206])=s[h +   206],hideTrace($w[h +   207])=s[h +   207]\
				,hideTrace($w[h +   208])=s[h +   208],hideTrace($w[h +   209])=s[h +   209],hideTrace($w[h +   210])=s[h +   210],hideTrace($w[h +   211])=s[h +   211],hideTrace($w[h +   212])=s[h +   212],hideTrace($w[h +   213])=s[h +   213],hideTrace($w[h +   214])=s[h +   214],hideTrace($w[h +   215])=s[h +   215]\
				,hideTrace($w[h +   216])=s[h +   216],hideTrace($w[h +   217])=s[h +   217],hideTrace($w[h +   218])=s[h +   218],hideTrace($w[h +   219])=s[h +   219],hideTrace($w[h +   220])=s[h +   220],hideTrace($w[h +   221])=s[h +   221],hideTrace($w[h +   222])=s[h +   222],hideTrace($w[h +   223])=s[h +   223]\
				,hideTrace($w[h +   224])=s[h +   224],hideTrace($w[h +   225])=s[h +   225],hideTrace($w[h +   226])=s[h +   226],hideTrace($w[h +   227])=s[h +   227],hideTrace($w[h +   228])=s[h +   228],hideTrace($w[h +   229])=s[h +   229],hideTrace($w[h +   230])=s[h +   230],hideTrace($w[h +   231])=s[h +   231]\
				,hideTrace($w[h +   232])=s[h +   232],hideTrace($w[h +   233])=s[h +   233],hideTrace($w[h +   234])=s[h +   234],hideTrace($w[h +   235])=s[h +   235],hideTrace($w[h +   236])=s[h +   236],hideTrace($w[h +   237])=s[h +   237],hideTrace($w[h +   238])=s[h +   238],hideTrace($w[h +   239])=s[h +   239]\
				,hideTrace($w[h +   240])=s[h +   240],hideTrace($w[h +   241])=s[h +   241],hideTrace($w[h +   242])=s[h +   242],hideTrace($w[h +   243])=s[h +   243],hideTrace($w[h +   244])=s[h +   244],hideTrace($w[h +   245])=s[h +   245],hideTrace($w[h +   246])=s[h +   246],hideTrace($w[h +   247])=s[h +   247]\
				,hideTrace($w[h +   248])=s[h +   248],hideTrace($w[h +   249])=s[h +   249],hideTrace($w[h +   250])=s[h +   250],hideTrace($w[h +   251])=s[h +   251],hideTrace($w[h +   252])=s[h +   252],hideTrace($w[h +   253])=s[h +   253],hideTrace($w[h +   254])=s[h +   254],hideTrace($w[h +   255])=s[h +   255]\
				,hideTrace($w[h +   256])=s[h +   256],hideTrace($w[h +   257])=s[h +   257],hideTrace($w[h +   258])=s[h +   258],hideTrace($w[h +   259])=s[h +   259],hideTrace($w[h +   260])=s[h +   260],hideTrace($w[h +   261])=s[h +   261],hideTrace($w[h +   262])=s[h +   262],hideTrace($w[h +   263])=s[h +   263]\
				,hideTrace($w[h +   264])=s[h +   264],hideTrace($w[h +   265])=s[h +   265],hideTrace($w[h +   266])=s[h +   266],hideTrace($w[h +   267])=s[h +   267],hideTrace($w[h +   268])=s[h +   268],hideTrace($w[h +   269])=s[h +   269],hideTrace($w[h +   270])=s[h +   270],hideTrace($w[h +   271])=s[h +   271]\
				,hideTrace($w[h +   272])=s[h +   272],hideTrace($w[h +   273])=s[h +   273],hideTrace($w[h +   274])=s[h +   274],hideTrace($w[h +   275])=s[h +   275],hideTrace($w[h +   276])=s[h +   276],hideTrace($w[h +   277])=s[h +   277],hideTrace($w[h +   278])=s[h +   278],hideTrace($w[h +   279])=s[h +   279]\
				,hideTrace($w[h +   280])=s[h +   280],hideTrace($w[h +   281])=s[h +   281],hideTrace($w[h +   282])=s[h +   282],hideTrace($w[h +   283])=s[h +   283],hideTrace($w[h +   284])=s[h +   284],hideTrace($w[h +   285])=s[h +   285],hideTrace($w[h +   286])=s[h +   286],hideTrace($w[h +   287])=s[h +   287]\
				,hideTrace($w[h +   288])=s[h +   288],hideTrace($w[h +   289])=s[h +   289],hideTrace($w[h +   290])=s[h +   290],hideTrace($w[h +   291])=s[h +   291],hideTrace($w[h +   292])=s[h +   292],hideTrace($w[h +   293])=s[h +   293],hideTrace($w[h +   294])=s[h +   294],hideTrace($w[h +   295])=s[h +   295]\
				,hideTrace($w[h +   296])=s[h +   296],hideTrace($w[h +   297])=s[h +   297],hideTrace($w[h +   298])=s[h +   298],hideTrace($w[h +   299])=s[h +   299],hideTrace($w[h +   300])=s[h +   300],hideTrace($w[h +   301])=s[h +   301],hideTrace($w[h +   302])=s[h +   302],hideTrace($w[h +   303])=s[h +   303]\
				,hideTrace($w[h +   304])=s[h +   304],hideTrace($w[h +   305])=s[h +   305],hideTrace($w[h +   306])=s[h +   306],hideTrace($w[h +   307])=s[h +   307],hideTrace($w[h +   308])=s[h +   308],hideTrace($w[h +   309])=s[h +   309],hideTrace($w[h +   310])=s[h +   310],hideTrace($w[h +   311])=s[h +   311]\
				,hideTrace($w[h +   312])=s[h +   312],hideTrace($w[h +   313])=s[h +   313],hideTrace($w[h +   314])=s[h +   314],hideTrace($w[h +   315])=s[h +   315],hideTrace($w[h +   316])=s[h +   316],hideTrace($w[h +   317])=s[h +   317],hideTrace($w[h +   318])=s[h +   318],hideTrace($w[h +   319])=s[h +   319]\
				,hideTrace($w[h +   320])=s[h +   320],hideTrace($w[h +   321])=s[h +   321],hideTrace($w[h +   322])=s[h +   322],hideTrace($w[h +   323])=s[h +   323],hideTrace($w[h +   324])=s[h +   324],hideTrace($w[h +   325])=s[h +   325],hideTrace($w[h +   326])=s[h +   326],hideTrace($w[h +   327])=s[h +   327]\
				,hideTrace($w[h +   328])=s[h +   328],hideTrace($w[h +   329])=s[h +   329],hideTrace($w[h +   330])=s[h +   330],hideTrace($w[h +   331])=s[h +   331],hideTrace($w[h +   332])=s[h +   332],hideTrace($w[h +   333])=s[h +   333],hideTrace($w[h +   334])=s[h +   334],hideTrace($w[h +   335])=s[h +   335]\
				,hideTrace($w[h +   336])=s[h +   336],hideTrace($w[h +   337])=s[h +   337],hideTrace($w[h +   338])=s[h +   338],hideTrace($w[h +   339])=s[h +   339],hideTrace($w[h +   340])=s[h +   340],hideTrace($w[h +   341])=s[h +   341],hideTrace($w[h +   342])=s[h +   342],hideTrace($w[h +   343])=s[h +   343]\
				,hideTrace($w[h +   344])=s[h +   344],hideTrace($w[h +   345])=s[h +   345],hideTrace($w[h +   346])=s[h +   346],hideTrace($w[h +   347])=s[h +   347],hideTrace($w[h +   348])=s[h +   348],hideTrace($w[h +   349])=s[h +   349],hideTrace($w[h +   350])=s[h +   350],hideTrace($w[h +   351])=s[h +   351]\
				,hideTrace($w[h +   352])=s[h +   352],hideTrace($w[h +   353])=s[h +   353],hideTrace($w[h +   354])=s[h +   354],hideTrace($w[h +   355])=s[h +   355],hideTrace($w[h +   356])=s[h +   356],hideTrace($w[h +   357])=s[h +   357],hideTrace($w[h +   358])=s[h +   358],hideTrace($w[h +   359])=s[h +   359]\
				,hideTrace($w[h +   360])=s[h +   360],hideTrace($w[h +   361])=s[h +   361],hideTrace($w[h +   362])=s[h +   362],hideTrace($w[h +   363])=s[h +   363],hideTrace($w[h +   364])=s[h +   364],hideTrace($w[h +   365])=s[h +   365],hideTrace($w[h +   366])=s[h +   366],hideTrace($w[h +   367])=s[h +   367]\
				,hideTrace($w[h +   368])=s[h +   368],hideTrace($w[h +   369])=s[h +   369],hideTrace($w[h +   370])=s[h +   370],hideTrace($w[h +   371])=s[h +   371],hideTrace($w[h +   372])=s[h +   372],hideTrace($w[h +   373])=s[h +   373],hideTrace($w[h +   374])=s[h +   374],hideTrace($w[h +   375])=s[h +   375]\
				,hideTrace($w[h +   376])=s[h +   376],hideTrace($w[h +   377])=s[h +   377],hideTrace($w[h +   378])=s[h +   378],hideTrace($w[h +   379])=s[h +   379],hideTrace($w[h +   380])=s[h +   380],hideTrace($w[h +   381])=s[h +   381],hideTrace($w[h +   382])=s[h +   382],hideTrace($w[h +   383])=s[h +   383]\
				,hideTrace($w[h +   384])=s[h +   384],hideTrace($w[h +   385])=s[h +   385],hideTrace($w[h +   386])=s[h +   386],hideTrace($w[h +   387])=s[h +   387],hideTrace($w[h +   388])=s[h +   388],hideTrace($w[h +   389])=s[h +   389],hideTrace($w[h +   390])=s[h +   390],hideTrace($w[h +   391])=s[h +   391]\
				,hideTrace($w[h +   392])=s[h +   392],hideTrace($w[h +   393])=s[h +   393],hideTrace($w[h +   394])=s[h +   394],hideTrace($w[h +   395])=s[h +   395],hideTrace($w[h +   396])=s[h +   396],hideTrace($w[h +   397])=s[h +   397],hideTrace($w[h +   398])=s[h +   398],hideTrace($w[h +   399])=s[h +   399]\
				,hideTrace($w[h +   400])=s[h +   400],hideTrace($w[h +   401])=s[h +   401],hideTrace($w[h +   402])=s[h +   402],hideTrace($w[h +   403])=s[h +   403],hideTrace($w[h +   404])=s[h +   404],hideTrace($w[h +   405])=s[h +   405],hideTrace($w[h +   406])=s[h +   406],hideTrace($w[h +   407])=s[h +   407]\
				,hideTrace($w[h +   408])=s[h +   408],hideTrace($w[h +   409])=s[h +   409],hideTrace($w[h +   410])=s[h +   410],hideTrace($w[h +   411])=s[h +   411],hideTrace($w[h +   412])=s[h +   412],hideTrace($w[h +   413])=s[h +   413],hideTrace($w[h +   414])=s[h +   414],hideTrace($w[h +   415])=s[h +   415]\
				,hideTrace($w[h +   416])=s[h +   416],hideTrace($w[h +   417])=s[h +   417],hideTrace($w[h +   418])=s[h +   418],hideTrace($w[h +   419])=s[h +   419],hideTrace($w[h +   420])=s[h +   420],hideTrace($w[h +   421])=s[h +   421],hideTrace($w[h +   422])=s[h +   422],hideTrace($w[h +   423])=s[h +   423]\
				,hideTrace($w[h +   424])=s[h +   424],hideTrace($w[h +   425])=s[h +   425],hideTrace($w[h +   426])=s[h +   426],hideTrace($w[h +   427])=s[h +   427],hideTrace($w[h +   428])=s[h +   428],hideTrace($w[h +   429])=s[h +   429],hideTrace($w[h +   430])=s[h +   430],hideTrace($w[h +   431])=s[h +   431]\
				,hideTrace($w[h +   432])=s[h +   432],hideTrace($w[h +   433])=s[h +   433],hideTrace($w[h +   434])=s[h +   434],hideTrace($w[h +   435])=s[h +   435],hideTrace($w[h +   436])=s[h +   436],hideTrace($w[h +   437])=s[h +   437],hideTrace($w[h +   438])=s[h +   438],hideTrace($w[h +   439])=s[h +   439]\
				,hideTrace($w[h +   440])=s[h +   440],hideTrace($w[h +   441])=s[h +   441],hideTrace($w[h +   442])=s[h +   442],hideTrace($w[h +   443])=s[h +   443],hideTrace($w[h +   444])=s[h +   444],hideTrace($w[h +   445])=s[h +   445],hideTrace($w[h +   446])=s[h +   446],hideTrace($w[h +   447])=s[h +   447]\
				,hideTrace($w[h +   448])=s[h +   448],hideTrace($w[h +   449])=s[h +   449],hideTrace($w[h +   450])=s[h +   450],hideTrace($w[h +   451])=s[h +   451],hideTrace($w[h +   452])=s[h +   452],hideTrace($w[h +   453])=s[h +   453],hideTrace($w[h +   454])=s[h +   454],hideTrace($w[h +   455])=s[h +   455]\
				,hideTrace($w[h +   456])=s[h +   456],hideTrace($w[h +   457])=s[h +   457],hideTrace($w[h +   458])=s[h +   458],hideTrace($w[h +   459])=s[h +   459],hideTrace($w[h +   460])=s[h +   460],hideTrace($w[h +   461])=s[h +   461],hideTrace($w[h +   462])=s[h +   462],hideTrace($w[h +   463])=s[h +   463]\
				,hideTrace($w[h +   464])=s[h +   464],hideTrace($w[h +   465])=s[h +   465],hideTrace($w[h +   466])=s[h +   466],hideTrace($w[h +   467])=s[h +   467],hideTrace($w[h +   468])=s[h +   468],hideTrace($w[h +   469])=s[h +   469],hideTrace($w[h +   470])=s[h +   470],hideTrace($w[h +   471])=s[h +   471]\
				,hideTrace($w[h +   472])=s[h +   472],hideTrace($w[h +   473])=s[h +   473],hideTrace($w[h +   474])=s[h +   474],hideTrace($w[h +   475])=s[h +   475],hideTrace($w[h +   476])=s[h +   476],hideTrace($w[h +   477])=s[h +   477],hideTrace($w[h +   478])=s[h +   478],hideTrace($w[h +   479])=s[h +   479]\
				,hideTrace($w[h +   480])=s[h +   480],hideTrace($w[h +   481])=s[h +   481],hideTrace($w[h +   482])=s[h +   482],hideTrace($w[h +   483])=s[h +   483],hideTrace($w[h +   484])=s[h +   484],hideTrace($w[h +   485])=s[h +   485],hideTrace($w[h +   486])=s[h +   486],hideTrace($w[h +   487])=s[h +   487]\
				,hideTrace($w[h +   488])=s[h +   488],hideTrace($w[h +   489])=s[h +   489],hideTrace($w[h +   490])=s[h +   490],hideTrace($w[h +   491])=s[h +   491],hideTrace($w[h +   492])=s[h +   492],hideTrace($w[h +   493])=s[h +   493],hideTrace($w[h +   494])=s[h +   494],hideTrace($w[h +   495])=s[h +   495]\
				,hideTrace($w[h +   496])=s[h +   496],hideTrace($w[h +   497])=s[h +   497],hideTrace($w[h +   498])=s[h +   498],hideTrace($w[h +   499])=s[h +   499],hideTrace($w[h +   500])=s[h +   500],hideTrace($w[h +   501])=s[h +   501],hideTrace($w[h +   502])=s[h +   502],hideTrace($w[h +   503])=s[h +   503]\
				,hideTrace($w[h +   504])=s[h +   504],hideTrace($w[h +   505])=s[h +   505],hideTrace($w[h +   506])=s[h +   506],hideTrace($w[h +   507])=s[h +   507],hideTrace($w[h +   508])=s[h +   508],hideTrace($w[h +   509])=s[h +   509],hideTrace($w[h +   510])=s[h +   510],hideTrace($w[h +   511])=s[h +   511]\
				,hideTrace($w[h +   512])=s[h +   512],hideTrace($w[h +   513])=s[h +   513],hideTrace($w[h +   514])=s[h +   514],hideTrace($w[h +   515])=s[h +   515],hideTrace($w[h +   516])=s[h +   516],hideTrace($w[h +   517])=s[h +   517],hideTrace($w[h +   518])=s[h +   518],hideTrace($w[h +   519])=s[h +   519]\
				,hideTrace($w[h +   520])=s[h +   520],hideTrace($w[h +   521])=s[h +   521],hideTrace($w[h +   522])=s[h +   522],hideTrace($w[h +   523])=s[h +   523],hideTrace($w[h +   524])=s[h +   524],hideTrace($w[h +   525])=s[h +   525],hideTrace($w[h +   526])=s[h +   526],hideTrace($w[h +   527])=s[h +   527]\
				,hideTrace($w[h +   528])=s[h +   528],hideTrace($w[h +   529])=s[h +   529],hideTrace($w[h +   530])=s[h +   530],hideTrace($w[h +   531])=s[h +   531],hideTrace($w[h +   532])=s[h +   532],hideTrace($w[h +   533])=s[h +   533],hideTrace($w[h +   534])=s[h +   534],hideTrace($w[h +   535])=s[h +   535]\
				,hideTrace($w[h +   536])=s[h +   536],hideTrace($w[h +   537])=s[h +   537],hideTrace($w[h +   538])=s[h +   538],hideTrace($w[h +   539])=s[h +   539],hideTrace($w[h +   540])=s[h +   540],hideTrace($w[h +   541])=s[h +   541],hideTrace($w[h +   542])=s[h +   542],hideTrace($w[h +   543])=s[h +   543]\
				,hideTrace($w[h +   544])=s[h +   544],hideTrace($w[h +   545])=s[h +   545],hideTrace($w[h +   546])=s[h +   546],hideTrace($w[h +   547])=s[h +   547],hideTrace($w[h +   548])=s[h +   548],hideTrace($w[h +   549])=s[h +   549],hideTrace($w[h +   550])=s[h +   550],hideTrace($w[h +   551])=s[h +   551]\
				,hideTrace($w[h +   552])=s[h +   552],hideTrace($w[h +   553])=s[h +   553],hideTrace($w[h +   554])=s[h +   554],hideTrace($w[h +   555])=s[h +   555],hideTrace($w[h +   556])=s[h +   556],hideTrace($w[h +   557])=s[h +   557],hideTrace($w[h +   558])=s[h +   558],hideTrace($w[h +   559])=s[h +   559]\
				,hideTrace($w[h +   560])=s[h +   560],hideTrace($w[h +   561])=s[h +   561],hideTrace($w[h +   562])=s[h +   562],hideTrace($w[h +   563])=s[h +   563],hideTrace($w[h +   564])=s[h +   564],hideTrace($w[h +   565])=s[h +   565],hideTrace($w[h +   566])=s[h +   566],hideTrace($w[h +   567])=s[h +   567]\
				,hideTrace($w[h +   568])=s[h +   568],hideTrace($w[h +   569])=s[h +   569],hideTrace($w[h +   570])=s[h +   570],hideTrace($w[h +   571])=s[h +   571],hideTrace($w[h +   572])=s[h +   572],hideTrace($w[h +   573])=s[h +   573],hideTrace($w[h +   574])=s[h +   574],hideTrace($w[h +   575])=s[h +   575]\
				,hideTrace($w[h +   576])=s[h +   576],hideTrace($w[h +   577])=s[h +   577],hideTrace($w[h +   578])=s[h +   578],hideTrace($w[h +   579])=s[h +   579],hideTrace($w[h +   580])=s[h +   580],hideTrace($w[h +   581])=s[h +   581],hideTrace($w[h +   582])=s[h +   582],hideTrace($w[h +   583])=s[h +   583]\
				,hideTrace($w[h +   584])=s[h +   584],hideTrace($w[h +   585])=s[h +   585],hideTrace($w[h +   586])=s[h +   586],hideTrace($w[h +   587])=s[h +   587],hideTrace($w[h +   588])=s[h +   588],hideTrace($w[h +   589])=s[h +   589],hideTrace($w[h +   590])=s[h +   590],hideTrace($w[h +   591])=s[h +   591]\
				,hideTrace($w[h +   592])=s[h +   592],hideTrace($w[h +   593])=s[h +   593],hideTrace($w[h +   594])=s[h +   594],hideTrace($w[h +   595])=s[h +   595],hideTrace($w[h +   596])=s[h +   596],hideTrace($w[h +   597])=s[h +   597],hideTrace($w[h +   598])=s[h +   598],hideTrace($w[h +   599])=s[h +   599]\
				,hideTrace($w[h +   600])=s[h +   600],hideTrace($w[h +   601])=s[h +   601],hideTrace($w[h +   602])=s[h +   602],hideTrace($w[h +   603])=s[h +   603],hideTrace($w[h +   604])=s[h +   604],hideTrace($w[h +   605])=s[h +   605],hideTrace($w[h +   606])=s[h +   606],hideTrace($w[h +   607])=s[h +   607]\
				,hideTrace($w[h +   608])=s[h +   608],hideTrace($w[h +   609])=s[h +   609],hideTrace($w[h +   610])=s[h +   610],hideTrace($w[h +   611])=s[h +   611],hideTrace($w[h +   612])=s[h +   612],hideTrace($w[h +   613])=s[h +   613],hideTrace($w[h +   614])=s[h +   614],hideTrace($w[h +   615])=s[h +   615]\
				,hideTrace($w[h +   616])=s[h +   616],hideTrace($w[h +   617])=s[h +   617],hideTrace($w[h +   618])=s[h +   618],hideTrace($w[h +   619])=s[h +   619],hideTrace($w[h +   620])=s[h +   620],hideTrace($w[h +   621])=s[h +   621],hideTrace($w[h +   622])=s[h +   622],hideTrace($w[h +   623])=s[h +   623]\
				,hideTrace($w[h +   624])=s[h +   624],hideTrace($w[h +   625])=s[h +   625],hideTrace($w[h +   626])=s[h +   626],hideTrace($w[h +   627])=s[h +   627],hideTrace($w[h +   628])=s[h +   628],hideTrace($w[h +   629])=s[h +   629],hideTrace($w[h +   630])=s[h +   630],hideTrace($w[h +   631])=s[h +   631]\
				,hideTrace($w[h +   632])=s[h +   632],hideTrace($w[h +   633])=s[h +   633],hideTrace($w[h +   634])=s[h +   634],hideTrace($w[h +   635])=s[h +   635],hideTrace($w[h +   636])=s[h +   636],hideTrace($w[h +   637])=s[h +   637],hideTrace($w[h +   638])=s[h +   638],hideTrace($w[h +   639])=s[h +   639]\
				,hideTrace($w[h +   640])=s[h +   640],hideTrace($w[h +   641])=s[h +   641],hideTrace($w[h +   642])=s[h +   642],hideTrace($w[h +   643])=s[h +   643],hideTrace($w[h +   644])=s[h +   644],hideTrace($w[h +   645])=s[h +   645],hideTrace($w[h +   646])=s[h +   646],hideTrace($w[h +   647])=s[h +   647]\
				,hideTrace($w[h +   648])=s[h +   648],hideTrace($w[h +   649])=s[h +   649],hideTrace($w[h +   650])=s[h +   650],hideTrace($w[h +   651])=s[h +   651],hideTrace($w[h +   652])=s[h +   652],hideTrace($w[h +   653])=s[h +   653],hideTrace($w[h +   654])=s[h +   654],hideTrace($w[h +   655])=s[h +   655]\
				,hideTrace($w[h +   656])=s[h +   656],hideTrace($w[h +   657])=s[h +   657],hideTrace($w[h +   658])=s[h +   658],hideTrace($w[h +   659])=s[h +   659],hideTrace($w[h +   660])=s[h +   660],hideTrace($w[h +   661])=s[h +   661],hideTrace($w[h +   662])=s[h +   662],hideTrace($w[h +   663])=s[h +   663]\
				,hideTrace($w[h +   664])=s[h +   664],hideTrace($w[h +   665])=s[h +   665],hideTrace($w[h +   666])=s[h +   666],hideTrace($w[h +   667])=s[h +   667],hideTrace($w[h +   668])=s[h +   668],hideTrace($w[h +   669])=s[h +   669],hideTrace($w[h +   670])=s[h +   670],hideTrace($w[h +   671])=s[h +   671]\
				,hideTrace($w[h +   672])=s[h +   672],hideTrace($w[h +   673])=s[h +   673],hideTrace($w[h +   674])=s[h +   674],hideTrace($w[h +   675])=s[h +   675],hideTrace($w[h +   676])=s[h +   676],hideTrace($w[h +   677])=s[h +   677],hideTrace($w[h +   678])=s[h +   678],hideTrace($w[h +   679])=s[h +   679]\
				,hideTrace($w[h +   680])=s[h +   680],hideTrace($w[h +   681])=s[h +   681],hideTrace($w[h +   682])=s[h +   682],hideTrace($w[h +   683])=s[h +   683],hideTrace($w[h +   684])=s[h +   684],hideTrace($w[h +   685])=s[h +   685],hideTrace($w[h +   686])=s[h +   686],hideTrace($w[h +   687])=s[h +   687]\
				,hideTrace($w[h +   688])=s[h +   688],hideTrace($w[h +   689])=s[h +   689],hideTrace($w[h +   690])=s[h +   690],hideTrace($w[h +   691])=s[h +   691],hideTrace($w[h +   692])=s[h +   692],hideTrace($w[h +   693])=s[h +   693],hideTrace($w[h +   694])=s[h +   694],hideTrace($w[h +   695])=s[h +   695]\
				,hideTrace($w[h +   696])=s[h +   696],hideTrace($w[h +   697])=s[h +   697],hideTrace($w[h +   698])=s[h +   698],hideTrace($w[h +   699])=s[h +   699],hideTrace($w[h +   700])=s[h +   700],hideTrace($w[h +   701])=s[h +   701],hideTrace($w[h +   702])=s[h +   702],hideTrace($w[h +   703])=s[h +   703]\
				,hideTrace($w[h +   704])=s[h +   704],hideTrace($w[h +   705])=s[h +   705],hideTrace($w[h +   706])=s[h +   706],hideTrace($w[h +   707])=s[h +   707],hideTrace($w[h +   708])=s[h +   708],hideTrace($w[h +   709])=s[h +   709],hideTrace($w[h +   710])=s[h +   710],hideTrace($w[h +   711])=s[h +   711]\
				,hideTrace($w[h +   712])=s[h +   712],hideTrace($w[h +   713])=s[h +   713],hideTrace($w[h +   714])=s[h +   714],hideTrace($w[h +   715])=s[h +   715],hideTrace($w[h +   716])=s[h +   716],hideTrace($w[h +   717])=s[h +   717],hideTrace($w[h +   718])=s[h +   718],hideTrace($w[h +   719])=s[h +   719]\
				,hideTrace($w[h +   720])=s[h +   720],hideTrace($w[h +   721])=s[h +   721],hideTrace($w[h +   722])=s[h +   722],hideTrace($w[h +   723])=s[h +   723],hideTrace($w[h +   724])=s[h +   724],hideTrace($w[h +   725])=s[h +   725],hideTrace($w[h +   726])=s[h +   726],hideTrace($w[h +   727])=s[h +   727]\
				,hideTrace($w[h +   728])=s[h +   728],hideTrace($w[h +   729])=s[h +   729],hideTrace($w[h +   730])=s[h +   730],hideTrace($w[h +   731])=s[h +   731],hideTrace($w[h +   732])=s[h +   732],hideTrace($w[h +   733])=s[h +   733],hideTrace($w[h +   734])=s[h +   734],hideTrace($w[h +   735])=s[h +   735]\
				,hideTrace($w[h +   736])=s[h +   736],hideTrace($w[h +   737])=s[h +   737],hideTrace($w[h +   738])=s[h +   738],hideTrace($w[h +   739])=s[h +   739],hideTrace($w[h +   740])=s[h +   740],hideTrace($w[h +   741])=s[h +   741],hideTrace($w[h +   742])=s[h +   742],hideTrace($w[h +   743])=s[h +   743]\
				,hideTrace($w[h +   744])=s[h +   744],hideTrace($w[h +   745])=s[h +   745],hideTrace($w[h +   746])=s[h +   746],hideTrace($w[h +   747])=s[h +   747],hideTrace($w[h +   748])=s[h +   748],hideTrace($w[h +   749])=s[h +   749],hideTrace($w[h +   750])=s[h +   750],hideTrace($w[h +   751])=s[h +   751]\
				,hideTrace($w[h +   752])=s[h +   752],hideTrace($w[h +   753])=s[h +   753],hideTrace($w[h +   754])=s[h +   754],hideTrace($w[h +   755])=s[h +   755],hideTrace($w[h +   756])=s[h +   756],hideTrace($w[h +   757])=s[h +   757],hideTrace($w[h +   758])=s[h +   758],hideTrace($w[h +   759])=s[h +   759]\
				,hideTrace($w[h +   760])=s[h +   760],hideTrace($w[h +   761])=s[h +   761],hideTrace($w[h +   762])=s[h +   762],hideTrace($w[h +   763])=s[h +   763],hideTrace($w[h +   764])=s[h +   764],hideTrace($w[h +   765])=s[h +   765],hideTrace($w[h +   766])=s[h +   766],hideTrace($w[h +   767])=s[h +   767]\
				,hideTrace($w[h +   768])=s[h +   768],hideTrace($w[h +   769])=s[h +   769],hideTrace($w[h +   770])=s[h +   770],hideTrace($w[h +   771])=s[h +   771],hideTrace($w[h +   772])=s[h +   772],hideTrace($w[h +   773])=s[h +   773],hideTrace($w[h +   774])=s[h +   774],hideTrace($w[h +   775])=s[h +   775]\
				,hideTrace($w[h +   776])=s[h +   776],hideTrace($w[h +   777])=s[h +   777],hideTrace($w[h +   778])=s[h +   778],hideTrace($w[h +   779])=s[h +   779],hideTrace($w[h +   780])=s[h +   780],hideTrace($w[h +   781])=s[h +   781],hideTrace($w[h +   782])=s[h +   782],hideTrace($w[h +   783])=s[h +   783]\
				,hideTrace($w[h +   784])=s[h +   784],hideTrace($w[h +   785])=s[h +   785],hideTrace($w[h +   786])=s[h +   786],hideTrace($w[h +   787])=s[h +   787],hideTrace($w[h +   788])=s[h +   788],hideTrace($w[h +   789])=s[h +   789],hideTrace($w[h +   790])=s[h +   790],hideTrace($w[h +   791])=s[h +   791]\
				,hideTrace($w[h +   792])=s[h +   792],hideTrace($w[h +   793])=s[h +   793],hideTrace($w[h +   794])=s[h +   794],hideTrace($w[h +   795])=s[h +   795],hideTrace($w[h +   796])=s[h +   796],hideTrace($w[h +   797])=s[h +   797],hideTrace($w[h +   798])=s[h +   798],hideTrace($w[h +   799])=s[h +   799]\
				,hideTrace($w[h +   800])=s[h +   800],hideTrace($w[h +   801])=s[h +   801],hideTrace($w[h +   802])=s[h +   802],hideTrace($w[h +   803])=s[h +   803],hideTrace($w[h +   804])=s[h +   804],hideTrace($w[h +   805])=s[h +   805],hideTrace($w[h +   806])=s[h +   806],hideTrace($w[h +   807])=s[h +   807]\
				,hideTrace($w[h +   808])=s[h +   808],hideTrace($w[h +   809])=s[h +   809],hideTrace($w[h +   810])=s[h +   810],hideTrace($w[h +   811])=s[h +   811],hideTrace($w[h +   812])=s[h +   812],hideTrace($w[h +   813])=s[h +   813],hideTrace($w[h +   814])=s[h +   814],hideTrace($w[h +   815])=s[h +   815]\
				,hideTrace($w[h +   816])=s[h +   816],hideTrace($w[h +   817])=s[h +   817],hideTrace($w[h +   818])=s[h +   818],hideTrace($w[h +   819])=s[h +   819],hideTrace($w[h +   820])=s[h +   820],hideTrace($w[h +   821])=s[h +   821],hideTrace($w[h +   822])=s[h +   822],hideTrace($w[h +   823])=s[h +   823]\
				,hideTrace($w[h +   824])=s[h +   824],hideTrace($w[h +   825])=s[h +   825],hideTrace($w[h +   826])=s[h +   826],hideTrace($w[h +   827])=s[h +   827],hideTrace($w[h +   828])=s[h +   828],hideTrace($w[h +   829])=s[h +   829],hideTrace($w[h +   830])=s[h +   830],hideTrace($w[h +   831])=s[h +   831]\
				,hideTrace($w[h +   832])=s[h +   832],hideTrace($w[h +   833])=s[h +   833],hideTrace($w[h +   834])=s[h +   834],hideTrace($w[h +   835])=s[h +   835],hideTrace($w[h +   836])=s[h +   836],hideTrace($w[h +   837])=s[h +   837],hideTrace($w[h +   838])=s[h +   838],hideTrace($w[h +   839])=s[h +   839]\
				,hideTrace($w[h +   840])=s[h +   840],hideTrace($w[h +   841])=s[h +   841],hideTrace($w[h +   842])=s[h +   842],hideTrace($w[h +   843])=s[h +   843],hideTrace($w[h +   844])=s[h +   844],hideTrace($w[h +   845])=s[h +   845],hideTrace($w[h +   846])=s[h +   846],hideTrace($w[h +   847])=s[h +   847]\
				,hideTrace($w[h +   848])=s[h +   848],hideTrace($w[h +   849])=s[h +   849],hideTrace($w[h +   850])=s[h +   850],hideTrace($w[h +   851])=s[h +   851],hideTrace($w[h +   852])=s[h +   852],hideTrace($w[h +   853])=s[h +   853],hideTrace($w[h +   854])=s[h +   854],hideTrace($w[h +   855])=s[h +   855]\
				,hideTrace($w[h +   856])=s[h +   856],hideTrace($w[h +   857])=s[h +   857],hideTrace($w[h +   858])=s[h +   858],hideTrace($w[h +   859])=s[h +   859],hideTrace($w[h +   860])=s[h +   860],hideTrace($w[h +   861])=s[h +   861],hideTrace($w[h +   862])=s[h +   862],hideTrace($w[h +   863])=s[h +   863]\
				,hideTrace($w[h +   864])=s[h +   864],hideTrace($w[h +   865])=s[h +   865],hideTrace($w[h +   866])=s[h +   866],hideTrace($w[h +   867])=s[h +   867],hideTrace($w[h +   868])=s[h +   868],hideTrace($w[h +   869])=s[h +   869],hideTrace($w[h +   870])=s[h +   870],hideTrace($w[h +   871])=s[h +   871]\
				,hideTrace($w[h +   872])=s[h +   872],hideTrace($w[h +   873])=s[h +   873],hideTrace($w[h +   874])=s[h +   874],hideTrace($w[h +   875])=s[h +   875],hideTrace($w[h +   876])=s[h +   876],hideTrace($w[h +   877])=s[h +   877],hideTrace($w[h +   878])=s[h +   878],hideTrace($w[h +   879])=s[h +   879]\
				,hideTrace($w[h +   880])=s[h +   880],hideTrace($w[h +   881])=s[h +   881],hideTrace($w[h +   882])=s[h +   882],hideTrace($w[h +   883])=s[h +   883],hideTrace($w[h +   884])=s[h +   884],hideTrace($w[h +   885])=s[h +   885],hideTrace($w[h +   886])=s[h +   886],hideTrace($w[h +   887])=s[h +   887]\
				,hideTrace($w[h +   888])=s[h +   888],hideTrace($w[h +   889])=s[h +   889],hideTrace($w[h +   890])=s[h +   890],hideTrace($w[h +   891])=s[h +   891],hideTrace($w[h +   892])=s[h +   892],hideTrace($w[h +   893])=s[h +   893],hideTrace($w[h +   894])=s[h +   894],hideTrace($w[h +   895])=s[h +   895]\
				,hideTrace($w[h +   896])=s[h +   896],hideTrace($w[h +   897])=s[h +   897],hideTrace($w[h +   898])=s[h +   898],hideTrace($w[h +   899])=s[h +   899],hideTrace($w[h +   900])=s[h +   900],hideTrace($w[h +   901])=s[h +   901],hideTrace($w[h +   902])=s[h +   902],hideTrace($w[h +   903])=s[h +   903]\
				,hideTrace($w[h +   904])=s[h +   904],hideTrace($w[h +   905])=s[h +   905],hideTrace($w[h +   906])=s[h +   906],hideTrace($w[h +   907])=s[h +   907],hideTrace($w[h +   908])=s[h +   908],hideTrace($w[h +   909])=s[h +   909],hideTrace($w[h +   910])=s[h +   910],hideTrace($w[h +   911])=s[h +   911]\
				,hideTrace($w[h +   912])=s[h +   912],hideTrace($w[h +   913])=s[h +   913],hideTrace($w[h +   914])=s[h +   914],hideTrace($w[h +   915])=s[h +   915],hideTrace($w[h +   916])=s[h +   916],hideTrace($w[h +   917])=s[h +   917],hideTrace($w[h +   918])=s[h +   918],hideTrace($w[h +   919])=s[h +   919]\
				,hideTrace($w[h +   920])=s[h +   920],hideTrace($w[h +   921])=s[h +   921],hideTrace($w[h +   922])=s[h +   922],hideTrace($w[h +   923])=s[h +   923],hideTrace($w[h +   924])=s[h +   924],hideTrace($w[h +   925])=s[h +   925],hideTrace($w[h +   926])=s[h +   926],hideTrace($w[h +   927])=s[h +   927]\
				,hideTrace($w[h +   928])=s[h +   928],hideTrace($w[h +   929])=s[h +   929],hideTrace($w[h +   930])=s[h +   930],hideTrace($w[h +   931])=s[h +   931],hideTrace($w[h +   932])=s[h +   932],hideTrace($w[h +   933])=s[h +   933],hideTrace($w[h +   934])=s[h +   934],hideTrace($w[h +   935])=s[h +   935]\
				,hideTrace($w[h +   936])=s[h +   936],hideTrace($w[h +   937])=s[h +   937],hideTrace($w[h +   938])=s[h +   938],hideTrace($w[h +   939])=s[h +   939],hideTrace($w[h +   940])=s[h +   940],hideTrace($w[h +   941])=s[h +   941],hideTrace($w[h +   942])=s[h +   942],hideTrace($w[h +   943])=s[h +   943]\
				,hideTrace($w[h +   944])=s[h +   944],hideTrace($w[h +   945])=s[h +   945],hideTrace($w[h +   946])=s[h +   946],hideTrace($w[h +   947])=s[h +   947],hideTrace($w[h +   948])=s[h +   948],hideTrace($w[h +   949])=s[h +   949],hideTrace($w[h +   950])=s[h +   950],hideTrace($w[h +   951])=s[h +   951]\
				,hideTrace($w[h +   952])=s[h +   952],hideTrace($w[h +   953])=s[h +   953],hideTrace($w[h +   954])=s[h +   954],hideTrace($w[h +   955])=s[h +   955],hideTrace($w[h +   956])=s[h +   956],hideTrace($w[h +   957])=s[h +   957],hideTrace($w[h +   958])=s[h +   958],hideTrace($w[h +   959])=s[h +   959]\
				,hideTrace($w[h +   960])=s[h +   960],hideTrace($w[h +   961])=s[h +   961],hideTrace($w[h +   962])=s[h +   962],hideTrace($w[h +   963])=s[h +   963],hideTrace($w[h +   964])=s[h +   964],hideTrace($w[h +   965])=s[h +   965],hideTrace($w[h +   966])=s[h +   966],hideTrace($w[h +   967])=s[h +   967]\
				,hideTrace($w[h +   968])=s[h +   968],hideTrace($w[h +   969])=s[h +   969],hideTrace($w[h +   970])=s[h +   970],hideTrace($w[h +   971])=s[h +   971],hideTrace($w[h +   972])=s[h +   972],hideTrace($w[h +   973])=s[h +   973],hideTrace($w[h +   974])=s[h +   974],hideTrace($w[h +   975])=s[h +   975]\
				,hideTrace($w[h +   976])=s[h +   976],hideTrace($w[h +   977])=s[h +   977],hideTrace($w[h +   978])=s[h +   978],hideTrace($w[h +   979])=s[h +   979],hideTrace($w[h +   980])=s[h +   980],hideTrace($w[h +   981])=s[h +   981],hideTrace($w[h +   982])=s[h +   982],hideTrace($w[h +   983])=s[h +   983]\
				,hideTrace($w[h +   984])=s[h +   984],hideTrace($w[h +   985])=s[h +   985],hideTrace($w[h +   986])=s[h +   986],hideTrace($w[h +   987])=s[h +   987],hideTrace($w[h +   988])=s[h +   988],hideTrace($w[h +   989])=s[h +   989],hideTrace($w[h +   990])=s[h +   990],hideTrace($w[h +   991])=s[h +   991]\
				,hideTrace($w[h +   992])=s[h +   992],hideTrace($w[h +   993])=s[h +   993],hideTrace($w[h +   994])=s[h +   994],hideTrace($w[h +   995])=s[h +   995],hideTrace($w[h +   996])=s[h +   996],hideTrace($w[h +   997])=s[h +   997],hideTrace($w[h +   998])=s[h +   998],hideTrace($w[h +   999])=s[h +   999]\
				,hideTrace($w[h +  1000])=s[h +  1000],hideTrace($w[h +  1001])=s[h +  1001],hideTrace($w[h +  1002])=s[h +  1002],hideTrace($w[h +  1003])=s[h +  1003],hideTrace($w[h +  1004])=s[h +  1004],hideTrace($w[h +  1005])=s[h +  1005],hideTrace($w[h +  1006])=s[h +  1006],hideTrace($w[h +  1007])=s[h +  1007]\
				,hideTrace($w[h +  1008])=s[h +  1008],hideTrace($w[h +  1009])=s[h +  1009],hideTrace($w[h +  1010])=s[h +  1010],hideTrace($w[h +  1011])=s[h +  1011],hideTrace($w[h +  1012])=s[h +  1012],hideTrace($w[h +  1013])=s[h +  1013],hideTrace($w[h +  1014])=s[h +  1014],hideTrace($w[h +  1015])=s[h +  1015]\
				,hideTrace($w[h +  1016])=s[h +  1016],hideTrace($w[h +  1017])=s[h +  1017],hideTrace($w[h +  1018])=s[h +  1018],hideTrace($w[h +  1019])=s[h +  1019],hideTrace($w[h +  1020])=s[h +  1020],hideTrace($w[h +  1021])=s[h +  1021],hideTrace($w[h +  1022])=s[h +  1022],hideTrace($w[h +  1023])=s[h +  1023]
				break
			case 512:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]\
				,hideTrace($w[h +    32])=s[h +    32],hideTrace($w[h +    33])=s[h +    33],hideTrace($w[h +    34])=s[h +    34],hideTrace($w[h +    35])=s[h +    35],hideTrace($w[h +    36])=s[h +    36],hideTrace($w[h +    37])=s[h +    37],hideTrace($w[h +    38])=s[h +    38],hideTrace($w[h +    39])=s[h +    39]\
				,hideTrace($w[h +    40])=s[h +    40],hideTrace($w[h +    41])=s[h +    41],hideTrace($w[h +    42])=s[h +    42],hideTrace($w[h +    43])=s[h +    43],hideTrace($w[h +    44])=s[h +    44],hideTrace($w[h +    45])=s[h +    45],hideTrace($w[h +    46])=s[h +    46],hideTrace($w[h +    47])=s[h +    47]\
				,hideTrace($w[h +    48])=s[h +    48],hideTrace($w[h +    49])=s[h +    49],hideTrace($w[h +    50])=s[h +    50],hideTrace($w[h +    51])=s[h +    51],hideTrace($w[h +    52])=s[h +    52],hideTrace($w[h +    53])=s[h +    53],hideTrace($w[h +    54])=s[h +    54],hideTrace($w[h +    55])=s[h +    55]\
				,hideTrace($w[h +    56])=s[h +    56],hideTrace($w[h +    57])=s[h +    57],hideTrace($w[h +    58])=s[h +    58],hideTrace($w[h +    59])=s[h +    59],hideTrace($w[h +    60])=s[h +    60],hideTrace($w[h +    61])=s[h +    61],hideTrace($w[h +    62])=s[h +    62],hideTrace($w[h +    63])=s[h +    63]\
				,hideTrace($w[h +    64])=s[h +    64],hideTrace($w[h +    65])=s[h +    65],hideTrace($w[h +    66])=s[h +    66],hideTrace($w[h +    67])=s[h +    67],hideTrace($w[h +    68])=s[h +    68],hideTrace($w[h +    69])=s[h +    69],hideTrace($w[h +    70])=s[h +    70],hideTrace($w[h +    71])=s[h +    71]\
				,hideTrace($w[h +    72])=s[h +    72],hideTrace($w[h +    73])=s[h +    73],hideTrace($w[h +    74])=s[h +    74],hideTrace($w[h +    75])=s[h +    75],hideTrace($w[h +    76])=s[h +    76],hideTrace($w[h +    77])=s[h +    77],hideTrace($w[h +    78])=s[h +    78],hideTrace($w[h +    79])=s[h +    79]\
				,hideTrace($w[h +    80])=s[h +    80],hideTrace($w[h +    81])=s[h +    81],hideTrace($w[h +    82])=s[h +    82],hideTrace($w[h +    83])=s[h +    83],hideTrace($w[h +    84])=s[h +    84],hideTrace($w[h +    85])=s[h +    85],hideTrace($w[h +    86])=s[h +    86],hideTrace($w[h +    87])=s[h +    87]\
				,hideTrace($w[h +    88])=s[h +    88],hideTrace($w[h +    89])=s[h +    89],hideTrace($w[h +    90])=s[h +    90],hideTrace($w[h +    91])=s[h +    91],hideTrace($w[h +    92])=s[h +    92],hideTrace($w[h +    93])=s[h +    93],hideTrace($w[h +    94])=s[h +    94],hideTrace($w[h +    95])=s[h +    95]\
				,hideTrace($w[h +    96])=s[h +    96],hideTrace($w[h +    97])=s[h +    97],hideTrace($w[h +    98])=s[h +    98],hideTrace($w[h +    99])=s[h +    99],hideTrace($w[h +   100])=s[h +   100],hideTrace($w[h +   101])=s[h +   101],hideTrace($w[h +   102])=s[h +   102],hideTrace($w[h +   103])=s[h +   103]\
				,hideTrace($w[h +   104])=s[h +   104],hideTrace($w[h +   105])=s[h +   105],hideTrace($w[h +   106])=s[h +   106],hideTrace($w[h +   107])=s[h +   107],hideTrace($w[h +   108])=s[h +   108],hideTrace($w[h +   109])=s[h +   109],hideTrace($w[h +   110])=s[h +   110],hideTrace($w[h +   111])=s[h +   111]\
				,hideTrace($w[h +   112])=s[h +   112],hideTrace($w[h +   113])=s[h +   113],hideTrace($w[h +   114])=s[h +   114],hideTrace($w[h +   115])=s[h +   115],hideTrace($w[h +   116])=s[h +   116],hideTrace($w[h +   117])=s[h +   117],hideTrace($w[h +   118])=s[h +   118],hideTrace($w[h +   119])=s[h +   119]\
				,hideTrace($w[h +   120])=s[h +   120],hideTrace($w[h +   121])=s[h +   121],hideTrace($w[h +   122])=s[h +   122],hideTrace($w[h +   123])=s[h +   123],hideTrace($w[h +   124])=s[h +   124],hideTrace($w[h +   125])=s[h +   125],hideTrace($w[h +   126])=s[h +   126],hideTrace($w[h +   127])=s[h +   127]\
				,hideTrace($w[h +   128])=s[h +   128],hideTrace($w[h +   129])=s[h +   129],hideTrace($w[h +   130])=s[h +   130],hideTrace($w[h +   131])=s[h +   131],hideTrace($w[h +   132])=s[h +   132],hideTrace($w[h +   133])=s[h +   133],hideTrace($w[h +   134])=s[h +   134],hideTrace($w[h +   135])=s[h +   135]\
				,hideTrace($w[h +   136])=s[h +   136],hideTrace($w[h +   137])=s[h +   137],hideTrace($w[h +   138])=s[h +   138],hideTrace($w[h +   139])=s[h +   139],hideTrace($w[h +   140])=s[h +   140],hideTrace($w[h +   141])=s[h +   141],hideTrace($w[h +   142])=s[h +   142],hideTrace($w[h +   143])=s[h +   143]\
				,hideTrace($w[h +   144])=s[h +   144],hideTrace($w[h +   145])=s[h +   145],hideTrace($w[h +   146])=s[h +   146],hideTrace($w[h +   147])=s[h +   147],hideTrace($w[h +   148])=s[h +   148],hideTrace($w[h +   149])=s[h +   149],hideTrace($w[h +   150])=s[h +   150],hideTrace($w[h +   151])=s[h +   151]\
				,hideTrace($w[h +   152])=s[h +   152],hideTrace($w[h +   153])=s[h +   153],hideTrace($w[h +   154])=s[h +   154],hideTrace($w[h +   155])=s[h +   155],hideTrace($w[h +   156])=s[h +   156],hideTrace($w[h +   157])=s[h +   157],hideTrace($w[h +   158])=s[h +   158],hideTrace($w[h +   159])=s[h +   159]\
				,hideTrace($w[h +   160])=s[h +   160],hideTrace($w[h +   161])=s[h +   161],hideTrace($w[h +   162])=s[h +   162],hideTrace($w[h +   163])=s[h +   163],hideTrace($w[h +   164])=s[h +   164],hideTrace($w[h +   165])=s[h +   165],hideTrace($w[h +   166])=s[h +   166],hideTrace($w[h +   167])=s[h +   167]\
				,hideTrace($w[h +   168])=s[h +   168],hideTrace($w[h +   169])=s[h +   169],hideTrace($w[h +   170])=s[h +   170],hideTrace($w[h +   171])=s[h +   171],hideTrace($w[h +   172])=s[h +   172],hideTrace($w[h +   173])=s[h +   173],hideTrace($w[h +   174])=s[h +   174],hideTrace($w[h +   175])=s[h +   175]\
				,hideTrace($w[h +   176])=s[h +   176],hideTrace($w[h +   177])=s[h +   177],hideTrace($w[h +   178])=s[h +   178],hideTrace($w[h +   179])=s[h +   179],hideTrace($w[h +   180])=s[h +   180],hideTrace($w[h +   181])=s[h +   181],hideTrace($w[h +   182])=s[h +   182],hideTrace($w[h +   183])=s[h +   183]\
				,hideTrace($w[h +   184])=s[h +   184],hideTrace($w[h +   185])=s[h +   185],hideTrace($w[h +   186])=s[h +   186],hideTrace($w[h +   187])=s[h +   187],hideTrace($w[h +   188])=s[h +   188],hideTrace($w[h +   189])=s[h +   189],hideTrace($w[h +   190])=s[h +   190],hideTrace($w[h +   191])=s[h +   191]\
				,hideTrace($w[h +   192])=s[h +   192],hideTrace($w[h +   193])=s[h +   193],hideTrace($w[h +   194])=s[h +   194],hideTrace($w[h +   195])=s[h +   195],hideTrace($w[h +   196])=s[h +   196],hideTrace($w[h +   197])=s[h +   197],hideTrace($w[h +   198])=s[h +   198],hideTrace($w[h +   199])=s[h +   199]\
				,hideTrace($w[h +   200])=s[h +   200],hideTrace($w[h +   201])=s[h +   201],hideTrace($w[h +   202])=s[h +   202],hideTrace($w[h +   203])=s[h +   203],hideTrace($w[h +   204])=s[h +   204],hideTrace($w[h +   205])=s[h +   205],hideTrace($w[h +   206])=s[h +   206],hideTrace($w[h +   207])=s[h +   207]\
				,hideTrace($w[h +   208])=s[h +   208],hideTrace($w[h +   209])=s[h +   209],hideTrace($w[h +   210])=s[h +   210],hideTrace($w[h +   211])=s[h +   211],hideTrace($w[h +   212])=s[h +   212],hideTrace($w[h +   213])=s[h +   213],hideTrace($w[h +   214])=s[h +   214],hideTrace($w[h +   215])=s[h +   215]\
				,hideTrace($w[h +   216])=s[h +   216],hideTrace($w[h +   217])=s[h +   217],hideTrace($w[h +   218])=s[h +   218],hideTrace($w[h +   219])=s[h +   219],hideTrace($w[h +   220])=s[h +   220],hideTrace($w[h +   221])=s[h +   221],hideTrace($w[h +   222])=s[h +   222],hideTrace($w[h +   223])=s[h +   223]\
				,hideTrace($w[h +   224])=s[h +   224],hideTrace($w[h +   225])=s[h +   225],hideTrace($w[h +   226])=s[h +   226],hideTrace($w[h +   227])=s[h +   227],hideTrace($w[h +   228])=s[h +   228],hideTrace($w[h +   229])=s[h +   229],hideTrace($w[h +   230])=s[h +   230],hideTrace($w[h +   231])=s[h +   231]\
				,hideTrace($w[h +   232])=s[h +   232],hideTrace($w[h +   233])=s[h +   233],hideTrace($w[h +   234])=s[h +   234],hideTrace($w[h +   235])=s[h +   235],hideTrace($w[h +   236])=s[h +   236],hideTrace($w[h +   237])=s[h +   237],hideTrace($w[h +   238])=s[h +   238],hideTrace($w[h +   239])=s[h +   239]\
				,hideTrace($w[h +   240])=s[h +   240],hideTrace($w[h +   241])=s[h +   241],hideTrace($w[h +   242])=s[h +   242],hideTrace($w[h +   243])=s[h +   243],hideTrace($w[h +   244])=s[h +   244],hideTrace($w[h +   245])=s[h +   245],hideTrace($w[h +   246])=s[h +   246],hideTrace($w[h +   247])=s[h +   247]\
				,hideTrace($w[h +   248])=s[h +   248],hideTrace($w[h +   249])=s[h +   249],hideTrace($w[h +   250])=s[h +   250],hideTrace($w[h +   251])=s[h +   251],hideTrace($w[h +   252])=s[h +   252],hideTrace($w[h +   253])=s[h +   253],hideTrace($w[h +   254])=s[h +   254],hideTrace($w[h +   255])=s[h +   255]\
				,hideTrace($w[h +   256])=s[h +   256],hideTrace($w[h +   257])=s[h +   257],hideTrace($w[h +   258])=s[h +   258],hideTrace($w[h +   259])=s[h +   259],hideTrace($w[h +   260])=s[h +   260],hideTrace($w[h +   261])=s[h +   261],hideTrace($w[h +   262])=s[h +   262],hideTrace($w[h +   263])=s[h +   263]\
				,hideTrace($w[h +   264])=s[h +   264],hideTrace($w[h +   265])=s[h +   265],hideTrace($w[h +   266])=s[h +   266],hideTrace($w[h +   267])=s[h +   267],hideTrace($w[h +   268])=s[h +   268],hideTrace($w[h +   269])=s[h +   269],hideTrace($w[h +   270])=s[h +   270],hideTrace($w[h +   271])=s[h +   271]\
				,hideTrace($w[h +   272])=s[h +   272],hideTrace($w[h +   273])=s[h +   273],hideTrace($w[h +   274])=s[h +   274],hideTrace($w[h +   275])=s[h +   275],hideTrace($w[h +   276])=s[h +   276],hideTrace($w[h +   277])=s[h +   277],hideTrace($w[h +   278])=s[h +   278],hideTrace($w[h +   279])=s[h +   279]\
				,hideTrace($w[h +   280])=s[h +   280],hideTrace($w[h +   281])=s[h +   281],hideTrace($w[h +   282])=s[h +   282],hideTrace($w[h +   283])=s[h +   283],hideTrace($w[h +   284])=s[h +   284],hideTrace($w[h +   285])=s[h +   285],hideTrace($w[h +   286])=s[h +   286],hideTrace($w[h +   287])=s[h +   287]\
				,hideTrace($w[h +   288])=s[h +   288],hideTrace($w[h +   289])=s[h +   289],hideTrace($w[h +   290])=s[h +   290],hideTrace($w[h +   291])=s[h +   291],hideTrace($w[h +   292])=s[h +   292],hideTrace($w[h +   293])=s[h +   293],hideTrace($w[h +   294])=s[h +   294],hideTrace($w[h +   295])=s[h +   295]\
				,hideTrace($w[h +   296])=s[h +   296],hideTrace($w[h +   297])=s[h +   297],hideTrace($w[h +   298])=s[h +   298],hideTrace($w[h +   299])=s[h +   299],hideTrace($w[h +   300])=s[h +   300],hideTrace($w[h +   301])=s[h +   301],hideTrace($w[h +   302])=s[h +   302],hideTrace($w[h +   303])=s[h +   303]\
				,hideTrace($w[h +   304])=s[h +   304],hideTrace($w[h +   305])=s[h +   305],hideTrace($w[h +   306])=s[h +   306],hideTrace($w[h +   307])=s[h +   307],hideTrace($w[h +   308])=s[h +   308],hideTrace($w[h +   309])=s[h +   309],hideTrace($w[h +   310])=s[h +   310],hideTrace($w[h +   311])=s[h +   311]\
				,hideTrace($w[h +   312])=s[h +   312],hideTrace($w[h +   313])=s[h +   313],hideTrace($w[h +   314])=s[h +   314],hideTrace($w[h +   315])=s[h +   315],hideTrace($w[h +   316])=s[h +   316],hideTrace($w[h +   317])=s[h +   317],hideTrace($w[h +   318])=s[h +   318],hideTrace($w[h +   319])=s[h +   319]\
				,hideTrace($w[h +   320])=s[h +   320],hideTrace($w[h +   321])=s[h +   321],hideTrace($w[h +   322])=s[h +   322],hideTrace($w[h +   323])=s[h +   323],hideTrace($w[h +   324])=s[h +   324],hideTrace($w[h +   325])=s[h +   325],hideTrace($w[h +   326])=s[h +   326],hideTrace($w[h +   327])=s[h +   327]\
				,hideTrace($w[h +   328])=s[h +   328],hideTrace($w[h +   329])=s[h +   329],hideTrace($w[h +   330])=s[h +   330],hideTrace($w[h +   331])=s[h +   331],hideTrace($w[h +   332])=s[h +   332],hideTrace($w[h +   333])=s[h +   333],hideTrace($w[h +   334])=s[h +   334],hideTrace($w[h +   335])=s[h +   335]\
				,hideTrace($w[h +   336])=s[h +   336],hideTrace($w[h +   337])=s[h +   337],hideTrace($w[h +   338])=s[h +   338],hideTrace($w[h +   339])=s[h +   339],hideTrace($w[h +   340])=s[h +   340],hideTrace($w[h +   341])=s[h +   341],hideTrace($w[h +   342])=s[h +   342],hideTrace($w[h +   343])=s[h +   343]\
				,hideTrace($w[h +   344])=s[h +   344],hideTrace($w[h +   345])=s[h +   345],hideTrace($w[h +   346])=s[h +   346],hideTrace($w[h +   347])=s[h +   347],hideTrace($w[h +   348])=s[h +   348],hideTrace($w[h +   349])=s[h +   349],hideTrace($w[h +   350])=s[h +   350],hideTrace($w[h +   351])=s[h +   351]\
				,hideTrace($w[h +   352])=s[h +   352],hideTrace($w[h +   353])=s[h +   353],hideTrace($w[h +   354])=s[h +   354],hideTrace($w[h +   355])=s[h +   355],hideTrace($w[h +   356])=s[h +   356],hideTrace($w[h +   357])=s[h +   357],hideTrace($w[h +   358])=s[h +   358],hideTrace($w[h +   359])=s[h +   359]\
				,hideTrace($w[h +   360])=s[h +   360],hideTrace($w[h +   361])=s[h +   361],hideTrace($w[h +   362])=s[h +   362],hideTrace($w[h +   363])=s[h +   363],hideTrace($w[h +   364])=s[h +   364],hideTrace($w[h +   365])=s[h +   365],hideTrace($w[h +   366])=s[h +   366],hideTrace($w[h +   367])=s[h +   367]\
				,hideTrace($w[h +   368])=s[h +   368],hideTrace($w[h +   369])=s[h +   369],hideTrace($w[h +   370])=s[h +   370],hideTrace($w[h +   371])=s[h +   371],hideTrace($w[h +   372])=s[h +   372],hideTrace($w[h +   373])=s[h +   373],hideTrace($w[h +   374])=s[h +   374],hideTrace($w[h +   375])=s[h +   375]\
				,hideTrace($w[h +   376])=s[h +   376],hideTrace($w[h +   377])=s[h +   377],hideTrace($w[h +   378])=s[h +   378],hideTrace($w[h +   379])=s[h +   379],hideTrace($w[h +   380])=s[h +   380],hideTrace($w[h +   381])=s[h +   381],hideTrace($w[h +   382])=s[h +   382],hideTrace($w[h +   383])=s[h +   383]\
				,hideTrace($w[h +   384])=s[h +   384],hideTrace($w[h +   385])=s[h +   385],hideTrace($w[h +   386])=s[h +   386],hideTrace($w[h +   387])=s[h +   387],hideTrace($w[h +   388])=s[h +   388],hideTrace($w[h +   389])=s[h +   389],hideTrace($w[h +   390])=s[h +   390],hideTrace($w[h +   391])=s[h +   391]\
				,hideTrace($w[h +   392])=s[h +   392],hideTrace($w[h +   393])=s[h +   393],hideTrace($w[h +   394])=s[h +   394],hideTrace($w[h +   395])=s[h +   395],hideTrace($w[h +   396])=s[h +   396],hideTrace($w[h +   397])=s[h +   397],hideTrace($w[h +   398])=s[h +   398],hideTrace($w[h +   399])=s[h +   399]\
				,hideTrace($w[h +   400])=s[h +   400],hideTrace($w[h +   401])=s[h +   401],hideTrace($w[h +   402])=s[h +   402],hideTrace($w[h +   403])=s[h +   403],hideTrace($w[h +   404])=s[h +   404],hideTrace($w[h +   405])=s[h +   405],hideTrace($w[h +   406])=s[h +   406],hideTrace($w[h +   407])=s[h +   407]\
				,hideTrace($w[h +   408])=s[h +   408],hideTrace($w[h +   409])=s[h +   409],hideTrace($w[h +   410])=s[h +   410],hideTrace($w[h +   411])=s[h +   411],hideTrace($w[h +   412])=s[h +   412],hideTrace($w[h +   413])=s[h +   413],hideTrace($w[h +   414])=s[h +   414],hideTrace($w[h +   415])=s[h +   415]\
				,hideTrace($w[h +   416])=s[h +   416],hideTrace($w[h +   417])=s[h +   417],hideTrace($w[h +   418])=s[h +   418],hideTrace($w[h +   419])=s[h +   419],hideTrace($w[h +   420])=s[h +   420],hideTrace($w[h +   421])=s[h +   421],hideTrace($w[h +   422])=s[h +   422],hideTrace($w[h +   423])=s[h +   423]\
				,hideTrace($w[h +   424])=s[h +   424],hideTrace($w[h +   425])=s[h +   425],hideTrace($w[h +   426])=s[h +   426],hideTrace($w[h +   427])=s[h +   427],hideTrace($w[h +   428])=s[h +   428],hideTrace($w[h +   429])=s[h +   429],hideTrace($w[h +   430])=s[h +   430],hideTrace($w[h +   431])=s[h +   431]\
				,hideTrace($w[h +   432])=s[h +   432],hideTrace($w[h +   433])=s[h +   433],hideTrace($w[h +   434])=s[h +   434],hideTrace($w[h +   435])=s[h +   435],hideTrace($w[h +   436])=s[h +   436],hideTrace($w[h +   437])=s[h +   437],hideTrace($w[h +   438])=s[h +   438],hideTrace($w[h +   439])=s[h +   439]\
				,hideTrace($w[h +   440])=s[h +   440],hideTrace($w[h +   441])=s[h +   441],hideTrace($w[h +   442])=s[h +   442],hideTrace($w[h +   443])=s[h +   443],hideTrace($w[h +   444])=s[h +   444],hideTrace($w[h +   445])=s[h +   445],hideTrace($w[h +   446])=s[h +   446],hideTrace($w[h +   447])=s[h +   447]\
				,hideTrace($w[h +   448])=s[h +   448],hideTrace($w[h +   449])=s[h +   449],hideTrace($w[h +   450])=s[h +   450],hideTrace($w[h +   451])=s[h +   451],hideTrace($w[h +   452])=s[h +   452],hideTrace($w[h +   453])=s[h +   453],hideTrace($w[h +   454])=s[h +   454],hideTrace($w[h +   455])=s[h +   455]\
				,hideTrace($w[h +   456])=s[h +   456],hideTrace($w[h +   457])=s[h +   457],hideTrace($w[h +   458])=s[h +   458],hideTrace($w[h +   459])=s[h +   459],hideTrace($w[h +   460])=s[h +   460],hideTrace($w[h +   461])=s[h +   461],hideTrace($w[h +   462])=s[h +   462],hideTrace($w[h +   463])=s[h +   463]\
				,hideTrace($w[h +   464])=s[h +   464],hideTrace($w[h +   465])=s[h +   465],hideTrace($w[h +   466])=s[h +   466],hideTrace($w[h +   467])=s[h +   467],hideTrace($w[h +   468])=s[h +   468],hideTrace($w[h +   469])=s[h +   469],hideTrace($w[h +   470])=s[h +   470],hideTrace($w[h +   471])=s[h +   471]\
				,hideTrace($w[h +   472])=s[h +   472],hideTrace($w[h +   473])=s[h +   473],hideTrace($w[h +   474])=s[h +   474],hideTrace($w[h +   475])=s[h +   475],hideTrace($w[h +   476])=s[h +   476],hideTrace($w[h +   477])=s[h +   477],hideTrace($w[h +   478])=s[h +   478],hideTrace($w[h +   479])=s[h +   479]\
				,hideTrace($w[h +   480])=s[h +   480],hideTrace($w[h +   481])=s[h +   481],hideTrace($w[h +   482])=s[h +   482],hideTrace($w[h +   483])=s[h +   483],hideTrace($w[h +   484])=s[h +   484],hideTrace($w[h +   485])=s[h +   485],hideTrace($w[h +   486])=s[h +   486],hideTrace($w[h +   487])=s[h +   487]\
				,hideTrace($w[h +   488])=s[h +   488],hideTrace($w[h +   489])=s[h +   489],hideTrace($w[h +   490])=s[h +   490],hideTrace($w[h +   491])=s[h +   491],hideTrace($w[h +   492])=s[h +   492],hideTrace($w[h +   493])=s[h +   493],hideTrace($w[h +   494])=s[h +   494],hideTrace($w[h +   495])=s[h +   495]\
				,hideTrace($w[h +   496])=s[h +   496],hideTrace($w[h +   497])=s[h +   497],hideTrace($w[h +   498])=s[h +   498],hideTrace($w[h +   499])=s[h +   499],hideTrace($w[h +   500])=s[h +   500],hideTrace($w[h +   501])=s[h +   501],hideTrace($w[h +   502])=s[h +   502],hideTrace($w[h +   503])=s[h +   503]\
				,hideTrace($w[h +   504])=s[h +   504],hideTrace($w[h +   505])=s[h +   505],hideTrace($w[h +   506])=s[h +   506],hideTrace($w[h +   507])=s[h +   507],hideTrace($w[h +   508])=s[h +   508],hideTrace($w[h +   509])=s[h +   509],hideTrace($w[h +   510])=s[h +   510],hideTrace($w[h +   511])=s[h +   511]
				break
			case 256:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]\
				,hideTrace($w[h +    32])=s[h +    32],hideTrace($w[h +    33])=s[h +    33],hideTrace($w[h +    34])=s[h +    34],hideTrace($w[h +    35])=s[h +    35],hideTrace($w[h +    36])=s[h +    36],hideTrace($w[h +    37])=s[h +    37],hideTrace($w[h +    38])=s[h +    38],hideTrace($w[h +    39])=s[h +    39]\
				,hideTrace($w[h +    40])=s[h +    40],hideTrace($w[h +    41])=s[h +    41],hideTrace($w[h +    42])=s[h +    42],hideTrace($w[h +    43])=s[h +    43],hideTrace($w[h +    44])=s[h +    44],hideTrace($w[h +    45])=s[h +    45],hideTrace($w[h +    46])=s[h +    46],hideTrace($w[h +    47])=s[h +    47]\
				,hideTrace($w[h +    48])=s[h +    48],hideTrace($w[h +    49])=s[h +    49],hideTrace($w[h +    50])=s[h +    50],hideTrace($w[h +    51])=s[h +    51],hideTrace($w[h +    52])=s[h +    52],hideTrace($w[h +    53])=s[h +    53],hideTrace($w[h +    54])=s[h +    54],hideTrace($w[h +    55])=s[h +    55]\
				,hideTrace($w[h +    56])=s[h +    56],hideTrace($w[h +    57])=s[h +    57],hideTrace($w[h +    58])=s[h +    58],hideTrace($w[h +    59])=s[h +    59],hideTrace($w[h +    60])=s[h +    60],hideTrace($w[h +    61])=s[h +    61],hideTrace($w[h +    62])=s[h +    62],hideTrace($w[h +    63])=s[h +    63]\
				,hideTrace($w[h +    64])=s[h +    64],hideTrace($w[h +    65])=s[h +    65],hideTrace($w[h +    66])=s[h +    66],hideTrace($w[h +    67])=s[h +    67],hideTrace($w[h +    68])=s[h +    68],hideTrace($w[h +    69])=s[h +    69],hideTrace($w[h +    70])=s[h +    70],hideTrace($w[h +    71])=s[h +    71]\
				,hideTrace($w[h +    72])=s[h +    72],hideTrace($w[h +    73])=s[h +    73],hideTrace($w[h +    74])=s[h +    74],hideTrace($w[h +    75])=s[h +    75],hideTrace($w[h +    76])=s[h +    76],hideTrace($w[h +    77])=s[h +    77],hideTrace($w[h +    78])=s[h +    78],hideTrace($w[h +    79])=s[h +    79]\
				,hideTrace($w[h +    80])=s[h +    80],hideTrace($w[h +    81])=s[h +    81],hideTrace($w[h +    82])=s[h +    82],hideTrace($w[h +    83])=s[h +    83],hideTrace($w[h +    84])=s[h +    84],hideTrace($w[h +    85])=s[h +    85],hideTrace($w[h +    86])=s[h +    86],hideTrace($w[h +    87])=s[h +    87]\
				,hideTrace($w[h +    88])=s[h +    88],hideTrace($w[h +    89])=s[h +    89],hideTrace($w[h +    90])=s[h +    90],hideTrace($w[h +    91])=s[h +    91],hideTrace($w[h +    92])=s[h +    92],hideTrace($w[h +    93])=s[h +    93],hideTrace($w[h +    94])=s[h +    94],hideTrace($w[h +    95])=s[h +    95]\
				,hideTrace($w[h +    96])=s[h +    96],hideTrace($w[h +    97])=s[h +    97],hideTrace($w[h +    98])=s[h +    98],hideTrace($w[h +    99])=s[h +    99],hideTrace($w[h +   100])=s[h +   100],hideTrace($w[h +   101])=s[h +   101],hideTrace($w[h +   102])=s[h +   102],hideTrace($w[h +   103])=s[h +   103]\
				,hideTrace($w[h +   104])=s[h +   104],hideTrace($w[h +   105])=s[h +   105],hideTrace($w[h +   106])=s[h +   106],hideTrace($w[h +   107])=s[h +   107],hideTrace($w[h +   108])=s[h +   108],hideTrace($w[h +   109])=s[h +   109],hideTrace($w[h +   110])=s[h +   110],hideTrace($w[h +   111])=s[h +   111]\
				,hideTrace($w[h +   112])=s[h +   112],hideTrace($w[h +   113])=s[h +   113],hideTrace($w[h +   114])=s[h +   114],hideTrace($w[h +   115])=s[h +   115],hideTrace($w[h +   116])=s[h +   116],hideTrace($w[h +   117])=s[h +   117],hideTrace($w[h +   118])=s[h +   118],hideTrace($w[h +   119])=s[h +   119]\
				,hideTrace($w[h +   120])=s[h +   120],hideTrace($w[h +   121])=s[h +   121],hideTrace($w[h +   122])=s[h +   122],hideTrace($w[h +   123])=s[h +   123],hideTrace($w[h +   124])=s[h +   124],hideTrace($w[h +   125])=s[h +   125],hideTrace($w[h +   126])=s[h +   126],hideTrace($w[h +   127])=s[h +   127]\
				,hideTrace($w[h +   128])=s[h +   128],hideTrace($w[h +   129])=s[h +   129],hideTrace($w[h +   130])=s[h +   130],hideTrace($w[h +   131])=s[h +   131],hideTrace($w[h +   132])=s[h +   132],hideTrace($w[h +   133])=s[h +   133],hideTrace($w[h +   134])=s[h +   134],hideTrace($w[h +   135])=s[h +   135]\
				,hideTrace($w[h +   136])=s[h +   136],hideTrace($w[h +   137])=s[h +   137],hideTrace($w[h +   138])=s[h +   138],hideTrace($w[h +   139])=s[h +   139],hideTrace($w[h +   140])=s[h +   140],hideTrace($w[h +   141])=s[h +   141],hideTrace($w[h +   142])=s[h +   142],hideTrace($w[h +   143])=s[h +   143]\
				,hideTrace($w[h +   144])=s[h +   144],hideTrace($w[h +   145])=s[h +   145],hideTrace($w[h +   146])=s[h +   146],hideTrace($w[h +   147])=s[h +   147],hideTrace($w[h +   148])=s[h +   148],hideTrace($w[h +   149])=s[h +   149],hideTrace($w[h +   150])=s[h +   150],hideTrace($w[h +   151])=s[h +   151]\
				,hideTrace($w[h +   152])=s[h +   152],hideTrace($w[h +   153])=s[h +   153],hideTrace($w[h +   154])=s[h +   154],hideTrace($w[h +   155])=s[h +   155],hideTrace($w[h +   156])=s[h +   156],hideTrace($w[h +   157])=s[h +   157],hideTrace($w[h +   158])=s[h +   158],hideTrace($w[h +   159])=s[h +   159]\
				,hideTrace($w[h +   160])=s[h +   160],hideTrace($w[h +   161])=s[h +   161],hideTrace($w[h +   162])=s[h +   162],hideTrace($w[h +   163])=s[h +   163],hideTrace($w[h +   164])=s[h +   164],hideTrace($w[h +   165])=s[h +   165],hideTrace($w[h +   166])=s[h +   166],hideTrace($w[h +   167])=s[h +   167]\
				,hideTrace($w[h +   168])=s[h +   168],hideTrace($w[h +   169])=s[h +   169],hideTrace($w[h +   170])=s[h +   170],hideTrace($w[h +   171])=s[h +   171],hideTrace($w[h +   172])=s[h +   172],hideTrace($w[h +   173])=s[h +   173],hideTrace($w[h +   174])=s[h +   174],hideTrace($w[h +   175])=s[h +   175]\
				,hideTrace($w[h +   176])=s[h +   176],hideTrace($w[h +   177])=s[h +   177],hideTrace($w[h +   178])=s[h +   178],hideTrace($w[h +   179])=s[h +   179],hideTrace($w[h +   180])=s[h +   180],hideTrace($w[h +   181])=s[h +   181],hideTrace($w[h +   182])=s[h +   182],hideTrace($w[h +   183])=s[h +   183]\
				,hideTrace($w[h +   184])=s[h +   184],hideTrace($w[h +   185])=s[h +   185],hideTrace($w[h +   186])=s[h +   186],hideTrace($w[h +   187])=s[h +   187],hideTrace($w[h +   188])=s[h +   188],hideTrace($w[h +   189])=s[h +   189],hideTrace($w[h +   190])=s[h +   190],hideTrace($w[h +   191])=s[h +   191]\
				,hideTrace($w[h +   192])=s[h +   192],hideTrace($w[h +   193])=s[h +   193],hideTrace($w[h +   194])=s[h +   194],hideTrace($w[h +   195])=s[h +   195],hideTrace($w[h +   196])=s[h +   196],hideTrace($w[h +   197])=s[h +   197],hideTrace($w[h +   198])=s[h +   198],hideTrace($w[h +   199])=s[h +   199]\
				,hideTrace($w[h +   200])=s[h +   200],hideTrace($w[h +   201])=s[h +   201],hideTrace($w[h +   202])=s[h +   202],hideTrace($w[h +   203])=s[h +   203],hideTrace($w[h +   204])=s[h +   204],hideTrace($w[h +   205])=s[h +   205],hideTrace($w[h +   206])=s[h +   206],hideTrace($w[h +   207])=s[h +   207]\
				,hideTrace($w[h +   208])=s[h +   208],hideTrace($w[h +   209])=s[h +   209],hideTrace($w[h +   210])=s[h +   210],hideTrace($w[h +   211])=s[h +   211],hideTrace($w[h +   212])=s[h +   212],hideTrace($w[h +   213])=s[h +   213],hideTrace($w[h +   214])=s[h +   214],hideTrace($w[h +   215])=s[h +   215]\
				,hideTrace($w[h +   216])=s[h +   216],hideTrace($w[h +   217])=s[h +   217],hideTrace($w[h +   218])=s[h +   218],hideTrace($w[h +   219])=s[h +   219],hideTrace($w[h +   220])=s[h +   220],hideTrace($w[h +   221])=s[h +   221],hideTrace($w[h +   222])=s[h +   222],hideTrace($w[h +   223])=s[h +   223]\
				,hideTrace($w[h +   224])=s[h +   224],hideTrace($w[h +   225])=s[h +   225],hideTrace($w[h +   226])=s[h +   226],hideTrace($w[h +   227])=s[h +   227],hideTrace($w[h +   228])=s[h +   228],hideTrace($w[h +   229])=s[h +   229],hideTrace($w[h +   230])=s[h +   230],hideTrace($w[h +   231])=s[h +   231]\
				,hideTrace($w[h +   232])=s[h +   232],hideTrace($w[h +   233])=s[h +   233],hideTrace($w[h +   234])=s[h +   234],hideTrace($w[h +   235])=s[h +   235],hideTrace($w[h +   236])=s[h +   236],hideTrace($w[h +   237])=s[h +   237],hideTrace($w[h +   238])=s[h +   238],hideTrace($w[h +   239])=s[h +   239]\
				,hideTrace($w[h +   240])=s[h +   240],hideTrace($w[h +   241])=s[h +   241],hideTrace($w[h +   242])=s[h +   242],hideTrace($w[h +   243])=s[h +   243],hideTrace($w[h +   244])=s[h +   244],hideTrace($w[h +   245])=s[h +   245],hideTrace($w[h +   246])=s[h +   246],hideTrace($w[h +   247])=s[h +   247]\
				,hideTrace($w[h +   248])=s[h +   248],hideTrace($w[h +   249])=s[h +   249],hideTrace($w[h +   250])=s[h +   250],hideTrace($w[h +   251])=s[h +   251],hideTrace($w[h +   252])=s[h +   252],hideTrace($w[h +   253])=s[h +   253],hideTrace($w[h +   254])=s[h +   254],hideTrace($w[h +   255])=s[h +   255]
				break
			case 128:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]\
				,hideTrace($w[h +    32])=s[h +    32],hideTrace($w[h +    33])=s[h +    33],hideTrace($w[h +    34])=s[h +    34],hideTrace($w[h +    35])=s[h +    35],hideTrace($w[h +    36])=s[h +    36],hideTrace($w[h +    37])=s[h +    37],hideTrace($w[h +    38])=s[h +    38],hideTrace($w[h +    39])=s[h +    39]\
				,hideTrace($w[h +    40])=s[h +    40],hideTrace($w[h +    41])=s[h +    41],hideTrace($w[h +    42])=s[h +    42],hideTrace($w[h +    43])=s[h +    43],hideTrace($w[h +    44])=s[h +    44],hideTrace($w[h +    45])=s[h +    45],hideTrace($w[h +    46])=s[h +    46],hideTrace($w[h +    47])=s[h +    47]\
				,hideTrace($w[h +    48])=s[h +    48],hideTrace($w[h +    49])=s[h +    49],hideTrace($w[h +    50])=s[h +    50],hideTrace($w[h +    51])=s[h +    51],hideTrace($w[h +    52])=s[h +    52],hideTrace($w[h +    53])=s[h +    53],hideTrace($w[h +    54])=s[h +    54],hideTrace($w[h +    55])=s[h +    55]\
				,hideTrace($w[h +    56])=s[h +    56],hideTrace($w[h +    57])=s[h +    57],hideTrace($w[h +    58])=s[h +    58],hideTrace($w[h +    59])=s[h +    59],hideTrace($w[h +    60])=s[h +    60],hideTrace($w[h +    61])=s[h +    61],hideTrace($w[h +    62])=s[h +    62],hideTrace($w[h +    63])=s[h +    63]\
				,hideTrace($w[h +    64])=s[h +    64],hideTrace($w[h +    65])=s[h +    65],hideTrace($w[h +    66])=s[h +    66],hideTrace($w[h +    67])=s[h +    67],hideTrace($w[h +    68])=s[h +    68],hideTrace($w[h +    69])=s[h +    69],hideTrace($w[h +    70])=s[h +    70],hideTrace($w[h +    71])=s[h +    71]\
				,hideTrace($w[h +    72])=s[h +    72],hideTrace($w[h +    73])=s[h +    73],hideTrace($w[h +    74])=s[h +    74],hideTrace($w[h +    75])=s[h +    75],hideTrace($w[h +    76])=s[h +    76],hideTrace($w[h +    77])=s[h +    77],hideTrace($w[h +    78])=s[h +    78],hideTrace($w[h +    79])=s[h +    79]\
				,hideTrace($w[h +    80])=s[h +    80],hideTrace($w[h +    81])=s[h +    81],hideTrace($w[h +    82])=s[h +    82],hideTrace($w[h +    83])=s[h +    83],hideTrace($w[h +    84])=s[h +    84],hideTrace($w[h +    85])=s[h +    85],hideTrace($w[h +    86])=s[h +    86],hideTrace($w[h +    87])=s[h +    87]\
				,hideTrace($w[h +    88])=s[h +    88],hideTrace($w[h +    89])=s[h +    89],hideTrace($w[h +    90])=s[h +    90],hideTrace($w[h +    91])=s[h +    91],hideTrace($w[h +    92])=s[h +    92],hideTrace($w[h +    93])=s[h +    93],hideTrace($w[h +    94])=s[h +    94],hideTrace($w[h +    95])=s[h +    95]\
				,hideTrace($w[h +    96])=s[h +    96],hideTrace($w[h +    97])=s[h +    97],hideTrace($w[h +    98])=s[h +    98],hideTrace($w[h +    99])=s[h +    99],hideTrace($w[h +   100])=s[h +   100],hideTrace($w[h +   101])=s[h +   101],hideTrace($w[h +   102])=s[h +   102],hideTrace($w[h +   103])=s[h +   103]\
				,hideTrace($w[h +   104])=s[h +   104],hideTrace($w[h +   105])=s[h +   105],hideTrace($w[h +   106])=s[h +   106],hideTrace($w[h +   107])=s[h +   107],hideTrace($w[h +   108])=s[h +   108],hideTrace($w[h +   109])=s[h +   109],hideTrace($w[h +   110])=s[h +   110],hideTrace($w[h +   111])=s[h +   111]\
				,hideTrace($w[h +   112])=s[h +   112],hideTrace($w[h +   113])=s[h +   113],hideTrace($w[h +   114])=s[h +   114],hideTrace($w[h +   115])=s[h +   115],hideTrace($w[h +   116])=s[h +   116],hideTrace($w[h +   117])=s[h +   117],hideTrace($w[h +   118])=s[h +   118],hideTrace($w[h +   119])=s[h +   119]\
				,hideTrace($w[h +   120])=s[h +   120],hideTrace($w[h +   121])=s[h +   121],hideTrace($w[h +   122])=s[h +   122],hideTrace($w[h +   123])=s[h +   123],hideTrace($w[h +   124])=s[h +   124],hideTrace($w[h +   125])=s[h +   125],hideTrace($w[h +   126])=s[h +   126],hideTrace($w[h +   127])=s[h +   127]
				break
			case 64:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]\
				,hideTrace($w[h +    32])=s[h +    32],hideTrace($w[h +    33])=s[h +    33],hideTrace($w[h +    34])=s[h +    34],hideTrace($w[h +    35])=s[h +    35],hideTrace($w[h +    36])=s[h +    36],hideTrace($w[h +    37])=s[h +    37],hideTrace($w[h +    38])=s[h +    38],hideTrace($w[h +    39])=s[h +    39]\
				,hideTrace($w[h +    40])=s[h +    40],hideTrace($w[h +    41])=s[h +    41],hideTrace($w[h +    42])=s[h +    42],hideTrace($w[h +    43])=s[h +    43],hideTrace($w[h +    44])=s[h +    44],hideTrace($w[h +    45])=s[h +    45],hideTrace($w[h +    46])=s[h +    46],hideTrace($w[h +    47])=s[h +    47]\
				,hideTrace($w[h +    48])=s[h +    48],hideTrace($w[h +    49])=s[h +    49],hideTrace($w[h +    50])=s[h +    50],hideTrace($w[h +    51])=s[h +    51],hideTrace($w[h +    52])=s[h +    52],hideTrace($w[h +    53])=s[h +    53],hideTrace($w[h +    54])=s[h +    54],hideTrace($w[h +    55])=s[h +    55]\
				,hideTrace($w[h +    56])=s[h +    56],hideTrace($w[h +    57])=s[h +    57],hideTrace($w[h +    58])=s[h +    58],hideTrace($w[h +    59])=s[h +    59],hideTrace($w[h +    60])=s[h +    60],hideTrace($w[h +    61])=s[h +    61],hideTrace($w[h +    62])=s[h +    62],hideTrace($w[h +    63])=s[h +    63]
				break
			case 32:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]\
				,hideTrace($w[h +    16])=s[h +    16],hideTrace($w[h +    17])=s[h +    17],hideTrace($w[h +    18])=s[h +    18],hideTrace($w[h +    19])=s[h +    19],hideTrace($w[h +    20])=s[h +    20],hideTrace($w[h +    21])=s[h +    21],hideTrace($w[h +    22])=s[h +    22],hideTrace($w[h +    23])=s[h +    23]\
				,hideTrace($w[h +    24])=s[h +    24],hideTrace($w[h +    25])=s[h +    25],hideTrace($w[h +    26])=s[h +    26],hideTrace($w[h +    27])=s[h +    27],hideTrace($w[h +    28])=s[h +    28],hideTrace($w[h +    29])=s[h +    29],hideTrace($w[h +    30])=s[h +    30],hideTrace($w[h +    31])=s[h +    31]
				break
			case 16:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]\
				,hideTrace($w[h +     8])=s[h +     8],hideTrace($w[h +     9])=s[h +     9],hideTrace($w[h +    10])=s[h +    10],hideTrace($w[h +    11])=s[h +    11],hideTrace($w[h +    12])=s[h +    12],hideTrace($w[h +    13])=s[h +    13],hideTrace($w[h +    14])=s[h +    14],hideTrace($w[h +    15])=s[h +    15]
				break
			case 8:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3],hideTrace($w[h +     4])=s[h +     4],hideTrace($w[h +     5])=s[h +     5],hideTrace($w[h +     6])=s[h +     6],hideTrace($w[h +     7])=s[h +     7]
				break
			case 4:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1],hideTrace($w[h +     2])=s[h +     2],hideTrace($w[h +     3])=s[h +     3]
				break
			case 2:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0],hideTrace($w[h +     1])=s[h +     1]
				break
			case 1:
				ModifyGraph/W=$graph \
				 hideTrace($w[h +     0])=s[h +     0]
				break
				// END AUTOMATED CODE
			default:
				ASSERT(0, "Fail")
				break
		endswitch
	while(h)
End

/// @brief Accelerated setting of multiple traces in a graph to un/hidden and the color
///
/// The code between `BEGIN/END AUTOMATED CODE` is generated via
/// GenerateAcceleratedModifyGraphCase("hideTrace") and cleanup for whitespace
/// errors.
///
/// @param[in] graph name of graph window
/// @param[in] w 1D text wave with trace names
/// @param[in] h number of traces in text wave
/// @param[in] hideState new hidden state
/// @param[in] color new hidden state
Function AccelerateHideTracesAndColor(string graph, WAVE/T w, variable h, WAVE hideState, WAVE color)

	variable step

	if(!h)
		return NaN
	endif

	// adapt to machine generated code naming
	WAVE s0 = color
	WAVE s1 = hideState

	do
		step = min(2 ^ trunc(log(h) / log(2)), ACCELERATE_MAX)
		h -= step
		switch(step)
			// BEGIN AUTOMATED CODE
			case ACCELERATE_MAX:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31]) \
				,rgb($w[h +    32])=(s0[h +    32][0],s0[h +    32][1],s0[h +    32][2],s0[h +    32][3]),hideTrace($w[h +    32])=(s1[h +    32]),rgb($w[h +    33])=(s0[h +    33][0],s0[h +    33][1],s0[h +    33][2],s0[h +    33][3]),hideTrace($w[h +    33])=(s1[h +    33]),rgb($w[h +    34])=(s0[h +    34][0],s0[h +    34][1],s0[h +    34][2],s0[h +    34][3]),hideTrace($w[h +    34])=(s1[h +    34]),rgb($w[h +    35])=(s0[h +    35][0],s0[h +    35][1],s0[h +    35][2],s0[h +    35][3]),hideTrace($w[h +    35])=(s1[h +    35]),rgb($w[h +    36])=(s0[h +    36][0],s0[h +    36][1],s0[h +    36][2],s0[h +    36][3]),hideTrace($w[h +    36])=(s1[h +    36]),rgb($w[h +    37])=(s0[h +    37][0],s0[h +    37][1],s0[h +    37][2],s0[h +    37][3]),hideTrace($w[h +    37])=(s1[h +    37]),rgb($w[h +    38])=(s0[h +    38][0],s0[h +    38][1],s0[h +    38][2],s0[h +    38][3]),hideTrace($w[h +    38])=(s1[h +    38]),rgb($w[h +    39])=(s0[h +    39][0],s0[h +    39][1],s0[h +    39][2],s0[h +    39][3]),hideTrace($w[h +    39])=(s1[h +    39]) \
				,rgb($w[h +    40])=(s0[h +    40][0],s0[h +    40][1],s0[h +    40][2],s0[h +    40][3]),hideTrace($w[h +    40])=(s1[h +    40]),rgb($w[h +    41])=(s0[h +    41][0],s0[h +    41][1],s0[h +    41][2],s0[h +    41][3]),hideTrace($w[h +    41])=(s1[h +    41]),rgb($w[h +    42])=(s0[h +    42][0],s0[h +    42][1],s0[h +    42][2],s0[h +    42][3]),hideTrace($w[h +    42])=(s1[h +    42]),rgb($w[h +    43])=(s0[h +    43][0],s0[h +    43][1],s0[h +    43][2],s0[h +    43][3]),hideTrace($w[h +    43])=(s1[h +    43]),rgb($w[h +    44])=(s0[h +    44][0],s0[h +    44][1],s0[h +    44][2],s0[h +    44][3]),hideTrace($w[h +    44])=(s1[h +    44]),rgb($w[h +    45])=(s0[h +    45][0],s0[h +    45][1],s0[h +    45][2],s0[h +    45][3]),hideTrace($w[h +    45])=(s1[h +    45]),rgb($w[h +    46])=(s0[h +    46][0],s0[h +    46][1],s0[h +    46][2],s0[h +    46][3]),hideTrace($w[h +    46])=(s1[h +    46]),rgb($w[h +    47])=(s0[h +    47][0],s0[h +    47][1],s0[h +    47][2],s0[h +    47][3]),hideTrace($w[h +    47])=(s1[h +    47]) \
				,rgb($w[h +    48])=(s0[h +    48][0],s0[h +    48][1],s0[h +    48][2],s0[h +    48][3]),hideTrace($w[h +    48])=(s1[h +    48]),rgb($w[h +    49])=(s0[h +    49][0],s0[h +    49][1],s0[h +    49][2],s0[h +    49][3]),hideTrace($w[h +    49])=(s1[h +    49]),rgb($w[h +    50])=(s0[h +    50][0],s0[h +    50][1],s0[h +    50][2],s0[h +    50][3]),hideTrace($w[h +    50])=(s1[h +    50]),rgb($w[h +    51])=(s0[h +    51][0],s0[h +    51][1],s0[h +    51][2],s0[h +    51][3]),hideTrace($w[h +    51])=(s1[h +    51]),rgb($w[h +    52])=(s0[h +    52][0],s0[h +    52][1],s0[h +    52][2],s0[h +    52][3]),hideTrace($w[h +    52])=(s1[h +    52]),rgb($w[h +    53])=(s0[h +    53][0],s0[h +    53][1],s0[h +    53][2],s0[h +    53][3]),hideTrace($w[h +    53])=(s1[h +    53]),rgb($w[h +    54])=(s0[h +    54][0],s0[h +    54][1],s0[h +    54][2],s0[h +    54][3]),hideTrace($w[h +    54])=(s1[h +    54]),rgb($w[h +    55])=(s0[h +    55][0],s0[h +    55][1],s0[h +    55][2],s0[h +    55][3]),hideTrace($w[h +    55])=(s1[h +    55]) \
				,rgb($w[h +    56])=(s0[h +    56][0],s0[h +    56][1],s0[h +    56][2],s0[h +    56][3]),hideTrace($w[h +    56])=(s1[h +    56]),rgb($w[h +    57])=(s0[h +    57][0],s0[h +    57][1],s0[h +    57][2],s0[h +    57][3]),hideTrace($w[h +    57])=(s1[h +    57]),rgb($w[h +    58])=(s0[h +    58][0],s0[h +    58][1],s0[h +    58][2],s0[h +    58][3]),hideTrace($w[h +    58])=(s1[h +    58]),rgb($w[h +    59])=(s0[h +    59][0],s0[h +    59][1],s0[h +    59][2],s0[h +    59][3]),hideTrace($w[h +    59])=(s1[h +    59]),rgb($w[h +    60])=(s0[h +    60][0],s0[h +    60][1],s0[h +    60][2],s0[h +    60][3]),hideTrace($w[h +    60])=(s1[h +    60]),rgb($w[h +    61])=(s0[h +    61][0],s0[h +    61][1],s0[h +    61][2],s0[h +    61][3]),hideTrace($w[h +    61])=(s1[h +    61]),rgb($w[h +    62])=(s0[h +    62][0],s0[h +    62][1],s0[h +    62][2],s0[h +    62][3]),hideTrace($w[h +    62])=(s1[h +    62]),rgb($w[h +    63])=(s0[h +    63][0],s0[h +    63][1],s0[h +    63][2],s0[h +    63][3]),hideTrace($w[h +    63])=(s1[h +    63]) \
				,rgb($w[h +    64])=(s0[h +    64][0],s0[h +    64][1],s0[h +    64][2],s0[h +    64][3]),hideTrace($w[h +    64])=(s1[h +    64]),rgb($w[h +    65])=(s0[h +    65][0],s0[h +    65][1],s0[h +    65][2],s0[h +    65][3]),hideTrace($w[h +    65])=(s1[h +    65]),rgb($w[h +    66])=(s0[h +    66][0],s0[h +    66][1],s0[h +    66][2],s0[h +    66][3]),hideTrace($w[h +    66])=(s1[h +    66]),rgb($w[h +    67])=(s0[h +    67][0],s0[h +    67][1],s0[h +    67][2],s0[h +    67][3]),hideTrace($w[h +    67])=(s1[h +    67]),rgb($w[h +    68])=(s0[h +    68][0],s0[h +    68][1],s0[h +    68][2],s0[h +    68][3]),hideTrace($w[h +    68])=(s1[h +    68]),rgb($w[h +    69])=(s0[h +    69][0],s0[h +    69][1],s0[h +    69][2],s0[h +    69][3]),hideTrace($w[h +    69])=(s1[h +    69]),rgb($w[h +    70])=(s0[h +    70][0],s0[h +    70][1],s0[h +    70][2],s0[h +    70][3]),hideTrace($w[h +    70])=(s1[h +    70]),rgb($w[h +    71])=(s0[h +    71][0],s0[h +    71][1],s0[h +    71][2],s0[h +    71][3]),hideTrace($w[h +    71])=(s1[h +    71]) \
				,rgb($w[h +    72])=(s0[h +    72][0],s0[h +    72][1],s0[h +    72][2],s0[h +    72][3]),hideTrace($w[h +    72])=(s1[h +    72]),rgb($w[h +    73])=(s0[h +    73][0],s0[h +    73][1],s0[h +    73][2],s0[h +    73][3]),hideTrace($w[h +    73])=(s1[h +    73]),rgb($w[h +    74])=(s0[h +    74][0],s0[h +    74][1],s0[h +    74][2],s0[h +    74][3]),hideTrace($w[h +    74])=(s1[h +    74]),rgb($w[h +    75])=(s0[h +    75][0],s0[h +    75][1],s0[h +    75][2],s0[h +    75][3]),hideTrace($w[h +    75])=(s1[h +    75]),rgb($w[h +    76])=(s0[h +    76][0],s0[h +    76][1],s0[h +    76][2],s0[h +    76][3]),hideTrace($w[h +    76])=(s1[h +    76]),rgb($w[h +    77])=(s0[h +    77][0],s0[h +    77][1],s0[h +    77][2],s0[h +    77][3]),hideTrace($w[h +    77])=(s1[h +    77]),rgb($w[h +    78])=(s0[h +    78][0],s0[h +    78][1],s0[h +    78][2],s0[h +    78][3]),hideTrace($w[h +    78])=(s1[h +    78]),rgb($w[h +    79])=(s0[h +    79][0],s0[h +    79][1],s0[h +    79][2],s0[h +    79][3]),hideTrace($w[h +    79])=(s1[h +    79]) \
				,rgb($w[h +    80])=(s0[h +    80][0],s0[h +    80][1],s0[h +    80][2],s0[h +    80][3]),hideTrace($w[h +    80])=(s1[h +    80]),rgb($w[h +    81])=(s0[h +    81][0],s0[h +    81][1],s0[h +    81][2],s0[h +    81][3]),hideTrace($w[h +    81])=(s1[h +    81]),rgb($w[h +    82])=(s0[h +    82][0],s0[h +    82][1],s0[h +    82][2],s0[h +    82][3]),hideTrace($w[h +    82])=(s1[h +    82]),rgb($w[h +    83])=(s0[h +    83][0],s0[h +    83][1],s0[h +    83][2],s0[h +    83][3]),hideTrace($w[h +    83])=(s1[h +    83]),rgb($w[h +    84])=(s0[h +    84][0],s0[h +    84][1],s0[h +    84][2],s0[h +    84][3]),hideTrace($w[h +    84])=(s1[h +    84]),rgb($w[h +    85])=(s0[h +    85][0],s0[h +    85][1],s0[h +    85][2],s0[h +    85][3]),hideTrace($w[h +    85])=(s1[h +    85]),rgb($w[h +    86])=(s0[h +    86][0],s0[h +    86][1],s0[h +    86][2],s0[h +    86][3]),hideTrace($w[h +    86])=(s1[h +    86]),rgb($w[h +    87])=(s0[h +    87][0],s0[h +    87][1],s0[h +    87][2],s0[h +    87][3]),hideTrace($w[h +    87])=(s1[h +    87]) \
				,rgb($w[h +    88])=(s0[h +    88][0],s0[h +    88][1],s0[h +    88][2],s0[h +    88][3]),hideTrace($w[h +    88])=(s1[h +    88]),rgb($w[h +    89])=(s0[h +    89][0],s0[h +    89][1],s0[h +    89][2],s0[h +    89][3]),hideTrace($w[h +    89])=(s1[h +    89]),rgb($w[h +    90])=(s0[h +    90][0],s0[h +    90][1],s0[h +    90][2],s0[h +    90][3]),hideTrace($w[h +    90])=(s1[h +    90]),rgb($w[h +    91])=(s0[h +    91][0],s0[h +    91][1],s0[h +    91][2],s0[h +    91][3]),hideTrace($w[h +    91])=(s1[h +    91]),rgb($w[h +    92])=(s0[h +    92][0],s0[h +    92][1],s0[h +    92][2],s0[h +    92][3]),hideTrace($w[h +    92])=(s1[h +    92]),rgb($w[h +    93])=(s0[h +    93][0],s0[h +    93][1],s0[h +    93][2],s0[h +    93][3]),hideTrace($w[h +    93])=(s1[h +    93]),rgb($w[h +    94])=(s0[h +    94][0],s0[h +    94][1],s0[h +    94][2],s0[h +    94][3]),hideTrace($w[h +    94])=(s1[h +    94]),rgb($w[h +    95])=(s0[h +    95][0],s0[h +    95][1],s0[h +    95][2],s0[h +    95][3]),hideTrace($w[h +    95])=(s1[h +    95]) \
				,rgb($w[h +    96])=(s0[h +    96][0],s0[h +    96][1],s0[h +    96][2],s0[h +    96][3]),hideTrace($w[h +    96])=(s1[h +    96]),rgb($w[h +    97])=(s0[h +    97][0],s0[h +    97][1],s0[h +    97][2],s0[h +    97][3]),hideTrace($w[h +    97])=(s1[h +    97]),rgb($w[h +    98])=(s0[h +    98][0],s0[h +    98][1],s0[h +    98][2],s0[h +    98][3]),hideTrace($w[h +    98])=(s1[h +    98]),rgb($w[h +    99])=(s0[h +    99][0],s0[h +    99][1],s0[h +    99][2],s0[h +    99][3]),hideTrace($w[h +    99])=(s1[h +    99]),rgb($w[h +   100])=(s0[h +   100][0],s0[h +   100][1],s0[h +   100][2],s0[h +   100][3]),hideTrace($w[h +   100])=(s1[h +   100]),rgb($w[h +   101])=(s0[h +   101][0],s0[h +   101][1],s0[h +   101][2],s0[h +   101][3]),hideTrace($w[h +   101])=(s1[h +   101]),rgb($w[h +   102])=(s0[h +   102][0],s0[h +   102][1],s0[h +   102][2],s0[h +   102][3]),hideTrace($w[h +   102])=(s1[h +   102]),rgb($w[h +   103])=(s0[h +   103][0],s0[h +   103][1],s0[h +   103][2],s0[h +   103][3]),hideTrace($w[h +   103])=(s1[h +   103]) \
				,rgb($w[h +   104])=(s0[h +   104][0],s0[h +   104][1],s0[h +   104][2],s0[h +   104][3]),hideTrace($w[h +   104])=(s1[h +   104]),rgb($w[h +   105])=(s0[h +   105][0],s0[h +   105][1],s0[h +   105][2],s0[h +   105][3]),hideTrace($w[h +   105])=(s1[h +   105]),rgb($w[h +   106])=(s0[h +   106][0],s0[h +   106][1],s0[h +   106][2],s0[h +   106][3]),hideTrace($w[h +   106])=(s1[h +   106]),rgb($w[h +   107])=(s0[h +   107][0],s0[h +   107][1],s0[h +   107][2],s0[h +   107][3]),hideTrace($w[h +   107])=(s1[h +   107]),rgb($w[h +   108])=(s0[h +   108][0],s0[h +   108][1],s0[h +   108][2],s0[h +   108][3]),hideTrace($w[h +   108])=(s1[h +   108]),rgb($w[h +   109])=(s0[h +   109][0],s0[h +   109][1],s0[h +   109][2],s0[h +   109][3]),hideTrace($w[h +   109])=(s1[h +   109]),rgb($w[h +   110])=(s0[h +   110][0],s0[h +   110][1],s0[h +   110][2],s0[h +   110][3]),hideTrace($w[h +   110])=(s1[h +   110]),rgb($w[h +   111])=(s0[h +   111][0],s0[h +   111][1],s0[h +   111][2],s0[h +   111][3]),hideTrace($w[h +   111])=(s1[h +   111]) \
				,rgb($w[h +   112])=(s0[h +   112][0],s0[h +   112][1],s0[h +   112][2],s0[h +   112][3]),hideTrace($w[h +   112])=(s1[h +   112]),rgb($w[h +   113])=(s0[h +   113][0],s0[h +   113][1],s0[h +   113][2],s0[h +   113][3]),hideTrace($w[h +   113])=(s1[h +   113]),rgb($w[h +   114])=(s0[h +   114][0],s0[h +   114][1],s0[h +   114][2],s0[h +   114][3]),hideTrace($w[h +   114])=(s1[h +   114]),rgb($w[h +   115])=(s0[h +   115][0],s0[h +   115][1],s0[h +   115][2],s0[h +   115][3]),hideTrace($w[h +   115])=(s1[h +   115]),rgb($w[h +   116])=(s0[h +   116][0],s0[h +   116][1],s0[h +   116][2],s0[h +   116][3]),hideTrace($w[h +   116])=(s1[h +   116]),rgb($w[h +   117])=(s0[h +   117][0],s0[h +   117][1],s0[h +   117][2],s0[h +   117][3]),hideTrace($w[h +   117])=(s1[h +   117]),rgb($w[h +   118])=(s0[h +   118][0],s0[h +   118][1],s0[h +   118][2],s0[h +   118][3]),hideTrace($w[h +   118])=(s1[h +   118]),rgb($w[h +   119])=(s0[h +   119][0],s0[h +   119][1],s0[h +   119][2],s0[h +   119][3]),hideTrace($w[h +   119])=(s1[h +   119]) \
				,rgb($w[h +   120])=(s0[h +   120][0],s0[h +   120][1],s0[h +   120][2],s0[h +   120][3]),hideTrace($w[h +   120])=(s1[h +   120]),rgb($w[h +   121])=(s0[h +   121][0],s0[h +   121][1],s0[h +   121][2],s0[h +   121][3]),hideTrace($w[h +   121])=(s1[h +   121]),rgb($w[h +   122])=(s0[h +   122][0],s0[h +   122][1],s0[h +   122][2],s0[h +   122][3]),hideTrace($w[h +   122])=(s1[h +   122]),rgb($w[h +   123])=(s0[h +   123][0],s0[h +   123][1],s0[h +   123][2],s0[h +   123][3]),hideTrace($w[h +   123])=(s1[h +   123]),rgb($w[h +   124])=(s0[h +   124][0],s0[h +   124][1],s0[h +   124][2],s0[h +   124][3]),hideTrace($w[h +   124])=(s1[h +   124]),rgb($w[h +   125])=(s0[h +   125][0],s0[h +   125][1],s0[h +   125][2],s0[h +   125][3]),hideTrace($w[h +   125])=(s1[h +   125]),rgb($w[h +   126])=(s0[h +   126][0],s0[h +   126][1],s0[h +   126][2],s0[h +   126][3]),hideTrace($w[h +   126])=(s1[h +   126]),rgb($w[h +   127])=(s0[h +   127][0],s0[h +   127][1],s0[h +   127][2],s0[h +   127][3]),hideTrace($w[h +   127])=(s1[h +   127]) \
				,rgb($w[h +   128])=(s0[h +   128][0],s0[h +   128][1],s0[h +   128][2],s0[h +   128][3]),hideTrace($w[h +   128])=(s1[h +   128]),rgb($w[h +   129])=(s0[h +   129][0],s0[h +   129][1],s0[h +   129][2],s0[h +   129][3]),hideTrace($w[h +   129])=(s1[h +   129]),rgb($w[h +   130])=(s0[h +   130][0],s0[h +   130][1],s0[h +   130][2],s0[h +   130][3]),hideTrace($w[h +   130])=(s1[h +   130]),rgb($w[h +   131])=(s0[h +   131][0],s0[h +   131][1],s0[h +   131][2],s0[h +   131][3]),hideTrace($w[h +   131])=(s1[h +   131]),rgb($w[h +   132])=(s0[h +   132][0],s0[h +   132][1],s0[h +   132][2],s0[h +   132][3]),hideTrace($w[h +   132])=(s1[h +   132]),rgb($w[h +   133])=(s0[h +   133][0],s0[h +   133][1],s0[h +   133][2],s0[h +   133][3]),hideTrace($w[h +   133])=(s1[h +   133]),rgb($w[h +   134])=(s0[h +   134][0],s0[h +   134][1],s0[h +   134][2],s0[h +   134][3]),hideTrace($w[h +   134])=(s1[h +   134]),rgb($w[h +   135])=(s0[h +   135][0],s0[h +   135][1],s0[h +   135][2],s0[h +   135][3]),hideTrace($w[h +   135])=(s1[h +   135]) \
				,rgb($w[h +   136])=(s0[h +   136][0],s0[h +   136][1],s0[h +   136][2],s0[h +   136][3]),hideTrace($w[h +   136])=(s1[h +   136]),rgb($w[h +   137])=(s0[h +   137][0],s0[h +   137][1],s0[h +   137][2],s0[h +   137][3]),hideTrace($w[h +   137])=(s1[h +   137]),rgb($w[h +   138])=(s0[h +   138][0],s0[h +   138][1],s0[h +   138][2],s0[h +   138][3]),hideTrace($w[h +   138])=(s1[h +   138]),rgb($w[h +   139])=(s0[h +   139][0],s0[h +   139][1],s0[h +   139][2],s0[h +   139][3]),hideTrace($w[h +   139])=(s1[h +   139]),rgb($w[h +   140])=(s0[h +   140][0],s0[h +   140][1],s0[h +   140][2],s0[h +   140][3]),hideTrace($w[h +   140])=(s1[h +   140]),rgb($w[h +   141])=(s0[h +   141][0],s0[h +   141][1],s0[h +   141][2],s0[h +   141][3]),hideTrace($w[h +   141])=(s1[h +   141]),rgb($w[h +   142])=(s0[h +   142][0],s0[h +   142][1],s0[h +   142][2],s0[h +   142][3]),hideTrace($w[h +   142])=(s1[h +   142]),rgb($w[h +   143])=(s0[h +   143][0],s0[h +   143][1],s0[h +   143][2],s0[h +   143][3]),hideTrace($w[h +   143])=(s1[h +   143]) \
				,rgb($w[h +   144])=(s0[h +   144][0],s0[h +   144][1],s0[h +   144][2],s0[h +   144][3]),hideTrace($w[h +   144])=(s1[h +   144]),rgb($w[h +   145])=(s0[h +   145][0],s0[h +   145][1],s0[h +   145][2],s0[h +   145][3]),hideTrace($w[h +   145])=(s1[h +   145]),rgb($w[h +   146])=(s0[h +   146][0],s0[h +   146][1],s0[h +   146][2],s0[h +   146][3]),hideTrace($w[h +   146])=(s1[h +   146]),rgb($w[h +   147])=(s0[h +   147][0],s0[h +   147][1],s0[h +   147][2],s0[h +   147][3]),hideTrace($w[h +   147])=(s1[h +   147]),rgb($w[h +   148])=(s0[h +   148][0],s0[h +   148][1],s0[h +   148][2],s0[h +   148][3]),hideTrace($w[h +   148])=(s1[h +   148]),rgb($w[h +   149])=(s0[h +   149][0],s0[h +   149][1],s0[h +   149][2],s0[h +   149][3]),hideTrace($w[h +   149])=(s1[h +   149]),rgb($w[h +   150])=(s0[h +   150][0],s0[h +   150][1],s0[h +   150][2],s0[h +   150][3]),hideTrace($w[h +   150])=(s1[h +   150]),rgb($w[h +   151])=(s0[h +   151][0],s0[h +   151][1],s0[h +   151][2],s0[h +   151][3]),hideTrace($w[h +   151])=(s1[h +   151]) \
				,rgb($w[h +   152])=(s0[h +   152][0],s0[h +   152][1],s0[h +   152][2],s0[h +   152][3]),hideTrace($w[h +   152])=(s1[h +   152]),rgb($w[h +   153])=(s0[h +   153][0],s0[h +   153][1],s0[h +   153][2],s0[h +   153][3]),hideTrace($w[h +   153])=(s1[h +   153]),rgb($w[h +   154])=(s0[h +   154][0],s0[h +   154][1],s0[h +   154][2],s0[h +   154][3]),hideTrace($w[h +   154])=(s1[h +   154]),rgb($w[h +   155])=(s0[h +   155][0],s0[h +   155][1],s0[h +   155][2],s0[h +   155][3]),hideTrace($w[h +   155])=(s1[h +   155]),rgb($w[h +   156])=(s0[h +   156][0],s0[h +   156][1],s0[h +   156][2],s0[h +   156][3]),hideTrace($w[h +   156])=(s1[h +   156]),rgb($w[h +   157])=(s0[h +   157][0],s0[h +   157][1],s0[h +   157][2],s0[h +   157][3]),hideTrace($w[h +   157])=(s1[h +   157]),rgb($w[h +   158])=(s0[h +   158][0],s0[h +   158][1],s0[h +   158][2],s0[h +   158][3]),hideTrace($w[h +   158])=(s1[h +   158]),rgb($w[h +   159])=(s0[h +   159][0],s0[h +   159][1],s0[h +   159][2],s0[h +   159][3]),hideTrace($w[h +   159])=(s1[h +   159]) \
				,rgb($w[h +   160])=(s0[h +   160][0],s0[h +   160][1],s0[h +   160][2],s0[h +   160][3]),hideTrace($w[h +   160])=(s1[h +   160]),rgb($w[h +   161])=(s0[h +   161][0],s0[h +   161][1],s0[h +   161][2],s0[h +   161][3]),hideTrace($w[h +   161])=(s1[h +   161]),rgb($w[h +   162])=(s0[h +   162][0],s0[h +   162][1],s0[h +   162][2],s0[h +   162][3]),hideTrace($w[h +   162])=(s1[h +   162]),rgb($w[h +   163])=(s0[h +   163][0],s0[h +   163][1],s0[h +   163][2],s0[h +   163][3]),hideTrace($w[h +   163])=(s1[h +   163]),rgb($w[h +   164])=(s0[h +   164][0],s0[h +   164][1],s0[h +   164][2],s0[h +   164][3]),hideTrace($w[h +   164])=(s1[h +   164]),rgb($w[h +   165])=(s0[h +   165][0],s0[h +   165][1],s0[h +   165][2],s0[h +   165][3]),hideTrace($w[h +   165])=(s1[h +   165]),rgb($w[h +   166])=(s0[h +   166][0],s0[h +   166][1],s0[h +   166][2],s0[h +   166][3]),hideTrace($w[h +   166])=(s1[h +   166]),rgb($w[h +   167])=(s0[h +   167][0],s0[h +   167][1],s0[h +   167][2],s0[h +   167][3]),hideTrace($w[h +   167])=(s1[h +   167]) \
				,rgb($w[h +   168])=(s0[h +   168][0],s0[h +   168][1],s0[h +   168][2],s0[h +   168][3]),hideTrace($w[h +   168])=(s1[h +   168]),rgb($w[h +   169])=(s0[h +   169][0],s0[h +   169][1],s0[h +   169][2],s0[h +   169][3]),hideTrace($w[h +   169])=(s1[h +   169]),rgb($w[h +   170])=(s0[h +   170][0],s0[h +   170][1],s0[h +   170][2],s0[h +   170][3]),hideTrace($w[h +   170])=(s1[h +   170]),rgb($w[h +   171])=(s0[h +   171][0],s0[h +   171][1],s0[h +   171][2],s0[h +   171][3]),hideTrace($w[h +   171])=(s1[h +   171]),rgb($w[h +   172])=(s0[h +   172][0],s0[h +   172][1],s0[h +   172][2],s0[h +   172][3]),hideTrace($w[h +   172])=(s1[h +   172]),rgb($w[h +   173])=(s0[h +   173][0],s0[h +   173][1],s0[h +   173][2],s0[h +   173][3]),hideTrace($w[h +   173])=(s1[h +   173]),rgb($w[h +   174])=(s0[h +   174][0],s0[h +   174][1],s0[h +   174][2],s0[h +   174][3]),hideTrace($w[h +   174])=(s1[h +   174]),rgb($w[h +   175])=(s0[h +   175][0],s0[h +   175][1],s0[h +   175][2],s0[h +   175][3]),hideTrace($w[h +   175])=(s1[h +   175]) \
				,rgb($w[h +   176])=(s0[h +   176][0],s0[h +   176][1],s0[h +   176][2],s0[h +   176][3]),hideTrace($w[h +   176])=(s1[h +   176]),rgb($w[h +   177])=(s0[h +   177][0],s0[h +   177][1],s0[h +   177][2],s0[h +   177][3]),hideTrace($w[h +   177])=(s1[h +   177]),rgb($w[h +   178])=(s0[h +   178][0],s0[h +   178][1],s0[h +   178][2],s0[h +   178][3]),hideTrace($w[h +   178])=(s1[h +   178]),rgb($w[h +   179])=(s0[h +   179][0],s0[h +   179][1],s0[h +   179][2],s0[h +   179][3]),hideTrace($w[h +   179])=(s1[h +   179]),rgb($w[h +   180])=(s0[h +   180][0],s0[h +   180][1],s0[h +   180][2],s0[h +   180][3]),hideTrace($w[h +   180])=(s1[h +   180]),rgb($w[h +   181])=(s0[h +   181][0],s0[h +   181][1],s0[h +   181][2],s0[h +   181][3]),hideTrace($w[h +   181])=(s1[h +   181]),rgb($w[h +   182])=(s0[h +   182][0],s0[h +   182][1],s0[h +   182][2],s0[h +   182][3]),hideTrace($w[h +   182])=(s1[h +   182]),rgb($w[h +   183])=(s0[h +   183][0],s0[h +   183][1],s0[h +   183][2],s0[h +   183][3]),hideTrace($w[h +   183])=(s1[h +   183]) \
				,rgb($w[h +   184])=(s0[h +   184][0],s0[h +   184][1],s0[h +   184][2],s0[h +   184][3]),hideTrace($w[h +   184])=(s1[h +   184]),rgb($w[h +   185])=(s0[h +   185][0],s0[h +   185][1],s0[h +   185][2],s0[h +   185][3]),hideTrace($w[h +   185])=(s1[h +   185]),rgb($w[h +   186])=(s0[h +   186][0],s0[h +   186][1],s0[h +   186][2],s0[h +   186][3]),hideTrace($w[h +   186])=(s1[h +   186]),rgb($w[h +   187])=(s0[h +   187][0],s0[h +   187][1],s0[h +   187][2],s0[h +   187][3]),hideTrace($w[h +   187])=(s1[h +   187]),rgb($w[h +   188])=(s0[h +   188][0],s0[h +   188][1],s0[h +   188][2],s0[h +   188][3]),hideTrace($w[h +   188])=(s1[h +   188]),rgb($w[h +   189])=(s0[h +   189][0],s0[h +   189][1],s0[h +   189][2],s0[h +   189][3]),hideTrace($w[h +   189])=(s1[h +   189]),rgb($w[h +   190])=(s0[h +   190][0],s0[h +   190][1],s0[h +   190][2],s0[h +   190][3]),hideTrace($w[h +   190])=(s1[h +   190]),rgb($w[h +   191])=(s0[h +   191][0],s0[h +   191][1],s0[h +   191][2],s0[h +   191][3]),hideTrace($w[h +   191])=(s1[h +   191]) \
				,rgb($w[h +   192])=(s0[h +   192][0],s0[h +   192][1],s0[h +   192][2],s0[h +   192][3]),hideTrace($w[h +   192])=(s1[h +   192]),rgb($w[h +   193])=(s0[h +   193][0],s0[h +   193][1],s0[h +   193][2],s0[h +   193][3]),hideTrace($w[h +   193])=(s1[h +   193]),rgb($w[h +   194])=(s0[h +   194][0],s0[h +   194][1],s0[h +   194][2],s0[h +   194][3]),hideTrace($w[h +   194])=(s1[h +   194]),rgb($w[h +   195])=(s0[h +   195][0],s0[h +   195][1],s0[h +   195][2],s0[h +   195][3]),hideTrace($w[h +   195])=(s1[h +   195]),rgb($w[h +   196])=(s0[h +   196][0],s0[h +   196][1],s0[h +   196][2],s0[h +   196][3]),hideTrace($w[h +   196])=(s1[h +   196]),rgb($w[h +   197])=(s0[h +   197][0],s0[h +   197][1],s0[h +   197][2],s0[h +   197][3]),hideTrace($w[h +   197])=(s1[h +   197]),rgb($w[h +   198])=(s0[h +   198][0],s0[h +   198][1],s0[h +   198][2],s0[h +   198][3]),hideTrace($w[h +   198])=(s1[h +   198]),rgb($w[h +   199])=(s0[h +   199][0],s0[h +   199][1],s0[h +   199][2],s0[h +   199][3]),hideTrace($w[h +   199])=(s1[h +   199]) \
				,rgb($w[h +   200])=(s0[h +   200][0],s0[h +   200][1],s0[h +   200][2],s0[h +   200][3]),hideTrace($w[h +   200])=(s1[h +   200]),rgb($w[h +   201])=(s0[h +   201][0],s0[h +   201][1],s0[h +   201][2],s0[h +   201][3]),hideTrace($w[h +   201])=(s1[h +   201]),rgb($w[h +   202])=(s0[h +   202][0],s0[h +   202][1],s0[h +   202][2],s0[h +   202][3]),hideTrace($w[h +   202])=(s1[h +   202]),rgb($w[h +   203])=(s0[h +   203][0],s0[h +   203][1],s0[h +   203][2],s0[h +   203][3]),hideTrace($w[h +   203])=(s1[h +   203]),rgb($w[h +   204])=(s0[h +   204][0],s0[h +   204][1],s0[h +   204][2],s0[h +   204][3]),hideTrace($w[h +   204])=(s1[h +   204]),rgb($w[h +   205])=(s0[h +   205][0],s0[h +   205][1],s0[h +   205][2],s0[h +   205][3]),hideTrace($w[h +   205])=(s1[h +   205]),rgb($w[h +   206])=(s0[h +   206][0],s0[h +   206][1],s0[h +   206][2],s0[h +   206][3]),hideTrace($w[h +   206])=(s1[h +   206]),rgb($w[h +   207])=(s0[h +   207][0],s0[h +   207][1],s0[h +   207][2],s0[h +   207][3]),hideTrace($w[h +   207])=(s1[h +   207]) \
				,rgb($w[h +   208])=(s0[h +   208][0],s0[h +   208][1],s0[h +   208][2],s0[h +   208][3]),hideTrace($w[h +   208])=(s1[h +   208]),rgb($w[h +   209])=(s0[h +   209][0],s0[h +   209][1],s0[h +   209][2],s0[h +   209][3]),hideTrace($w[h +   209])=(s1[h +   209]),rgb($w[h +   210])=(s0[h +   210][0],s0[h +   210][1],s0[h +   210][2],s0[h +   210][3]),hideTrace($w[h +   210])=(s1[h +   210]),rgb($w[h +   211])=(s0[h +   211][0],s0[h +   211][1],s0[h +   211][2],s0[h +   211][3]),hideTrace($w[h +   211])=(s1[h +   211]),rgb($w[h +   212])=(s0[h +   212][0],s0[h +   212][1],s0[h +   212][2],s0[h +   212][3]),hideTrace($w[h +   212])=(s1[h +   212]),rgb($w[h +   213])=(s0[h +   213][0],s0[h +   213][1],s0[h +   213][2],s0[h +   213][3]),hideTrace($w[h +   213])=(s1[h +   213]),rgb($w[h +   214])=(s0[h +   214][0],s0[h +   214][1],s0[h +   214][2],s0[h +   214][3]),hideTrace($w[h +   214])=(s1[h +   214]),rgb($w[h +   215])=(s0[h +   215][0],s0[h +   215][1],s0[h +   215][2],s0[h +   215][3]),hideTrace($w[h +   215])=(s1[h +   215]) \
				,rgb($w[h +   216])=(s0[h +   216][0],s0[h +   216][1],s0[h +   216][2],s0[h +   216][3]),hideTrace($w[h +   216])=(s1[h +   216]),rgb($w[h +   217])=(s0[h +   217][0],s0[h +   217][1],s0[h +   217][2],s0[h +   217][3]),hideTrace($w[h +   217])=(s1[h +   217]),rgb($w[h +   218])=(s0[h +   218][0],s0[h +   218][1],s0[h +   218][2],s0[h +   218][3]),hideTrace($w[h +   218])=(s1[h +   218]),rgb($w[h +   219])=(s0[h +   219][0],s0[h +   219][1],s0[h +   219][2],s0[h +   219][3]),hideTrace($w[h +   219])=(s1[h +   219]),rgb($w[h +   220])=(s0[h +   220][0],s0[h +   220][1],s0[h +   220][2],s0[h +   220][3]),hideTrace($w[h +   220])=(s1[h +   220]),rgb($w[h +   221])=(s0[h +   221][0],s0[h +   221][1],s0[h +   221][2],s0[h +   221][3]),hideTrace($w[h +   221])=(s1[h +   221]),rgb($w[h +   222])=(s0[h +   222][0],s0[h +   222][1],s0[h +   222][2],s0[h +   222][3]),hideTrace($w[h +   222])=(s1[h +   222]),rgb($w[h +   223])=(s0[h +   223][0],s0[h +   223][1],s0[h +   223][2],s0[h +   223][3]),hideTrace($w[h +   223])=(s1[h +   223]) \
				,rgb($w[h +   224])=(s0[h +   224][0],s0[h +   224][1],s0[h +   224][2],s0[h +   224][3]),hideTrace($w[h +   224])=(s1[h +   224]),rgb($w[h +   225])=(s0[h +   225][0],s0[h +   225][1],s0[h +   225][2],s0[h +   225][3]),hideTrace($w[h +   225])=(s1[h +   225]),rgb($w[h +   226])=(s0[h +   226][0],s0[h +   226][1],s0[h +   226][2],s0[h +   226][3]),hideTrace($w[h +   226])=(s1[h +   226]),rgb($w[h +   227])=(s0[h +   227][0],s0[h +   227][1],s0[h +   227][2],s0[h +   227][3]),hideTrace($w[h +   227])=(s1[h +   227]),rgb($w[h +   228])=(s0[h +   228][0],s0[h +   228][1],s0[h +   228][2],s0[h +   228][3]),hideTrace($w[h +   228])=(s1[h +   228]),rgb($w[h +   229])=(s0[h +   229][0],s0[h +   229][1],s0[h +   229][2],s0[h +   229][3]),hideTrace($w[h +   229])=(s1[h +   229]),rgb($w[h +   230])=(s0[h +   230][0],s0[h +   230][1],s0[h +   230][2],s0[h +   230][3]),hideTrace($w[h +   230])=(s1[h +   230]),rgb($w[h +   231])=(s0[h +   231][0],s0[h +   231][1],s0[h +   231][2],s0[h +   231][3]),hideTrace($w[h +   231])=(s1[h +   231]) \
				,rgb($w[h +   232])=(s0[h +   232][0],s0[h +   232][1],s0[h +   232][2],s0[h +   232][3]),hideTrace($w[h +   232])=(s1[h +   232]),rgb($w[h +   233])=(s0[h +   233][0],s0[h +   233][1],s0[h +   233][2],s0[h +   233][3]),hideTrace($w[h +   233])=(s1[h +   233]),rgb($w[h +   234])=(s0[h +   234][0],s0[h +   234][1],s0[h +   234][2],s0[h +   234][3]),hideTrace($w[h +   234])=(s1[h +   234]),rgb($w[h +   235])=(s0[h +   235][0],s0[h +   235][1],s0[h +   235][2],s0[h +   235][3]),hideTrace($w[h +   235])=(s1[h +   235]),rgb($w[h +   236])=(s0[h +   236][0],s0[h +   236][1],s0[h +   236][2],s0[h +   236][3]),hideTrace($w[h +   236])=(s1[h +   236]),rgb($w[h +   237])=(s0[h +   237][0],s0[h +   237][1],s0[h +   237][2],s0[h +   237][3]),hideTrace($w[h +   237])=(s1[h +   237]),rgb($w[h +   238])=(s0[h +   238][0],s0[h +   238][1],s0[h +   238][2],s0[h +   238][3]),hideTrace($w[h +   238])=(s1[h +   238]),rgb($w[h +   239])=(s0[h +   239][0],s0[h +   239][1],s0[h +   239][2],s0[h +   239][3]),hideTrace($w[h +   239])=(s1[h +   239]) \
				,rgb($w[h +   240])=(s0[h +   240][0],s0[h +   240][1],s0[h +   240][2],s0[h +   240][3]),hideTrace($w[h +   240])=(s1[h +   240]),rgb($w[h +   241])=(s0[h +   241][0],s0[h +   241][1],s0[h +   241][2],s0[h +   241][3]),hideTrace($w[h +   241])=(s1[h +   241]),rgb($w[h +   242])=(s0[h +   242][0],s0[h +   242][1],s0[h +   242][2],s0[h +   242][3]),hideTrace($w[h +   242])=(s1[h +   242]),rgb($w[h +   243])=(s0[h +   243][0],s0[h +   243][1],s0[h +   243][2],s0[h +   243][3]),hideTrace($w[h +   243])=(s1[h +   243]),rgb($w[h +   244])=(s0[h +   244][0],s0[h +   244][1],s0[h +   244][2],s0[h +   244][3]),hideTrace($w[h +   244])=(s1[h +   244]),rgb($w[h +   245])=(s0[h +   245][0],s0[h +   245][1],s0[h +   245][2],s0[h +   245][3]),hideTrace($w[h +   245])=(s1[h +   245]),rgb($w[h +   246])=(s0[h +   246][0],s0[h +   246][1],s0[h +   246][2],s0[h +   246][3]),hideTrace($w[h +   246])=(s1[h +   246]),rgb($w[h +   247])=(s0[h +   247][0],s0[h +   247][1],s0[h +   247][2],s0[h +   247][3]),hideTrace($w[h +   247])=(s1[h +   247]) \
				,rgb($w[h +   248])=(s0[h +   248][0],s0[h +   248][1],s0[h +   248][2],s0[h +   248][3]),hideTrace($w[h +   248])=(s1[h +   248]),rgb($w[h +   249])=(s0[h +   249][0],s0[h +   249][1],s0[h +   249][2],s0[h +   249][3]),hideTrace($w[h +   249])=(s1[h +   249]),rgb($w[h +   250])=(s0[h +   250][0],s0[h +   250][1],s0[h +   250][2],s0[h +   250][3]),hideTrace($w[h +   250])=(s1[h +   250]),rgb($w[h +   251])=(s0[h +   251][0],s0[h +   251][1],s0[h +   251][2],s0[h +   251][3]),hideTrace($w[h +   251])=(s1[h +   251]),rgb($w[h +   252])=(s0[h +   252][0],s0[h +   252][1],s0[h +   252][2],s0[h +   252][3]),hideTrace($w[h +   252])=(s1[h +   252]),rgb($w[h +   253])=(s0[h +   253][0],s0[h +   253][1],s0[h +   253][2],s0[h +   253][3]),hideTrace($w[h +   253])=(s1[h +   253]),rgb($w[h +   254])=(s0[h +   254][0],s0[h +   254][1],s0[h +   254][2],s0[h +   254][3]),hideTrace($w[h +   254])=(s1[h +   254]),rgb($w[h +   255])=(s0[h +   255][0],s0[h +   255][1],s0[h +   255][2],s0[h +   255][3]),hideTrace($w[h +   255])=(s1[h +   255]) \
				,rgb($w[h +   256])=(s0[h +   256][0],s0[h +   256][1],s0[h +   256][2],s0[h +   256][3]),hideTrace($w[h +   256])=(s1[h +   256]),rgb($w[h +   257])=(s0[h +   257][0],s0[h +   257][1],s0[h +   257][2],s0[h +   257][3]),hideTrace($w[h +   257])=(s1[h +   257]),rgb($w[h +   258])=(s0[h +   258][0],s0[h +   258][1],s0[h +   258][2],s0[h +   258][3]),hideTrace($w[h +   258])=(s1[h +   258]),rgb($w[h +   259])=(s0[h +   259][0],s0[h +   259][1],s0[h +   259][2],s0[h +   259][3]),hideTrace($w[h +   259])=(s1[h +   259]),rgb($w[h +   260])=(s0[h +   260][0],s0[h +   260][1],s0[h +   260][2],s0[h +   260][3]),hideTrace($w[h +   260])=(s1[h +   260]),rgb($w[h +   261])=(s0[h +   261][0],s0[h +   261][1],s0[h +   261][2],s0[h +   261][3]),hideTrace($w[h +   261])=(s1[h +   261]),rgb($w[h +   262])=(s0[h +   262][0],s0[h +   262][1],s0[h +   262][2],s0[h +   262][3]),hideTrace($w[h +   262])=(s1[h +   262]),rgb($w[h +   263])=(s0[h +   263][0],s0[h +   263][1],s0[h +   263][2],s0[h +   263][3]),hideTrace($w[h +   263])=(s1[h +   263]) \
				,rgb($w[h +   264])=(s0[h +   264][0],s0[h +   264][1],s0[h +   264][2],s0[h +   264][3]),hideTrace($w[h +   264])=(s1[h +   264]),rgb($w[h +   265])=(s0[h +   265][0],s0[h +   265][1],s0[h +   265][2],s0[h +   265][3]),hideTrace($w[h +   265])=(s1[h +   265]),rgb($w[h +   266])=(s0[h +   266][0],s0[h +   266][1],s0[h +   266][2],s0[h +   266][3]),hideTrace($w[h +   266])=(s1[h +   266]),rgb($w[h +   267])=(s0[h +   267][0],s0[h +   267][1],s0[h +   267][2],s0[h +   267][3]),hideTrace($w[h +   267])=(s1[h +   267]),rgb($w[h +   268])=(s0[h +   268][0],s0[h +   268][1],s0[h +   268][2],s0[h +   268][3]),hideTrace($w[h +   268])=(s1[h +   268]),rgb($w[h +   269])=(s0[h +   269][0],s0[h +   269][1],s0[h +   269][2],s0[h +   269][3]),hideTrace($w[h +   269])=(s1[h +   269]),rgb($w[h +   270])=(s0[h +   270][0],s0[h +   270][1],s0[h +   270][2],s0[h +   270][3]),hideTrace($w[h +   270])=(s1[h +   270]),rgb($w[h +   271])=(s0[h +   271][0],s0[h +   271][1],s0[h +   271][2],s0[h +   271][3]),hideTrace($w[h +   271])=(s1[h +   271]) \
				,rgb($w[h +   272])=(s0[h +   272][0],s0[h +   272][1],s0[h +   272][2],s0[h +   272][3]),hideTrace($w[h +   272])=(s1[h +   272]),rgb($w[h +   273])=(s0[h +   273][0],s0[h +   273][1],s0[h +   273][2],s0[h +   273][3]),hideTrace($w[h +   273])=(s1[h +   273]),rgb($w[h +   274])=(s0[h +   274][0],s0[h +   274][1],s0[h +   274][2],s0[h +   274][3]),hideTrace($w[h +   274])=(s1[h +   274]),rgb($w[h +   275])=(s0[h +   275][0],s0[h +   275][1],s0[h +   275][2],s0[h +   275][3]),hideTrace($w[h +   275])=(s1[h +   275]),rgb($w[h +   276])=(s0[h +   276][0],s0[h +   276][1],s0[h +   276][2],s0[h +   276][3]),hideTrace($w[h +   276])=(s1[h +   276]),rgb($w[h +   277])=(s0[h +   277][0],s0[h +   277][1],s0[h +   277][2],s0[h +   277][3]),hideTrace($w[h +   277])=(s1[h +   277]),rgb($w[h +   278])=(s0[h +   278][0],s0[h +   278][1],s0[h +   278][2],s0[h +   278][3]),hideTrace($w[h +   278])=(s1[h +   278]),rgb($w[h +   279])=(s0[h +   279][0],s0[h +   279][1],s0[h +   279][2],s0[h +   279][3]),hideTrace($w[h +   279])=(s1[h +   279]) \
				,rgb($w[h +   280])=(s0[h +   280][0],s0[h +   280][1],s0[h +   280][2],s0[h +   280][3]),hideTrace($w[h +   280])=(s1[h +   280]),rgb($w[h +   281])=(s0[h +   281][0],s0[h +   281][1],s0[h +   281][2],s0[h +   281][3]),hideTrace($w[h +   281])=(s1[h +   281]),rgb($w[h +   282])=(s0[h +   282][0],s0[h +   282][1],s0[h +   282][2],s0[h +   282][3]),hideTrace($w[h +   282])=(s1[h +   282]),rgb($w[h +   283])=(s0[h +   283][0],s0[h +   283][1],s0[h +   283][2],s0[h +   283][3]),hideTrace($w[h +   283])=(s1[h +   283]),rgb($w[h +   284])=(s0[h +   284][0],s0[h +   284][1],s0[h +   284][2],s0[h +   284][3]),hideTrace($w[h +   284])=(s1[h +   284]),rgb($w[h +   285])=(s0[h +   285][0],s0[h +   285][1],s0[h +   285][2],s0[h +   285][3]),hideTrace($w[h +   285])=(s1[h +   285]),rgb($w[h +   286])=(s0[h +   286][0],s0[h +   286][1],s0[h +   286][2],s0[h +   286][3]),hideTrace($w[h +   286])=(s1[h +   286]),rgb($w[h +   287])=(s0[h +   287][0],s0[h +   287][1],s0[h +   287][2],s0[h +   287][3]),hideTrace($w[h +   287])=(s1[h +   287]) \
				,rgb($w[h +   288])=(s0[h +   288][0],s0[h +   288][1],s0[h +   288][2],s0[h +   288][3]),hideTrace($w[h +   288])=(s1[h +   288]),rgb($w[h +   289])=(s0[h +   289][0],s0[h +   289][1],s0[h +   289][2],s0[h +   289][3]),hideTrace($w[h +   289])=(s1[h +   289]),rgb($w[h +   290])=(s0[h +   290][0],s0[h +   290][1],s0[h +   290][2],s0[h +   290][3]),hideTrace($w[h +   290])=(s1[h +   290]),rgb($w[h +   291])=(s0[h +   291][0],s0[h +   291][1],s0[h +   291][2],s0[h +   291][3]),hideTrace($w[h +   291])=(s1[h +   291]),rgb($w[h +   292])=(s0[h +   292][0],s0[h +   292][1],s0[h +   292][2],s0[h +   292][3]),hideTrace($w[h +   292])=(s1[h +   292]),rgb($w[h +   293])=(s0[h +   293][0],s0[h +   293][1],s0[h +   293][2],s0[h +   293][3]),hideTrace($w[h +   293])=(s1[h +   293]),rgb($w[h +   294])=(s0[h +   294][0],s0[h +   294][1],s0[h +   294][2],s0[h +   294][3]),hideTrace($w[h +   294])=(s1[h +   294]),rgb($w[h +   295])=(s0[h +   295][0],s0[h +   295][1],s0[h +   295][2],s0[h +   295][3]),hideTrace($w[h +   295])=(s1[h +   295]) \
				,rgb($w[h +   296])=(s0[h +   296][0],s0[h +   296][1],s0[h +   296][2],s0[h +   296][3]),hideTrace($w[h +   296])=(s1[h +   296]),rgb($w[h +   297])=(s0[h +   297][0],s0[h +   297][1],s0[h +   297][2],s0[h +   297][3]),hideTrace($w[h +   297])=(s1[h +   297]),rgb($w[h +   298])=(s0[h +   298][0],s0[h +   298][1],s0[h +   298][2],s0[h +   298][3]),hideTrace($w[h +   298])=(s1[h +   298]),rgb($w[h +   299])=(s0[h +   299][0],s0[h +   299][1],s0[h +   299][2],s0[h +   299][3]),hideTrace($w[h +   299])=(s1[h +   299]),rgb($w[h +   300])=(s0[h +   300][0],s0[h +   300][1],s0[h +   300][2],s0[h +   300][3]),hideTrace($w[h +   300])=(s1[h +   300]),rgb($w[h +   301])=(s0[h +   301][0],s0[h +   301][1],s0[h +   301][2],s0[h +   301][3]),hideTrace($w[h +   301])=(s1[h +   301]),rgb($w[h +   302])=(s0[h +   302][0],s0[h +   302][1],s0[h +   302][2],s0[h +   302][3]),hideTrace($w[h +   302])=(s1[h +   302]),rgb($w[h +   303])=(s0[h +   303][0],s0[h +   303][1],s0[h +   303][2],s0[h +   303][3]),hideTrace($w[h +   303])=(s1[h +   303]) \
				,rgb($w[h +   304])=(s0[h +   304][0],s0[h +   304][1],s0[h +   304][2],s0[h +   304][3]),hideTrace($w[h +   304])=(s1[h +   304]),rgb($w[h +   305])=(s0[h +   305][0],s0[h +   305][1],s0[h +   305][2],s0[h +   305][3]),hideTrace($w[h +   305])=(s1[h +   305]),rgb($w[h +   306])=(s0[h +   306][0],s0[h +   306][1],s0[h +   306][2],s0[h +   306][3]),hideTrace($w[h +   306])=(s1[h +   306]),rgb($w[h +   307])=(s0[h +   307][0],s0[h +   307][1],s0[h +   307][2],s0[h +   307][3]),hideTrace($w[h +   307])=(s1[h +   307]),rgb($w[h +   308])=(s0[h +   308][0],s0[h +   308][1],s0[h +   308][2],s0[h +   308][3]),hideTrace($w[h +   308])=(s1[h +   308]),rgb($w[h +   309])=(s0[h +   309][0],s0[h +   309][1],s0[h +   309][2],s0[h +   309][3]),hideTrace($w[h +   309])=(s1[h +   309]),rgb($w[h +   310])=(s0[h +   310][0],s0[h +   310][1],s0[h +   310][2],s0[h +   310][3]),hideTrace($w[h +   310])=(s1[h +   310]),rgb($w[h +   311])=(s0[h +   311][0],s0[h +   311][1],s0[h +   311][2],s0[h +   311][3]),hideTrace($w[h +   311])=(s1[h +   311]) \
				,rgb($w[h +   312])=(s0[h +   312][0],s0[h +   312][1],s0[h +   312][2],s0[h +   312][3]),hideTrace($w[h +   312])=(s1[h +   312]),rgb($w[h +   313])=(s0[h +   313][0],s0[h +   313][1],s0[h +   313][2],s0[h +   313][3]),hideTrace($w[h +   313])=(s1[h +   313]),rgb($w[h +   314])=(s0[h +   314][0],s0[h +   314][1],s0[h +   314][2],s0[h +   314][3]),hideTrace($w[h +   314])=(s1[h +   314]),rgb($w[h +   315])=(s0[h +   315][0],s0[h +   315][1],s0[h +   315][2],s0[h +   315][3]),hideTrace($w[h +   315])=(s1[h +   315]),rgb($w[h +   316])=(s0[h +   316][0],s0[h +   316][1],s0[h +   316][2],s0[h +   316][3]),hideTrace($w[h +   316])=(s1[h +   316]),rgb($w[h +   317])=(s0[h +   317][0],s0[h +   317][1],s0[h +   317][2],s0[h +   317][3]),hideTrace($w[h +   317])=(s1[h +   317]),rgb($w[h +   318])=(s0[h +   318][0],s0[h +   318][1],s0[h +   318][2],s0[h +   318][3]),hideTrace($w[h +   318])=(s1[h +   318]),rgb($w[h +   319])=(s0[h +   319][0],s0[h +   319][1],s0[h +   319][2],s0[h +   319][3]),hideTrace($w[h +   319])=(s1[h +   319]) \
				,rgb($w[h +   320])=(s0[h +   320][0],s0[h +   320][1],s0[h +   320][2],s0[h +   320][3]),hideTrace($w[h +   320])=(s1[h +   320]),rgb($w[h +   321])=(s0[h +   321][0],s0[h +   321][1],s0[h +   321][2],s0[h +   321][3]),hideTrace($w[h +   321])=(s1[h +   321]),rgb($w[h +   322])=(s0[h +   322][0],s0[h +   322][1],s0[h +   322][2],s0[h +   322][3]),hideTrace($w[h +   322])=(s1[h +   322]),rgb($w[h +   323])=(s0[h +   323][0],s0[h +   323][1],s0[h +   323][2],s0[h +   323][3]),hideTrace($w[h +   323])=(s1[h +   323]),rgb($w[h +   324])=(s0[h +   324][0],s0[h +   324][1],s0[h +   324][2],s0[h +   324][3]),hideTrace($w[h +   324])=(s1[h +   324]),rgb($w[h +   325])=(s0[h +   325][0],s0[h +   325][1],s0[h +   325][2],s0[h +   325][3]),hideTrace($w[h +   325])=(s1[h +   325]),rgb($w[h +   326])=(s0[h +   326][0],s0[h +   326][1],s0[h +   326][2],s0[h +   326][3]),hideTrace($w[h +   326])=(s1[h +   326]),rgb($w[h +   327])=(s0[h +   327][0],s0[h +   327][1],s0[h +   327][2],s0[h +   327][3]),hideTrace($w[h +   327])=(s1[h +   327]) \
				,rgb($w[h +   328])=(s0[h +   328][0],s0[h +   328][1],s0[h +   328][2],s0[h +   328][3]),hideTrace($w[h +   328])=(s1[h +   328]),rgb($w[h +   329])=(s0[h +   329][0],s0[h +   329][1],s0[h +   329][2],s0[h +   329][3]),hideTrace($w[h +   329])=(s1[h +   329]),rgb($w[h +   330])=(s0[h +   330][0],s0[h +   330][1],s0[h +   330][2],s0[h +   330][3]),hideTrace($w[h +   330])=(s1[h +   330]),rgb($w[h +   331])=(s0[h +   331][0],s0[h +   331][1],s0[h +   331][2],s0[h +   331][3]),hideTrace($w[h +   331])=(s1[h +   331]),rgb($w[h +   332])=(s0[h +   332][0],s0[h +   332][1],s0[h +   332][2],s0[h +   332][3]),hideTrace($w[h +   332])=(s1[h +   332]),rgb($w[h +   333])=(s0[h +   333][0],s0[h +   333][1],s0[h +   333][2],s0[h +   333][3]),hideTrace($w[h +   333])=(s1[h +   333]),rgb($w[h +   334])=(s0[h +   334][0],s0[h +   334][1],s0[h +   334][2],s0[h +   334][3]),hideTrace($w[h +   334])=(s1[h +   334]),rgb($w[h +   335])=(s0[h +   335][0],s0[h +   335][1],s0[h +   335][2],s0[h +   335][3]),hideTrace($w[h +   335])=(s1[h +   335]) \
				,rgb($w[h +   336])=(s0[h +   336][0],s0[h +   336][1],s0[h +   336][2],s0[h +   336][3]),hideTrace($w[h +   336])=(s1[h +   336]),rgb($w[h +   337])=(s0[h +   337][0],s0[h +   337][1],s0[h +   337][2],s0[h +   337][3]),hideTrace($w[h +   337])=(s1[h +   337]),rgb($w[h +   338])=(s0[h +   338][0],s0[h +   338][1],s0[h +   338][2],s0[h +   338][3]),hideTrace($w[h +   338])=(s1[h +   338]),rgb($w[h +   339])=(s0[h +   339][0],s0[h +   339][1],s0[h +   339][2],s0[h +   339][3]),hideTrace($w[h +   339])=(s1[h +   339]),rgb($w[h +   340])=(s0[h +   340][0],s0[h +   340][1],s0[h +   340][2],s0[h +   340][3]),hideTrace($w[h +   340])=(s1[h +   340]),rgb($w[h +   341])=(s0[h +   341][0],s0[h +   341][1],s0[h +   341][2],s0[h +   341][3]),hideTrace($w[h +   341])=(s1[h +   341]),rgb($w[h +   342])=(s0[h +   342][0],s0[h +   342][1],s0[h +   342][2],s0[h +   342][3]),hideTrace($w[h +   342])=(s1[h +   342]),rgb($w[h +   343])=(s0[h +   343][0],s0[h +   343][1],s0[h +   343][2],s0[h +   343][3]),hideTrace($w[h +   343])=(s1[h +   343]) \
				,rgb($w[h +   344])=(s0[h +   344][0],s0[h +   344][1],s0[h +   344][2],s0[h +   344][3]),hideTrace($w[h +   344])=(s1[h +   344]),rgb($w[h +   345])=(s0[h +   345][0],s0[h +   345][1],s0[h +   345][2],s0[h +   345][3]),hideTrace($w[h +   345])=(s1[h +   345]),rgb($w[h +   346])=(s0[h +   346][0],s0[h +   346][1],s0[h +   346][2],s0[h +   346][3]),hideTrace($w[h +   346])=(s1[h +   346]),rgb($w[h +   347])=(s0[h +   347][0],s0[h +   347][1],s0[h +   347][2],s0[h +   347][3]),hideTrace($w[h +   347])=(s1[h +   347]),rgb($w[h +   348])=(s0[h +   348][0],s0[h +   348][1],s0[h +   348][2],s0[h +   348][3]),hideTrace($w[h +   348])=(s1[h +   348]),rgb($w[h +   349])=(s0[h +   349][0],s0[h +   349][1],s0[h +   349][2],s0[h +   349][3]),hideTrace($w[h +   349])=(s1[h +   349]),rgb($w[h +   350])=(s0[h +   350][0],s0[h +   350][1],s0[h +   350][2],s0[h +   350][3]),hideTrace($w[h +   350])=(s1[h +   350]),rgb($w[h +   351])=(s0[h +   351][0],s0[h +   351][1],s0[h +   351][2],s0[h +   351][3]),hideTrace($w[h +   351])=(s1[h +   351]) \
				,rgb($w[h +   352])=(s0[h +   352][0],s0[h +   352][1],s0[h +   352][2],s0[h +   352][3]),hideTrace($w[h +   352])=(s1[h +   352]),rgb($w[h +   353])=(s0[h +   353][0],s0[h +   353][1],s0[h +   353][2],s0[h +   353][3]),hideTrace($w[h +   353])=(s1[h +   353]),rgb($w[h +   354])=(s0[h +   354][0],s0[h +   354][1],s0[h +   354][2],s0[h +   354][3]),hideTrace($w[h +   354])=(s1[h +   354]),rgb($w[h +   355])=(s0[h +   355][0],s0[h +   355][1],s0[h +   355][2],s0[h +   355][3]),hideTrace($w[h +   355])=(s1[h +   355]),rgb($w[h +   356])=(s0[h +   356][0],s0[h +   356][1],s0[h +   356][2],s0[h +   356][3]),hideTrace($w[h +   356])=(s1[h +   356]),rgb($w[h +   357])=(s0[h +   357][0],s0[h +   357][1],s0[h +   357][2],s0[h +   357][3]),hideTrace($w[h +   357])=(s1[h +   357]),rgb($w[h +   358])=(s0[h +   358][0],s0[h +   358][1],s0[h +   358][2],s0[h +   358][3]),hideTrace($w[h +   358])=(s1[h +   358]),rgb($w[h +   359])=(s0[h +   359][0],s0[h +   359][1],s0[h +   359][2],s0[h +   359][3]),hideTrace($w[h +   359])=(s1[h +   359]) \
				,rgb($w[h +   360])=(s0[h +   360][0],s0[h +   360][1],s0[h +   360][2],s0[h +   360][3]),hideTrace($w[h +   360])=(s1[h +   360]),rgb($w[h +   361])=(s0[h +   361][0],s0[h +   361][1],s0[h +   361][2],s0[h +   361][3]),hideTrace($w[h +   361])=(s1[h +   361]),rgb($w[h +   362])=(s0[h +   362][0],s0[h +   362][1],s0[h +   362][2],s0[h +   362][3]),hideTrace($w[h +   362])=(s1[h +   362]),rgb($w[h +   363])=(s0[h +   363][0],s0[h +   363][1],s0[h +   363][2],s0[h +   363][3]),hideTrace($w[h +   363])=(s1[h +   363]),rgb($w[h +   364])=(s0[h +   364][0],s0[h +   364][1],s0[h +   364][2],s0[h +   364][3]),hideTrace($w[h +   364])=(s1[h +   364]),rgb($w[h +   365])=(s0[h +   365][0],s0[h +   365][1],s0[h +   365][2],s0[h +   365][3]),hideTrace($w[h +   365])=(s1[h +   365]),rgb($w[h +   366])=(s0[h +   366][0],s0[h +   366][1],s0[h +   366][2],s0[h +   366][3]),hideTrace($w[h +   366])=(s1[h +   366]),rgb($w[h +   367])=(s0[h +   367][0],s0[h +   367][1],s0[h +   367][2],s0[h +   367][3]),hideTrace($w[h +   367])=(s1[h +   367]) \
				,rgb($w[h +   368])=(s0[h +   368][0],s0[h +   368][1],s0[h +   368][2],s0[h +   368][3]),hideTrace($w[h +   368])=(s1[h +   368]),rgb($w[h +   369])=(s0[h +   369][0],s0[h +   369][1],s0[h +   369][2],s0[h +   369][3]),hideTrace($w[h +   369])=(s1[h +   369]),rgb($w[h +   370])=(s0[h +   370][0],s0[h +   370][1],s0[h +   370][2],s0[h +   370][3]),hideTrace($w[h +   370])=(s1[h +   370]),rgb($w[h +   371])=(s0[h +   371][0],s0[h +   371][1],s0[h +   371][2],s0[h +   371][3]),hideTrace($w[h +   371])=(s1[h +   371]),rgb($w[h +   372])=(s0[h +   372][0],s0[h +   372][1],s0[h +   372][2],s0[h +   372][3]),hideTrace($w[h +   372])=(s1[h +   372]),rgb($w[h +   373])=(s0[h +   373][0],s0[h +   373][1],s0[h +   373][2],s0[h +   373][3]),hideTrace($w[h +   373])=(s1[h +   373]),rgb($w[h +   374])=(s0[h +   374][0],s0[h +   374][1],s0[h +   374][2],s0[h +   374][3]),hideTrace($w[h +   374])=(s1[h +   374]),rgb($w[h +   375])=(s0[h +   375][0],s0[h +   375][1],s0[h +   375][2],s0[h +   375][3]),hideTrace($w[h +   375])=(s1[h +   375]) \
				,rgb($w[h +   376])=(s0[h +   376][0],s0[h +   376][1],s0[h +   376][2],s0[h +   376][3]),hideTrace($w[h +   376])=(s1[h +   376]),rgb($w[h +   377])=(s0[h +   377][0],s0[h +   377][1],s0[h +   377][2],s0[h +   377][3]),hideTrace($w[h +   377])=(s1[h +   377]),rgb($w[h +   378])=(s0[h +   378][0],s0[h +   378][1],s0[h +   378][2],s0[h +   378][3]),hideTrace($w[h +   378])=(s1[h +   378]),rgb($w[h +   379])=(s0[h +   379][0],s0[h +   379][1],s0[h +   379][2],s0[h +   379][3]),hideTrace($w[h +   379])=(s1[h +   379]),rgb($w[h +   380])=(s0[h +   380][0],s0[h +   380][1],s0[h +   380][2],s0[h +   380][3]),hideTrace($w[h +   380])=(s1[h +   380]),rgb($w[h +   381])=(s0[h +   381][0],s0[h +   381][1],s0[h +   381][2],s0[h +   381][3]),hideTrace($w[h +   381])=(s1[h +   381]),rgb($w[h +   382])=(s0[h +   382][0],s0[h +   382][1],s0[h +   382][2],s0[h +   382][3]),hideTrace($w[h +   382])=(s1[h +   382]),rgb($w[h +   383])=(s0[h +   383][0],s0[h +   383][1],s0[h +   383][2],s0[h +   383][3]),hideTrace($w[h +   383])=(s1[h +   383]) \
				,rgb($w[h +   384])=(s0[h +   384][0],s0[h +   384][1],s0[h +   384][2],s0[h +   384][3]),hideTrace($w[h +   384])=(s1[h +   384]),rgb($w[h +   385])=(s0[h +   385][0],s0[h +   385][1],s0[h +   385][2],s0[h +   385][3]),hideTrace($w[h +   385])=(s1[h +   385]),rgb($w[h +   386])=(s0[h +   386][0],s0[h +   386][1],s0[h +   386][2],s0[h +   386][3]),hideTrace($w[h +   386])=(s1[h +   386]),rgb($w[h +   387])=(s0[h +   387][0],s0[h +   387][1],s0[h +   387][2],s0[h +   387][3]),hideTrace($w[h +   387])=(s1[h +   387]),rgb($w[h +   388])=(s0[h +   388][0],s0[h +   388][1],s0[h +   388][2],s0[h +   388][3]),hideTrace($w[h +   388])=(s1[h +   388]),rgb($w[h +   389])=(s0[h +   389][0],s0[h +   389][1],s0[h +   389][2],s0[h +   389][3]),hideTrace($w[h +   389])=(s1[h +   389]),rgb($w[h +   390])=(s0[h +   390][0],s0[h +   390][1],s0[h +   390][2],s0[h +   390][3]),hideTrace($w[h +   390])=(s1[h +   390]),rgb($w[h +   391])=(s0[h +   391][0],s0[h +   391][1],s0[h +   391][2],s0[h +   391][3]),hideTrace($w[h +   391])=(s1[h +   391]) \
				,rgb($w[h +   392])=(s0[h +   392][0],s0[h +   392][1],s0[h +   392][2],s0[h +   392][3]),hideTrace($w[h +   392])=(s1[h +   392]),rgb($w[h +   393])=(s0[h +   393][0],s0[h +   393][1],s0[h +   393][2],s0[h +   393][3]),hideTrace($w[h +   393])=(s1[h +   393]),rgb($w[h +   394])=(s0[h +   394][0],s0[h +   394][1],s0[h +   394][2],s0[h +   394][3]),hideTrace($w[h +   394])=(s1[h +   394]),rgb($w[h +   395])=(s0[h +   395][0],s0[h +   395][1],s0[h +   395][2],s0[h +   395][3]),hideTrace($w[h +   395])=(s1[h +   395]),rgb($w[h +   396])=(s0[h +   396][0],s0[h +   396][1],s0[h +   396][2],s0[h +   396][3]),hideTrace($w[h +   396])=(s1[h +   396]),rgb($w[h +   397])=(s0[h +   397][0],s0[h +   397][1],s0[h +   397][2],s0[h +   397][3]),hideTrace($w[h +   397])=(s1[h +   397]),rgb($w[h +   398])=(s0[h +   398][0],s0[h +   398][1],s0[h +   398][2],s0[h +   398][3]),hideTrace($w[h +   398])=(s1[h +   398]),rgb($w[h +   399])=(s0[h +   399][0],s0[h +   399][1],s0[h +   399][2],s0[h +   399][3]),hideTrace($w[h +   399])=(s1[h +   399]) \
				,rgb($w[h +   400])=(s0[h +   400][0],s0[h +   400][1],s0[h +   400][2],s0[h +   400][3]),hideTrace($w[h +   400])=(s1[h +   400]),rgb($w[h +   401])=(s0[h +   401][0],s0[h +   401][1],s0[h +   401][2],s0[h +   401][3]),hideTrace($w[h +   401])=(s1[h +   401]),rgb($w[h +   402])=(s0[h +   402][0],s0[h +   402][1],s0[h +   402][2],s0[h +   402][3]),hideTrace($w[h +   402])=(s1[h +   402]),rgb($w[h +   403])=(s0[h +   403][0],s0[h +   403][1],s0[h +   403][2],s0[h +   403][3]),hideTrace($w[h +   403])=(s1[h +   403]),rgb($w[h +   404])=(s0[h +   404][0],s0[h +   404][1],s0[h +   404][2],s0[h +   404][3]),hideTrace($w[h +   404])=(s1[h +   404]),rgb($w[h +   405])=(s0[h +   405][0],s0[h +   405][1],s0[h +   405][2],s0[h +   405][3]),hideTrace($w[h +   405])=(s1[h +   405]),rgb($w[h +   406])=(s0[h +   406][0],s0[h +   406][1],s0[h +   406][2],s0[h +   406][3]),hideTrace($w[h +   406])=(s1[h +   406]),rgb($w[h +   407])=(s0[h +   407][0],s0[h +   407][1],s0[h +   407][2],s0[h +   407][3]),hideTrace($w[h +   407])=(s1[h +   407]) \
				,rgb($w[h +   408])=(s0[h +   408][0],s0[h +   408][1],s0[h +   408][2],s0[h +   408][3]),hideTrace($w[h +   408])=(s1[h +   408]),rgb($w[h +   409])=(s0[h +   409][0],s0[h +   409][1],s0[h +   409][2],s0[h +   409][3]),hideTrace($w[h +   409])=(s1[h +   409]),rgb($w[h +   410])=(s0[h +   410][0],s0[h +   410][1],s0[h +   410][2],s0[h +   410][3]),hideTrace($w[h +   410])=(s1[h +   410]),rgb($w[h +   411])=(s0[h +   411][0],s0[h +   411][1],s0[h +   411][2],s0[h +   411][3]),hideTrace($w[h +   411])=(s1[h +   411]),rgb($w[h +   412])=(s0[h +   412][0],s0[h +   412][1],s0[h +   412][2],s0[h +   412][3]),hideTrace($w[h +   412])=(s1[h +   412]),rgb($w[h +   413])=(s0[h +   413][0],s0[h +   413][1],s0[h +   413][2],s0[h +   413][3]),hideTrace($w[h +   413])=(s1[h +   413]),rgb($w[h +   414])=(s0[h +   414][0],s0[h +   414][1],s0[h +   414][2],s0[h +   414][3]),hideTrace($w[h +   414])=(s1[h +   414]),rgb($w[h +   415])=(s0[h +   415][0],s0[h +   415][1],s0[h +   415][2],s0[h +   415][3]),hideTrace($w[h +   415])=(s1[h +   415]) \
				,rgb($w[h +   416])=(s0[h +   416][0],s0[h +   416][1],s0[h +   416][2],s0[h +   416][3]),hideTrace($w[h +   416])=(s1[h +   416]),rgb($w[h +   417])=(s0[h +   417][0],s0[h +   417][1],s0[h +   417][2],s0[h +   417][3]),hideTrace($w[h +   417])=(s1[h +   417]),rgb($w[h +   418])=(s0[h +   418][0],s0[h +   418][1],s0[h +   418][2],s0[h +   418][3]),hideTrace($w[h +   418])=(s1[h +   418]),rgb($w[h +   419])=(s0[h +   419][0],s0[h +   419][1],s0[h +   419][2],s0[h +   419][3]),hideTrace($w[h +   419])=(s1[h +   419]),rgb($w[h +   420])=(s0[h +   420][0],s0[h +   420][1],s0[h +   420][2],s0[h +   420][3]),hideTrace($w[h +   420])=(s1[h +   420]),rgb($w[h +   421])=(s0[h +   421][0],s0[h +   421][1],s0[h +   421][2],s0[h +   421][3]),hideTrace($w[h +   421])=(s1[h +   421]),rgb($w[h +   422])=(s0[h +   422][0],s0[h +   422][1],s0[h +   422][2],s0[h +   422][3]),hideTrace($w[h +   422])=(s1[h +   422]),rgb($w[h +   423])=(s0[h +   423][0],s0[h +   423][1],s0[h +   423][2],s0[h +   423][3]),hideTrace($w[h +   423])=(s1[h +   423]) \
				,rgb($w[h +   424])=(s0[h +   424][0],s0[h +   424][1],s0[h +   424][2],s0[h +   424][3]),hideTrace($w[h +   424])=(s1[h +   424]),rgb($w[h +   425])=(s0[h +   425][0],s0[h +   425][1],s0[h +   425][2],s0[h +   425][3]),hideTrace($w[h +   425])=(s1[h +   425]),rgb($w[h +   426])=(s0[h +   426][0],s0[h +   426][1],s0[h +   426][2],s0[h +   426][3]),hideTrace($w[h +   426])=(s1[h +   426]),rgb($w[h +   427])=(s0[h +   427][0],s0[h +   427][1],s0[h +   427][2],s0[h +   427][3]),hideTrace($w[h +   427])=(s1[h +   427]),rgb($w[h +   428])=(s0[h +   428][0],s0[h +   428][1],s0[h +   428][2],s0[h +   428][3]),hideTrace($w[h +   428])=(s1[h +   428]),rgb($w[h +   429])=(s0[h +   429][0],s0[h +   429][1],s0[h +   429][2],s0[h +   429][3]),hideTrace($w[h +   429])=(s1[h +   429]),rgb($w[h +   430])=(s0[h +   430][0],s0[h +   430][1],s0[h +   430][2],s0[h +   430][3]),hideTrace($w[h +   430])=(s1[h +   430]),rgb($w[h +   431])=(s0[h +   431][0],s0[h +   431][1],s0[h +   431][2],s0[h +   431][3]),hideTrace($w[h +   431])=(s1[h +   431]) \
				,rgb($w[h +   432])=(s0[h +   432][0],s0[h +   432][1],s0[h +   432][2],s0[h +   432][3]),hideTrace($w[h +   432])=(s1[h +   432]),rgb($w[h +   433])=(s0[h +   433][0],s0[h +   433][1],s0[h +   433][2],s0[h +   433][3]),hideTrace($w[h +   433])=(s1[h +   433]),rgb($w[h +   434])=(s0[h +   434][0],s0[h +   434][1],s0[h +   434][2],s0[h +   434][3]),hideTrace($w[h +   434])=(s1[h +   434]),rgb($w[h +   435])=(s0[h +   435][0],s0[h +   435][1],s0[h +   435][2],s0[h +   435][3]),hideTrace($w[h +   435])=(s1[h +   435]),rgb($w[h +   436])=(s0[h +   436][0],s0[h +   436][1],s0[h +   436][2],s0[h +   436][3]),hideTrace($w[h +   436])=(s1[h +   436]),rgb($w[h +   437])=(s0[h +   437][0],s0[h +   437][1],s0[h +   437][2],s0[h +   437][3]),hideTrace($w[h +   437])=(s1[h +   437]),rgb($w[h +   438])=(s0[h +   438][0],s0[h +   438][1],s0[h +   438][2],s0[h +   438][3]),hideTrace($w[h +   438])=(s1[h +   438]),rgb($w[h +   439])=(s0[h +   439][0],s0[h +   439][1],s0[h +   439][2],s0[h +   439][3]),hideTrace($w[h +   439])=(s1[h +   439]) \
				,rgb($w[h +   440])=(s0[h +   440][0],s0[h +   440][1],s0[h +   440][2],s0[h +   440][3]),hideTrace($w[h +   440])=(s1[h +   440]),rgb($w[h +   441])=(s0[h +   441][0],s0[h +   441][1],s0[h +   441][2],s0[h +   441][3]),hideTrace($w[h +   441])=(s1[h +   441]),rgb($w[h +   442])=(s0[h +   442][0],s0[h +   442][1],s0[h +   442][2],s0[h +   442][3]),hideTrace($w[h +   442])=(s1[h +   442]),rgb($w[h +   443])=(s0[h +   443][0],s0[h +   443][1],s0[h +   443][2],s0[h +   443][3]),hideTrace($w[h +   443])=(s1[h +   443]),rgb($w[h +   444])=(s0[h +   444][0],s0[h +   444][1],s0[h +   444][2],s0[h +   444][3]),hideTrace($w[h +   444])=(s1[h +   444]),rgb($w[h +   445])=(s0[h +   445][0],s0[h +   445][1],s0[h +   445][2],s0[h +   445][3]),hideTrace($w[h +   445])=(s1[h +   445]),rgb($w[h +   446])=(s0[h +   446][0],s0[h +   446][1],s0[h +   446][2],s0[h +   446][3]),hideTrace($w[h +   446])=(s1[h +   446]),rgb($w[h +   447])=(s0[h +   447][0],s0[h +   447][1],s0[h +   447][2],s0[h +   447][3]),hideTrace($w[h +   447])=(s1[h +   447]) \
				,rgb($w[h +   448])=(s0[h +   448][0],s0[h +   448][1],s0[h +   448][2],s0[h +   448][3]),hideTrace($w[h +   448])=(s1[h +   448]),rgb($w[h +   449])=(s0[h +   449][0],s0[h +   449][1],s0[h +   449][2],s0[h +   449][3]),hideTrace($w[h +   449])=(s1[h +   449]),rgb($w[h +   450])=(s0[h +   450][0],s0[h +   450][1],s0[h +   450][2],s0[h +   450][3]),hideTrace($w[h +   450])=(s1[h +   450]),rgb($w[h +   451])=(s0[h +   451][0],s0[h +   451][1],s0[h +   451][2],s0[h +   451][3]),hideTrace($w[h +   451])=(s1[h +   451]),rgb($w[h +   452])=(s0[h +   452][0],s0[h +   452][1],s0[h +   452][2],s0[h +   452][3]),hideTrace($w[h +   452])=(s1[h +   452]),rgb($w[h +   453])=(s0[h +   453][0],s0[h +   453][1],s0[h +   453][2],s0[h +   453][3]),hideTrace($w[h +   453])=(s1[h +   453]),rgb($w[h +   454])=(s0[h +   454][0],s0[h +   454][1],s0[h +   454][2],s0[h +   454][3]),hideTrace($w[h +   454])=(s1[h +   454]),rgb($w[h +   455])=(s0[h +   455][0],s0[h +   455][1],s0[h +   455][2],s0[h +   455][3]),hideTrace($w[h +   455])=(s1[h +   455]) \
				,rgb($w[h +   456])=(s0[h +   456][0],s0[h +   456][1],s0[h +   456][2],s0[h +   456][3]),hideTrace($w[h +   456])=(s1[h +   456]),rgb($w[h +   457])=(s0[h +   457][0],s0[h +   457][1],s0[h +   457][2],s0[h +   457][3]),hideTrace($w[h +   457])=(s1[h +   457]),rgb($w[h +   458])=(s0[h +   458][0],s0[h +   458][1],s0[h +   458][2],s0[h +   458][3]),hideTrace($w[h +   458])=(s1[h +   458]),rgb($w[h +   459])=(s0[h +   459][0],s0[h +   459][1],s0[h +   459][2],s0[h +   459][3]),hideTrace($w[h +   459])=(s1[h +   459]),rgb($w[h +   460])=(s0[h +   460][0],s0[h +   460][1],s0[h +   460][2],s0[h +   460][3]),hideTrace($w[h +   460])=(s1[h +   460]),rgb($w[h +   461])=(s0[h +   461][0],s0[h +   461][1],s0[h +   461][2],s0[h +   461][3]),hideTrace($w[h +   461])=(s1[h +   461]),rgb($w[h +   462])=(s0[h +   462][0],s0[h +   462][1],s0[h +   462][2],s0[h +   462][3]),hideTrace($w[h +   462])=(s1[h +   462]),rgb($w[h +   463])=(s0[h +   463][0],s0[h +   463][1],s0[h +   463][2],s0[h +   463][3]),hideTrace($w[h +   463])=(s1[h +   463]) \
				,rgb($w[h +   464])=(s0[h +   464][0],s0[h +   464][1],s0[h +   464][2],s0[h +   464][3]),hideTrace($w[h +   464])=(s1[h +   464]),rgb($w[h +   465])=(s0[h +   465][0],s0[h +   465][1],s0[h +   465][2],s0[h +   465][3]),hideTrace($w[h +   465])=(s1[h +   465]),rgb($w[h +   466])=(s0[h +   466][0],s0[h +   466][1],s0[h +   466][2],s0[h +   466][3]),hideTrace($w[h +   466])=(s1[h +   466]),rgb($w[h +   467])=(s0[h +   467][0],s0[h +   467][1],s0[h +   467][2],s0[h +   467][3]),hideTrace($w[h +   467])=(s1[h +   467]),rgb($w[h +   468])=(s0[h +   468][0],s0[h +   468][1],s0[h +   468][2],s0[h +   468][3]),hideTrace($w[h +   468])=(s1[h +   468]),rgb($w[h +   469])=(s0[h +   469][0],s0[h +   469][1],s0[h +   469][2],s0[h +   469][3]),hideTrace($w[h +   469])=(s1[h +   469]),rgb($w[h +   470])=(s0[h +   470][0],s0[h +   470][1],s0[h +   470][2],s0[h +   470][3]),hideTrace($w[h +   470])=(s1[h +   470]),rgb($w[h +   471])=(s0[h +   471][0],s0[h +   471][1],s0[h +   471][2],s0[h +   471][3]),hideTrace($w[h +   471])=(s1[h +   471]) \
				,rgb($w[h +   472])=(s0[h +   472][0],s0[h +   472][1],s0[h +   472][2],s0[h +   472][3]),hideTrace($w[h +   472])=(s1[h +   472]),rgb($w[h +   473])=(s0[h +   473][0],s0[h +   473][1],s0[h +   473][2],s0[h +   473][3]),hideTrace($w[h +   473])=(s1[h +   473]),rgb($w[h +   474])=(s0[h +   474][0],s0[h +   474][1],s0[h +   474][2],s0[h +   474][3]),hideTrace($w[h +   474])=(s1[h +   474]),rgb($w[h +   475])=(s0[h +   475][0],s0[h +   475][1],s0[h +   475][2],s0[h +   475][3]),hideTrace($w[h +   475])=(s1[h +   475]),rgb($w[h +   476])=(s0[h +   476][0],s0[h +   476][1],s0[h +   476][2],s0[h +   476][3]),hideTrace($w[h +   476])=(s1[h +   476]),rgb($w[h +   477])=(s0[h +   477][0],s0[h +   477][1],s0[h +   477][2],s0[h +   477][3]),hideTrace($w[h +   477])=(s1[h +   477]),rgb($w[h +   478])=(s0[h +   478][0],s0[h +   478][1],s0[h +   478][2],s0[h +   478][3]),hideTrace($w[h +   478])=(s1[h +   478]),rgb($w[h +   479])=(s0[h +   479][0],s0[h +   479][1],s0[h +   479][2],s0[h +   479][3]),hideTrace($w[h +   479])=(s1[h +   479]) \
				,rgb($w[h +   480])=(s0[h +   480][0],s0[h +   480][1],s0[h +   480][2],s0[h +   480][3]),hideTrace($w[h +   480])=(s1[h +   480]),rgb($w[h +   481])=(s0[h +   481][0],s0[h +   481][1],s0[h +   481][2],s0[h +   481][3]),hideTrace($w[h +   481])=(s1[h +   481]),rgb($w[h +   482])=(s0[h +   482][0],s0[h +   482][1],s0[h +   482][2],s0[h +   482][3]),hideTrace($w[h +   482])=(s1[h +   482]),rgb($w[h +   483])=(s0[h +   483][0],s0[h +   483][1],s0[h +   483][2],s0[h +   483][3]),hideTrace($w[h +   483])=(s1[h +   483]),rgb($w[h +   484])=(s0[h +   484][0],s0[h +   484][1],s0[h +   484][2],s0[h +   484][3]),hideTrace($w[h +   484])=(s1[h +   484]),rgb($w[h +   485])=(s0[h +   485][0],s0[h +   485][1],s0[h +   485][2],s0[h +   485][3]),hideTrace($w[h +   485])=(s1[h +   485]),rgb($w[h +   486])=(s0[h +   486][0],s0[h +   486][1],s0[h +   486][2],s0[h +   486][3]),hideTrace($w[h +   486])=(s1[h +   486]),rgb($w[h +   487])=(s0[h +   487][0],s0[h +   487][1],s0[h +   487][2],s0[h +   487][3]),hideTrace($w[h +   487])=(s1[h +   487]) \
				,rgb($w[h +   488])=(s0[h +   488][0],s0[h +   488][1],s0[h +   488][2],s0[h +   488][3]),hideTrace($w[h +   488])=(s1[h +   488]),rgb($w[h +   489])=(s0[h +   489][0],s0[h +   489][1],s0[h +   489][2],s0[h +   489][3]),hideTrace($w[h +   489])=(s1[h +   489]),rgb($w[h +   490])=(s0[h +   490][0],s0[h +   490][1],s0[h +   490][2],s0[h +   490][3]),hideTrace($w[h +   490])=(s1[h +   490]),rgb($w[h +   491])=(s0[h +   491][0],s0[h +   491][1],s0[h +   491][2],s0[h +   491][3]),hideTrace($w[h +   491])=(s1[h +   491]),rgb($w[h +   492])=(s0[h +   492][0],s0[h +   492][1],s0[h +   492][2],s0[h +   492][3]),hideTrace($w[h +   492])=(s1[h +   492]),rgb($w[h +   493])=(s0[h +   493][0],s0[h +   493][1],s0[h +   493][2],s0[h +   493][3]),hideTrace($w[h +   493])=(s1[h +   493]),rgb($w[h +   494])=(s0[h +   494][0],s0[h +   494][1],s0[h +   494][2],s0[h +   494][3]),hideTrace($w[h +   494])=(s1[h +   494]),rgb($w[h +   495])=(s0[h +   495][0],s0[h +   495][1],s0[h +   495][2],s0[h +   495][3]),hideTrace($w[h +   495])=(s1[h +   495]) \
				,rgb($w[h +   496])=(s0[h +   496][0],s0[h +   496][1],s0[h +   496][2],s0[h +   496][3]),hideTrace($w[h +   496])=(s1[h +   496]),rgb($w[h +   497])=(s0[h +   497][0],s0[h +   497][1],s0[h +   497][2],s0[h +   497][3]),hideTrace($w[h +   497])=(s1[h +   497]),rgb($w[h +   498])=(s0[h +   498][0],s0[h +   498][1],s0[h +   498][2],s0[h +   498][3]),hideTrace($w[h +   498])=(s1[h +   498]),rgb($w[h +   499])=(s0[h +   499][0],s0[h +   499][1],s0[h +   499][2],s0[h +   499][3]),hideTrace($w[h +   499])=(s1[h +   499]),rgb($w[h +   500])=(s0[h +   500][0],s0[h +   500][1],s0[h +   500][2],s0[h +   500][3]),hideTrace($w[h +   500])=(s1[h +   500]),rgb($w[h +   501])=(s0[h +   501][0],s0[h +   501][1],s0[h +   501][2],s0[h +   501][3]),hideTrace($w[h +   501])=(s1[h +   501]),rgb($w[h +   502])=(s0[h +   502][0],s0[h +   502][1],s0[h +   502][2],s0[h +   502][3]),hideTrace($w[h +   502])=(s1[h +   502]),rgb($w[h +   503])=(s0[h +   503][0],s0[h +   503][1],s0[h +   503][2],s0[h +   503][3]),hideTrace($w[h +   503])=(s1[h +   503]) \
				,rgb($w[h +   504])=(s0[h +   504][0],s0[h +   504][1],s0[h +   504][2],s0[h +   504][3]),hideTrace($w[h +   504])=(s1[h +   504]),rgb($w[h +   505])=(s0[h +   505][0],s0[h +   505][1],s0[h +   505][2],s0[h +   505][3]),hideTrace($w[h +   505])=(s1[h +   505]),rgb($w[h +   506])=(s0[h +   506][0],s0[h +   506][1],s0[h +   506][2],s0[h +   506][3]),hideTrace($w[h +   506])=(s1[h +   506]),rgb($w[h +   507])=(s0[h +   507][0],s0[h +   507][1],s0[h +   507][2],s0[h +   507][3]),hideTrace($w[h +   507])=(s1[h +   507]),rgb($w[h +   508])=(s0[h +   508][0],s0[h +   508][1],s0[h +   508][2],s0[h +   508][3]),hideTrace($w[h +   508])=(s1[h +   508]),rgb($w[h +   509])=(s0[h +   509][0],s0[h +   509][1],s0[h +   509][2],s0[h +   509][3]),hideTrace($w[h +   509])=(s1[h +   509]),rgb($w[h +   510])=(s0[h +   510][0],s0[h +   510][1],s0[h +   510][2],s0[h +   510][3]),hideTrace($w[h +   510])=(s1[h +   510]),rgb($w[h +   511])=(s0[h +   511][0],s0[h +   511][1],s0[h +   511][2],s0[h +   511][3]),hideTrace($w[h +   511])=(s1[h +   511]) \
				,rgb($w[h +   512])=(s0[h +   512][0],s0[h +   512][1],s0[h +   512][2],s0[h +   512][3]),hideTrace($w[h +   512])=(s1[h +   512]),rgb($w[h +   513])=(s0[h +   513][0],s0[h +   513][1],s0[h +   513][2],s0[h +   513][3]),hideTrace($w[h +   513])=(s1[h +   513]),rgb($w[h +   514])=(s0[h +   514][0],s0[h +   514][1],s0[h +   514][2],s0[h +   514][3]),hideTrace($w[h +   514])=(s1[h +   514]),rgb($w[h +   515])=(s0[h +   515][0],s0[h +   515][1],s0[h +   515][2],s0[h +   515][3]),hideTrace($w[h +   515])=(s1[h +   515]),rgb($w[h +   516])=(s0[h +   516][0],s0[h +   516][1],s0[h +   516][2],s0[h +   516][3]),hideTrace($w[h +   516])=(s1[h +   516]),rgb($w[h +   517])=(s0[h +   517][0],s0[h +   517][1],s0[h +   517][2],s0[h +   517][3]),hideTrace($w[h +   517])=(s1[h +   517]),rgb($w[h +   518])=(s0[h +   518][0],s0[h +   518][1],s0[h +   518][2],s0[h +   518][3]),hideTrace($w[h +   518])=(s1[h +   518]),rgb($w[h +   519])=(s0[h +   519][0],s0[h +   519][1],s0[h +   519][2],s0[h +   519][3]),hideTrace($w[h +   519])=(s1[h +   519]) \
				,rgb($w[h +   520])=(s0[h +   520][0],s0[h +   520][1],s0[h +   520][2],s0[h +   520][3]),hideTrace($w[h +   520])=(s1[h +   520]),rgb($w[h +   521])=(s0[h +   521][0],s0[h +   521][1],s0[h +   521][2],s0[h +   521][3]),hideTrace($w[h +   521])=(s1[h +   521]),rgb($w[h +   522])=(s0[h +   522][0],s0[h +   522][1],s0[h +   522][2],s0[h +   522][3]),hideTrace($w[h +   522])=(s1[h +   522]),rgb($w[h +   523])=(s0[h +   523][0],s0[h +   523][1],s0[h +   523][2],s0[h +   523][3]),hideTrace($w[h +   523])=(s1[h +   523]),rgb($w[h +   524])=(s0[h +   524][0],s0[h +   524][1],s0[h +   524][2],s0[h +   524][3]),hideTrace($w[h +   524])=(s1[h +   524]),rgb($w[h +   525])=(s0[h +   525][0],s0[h +   525][1],s0[h +   525][2],s0[h +   525][3]),hideTrace($w[h +   525])=(s1[h +   525]),rgb($w[h +   526])=(s0[h +   526][0],s0[h +   526][1],s0[h +   526][2],s0[h +   526][3]),hideTrace($w[h +   526])=(s1[h +   526]),rgb($w[h +   527])=(s0[h +   527][0],s0[h +   527][1],s0[h +   527][2],s0[h +   527][3]),hideTrace($w[h +   527])=(s1[h +   527]) \
				,rgb($w[h +   528])=(s0[h +   528][0],s0[h +   528][1],s0[h +   528][2],s0[h +   528][3]),hideTrace($w[h +   528])=(s1[h +   528]),rgb($w[h +   529])=(s0[h +   529][0],s0[h +   529][1],s0[h +   529][2],s0[h +   529][3]),hideTrace($w[h +   529])=(s1[h +   529]),rgb($w[h +   530])=(s0[h +   530][0],s0[h +   530][1],s0[h +   530][2],s0[h +   530][3]),hideTrace($w[h +   530])=(s1[h +   530]),rgb($w[h +   531])=(s0[h +   531][0],s0[h +   531][1],s0[h +   531][2],s0[h +   531][3]),hideTrace($w[h +   531])=(s1[h +   531]),rgb($w[h +   532])=(s0[h +   532][0],s0[h +   532][1],s0[h +   532][2],s0[h +   532][3]),hideTrace($w[h +   532])=(s1[h +   532]),rgb($w[h +   533])=(s0[h +   533][0],s0[h +   533][1],s0[h +   533][2],s0[h +   533][3]),hideTrace($w[h +   533])=(s1[h +   533]),rgb($w[h +   534])=(s0[h +   534][0],s0[h +   534][1],s0[h +   534][2],s0[h +   534][3]),hideTrace($w[h +   534])=(s1[h +   534]),rgb($w[h +   535])=(s0[h +   535][0],s0[h +   535][1],s0[h +   535][2],s0[h +   535][3]),hideTrace($w[h +   535])=(s1[h +   535]) \
				,rgb($w[h +   536])=(s0[h +   536][0],s0[h +   536][1],s0[h +   536][2],s0[h +   536][3]),hideTrace($w[h +   536])=(s1[h +   536]),rgb($w[h +   537])=(s0[h +   537][0],s0[h +   537][1],s0[h +   537][2],s0[h +   537][3]),hideTrace($w[h +   537])=(s1[h +   537]),rgb($w[h +   538])=(s0[h +   538][0],s0[h +   538][1],s0[h +   538][2],s0[h +   538][3]),hideTrace($w[h +   538])=(s1[h +   538]),rgb($w[h +   539])=(s0[h +   539][0],s0[h +   539][1],s0[h +   539][2],s0[h +   539][3]),hideTrace($w[h +   539])=(s1[h +   539]),rgb($w[h +   540])=(s0[h +   540][0],s0[h +   540][1],s0[h +   540][2],s0[h +   540][3]),hideTrace($w[h +   540])=(s1[h +   540]),rgb($w[h +   541])=(s0[h +   541][0],s0[h +   541][1],s0[h +   541][2],s0[h +   541][3]),hideTrace($w[h +   541])=(s1[h +   541]),rgb($w[h +   542])=(s0[h +   542][0],s0[h +   542][1],s0[h +   542][2],s0[h +   542][3]),hideTrace($w[h +   542])=(s1[h +   542]),rgb($w[h +   543])=(s0[h +   543][0],s0[h +   543][1],s0[h +   543][2],s0[h +   543][3]),hideTrace($w[h +   543])=(s1[h +   543]) \
				,rgb($w[h +   544])=(s0[h +   544][0],s0[h +   544][1],s0[h +   544][2],s0[h +   544][3]),hideTrace($w[h +   544])=(s1[h +   544]),rgb($w[h +   545])=(s0[h +   545][0],s0[h +   545][1],s0[h +   545][2],s0[h +   545][3]),hideTrace($w[h +   545])=(s1[h +   545]),rgb($w[h +   546])=(s0[h +   546][0],s0[h +   546][1],s0[h +   546][2],s0[h +   546][3]),hideTrace($w[h +   546])=(s1[h +   546]),rgb($w[h +   547])=(s0[h +   547][0],s0[h +   547][1],s0[h +   547][2],s0[h +   547][3]),hideTrace($w[h +   547])=(s1[h +   547]),rgb($w[h +   548])=(s0[h +   548][0],s0[h +   548][1],s0[h +   548][2],s0[h +   548][3]),hideTrace($w[h +   548])=(s1[h +   548]),rgb($w[h +   549])=(s0[h +   549][0],s0[h +   549][1],s0[h +   549][2],s0[h +   549][3]),hideTrace($w[h +   549])=(s1[h +   549]),rgb($w[h +   550])=(s0[h +   550][0],s0[h +   550][1],s0[h +   550][2],s0[h +   550][3]),hideTrace($w[h +   550])=(s1[h +   550]),rgb($w[h +   551])=(s0[h +   551][0],s0[h +   551][1],s0[h +   551][2],s0[h +   551][3]),hideTrace($w[h +   551])=(s1[h +   551]) \
				,rgb($w[h +   552])=(s0[h +   552][0],s0[h +   552][1],s0[h +   552][2],s0[h +   552][3]),hideTrace($w[h +   552])=(s1[h +   552]),rgb($w[h +   553])=(s0[h +   553][0],s0[h +   553][1],s0[h +   553][2],s0[h +   553][3]),hideTrace($w[h +   553])=(s1[h +   553]),rgb($w[h +   554])=(s0[h +   554][0],s0[h +   554][1],s0[h +   554][2],s0[h +   554][3]),hideTrace($w[h +   554])=(s1[h +   554]),rgb($w[h +   555])=(s0[h +   555][0],s0[h +   555][1],s0[h +   555][2],s0[h +   555][3]),hideTrace($w[h +   555])=(s1[h +   555]),rgb($w[h +   556])=(s0[h +   556][0],s0[h +   556][1],s0[h +   556][2],s0[h +   556][3]),hideTrace($w[h +   556])=(s1[h +   556]),rgb($w[h +   557])=(s0[h +   557][0],s0[h +   557][1],s0[h +   557][2],s0[h +   557][3]),hideTrace($w[h +   557])=(s1[h +   557]),rgb($w[h +   558])=(s0[h +   558][0],s0[h +   558][1],s0[h +   558][2],s0[h +   558][3]),hideTrace($w[h +   558])=(s1[h +   558]),rgb($w[h +   559])=(s0[h +   559][0],s0[h +   559][1],s0[h +   559][2],s0[h +   559][3]),hideTrace($w[h +   559])=(s1[h +   559]) \
				,rgb($w[h +   560])=(s0[h +   560][0],s0[h +   560][1],s0[h +   560][2],s0[h +   560][3]),hideTrace($w[h +   560])=(s1[h +   560]),rgb($w[h +   561])=(s0[h +   561][0],s0[h +   561][1],s0[h +   561][2],s0[h +   561][3]),hideTrace($w[h +   561])=(s1[h +   561]),rgb($w[h +   562])=(s0[h +   562][0],s0[h +   562][1],s0[h +   562][2],s0[h +   562][3]),hideTrace($w[h +   562])=(s1[h +   562]),rgb($w[h +   563])=(s0[h +   563][0],s0[h +   563][1],s0[h +   563][2],s0[h +   563][3]),hideTrace($w[h +   563])=(s1[h +   563]),rgb($w[h +   564])=(s0[h +   564][0],s0[h +   564][1],s0[h +   564][2],s0[h +   564][3]),hideTrace($w[h +   564])=(s1[h +   564]),rgb($w[h +   565])=(s0[h +   565][0],s0[h +   565][1],s0[h +   565][2],s0[h +   565][3]),hideTrace($w[h +   565])=(s1[h +   565]),rgb($w[h +   566])=(s0[h +   566][0],s0[h +   566][1],s0[h +   566][2],s0[h +   566][3]),hideTrace($w[h +   566])=(s1[h +   566]),rgb($w[h +   567])=(s0[h +   567][0],s0[h +   567][1],s0[h +   567][2],s0[h +   567][3]),hideTrace($w[h +   567])=(s1[h +   567]) \
				,rgb($w[h +   568])=(s0[h +   568][0],s0[h +   568][1],s0[h +   568][2],s0[h +   568][3]),hideTrace($w[h +   568])=(s1[h +   568]),rgb($w[h +   569])=(s0[h +   569][0],s0[h +   569][1],s0[h +   569][2],s0[h +   569][3]),hideTrace($w[h +   569])=(s1[h +   569]),rgb($w[h +   570])=(s0[h +   570][0],s0[h +   570][1],s0[h +   570][2],s0[h +   570][3]),hideTrace($w[h +   570])=(s1[h +   570]),rgb($w[h +   571])=(s0[h +   571][0],s0[h +   571][1],s0[h +   571][2],s0[h +   571][3]),hideTrace($w[h +   571])=(s1[h +   571]),rgb($w[h +   572])=(s0[h +   572][0],s0[h +   572][1],s0[h +   572][2],s0[h +   572][3]),hideTrace($w[h +   572])=(s1[h +   572]),rgb($w[h +   573])=(s0[h +   573][0],s0[h +   573][1],s0[h +   573][2],s0[h +   573][3]),hideTrace($w[h +   573])=(s1[h +   573]),rgb($w[h +   574])=(s0[h +   574][0],s0[h +   574][1],s0[h +   574][2],s0[h +   574][3]),hideTrace($w[h +   574])=(s1[h +   574]),rgb($w[h +   575])=(s0[h +   575][0],s0[h +   575][1],s0[h +   575][2],s0[h +   575][3]),hideTrace($w[h +   575])=(s1[h +   575]) \
				,rgb($w[h +   576])=(s0[h +   576][0],s0[h +   576][1],s0[h +   576][2],s0[h +   576][3]),hideTrace($w[h +   576])=(s1[h +   576]),rgb($w[h +   577])=(s0[h +   577][0],s0[h +   577][1],s0[h +   577][2],s0[h +   577][3]),hideTrace($w[h +   577])=(s1[h +   577]),rgb($w[h +   578])=(s0[h +   578][0],s0[h +   578][1],s0[h +   578][2],s0[h +   578][3]),hideTrace($w[h +   578])=(s1[h +   578]),rgb($w[h +   579])=(s0[h +   579][0],s0[h +   579][1],s0[h +   579][2],s0[h +   579][3]),hideTrace($w[h +   579])=(s1[h +   579]),rgb($w[h +   580])=(s0[h +   580][0],s0[h +   580][1],s0[h +   580][2],s0[h +   580][3]),hideTrace($w[h +   580])=(s1[h +   580]),rgb($w[h +   581])=(s0[h +   581][0],s0[h +   581][1],s0[h +   581][2],s0[h +   581][3]),hideTrace($w[h +   581])=(s1[h +   581]),rgb($w[h +   582])=(s0[h +   582][0],s0[h +   582][1],s0[h +   582][2],s0[h +   582][3]),hideTrace($w[h +   582])=(s1[h +   582]),rgb($w[h +   583])=(s0[h +   583][0],s0[h +   583][1],s0[h +   583][2],s0[h +   583][3]),hideTrace($w[h +   583])=(s1[h +   583]) \
				,rgb($w[h +   584])=(s0[h +   584][0],s0[h +   584][1],s0[h +   584][2],s0[h +   584][3]),hideTrace($w[h +   584])=(s1[h +   584]),rgb($w[h +   585])=(s0[h +   585][0],s0[h +   585][1],s0[h +   585][2],s0[h +   585][3]),hideTrace($w[h +   585])=(s1[h +   585]),rgb($w[h +   586])=(s0[h +   586][0],s0[h +   586][1],s0[h +   586][2],s0[h +   586][3]),hideTrace($w[h +   586])=(s1[h +   586]),rgb($w[h +   587])=(s0[h +   587][0],s0[h +   587][1],s0[h +   587][2],s0[h +   587][3]),hideTrace($w[h +   587])=(s1[h +   587]),rgb($w[h +   588])=(s0[h +   588][0],s0[h +   588][1],s0[h +   588][2],s0[h +   588][3]),hideTrace($w[h +   588])=(s1[h +   588]),rgb($w[h +   589])=(s0[h +   589][0],s0[h +   589][1],s0[h +   589][2],s0[h +   589][3]),hideTrace($w[h +   589])=(s1[h +   589]),rgb($w[h +   590])=(s0[h +   590][0],s0[h +   590][1],s0[h +   590][2],s0[h +   590][3]),hideTrace($w[h +   590])=(s1[h +   590]),rgb($w[h +   591])=(s0[h +   591][0],s0[h +   591][1],s0[h +   591][2],s0[h +   591][3]),hideTrace($w[h +   591])=(s1[h +   591]) \
				,rgb($w[h +   592])=(s0[h +   592][0],s0[h +   592][1],s0[h +   592][2],s0[h +   592][3]),hideTrace($w[h +   592])=(s1[h +   592]),rgb($w[h +   593])=(s0[h +   593][0],s0[h +   593][1],s0[h +   593][2],s0[h +   593][3]),hideTrace($w[h +   593])=(s1[h +   593]),rgb($w[h +   594])=(s0[h +   594][0],s0[h +   594][1],s0[h +   594][2],s0[h +   594][3]),hideTrace($w[h +   594])=(s1[h +   594]),rgb($w[h +   595])=(s0[h +   595][0],s0[h +   595][1],s0[h +   595][2],s0[h +   595][3]),hideTrace($w[h +   595])=(s1[h +   595]),rgb($w[h +   596])=(s0[h +   596][0],s0[h +   596][1],s0[h +   596][2],s0[h +   596][3]),hideTrace($w[h +   596])=(s1[h +   596]),rgb($w[h +   597])=(s0[h +   597][0],s0[h +   597][1],s0[h +   597][2],s0[h +   597][3]),hideTrace($w[h +   597])=(s1[h +   597]),rgb($w[h +   598])=(s0[h +   598][0],s0[h +   598][1],s0[h +   598][2],s0[h +   598][3]),hideTrace($w[h +   598])=(s1[h +   598]),rgb($w[h +   599])=(s0[h +   599][0],s0[h +   599][1],s0[h +   599][2],s0[h +   599][3]),hideTrace($w[h +   599])=(s1[h +   599]) \
				,rgb($w[h +   600])=(s0[h +   600][0],s0[h +   600][1],s0[h +   600][2],s0[h +   600][3]),hideTrace($w[h +   600])=(s1[h +   600]),rgb($w[h +   601])=(s0[h +   601][0],s0[h +   601][1],s0[h +   601][2],s0[h +   601][3]),hideTrace($w[h +   601])=(s1[h +   601]),rgb($w[h +   602])=(s0[h +   602][0],s0[h +   602][1],s0[h +   602][2],s0[h +   602][3]),hideTrace($w[h +   602])=(s1[h +   602]),rgb($w[h +   603])=(s0[h +   603][0],s0[h +   603][1],s0[h +   603][2],s0[h +   603][3]),hideTrace($w[h +   603])=(s1[h +   603]),rgb($w[h +   604])=(s0[h +   604][0],s0[h +   604][1],s0[h +   604][2],s0[h +   604][3]),hideTrace($w[h +   604])=(s1[h +   604]),rgb($w[h +   605])=(s0[h +   605][0],s0[h +   605][1],s0[h +   605][2],s0[h +   605][3]),hideTrace($w[h +   605])=(s1[h +   605]),rgb($w[h +   606])=(s0[h +   606][0],s0[h +   606][1],s0[h +   606][2],s0[h +   606][3]),hideTrace($w[h +   606])=(s1[h +   606]),rgb($w[h +   607])=(s0[h +   607][0],s0[h +   607][1],s0[h +   607][2],s0[h +   607][3]),hideTrace($w[h +   607])=(s1[h +   607]) \
				,rgb($w[h +   608])=(s0[h +   608][0],s0[h +   608][1],s0[h +   608][2],s0[h +   608][3]),hideTrace($w[h +   608])=(s1[h +   608]),rgb($w[h +   609])=(s0[h +   609][0],s0[h +   609][1],s0[h +   609][2],s0[h +   609][3]),hideTrace($w[h +   609])=(s1[h +   609]),rgb($w[h +   610])=(s0[h +   610][0],s0[h +   610][1],s0[h +   610][2],s0[h +   610][3]),hideTrace($w[h +   610])=(s1[h +   610]),rgb($w[h +   611])=(s0[h +   611][0],s0[h +   611][1],s0[h +   611][2],s0[h +   611][3]),hideTrace($w[h +   611])=(s1[h +   611]),rgb($w[h +   612])=(s0[h +   612][0],s0[h +   612][1],s0[h +   612][2],s0[h +   612][3]),hideTrace($w[h +   612])=(s1[h +   612]),rgb($w[h +   613])=(s0[h +   613][0],s0[h +   613][1],s0[h +   613][2],s0[h +   613][3]),hideTrace($w[h +   613])=(s1[h +   613]),rgb($w[h +   614])=(s0[h +   614][0],s0[h +   614][1],s0[h +   614][2],s0[h +   614][3]),hideTrace($w[h +   614])=(s1[h +   614]),rgb($w[h +   615])=(s0[h +   615][0],s0[h +   615][1],s0[h +   615][2],s0[h +   615][3]),hideTrace($w[h +   615])=(s1[h +   615]) \
				,rgb($w[h +   616])=(s0[h +   616][0],s0[h +   616][1],s0[h +   616][2],s0[h +   616][3]),hideTrace($w[h +   616])=(s1[h +   616]),rgb($w[h +   617])=(s0[h +   617][0],s0[h +   617][1],s0[h +   617][2],s0[h +   617][3]),hideTrace($w[h +   617])=(s1[h +   617]),rgb($w[h +   618])=(s0[h +   618][0],s0[h +   618][1],s0[h +   618][2],s0[h +   618][3]),hideTrace($w[h +   618])=(s1[h +   618]),rgb($w[h +   619])=(s0[h +   619][0],s0[h +   619][1],s0[h +   619][2],s0[h +   619][3]),hideTrace($w[h +   619])=(s1[h +   619]),rgb($w[h +   620])=(s0[h +   620][0],s0[h +   620][1],s0[h +   620][2],s0[h +   620][3]),hideTrace($w[h +   620])=(s1[h +   620]),rgb($w[h +   621])=(s0[h +   621][0],s0[h +   621][1],s0[h +   621][2],s0[h +   621][3]),hideTrace($w[h +   621])=(s1[h +   621]),rgb($w[h +   622])=(s0[h +   622][0],s0[h +   622][1],s0[h +   622][2],s0[h +   622][3]),hideTrace($w[h +   622])=(s1[h +   622]),rgb($w[h +   623])=(s0[h +   623][0],s0[h +   623][1],s0[h +   623][2],s0[h +   623][3]),hideTrace($w[h +   623])=(s1[h +   623]) \
				,rgb($w[h +   624])=(s0[h +   624][0],s0[h +   624][1],s0[h +   624][2],s0[h +   624][3]),hideTrace($w[h +   624])=(s1[h +   624]),rgb($w[h +   625])=(s0[h +   625][0],s0[h +   625][1],s0[h +   625][2],s0[h +   625][3]),hideTrace($w[h +   625])=(s1[h +   625]),rgb($w[h +   626])=(s0[h +   626][0],s0[h +   626][1],s0[h +   626][2],s0[h +   626][3]),hideTrace($w[h +   626])=(s1[h +   626]),rgb($w[h +   627])=(s0[h +   627][0],s0[h +   627][1],s0[h +   627][2],s0[h +   627][3]),hideTrace($w[h +   627])=(s1[h +   627]),rgb($w[h +   628])=(s0[h +   628][0],s0[h +   628][1],s0[h +   628][2],s0[h +   628][3]),hideTrace($w[h +   628])=(s1[h +   628]),rgb($w[h +   629])=(s0[h +   629][0],s0[h +   629][1],s0[h +   629][2],s0[h +   629][3]),hideTrace($w[h +   629])=(s1[h +   629]),rgb($w[h +   630])=(s0[h +   630][0],s0[h +   630][1],s0[h +   630][2],s0[h +   630][3]),hideTrace($w[h +   630])=(s1[h +   630]),rgb($w[h +   631])=(s0[h +   631][0],s0[h +   631][1],s0[h +   631][2],s0[h +   631][3]),hideTrace($w[h +   631])=(s1[h +   631]) \
				,rgb($w[h +   632])=(s0[h +   632][0],s0[h +   632][1],s0[h +   632][2],s0[h +   632][3]),hideTrace($w[h +   632])=(s1[h +   632]),rgb($w[h +   633])=(s0[h +   633][0],s0[h +   633][1],s0[h +   633][2],s0[h +   633][3]),hideTrace($w[h +   633])=(s1[h +   633]),rgb($w[h +   634])=(s0[h +   634][0],s0[h +   634][1],s0[h +   634][2],s0[h +   634][3]),hideTrace($w[h +   634])=(s1[h +   634]),rgb($w[h +   635])=(s0[h +   635][0],s0[h +   635][1],s0[h +   635][2],s0[h +   635][3]),hideTrace($w[h +   635])=(s1[h +   635]),rgb($w[h +   636])=(s0[h +   636][0],s0[h +   636][1],s0[h +   636][2],s0[h +   636][3]),hideTrace($w[h +   636])=(s1[h +   636]),rgb($w[h +   637])=(s0[h +   637][0],s0[h +   637][1],s0[h +   637][2],s0[h +   637][3]),hideTrace($w[h +   637])=(s1[h +   637]),rgb($w[h +   638])=(s0[h +   638][0],s0[h +   638][1],s0[h +   638][2],s0[h +   638][3]),hideTrace($w[h +   638])=(s1[h +   638]),rgb($w[h +   639])=(s0[h +   639][0],s0[h +   639][1],s0[h +   639][2],s0[h +   639][3]),hideTrace($w[h +   639])=(s1[h +   639]) \
				,rgb($w[h +   640])=(s0[h +   640][0],s0[h +   640][1],s0[h +   640][2],s0[h +   640][3]),hideTrace($w[h +   640])=(s1[h +   640]),rgb($w[h +   641])=(s0[h +   641][0],s0[h +   641][1],s0[h +   641][2],s0[h +   641][3]),hideTrace($w[h +   641])=(s1[h +   641]),rgb($w[h +   642])=(s0[h +   642][0],s0[h +   642][1],s0[h +   642][2],s0[h +   642][3]),hideTrace($w[h +   642])=(s1[h +   642]),rgb($w[h +   643])=(s0[h +   643][0],s0[h +   643][1],s0[h +   643][2],s0[h +   643][3]),hideTrace($w[h +   643])=(s1[h +   643]),rgb($w[h +   644])=(s0[h +   644][0],s0[h +   644][1],s0[h +   644][2],s0[h +   644][3]),hideTrace($w[h +   644])=(s1[h +   644]),rgb($w[h +   645])=(s0[h +   645][0],s0[h +   645][1],s0[h +   645][2],s0[h +   645][3]),hideTrace($w[h +   645])=(s1[h +   645]),rgb($w[h +   646])=(s0[h +   646][0],s0[h +   646][1],s0[h +   646][2],s0[h +   646][3]),hideTrace($w[h +   646])=(s1[h +   646]),rgb($w[h +   647])=(s0[h +   647][0],s0[h +   647][1],s0[h +   647][2],s0[h +   647][3]),hideTrace($w[h +   647])=(s1[h +   647]) \
				,rgb($w[h +   648])=(s0[h +   648][0],s0[h +   648][1],s0[h +   648][2],s0[h +   648][3]),hideTrace($w[h +   648])=(s1[h +   648]),rgb($w[h +   649])=(s0[h +   649][0],s0[h +   649][1],s0[h +   649][2],s0[h +   649][3]),hideTrace($w[h +   649])=(s1[h +   649]),rgb($w[h +   650])=(s0[h +   650][0],s0[h +   650][1],s0[h +   650][2],s0[h +   650][3]),hideTrace($w[h +   650])=(s1[h +   650]),rgb($w[h +   651])=(s0[h +   651][0],s0[h +   651][1],s0[h +   651][2],s0[h +   651][3]),hideTrace($w[h +   651])=(s1[h +   651]),rgb($w[h +   652])=(s0[h +   652][0],s0[h +   652][1],s0[h +   652][2],s0[h +   652][3]),hideTrace($w[h +   652])=(s1[h +   652]),rgb($w[h +   653])=(s0[h +   653][0],s0[h +   653][1],s0[h +   653][2],s0[h +   653][3]),hideTrace($w[h +   653])=(s1[h +   653]),rgb($w[h +   654])=(s0[h +   654][0],s0[h +   654][1],s0[h +   654][2],s0[h +   654][3]),hideTrace($w[h +   654])=(s1[h +   654]),rgb($w[h +   655])=(s0[h +   655][0],s0[h +   655][1],s0[h +   655][2],s0[h +   655][3]),hideTrace($w[h +   655])=(s1[h +   655]) \
				,rgb($w[h +   656])=(s0[h +   656][0],s0[h +   656][1],s0[h +   656][2],s0[h +   656][3]),hideTrace($w[h +   656])=(s1[h +   656]),rgb($w[h +   657])=(s0[h +   657][0],s0[h +   657][1],s0[h +   657][2],s0[h +   657][3]),hideTrace($w[h +   657])=(s1[h +   657]),rgb($w[h +   658])=(s0[h +   658][0],s0[h +   658][1],s0[h +   658][2],s0[h +   658][3]),hideTrace($w[h +   658])=(s1[h +   658]),rgb($w[h +   659])=(s0[h +   659][0],s0[h +   659][1],s0[h +   659][2],s0[h +   659][3]),hideTrace($w[h +   659])=(s1[h +   659]),rgb($w[h +   660])=(s0[h +   660][0],s0[h +   660][1],s0[h +   660][2],s0[h +   660][3]),hideTrace($w[h +   660])=(s1[h +   660]),rgb($w[h +   661])=(s0[h +   661][0],s0[h +   661][1],s0[h +   661][2],s0[h +   661][3]),hideTrace($w[h +   661])=(s1[h +   661]),rgb($w[h +   662])=(s0[h +   662][0],s0[h +   662][1],s0[h +   662][2],s0[h +   662][3]),hideTrace($w[h +   662])=(s1[h +   662]),rgb($w[h +   663])=(s0[h +   663][0],s0[h +   663][1],s0[h +   663][2],s0[h +   663][3]),hideTrace($w[h +   663])=(s1[h +   663]) \
				,rgb($w[h +   664])=(s0[h +   664][0],s0[h +   664][1],s0[h +   664][2],s0[h +   664][3]),hideTrace($w[h +   664])=(s1[h +   664]),rgb($w[h +   665])=(s0[h +   665][0],s0[h +   665][1],s0[h +   665][2],s0[h +   665][3]),hideTrace($w[h +   665])=(s1[h +   665]),rgb($w[h +   666])=(s0[h +   666][0],s0[h +   666][1],s0[h +   666][2],s0[h +   666][3]),hideTrace($w[h +   666])=(s1[h +   666]),rgb($w[h +   667])=(s0[h +   667][0],s0[h +   667][1],s0[h +   667][2],s0[h +   667][3]),hideTrace($w[h +   667])=(s1[h +   667]),rgb($w[h +   668])=(s0[h +   668][0],s0[h +   668][1],s0[h +   668][2],s0[h +   668][3]),hideTrace($w[h +   668])=(s1[h +   668]),rgb($w[h +   669])=(s0[h +   669][0],s0[h +   669][1],s0[h +   669][2],s0[h +   669][3]),hideTrace($w[h +   669])=(s1[h +   669]),rgb($w[h +   670])=(s0[h +   670][0],s0[h +   670][1],s0[h +   670][2],s0[h +   670][3]),hideTrace($w[h +   670])=(s1[h +   670]),rgb($w[h +   671])=(s0[h +   671][0],s0[h +   671][1],s0[h +   671][2],s0[h +   671][3]),hideTrace($w[h +   671])=(s1[h +   671]) \
				,rgb($w[h +   672])=(s0[h +   672][0],s0[h +   672][1],s0[h +   672][2],s0[h +   672][3]),hideTrace($w[h +   672])=(s1[h +   672]),rgb($w[h +   673])=(s0[h +   673][0],s0[h +   673][1],s0[h +   673][2],s0[h +   673][3]),hideTrace($w[h +   673])=(s1[h +   673]),rgb($w[h +   674])=(s0[h +   674][0],s0[h +   674][1],s0[h +   674][2],s0[h +   674][3]),hideTrace($w[h +   674])=(s1[h +   674]),rgb($w[h +   675])=(s0[h +   675][0],s0[h +   675][1],s0[h +   675][2],s0[h +   675][3]),hideTrace($w[h +   675])=(s1[h +   675]),rgb($w[h +   676])=(s0[h +   676][0],s0[h +   676][1],s0[h +   676][2],s0[h +   676][3]),hideTrace($w[h +   676])=(s1[h +   676]),rgb($w[h +   677])=(s0[h +   677][0],s0[h +   677][1],s0[h +   677][2],s0[h +   677][3]),hideTrace($w[h +   677])=(s1[h +   677]),rgb($w[h +   678])=(s0[h +   678][0],s0[h +   678][1],s0[h +   678][2],s0[h +   678][3]),hideTrace($w[h +   678])=(s1[h +   678]),rgb($w[h +   679])=(s0[h +   679][0],s0[h +   679][1],s0[h +   679][2],s0[h +   679][3]),hideTrace($w[h +   679])=(s1[h +   679]) \
				,rgb($w[h +   680])=(s0[h +   680][0],s0[h +   680][1],s0[h +   680][2],s0[h +   680][3]),hideTrace($w[h +   680])=(s1[h +   680]),rgb($w[h +   681])=(s0[h +   681][0],s0[h +   681][1],s0[h +   681][2],s0[h +   681][3]),hideTrace($w[h +   681])=(s1[h +   681]),rgb($w[h +   682])=(s0[h +   682][0],s0[h +   682][1],s0[h +   682][2],s0[h +   682][3]),hideTrace($w[h +   682])=(s1[h +   682]),rgb($w[h +   683])=(s0[h +   683][0],s0[h +   683][1],s0[h +   683][2],s0[h +   683][3]),hideTrace($w[h +   683])=(s1[h +   683]),rgb($w[h +   684])=(s0[h +   684][0],s0[h +   684][1],s0[h +   684][2],s0[h +   684][3]),hideTrace($w[h +   684])=(s1[h +   684]),rgb($w[h +   685])=(s0[h +   685][0],s0[h +   685][1],s0[h +   685][2],s0[h +   685][3]),hideTrace($w[h +   685])=(s1[h +   685]),rgb($w[h +   686])=(s0[h +   686][0],s0[h +   686][1],s0[h +   686][2],s0[h +   686][3]),hideTrace($w[h +   686])=(s1[h +   686]),rgb($w[h +   687])=(s0[h +   687][0],s0[h +   687][1],s0[h +   687][2],s0[h +   687][3]),hideTrace($w[h +   687])=(s1[h +   687]) \
				,rgb($w[h +   688])=(s0[h +   688][0],s0[h +   688][1],s0[h +   688][2],s0[h +   688][3]),hideTrace($w[h +   688])=(s1[h +   688]),rgb($w[h +   689])=(s0[h +   689][0],s0[h +   689][1],s0[h +   689][2],s0[h +   689][3]),hideTrace($w[h +   689])=(s1[h +   689]),rgb($w[h +   690])=(s0[h +   690][0],s0[h +   690][1],s0[h +   690][2],s0[h +   690][3]),hideTrace($w[h +   690])=(s1[h +   690]),rgb($w[h +   691])=(s0[h +   691][0],s0[h +   691][1],s0[h +   691][2],s0[h +   691][3]),hideTrace($w[h +   691])=(s1[h +   691]),rgb($w[h +   692])=(s0[h +   692][0],s0[h +   692][1],s0[h +   692][2],s0[h +   692][3]),hideTrace($w[h +   692])=(s1[h +   692]),rgb($w[h +   693])=(s0[h +   693][0],s0[h +   693][1],s0[h +   693][2],s0[h +   693][3]),hideTrace($w[h +   693])=(s1[h +   693]),rgb($w[h +   694])=(s0[h +   694][0],s0[h +   694][1],s0[h +   694][2],s0[h +   694][3]),hideTrace($w[h +   694])=(s1[h +   694]),rgb($w[h +   695])=(s0[h +   695][0],s0[h +   695][1],s0[h +   695][2],s0[h +   695][3]),hideTrace($w[h +   695])=(s1[h +   695]) \
				,rgb($w[h +   696])=(s0[h +   696][0],s0[h +   696][1],s0[h +   696][2],s0[h +   696][3]),hideTrace($w[h +   696])=(s1[h +   696]),rgb($w[h +   697])=(s0[h +   697][0],s0[h +   697][1],s0[h +   697][2],s0[h +   697][3]),hideTrace($w[h +   697])=(s1[h +   697]),rgb($w[h +   698])=(s0[h +   698][0],s0[h +   698][1],s0[h +   698][2],s0[h +   698][3]),hideTrace($w[h +   698])=(s1[h +   698]),rgb($w[h +   699])=(s0[h +   699][0],s0[h +   699][1],s0[h +   699][2],s0[h +   699][3]),hideTrace($w[h +   699])=(s1[h +   699]),rgb($w[h +   700])=(s0[h +   700][0],s0[h +   700][1],s0[h +   700][2],s0[h +   700][3]),hideTrace($w[h +   700])=(s1[h +   700]),rgb($w[h +   701])=(s0[h +   701][0],s0[h +   701][1],s0[h +   701][2],s0[h +   701][3]),hideTrace($w[h +   701])=(s1[h +   701]),rgb($w[h +   702])=(s0[h +   702][0],s0[h +   702][1],s0[h +   702][2],s0[h +   702][3]),hideTrace($w[h +   702])=(s1[h +   702]),rgb($w[h +   703])=(s0[h +   703][0],s0[h +   703][1],s0[h +   703][2],s0[h +   703][3]),hideTrace($w[h +   703])=(s1[h +   703]) \
				,rgb($w[h +   704])=(s0[h +   704][0],s0[h +   704][1],s0[h +   704][2],s0[h +   704][3]),hideTrace($w[h +   704])=(s1[h +   704]),rgb($w[h +   705])=(s0[h +   705][0],s0[h +   705][1],s0[h +   705][2],s0[h +   705][3]),hideTrace($w[h +   705])=(s1[h +   705]),rgb($w[h +   706])=(s0[h +   706][0],s0[h +   706][1],s0[h +   706][2],s0[h +   706][3]),hideTrace($w[h +   706])=(s1[h +   706]),rgb($w[h +   707])=(s0[h +   707][0],s0[h +   707][1],s0[h +   707][2],s0[h +   707][3]),hideTrace($w[h +   707])=(s1[h +   707]),rgb($w[h +   708])=(s0[h +   708][0],s0[h +   708][1],s0[h +   708][2],s0[h +   708][3]),hideTrace($w[h +   708])=(s1[h +   708]),rgb($w[h +   709])=(s0[h +   709][0],s0[h +   709][1],s0[h +   709][2],s0[h +   709][3]),hideTrace($w[h +   709])=(s1[h +   709]),rgb($w[h +   710])=(s0[h +   710][0],s0[h +   710][1],s0[h +   710][2],s0[h +   710][3]),hideTrace($w[h +   710])=(s1[h +   710]),rgb($w[h +   711])=(s0[h +   711][0],s0[h +   711][1],s0[h +   711][2],s0[h +   711][3]),hideTrace($w[h +   711])=(s1[h +   711]) \
				,rgb($w[h +   712])=(s0[h +   712][0],s0[h +   712][1],s0[h +   712][2],s0[h +   712][3]),hideTrace($w[h +   712])=(s1[h +   712]),rgb($w[h +   713])=(s0[h +   713][0],s0[h +   713][1],s0[h +   713][2],s0[h +   713][3]),hideTrace($w[h +   713])=(s1[h +   713]),rgb($w[h +   714])=(s0[h +   714][0],s0[h +   714][1],s0[h +   714][2],s0[h +   714][3]),hideTrace($w[h +   714])=(s1[h +   714]),rgb($w[h +   715])=(s0[h +   715][0],s0[h +   715][1],s0[h +   715][2],s0[h +   715][3]),hideTrace($w[h +   715])=(s1[h +   715]),rgb($w[h +   716])=(s0[h +   716][0],s0[h +   716][1],s0[h +   716][2],s0[h +   716][3]),hideTrace($w[h +   716])=(s1[h +   716]),rgb($w[h +   717])=(s0[h +   717][0],s0[h +   717][1],s0[h +   717][2],s0[h +   717][3]),hideTrace($w[h +   717])=(s1[h +   717]),rgb($w[h +   718])=(s0[h +   718][0],s0[h +   718][1],s0[h +   718][2],s0[h +   718][3]),hideTrace($w[h +   718])=(s1[h +   718]),rgb($w[h +   719])=(s0[h +   719][0],s0[h +   719][1],s0[h +   719][2],s0[h +   719][3]),hideTrace($w[h +   719])=(s1[h +   719]) \
				,rgb($w[h +   720])=(s0[h +   720][0],s0[h +   720][1],s0[h +   720][2],s0[h +   720][3]),hideTrace($w[h +   720])=(s1[h +   720]),rgb($w[h +   721])=(s0[h +   721][0],s0[h +   721][1],s0[h +   721][2],s0[h +   721][3]),hideTrace($w[h +   721])=(s1[h +   721]),rgb($w[h +   722])=(s0[h +   722][0],s0[h +   722][1],s0[h +   722][2],s0[h +   722][3]),hideTrace($w[h +   722])=(s1[h +   722]),rgb($w[h +   723])=(s0[h +   723][0],s0[h +   723][1],s0[h +   723][2],s0[h +   723][3]),hideTrace($w[h +   723])=(s1[h +   723]),rgb($w[h +   724])=(s0[h +   724][0],s0[h +   724][1],s0[h +   724][2],s0[h +   724][3]),hideTrace($w[h +   724])=(s1[h +   724]),rgb($w[h +   725])=(s0[h +   725][0],s0[h +   725][1],s0[h +   725][2],s0[h +   725][3]),hideTrace($w[h +   725])=(s1[h +   725]),rgb($w[h +   726])=(s0[h +   726][0],s0[h +   726][1],s0[h +   726][2],s0[h +   726][3]),hideTrace($w[h +   726])=(s1[h +   726]),rgb($w[h +   727])=(s0[h +   727][0],s0[h +   727][1],s0[h +   727][2],s0[h +   727][3]),hideTrace($w[h +   727])=(s1[h +   727]) \
				,rgb($w[h +   728])=(s0[h +   728][0],s0[h +   728][1],s0[h +   728][2],s0[h +   728][3]),hideTrace($w[h +   728])=(s1[h +   728]),rgb($w[h +   729])=(s0[h +   729][0],s0[h +   729][1],s0[h +   729][2],s0[h +   729][3]),hideTrace($w[h +   729])=(s1[h +   729]),rgb($w[h +   730])=(s0[h +   730][0],s0[h +   730][1],s0[h +   730][2],s0[h +   730][3]),hideTrace($w[h +   730])=(s1[h +   730]),rgb($w[h +   731])=(s0[h +   731][0],s0[h +   731][1],s0[h +   731][2],s0[h +   731][3]),hideTrace($w[h +   731])=(s1[h +   731]),rgb($w[h +   732])=(s0[h +   732][0],s0[h +   732][1],s0[h +   732][2],s0[h +   732][3]),hideTrace($w[h +   732])=(s1[h +   732]),rgb($w[h +   733])=(s0[h +   733][0],s0[h +   733][1],s0[h +   733][2],s0[h +   733][3]),hideTrace($w[h +   733])=(s1[h +   733]),rgb($w[h +   734])=(s0[h +   734][0],s0[h +   734][1],s0[h +   734][2],s0[h +   734][3]),hideTrace($w[h +   734])=(s1[h +   734]),rgb($w[h +   735])=(s0[h +   735][0],s0[h +   735][1],s0[h +   735][2],s0[h +   735][3]),hideTrace($w[h +   735])=(s1[h +   735]) \
				,rgb($w[h +   736])=(s0[h +   736][0],s0[h +   736][1],s0[h +   736][2],s0[h +   736][3]),hideTrace($w[h +   736])=(s1[h +   736]),rgb($w[h +   737])=(s0[h +   737][0],s0[h +   737][1],s0[h +   737][2],s0[h +   737][3]),hideTrace($w[h +   737])=(s1[h +   737]),rgb($w[h +   738])=(s0[h +   738][0],s0[h +   738][1],s0[h +   738][2],s0[h +   738][3]),hideTrace($w[h +   738])=(s1[h +   738]),rgb($w[h +   739])=(s0[h +   739][0],s0[h +   739][1],s0[h +   739][2],s0[h +   739][3]),hideTrace($w[h +   739])=(s1[h +   739]),rgb($w[h +   740])=(s0[h +   740][0],s0[h +   740][1],s0[h +   740][2],s0[h +   740][3]),hideTrace($w[h +   740])=(s1[h +   740]),rgb($w[h +   741])=(s0[h +   741][0],s0[h +   741][1],s0[h +   741][2],s0[h +   741][3]),hideTrace($w[h +   741])=(s1[h +   741]),rgb($w[h +   742])=(s0[h +   742][0],s0[h +   742][1],s0[h +   742][2],s0[h +   742][3]),hideTrace($w[h +   742])=(s1[h +   742]),rgb($w[h +   743])=(s0[h +   743][0],s0[h +   743][1],s0[h +   743][2],s0[h +   743][3]),hideTrace($w[h +   743])=(s1[h +   743]) \
				,rgb($w[h +   744])=(s0[h +   744][0],s0[h +   744][1],s0[h +   744][2],s0[h +   744][3]),hideTrace($w[h +   744])=(s1[h +   744]),rgb($w[h +   745])=(s0[h +   745][0],s0[h +   745][1],s0[h +   745][2],s0[h +   745][3]),hideTrace($w[h +   745])=(s1[h +   745]),rgb($w[h +   746])=(s0[h +   746][0],s0[h +   746][1],s0[h +   746][2],s0[h +   746][3]),hideTrace($w[h +   746])=(s1[h +   746]),rgb($w[h +   747])=(s0[h +   747][0],s0[h +   747][1],s0[h +   747][2],s0[h +   747][3]),hideTrace($w[h +   747])=(s1[h +   747]),rgb($w[h +   748])=(s0[h +   748][0],s0[h +   748][1],s0[h +   748][2],s0[h +   748][3]),hideTrace($w[h +   748])=(s1[h +   748]),rgb($w[h +   749])=(s0[h +   749][0],s0[h +   749][1],s0[h +   749][2],s0[h +   749][3]),hideTrace($w[h +   749])=(s1[h +   749]),rgb($w[h +   750])=(s0[h +   750][0],s0[h +   750][1],s0[h +   750][2],s0[h +   750][3]),hideTrace($w[h +   750])=(s1[h +   750]),rgb($w[h +   751])=(s0[h +   751][0],s0[h +   751][1],s0[h +   751][2],s0[h +   751][3]),hideTrace($w[h +   751])=(s1[h +   751]) \
				,rgb($w[h +   752])=(s0[h +   752][0],s0[h +   752][1],s0[h +   752][2],s0[h +   752][3]),hideTrace($w[h +   752])=(s1[h +   752]),rgb($w[h +   753])=(s0[h +   753][0],s0[h +   753][1],s0[h +   753][2],s0[h +   753][3]),hideTrace($w[h +   753])=(s1[h +   753]),rgb($w[h +   754])=(s0[h +   754][0],s0[h +   754][1],s0[h +   754][2],s0[h +   754][3]),hideTrace($w[h +   754])=(s1[h +   754]),rgb($w[h +   755])=(s0[h +   755][0],s0[h +   755][1],s0[h +   755][2],s0[h +   755][3]),hideTrace($w[h +   755])=(s1[h +   755]),rgb($w[h +   756])=(s0[h +   756][0],s0[h +   756][1],s0[h +   756][2],s0[h +   756][3]),hideTrace($w[h +   756])=(s1[h +   756]),rgb($w[h +   757])=(s0[h +   757][0],s0[h +   757][1],s0[h +   757][2],s0[h +   757][3]),hideTrace($w[h +   757])=(s1[h +   757]),rgb($w[h +   758])=(s0[h +   758][0],s0[h +   758][1],s0[h +   758][2],s0[h +   758][3]),hideTrace($w[h +   758])=(s1[h +   758]),rgb($w[h +   759])=(s0[h +   759][0],s0[h +   759][1],s0[h +   759][2],s0[h +   759][3]),hideTrace($w[h +   759])=(s1[h +   759]) \
				,rgb($w[h +   760])=(s0[h +   760][0],s0[h +   760][1],s0[h +   760][2],s0[h +   760][3]),hideTrace($w[h +   760])=(s1[h +   760]),rgb($w[h +   761])=(s0[h +   761][0],s0[h +   761][1],s0[h +   761][2],s0[h +   761][3]),hideTrace($w[h +   761])=(s1[h +   761]),rgb($w[h +   762])=(s0[h +   762][0],s0[h +   762][1],s0[h +   762][2],s0[h +   762][3]),hideTrace($w[h +   762])=(s1[h +   762]),rgb($w[h +   763])=(s0[h +   763][0],s0[h +   763][1],s0[h +   763][2],s0[h +   763][3]),hideTrace($w[h +   763])=(s1[h +   763]),rgb($w[h +   764])=(s0[h +   764][0],s0[h +   764][1],s0[h +   764][2],s0[h +   764][3]),hideTrace($w[h +   764])=(s1[h +   764]),rgb($w[h +   765])=(s0[h +   765][0],s0[h +   765][1],s0[h +   765][2],s0[h +   765][3]),hideTrace($w[h +   765])=(s1[h +   765]),rgb($w[h +   766])=(s0[h +   766][0],s0[h +   766][1],s0[h +   766][2],s0[h +   766][3]),hideTrace($w[h +   766])=(s1[h +   766]),rgb($w[h +   767])=(s0[h +   767][0],s0[h +   767][1],s0[h +   767][2],s0[h +   767][3]),hideTrace($w[h +   767])=(s1[h +   767]) \
				,rgb($w[h +   768])=(s0[h +   768][0],s0[h +   768][1],s0[h +   768][2],s0[h +   768][3]),hideTrace($w[h +   768])=(s1[h +   768]),rgb($w[h +   769])=(s0[h +   769][0],s0[h +   769][1],s0[h +   769][2],s0[h +   769][3]),hideTrace($w[h +   769])=(s1[h +   769]),rgb($w[h +   770])=(s0[h +   770][0],s0[h +   770][1],s0[h +   770][2],s0[h +   770][3]),hideTrace($w[h +   770])=(s1[h +   770]),rgb($w[h +   771])=(s0[h +   771][0],s0[h +   771][1],s0[h +   771][2],s0[h +   771][3]),hideTrace($w[h +   771])=(s1[h +   771]),rgb($w[h +   772])=(s0[h +   772][0],s0[h +   772][1],s0[h +   772][2],s0[h +   772][3]),hideTrace($w[h +   772])=(s1[h +   772]),rgb($w[h +   773])=(s0[h +   773][0],s0[h +   773][1],s0[h +   773][2],s0[h +   773][3]),hideTrace($w[h +   773])=(s1[h +   773]),rgb($w[h +   774])=(s0[h +   774][0],s0[h +   774][1],s0[h +   774][2],s0[h +   774][3]),hideTrace($w[h +   774])=(s1[h +   774]),rgb($w[h +   775])=(s0[h +   775][0],s0[h +   775][1],s0[h +   775][2],s0[h +   775][3]),hideTrace($w[h +   775])=(s1[h +   775]) \
				,rgb($w[h +   776])=(s0[h +   776][0],s0[h +   776][1],s0[h +   776][2],s0[h +   776][3]),hideTrace($w[h +   776])=(s1[h +   776]),rgb($w[h +   777])=(s0[h +   777][0],s0[h +   777][1],s0[h +   777][2],s0[h +   777][3]),hideTrace($w[h +   777])=(s1[h +   777]),rgb($w[h +   778])=(s0[h +   778][0],s0[h +   778][1],s0[h +   778][2],s0[h +   778][3]),hideTrace($w[h +   778])=(s1[h +   778]),rgb($w[h +   779])=(s0[h +   779][0],s0[h +   779][1],s0[h +   779][2],s0[h +   779][3]),hideTrace($w[h +   779])=(s1[h +   779]),rgb($w[h +   780])=(s0[h +   780][0],s0[h +   780][1],s0[h +   780][2],s0[h +   780][3]),hideTrace($w[h +   780])=(s1[h +   780]),rgb($w[h +   781])=(s0[h +   781][0],s0[h +   781][1],s0[h +   781][2],s0[h +   781][3]),hideTrace($w[h +   781])=(s1[h +   781]),rgb($w[h +   782])=(s0[h +   782][0],s0[h +   782][1],s0[h +   782][2],s0[h +   782][3]),hideTrace($w[h +   782])=(s1[h +   782]),rgb($w[h +   783])=(s0[h +   783][0],s0[h +   783][1],s0[h +   783][2],s0[h +   783][3]),hideTrace($w[h +   783])=(s1[h +   783]) \
				,rgb($w[h +   784])=(s0[h +   784][0],s0[h +   784][1],s0[h +   784][2],s0[h +   784][3]),hideTrace($w[h +   784])=(s1[h +   784]),rgb($w[h +   785])=(s0[h +   785][0],s0[h +   785][1],s0[h +   785][2],s0[h +   785][3]),hideTrace($w[h +   785])=(s1[h +   785]),rgb($w[h +   786])=(s0[h +   786][0],s0[h +   786][1],s0[h +   786][2],s0[h +   786][3]),hideTrace($w[h +   786])=(s1[h +   786]),rgb($w[h +   787])=(s0[h +   787][0],s0[h +   787][1],s0[h +   787][2],s0[h +   787][3]),hideTrace($w[h +   787])=(s1[h +   787]),rgb($w[h +   788])=(s0[h +   788][0],s0[h +   788][1],s0[h +   788][2],s0[h +   788][3]),hideTrace($w[h +   788])=(s1[h +   788]),rgb($w[h +   789])=(s0[h +   789][0],s0[h +   789][1],s0[h +   789][2],s0[h +   789][3]),hideTrace($w[h +   789])=(s1[h +   789]),rgb($w[h +   790])=(s0[h +   790][0],s0[h +   790][1],s0[h +   790][2],s0[h +   790][3]),hideTrace($w[h +   790])=(s1[h +   790]),rgb($w[h +   791])=(s0[h +   791][0],s0[h +   791][1],s0[h +   791][2],s0[h +   791][3]),hideTrace($w[h +   791])=(s1[h +   791]) \
				,rgb($w[h +   792])=(s0[h +   792][0],s0[h +   792][1],s0[h +   792][2],s0[h +   792][3]),hideTrace($w[h +   792])=(s1[h +   792]),rgb($w[h +   793])=(s0[h +   793][0],s0[h +   793][1],s0[h +   793][2],s0[h +   793][3]),hideTrace($w[h +   793])=(s1[h +   793]),rgb($w[h +   794])=(s0[h +   794][0],s0[h +   794][1],s0[h +   794][2],s0[h +   794][3]),hideTrace($w[h +   794])=(s1[h +   794]),rgb($w[h +   795])=(s0[h +   795][0],s0[h +   795][1],s0[h +   795][2],s0[h +   795][3]),hideTrace($w[h +   795])=(s1[h +   795]),rgb($w[h +   796])=(s0[h +   796][0],s0[h +   796][1],s0[h +   796][2],s0[h +   796][3]),hideTrace($w[h +   796])=(s1[h +   796]),rgb($w[h +   797])=(s0[h +   797][0],s0[h +   797][1],s0[h +   797][2],s0[h +   797][3]),hideTrace($w[h +   797])=(s1[h +   797]),rgb($w[h +   798])=(s0[h +   798][0],s0[h +   798][1],s0[h +   798][2],s0[h +   798][3]),hideTrace($w[h +   798])=(s1[h +   798]),rgb($w[h +   799])=(s0[h +   799][0],s0[h +   799][1],s0[h +   799][2],s0[h +   799][3]),hideTrace($w[h +   799])=(s1[h +   799]) \
				,rgb($w[h +   800])=(s0[h +   800][0],s0[h +   800][1],s0[h +   800][2],s0[h +   800][3]),hideTrace($w[h +   800])=(s1[h +   800]),rgb($w[h +   801])=(s0[h +   801][0],s0[h +   801][1],s0[h +   801][2],s0[h +   801][3]),hideTrace($w[h +   801])=(s1[h +   801]),rgb($w[h +   802])=(s0[h +   802][0],s0[h +   802][1],s0[h +   802][2],s0[h +   802][3]),hideTrace($w[h +   802])=(s1[h +   802]),rgb($w[h +   803])=(s0[h +   803][0],s0[h +   803][1],s0[h +   803][2],s0[h +   803][3]),hideTrace($w[h +   803])=(s1[h +   803]),rgb($w[h +   804])=(s0[h +   804][0],s0[h +   804][1],s0[h +   804][2],s0[h +   804][3]),hideTrace($w[h +   804])=(s1[h +   804]),rgb($w[h +   805])=(s0[h +   805][0],s0[h +   805][1],s0[h +   805][2],s0[h +   805][3]),hideTrace($w[h +   805])=(s1[h +   805]),rgb($w[h +   806])=(s0[h +   806][0],s0[h +   806][1],s0[h +   806][2],s0[h +   806][3]),hideTrace($w[h +   806])=(s1[h +   806]),rgb($w[h +   807])=(s0[h +   807][0],s0[h +   807][1],s0[h +   807][2],s0[h +   807][3]),hideTrace($w[h +   807])=(s1[h +   807]) \
				,rgb($w[h +   808])=(s0[h +   808][0],s0[h +   808][1],s0[h +   808][2],s0[h +   808][3]),hideTrace($w[h +   808])=(s1[h +   808]),rgb($w[h +   809])=(s0[h +   809][0],s0[h +   809][1],s0[h +   809][2],s0[h +   809][3]),hideTrace($w[h +   809])=(s1[h +   809]),rgb($w[h +   810])=(s0[h +   810][0],s0[h +   810][1],s0[h +   810][2],s0[h +   810][3]),hideTrace($w[h +   810])=(s1[h +   810]),rgb($w[h +   811])=(s0[h +   811][0],s0[h +   811][1],s0[h +   811][2],s0[h +   811][3]),hideTrace($w[h +   811])=(s1[h +   811]),rgb($w[h +   812])=(s0[h +   812][0],s0[h +   812][1],s0[h +   812][2],s0[h +   812][3]),hideTrace($w[h +   812])=(s1[h +   812]),rgb($w[h +   813])=(s0[h +   813][0],s0[h +   813][1],s0[h +   813][2],s0[h +   813][3]),hideTrace($w[h +   813])=(s1[h +   813]),rgb($w[h +   814])=(s0[h +   814][0],s0[h +   814][1],s0[h +   814][2],s0[h +   814][3]),hideTrace($w[h +   814])=(s1[h +   814]),rgb($w[h +   815])=(s0[h +   815][0],s0[h +   815][1],s0[h +   815][2],s0[h +   815][3]),hideTrace($w[h +   815])=(s1[h +   815]) \
				,rgb($w[h +   816])=(s0[h +   816][0],s0[h +   816][1],s0[h +   816][2],s0[h +   816][3]),hideTrace($w[h +   816])=(s1[h +   816]),rgb($w[h +   817])=(s0[h +   817][0],s0[h +   817][1],s0[h +   817][2],s0[h +   817][3]),hideTrace($w[h +   817])=(s1[h +   817]),rgb($w[h +   818])=(s0[h +   818][0],s0[h +   818][1],s0[h +   818][2],s0[h +   818][3]),hideTrace($w[h +   818])=(s1[h +   818]),rgb($w[h +   819])=(s0[h +   819][0],s0[h +   819][1],s0[h +   819][2],s0[h +   819][3]),hideTrace($w[h +   819])=(s1[h +   819]),rgb($w[h +   820])=(s0[h +   820][0],s0[h +   820][1],s0[h +   820][2],s0[h +   820][3]),hideTrace($w[h +   820])=(s1[h +   820]),rgb($w[h +   821])=(s0[h +   821][0],s0[h +   821][1],s0[h +   821][2],s0[h +   821][3]),hideTrace($w[h +   821])=(s1[h +   821]),rgb($w[h +   822])=(s0[h +   822][0],s0[h +   822][1],s0[h +   822][2],s0[h +   822][3]),hideTrace($w[h +   822])=(s1[h +   822]),rgb($w[h +   823])=(s0[h +   823][0],s0[h +   823][1],s0[h +   823][2],s0[h +   823][3]),hideTrace($w[h +   823])=(s1[h +   823]) \
				,rgb($w[h +   824])=(s0[h +   824][0],s0[h +   824][1],s0[h +   824][2],s0[h +   824][3]),hideTrace($w[h +   824])=(s1[h +   824]),rgb($w[h +   825])=(s0[h +   825][0],s0[h +   825][1],s0[h +   825][2],s0[h +   825][3]),hideTrace($w[h +   825])=(s1[h +   825]),rgb($w[h +   826])=(s0[h +   826][0],s0[h +   826][1],s0[h +   826][2],s0[h +   826][3]),hideTrace($w[h +   826])=(s1[h +   826]),rgb($w[h +   827])=(s0[h +   827][0],s0[h +   827][1],s0[h +   827][2],s0[h +   827][3]),hideTrace($w[h +   827])=(s1[h +   827]),rgb($w[h +   828])=(s0[h +   828][0],s0[h +   828][1],s0[h +   828][2],s0[h +   828][3]),hideTrace($w[h +   828])=(s1[h +   828]),rgb($w[h +   829])=(s0[h +   829][0],s0[h +   829][1],s0[h +   829][2],s0[h +   829][3]),hideTrace($w[h +   829])=(s1[h +   829]),rgb($w[h +   830])=(s0[h +   830][0],s0[h +   830][1],s0[h +   830][2],s0[h +   830][3]),hideTrace($w[h +   830])=(s1[h +   830]),rgb($w[h +   831])=(s0[h +   831][0],s0[h +   831][1],s0[h +   831][2],s0[h +   831][3]),hideTrace($w[h +   831])=(s1[h +   831]) \
				,rgb($w[h +   832])=(s0[h +   832][0],s0[h +   832][1],s0[h +   832][2],s0[h +   832][3]),hideTrace($w[h +   832])=(s1[h +   832]),rgb($w[h +   833])=(s0[h +   833][0],s0[h +   833][1],s0[h +   833][2],s0[h +   833][3]),hideTrace($w[h +   833])=(s1[h +   833]),rgb($w[h +   834])=(s0[h +   834][0],s0[h +   834][1],s0[h +   834][2],s0[h +   834][3]),hideTrace($w[h +   834])=(s1[h +   834]),rgb($w[h +   835])=(s0[h +   835][0],s0[h +   835][1],s0[h +   835][2],s0[h +   835][3]),hideTrace($w[h +   835])=(s1[h +   835]),rgb($w[h +   836])=(s0[h +   836][0],s0[h +   836][1],s0[h +   836][2],s0[h +   836][3]),hideTrace($w[h +   836])=(s1[h +   836]),rgb($w[h +   837])=(s0[h +   837][0],s0[h +   837][1],s0[h +   837][2],s0[h +   837][3]),hideTrace($w[h +   837])=(s1[h +   837]),rgb($w[h +   838])=(s0[h +   838][0],s0[h +   838][1],s0[h +   838][2],s0[h +   838][3]),hideTrace($w[h +   838])=(s1[h +   838]),rgb($w[h +   839])=(s0[h +   839][0],s0[h +   839][1],s0[h +   839][2],s0[h +   839][3]),hideTrace($w[h +   839])=(s1[h +   839]) \
				,rgb($w[h +   840])=(s0[h +   840][0],s0[h +   840][1],s0[h +   840][2],s0[h +   840][3]),hideTrace($w[h +   840])=(s1[h +   840]),rgb($w[h +   841])=(s0[h +   841][0],s0[h +   841][1],s0[h +   841][2],s0[h +   841][3]),hideTrace($w[h +   841])=(s1[h +   841]),rgb($w[h +   842])=(s0[h +   842][0],s0[h +   842][1],s0[h +   842][2],s0[h +   842][3]),hideTrace($w[h +   842])=(s1[h +   842]),rgb($w[h +   843])=(s0[h +   843][0],s0[h +   843][1],s0[h +   843][2],s0[h +   843][3]),hideTrace($w[h +   843])=(s1[h +   843]),rgb($w[h +   844])=(s0[h +   844][0],s0[h +   844][1],s0[h +   844][2],s0[h +   844][3]),hideTrace($w[h +   844])=(s1[h +   844]),rgb($w[h +   845])=(s0[h +   845][0],s0[h +   845][1],s0[h +   845][2],s0[h +   845][3]),hideTrace($w[h +   845])=(s1[h +   845]),rgb($w[h +   846])=(s0[h +   846][0],s0[h +   846][1],s0[h +   846][2],s0[h +   846][3]),hideTrace($w[h +   846])=(s1[h +   846]),rgb($w[h +   847])=(s0[h +   847][0],s0[h +   847][1],s0[h +   847][2],s0[h +   847][3]),hideTrace($w[h +   847])=(s1[h +   847]) \
				,rgb($w[h +   848])=(s0[h +   848][0],s0[h +   848][1],s0[h +   848][2],s0[h +   848][3]),hideTrace($w[h +   848])=(s1[h +   848]),rgb($w[h +   849])=(s0[h +   849][0],s0[h +   849][1],s0[h +   849][2],s0[h +   849][3]),hideTrace($w[h +   849])=(s1[h +   849]),rgb($w[h +   850])=(s0[h +   850][0],s0[h +   850][1],s0[h +   850][2],s0[h +   850][3]),hideTrace($w[h +   850])=(s1[h +   850]),rgb($w[h +   851])=(s0[h +   851][0],s0[h +   851][1],s0[h +   851][2],s0[h +   851][3]),hideTrace($w[h +   851])=(s1[h +   851]),rgb($w[h +   852])=(s0[h +   852][0],s0[h +   852][1],s0[h +   852][2],s0[h +   852][3]),hideTrace($w[h +   852])=(s1[h +   852]),rgb($w[h +   853])=(s0[h +   853][0],s0[h +   853][1],s0[h +   853][2],s0[h +   853][3]),hideTrace($w[h +   853])=(s1[h +   853]),rgb($w[h +   854])=(s0[h +   854][0],s0[h +   854][1],s0[h +   854][2],s0[h +   854][3]),hideTrace($w[h +   854])=(s1[h +   854]),rgb($w[h +   855])=(s0[h +   855][0],s0[h +   855][1],s0[h +   855][2],s0[h +   855][3]),hideTrace($w[h +   855])=(s1[h +   855]) \
				,rgb($w[h +   856])=(s0[h +   856][0],s0[h +   856][1],s0[h +   856][2],s0[h +   856][3]),hideTrace($w[h +   856])=(s1[h +   856]),rgb($w[h +   857])=(s0[h +   857][0],s0[h +   857][1],s0[h +   857][2],s0[h +   857][3]),hideTrace($w[h +   857])=(s1[h +   857]),rgb($w[h +   858])=(s0[h +   858][0],s0[h +   858][1],s0[h +   858][2],s0[h +   858][3]),hideTrace($w[h +   858])=(s1[h +   858]),rgb($w[h +   859])=(s0[h +   859][0],s0[h +   859][1],s0[h +   859][2],s0[h +   859][3]),hideTrace($w[h +   859])=(s1[h +   859]),rgb($w[h +   860])=(s0[h +   860][0],s0[h +   860][1],s0[h +   860][2],s0[h +   860][3]),hideTrace($w[h +   860])=(s1[h +   860]),rgb($w[h +   861])=(s0[h +   861][0],s0[h +   861][1],s0[h +   861][2],s0[h +   861][3]),hideTrace($w[h +   861])=(s1[h +   861]),rgb($w[h +   862])=(s0[h +   862][0],s0[h +   862][1],s0[h +   862][2],s0[h +   862][3]),hideTrace($w[h +   862])=(s1[h +   862]),rgb($w[h +   863])=(s0[h +   863][0],s0[h +   863][1],s0[h +   863][2],s0[h +   863][3]),hideTrace($w[h +   863])=(s1[h +   863]) \
				,rgb($w[h +   864])=(s0[h +   864][0],s0[h +   864][1],s0[h +   864][2],s0[h +   864][3]),hideTrace($w[h +   864])=(s1[h +   864]),rgb($w[h +   865])=(s0[h +   865][0],s0[h +   865][1],s0[h +   865][2],s0[h +   865][3]),hideTrace($w[h +   865])=(s1[h +   865]),rgb($w[h +   866])=(s0[h +   866][0],s0[h +   866][1],s0[h +   866][2],s0[h +   866][3]),hideTrace($w[h +   866])=(s1[h +   866]),rgb($w[h +   867])=(s0[h +   867][0],s0[h +   867][1],s0[h +   867][2],s0[h +   867][3]),hideTrace($w[h +   867])=(s1[h +   867]),rgb($w[h +   868])=(s0[h +   868][0],s0[h +   868][1],s0[h +   868][2],s0[h +   868][3]),hideTrace($w[h +   868])=(s1[h +   868]),rgb($w[h +   869])=(s0[h +   869][0],s0[h +   869][1],s0[h +   869][2],s0[h +   869][3]),hideTrace($w[h +   869])=(s1[h +   869]),rgb($w[h +   870])=(s0[h +   870][0],s0[h +   870][1],s0[h +   870][2],s0[h +   870][3]),hideTrace($w[h +   870])=(s1[h +   870]),rgb($w[h +   871])=(s0[h +   871][0],s0[h +   871][1],s0[h +   871][2],s0[h +   871][3]),hideTrace($w[h +   871])=(s1[h +   871]) \
				,rgb($w[h +   872])=(s0[h +   872][0],s0[h +   872][1],s0[h +   872][2],s0[h +   872][3]),hideTrace($w[h +   872])=(s1[h +   872]),rgb($w[h +   873])=(s0[h +   873][0],s0[h +   873][1],s0[h +   873][2],s0[h +   873][3]),hideTrace($w[h +   873])=(s1[h +   873]),rgb($w[h +   874])=(s0[h +   874][0],s0[h +   874][1],s0[h +   874][2],s0[h +   874][3]),hideTrace($w[h +   874])=(s1[h +   874]),rgb($w[h +   875])=(s0[h +   875][0],s0[h +   875][1],s0[h +   875][2],s0[h +   875][3]),hideTrace($w[h +   875])=(s1[h +   875]),rgb($w[h +   876])=(s0[h +   876][0],s0[h +   876][1],s0[h +   876][2],s0[h +   876][3]),hideTrace($w[h +   876])=(s1[h +   876]),rgb($w[h +   877])=(s0[h +   877][0],s0[h +   877][1],s0[h +   877][2],s0[h +   877][3]),hideTrace($w[h +   877])=(s1[h +   877]),rgb($w[h +   878])=(s0[h +   878][0],s0[h +   878][1],s0[h +   878][2],s0[h +   878][3]),hideTrace($w[h +   878])=(s1[h +   878]),rgb($w[h +   879])=(s0[h +   879][0],s0[h +   879][1],s0[h +   879][2],s0[h +   879][3]),hideTrace($w[h +   879])=(s1[h +   879]) \
				,rgb($w[h +   880])=(s0[h +   880][0],s0[h +   880][1],s0[h +   880][2],s0[h +   880][3]),hideTrace($w[h +   880])=(s1[h +   880]),rgb($w[h +   881])=(s0[h +   881][0],s0[h +   881][1],s0[h +   881][2],s0[h +   881][3]),hideTrace($w[h +   881])=(s1[h +   881]),rgb($w[h +   882])=(s0[h +   882][0],s0[h +   882][1],s0[h +   882][2],s0[h +   882][3]),hideTrace($w[h +   882])=(s1[h +   882]),rgb($w[h +   883])=(s0[h +   883][0],s0[h +   883][1],s0[h +   883][2],s0[h +   883][3]),hideTrace($w[h +   883])=(s1[h +   883]),rgb($w[h +   884])=(s0[h +   884][0],s0[h +   884][1],s0[h +   884][2],s0[h +   884][3]),hideTrace($w[h +   884])=(s1[h +   884]),rgb($w[h +   885])=(s0[h +   885][0],s0[h +   885][1],s0[h +   885][2],s0[h +   885][3]),hideTrace($w[h +   885])=(s1[h +   885]),rgb($w[h +   886])=(s0[h +   886][0],s0[h +   886][1],s0[h +   886][2],s0[h +   886][3]),hideTrace($w[h +   886])=(s1[h +   886]),rgb($w[h +   887])=(s0[h +   887][0],s0[h +   887][1],s0[h +   887][2],s0[h +   887][3]),hideTrace($w[h +   887])=(s1[h +   887]) \
				,rgb($w[h +   888])=(s0[h +   888][0],s0[h +   888][1],s0[h +   888][2],s0[h +   888][3]),hideTrace($w[h +   888])=(s1[h +   888]),rgb($w[h +   889])=(s0[h +   889][0],s0[h +   889][1],s0[h +   889][2],s0[h +   889][3]),hideTrace($w[h +   889])=(s1[h +   889]),rgb($w[h +   890])=(s0[h +   890][0],s0[h +   890][1],s0[h +   890][2],s0[h +   890][3]),hideTrace($w[h +   890])=(s1[h +   890]),rgb($w[h +   891])=(s0[h +   891][0],s0[h +   891][1],s0[h +   891][2],s0[h +   891][3]),hideTrace($w[h +   891])=(s1[h +   891]),rgb($w[h +   892])=(s0[h +   892][0],s0[h +   892][1],s0[h +   892][2],s0[h +   892][3]),hideTrace($w[h +   892])=(s1[h +   892]),rgb($w[h +   893])=(s0[h +   893][0],s0[h +   893][1],s0[h +   893][2],s0[h +   893][3]),hideTrace($w[h +   893])=(s1[h +   893]),rgb($w[h +   894])=(s0[h +   894][0],s0[h +   894][1],s0[h +   894][2],s0[h +   894][3]),hideTrace($w[h +   894])=(s1[h +   894]),rgb($w[h +   895])=(s0[h +   895][0],s0[h +   895][1],s0[h +   895][2],s0[h +   895][3]),hideTrace($w[h +   895])=(s1[h +   895]) \
				,rgb($w[h +   896])=(s0[h +   896][0],s0[h +   896][1],s0[h +   896][2],s0[h +   896][3]),hideTrace($w[h +   896])=(s1[h +   896]),rgb($w[h +   897])=(s0[h +   897][0],s0[h +   897][1],s0[h +   897][2],s0[h +   897][3]),hideTrace($w[h +   897])=(s1[h +   897]),rgb($w[h +   898])=(s0[h +   898][0],s0[h +   898][1],s0[h +   898][2],s0[h +   898][3]),hideTrace($w[h +   898])=(s1[h +   898]),rgb($w[h +   899])=(s0[h +   899][0],s0[h +   899][1],s0[h +   899][2],s0[h +   899][3]),hideTrace($w[h +   899])=(s1[h +   899]),rgb($w[h +   900])=(s0[h +   900][0],s0[h +   900][1],s0[h +   900][2],s0[h +   900][3]),hideTrace($w[h +   900])=(s1[h +   900]),rgb($w[h +   901])=(s0[h +   901][0],s0[h +   901][1],s0[h +   901][2],s0[h +   901][3]),hideTrace($w[h +   901])=(s1[h +   901]),rgb($w[h +   902])=(s0[h +   902][0],s0[h +   902][1],s0[h +   902][2],s0[h +   902][3]),hideTrace($w[h +   902])=(s1[h +   902]),rgb($w[h +   903])=(s0[h +   903][0],s0[h +   903][1],s0[h +   903][2],s0[h +   903][3]),hideTrace($w[h +   903])=(s1[h +   903]) \
				,rgb($w[h +   904])=(s0[h +   904][0],s0[h +   904][1],s0[h +   904][2],s0[h +   904][3]),hideTrace($w[h +   904])=(s1[h +   904]),rgb($w[h +   905])=(s0[h +   905][0],s0[h +   905][1],s0[h +   905][2],s0[h +   905][3]),hideTrace($w[h +   905])=(s1[h +   905]),rgb($w[h +   906])=(s0[h +   906][0],s0[h +   906][1],s0[h +   906][2],s0[h +   906][3]),hideTrace($w[h +   906])=(s1[h +   906]),rgb($w[h +   907])=(s0[h +   907][0],s0[h +   907][1],s0[h +   907][2],s0[h +   907][3]),hideTrace($w[h +   907])=(s1[h +   907]),rgb($w[h +   908])=(s0[h +   908][0],s0[h +   908][1],s0[h +   908][2],s0[h +   908][3]),hideTrace($w[h +   908])=(s1[h +   908]),rgb($w[h +   909])=(s0[h +   909][0],s0[h +   909][1],s0[h +   909][2],s0[h +   909][3]),hideTrace($w[h +   909])=(s1[h +   909]),rgb($w[h +   910])=(s0[h +   910][0],s0[h +   910][1],s0[h +   910][2],s0[h +   910][3]),hideTrace($w[h +   910])=(s1[h +   910]),rgb($w[h +   911])=(s0[h +   911][0],s0[h +   911][1],s0[h +   911][2],s0[h +   911][3]),hideTrace($w[h +   911])=(s1[h +   911]) \
				,rgb($w[h +   912])=(s0[h +   912][0],s0[h +   912][1],s0[h +   912][2],s0[h +   912][3]),hideTrace($w[h +   912])=(s1[h +   912]),rgb($w[h +   913])=(s0[h +   913][0],s0[h +   913][1],s0[h +   913][2],s0[h +   913][3]),hideTrace($w[h +   913])=(s1[h +   913]),rgb($w[h +   914])=(s0[h +   914][0],s0[h +   914][1],s0[h +   914][2],s0[h +   914][3]),hideTrace($w[h +   914])=(s1[h +   914]),rgb($w[h +   915])=(s0[h +   915][0],s0[h +   915][1],s0[h +   915][2],s0[h +   915][3]),hideTrace($w[h +   915])=(s1[h +   915]),rgb($w[h +   916])=(s0[h +   916][0],s0[h +   916][1],s0[h +   916][2],s0[h +   916][3]),hideTrace($w[h +   916])=(s1[h +   916]),rgb($w[h +   917])=(s0[h +   917][0],s0[h +   917][1],s0[h +   917][2],s0[h +   917][3]),hideTrace($w[h +   917])=(s1[h +   917]),rgb($w[h +   918])=(s0[h +   918][0],s0[h +   918][1],s0[h +   918][2],s0[h +   918][3]),hideTrace($w[h +   918])=(s1[h +   918]),rgb($w[h +   919])=(s0[h +   919][0],s0[h +   919][1],s0[h +   919][2],s0[h +   919][3]),hideTrace($w[h +   919])=(s1[h +   919]) \
				,rgb($w[h +   920])=(s0[h +   920][0],s0[h +   920][1],s0[h +   920][2],s0[h +   920][3]),hideTrace($w[h +   920])=(s1[h +   920]),rgb($w[h +   921])=(s0[h +   921][0],s0[h +   921][1],s0[h +   921][2],s0[h +   921][3]),hideTrace($w[h +   921])=(s1[h +   921]),rgb($w[h +   922])=(s0[h +   922][0],s0[h +   922][1],s0[h +   922][2],s0[h +   922][3]),hideTrace($w[h +   922])=(s1[h +   922]),rgb($w[h +   923])=(s0[h +   923][0],s0[h +   923][1],s0[h +   923][2],s0[h +   923][3]),hideTrace($w[h +   923])=(s1[h +   923]),rgb($w[h +   924])=(s0[h +   924][0],s0[h +   924][1],s0[h +   924][2],s0[h +   924][3]),hideTrace($w[h +   924])=(s1[h +   924]),rgb($w[h +   925])=(s0[h +   925][0],s0[h +   925][1],s0[h +   925][2],s0[h +   925][3]),hideTrace($w[h +   925])=(s1[h +   925]),rgb($w[h +   926])=(s0[h +   926][0],s0[h +   926][1],s0[h +   926][2],s0[h +   926][3]),hideTrace($w[h +   926])=(s1[h +   926]),rgb($w[h +   927])=(s0[h +   927][0],s0[h +   927][1],s0[h +   927][2],s0[h +   927][3]),hideTrace($w[h +   927])=(s1[h +   927]) \
				,rgb($w[h +   928])=(s0[h +   928][0],s0[h +   928][1],s0[h +   928][2],s0[h +   928][3]),hideTrace($w[h +   928])=(s1[h +   928]),rgb($w[h +   929])=(s0[h +   929][0],s0[h +   929][1],s0[h +   929][2],s0[h +   929][3]),hideTrace($w[h +   929])=(s1[h +   929]),rgb($w[h +   930])=(s0[h +   930][0],s0[h +   930][1],s0[h +   930][2],s0[h +   930][3]),hideTrace($w[h +   930])=(s1[h +   930]),rgb($w[h +   931])=(s0[h +   931][0],s0[h +   931][1],s0[h +   931][2],s0[h +   931][3]),hideTrace($w[h +   931])=(s1[h +   931]),rgb($w[h +   932])=(s0[h +   932][0],s0[h +   932][1],s0[h +   932][2],s0[h +   932][3]),hideTrace($w[h +   932])=(s1[h +   932]),rgb($w[h +   933])=(s0[h +   933][0],s0[h +   933][1],s0[h +   933][2],s0[h +   933][3]),hideTrace($w[h +   933])=(s1[h +   933]),rgb($w[h +   934])=(s0[h +   934][0],s0[h +   934][1],s0[h +   934][2],s0[h +   934][3]),hideTrace($w[h +   934])=(s1[h +   934]),rgb($w[h +   935])=(s0[h +   935][0],s0[h +   935][1],s0[h +   935][2],s0[h +   935][3]),hideTrace($w[h +   935])=(s1[h +   935]) \
				,rgb($w[h +   936])=(s0[h +   936][0],s0[h +   936][1],s0[h +   936][2],s0[h +   936][3]),hideTrace($w[h +   936])=(s1[h +   936]),rgb($w[h +   937])=(s0[h +   937][0],s0[h +   937][1],s0[h +   937][2],s0[h +   937][3]),hideTrace($w[h +   937])=(s1[h +   937]),rgb($w[h +   938])=(s0[h +   938][0],s0[h +   938][1],s0[h +   938][2],s0[h +   938][3]),hideTrace($w[h +   938])=(s1[h +   938]),rgb($w[h +   939])=(s0[h +   939][0],s0[h +   939][1],s0[h +   939][2],s0[h +   939][3]),hideTrace($w[h +   939])=(s1[h +   939]),rgb($w[h +   940])=(s0[h +   940][0],s0[h +   940][1],s0[h +   940][2],s0[h +   940][3]),hideTrace($w[h +   940])=(s1[h +   940]),rgb($w[h +   941])=(s0[h +   941][0],s0[h +   941][1],s0[h +   941][2],s0[h +   941][3]),hideTrace($w[h +   941])=(s1[h +   941]),rgb($w[h +   942])=(s0[h +   942][0],s0[h +   942][1],s0[h +   942][2],s0[h +   942][3]),hideTrace($w[h +   942])=(s1[h +   942]),rgb($w[h +   943])=(s0[h +   943][0],s0[h +   943][1],s0[h +   943][2],s0[h +   943][3]),hideTrace($w[h +   943])=(s1[h +   943]) \
				,rgb($w[h +   944])=(s0[h +   944][0],s0[h +   944][1],s0[h +   944][2],s0[h +   944][3]),hideTrace($w[h +   944])=(s1[h +   944]),rgb($w[h +   945])=(s0[h +   945][0],s0[h +   945][1],s0[h +   945][2],s0[h +   945][3]),hideTrace($w[h +   945])=(s1[h +   945]),rgb($w[h +   946])=(s0[h +   946][0],s0[h +   946][1],s0[h +   946][2],s0[h +   946][3]),hideTrace($w[h +   946])=(s1[h +   946]),rgb($w[h +   947])=(s0[h +   947][0],s0[h +   947][1],s0[h +   947][2],s0[h +   947][3]),hideTrace($w[h +   947])=(s1[h +   947]),rgb($w[h +   948])=(s0[h +   948][0],s0[h +   948][1],s0[h +   948][2],s0[h +   948][3]),hideTrace($w[h +   948])=(s1[h +   948]),rgb($w[h +   949])=(s0[h +   949][0],s0[h +   949][1],s0[h +   949][2],s0[h +   949][3]),hideTrace($w[h +   949])=(s1[h +   949]),rgb($w[h +   950])=(s0[h +   950][0],s0[h +   950][1],s0[h +   950][2],s0[h +   950][3]),hideTrace($w[h +   950])=(s1[h +   950]),rgb($w[h +   951])=(s0[h +   951][0],s0[h +   951][1],s0[h +   951][2],s0[h +   951][3]),hideTrace($w[h +   951])=(s1[h +   951]) \
				,rgb($w[h +   952])=(s0[h +   952][0],s0[h +   952][1],s0[h +   952][2],s0[h +   952][3]),hideTrace($w[h +   952])=(s1[h +   952]),rgb($w[h +   953])=(s0[h +   953][0],s0[h +   953][1],s0[h +   953][2],s0[h +   953][3]),hideTrace($w[h +   953])=(s1[h +   953]),rgb($w[h +   954])=(s0[h +   954][0],s0[h +   954][1],s0[h +   954][2],s0[h +   954][3]),hideTrace($w[h +   954])=(s1[h +   954]),rgb($w[h +   955])=(s0[h +   955][0],s0[h +   955][1],s0[h +   955][2],s0[h +   955][3]),hideTrace($w[h +   955])=(s1[h +   955]),rgb($w[h +   956])=(s0[h +   956][0],s0[h +   956][1],s0[h +   956][2],s0[h +   956][3]),hideTrace($w[h +   956])=(s1[h +   956]),rgb($w[h +   957])=(s0[h +   957][0],s0[h +   957][1],s0[h +   957][2],s0[h +   957][3]),hideTrace($w[h +   957])=(s1[h +   957]),rgb($w[h +   958])=(s0[h +   958][0],s0[h +   958][1],s0[h +   958][2],s0[h +   958][3]),hideTrace($w[h +   958])=(s1[h +   958]),rgb($w[h +   959])=(s0[h +   959][0],s0[h +   959][1],s0[h +   959][2],s0[h +   959][3]),hideTrace($w[h +   959])=(s1[h +   959]) \
				,rgb($w[h +   960])=(s0[h +   960][0],s0[h +   960][1],s0[h +   960][2],s0[h +   960][3]),hideTrace($w[h +   960])=(s1[h +   960]),rgb($w[h +   961])=(s0[h +   961][0],s0[h +   961][1],s0[h +   961][2],s0[h +   961][3]),hideTrace($w[h +   961])=(s1[h +   961]),rgb($w[h +   962])=(s0[h +   962][0],s0[h +   962][1],s0[h +   962][2],s0[h +   962][3]),hideTrace($w[h +   962])=(s1[h +   962]),rgb($w[h +   963])=(s0[h +   963][0],s0[h +   963][1],s0[h +   963][2],s0[h +   963][3]),hideTrace($w[h +   963])=(s1[h +   963]),rgb($w[h +   964])=(s0[h +   964][0],s0[h +   964][1],s0[h +   964][2],s0[h +   964][3]),hideTrace($w[h +   964])=(s1[h +   964]),rgb($w[h +   965])=(s0[h +   965][0],s0[h +   965][1],s0[h +   965][2],s0[h +   965][3]),hideTrace($w[h +   965])=(s1[h +   965]),rgb($w[h +   966])=(s0[h +   966][0],s0[h +   966][1],s0[h +   966][2],s0[h +   966][3]),hideTrace($w[h +   966])=(s1[h +   966]),rgb($w[h +   967])=(s0[h +   967][0],s0[h +   967][1],s0[h +   967][2],s0[h +   967][3]),hideTrace($w[h +   967])=(s1[h +   967]) \
				,rgb($w[h +   968])=(s0[h +   968][0],s0[h +   968][1],s0[h +   968][2],s0[h +   968][3]),hideTrace($w[h +   968])=(s1[h +   968]),rgb($w[h +   969])=(s0[h +   969][0],s0[h +   969][1],s0[h +   969][2],s0[h +   969][3]),hideTrace($w[h +   969])=(s1[h +   969]),rgb($w[h +   970])=(s0[h +   970][0],s0[h +   970][1],s0[h +   970][2],s0[h +   970][3]),hideTrace($w[h +   970])=(s1[h +   970]),rgb($w[h +   971])=(s0[h +   971][0],s0[h +   971][1],s0[h +   971][2],s0[h +   971][3]),hideTrace($w[h +   971])=(s1[h +   971]),rgb($w[h +   972])=(s0[h +   972][0],s0[h +   972][1],s0[h +   972][2],s0[h +   972][3]),hideTrace($w[h +   972])=(s1[h +   972]),rgb($w[h +   973])=(s0[h +   973][0],s0[h +   973][1],s0[h +   973][2],s0[h +   973][3]),hideTrace($w[h +   973])=(s1[h +   973]),rgb($w[h +   974])=(s0[h +   974][0],s0[h +   974][1],s0[h +   974][2],s0[h +   974][3]),hideTrace($w[h +   974])=(s1[h +   974]),rgb($w[h +   975])=(s0[h +   975][0],s0[h +   975][1],s0[h +   975][2],s0[h +   975][3]),hideTrace($w[h +   975])=(s1[h +   975]) \
				,rgb($w[h +   976])=(s0[h +   976][0],s0[h +   976][1],s0[h +   976][2],s0[h +   976][3]),hideTrace($w[h +   976])=(s1[h +   976]),rgb($w[h +   977])=(s0[h +   977][0],s0[h +   977][1],s0[h +   977][2],s0[h +   977][3]),hideTrace($w[h +   977])=(s1[h +   977]),rgb($w[h +   978])=(s0[h +   978][0],s0[h +   978][1],s0[h +   978][2],s0[h +   978][3]),hideTrace($w[h +   978])=(s1[h +   978]),rgb($w[h +   979])=(s0[h +   979][0],s0[h +   979][1],s0[h +   979][2],s0[h +   979][3]),hideTrace($w[h +   979])=(s1[h +   979]),rgb($w[h +   980])=(s0[h +   980][0],s0[h +   980][1],s0[h +   980][2],s0[h +   980][3]),hideTrace($w[h +   980])=(s1[h +   980]),rgb($w[h +   981])=(s0[h +   981][0],s0[h +   981][1],s0[h +   981][2],s0[h +   981][3]),hideTrace($w[h +   981])=(s1[h +   981]),rgb($w[h +   982])=(s0[h +   982][0],s0[h +   982][1],s0[h +   982][2],s0[h +   982][3]),hideTrace($w[h +   982])=(s1[h +   982]),rgb($w[h +   983])=(s0[h +   983][0],s0[h +   983][1],s0[h +   983][2],s0[h +   983][3]),hideTrace($w[h +   983])=(s1[h +   983]) \
				,rgb($w[h +   984])=(s0[h +   984][0],s0[h +   984][1],s0[h +   984][2],s0[h +   984][3]),hideTrace($w[h +   984])=(s1[h +   984]),rgb($w[h +   985])=(s0[h +   985][0],s0[h +   985][1],s0[h +   985][2],s0[h +   985][3]),hideTrace($w[h +   985])=(s1[h +   985]),rgb($w[h +   986])=(s0[h +   986][0],s0[h +   986][1],s0[h +   986][2],s0[h +   986][3]),hideTrace($w[h +   986])=(s1[h +   986]),rgb($w[h +   987])=(s0[h +   987][0],s0[h +   987][1],s0[h +   987][2],s0[h +   987][3]),hideTrace($w[h +   987])=(s1[h +   987]),rgb($w[h +   988])=(s0[h +   988][0],s0[h +   988][1],s0[h +   988][2],s0[h +   988][3]),hideTrace($w[h +   988])=(s1[h +   988]),rgb($w[h +   989])=(s0[h +   989][0],s0[h +   989][1],s0[h +   989][2],s0[h +   989][3]),hideTrace($w[h +   989])=(s1[h +   989]),rgb($w[h +   990])=(s0[h +   990][0],s0[h +   990][1],s0[h +   990][2],s0[h +   990][3]),hideTrace($w[h +   990])=(s1[h +   990]),rgb($w[h +   991])=(s0[h +   991][0],s0[h +   991][1],s0[h +   991][2],s0[h +   991][3]),hideTrace($w[h +   991])=(s1[h +   991]) \
				,rgb($w[h +   992])=(s0[h +   992][0],s0[h +   992][1],s0[h +   992][2],s0[h +   992][3]),hideTrace($w[h +   992])=(s1[h +   992]),rgb($w[h +   993])=(s0[h +   993][0],s0[h +   993][1],s0[h +   993][2],s0[h +   993][3]),hideTrace($w[h +   993])=(s1[h +   993]),rgb($w[h +   994])=(s0[h +   994][0],s0[h +   994][1],s0[h +   994][2],s0[h +   994][3]),hideTrace($w[h +   994])=(s1[h +   994]),rgb($w[h +   995])=(s0[h +   995][0],s0[h +   995][1],s0[h +   995][2],s0[h +   995][3]),hideTrace($w[h +   995])=(s1[h +   995]),rgb($w[h +   996])=(s0[h +   996][0],s0[h +   996][1],s0[h +   996][2],s0[h +   996][3]),hideTrace($w[h +   996])=(s1[h +   996]),rgb($w[h +   997])=(s0[h +   997][0],s0[h +   997][1],s0[h +   997][2],s0[h +   997][3]),hideTrace($w[h +   997])=(s1[h +   997]),rgb($w[h +   998])=(s0[h +   998][0],s0[h +   998][1],s0[h +   998][2],s0[h +   998][3]),hideTrace($w[h +   998])=(s1[h +   998]),rgb($w[h +   999])=(s0[h +   999][0],s0[h +   999][1],s0[h +   999][2],s0[h +   999][3]),hideTrace($w[h +   999])=(s1[h +   999]) \
				,rgb($w[h +  1000])=(s0[h +  1000][0],s0[h +  1000][1],s0[h +  1000][2],s0[h +  1000][3]),hideTrace($w[h +  1000])=(s1[h +  1000]),rgb($w[h +  1001])=(s0[h +  1001][0],s0[h +  1001][1],s0[h +  1001][2],s0[h +  1001][3]),hideTrace($w[h +  1001])=(s1[h +  1001]),rgb($w[h +  1002])=(s0[h +  1002][0],s0[h +  1002][1],s0[h +  1002][2],s0[h +  1002][3]),hideTrace($w[h +  1002])=(s1[h +  1002]),rgb($w[h +  1003])=(s0[h +  1003][0],s0[h +  1003][1],s0[h +  1003][2],s0[h +  1003][3]),hideTrace($w[h +  1003])=(s1[h +  1003]),rgb($w[h +  1004])=(s0[h +  1004][0],s0[h +  1004][1],s0[h +  1004][2],s0[h +  1004][3]),hideTrace($w[h +  1004])=(s1[h +  1004]),rgb($w[h +  1005])=(s0[h +  1005][0],s0[h +  1005][1],s0[h +  1005][2],s0[h +  1005][3]),hideTrace($w[h +  1005])=(s1[h +  1005]),rgb($w[h +  1006])=(s0[h +  1006][0],s0[h +  1006][1],s0[h +  1006][2],s0[h +  1006][3]),hideTrace($w[h +  1006])=(s1[h +  1006]),rgb($w[h +  1007])=(s0[h +  1007][0],s0[h +  1007][1],s0[h +  1007][2],s0[h +  1007][3]),hideTrace($w[h +  1007])=(s1[h +  1007]) \
				,rgb($w[h +  1008])=(s0[h +  1008][0],s0[h +  1008][1],s0[h +  1008][2],s0[h +  1008][3]),hideTrace($w[h +  1008])=(s1[h +  1008]),rgb($w[h +  1009])=(s0[h +  1009][0],s0[h +  1009][1],s0[h +  1009][2],s0[h +  1009][3]),hideTrace($w[h +  1009])=(s1[h +  1009]),rgb($w[h +  1010])=(s0[h +  1010][0],s0[h +  1010][1],s0[h +  1010][2],s0[h +  1010][3]),hideTrace($w[h +  1010])=(s1[h +  1010]),rgb($w[h +  1011])=(s0[h +  1011][0],s0[h +  1011][1],s0[h +  1011][2],s0[h +  1011][3]),hideTrace($w[h +  1011])=(s1[h +  1011]),rgb($w[h +  1012])=(s0[h +  1012][0],s0[h +  1012][1],s0[h +  1012][2],s0[h +  1012][3]),hideTrace($w[h +  1012])=(s1[h +  1012]),rgb($w[h +  1013])=(s0[h +  1013][0],s0[h +  1013][1],s0[h +  1013][2],s0[h +  1013][3]),hideTrace($w[h +  1013])=(s1[h +  1013]),rgb($w[h +  1014])=(s0[h +  1014][0],s0[h +  1014][1],s0[h +  1014][2],s0[h +  1014][3]),hideTrace($w[h +  1014])=(s1[h +  1014]),rgb($w[h +  1015])=(s0[h +  1015][0],s0[h +  1015][1],s0[h +  1015][2],s0[h +  1015][3]),hideTrace($w[h +  1015])=(s1[h +  1015]) \
				,rgb($w[h +  1016])=(s0[h +  1016][0],s0[h +  1016][1],s0[h +  1016][2],s0[h +  1016][3]),hideTrace($w[h +  1016])=(s1[h +  1016]),rgb($w[h +  1017])=(s0[h +  1017][0],s0[h +  1017][1],s0[h +  1017][2],s0[h +  1017][3]),hideTrace($w[h +  1017])=(s1[h +  1017]),rgb($w[h +  1018])=(s0[h +  1018][0],s0[h +  1018][1],s0[h +  1018][2],s0[h +  1018][3]),hideTrace($w[h +  1018])=(s1[h +  1018]),rgb($w[h +  1019])=(s0[h +  1019][0],s0[h +  1019][1],s0[h +  1019][2],s0[h +  1019][3]),hideTrace($w[h +  1019])=(s1[h +  1019]),rgb($w[h +  1020])=(s0[h +  1020][0],s0[h +  1020][1],s0[h +  1020][2],s0[h +  1020][3]),hideTrace($w[h +  1020])=(s1[h +  1020]),rgb($w[h +  1021])=(s0[h +  1021][0],s0[h +  1021][1],s0[h +  1021][2],s0[h +  1021][3]),hideTrace($w[h +  1021])=(s1[h +  1021]),rgb($w[h +  1022])=(s0[h +  1022][0],s0[h +  1022][1],s0[h +  1022][2],s0[h +  1022][3]),hideTrace($w[h +  1022])=(s1[h +  1022]),rgb($w[h +  1023])=(s0[h +  1023][0],s0[h +  1023][1],s0[h +  1023][2],s0[h +  1023][3]),hideTrace($w[h +  1023])=(s1[h +  1023])
				break
			case 512:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31]) \
				,rgb($w[h +    32])=(s0[h +    32][0],s0[h +    32][1],s0[h +    32][2],s0[h +    32][3]),hideTrace($w[h +    32])=(s1[h +    32]),rgb($w[h +    33])=(s0[h +    33][0],s0[h +    33][1],s0[h +    33][2],s0[h +    33][3]),hideTrace($w[h +    33])=(s1[h +    33]),rgb($w[h +    34])=(s0[h +    34][0],s0[h +    34][1],s0[h +    34][2],s0[h +    34][3]),hideTrace($w[h +    34])=(s1[h +    34]),rgb($w[h +    35])=(s0[h +    35][0],s0[h +    35][1],s0[h +    35][2],s0[h +    35][3]),hideTrace($w[h +    35])=(s1[h +    35]),rgb($w[h +    36])=(s0[h +    36][0],s0[h +    36][1],s0[h +    36][2],s0[h +    36][3]),hideTrace($w[h +    36])=(s1[h +    36]),rgb($w[h +    37])=(s0[h +    37][0],s0[h +    37][1],s0[h +    37][2],s0[h +    37][3]),hideTrace($w[h +    37])=(s1[h +    37]),rgb($w[h +    38])=(s0[h +    38][0],s0[h +    38][1],s0[h +    38][2],s0[h +    38][3]),hideTrace($w[h +    38])=(s1[h +    38]),rgb($w[h +    39])=(s0[h +    39][0],s0[h +    39][1],s0[h +    39][2],s0[h +    39][3]),hideTrace($w[h +    39])=(s1[h +    39]) \
				,rgb($w[h +    40])=(s0[h +    40][0],s0[h +    40][1],s0[h +    40][2],s0[h +    40][3]),hideTrace($w[h +    40])=(s1[h +    40]),rgb($w[h +    41])=(s0[h +    41][0],s0[h +    41][1],s0[h +    41][2],s0[h +    41][3]),hideTrace($w[h +    41])=(s1[h +    41]),rgb($w[h +    42])=(s0[h +    42][0],s0[h +    42][1],s0[h +    42][2],s0[h +    42][3]),hideTrace($w[h +    42])=(s1[h +    42]),rgb($w[h +    43])=(s0[h +    43][0],s0[h +    43][1],s0[h +    43][2],s0[h +    43][3]),hideTrace($w[h +    43])=(s1[h +    43]),rgb($w[h +    44])=(s0[h +    44][0],s0[h +    44][1],s0[h +    44][2],s0[h +    44][3]),hideTrace($w[h +    44])=(s1[h +    44]),rgb($w[h +    45])=(s0[h +    45][0],s0[h +    45][1],s0[h +    45][2],s0[h +    45][3]),hideTrace($w[h +    45])=(s1[h +    45]),rgb($w[h +    46])=(s0[h +    46][0],s0[h +    46][1],s0[h +    46][2],s0[h +    46][3]),hideTrace($w[h +    46])=(s1[h +    46]),rgb($w[h +    47])=(s0[h +    47][0],s0[h +    47][1],s0[h +    47][2],s0[h +    47][3]),hideTrace($w[h +    47])=(s1[h +    47]) \
				,rgb($w[h +    48])=(s0[h +    48][0],s0[h +    48][1],s0[h +    48][2],s0[h +    48][3]),hideTrace($w[h +    48])=(s1[h +    48]),rgb($w[h +    49])=(s0[h +    49][0],s0[h +    49][1],s0[h +    49][2],s0[h +    49][3]),hideTrace($w[h +    49])=(s1[h +    49]),rgb($w[h +    50])=(s0[h +    50][0],s0[h +    50][1],s0[h +    50][2],s0[h +    50][3]),hideTrace($w[h +    50])=(s1[h +    50]),rgb($w[h +    51])=(s0[h +    51][0],s0[h +    51][1],s0[h +    51][2],s0[h +    51][3]),hideTrace($w[h +    51])=(s1[h +    51]),rgb($w[h +    52])=(s0[h +    52][0],s0[h +    52][1],s0[h +    52][2],s0[h +    52][3]),hideTrace($w[h +    52])=(s1[h +    52]),rgb($w[h +    53])=(s0[h +    53][0],s0[h +    53][1],s0[h +    53][2],s0[h +    53][3]),hideTrace($w[h +    53])=(s1[h +    53]),rgb($w[h +    54])=(s0[h +    54][0],s0[h +    54][1],s0[h +    54][2],s0[h +    54][3]),hideTrace($w[h +    54])=(s1[h +    54]),rgb($w[h +    55])=(s0[h +    55][0],s0[h +    55][1],s0[h +    55][2],s0[h +    55][3]),hideTrace($w[h +    55])=(s1[h +    55]) \
				,rgb($w[h +    56])=(s0[h +    56][0],s0[h +    56][1],s0[h +    56][2],s0[h +    56][3]),hideTrace($w[h +    56])=(s1[h +    56]),rgb($w[h +    57])=(s0[h +    57][0],s0[h +    57][1],s0[h +    57][2],s0[h +    57][3]),hideTrace($w[h +    57])=(s1[h +    57]),rgb($w[h +    58])=(s0[h +    58][0],s0[h +    58][1],s0[h +    58][2],s0[h +    58][3]),hideTrace($w[h +    58])=(s1[h +    58]),rgb($w[h +    59])=(s0[h +    59][0],s0[h +    59][1],s0[h +    59][2],s0[h +    59][3]),hideTrace($w[h +    59])=(s1[h +    59]),rgb($w[h +    60])=(s0[h +    60][0],s0[h +    60][1],s0[h +    60][2],s0[h +    60][3]),hideTrace($w[h +    60])=(s1[h +    60]),rgb($w[h +    61])=(s0[h +    61][0],s0[h +    61][1],s0[h +    61][2],s0[h +    61][3]),hideTrace($w[h +    61])=(s1[h +    61]),rgb($w[h +    62])=(s0[h +    62][0],s0[h +    62][1],s0[h +    62][2],s0[h +    62][3]),hideTrace($w[h +    62])=(s1[h +    62]),rgb($w[h +    63])=(s0[h +    63][0],s0[h +    63][1],s0[h +    63][2],s0[h +    63][3]),hideTrace($w[h +    63])=(s1[h +    63]) \
				,rgb($w[h +    64])=(s0[h +    64][0],s0[h +    64][1],s0[h +    64][2],s0[h +    64][3]),hideTrace($w[h +    64])=(s1[h +    64]),rgb($w[h +    65])=(s0[h +    65][0],s0[h +    65][1],s0[h +    65][2],s0[h +    65][3]),hideTrace($w[h +    65])=(s1[h +    65]),rgb($w[h +    66])=(s0[h +    66][0],s0[h +    66][1],s0[h +    66][2],s0[h +    66][3]),hideTrace($w[h +    66])=(s1[h +    66]),rgb($w[h +    67])=(s0[h +    67][0],s0[h +    67][1],s0[h +    67][2],s0[h +    67][3]),hideTrace($w[h +    67])=(s1[h +    67]),rgb($w[h +    68])=(s0[h +    68][0],s0[h +    68][1],s0[h +    68][2],s0[h +    68][3]),hideTrace($w[h +    68])=(s1[h +    68]),rgb($w[h +    69])=(s0[h +    69][0],s0[h +    69][1],s0[h +    69][2],s0[h +    69][3]),hideTrace($w[h +    69])=(s1[h +    69]),rgb($w[h +    70])=(s0[h +    70][0],s0[h +    70][1],s0[h +    70][2],s0[h +    70][3]),hideTrace($w[h +    70])=(s1[h +    70]),rgb($w[h +    71])=(s0[h +    71][0],s0[h +    71][1],s0[h +    71][2],s0[h +    71][3]),hideTrace($w[h +    71])=(s1[h +    71]) \
				,rgb($w[h +    72])=(s0[h +    72][0],s0[h +    72][1],s0[h +    72][2],s0[h +    72][3]),hideTrace($w[h +    72])=(s1[h +    72]),rgb($w[h +    73])=(s0[h +    73][0],s0[h +    73][1],s0[h +    73][2],s0[h +    73][3]),hideTrace($w[h +    73])=(s1[h +    73]),rgb($w[h +    74])=(s0[h +    74][0],s0[h +    74][1],s0[h +    74][2],s0[h +    74][3]),hideTrace($w[h +    74])=(s1[h +    74]),rgb($w[h +    75])=(s0[h +    75][0],s0[h +    75][1],s0[h +    75][2],s0[h +    75][3]),hideTrace($w[h +    75])=(s1[h +    75]),rgb($w[h +    76])=(s0[h +    76][0],s0[h +    76][1],s0[h +    76][2],s0[h +    76][3]),hideTrace($w[h +    76])=(s1[h +    76]),rgb($w[h +    77])=(s0[h +    77][0],s0[h +    77][1],s0[h +    77][2],s0[h +    77][3]),hideTrace($w[h +    77])=(s1[h +    77]),rgb($w[h +    78])=(s0[h +    78][0],s0[h +    78][1],s0[h +    78][2],s0[h +    78][3]),hideTrace($w[h +    78])=(s1[h +    78]),rgb($w[h +    79])=(s0[h +    79][0],s0[h +    79][1],s0[h +    79][2],s0[h +    79][3]),hideTrace($w[h +    79])=(s1[h +    79]) \
				,rgb($w[h +    80])=(s0[h +    80][0],s0[h +    80][1],s0[h +    80][2],s0[h +    80][3]),hideTrace($w[h +    80])=(s1[h +    80]),rgb($w[h +    81])=(s0[h +    81][0],s0[h +    81][1],s0[h +    81][2],s0[h +    81][3]),hideTrace($w[h +    81])=(s1[h +    81]),rgb($w[h +    82])=(s0[h +    82][0],s0[h +    82][1],s0[h +    82][2],s0[h +    82][3]),hideTrace($w[h +    82])=(s1[h +    82]),rgb($w[h +    83])=(s0[h +    83][0],s0[h +    83][1],s0[h +    83][2],s0[h +    83][3]),hideTrace($w[h +    83])=(s1[h +    83]),rgb($w[h +    84])=(s0[h +    84][0],s0[h +    84][1],s0[h +    84][2],s0[h +    84][3]),hideTrace($w[h +    84])=(s1[h +    84]),rgb($w[h +    85])=(s0[h +    85][0],s0[h +    85][1],s0[h +    85][2],s0[h +    85][3]),hideTrace($w[h +    85])=(s1[h +    85]),rgb($w[h +    86])=(s0[h +    86][0],s0[h +    86][1],s0[h +    86][2],s0[h +    86][3]),hideTrace($w[h +    86])=(s1[h +    86]),rgb($w[h +    87])=(s0[h +    87][0],s0[h +    87][1],s0[h +    87][2],s0[h +    87][3]),hideTrace($w[h +    87])=(s1[h +    87]) \
				,rgb($w[h +    88])=(s0[h +    88][0],s0[h +    88][1],s0[h +    88][2],s0[h +    88][3]),hideTrace($w[h +    88])=(s1[h +    88]),rgb($w[h +    89])=(s0[h +    89][0],s0[h +    89][1],s0[h +    89][2],s0[h +    89][3]),hideTrace($w[h +    89])=(s1[h +    89]),rgb($w[h +    90])=(s0[h +    90][0],s0[h +    90][1],s0[h +    90][2],s0[h +    90][3]),hideTrace($w[h +    90])=(s1[h +    90]),rgb($w[h +    91])=(s0[h +    91][0],s0[h +    91][1],s0[h +    91][2],s0[h +    91][3]),hideTrace($w[h +    91])=(s1[h +    91]),rgb($w[h +    92])=(s0[h +    92][0],s0[h +    92][1],s0[h +    92][2],s0[h +    92][3]),hideTrace($w[h +    92])=(s1[h +    92]),rgb($w[h +    93])=(s0[h +    93][0],s0[h +    93][1],s0[h +    93][2],s0[h +    93][3]),hideTrace($w[h +    93])=(s1[h +    93]),rgb($w[h +    94])=(s0[h +    94][0],s0[h +    94][1],s0[h +    94][2],s0[h +    94][3]),hideTrace($w[h +    94])=(s1[h +    94]),rgb($w[h +    95])=(s0[h +    95][0],s0[h +    95][1],s0[h +    95][2],s0[h +    95][3]),hideTrace($w[h +    95])=(s1[h +    95]) \
				,rgb($w[h +    96])=(s0[h +    96][0],s0[h +    96][1],s0[h +    96][2],s0[h +    96][3]),hideTrace($w[h +    96])=(s1[h +    96]),rgb($w[h +    97])=(s0[h +    97][0],s0[h +    97][1],s0[h +    97][2],s0[h +    97][3]),hideTrace($w[h +    97])=(s1[h +    97]),rgb($w[h +    98])=(s0[h +    98][0],s0[h +    98][1],s0[h +    98][2],s0[h +    98][3]),hideTrace($w[h +    98])=(s1[h +    98]),rgb($w[h +    99])=(s0[h +    99][0],s0[h +    99][1],s0[h +    99][2],s0[h +    99][3]),hideTrace($w[h +    99])=(s1[h +    99]),rgb($w[h +   100])=(s0[h +   100][0],s0[h +   100][1],s0[h +   100][2],s0[h +   100][3]),hideTrace($w[h +   100])=(s1[h +   100]),rgb($w[h +   101])=(s0[h +   101][0],s0[h +   101][1],s0[h +   101][2],s0[h +   101][3]),hideTrace($w[h +   101])=(s1[h +   101]),rgb($w[h +   102])=(s0[h +   102][0],s0[h +   102][1],s0[h +   102][2],s0[h +   102][3]),hideTrace($w[h +   102])=(s1[h +   102]),rgb($w[h +   103])=(s0[h +   103][0],s0[h +   103][1],s0[h +   103][2],s0[h +   103][3]),hideTrace($w[h +   103])=(s1[h +   103]) \
				,rgb($w[h +   104])=(s0[h +   104][0],s0[h +   104][1],s0[h +   104][2],s0[h +   104][3]),hideTrace($w[h +   104])=(s1[h +   104]),rgb($w[h +   105])=(s0[h +   105][0],s0[h +   105][1],s0[h +   105][2],s0[h +   105][3]),hideTrace($w[h +   105])=(s1[h +   105]),rgb($w[h +   106])=(s0[h +   106][0],s0[h +   106][1],s0[h +   106][2],s0[h +   106][3]),hideTrace($w[h +   106])=(s1[h +   106]),rgb($w[h +   107])=(s0[h +   107][0],s0[h +   107][1],s0[h +   107][2],s0[h +   107][3]),hideTrace($w[h +   107])=(s1[h +   107]),rgb($w[h +   108])=(s0[h +   108][0],s0[h +   108][1],s0[h +   108][2],s0[h +   108][3]),hideTrace($w[h +   108])=(s1[h +   108]),rgb($w[h +   109])=(s0[h +   109][0],s0[h +   109][1],s0[h +   109][2],s0[h +   109][3]),hideTrace($w[h +   109])=(s1[h +   109]),rgb($w[h +   110])=(s0[h +   110][0],s0[h +   110][1],s0[h +   110][2],s0[h +   110][3]),hideTrace($w[h +   110])=(s1[h +   110]),rgb($w[h +   111])=(s0[h +   111][0],s0[h +   111][1],s0[h +   111][2],s0[h +   111][3]),hideTrace($w[h +   111])=(s1[h +   111]) \
				,rgb($w[h +   112])=(s0[h +   112][0],s0[h +   112][1],s0[h +   112][2],s0[h +   112][3]),hideTrace($w[h +   112])=(s1[h +   112]),rgb($w[h +   113])=(s0[h +   113][0],s0[h +   113][1],s0[h +   113][2],s0[h +   113][3]),hideTrace($w[h +   113])=(s1[h +   113]),rgb($w[h +   114])=(s0[h +   114][0],s0[h +   114][1],s0[h +   114][2],s0[h +   114][3]),hideTrace($w[h +   114])=(s1[h +   114]),rgb($w[h +   115])=(s0[h +   115][0],s0[h +   115][1],s0[h +   115][2],s0[h +   115][3]),hideTrace($w[h +   115])=(s1[h +   115]),rgb($w[h +   116])=(s0[h +   116][0],s0[h +   116][1],s0[h +   116][2],s0[h +   116][3]),hideTrace($w[h +   116])=(s1[h +   116]),rgb($w[h +   117])=(s0[h +   117][0],s0[h +   117][1],s0[h +   117][2],s0[h +   117][3]),hideTrace($w[h +   117])=(s1[h +   117]),rgb($w[h +   118])=(s0[h +   118][0],s0[h +   118][1],s0[h +   118][2],s0[h +   118][3]),hideTrace($w[h +   118])=(s1[h +   118]),rgb($w[h +   119])=(s0[h +   119][0],s0[h +   119][1],s0[h +   119][2],s0[h +   119][3]),hideTrace($w[h +   119])=(s1[h +   119]) \
				,rgb($w[h +   120])=(s0[h +   120][0],s0[h +   120][1],s0[h +   120][2],s0[h +   120][3]),hideTrace($w[h +   120])=(s1[h +   120]),rgb($w[h +   121])=(s0[h +   121][0],s0[h +   121][1],s0[h +   121][2],s0[h +   121][3]),hideTrace($w[h +   121])=(s1[h +   121]),rgb($w[h +   122])=(s0[h +   122][0],s0[h +   122][1],s0[h +   122][2],s0[h +   122][3]),hideTrace($w[h +   122])=(s1[h +   122]),rgb($w[h +   123])=(s0[h +   123][0],s0[h +   123][1],s0[h +   123][2],s0[h +   123][3]),hideTrace($w[h +   123])=(s1[h +   123]),rgb($w[h +   124])=(s0[h +   124][0],s0[h +   124][1],s0[h +   124][2],s0[h +   124][3]),hideTrace($w[h +   124])=(s1[h +   124]),rgb($w[h +   125])=(s0[h +   125][0],s0[h +   125][1],s0[h +   125][2],s0[h +   125][3]),hideTrace($w[h +   125])=(s1[h +   125]),rgb($w[h +   126])=(s0[h +   126][0],s0[h +   126][1],s0[h +   126][2],s0[h +   126][3]),hideTrace($w[h +   126])=(s1[h +   126]),rgb($w[h +   127])=(s0[h +   127][0],s0[h +   127][1],s0[h +   127][2],s0[h +   127][3]),hideTrace($w[h +   127])=(s1[h +   127]) \
				,rgb($w[h +   128])=(s0[h +   128][0],s0[h +   128][1],s0[h +   128][2],s0[h +   128][3]),hideTrace($w[h +   128])=(s1[h +   128]),rgb($w[h +   129])=(s0[h +   129][0],s0[h +   129][1],s0[h +   129][2],s0[h +   129][3]),hideTrace($w[h +   129])=(s1[h +   129]),rgb($w[h +   130])=(s0[h +   130][0],s0[h +   130][1],s0[h +   130][2],s0[h +   130][3]),hideTrace($w[h +   130])=(s1[h +   130]),rgb($w[h +   131])=(s0[h +   131][0],s0[h +   131][1],s0[h +   131][2],s0[h +   131][3]),hideTrace($w[h +   131])=(s1[h +   131]),rgb($w[h +   132])=(s0[h +   132][0],s0[h +   132][1],s0[h +   132][2],s0[h +   132][3]),hideTrace($w[h +   132])=(s1[h +   132]),rgb($w[h +   133])=(s0[h +   133][0],s0[h +   133][1],s0[h +   133][2],s0[h +   133][3]),hideTrace($w[h +   133])=(s1[h +   133]),rgb($w[h +   134])=(s0[h +   134][0],s0[h +   134][1],s0[h +   134][2],s0[h +   134][3]),hideTrace($w[h +   134])=(s1[h +   134]),rgb($w[h +   135])=(s0[h +   135][0],s0[h +   135][1],s0[h +   135][2],s0[h +   135][3]),hideTrace($w[h +   135])=(s1[h +   135]) \
				,rgb($w[h +   136])=(s0[h +   136][0],s0[h +   136][1],s0[h +   136][2],s0[h +   136][3]),hideTrace($w[h +   136])=(s1[h +   136]),rgb($w[h +   137])=(s0[h +   137][0],s0[h +   137][1],s0[h +   137][2],s0[h +   137][3]),hideTrace($w[h +   137])=(s1[h +   137]),rgb($w[h +   138])=(s0[h +   138][0],s0[h +   138][1],s0[h +   138][2],s0[h +   138][3]),hideTrace($w[h +   138])=(s1[h +   138]),rgb($w[h +   139])=(s0[h +   139][0],s0[h +   139][1],s0[h +   139][2],s0[h +   139][3]),hideTrace($w[h +   139])=(s1[h +   139]),rgb($w[h +   140])=(s0[h +   140][0],s0[h +   140][1],s0[h +   140][2],s0[h +   140][3]),hideTrace($w[h +   140])=(s1[h +   140]),rgb($w[h +   141])=(s0[h +   141][0],s0[h +   141][1],s0[h +   141][2],s0[h +   141][3]),hideTrace($w[h +   141])=(s1[h +   141]),rgb($w[h +   142])=(s0[h +   142][0],s0[h +   142][1],s0[h +   142][2],s0[h +   142][3]),hideTrace($w[h +   142])=(s1[h +   142]),rgb($w[h +   143])=(s0[h +   143][0],s0[h +   143][1],s0[h +   143][2],s0[h +   143][3]),hideTrace($w[h +   143])=(s1[h +   143]) \
				,rgb($w[h +   144])=(s0[h +   144][0],s0[h +   144][1],s0[h +   144][2],s0[h +   144][3]),hideTrace($w[h +   144])=(s1[h +   144]),rgb($w[h +   145])=(s0[h +   145][0],s0[h +   145][1],s0[h +   145][2],s0[h +   145][3]),hideTrace($w[h +   145])=(s1[h +   145]),rgb($w[h +   146])=(s0[h +   146][0],s0[h +   146][1],s0[h +   146][2],s0[h +   146][3]),hideTrace($w[h +   146])=(s1[h +   146]),rgb($w[h +   147])=(s0[h +   147][0],s0[h +   147][1],s0[h +   147][2],s0[h +   147][3]),hideTrace($w[h +   147])=(s1[h +   147]),rgb($w[h +   148])=(s0[h +   148][0],s0[h +   148][1],s0[h +   148][2],s0[h +   148][3]),hideTrace($w[h +   148])=(s1[h +   148]),rgb($w[h +   149])=(s0[h +   149][0],s0[h +   149][1],s0[h +   149][2],s0[h +   149][3]),hideTrace($w[h +   149])=(s1[h +   149]),rgb($w[h +   150])=(s0[h +   150][0],s0[h +   150][1],s0[h +   150][2],s0[h +   150][3]),hideTrace($w[h +   150])=(s1[h +   150]),rgb($w[h +   151])=(s0[h +   151][0],s0[h +   151][1],s0[h +   151][2],s0[h +   151][3]),hideTrace($w[h +   151])=(s1[h +   151]) \
				,rgb($w[h +   152])=(s0[h +   152][0],s0[h +   152][1],s0[h +   152][2],s0[h +   152][3]),hideTrace($w[h +   152])=(s1[h +   152]),rgb($w[h +   153])=(s0[h +   153][0],s0[h +   153][1],s0[h +   153][2],s0[h +   153][3]),hideTrace($w[h +   153])=(s1[h +   153]),rgb($w[h +   154])=(s0[h +   154][0],s0[h +   154][1],s0[h +   154][2],s0[h +   154][3]),hideTrace($w[h +   154])=(s1[h +   154]),rgb($w[h +   155])=(s0[h +   155][0],s0[h +   155][1],s0[h +   155][2],s0[h +   155][3]),hideTrace($w[h +   155])=(s1[h +   155]),rgb($w[h +   156])=(s0[h +   156][0],s0[h +   156][1],s0[h +   156][2],s0[h +   156][3]),hideTrace($w[h +   156])=(s1[h +   156]),rgb($w[h +   157])=(s0[h +   157][0],s0[h +   157][1],s0[h +   157][2],s0[h +   157][3]),hideTrace($w[h +   157])=(s1[h +   157]),rgb($w[h +   158])=(s0[h +   158][0],s0[h +   158][1],s0[h +   158][2],s0[h +   158][3]),hideTrace($w[h +   158])=(s1[h +   158]),rgb($w[h +   159])=(s0[h +   159][0],s0[h +   159][1],s0[h +   159][2],s0[h +   159][3]),hideTrace($w[h +   159])=(s1[h +   159]) \
				,rgb($w[h +   160])=(s0[h +   160][0],s0[h +   160][1],s0[h +   160][2],s0[h +   160][3]),hideTrace($w[h +   160])=(s1[h +   160]),rgb($w[h +   161])=(s0[h +   161][0],s0[h +   161][1],s0[h +   161][2],s0[h +   161][3]),hideTrace($w[h +   161])=(s1[h +   161]),rgb($w[h +   162])=(s0[h +   162][0],s0[h +   162][1],s0[h +   162][2],s0[h +   162][3]),hideTrace($w[h +   162])=(s1[h +   162]),rgb($w[h +   163])=(s0[h +   163][0],s0[h +   163][1],s0[h +   163][2],s0[h +   163][3]),hideTrace($w[h +   163])=(s1[h +   163]),rgb($w[h +   164])=(s0[h +   164][0],s0[h +   164][1],s0[h +   164][2],s0[h +   164][3]),hideTrace($w[h +   164])=(s1[h +   164]),rgb($w[h +   165])=(s0[h +   165][0],s0[h +   165][1],s0[h +   165][2],s0[h +   165][3]),hideTrace($w[h +   165])=(s1[h +   165]),rgb($w[h +   166])=(s0[h +   166][0],s0[h +   166][1],s0[h +   166][2],s0[h +   166][3]),hideTrace($w[h +   166])=(s1[h +   166]),rgb($w[h +   167])=(s0[h +   167][0],s0[h +   167][1],s0[h +   167][2],s0[h +   167][3]),hideTrace($w[h +   167])=(s1[h +   167]) \
				,rgb($w[h +   168])=(s0[h +   168][0],s0[h +   168][1],s0[h +   168][2],s0[h +   168][3]),hideTrace($w[h +   168])=(s1[h +   168]),rgb($w[h +   169])=(s0[h +   169][0],s0[h +   169][1],s0[h +   169][2],s0[h +   169][3]),hideTrace($w[h +   169])=(s1[h +   169]),rgb($w[h +   170])=(s0[h +   170][0],s0[h +   170][1],s0[h +   170][2],s0[h +   170][3]),hideTrace($w[h +   170])=(s1[h +   170]),rgb($w[h +   171])=(s0[h +   171][0],s0[h +   171][1],s0[h +   171][2],s0[h +   171][3]),hideTrace($w[h +   171])=(s1[h +   171]),rgb($w[h +   172])=(s0[h +   172][0],s0[h +   172][1],s0[h +   172][2],s0[h +   172][3]),hideTrace($w[h +   172])=(s1[h +   172]),rgb($w[h +   173])=(s0[h +   173][0],s0[h +   173][1],s0[h +   173][2],s0[h +   173][3]),hideTrace($w[h +   173])=(s1[h +   173]),rgb($w[h +   174])=(s0[h +   174][0],s0[h +   174][1],s0[h +   174][2],s0[h +   174][3]),hideTrace($w[h +   174])=(s1[h +   174]),rgb($w[h +   175])=(s0[h +   175][0],s0[h +   175][1],s0[h +   175][2],s0[h +   175][3]),hideTrace($w[h +   175])=(s1[h +   175]) \
				,rgb($w[h +   176])=(s0[h +   176][0],s0[h +   176][1],s0[h +   176][2],s0[h +   176][3]),hideTrace($w[h +   176])=(s1[h +   176]),rgb($w[h +   177])=(s0[h +   177][0],s0[h +   177][1],s0[h +   177][2],s0[h +   177][3]),hideTrace($w[h +   177])=(s1[h +   177]),rgb($w[h +   178])=(s0[h +   178][0],s0[h +   178][1],s0[h +   178][2],s0[h +   178][3]),hideTrace($w[h +   178])=(s1[h +   178]),rgb($w[h +   179])=(s0[h +   179][0],s0[h +   179][1],s0[h +   179][2],s0[h +   179][3]),hideTrace($w[h +   179])=(s1[h +   179]),rgb($w[h +   180])=(s0[h +   180][0],s0[h +   180][1],s0[h +   180][2],s0[h +   180][3]),hideTrace($w[h +   180])=(s1[h +   180]),rgb($w[h +   181])=(s0[h +   181][0],s0[h +   181][1],s0[h +   181][2],s0[h +   181][3]),hideTrace($w[h +   181])=(s1[h +   181]),rgb($w[h +   182])=(s0[h +   182][0],s0[h +   182][1],s0[h +   182][2],s0[h +   182][3]),hideTrace($w[h +   182])=(s1[h +   182]),rgb($w[h +   183])=(s0[h +   183][0],s0[h +   183][1],s0[h +   183][2],s0[h +   183][3]),hideTrace($w[h +   183])=(s1[h +   183]) \
				,rgb($w[h +   184])=(s0[h +   184][0],s0[h +   184][1],s0[h +   184][2],s0[h +   184][3]),hideTrace($w[h +   184])=(s1[h +   184]),rgb($w[h +   185])=(s0[h +   185][0],s0[h +   185][1],s0[h +   185][2],s0[h +   185][3]),hideTrace($w[h +   185])=(s1[h +   185]),rgb($w[h +   186])=(s0[h +   186][0],s0[h +   186][1],s0[h +   186][2],s0[h +   186][3]),hideTrace($w[h +   186])=(s1[h +   186]),rgb($w[h +   187])=(s0[h +   187][0],s0[h +   187][1],s0[h +   187][2],s0[h +   187][3]),hideTrace($w[h +   187])=(s1[h +   187]),rgb($w[h +   188])=(s0[h +   188][0],s0[h +   188][1],s0[h +   188][2],s0[h +   188][3]),hideTrace($w[h +   188])=(s1[h +   188]),rgb($w[h +   189])=(s0[h +   189][0],s0[h +   189][1],s0[h +   189][2],s0[h +   189][3]),hideTrace($w[h +   189])=(s1[h +   189]),rgb($w[h +   190])=(s0[h +   190][0],s0[h +   190][1],s0[h +   190][2],s0[h +   190][3]),hideTrace($w[h +   190])=(s1[h +   190]),rgb($w[h +   191])=(s0[h +   191][0],s0[h +   191][1],s0[h +   191][2],s0[h +   191][3]),hideTrace($w[h +   191])=(s1[h +   191]) \
				,rgb($w[h +   192])=(s0[h +   192][0],s0[h +   192][1],s0[h +   192][2],s0[h +   192][3]),hideTrace($w[h +   192])=(s1[h +   192]),rgb($w[h +   193])=(s0[h +   193][0],s0[h +   193][1],s0[h +   193][2],s0[h +   193][3]),hideTrace($w[h +   193])=(s1[h +   193]),rgb($w[h +   194])=(s0[h +   194][0],s0[h +   194][1],s0[h +   194][2],s0[h +   194][3]),hideTrace($w[h +   194])=(s1[h +   194]),rgb($w[h +   195])=(s0[h +   195][0],s0[h +   195][1],s0[h +   195][2],s0[h +   195][3]),hideTrace($w[h +   195])=(s1[h +   195]),rgb($w[h +   196])=(s0[h +   196][0],s0[h +   196][1],s0[h +   196][2],s0[h +   196][3]),hideTrace($w[h +   196])=(s1[h +   196]),rgb($w[h +   197])=(s0[h +   197][0],s0[h +   197][1],s0[h +   197][2],s0[h +   197][3]),hideTrace($w[h +   197])=(s1[h +   197]),rgb($w[h +   198])=(s0[h +   198][0],s0[h +   198][1],s0[h +   198][2],s0[h +   198][3]),hideTrace($w[h +   198])=(s1[h +   198]),rgb($w[h +   199])=(s0[h +   199][0],s0[h +   199][1],s0[h +   199][2],s0[h +   199][3]),hideTrace($w[h +   199])=(s1[h +   199]) \
				,rgb($w[h +   200])=(s0[h +   200][0],s0[h +   200][1],s0[h +   200][2],s0[h +   200][3]),hideTrace($w[h +   200])=(s1[h +   200]),rgb($w[h +   201])=(s0[h +   201][0],s0[h +   201][1],s0[h +   201][2],s0[h +   201][3]),hideTrace($w[h +   201])=(s1[h +   201]),rgb($w[h +   202])=(s0[h +   202][0],s0[h +   202][1],s0[h +   202][2],s0[h +   202][3]),hideTrace($w[h +   202])=(s1[h +   202]),rgb($w[h +   203])=(s0[h +   203][0],s0[h +   203][1],s0[h +   203][2],s0[h +   203][3]),hideTrace($w[h +   203])=(s1[h +   203]),rgb($w[h +   204])=(s0[h +   204][0],s0[h +   204][1],s0[h +   204][2],s0[h +   204][3]),hideTrace($w[h +   204])=(s1[h +   204]),rgb($w[h +   205])=(s0[h +   205][0],s0[h +   205][1],s0[h +   205][2],s0[h +   205][3]),hideTrace($w[h +   205])=(s1[h +   205]),rgb($w[h +   206])=(s0[h +   206][0],s0[h +   206][1],s0[h +   206][2],s0[h +   206][3]),hideTrace($w[h +   206])=(s1[h +   206]),rgb($w[h +   207])=(s0[h +   207][0],s0[h +   207][1],s0[h +   207][2],s0[h +   207][3]),hideTrace($w[h +   207])=(s1[h +   207]) \
				,rgb($w[h +   208])=(s0[h +   208][0],s0[h +   208][1],s0[h +   208][2],s0[h +   208][3]),hideTrace($w[h +   208])=(s1[h +   208]),rgb($w[h +   209])=(s0[h +   209][0],s0[h +   209][1],s0[h +   209][2],s0[h +   209][3]),hideTrace($w[h +   209])=(s1[h +   209]),rgb($w[h +   210])=(s0[h +   210][0],s0[h +   210][1],s0[h +   210][2],s0[h +   210][3]),hideTrace($w[h +   210])=(s1[h +   210]),rgb($w[h +   211])=(s0[h +   211][0],s0[h +   211][1],s0[h +   211][2],s0[h +   211][3]),hideTrace($w[h +   211])=(s1[h +   211]),rgb($w[h +   212])=(s0[h +   212][0],s0[h +   212][1],s0[h +   212][2],s0[h +   212][3]),hideTrace($w[h +   212])=(s1[h +   212]),rgb($w[h +   213])=(s0[h +   213][0],s0[h +   213][1],s0[h +   213][2],s0[h +   213][3]),hideTrace($w[h +   213])=(s1[h +   213]),rgb($w[h +   214])=(s0[h +   214][0],s0[h +   214][1],s0[h +   214][2],s0[h +   214][3]),hideTrace($w[h +   214])=(s1[h +   214]),rgb($w[h +   215])=(s0[h +   215][0],s0[h +   215][1],s0[h +   215][2],s0[h +   215][3]),hideTrace($w[h +   215])=(s1[h +   215]) \
				,rgb($w[h +   216])=(s0[h +   216][0],s0[h +   216][1],s0[h +   216][2],s0[h +   216][3]),hideTrace($w[h +   216])=(s1[h +   216]),rgb($w[h +   217])=(s0[h +   217][0],s0[h +   217][1],s0[h +   217][2],s0[h +   217][3]),hideTrace($w[h +   217])=(s1[h +   217]),rgb($w[h +   218])=(s0[h +   218][0],s0[h +   218][1],s0[h +   218][2],s0[h +   218][3]),hideTrace($w[h +   218])=(s1[h +   218]),rgb($w[h +   219])=(s0[h +   219][0],s0[h +   219][1],s0[h +   219][2],s0[h +   219][3]),hideTrace($w[h +   219])=(s1[h +   219]),rgb($w[h +   220])=(s0[h +   220][0],s0[h +   220][1],s0[h +   220][2],s0[h +   220][3]),hideTrace($w[h +   220])=(s1[h +   220]),rgb($w[h +   221])=(s0[h +   221][0],s0[h +   221][1],s0[h +   221][2],s0[h +   221][3]),hideTrace($w[h +   221])=(s1[h +   221]),rgb($w[h +   222])=(s0[h +   222][0],s0[h +   222][1],s0[h +   222][2],s0[h +   222][3]),hideTrace($w[h +   222])=(s1[h +   222]),rgb($w[h +   223])=(s0[h +   223][0],s0[h +   223][1],s0[h +   223][2],s0[h +   223][3]),hideTrace($w[h +   223])=(s1[h +   223]) \
				,rgb($w[h +   224])=(s0[h +   224][0],s0[h +   224][1],s0[h +   224][2],s0[h +   224][3]),hideTrace($w[h +   224])=(s1[h +   224]),rgb($w[h +   225])=(s0[h +   225][0],s0[h +   225][1],s0[h +   225][2],s0[h +   225][3]),hideTrace($w[h +   225])=(s1[h +   225]),rgb($w[h +   226])=(s0[h +   226][0],s0[h +   226][1],s0[h +   226][2],s0[h +   226][3]),hideTrace($w[h +   226])=(s1[h +   226]),rgb($w[h +   227])=(s0[h +   227][0],s0[h +   227][1],s0[h +   227][2],s0[h +   227][3]),hideTrace($w[h +   227])=(s1[h +   227]),rgb($w[h +   228])=(s0[h +   228][0],s0[h +   228][1],s0[h +   228][2],s0[h +   228][3]),hideTrace($w[h +   228])=(s1[h +   228]),rgb($w[h +   229])=(s0[h +   229][0],s0[h +   229][1],s0[h +   229][2],s0[h +   229][3]),hideTrace($w[h +   229])=(s1[h +   229]),rgb($w[h +   230])=(s0[h +   230][0],s0[h +   230][1],s0[h +   230][2],s0[h +   230][3]),hideTrace($w[h +   230])=(s1[h +   230]),rgb($w[h +   231])=(s0[h +   231][0],s0[h +   231][1],s0[h +   231][2],s0[h +   231][3]),hideTrace($w[h +   231])=(s1[h +   231]) \
				,rgb($w[h +   232])=(s0[h +   232][0],s0[h +   232][1],s0[h +   232][2],s0[h +   232][3]),hideTrace($w[h +   232])=(s1[h +   232]),rgb($w[h +   233])=(s0[h +   233][0],s0[h +   233][1],s0[h +   233][2],s0[h +   233][3]),hideTrace($w[h +   233])=(s1[h +   233]),rgb($w[h +   234])=(s0[h +   234][0],s0[h +   234][1],s0[h +   234][2],s0[h +   234][3]),hideTrace($w[h +   234])=(s1[h +   234]),rgb($w[h +   235])=(s0[h +   235][0],s0[h +   235][1],s0[h +   235][2],s0[h +   235][3]),hideTrace($w[h +   235])=(s1[h +   235]),rgb($w[h +   236])=(s0[h +   236][0],s0[h +   236][1],s0[h +   236][2],s0[h +   236][3]),hideTrace($w[h +   236])=(s1[h +   236]),rgb($w[h +   237])=(s0[h +   237][0],s0[h +   237][1],s0[h +   237][2],s0[h +   237][3]),hideTrace($w[h +   237])=(s1[h +   237]),rgb($w[h +   238])=(s0[h +   238][0],s0[h +   238][1],s0[h +   238][2],s0[h +   238][3]),hideTrace($w[h +   238])=(s1[h +   238]),rgb($w[h +   239])=(s0[h +   239][0],s0[h +   239][1],s0[h +   239][2],s0[h +   239][3]),hideTrace($w[h +   239])=(s1[h +   239]) \
				,rgb($w[h +   240])=(s0[h +   240][0],s0[h +   240][1],s0[h +   240][2],s0[h +   240][3]),hideTrace($w[h +   240])=(s1[h +   240]),rgb($w[h +   241])=(s0[h +   241][0],s0[h +   241][1],s0[h +   241][2],s0[h +   241][3]),hideTrace($w[h +   241])=(s1[h +   241]),rgb($w[h +   242])=(s0[h +   242][0],s0[h +   242][1],s0[h +   242][2],s0[h +   242][3]),hideTrace($w[h +   242])=(s1[h +   242]),rgb($w[h +   243])=(s0[h +   243][0],s0[h +   243][1],s0[h +   243][2],s0[h +   243][3]),hideTrace($w[h +   243])=(s1[h +   243]),rgb($w[h +   244])=(s0[h +   244][0],s0[h +   244][1],s0[h +   244][2],s0[h +   244][3]),hideTrace($w[h +   244])=(s1[h +   244]),rgb($w[h +   245])=(s0[h +   245][0],s0[h +   245][1],s0[h +   245][2],s0[h +   245][3]),hideTrace($w[h +   245])=(s1[h +   245]),rgb($w[h +   246])=(s0[h +   246][0],s0[h +   246][1],s0[h +   246][2],s0[h +   246][3]),hideTrace($w[h +   246])=(s1[h +   246]),rgb($w[h +   247])=(s0[h +   247][0],s0[h +   247][1],s0[h +   247][2],s0[h +   247][3]),hideTrace($w[h +   247])=(s1[h +   247]) \
				,rgb($w[h +   248])=(s0[h +   248][0],s0[h +   248][1],s0[h +   248][2],s0[h +   248][3]),hideTrace($w[h +   248])=(s1[h +   248]),rgb($w[h +   249])=(s0[h +   249][0],s0[h +   249][1],s0[h +   249][2],s0[h +   249][3]),hideTrace($w[h +   249])=(s1[h +   249]),rgb($w[h +   250])=(s0[h +   250][0],s0[h +   250][1],s0[h +   250][2],s0[h +   250][3]),hideTrace($w[h +   250])=(s1[h +   250]),rgb($w[h +   251])=(s0[h +   251][0],s0[h +   251][1],s0[h +   251][2],s0[h +   251][3]),hideTrace($w[h +   251])=(s1[h +   251]),rgb($w[h +   252])=(s0[h +   252][0],s0[h +   252][1],s0[h +   252][2],s0[h +   252][3]),hideTrace($w[h +   252])=(s1[h +   252]),rgb($w[h +   253])=(s0[h +   253][0],s0[h +   253][1],s0[h +   253][2],s0[h +   253][3]),hideTrace($w[h +   253])=(s1[h +   253]),rgb($w[h +   254])=(s0[h +   254][0],s0[h +   254][1],s0[h +   254][2],s0[h +   254][3]),hideTrace($w[h +   254])=(s1[h +   254]),rgb($w[h +   255])=(s0[h +   255][0],s0[h +   255][1],s0[h +   255][2],s0[h +   255][3]),hideTrace($w[h +   255])=(s1[h +   255]) \
				,rgb($w[h +   256])=(s0[h +   256][0],s0[h +   256][1],s0[h +   256][2],s0[h +   256][3]),hideTrace($w[h +   256])=(s1[h +   256]),rgb($w[h +   257])=(s0[h +   257][0],s0[h +   257][1],s0[h +   257][2],s0[h +   257][3]),hideTrace($w[h +   257])=(s1[h +   257]),rgb($w[h +   258])=(s0[h +   258][0],s0[h +   258][1],s0[h +   258][2],s0[h +   258][3]),hideTrace($w[h +   258])=(s1[h +   258]),rgb($w[h +   259])=(s0[h +   259][0],s0[h +   259][1],s0[h +   259][2],s0[h +   259][3]),hideTrace($w[h +   259])=(s1[h +   259]),rgb($w[h +   260])=(s0[h +   260][0],s0[h +   260][1],s0[h +   260][2],s0[h +   260][3]),hideTrace($w[h +   260])=(s1[h +   260]),rgb($w[h +   261])=(s0[h +   261][0],s0[h +   261][1],s0[h +   261][2],s0[h +   261][3]),hideTrace($w[h +   261])=(s1[h +   261]),rgb($w[h +   262])=(s0[h +   262][0],s0[h +   262][1],s0[h +   262][2],s0[h +   262][3]),hideTrace($w[h +   262])=(s1[h +   262]),rgb($w[h +   263])=(s0[h +   263][0],s0[h +   263][1],s0[h +   263][2],s0[h +   263][3]),hideTrace($w[h +   263])=(s1[h +   263]) \
				,rgb($w[h +   264])=(s0[h +   264][0],s0[h +   264][1],s0[h +   264][2],s0[h +   264][3]),hideTrace($w[h +   264])=(s1[h +   264]),rgb($w[h +   265])=(s0[h +   265][0],s0[h +   265][1],s0[h +   265][2],s0[h +   265][3]),hideTrace($w[h +   265])=(s1[h +   265]),rgb($w[h +   266])=(s0[h +   266][0],s0[h +   266][1],s0[h +   266][2],s0[h +   266][3]),hideTrace($w[h +   266])=(s1[h +   266]),rgb($w[h +   267])=(s0[h +   267][0],s0[h +   267][1],s0[h +   267][2],s0[h +   267][3]),hideTrace($w[h +   267])=(s1[h +   267]),rgb($w[h +   268])=(s0[h +   268][0],s0[h +   268][1],s0[h +   268][2],s0[h +   268][3]),hideTrace($w[h +   268])=(s1[h +   268]),rgb($w[h +   269])=(s0[h +   269][0],s0[h +   269][1],s0[h +   269][2],s0[h +   269][3]),hideTrace($w[h +   269])=(s1[h +   269]),rgb($w[h +   270])=(s0[h +   270][0],s0[h +   270][1],s0[h +   270][2],s0[h +   270][3]),hideTrace($w[h +   270])=(s1[h +   270]),rgb($w[h +   271])=(s0[h +   271][0],s0[h +   271][1],s0[h +   271][2],s0[h +   271][3]),hideTrace($w[h +   271])=(s1[h +   271]) \
				,rgb($w[h +   272])=(s0[h +   272][0],s0[h +   272][1],s0[h +   272][2],s0[h +   272][3]),hideTrace($w[h +   272])=(s1[h +   272]),rgb($w[h +   273])=(s0[h +   273][0],s0[h +   273][1],s0[h +   273][2],s0[h +   273][3]),hideTrace($w[h +   273])=(s1[h +   273]),rgb($w[h +   274])=(s0[h +   274][0],s0[h +   274][1],s0[h +   274][2],s0[h +   274][3]),hideTrace($w[h +   274])=(s1[h +   274]),rgb($w[h +   275])=(s0[h +   275][0],s0[h +   275][1],s0[h +   275][2],s0[h +   275][3]),hideTrace($w[h +   275])=(s1[h +   275]),rgb($w[h +   276])=(s0[h +   276][0],s0[h +   276][1],s0[h +   276][2],s0[h +   276][3]),hideTrace($w[h +   276])=(s1[h +   276]),rgb($w[h +   277])=(s0[h +   277][0],s0[h +   277][1],s0[h +   277][2],s0[h +   277][3]),hideTrace($w[h +   277])=(s1[h +   277]),rgb($w[h +   278])=(s0[h +   278][0],s0[h +   278][1],s0[h +   278][2],s0[h +   278][3]),hideTrace($w[h +   278])=(s1[h +   278]),rgb($w[h +   279])=(s0[h +   279][0],s0[h +   279][1],s0[h +   279][2],s0[h +   279][3]),hideTrace($w[h +   279])=(s1[h +   279]) \
				,rgb($w[h +   280])=(s0[h +   280][0],s0[h +   280][1],s0[h +   280][2],s0[h +   280][3]),hideTrace($w[h +   280])=(s1[h +   280]),rgb($w[h +   281])=(s0[h +   281][0],s0[h +   281][1],s0[h +   281][2],s0[h +   281][3]),hideTrace($w[h +   281])=(s1[h +   281]),rgb($w[h +   282])=(s0[h +   282][0],s0[h +   282][1],s0[h +   282][2],s0[h +   282][3]),hideTrace($w[h +   282])=(s1[h +   282]),rgb($w[h +   283])=(s0[h +   283][0],s0[h +   283][1],s0[h +   283][2],s0[h +   283][3]),hideTrace($w[h +   283])=(s1[h +   283]),rgb($w[h +   284])=(s0[h +   284][0],s0[h +   284][1],s0[h +   284][2],s0[h +   284][3]),hideTrace($w[h +   284])=(s1[h +   284]),rgb($w[h +   285])=(s0[h +   285][0],s0[h +   285][1],s0[h +   285][2],s0[h +   285][3]),hideTrace($w[h +   285])=(s1[h +   285]),rgb($w[h +   286])=(s0[h +   286][0],s0[h +   286][1],s0[h +   286][2],s0[h +   286][3]),hideTrace($w[h +   286])=(s1[h +   286]),rgb($w[h +   287])=(s0[h +   287][0],s0[h +   287][1],s0[h +   287][2],s0[h +   287][3]),hideTrace($w[h +   287])=(s1[h +   287]) \
				,rgb($w[h +   288])=(s0[h +   288][0],s0[h +   288][1],s0[h +   288][2],s0[h +   288][3]),hideTrace($w[h +   288])=(s1[h +   288]),rgb($w[h +   289])=(s0[h +   289][0],s0[h +   289][1],s0[h +   289][2],s0[h +   289][3]),hideTrace($w[h +   289])=(s1[h +   289]),rgb($w[h +   290])=(s0[h +   290][0],s0[h +   290][1],s0[h +   290][2],s0[h +   290][3]),hideTrace($w[h +   290])=(s1[h +   290]),rgb($w[h +   291])=(s0[h +   291][0],s0[h +   291][1],s0[h +   291][2],s0[h +   291][3]),hideTrace($w[h +   291])=(s1[h +   291]),rgb($w[h +   292])=(s0[h +   292][0],s0[h +   292][1],s0[h +   292][2],s0[h +   292][3]),hideTrace($w[h +   292])=(s1[h +   292]),rgb($w[h +   293])=(s0[h +   293][0],s0[h +   293][1],s0[h +   293][2],s0[h +   293][3]),hideTrace($w[h +   293])=(s1[h +   293]),rgb($w[h +   294])=(s0[h +   294][0],s0[h +   294][1],s0[h +   294][2],s0[h +   294][3]),hideTrace($w[h +   294])=(s1[h +   294]),rgb($w[h +   295])=(s0[h +   295][0],s0[h +   295][1],s0[h +   295][2],s0[h +   295][3]),hideTrace($w[h +   295])=(s1[h +   295]) \
				,rgb($w[h +   296])=(s0[h +   296][0],s0[h +   296][1],s0[h +   296][2],s0[h +   296][3]),hideTrace($w[h +   296])=(s1[h +   296]),rgb($w[h +   297])=(s0[h +   297][0],s0[h +   297][1],s0[h +   297][2],s0[h +   297][3]),hideTrace($w[h +   297])=(s1[h +   297]),rgb($w[h +   298])=(s0[h +   298][0],s0[h +   298][1],s0[h +   298][2],s0[h +   298][3]),hideTrace($w[h +   298])=(s1[h +   298]),rgb($w[h +   299])=(s0[h +   299][0],s0[h +   299][1],s0[h +   299][2],s0[h +   299][3]),hideTrace($w[h +   299])=(s1[h +   299]),rgb($w[h +   300])=(s0[h +   300][0],s0[h +   300][1],s0[h +   300][2],s0[h +   300][3]),hideTrace($w[h +   300])=(s1[h +   300]),rgb($w[h +   301])=(s0[h +   301][0],s0[h +   301][1],s0[h +   301][2],s0[h +   301][3]),hideTrace($w[h +   301])=(s1[h +   301]),rgb($w[h +   302])=(s0[h +   302][0],s0[h +   302][1],s0[h +   302][2],s0[h +   302][3]),hideTrace($w[h +   302])=(s1[h +   302]),rgb($w[h +   303])=(s0[h +   303][0],s0[h +   303][1],s0[h +   303][2],s0[h +   303][3]),hideTrace($w[h +   303])=(s1[h +   303]) \
				,rgb($w[h +   304])=(s0[h +   304][0],s0[h +   304][1],s0[h +   304][2],s0[h +   304][3]),hideTrace($w[h +   304])=(s1[h +   304]),rgb($w[h +   305])=(s0[h +   305][0],s0[h +   305][1],s0[h +   305][2],s0[h +   305][3]),hideTrace($w[h +   305])=(s1[h +   305]),rgb($w[h +   306])=(s0[h +   306][0],s0[h +   306][1],s0[h +   306][2],s0[h +   306][3]),hideTrace($w[h +   306])=(s1[h +   306]),rgb($w[h +   307])=(s0[h +   307][0],s0[h +   307][1],s0[h +   307][2],s0[h +   307][3]),hideTrace($w[h +   307])=(s1[h +   307]),rgb($w[h +   308])=(s0[h +   308][0],s0[h +   308][1],s0[h +   308][2],s0[h +   308][3]),hideTrace($w[h +   308])=(s1[h +   308]),rgb($w[h +   309])=(s0[h +   309][0],s0[h +   309][1],s0[h +   309][2],s0[h +   309][3]),hideTrace($w[h +   309])=(s1[h +   309]),rgb($w[h +   310])=(s0[h +   310][0],s0[h +   310][1],s0[h +   310][2],s0[h +   310][3]),hideTrace($w[h +   310])=(s1[h +   310]),rgb($w[h +   311])=(s0[h +   311][0],s0[h +   311][1],s0[h +   311][2],s0[h +   311][3]),hideTrace($w[h +   311])=(s1[h +   311]) \
				,rgb($w[h +   312])=(s0[h +   312][0],s0[h +   312][1],s0[h +   312][2],s0[h +   312][3]),hideTrace($w[h +   312])=(s1[h +   312]),rgb($w[h +   313])=(s0[h +   313][0],s0[h +   313][1],s0[h +   313][2],s0[h +   313][3]),hideTrace($w[h +   313])=(s1[h +   313]),rgb($w[h +   314])=(s0[h +   314][0],s0[h +   314][1],s0[h +   314][2],s0[h +   314][3]),hideTrace($w[h +   314])=(s1[h +   314]),rgb($w[h +   315])=(s0[h +   315][0],s0[h +   315][1],s0[h +   315][2],s0[h +   315][3]),hideTrace($w[h +   315])=(s1[h +   315]),rgb($w[h +   316])=(s0[h +   316][0],s0[h +   316][1],s0[h +   316][2],s0[h +   316][3]),hideTrace($w[h +   316])=(s1[h +   316]),rgb($w[h +   317])=(s0[h +   317][0],s0[h +   317][1],s0[h +   317][2],s0[h +   317][3]),hideTrace($w[h +   317])=(s1[h +   317]),rgb($w[h +   318])=(s0[h +   318][0],s0[h +   318][1],s0[h +   318][2],s0[h +   318][3]),hideTrace($w[h +   318])=(s1[h +   318]),rgb($w[h +   319])=(s0[h +   319][0],s0[h +   319][1],s0[h +   319][2],s0[h +   319][3]),hideTrace($w[h +   319])=(s1[h +   319]) \
				,rgb($w[h +   320])=(s0[h +   320][0],s0[h +   320][1],s0[h +   320][2],s0[h +   320][3]),hideTrace($w[h +   320])=(s1[h +   320]),rgb($w[h +   321])=(s0[h +   321][0],s0[h +   321][1],s0[h +   321][2],s0[h +   321][3]),hideTrace($w[h +   321])=(s1[h +   321]),rgb($w[h +   322])=(s0[h +   322][0],s0[h +   322][1],s0[h +   322][2],s0[h +   322][3]),hideTrace($w[h +   322])=(s1[h +   322]),rgb($w[h +   323])=(s0[h +   323][0],s0[h +   323][1],s0[h +   323][2],s0[h +   323][3]),hideTrace($w[h +   323])=(s1[h +   323]),rgb($w[h +   324])=(s0[h +   324][0],s0[h +   324][1],s0[h +   324][2],s0[h +   324][3]),hideTrace($w[h +   324])=(s1[h +   324]),rgb($w[h +   325])=(s0[h +   325][0],s0[h +   325][1],s0[h +   325][2],s0[h +   325][3]),hideTrace($w[h +   325])=(s1[h +   325]),rgb($w[h +   326])=(s0[h +   326][0],s0[h +   326][1],s0[h +   326][2],s0[h +   326][3]),hideTrace($w[h +   326])=(s1[h +   326]),rgb($w[h +   327])=(s0[h +   327][0],s0[h +   327][1],s0[h +   327][2],s0[h +   327][3]),hideTrace($w[h +   327])=(s1[h +   327]) \
				,rgb($w[h +   328])=(s0[h +   328][0],s0[h +   328][1],s0[h +   328][2],s0[h +   328][3]),hideTrace($w[h +   328])=(s1[h +   328]),rgb($w[h +   329])=(s0[h +   329][0],s0[h +   329][1],s0[h +   329][2],s0[h +   329][3]),hideTrace($w[h +   329])=(s1[h +   329]),rgb($w[h +   330])=(s0[h +   330][0],s0[h +   330][1],s0[h +   330][2],s0[h +   330][3]),hideTrace($w[h +   330])=(s1[h +   330]),rgb($w[h +   331])=(s0[h +   331][0],s0[h +   331][1],s0[h +   331][2],s0[h +   331][3]),hideTrace($w[h +   331])=(s1[h +   331]),rgb($w[h +   332])=(s0[h +   332][0],s0[h +   332][1],s0[h +   332][2],s0[h +   332][3]),hideTrace($w[h +   332])=(s1[h +   332]),rgb($w[h +   333])=(s0[h +   333][0],s0[h +   333][1],s0[h +   333][2],s0[h +   333][3]),hideTrace($w[h +   333])=(s1[h +   333]),rgb($w[h +   334])=(s0[h +   334][0],s0[h +   334][1],s0[h +   334][2],s0[h +   334][3]),hideTrace($w[h +   334])=(s1[h +   334]),rgb($w[h +   335])=(s0[h +   335][0],s0[h +   335][1],s0[h +   335][2],s0[h +   335][3]),hideTrace($w[h +   335])=(s1[h +   335]) \
				,rgb($w[h +   336])=(s0[h +   336][0],s0[h +   336][1],s0[h +   336][2],s0[h +   336][3]),hideTrace($w[h +   336])=(s1[h +   336]),rgb($w[h +   337])=(s0[h +   337][0],s0[h +   337][1],s0[h +   337][2],s0[h +   337][3]),hideTrace($w[h +   337])=(s1[h +   337]),rgb($w[h +   338])=(s0[h +   338][0],s0[h +   338][1],s0[h +   338][2],s0[h +   338][3]),hideTrace($w[h +   338])=(s1[h +   338]),rgb($w[h +   339])=(s0[h +   339][0],s0[h +   339][1],s0[h +   339][2],s0[h +   339][3]),hideTrace($w[h +   339])=(s1[h +   339]),rgb($w[h +   340])=(s0[h +   340][0],s0[h +   340][1],s0[h +   340][2],s0[h +   340][3]),hideTrace($w[h +   340])=(s1[h +   340]),rgb($w[h +   341])=(s0[h +   341][0],s0[h +   341][1],s0[h +   341][2],s0[h +   341][3]),hideTrace($w[h +   341])=(s1[h +   341]),rgb($w[h +   342])=(s0[h +   342][0],s0[h +   342][1],s0[h +   342][2],s0[h +   342][3]),hideTrace($w[h +   342])=(s1[h +   342]),rgb($w[h +   343])=(s0[h +   343][0],s0[h +   343][1],s0[h +   343][2],s0[h +   343][3]),hideTrace($w[h +   343])=(s1[h +   343]) \
				,rgb($w[h +   344])=(s0[h +   344][0],s0[h +   344][1],s0[h +   344][2],s0[h +   344][3]),hideTrace($w[h +   344])=(s1[h +   344]),rgb($w[h +   345])=(s0[h +   345][0],s0[h +   345][1],s0[h +   345][2],s0[h +   345][3]),hideTrace($w[h +   345])=(s1[h +   345]),rgb($w[h +   346])=(s0[h +   346][0],s0[h +   346][1],s0[h +   346][2],s0[h +   346][3]),hideTrace($w[h +   346])=(s1[h +   346]),rgb($w[h +   347])=(s0[h +   347][0],s0[h +   347][1],s0[h +   347][2],s0[h +   347][3]),hideTrace($w[h +   347])=(s1[h +   347]),rgb($w[h +   348])=(s0[h +   348][0],s0[h +   348][1],s0[h +   348][2],s0[h +   348][3]),hideTrace($w[h +   348])=(s1[h +   348]),rgb($w[h +   349])=(s0[h +   349][0],s0[h +   349][1],s0[h +   349][2],s0[h +   349][3]),hideTrace($w[h +   349])=(s1[h +   349]),rgb($w[h +   350])=(s0[h +   350][0],s0[h +   350][1],s0[h +   350][2],s0[h +   350][3]),hideTrace($w[h +   350])=(s1[h +   350]),rgb($w[h +   351])=(s0[h +   351][0],s0[h +   351][1],s0[h +   351][2],s0[h +   351][3]),hideTrace($w[h +   351])=(s1[h +   351]) \
				,rgb($w[h +   352])=(s0[h +   352][0],s0[h +   352][1],s0[h +   352][2],s0[h +   352][3]),hideTrace($w[h +   352])=(s1[h +   352]),rgb($w[h +   353])=(s0[h +   353][0],s0[h +   353][1],s0[h +   353][2],s0[h +   353][3]),hideTrace($w[h +   353])=(s1[h +   353]),rgb($w[h +   354])=(s0[h +   354][0],s0[h +   354][1],s0[h +   354][2],s0[h +   354][3]),hideTrace($w[h +   354])=(s1[h +   354]),rgb($w[h +   355])=(s0[h +   355][0],s0[h +   355][1],s0[h +   355][2],s0[h +   355][3]),hideTrace($w[h +   355])=(s1[h +   355]),rgb($w[h +   356])=(s0[h +   356][0],s0[h +   356][1],s0[h +   356][2],s0[h +   356][3]),hideTrace($w[h +   356])=(s1[h +   356]),rgb($w[h +   357])=(s0[h +   357][0],s0[h +   357][1],s0[h +   357][2],s0[h +   357][3]),hideTrace($w[h +   357])=(s1[h +   357]),rgb($w[h +   358])=(s0[h +   358][0],s0[h +   358][1],s0[h +   358][2],s0[h +   358][3]),hideTrace($w[h +   358])=(s1[h +   358]),rgb($w[h +   359])=(s0[h +   359][0],s0[h +   359][1],s0[h +   359][2],s0[h +   359][3]),hideTrace($w[h +   359])=(s1[h +   359]) \
				,rgb($w[h +   360])=(s0[h +   360][0],s0[h +   360][1],s0[h +   360][2],s0[h +   360][3]),hideTrace($w[h +   360])=(s1[h +   360]),rgb($w[h +   361])=(s0[h +   361][0],s0[h +   361][1],s0[h +   361][2],s0[h +   361][3]),hideTrace($w[h +   361])=(s1[h +   361]),rgb($w[h +   362])=(s0[h +   362][0],s0[h +   362][1],s0[h +   362][2],s0[h +   362][3]),hideTrace($w[h +   362])=(s1[h +   362]),rgb($w[h +   363])=(s0[h +   363][0],s0[h +   363][1],s0[h +   363][2],s0[h +   363][3]),hideTrace($w[h +   363])=(s1[h +   363]),rgb($w[h +   364])=(s0[h +   364][0],s0[h +   364][1],s0[h +   364][2],s0[h +   364][3]),hideTrace($w[h +   364])=(s1[h +   364]),rgb($w[h +   365])=(s0[h +   365][0],s0[h +   365][1],s0[h +   365][2],s0[h +   365][3]),hideTrace($w[h +   365])=(s1[h +   365]),rgb($w[h +   366])=(s0[h +   366][0],s0[h +   366][1],s0[h +   366][2],s0[h +   366][3]),hideTrace($w[h +   366])=(s1[h +   366]),rgb($w[h +   367])=(s0[h +   367][0],s0[h +   367][1],s0[h +   367][2],s0[h +   367][3]),hideTrace($w[h +   367])=(s1[h +   367]) \
				,rgb($w[h +   368])=(s0[h +   368][0],s0[h +   368][1],s0[h +   368][2],s0[h +   368][3]),hideTrace($w[h +   368])=(s1[h +   368]),rgb($w[h +   369])=(s0[h +   369][0],s0[h +   369][1],s0[h +   369][2],s0[h +   369][3]),hideTrace($w[h +   369])=(s1[h +   369]),rgb($w[h +   370])=(s0[h +   370][0],s0[h +   370][1],s0[h +   370][2],s0[h +   370][3]),hideTrace($w[h +   370])=(s1[h +   370]),rgb($w[h +   371])=(s0[h +   371][0],s0[h +   371][1],s0[h +   371][2],s0[h +   371][3]),hideTrace($w[h +   371])=(s1[h +   371]),rgb($w[h +   372])=(s0[h +   372][0],s0[h +   372][1],s0[h +   372][2],s0[h +   372][3]),hideTrace($w[h +   372])=(s1[h +   372]),rgb($w[h +   373])=(s0[h +   373][0],s0[h +   373][1],s0[h +   373][2],s0[h +   373][3]),hideTrace($w[h +   373])=(s1[h +   373]),rgb($w[h +   374])=(s0[h +   374][0],s0[h +   374][1],s0[h +   374][2],s0[h +   374][3]),hideTrace($w[h +   374])=(s1[h +   374]),rgb($w[h +   375])=(s0[h +   375][0],s0[h +   375][1],s0[h +   375][2],s0[h +   375][3]),hideTrace($w[h +   375])=(s1[h +   375]) \
				,rgb($w[h +   376])=(s0[h +   376][0],s0[h +   376][1],s0[h +   376][2],s0[h +   376][3]),hideTrace($w[h +   376])=(s1[h +   376]),rgb($w[h +   377])=(s0[h +   377][0],s0[h +   377][1],s0[h +   377][2],s0[h +   377][3]),hideTrace($w[h +   377])=(s1[h +   377]),rgb($w[h +   378])=(s0[h +   378][0],s0[h +   378][1],s0[h +   378][2],s0[h +   378][3]),hideTrace($w[h +   378])=(s1[h +   378]),rgb($w[h +   379])=(s0[h +   379][0],s0[h +   379][1],s0[h +   379][2],s0[h +   379][3]),hideTrace($w[h +   379])=(s1[h +   379]),rgb($w[h +   380])=(s0[h +   380][0],s0[h +   380][1],s0[h +   380][2],s0[h +   380][3]),hideTrace($w[h +   380])=(s1[h +   380]),rgb($w[h +   381])=(s0[h +   381][0],s0[h +   381][1],s0[h +   381][2],s0[h +   381][3]),hideTrace($w[h +   381])=(s1[h +   381]),rgb($w[h +   382])=(s0[h +   382][0],s0[h +   382][1],s0[h +   382][2],s0[h +   382][3]),hideTrace($w[h +   382])=(s1[h +   382]),rgb($w[h +   383])=(s0[h +   383][0],s0[h +   383][1],s0[h +   383][2],s0[h +   383][3]),hideTrace($w[h +   383])=(s1[h +   383]) \
				,rgb($w[h +   384])=(s0[h +   384][0],s0[h +   384][1],s0[h +   384][2],s0[h +   384][3]),hideTrace($w[h +   384])=(s1[h +   384]),rgb($w[h +   385])=(s0[h +   385][0],s0[h +   385][1],s0[h +   385][2],s0[h +   385][3]),hideTrace($w[h +   385])=(s1[h +   385]),rgb($w[h +   386])=(s0[h +   386][0],s0[h +   386][1],s0[h +   386][2],s0[h +   386][3]),hideTrace($w[h +   386])=(s1[h +   386]),rgb($w[h +   387])=(s0[h +   387][0],s0[h +   387][1],s0[h +   387][2],s0[h +   387][3]),hideTrace($w[h +   387])=(s1[h +   387]),rgb($w[h +   388])=(s0[h +   388][0],s0[h +   388][1],s0[h +   388][2],s0[h +   388][3]),hideTrace($w[h +   388])=(s1[h +   388]),rgb($w[h +   389])=(s0[h +   389][0],s0[h +   389][1],s0[h +   389][2],s0[h +   389][3]),hideTrace($w[h +   389])=(s1[h +   389]),rgb($w[h +   390])=(s0[h +   390][0],s0[h +   390][1],s0[h +   390][2],s0[h +   390][3]),hideTrace($w[h +   390])=(s1[h +   390]),rgb($w[h +   391])=(s0[h +   391][0],s0[h +   391][1],s0[h +   391][2],s0[h +   391][3]),hideTrace($w[h +   391])=(s1[h +   391]) \
				,rgb($w[h +   392])=(s0[h +   392][0],s0[h +   392][1],s0[h +   392][2],s0[h +   392][3]),hideTrace($w[h +   392])=(s1[h +   392]),rgb($w[h +   393])=(s0[h +   393][0],s0[h +   393][1],s0[h +   393][2],s0[h +   393][3]),hideTrace($w[h +   393])=(s1[h +   393]),rgb($w[h +   394])=(s0[h +   394][0],s0[h +   394][1],s0[h +   394][2],s0[h +   394][3]),hideTrace($w[h +   394])=(s1[h +   394]),rgb($w[h +   395])=(s0[h +   395][0],s0[h +   395][1],s0[h +   395][2],s0[h +   395][3]),hideTrace($w[h +   395])=(s1[h +   395]),rgb($w[h +   396])=(s0[h +   396][0],s0[h +   396][1],s0[h +   396][2],s0[h +   396][3]),hideTrace($w[h +   396])=(s1[h +   396]),rgb($w[h +   397])=(s0[h +   397][0],s0[h +   397][1],s0[h +   397][2],s0[h +   397][3]),hideTrace($w[h +   397])=(s1[h +   397]),rgb($w[h +   398])=(s0[h +   398][0],s0[h +   398][1],s0[h +   398][2],s0[h +   398][3]),hideTrace($w[h +   398])=(s1[h +   398]),rgb($w[h +   399])=(s0[h +   399][0],s0[h +   399][1],s0[h +   399][2],s0[h +   399][3]),hideTrace($w[h +   399])=(s1[h +   399]) \
				,rgb($w[h +   400])=(s0[h +   400][0],s0[h +   400][1],s0[h +   400][2],s0[h +   400][3]),hideTrace($w[h +   400])=(s1[h +   400]),rgb($w[h +   401])=(s0[h +   401][0],s0[h +   401][1],s0[h +   401][2],s0[h +   401][3]),hideTrace($w[h +   401])=(s1[h +   401]),rgb($w[h +   402])=(s0[h +   402][0],s0[h +   402][1],s0[h +   402][2],s0[h +   402][3]),hideTrace($w[h +   402])=(s1[h +   402]),rgb($w[h +   403])=(s0[h +   403][0],s0[h +   403][1],s0[h +   403][2],s0[h +   403][3]),hideTrace($w[h +   403])=(s1[h +   403]),rgb($w[h +   404])=(s0[h +   404][0],s0[h +   404][1],s0[h +   404][2],s0[h +   404][3]),hideTrace($w[h +   404])=(s1[h +   404]),rgb($w[h +   405])=(s0[h +   405][0],s0[h +   405][1],s0[h +   405][2],s0[h +   405][3]),hideTrace($w[h +   405])=(s1[h +   405]),rgb($w[h +   406])=(s0[h +   406][0],s0[h +   406][1],s0[h +   406][2],s0[h +   406][3]),hideTrace($w[h +   406])=(s1[h +   406]),rgb($w[h +   407])=(s0[h +   407][0],s0[h +   407][1],s0[h +   407][2],s0[h +   407][3]),hideTrace($w[h +   407])=(s1[h +   407]) \
				,rgb($w[h +   408])=(s0[h +   408][0],s0[h +   408][1],s0[h +   408][2],s0[h +   408][3]),hideTrace($w[h +   408])=(s1[h +   408]),rgb($w[h +   409])=(s0[h +   409][0],s0[h +   409][1],s0[h +   409][2],s0[h +   409][3]),hideTrace($w[h +   409])=(s1[h +   409]),rgb($w[h +   410])=(s0[h +   410][0],s0[h +   410][1],s0[h +   410][2],s0[h +   410][3]),hideTrace($w[h +   410])=(s1[h +   410]),rgb($w[h +   411])=(s0[h +   411][0],s0[h +   411][1],s0[h +   411][2],s0[h +   411][3]),hideTrace($w[h +   411])=(s1[h +   411]),rgb($w[h +   412])=(s0[h +   412][0],s0[h +   412][1],s0[h +   412][2],s0[h +   412][3]),hideTrace($w[h +   412])=(s1[h +   412]),rgb($w[h +   413])=(s0[h +   413][0],s0[h +   413][1],s0[h +   413][2],s0[h +   413][3]),hideTrace($w[h +   413])=(s1[h +   413]),rgb($w[h +   414])=(s0[h +   414][0],s0[h +   414][1],s0[h +   414][2],s0[h +   414][3]),hideTrace($w[h +   414])=(s1[h +   414]),rgb($w[h +   415])=(s0[h +   415][0],s0[h +   415][1],s0[h +   415][2],s0[h +   415][3]),hideTrace($w[h +   415])=(s1[h +   415]) \
				,rgb($w[h +   416])=(s0[h +   416][0],s0[h +   416][1],s0[h +   416][2],s0[h +   416][3]),hideTrace($w[h +   416])=(s1[h +   416]),rgb($w[h +   417])=(s0[h +   417][0],s0[h +   417][1],s0[h +   417][2],s0[h +   417][3]),hideTrace($w[h +   417])=(s1[h +   417]),rgb($w[h +   418])=(s0[h +   418][0],s0[h +   418][1],s0[h +   418][2],s0[h +   418][3]),hideTrace($w[h +   418])=(s1[h +   418]),rgb($w[h +   419])=(s0[h +   419][0],s0[h +   419][1],s0[h +   419][2],s0[h +   419][3]),hideTrace($w[h +   419])=(s1[h +   419]),rgb($w[h +   420])=(s0[h +   420][0],s0[h +   420][1],s0[h +   420][2],s0[h +   420][3]),hideTrace($w[h +   420])=(s1[h +   420]),rgb($w[h +   421])=(s0[h +   421][0],s0[h +   421][1],s0[h +   421][2],s0[h +   421][3]),hideTrace($w[h +   421])=(s1[h +   421]),rgb($w[h +   422])=(s0[h +   422][0],s0[h +   422][1],s0[h +   422][2],s0[h +   422][3]),hideTrace($w[h +   422])=(s1[h +   422]),rgb($w[h +   423])=(s0[h +   423][0],s0[h +   423][1],s0[h +   423][2],s0[h +   423][3]),hideTrace($w[h +   423])=(s1[h +   423]) \
				,rgb($w[h +   424])=(s0[h +   424][0],s0[h +   424][1],s0[h +   424][2],s0[h +   424][3]),hideTrace($w[h +   424])=(s1[h +   424]),rgb($w[h +   425])=(s0[h +   425][0],s0[h +   425][1],s0[h +   425][2],s0[h +   425][3]),hideTrace($w[h +   425])=(s1[h +   425]),rgb($w[h +   426])=(s0[h +   426][0],s0[h +   426][1],s0[h +   426][2],s0[h +   426][3]),hideTrace($w[h +   426])=(s1[h +   426]),rgb($w[h +   427])=(s0[h +   427][0],s0[h +   427][1],s0[h +   427][2],s0[h +   427][3]),hideTrace($w[h +   427])=(s1[h +   427]),rgb($w[h +   428])=(s0[h +   428][0],s0[h +   428][1],s0[h +   428][2],s0[h +   428][3]),hideTrace($w[h +   428])=(s1[h +   428]),rgb($w[h +   429])=(s0[h +   429][0],s0[h +   429][1],s0[h +   429][2],s0[h +   429][3]),hideTrace($w[h +   429])=(s1[h +   429]),rgb($w[h +   430])=(s0[h +   430][0],s0[h +   430][1],s0[h +   430][2],s0[h +   430][3]),hideTrace($w[h +   430])=(s1[h +   430]),rgb($w[h +   431])=(s0[h +   431][0],s0[h +   431][1],s0[h +   431][2],s0[h +   431][3]),hideTrace($w[h +   431])=(s1[h +   431]) \
				,rgb($w[h +   432])=(s0[h +   432][0],s0[h +   432][1],s0[h +   432][2],s0[h +   432][3]),hideTrace($w[h +   432])=(s1[h +   432]),rgb($w[h +   433])=(s0[h +   433][0],s0[h +   433][1],s0[h +   433][2],s0[h +   433][3]),hideTrace($w[h +   433])=(s1[h +   433]),rgb($w[h +   434])=(s0[h +   434][0],s0[h +   434][1],s0[h +   434][2],s0[h +   434][3]),hideTrace($w[h +   434])=(s1[h +   434]),rgb($w[h +   435])=(s0[h +   435][0],s0[h +   435][1],s0[h +   435][2],s0[h +   435][3]),hideTrace($w[h +   435])=(s1[h +   435]),rgb($w[h +   436])=(s0[h +   436][0],s0[h +   436][1],s0[h +   436][2],s0[h +   436][3]),hideTrace($w[h +   436])=(s1[h +   436]),rgb($w[h +   437])=(s0[h +   437][0],s0[h +   437][1],s0[h +   437][2],s0[h +   437][3]),hideTrace($w[h +   437])=(s1[h +   437]),rgb($w[h +   438])=(s0[h +   438][0],s0[h +   438][1],s0[h +   438][2],s0[h +   438][3]),hideTrace($w[h +   438])=(s1[h +   438]),rgb($w[h +   439])=(s0[h +   439][0],s0[h +   439][1],s0[h +   439][2],s0[h +   439][3]),hideTrace($w[h +   439])=(s1[h +   439]) \
				,rgb($w[h +   440])=(s0[h +   440][0],s0[h +   440][1],s0[h +   440][2],s0[h +   440][3]),hideTrace($w[h +   440])=(s1[h +   440]),rgb($w[h +   441])=(s0[h +   441][0],s0[h +   441][1],s0[h +   441][2],s0[h +   441][3]),hideTrace($w[h +   441])=(s1[h +   441]),rgb($w[h +   442])=(s0[h +   442][0],s0[h +   442][1],s0[h +   442][2],s0[h +   442][3]),hideTrace($w[h +   442])=(s1[h +   442]),rgb($w[h +   443])=(s0[h +   443][0],s0[h +   443][1],s0[h +   443][2],s0[h +   443][3]),hideTrace($w[h +   443])=(s1[h +   443]),rgb($w[h +   444])=(s0[h +   444][0],s0[h +   444][1],s0[h +   444][2],s0[h +   444][3]),hideTrace($w[h +   444])=(s1[h +   444]),rgb($w[h +   445])=(s0[h +   445][0],s0[h +   445][1],s0[h +   445][2],s0[h +   445][3]),hideTrace($w[h +   445])=(s1[h +   445]),rgb($w[h +   446])=(s0[h +   446][0],s0[h +   446][1],s0[h +   446][2],s0[h +   446][3]),hideTrace($w[h +   446])=(s1[h +   446]),rgb($w[h +   447])=(s0[h +   447][0],s0[h +   447][1],s0[h +   447][2],s0[h +   447][3]),hideTrace($w[h +   447])=(s1[h +   447]) \
				,rgb($w[h +   448])=(s0[h +   448][0],s0[h +   448][1],s0[h +   448][2],s0[h +   448][3]),hideTrace($w[h +   448])=(s1[h +   448]),rgb($w[h +   449])=(s0[h +   449][0],s0[h +   449][1],s0[h +   449][2],s0[h +   449][3]),hideTrace($w[h +   449])=(s1[h +   449]),rgb($w[h +   450])=(s0[h +   450][0],s0[h +   450][1],s0[h +   450][2],s0[h +   450][3]),hideTrace($w[h +   450])=(s1[h +   450]),rgb($w[h +   451])=(s0[h +   451][0],s0[h +   451][1],s0[h +   451][2],s0[h +   451][3]),hideTrace($w[h +   451])=(s1[h +   451]),rgb($w[h +   452])=(s0[h +   452][0],s0[h +   452][1],s0[h +   452][2],s0[h +   452][3]),hideTrace($w[h +   452])=(s1[h +   452]),rgb($w[h +   453])=(s0[h +   453][0],s0[h +   453][1],s0[h +   453][2],s0[h +   453][3]),hideTrace($w[h +   453])=(s1[h +   453]),rgb($w[h +   454])=(s0[h +   454][0],s0[h +   454][1],s0[h +   454][2],s0[h +   454][3]),hideTrace($w[h +   454])=(s1[h +   454]),rgb($w[h +   455])=(s0[h +   455][0],s0[h +   455][1],s0[h +   455][2],s0[h +   455][3]),hideTrace($w[h +   455])=(s1[h +   455]) \
				,rgb($w[h +   456])=(s0[h +   456][0],s0[h +   456][1],s0[h +   456][2],s0[h +   456][3]),hideTrace($w[h +   456])=(s1[h +   456]),rgb($w[h +   457])=(s0[h +   457][0],s0[h +   457][1],s0[h +   457][2],s0[h +   457][3]),hideTrace($w[h +   457])=(s1[h +   457]),rgb($w[h +   458])=(s0[h +   458][0],s0[h +   458][1],s0[h +   458][2],s0[h +   458][3]),hideTrace($w[h +   458])=(s1[h +   458]),rgb($w[h +   459])=(s0[h +   459][0],s0[h +   459][1],s0[h +   459][2],s0[h +   459][3]),hideTrace($w[h +   459])=(s1[h +   459]),rgb($w[h +   460])=(s0[h +   460][0],s0[h +   460][1],s0[h +   460][2],s0[h +   460][3]),hideTrace($w[h +   460])=(s1[h +   460]),rgb($w[h +   461])=(s0[h +   461][0],s0[h +   461][1],s0[h +   461][2],s0[h +   461][3]),hideTrace($w[h +   461])=(s1[h +   461]),rgb($w[h +   462])=(s0[h +   462][0],s0[h +   462][1],s0[h +   462][2],s0[h +   462][3]),hideTrace($w[h +   462])=(s1[h +   462]),rgb($w[h +   463])=(s0[h +   463][0],s0[h +   463][1],s0[h +   463][2],s0[h +   463][3]),hideTrace($w[h +   463])=(s1[h +   463]) \
				,rgb($w[h +   464])=(s0[h +   464][0],s0[h +   464][1],s0[h +   464][2],s0[h +   464][3]),hideTrace($w[h +   464])=(s1[h +   464]),rgb($w[h +   465])=(s0[h +   465][0],s0[h +   465][1],s0[h +   465][2],s0[h +   465][3]),hideTrace($w[h +   465])=(s1[h +   465]),rgb($w[h +   466])=(s0[h +   466][0],s0[h +   466][1],s0[h +   466][2],s0[h +   466][3]),hideTrace($w[h +   466])=(s1[h +   466]),rgb($w[h +   467])=(s0[h +   467][0],s0[h +   467][1],s0[h +   467][2],s0[h +   467][3]),hideTrace($w[h +   467])=(s1[h +   467]),rgb($w[h +   468])=(s0[h +   468][0],s0[h +   468][1],s0[h +   468][2],s0[h +   468][3]),hideTrace($w[h +   468])=(s1[h +   468]),rgb($w[h +   469])=(s0[h +   469][0],s0[h +   469][1],s0[h +   469][2],s0[h +   469][3]),hideTrace($w[h +   469])=(s1[h +   469]),rgb($w[h +   470])=(s0[h +   470][0],s0[h +   470][1],s0[h +   470][2],s0[h +   470][3]),hideTrace($w[h +   470])=(s1[h +   470]),rgb($w[h +   471])=(s0[h +   471][0],s0[h +   471][1],s0[h +   471][2],s0[h +   471][3]),hideTrace($w[h +   471])=(s1[h +   471]) \
				,rgb($w[h +   472])=(s0[h +   472][0],s0[h +   472][1],s0[h +   472][2],s0[h +   472][3]),hideTrace($w[h +   472])=(s1[h +   472]),rgb($w[h +   473])=(s0[h +   473][0],s0[h +   473][1],s0[h +   473][2],s0[h +   473][3]),hideTrace($w[h +   473])=(s1[h +   473]),rgb($w[h +   474])=(s0[h +   474][0],s0[h +   474][1],s0[h +   474][2],s0[h +   474][3]),hideTrace($w[h +   474])=(s1[h +   474]),rgb($w[h +   475])=(s0[h +   475][0],s0[h +   475][1],s0[h +   475][2],s0[h +   475][3]),hideTrace($w[h +   475])=(s1[h +   475]),rgb($w[h +   476])=(s0[h +   476][0],s0[h +   476][1],s0[h +   476][2],s0[h +   476][3]),hideTrace($w[h +   476])=(s1[h +   476]),rgb($w[h +   477])=(s0[h +   477][0],s0[h +   477][1],s0[h +   477][2],s0[h +   477][3]),hideTrace($w[h +   477])=(s1[h +   477]),rgb($w[h +   478])=(s0[h +   478][0],s0[h +   478][1],s0[h +   478][2],s0[h +   478][3]),hideTrace($w[h +   478])=(s1[h +   478]),rgb($w[h +   479])=(s0[h +   479][0],s0[h +   479][1],s0[h +   479][2],s0[h +   479][3]),hideTrace($w[h +   479])=(s1[h +   479]) \
				,rgb($w[h +   480])=(s0[h +   480][0],s0[h +   480][1],s0[h +   480][2],s0[h +   480][3]),hideTrace($w[h +   480])=(s1[h +   480]),rgb($w[h +   481])=(s0[h +   481][0],s0[h +   481][1],s0[h +   481][2],s0[h +   481][3]),hideTrace($w[h +   481])=(s1[h +   481]),rgb($w[h +   482])=(s0[h +   482][0],s0[h +   482][1],s0[h +   482][2],s0[h +   482][3]),hideTrace($w[h +   482])=(s1[h +   482]),rgb($w[h +   483])=(s0[h +   483][0],s0[h +   483][1],s0[h +   483][2],s0[h +   483][3]),hideTrace($w[h +   483])=(s1[h +   483]),rgb($w[h +   484])=(s0[h +   484][0],s0[h +   484][1],s0[h +   484][2],s0[h +   484][3]),hideTrace($w[h +   484])=(s1[h +   484]),rgb($w[h +   485])=(s0[h +   485][0],s0[h +   485][1],s0[h +   485][2],s0[h +   485][3]),hideTrace($w[h +   485])=(s1[h +   485]),rgb($w[h +   486])=(s0[h +   486][0],s0[h +   486][1],s0[h +   486][2],s0[h +   486][3]),hideTrace($w[h +   486])=(s1[h +   486]),rgb($w[h +   487])=(s0[h +   487][0],s0[h +   487][1],s0[h +   487][2],s0[h +   487][3]),hideTrace($w[h +   487])=(s1[h +   487]) \
				,rgb($w[h +   488])=(s0[h +   488][0],s0[h +   488][1],s0[h +   488][2],s0[h +   488][3]),hideTrace($w[h +   488])=(s1[h +   488]),rgb($w[h +   489])=(s0[h +   489][0],s0[h +   489][1],s0[h +   489][2],s0[h +   489][3]),hideTrace($w[h +   489])=(s1[h +   489]),rgb($w[h +   490])=(s0[h +   490][0],s0[h +   490][1],s0[h +   490][2],s0[h +   490][3]),hideTrace($w[h +   490])=(s1[h +   490]),rgb($w[h +   491])=(s0[h +   491][0],s0[h +   491][1],s0[h +   491][2],s0[h +   491][3]),hideTrace($w[h +   491])=(s1[h +   491]),rgb($w[h +   492])=(s0[h +   492][0],s0[h +   492][1],s0[h +   492][2],s0[h +   492][3]),hideTrace($w[h +   492])=(s1[h +   492]),rgb($w[h +   493])=(s0[h +   493][0],s0[h +   493][1],s0[h +   493][2],s0[h +   493][3]),hideTrace($w[h +   493])=(s1[h +   493]),rgb($w[h +   494])=(s0[h +   494][0],s0[h +   494][1],s0[h +   494][2],s0[h +   494][3]),hideTrace($w[h +   494])=(s1[h +   494]),rgb($w[h +   495])=(s0[h +   495][0],s0[h +   495][1],s0[h +   495][2],s0[h +   495][3]),hideTrace($w[h +   495])=(s1[h +   495]) \
				,rgb($w[h +   496])=(s0[h +   496][0],s0[h +   496][1],s0[h +   496][2],s0[h +   496][3]),hideTrace($w[h +   496])=(s1[h +   496]),rgb($w[h +   497])=(s0[h +   497][0],s0[h +   497][1],s0[h +   497][2],s0[h +   497][3]),hideTrace($w[h +   497])=(s1[h +   497]),rgb($w[h +   498])=(s0[h +   498][0],s0[h +   498][1],s0[h +   498][2],s0[h +   498][3]),hideTrace($w[h +   498])=(s1[h +   498]),rgb($w[h +   499])=(s0[h +   499][0],s0[h +   499][1],s0[h +   499][2],s0[h +   499][3]),hideTrace($w[h +   499])=(s1[h +   499]),rgb($w[h +   500])=(s0[h +   500][0],s0[h +   500][1],s0[h +   500][2],s0[h +   500][3]),hideTrace($w[h +   500])=(s1[h +   500]),rgb($w[h +   501])=(s0[h +   501][0],s0[h +   501][1],s0[h +   501][2],s0[h +   501][3]),hideTrace($w[h +   501])=(s1[h +   501]),rgb($w[h +   502])=(s0[h +   502][0],s0[h +   502][1],s0[h +   502][2],s0[h +   502][3]),hideTrace($w[h +   502])=(s1[h +   502]),rgb($w[h +   503])=(s0[h +   503][0],s0[h +   503][1],s0[h +   503][2],s0[h +   503][3]),hideTrace($w[h +   503])=(s1[h +   503]) \
				,rgb($w[h +   504])=(s0[h +   504][0],s0[h +   504][1],s0[h +   504][2],s0[h +   504][3]),hideTrace($w[h +   504])=(s1[h +   504]),rgb($w[h +   505])=(s0[h +   505][0],s0[h +   505][1],s0[h +   505][2],s0[h +   505][3]),hideTrace($w[h +   505])=(s1[h +   505]),rgb($w[h +   506])=(s0[h +   506][0],s0[h +   506][1],s0[h +   506][2],s0[h +   506][3]),hideTrace($w[h +   506])=(s1[h +   506]),rgb($w[h +   507])=(s0[h +   507][0],s0[h +   507][1],s0[h +   507][2],s0[h +   507][3]),hideTrace($w[h +   507])=(s1[h +   507]),rgb($w[h +   508])=(s0[h +   508][0],s0[h +   508][1],s0[h +   508][2],s0[h +   508][3]),hideTrace($w[h +   508])=(s1[h +   508]),rgb($w[h +   509])=(s0[h +   509][0],s0[h +   509][1],s0[h +   509][2],s0[h +   509][3]),hideTrace($w[h +   509])=(s1[h +   509]),rgb($w[h +   510])=(s0[h +   510][0],s0[h +   510][1],s0[h +   510][2],s0[h +   510][3]),hideTrace($w[h +   510])=(s1[h +   510]),rgb($w[h +   511])=(s0[h +   511][0],s0[h +   511][1],s0[h +   511][2],s0[h +   511][3]),hideTrace($w[h +   511])=(s1[h +   511])
				break
			case 256:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31]) \
				,rgb($w[h +    32])=(s0[h +    32][0],s0[h +    32][1],s0[h +    32][2],s0[h +    32][3]),hideTrace($w[h +    32])=(s1[h +    32]),rgb($w[h +    33])=(s0[h +    33][0],s0[h +    33][1],s0[h +    33][2],s0[h +    33][3]),hideTrace($w[h +    33])=(s1[h +    33]),rgb($w[h +    34])=(s0[h +    34][0],s0[h +    34][1],s0[h +    34][2],s0[h +    34][3]),hideTrace($w[h +    34])=(s1[h +    34]),rgb($w[h +    35])=(s0[h +    35][0],s0[h +    35][1],s0[h +    35][2],s0[h +    35][3]),hideTrace($w[h +    35])=(s1[h +    35]),rgb($w[h +    36])=(s0[h +    36][0],s0[h +    36][1],s0[h +    36][2],s0[h +    36][3]),hideTrace($w[h +    36])=(s1[h +    36]),rgb($w[h +    37])=(s0[h +    37][0],s0[h +    37][1],s0[h +    37][2],s0[h +    37][3]),hideTrace($w[h +    37])=(s1[h +    37]),rgb($w[h +    38])=(s0[h +    38][0],s0[h +    38][1],s0[h +    38][2],s0[h +    38][3]),hideTrace($w[h +    38])=(s1[h +    38]),rgb($w[h +    39])=(s0[h +    39][0],s0[h +    39][1],s0[h +    39][2],s0[h +    39][3]),hideTrace($w[h +    39])=(s1[h +    39]) \
				,rgb($w[h +    40])=(s0[h +    40][0],s0[h +    40][1],s0[h +    40][2],s0[h +    40][3]),hideTrace($w[h +    40])=(s1[h +    40]),rgb($w[h +    41])=(s0[h +    41][0],s0[h +    41][1],s0[h +    41][2],s0[h +    41][3]),hideTrace($w[h +    41])=(s1[h +    41]),rgb($w[h +    42])=(s0[h +    42][0],s0[h +    42][1],s0[h +    42][2],s0[h +    42][3]),hideTrace($w[h +    42])=(s1[h +    42]),rgb($w[h +    43])=(s0[h +    43][0],s0[h +    43][1],s0[h +    43][2],s0[h +    43][3]),hideTrace($w[h +    43])=(s1[h +    43]),rgb($w[h +    44])=(s0[h +    44][0],s0[h +    44][1],s0[h +    44][2],s0[h +    44][3]),hideTrace($w[h +    44])=(s1[h +    44]),rgb($w[h +    45])=(s0[h +    45][0],s0[h +    45][1],s0[h +    45][2],s0[h +    45][3]),hideTrace($w[h +    45])=(s1[h +    45]),rgb($w[h +    46])=(s0[h +    46][0],s0[h +    46][1],s0[h +    46][2],s0[h +    46][3]),hideTrace($w[h +    46])=(s1[h +    46]),rgb($w[h +    47])=(s0[h +    47][0],s0[h +    47][1],s0[h +    47][2],s0[h +    47][3]),hideTrace($w[h +    47])=(s1[h +    47]) \
				,rgb($w[h +    48])=(s0[h +    48][0],s0[h +    48][1],s0[h +    48][2],s0[h +    48][3]),hideTrace($w[h +    48])=(s1[h +    48]),rgb($w[h +    49])=(s0[h +    49][0],s0[h +    49][1],s0[h +    49][2],s0[h +    49][3]),hideTrace($w[h +    49])=(s1[h +    49]),rgb($w[h +    50])=(s0[h +    50][0],s0[h +    50][1],s0[h +    50][2],s0[h +    50][3]),hideTrace($w[h +    50])=(s1[h +    50]),rgb($w[h +    51])=(s0[h +    51][0],s0[h +    51][1],s0[h +    51][2],s0[h +    51][3]),hideTrace($w[h +    51])=(s1[h +    51]),rgb($w[h +    52])=(s0[h +    52][0],s0[h +    52][1],s0[h +    52][2],s0[h +    52][3]),hideTrace($w[h +    52])=(s1[h +    52]),rgb($w[h +    53])=(s0[h +    53][0],s0[h +    53][1],s0[h +    53][2],s0[h +    53][3]),hideTrace($w[h +    53])=(s1[h +    53]),rgb($w[h +    54])=(s0[h +    54][0],s0[h +    54][1],s0[h +    54][2],s0[h +    54][3]),hideTrace($w[h +    54])=(s1[h +    54]),rgb($w[h +    55])=(s0[h +    55][0],s0[h +    55][1],s0[h +    55][2],s0[h +    55][3]),hideTrace($w[h +    55])=(s1[h +    55]) \
				,rgb($w[h +    56])=(s0[h +    56][0],s0[h +    56][1],s0[h +    56][2],s0[h +    56][3]),hideTrace($w[h +    56])=(s1[h +    56]),rgb($w[h +    57])=(s0[h +    57][0],s0[h +    57][1],s0[h +    57][2],s0[h +    57][3]),hideTrace($w[h +    57])=(s1[h +    57]),rgb($w[h +    58])=(s0[h +    58][0],s0[h +    58][1],s0[h +    58][2],s0[h +    58][3]),hideTrace($w[h +    58])=(s1[h +    58]),rgb($w[h +    59])=(s0[h +    59][0],s0[h +    59][1],s0[h +    59][2],s0[h +    59][3]),hideTrace($w[h +    59])=(s1[h +    59]),rgb($w[h +    60])=(s0[h +    60][0],s0[h +    60][1],s0[h +    60][2],s0[h +    60][3]),hideTrace($w[h +    60])=(s1[h +    60]),rgb($w[h +    61])=(s0[h +    61][0],s0[h +    61][1],s0[h +    61][2],s0[h +    61][3]),hideTrace($w[h +    61])=(s1[h +    61]),rgb($w[h +    62])=(s0[h +    62][0],s0[h +    62][1],s0[h +    62][2],s0[h +    62][3]),hideTrace($w[h +    62])=(s1[h +    62]),rgb($w[h +    63])=(s0[h +    63][0],s0[h +    63][1],s0[h +    63][2],s0[h +    63][3]),hideTrace($w[h +    63])=(s1[h +    63]) \
				,rgb($w[h +    64])=(s0[h +    64][0],s0[h +    64][1],s0[h +    64][2],s0[h +    64][3]),hideTrace($w[h +    64])=(s1[h +    64]),rgb($w[h +    65])=(s0[h +    65][0],s0[h +    65][1],s0[h +    65][2],s0[h +    65][3]),hideTrace($w[h +    65])=(s1[h +    65]),rgb($w[h +    66])=(s0[h +    66][0],s0[h +    66][1],s0[h +    66][2],s0[h +    66][3]),hideTrace($w[h +    66])=(s1[h +    66]),rgb($w[h +    67])=(s0[h +    67][0],s0[h +    67][1],s0[h +    67][2],s0[h +    67][3]),hideTrace($w[h +    67])=(s1[h +    67]),rgb($w[h +    68])=(s0[h +    68][0],s0[h +    68][1],s0[h +    68][2],s0[h +    68][3]),hideTrace($w[h +    68])=(s1[h +    68]),rgb($w[h +    69])=(s0[h +    69][0],s0[h +    69][1],s0[h +    69][2],s0[h +    69][3]),hideTrace($w[h +    69])=(s1[h +    69]),rgb($w[h +    70])=(s0[h +    70][0],s0[h +    70][1],s0[h +    70][2],s0[h +    70][3]),hideTrace($w[h +    70])=(s1[h +    70]),rgb($w[h +    71])=(s0[h +    71][0],s0[h +    71][1],s0[h +    71][2],s0[h +    71][3]),hideTrace($w[h +    71])=(s1[h +    71]) \
				,rgb($w[h +    72])=(s0[h +    72][0],s0[h +    72][1],s0[h +    72][2],s0[h +    72][3]),hideTrace($w[h +    72])=(s1[h +    72]),rgb($w[h +    73])=(s0[h +    73][0],s0[h +    73][1],s0[h +    73][2],s0[h +    73][3]),hideTrace($w[h +    73])=(s1[h +    73]),rgb($w[h +    74])=(s0[h +    74][0],s0[h +    74][1],s0[h +    74][2],s0[h +    74][3]),hideTrace($w[h +    74])=(s1[h +    74]),rgb($w[h +    75])=(s0[h +    75][0],s0[h +    75][1],s0[h +    75][2],s0[h +    75][3]),hideTrace($w[h +    75])=(s1[h +    75]),rgb($w[h +    76])=(s0[h +    76][0],s0[h +    76][1],s0[h +    76][2],s0[h +    76][3]),hideTrace($w[h +    76])=(s1[h +    76]),rgb($w[h +    77])=(s0[h +    77][0],s0[h +    77][1],s0[h +    77][2],s0[h +    77][3]),hideTrace($w[h +    77])=(s1[h +    77]),rgb($w[h +    78])=(s0[h +    78][0],s0[h +    78][1],s0[h +    78][2],s0[h +    78][3]),hideTrace($w[h +    78])=(s1[h +    78]),rgb($w[h +    79])=(s0[h +    79][0],s0[h +    79][1],s0[h +    79][2],s0[h +    79][3]),hideTrace($w[h +    79])=(s1[h +    79]) \
				,rgb($w[h +    80])=(s0[h +    80][0],s0[h +    80][1],s0[h +    80][2],s0[h +    80][3]),hideTrace($w[h +    80])=(s1[h +    80]),rgb($w[h +    81])=(s0[h +    81][0],s0[h +    81][1],s0[h +    81][2],s0[h +    81][3]),hideTrace($w[h +    81])=(s1[h +    81]),rgb($w[h +    82])=(s0[h +    82][0],s0[h +    82][1],s0[h +    82][2],s0[h +    82][3]),hideTrace($w[h +    82])=(s1[h +    82]),rgb($w[h +    83])=(s0[h +    83][0],s0[h +    83][1],s0[h +    83][2],s0[h +    83][3]),hideTrace($w[h +    83])=(s1[h +    83]),rgb($w[h +    84])=(s0[h +    84][0],s0[h +    84][1],s0[h +    84][2],s0[h +    84][3]),hideTrace($w[h +    84])=(s1[h +    84]),rgb($w[h +    85])=(s0[h +    85][0],s0[h +    85][1],s0[h +    85][2],s0[h +    85][3]),hideTrace($w[h +    85])=(s1[h +    85]),rgb($w[h +    86])=(s0[h +    86][0],s0[h +    86][1],s0[h +    86][2],s0[h +    86][3]),hideTrace($w[h +    86])=(s1[h +    86]),rgb($w[h +    87])=(s0[h +    87][0],s0[h +    87][1],s0[h +    87][2],s0[h +    87][3]),hideTrace($w[h +    87])=(s1[h +    87]) \
				,rgb($w[h +    88])=(s0[h +    88][0],s0[h +    88][1],s0[h +    88][2],s0[h +    88][3]),hideTrace($w[h +    88])=(s1[h +    88]),rgb($w[h +    89])=(s0[h +    89][0],s0[h +    89][1],s0[h +    89][2],s0[h +    89][3]),hideTrace($w[h +    89])=(s1[h +    89]),rgb($w[h +    90])=(s0[h +    90][0],s0[h +    90][1],s0[h +    90][2],s0[h +    90][3]),hideTrace($w[h +    90])=(s1[h +    90]),rgb($w[h +    91])=(s0[h +    91][0],s0[h +    91][1],s0[h +    91][2],s0[h +    91][3]),hideTrace($w[h +    91])=(s1[h +    91]),rgb($w[h +    92])=(s0[h +    92][0],s0[h +    92][1],s0[h +    92][2],s0[h +    92][3]),hideTrace($w[h +    92])=(s1[h +    92]),rgb($w[h +    93])=(s0[h +    93][0],s0[h +    93][1],s0[h +    93][2],s0[h +    93][3]),hideTrace($w[h +    93])=(s1[h +    93]),rgb($w[h +    94])=(s0[h +    94][0],s0[h +    94][1],s0[h +    94][2],s0[h +    94][3]),hideTrace($w[h +    94])=(s1[h +    94]),rgb($w[h +    95])=(s0[h +    95][0],s0[h +    95][1],s0[h +    95][2],s0[h +    95][3]),hideTrace($w[h +    95])=(s1[h +    95]) \
				,rgb($w[h +    96])=(s0[h +    96][0],s0[h +    96][1],s0[h +    96][2],s0[h +    96][3]),hideTrace($w[h +    96])=(s1[h +    96]),rgb($w[h +    97])=(s0[h +    97][0],s0[h +    97][1],s0[h +    97][2],s0[h +    97][3]),hideTrace($w[h +    97])=(s1[h +    97]),rgb($w[h +    98])=(s0[h +    98][0],s0[h +    98][1],s0[h +    98][2],s0[h +    98][3]),hideTrace($w[h +    98])=(s1[h +    98]),rgb($w[h +    99])=(s0[h +    99][0],s0[h +    99][1],s0[h +    99][2],s0[h +    99][3]),hideTrace($w[h +    99])=(s1[h +    99]),rgb($w[h +   100])=(s0[h +   100][0],s0[h +   100][1],s0[h +   100][2],s0[h +   100][3]),hideTrace($w[h +   100])=(s1[h +   100]),rgb($w[h +   101])=(s0[h +   101][0],s0[h +   101][1],s0[h +   101][2],s0[h +   101][3]),hideTrace($w[h +   101])=(s1[h +   101]),rgb($w[h +   102])=(s0[h +   102][0],s0[h +   102][1],s0[h +   102][2],s0[h +   102][3]),hideTrace($w[h +   102])=(s1[h +   102]),rgb($w[h +   103])=(s0[h +   103][0],s0[h +   103][1],s0[h +   103][2],s0[h +   103][3]),hideTrace($w[h +   103])=(s1[h +   103]) \
				,rgb($w[h +   104])=(s0[h +   104][0],s0[h +   104][1],s0[h +   104][2],s0[h +   104][3]),hideTrace($w[h +   104])=(s1[h +   104]),rgb($w[h +   105])=(s0[h +   105][0],s0[h +   105][1],s0[h +   105][2],s0[h +   105][3]),hideTrace($w[h +   105])=(s1[h +   105]),rgb($w[h +   106])=(s0[h +   106][0],s0[h +   106][1],s0[h +   106][2],s0[h +   106][3]),hideTrace($w[h +   106])=(s1[h +   106]),rgb($w[h +   107])=(s0[h +   107][0],s0[h +   107][1],s0[h +   107][2],s0[h +   107][3]),hideTrace($w[h +   107])=(s1[h +   107]),rgb($w[h +   108])=(s0[h +   108][0],s0[h +   108][1],s0[h +   108][2],s0[h +   108][3]),hideTrace($w[h +   108])=(s1[h +   108]),rgb($w[h +   109])=(s0[h +   109][0],s0[h +   109][1],s0[h +   109][2],s0[h +   109][3]),hideTrace($w[h +   109])=(s1[h +   109]),rgb($w[h +   110])=(s0[h +   110][0],s0[h +   110][1],s0[h +   110][2],s0[h +   110][3]),hideTrace($w[h +   110])=(s1[h +   110]),rgb($w[h +   111])=(s0[h +   111][0],s0[h +   111][1],s0[h +   111][2],s0[h +   111][3]),hideTrace($w[h +   111])=(s1[h +   111]) \
				,rgb($w[h +   112])=(s0[h +   112][0],s0[h +   112][1],s0[h +   112][2],s0[h +   112][3]),hideTrace($w[h +   112])=(s1[h +   112]),rgb($w[h +   113])=(s0[h +   113][0],s0[h +   113][1],s0[h +   113][2],s0[h +   113][3]),hideTrace($w[h +   113])=(s1[h +   113]),rgb($w[h +   114])=(s0[h +   114][0],s0[h +   114][1],s0[h +   114][2],s0[h +   114][3]),hideTrace($w[h +   114])=(s1[h +   114]),rgb($w[h +   115])=(s0[h +   115][0],s0[h +   115][1],s0[h +   115][2],s0[h +   115][3]),hideTrace($w[h +   115])=(s1[h +   115]),rgb($w[h +   116])=(s0[h +   116][0],s0[h +   116][1],s0[h +   116][2],s0[h +   116][3]),hideTrace($w[h +   116])=(s1[h +   116]),rgb($w[h +   117])=(s0[h +   117][0],s0[h +   117][1],s0[h +   117][2],s0[h +   117][3]),hideTrace($w[h +   117])=(s1[h +   117]),rgb($w[h +   118])=(s0[h +   118][0],s0[h +   118][1],s0[h +   118][2],s0[h +   118][3]),hideTrace($w[h +   118])=(s1[h +   118]),rgb($w[h +   119])=(s0[h +   119][0],s0[h +   119][1],s0[h +   119][2],s0[h +   119][3]),hideTrace($w[h +   119])=(s1[h +   119]) \
				,rgb($w[h +   120])=(s0[h +   120][0],s0[h +   120][1],s0[h +   120][2],s0[h +   120][3]),hideTrace($w[h +   120])=(s1[h +   120]),rgb($w[h +   121])=(s0[h +   121][0],s0[h +   121][1],s0[h +   121][2],s0[h +   121][3]),hideTrace($w[h +   121])=(s1[h +   121]),rgb($w[h +   122])=(s0[h +   122][0],s0[h +   122][1],s0[h +   122][2],s0[h +   122][3]),hideTrace($w[h +   122])=(s1[h +   122]),rgb($w[h +   123])=(s0[h +   123][0],s0[h +   123][1],s0[h +   123][2],s0[h +   123][3]),hideTrace($w[h +   123])=(s1[h +   123]),rgb($w[h +   124])=(s0[h +   124][0],s0[h +   124][1],s0[h +   124][2],s0[h +   124][3]),hideTrace($w[h +   124])=(s1[h +   124]),rgb($w[h +   125])=(s0[h +   125][0],s0[h +   125][1],s0[h +   125][2],s0[h +   125][3]),hideTrace($w[h +   125])=(s1[h +   125]),rgb($w[h +   126])=(s0[h +   126][0],s0[h +   126][1],s0[h +   126][2],s0[h +   126][3]),hideTrace($w[h +   126])=(s1[h +   126]),rgb($w[h +   127])=(s0[h +   127][0],s0[h +   127][1],s0[h +   127][2],s0[h +   127][3]),hideTrace($w[h +   127])=(s1[h +   127]) \
				,rgb($w[h +   128])=(s0[h +   128][0],s0[h +   128][1],s0[h +   128][2],s0[h +   128][3]),hideTrace($w[h +   128])=(s1[h +   128]),rgb($w[h +   129])=(s0[h +   129][0],s0[h +   129][1],s0[h +   129][2],s0[h +   129][3]),hideTrace($w[h +   129])=(s1[h +   129]),rgb($w[h +   130])=(s0[h +   130][0],s0[h +   130][1],s0[h +   130][2],s0[h +   130][3]),hideTrace($w[h +   130])=(s1[h +   130]),rgb($w[h +   131])=(s0[h +   131][0],s0[h +   131][1],s0[h +   131][2],s0[h +   131][3]),hideTrace($w[h +   131])=(s1[h +   131]),rgb($w[h +   132])=(s0[h +   132][0],s0[h +   132][1],s0[h +   132][2],s0[h +   132][3]),hideTrace($w[h +   132])=(s1[h +   132]),rgb($w[h +   133])=(s0[h +   133][0],s0[h +   133][1],s0[h +   133][2],s0[h +   133][3]),hideTrace($w[h +   133])=(s1[h +   133]),rgb($w[h +   134])=(s0[h +   134][0],s0[h +   134][1],s0[h +   134][2],s0[h +   134][3]),hideTrace($w[h +   134])=(s1[h +   134]),rgb($w[h +   135])=(s0[h +   135][0],s0[h +   135][1],s0[h +   135][2],s0[h +   135][3]),hideTrace($w[h +   135])=(s1[h +   135]) \
				,rgb($w[h +   136])=(s0[h +   136][0],s0[h +   136][1],s0[h +   136][2],s0[h +   136][3]),hideTrace($w[h +   136])=(s1[h +   136]),rgb($w[h +   137])=(s0[h +   137][0],s0[h +   137][1],s0[h +   137][2],s0[h +   137][3]),hideTrace($w[h +   137])=(s1[h +   137]),rgb($w[h +   138])=(s0[h +   138][0],s0[h +   138][1],s0[h +   138][2],s0[h +   138][3]),hideTrace($w[h +   138])=(s1[h +   138]),rgb($w[h +   139])=(s0[h +   139][0],s0[h +   139][1],s0[h +   139][2],s0[h +   139][3]),hideTrace($w[h +   139])=(s1[h +   139]),rgb($w[h +   140])=(s0[h +   140][0],s0[h +   140][1],s0[h +   140][2],s0[h +   140][3]),hideTrace($w[h +   140])=(s1[h +   140]),rgb($w[h +   141])=(s0[h +   141][0],s0[h +   141][1],s0[h +   141][2],s0[h +   141][3]),hideTrace($w[h +   141])=(s1[h +   141]),rgb($w[h +   142])=(s0[h +   142][0],s0[h +   142][1],s0[h +   142][2],s0[h +   142][3]),hideTrace($w[h +   142])=(s1[h +   142]),rgb($w[h +   143])=(s0[h +   143][0],s0[h +   143][1],s0[h +   143][2],s0[h +   143][3]),hideTrace($w[h +   143])=(s1[h +   143]) \
				,rgb($w[h +   144])=(s0[h +   144][0],s0[h +   144][1],s0[h +   144][2],s0[h +   144][3]),hideTrace($w[h +   144])=(s1[h +   144]),rgb($w[h +   145])=(s0[h +   145][0],s0[h +   145][1],s0[h +   145][2],s0[h +   145][3]),hideTrace($w[h +   145])=(s1[h +   145]),rgb($w[h +   146])=(s0[h +   146][0],s0[h +   146][1],s0[h +   146][2],s0[h +   146][3]),hideTrace($w[h +   146])=(s1[h +   146]),rgb($w[h +   147])=(s0[h +   147][0],s0[h +   147][1],s0[h +   147][2],s0[h +   147][3]),hideTrace($w[h +   147])=(s1[h +   147]),rgb($w[h +   148])=(s0[h +   148][0],s0[h +   148][1],s0[h +   148][2],s0[h +   148][3]),hideTrace($w[h +   148])=(s1[h +   148]),rgb($w[h +   149])=(s0[h +   149][0],s0[h +   149][1],s0[h +   149][2],s0[h +   149][3]),hideTrace($w[h +   149])=(s1[h +   149]),rgb($w[h +   150])=(s0[h +   150][0],s0[h +   150][1],s0[h +   150][2],s0[h +   150][3]),hideTrace($w[h +   150])=(s1[h +   150]),rgb($w[h +   151])=(s0[h +   151][0],s0[h +   151][1],s0[h +   151][2],s0[h +   151][3]),hideTrace($w[h +   151])=(s1[h +   151]) \
				,rgb($w[h +   152])=(s0[h +   152][0],s0[h +   152][1],s0[h +   152][2],s0[h +   152][3]),hideTrace($w[h +   152])=(s1[h +   152]),rgb($w[h +   153])=(s0[h +   153][0],s0[h +   153][1],s0[h +   153][2],s0[h +   153][3]),hideTrace($w[h +   153])=(s1[h +   153]),rgb($w[h +   154])=(s0[h +   154][0],s0[h +   154][1],s0[h +   154][2],s0[h +   154][3]),hideTrace($w[h +   154])=(s1[h +   154]),rgb($w[h +   155])=(s0[h +   155][0],s0[h +   155][1],s0[h +   155][2],s0[h +   155][3]),hideTrace($w[h +   155])=(s1[h +   155]),rgb($w[h +   156])=(s0[h +   156][0],s0[h +   156][1],s0[h +   156][2],s0[h +   156][3]),hideTrace($w[h +   156])=(s1[h +   156]),rgb($w[h +   157])=(s0[h +   157][0],s0[h +   157][1],s0[h +   157][2],s0[h +   157][3]),hideTrace($w[h +   157])=(s1[h +   157]),rgb($w[h +   158])=(s0[h +   158][0],s0[h +   158][1],s0[h +   158][2],s0[h +   158][3]),hideTrace($w[h +   158])=(s1[h +   158]),rgb($w[h +   159])=(s0[h +   159][0],s0[h +   159][1],s0[h +   159][2],s0[h +   159][3]),hideTrace($w[h +   159])=(s1[h +   159]) \
				,rgb($w[h +   160])=(s0[h +   160][0],s0[h +   160][1],s0[h +   160][2],s0[h +   160][3]),hideTrace($w[h +   160])=(s1[h +   160]),rgb($w[h +   161])=(s0[h +   161][0],s0[h +   161][1],s0[h +   161][2],s0[h +   161][3]),hideTrace($w[h +   161])=(s1[h +   161]),rgb($w[h +   162])=(s0[h +   162][0],s0[h +   162][1],s0[h +   162][2],s0[h +   162][3]),hideTrace($w[h +   162])=(s1[h +   162]),rgb($w[h +   163])=(s0[h +   163][0],s0[h +   163][1],s0[h +   163][2],s0[h +   163][3]),hideTrace($w[h +   163])=(s1[h +   163]),rgb($w[h +   164])=(s0[h +   164][0],s0[h +   164][1],s0[h +   164][2],s0[h +   164][3]),hideTrace($w[h +   164])=(s1[h +   164]),rgb($w[h +   165])=(s0[h +   165][0],s0[h +   165][1],s0[h +   165][2],s0[h +   165][3]),hideTrace($w[h +   165])=(s1[h +   165]),rgb($w[h +   166])=(s0[h +   166][0],s0[h +   166][1],s0[h +   166][2],s0[h +   166][3]),hideTrace($w[h +   166])=(s1[h +   166]),rgb($w[h +   167])=(s0[h +   167][0],s0[h +   167][1],s0[h +   167][2],s0[h +   167][3]),hideTrace($w[h +   167])=(s1[h +   167]) \
				,rgb($w[h +   168])=(s0[h +   168][0],s0[h +   168][1],s0[h +   168][2],s0[h +   168][3]),hideTrace($w[h +   168])=(s1[h +   168]),rgb($w[h +   169])=(s0[h +   169][0],s0[h +   169][1],s0[h +   169][2],s0[h +   169][3]),hideTrace($w[h +   169])=(s1[h +   169]),rgb($w[h +   170])=(s0[h +   170][0],s0[h +   170][1],s0[h +   170][2],s0[h +   170][3]),hideTrace($w[h +   170])=(s1[h +   170]),rgb($w[h +   171])=(s0[h +   171][0],s0[h +   171][1],s0[h +   171][2],s0[h +   171][3]),hideTrace($w[h +   171])=(s1[h +   171]),rgb($w[h +   172])=(s0[h +   172][0],s0[h +   172][1],s0[h +   172][2],s0[h +   172][3]),hideTrace($w[h +   172])=(s1[h +   172]),rgb($w[h +   173])=(s0[h +   173][0],s0[h +   173][1],s0[h +   173][2],s0[h +   173][3]),hideTrace($w[h +   173])=(s1[h +   173]),rgb($w[h +   174])=(s0[h +   174][0],s0[h +   174][1],s0[h +   174][2],s0[h +   174][3]),hideTrace($w[h +   174])=(s1[h +   174]),rgb($w[h +   175])=(s0[h +   175][0],s0[h +   175][1],s0[h +   175][2],s0[h +   175][3]),hideTrace($w[h +   175])=(s1[h +   175]) \
				,rgb($w[h +   176])=(s0[h +   176][0],s0[h +   176][1],s0[h +   176][2],s0[h +   176][3]),hideTrace($w[h +   176])=(s1[h +   176]),rgb($w[h +   177])=(s0[h +   177][0],s0[h +   177][1],s0[h +   177][2],s0[h +   177][3]),hideTrace($w[h +   177])=(s1[h +   177]),rgb($w[h +   178])=(s0[h +   178][0],s0[h +   178][1],s0[h +   178][2],s0[h +   178][3]),hideTrace($w[h +   178])=(s1[h +   178]),rgb($w[h +   179])=(s0[h +   179][0],s0[h +   179][1],s0[h +   179][2],s0[h +   179][3]),hideTrace($w[h +   179])=(s1[h +   179]),rgb($w[h +   180])=(s0[h +   180][0],s0[h +   180][1],s0[h +   180][2],s0[h +   180][3]),hideTrace($w[h +   180])=(s1[h +   180]),rgb($w[h +   181])=(s0[h +   181][0],s0[h +   181][1],s0[h +   181][2],s0[h +   181][3]),hideTrace($w[h +   181])=(s1[h +   181]),rgb($w[h +   182])=(s0[h +   182][0],s0[h +   182][1],s0[h +   182][2],s0[h +   182][3]),hideTrace($w[h +   182])=(s1[h +   182]),rgb($w[h +   183])=(s0[h +   183][0],s0[h +   183][1],s0[h +   183][2],s0[h +   183][3]),hideTrace($w[h +   183])=(s1[h +   183]) \
				,rgb($w[h +   184])=(s0[h +   184][0],s0[h +   184][1],s0[h +   184][2],s0[h +   184][3]),hideTrace($w[h +   184])=(s1[h +   184]),rgb($w[h +   185])=(s0[h +   185][0],s0[h +   185][1],s0[h +   185][2],s0[h +   185][3]),hideTrace($w[h +   185])=(s1[h +   185]),rgb($w[h +   186])=(s0[h +   186][0],s0[h +   186][1],s0[h +   186][2],s0[h +   186][3]),hideTrace($w[h +   186])=(s1[h +   186]),rgb($w[h +   187])=(s0[h +   187][0],s0[h +   187][1],s0[h +   187][2],s0[h +   187][3]),hideTrace($w[h +   187])=(s1[h +   187]),rgb($w[h +   188])=(s0[h +   188][0],s0[h +   188][1],s0[h +   188][2],s0[h +   188][3]),hideTrace($w[h +   188])=(s1[h +   188]),rgb($w[h +   189])=(s0[h +   189][0],s0[h +   189][1],s0[h +   189][2],s0[h +   189][3]),hideTrace($w[h +   189])=(s1[h +   189]),rgb($w[h +   190])=(s0[h +   190][0],s0[h +   190][1],s0[h +   190][2],s0[h +   190][3]),hideTrace($w[h +   190])=(s1[h +   190]),rgb($w[h +   191])=(s0[h +   191][0],s0[h +   191][1],s0[h +   191][2],s0[h +   191][3]),hideTrace($w[h +   191])=(s1[h +   191]) \
				,rgb($w[h +   192])=(s0[h +   192][0],s0[h +   192][1],s0[h +   192][2],s0[h +   192][3]),hideTrace($w[h +   192])=(s1[h +   192]),rgb($w[h +   193])=(s0[h +   193][0],s0[h +   193][1],s0[h +   193][2],s0[h +   193][3]),hideTrace($w[h +   193])=(s1[h +   193]),rgb($w[h +   194])=(s0[h +   194][0],s0[h +   194][1],s0[h +   194][2],s0[h +   194][3]),hideTrace($w[h +   194])=(s1[h +   194]),rgb($w[h +   195])=(s0[h +   195][0],s0[h +   195][1],s0[h +   195][2],s0[h +   195][3]),hideTrace($w[h +   195])=(s1[h +   195]),rgb($w[h +   196])=(s0[h +   196][0],s0[h +   196][1],s0[h +   196][2],s0[h +   196][3]),hideTrace($w[h +   196])=(s1[h +   196]),rgb($w[h +   197])=(s0[h +   197][0],s0[h +   197][1],s0[h +   197][2],s0[h +   197][3]),hideTrace($w[h +   197])=(s1[h +   197]),rgb($w[h +   198])=(s0[h +   198][0],s0[h +   198][1],s0[h +   198][2],s0[h +   198][3]),hideTrace($w[h +   198])=(s1[h +   198]),rgb($w[h +   199])=(s0[h +   199][0],s0[h +   199][1],s0[h +   199][2],s0[h +   199][3]),hideTrace($w[h +   199])=(s1[h +   199]) \
				,rgb($w[h +   200])=(s0[h +   200][0],s0[h +   200][1],s0[h +   200][2],s0[h +   200][3]),hideTrace($w[h +   200])=(s1[h +   200]),rgb($w[h +   201])=(s0[h +   201][0],s0[h +   201][1],s0[h +   201][2],s0[h +   201][3]),hideTrace($w[h +   201])=(s1[h +   201]),rgb($w[h +   202])=(s0[h +   202][0],s0[h +   202][1],s0[h +   202][2],s0[h +   202][3]),hideTrace($w[h +   202])=(s1[h +   202]),rgb($w[h +   203])=(s0[h +   203][0],s0[h +   203][1],s0[h +   203][2],s0[h +   203][3]),hideTrace($w[h +   203])=(s1[h +   203]),rgb($w[h +   204])=(s0[h +   204][0],s0[h +   204][1],s0[h +   204][2],s0[h +   204][3]),hideTrace($w[h +   204])=(s1[h +   204]),rgb($w[h +   205])=(s0[h +   205][0],s0[h +   205][1],s0[h +   205][2],s0[h +   205][3]),hideTrace($w[h +   205])=(s1[h +   205]),rgb($w[h +   206])=(s0[h +   206][0],s0[h +   206][1],s0[h +   206][2],s0[h +   206][3]),hideTrace($w[h +   206])=(s1[h +   206]),rgb($w[h +   207])=(s0[h +   207][0],s0[h +   207][1],s0[h +   207][2],s0[h +   207][3]),hideTrace($w[h +   207])=(s1[h +   207]) \
				,rgb($w[h +   208])=(s0[h +   208][0],s0[h +   208][1],s0[h +   208][2],s0[h +   208][3]),hideTrace($w[h +   208])=(s1[h +   208]),rgb($w[h +   209])=(s0[h +   209][0],s0[h +   209][1],s0[h +   209][2],s0[h +   209][3]),hideTrace($w[h +   209])=(s1[h +   209]),rgb($w[h +   210])=(s0[h +   210][0],s0[h +   210][1],s0[h +   210][2],s0[h +   210][3]),hideTrace($w[h +   210])=(s1[h +   210]),rgb($w[h +   211])=(s0[h +   211][0],s0[h +   211][1],s0[h +   211][2],s0[h +   211][3]),hideTrace($w[h +   211])=(s1[h +   211]),rgb($w[h +   212])=(s0[h +   212][0],s0[h +   212][1],s0[h +   212][2],s0[h +   212][3]),hideTrace($w[h +   212])=(s1[h +   212]),rgb($w[h +   213])=(s0[h +   213][0],s0[h +   213][1],s0[h +   213][2],s0[h +   213][3]),hideTrace($w[h +   213])=(s1[h +   213]),rgb($w[h +   214])=(s0[h +   214][0],s0[h +   214][1],s0[h +   214][2],s0[h +   214][3]),hideTrace($w[h +   214])=(s1[h +   214]),rgb($w[h +   215])=(s0[h +   215][0],s0[h +   215][1],s0[h +   215][2],s0[h +   215][3]),hideTrace($w[h +   215])=(s1[h +   215]) \
				,rgb($w[h +   216])=(s0[h +   216][0],s0[h +   216][1],s0[h +   216][2],s0[h +   216][3]),hideTrace($w[h +   216])=(s1[h +   216]),rgb($w[h +   217])=(s0[h +   217][0],s0[h +   217][1],s0[h +   217][2],s0[h +   217][3]),hideTrace($w[h +   217])=(s1[h +   217]),rgb($w[h +   218])=(s0[h +   218][0],s0[h +   218][1],s0[h +   218][2],s0[h +   218][3]),hideTrace($w[h +   218])=(s1[h +   218]),rgb($w[h +   219])=(s0[h +   219][0],s0[h +   219][1],s0[h +   219][2],s0[h +   219][3]),hideTrace($w[h +   219])=(s1[h +   219]),rgb($w[h +   220])=(s0[h +   220][0],s0[h +   220][1],s0[h +   220][2],s0[h +   220][3]),hideTrace($w[h +   220])=(s1[h +   220]),rgb($w[h +   221])=(s0[h +   221][0],s0[h +   221][1],s0[h +   221][2],s0[h +   221][3]),hideTrace($w[h +   221])=(s1[h +   221]),rgb($w[h +   222])=(s0[h +   222][0],s0[h +   222][1],s0[h +   222][2],s0[h +   222][3]),hideTrace($w[h +   222])=(s1[h +   222]),rgb($w[h +   223])=(s0[h +   223][0],s0[h +   223][1],s0[h +   223][2],s0[h +   223][3]),hideTrace($w[h +   223])=(s1[h +   223]) \
				,rgb($w[h +   224])=(s0[h +   224][0],s0[h +   224][1],s0[h +   224][2],s0[h +   224][3]),hideTrace($w[h +   224])=(s1[h +   224]),rgb($w[h +   225])=(s0[h +   225][0],s0[h +   225][1],s0[h +   225][2],s0[h +   225][3]),hideTrace($w[h +   225])=(s1[h +   225]),rgb($w[h +   226])=(s0[h +   226][0],s0[h +   226][1],s0[h +   226][2],s0[h +   226][3]),hideTrace($w[h +   226])=(s1[h +   226]),rgb($w[h +   227])=(s0[h +   227][0],s0[h +   227][1],s0[h +   227][2],s0[h +   227][3]),hideTrace($w[h +   227])=(s1[h +   227]),rgb($w[h +   228])=(s0[h +   228][0],s0[h +   228][1],s0[h +   228][2],s0[h +   228][3]),hideTrace($w[h +   228])=(s1[h +   228]),rgb($w[h +   229])=(s0[h +   229][0],s0[h +   229][1],s0[h +   229][2],s0[h +   229][3]),hideTrace($w[h +   229])=(s1[h +   229]),rgb($w[h +   230])=(s0[h +   230][0],s0[h +   230][1],s0[h +   230][2],s0[h +   230][3]),hideTrace($w[h +   230])=(s1[h +   230]),rgb($w[h +   231])=(s0[h +   231][0],s0[h +   231][1],s0[h +   231][2],s0[h +   231][3]),hideTrace($w[h +   231])=(s1[h +   231]) \
				,rgb($w[h +   232])=(s0[h +   232][0],s0[h +   232][1],s0[h +   232][2],s0[h +   232][3]),hideTrace($w[h +   232])=(s1[h +   232]),rgb($w[h +   233])=(s0[h +   233][0],s0[h +   233][1],s0[h +   233][2],s0[h +   233][3]),hideTrace($w[h +   233])=(s1[h +   233]),rgb($w[h +   234])=(s0[h +   234][0],s0[h +   234][1],s0[h +   234][2],s0[h +   234][3]),hideTrace($w[h +   234])=(s1[h +   234]),rgb($w[h +   235])=(s0[h +   235][0],s0[h +   235][1],s0[h +   235][2],s0[h +   235][3]),hideTrace($w[h +   235])=(s1[h +   235]),rgb($w[h +   236])=(s0[h +   236][0],s0[h +   236][1],s0[h +   236][2],s0[h +   236][3]),hideTrace($w[h +   236])=(s1[h +   236]),rgb($w[h +   237])=(s0[h +   237][0],s0[h +   237][1],s0[h +   237][2],s0[h +   237][3]),hideTrace($w[h +   237])=(s1[h +   237]),rgb($w[h +   238])=(s0[h +   238][0],s0[h +   238][1],s0[h +   238][2],s0[h +   238][3]),hideTrace($w[h +   238])=(s1[h +   238]),rgb($w[h +   239])=(s0[h +   239][0],s0[h +   239][1],s0[h +   239][2],s0[h +   239][3]),hideTrace($w[h +   239])=(s1[h +   239]) \
				,rgb($w[h +   240])=(s0[h +   240][0],s0[h +   240][1],s0[h +   240][2],s0[h +   240][3]),hideTrace($w[h +   240])=(s1[h +   240]),rgb($w[h +   241])=(s0[h +   241][0],s0[h +   241][1],s0[h +   241][2],s0[h +   241][3]),hideTrace($w[h +   241])=(s1[h +   241]),rgb($w[h +   242])=(s0[h +   242][0],s0[h +   242][1],s0[h +   242][2],s0[h +   242][3]),hideTrace($w[h +   242])=(s1[h +   242]),rgb($w[h +   243])=(s0[h +   243][0],s0[h +   243][1],s0[h +   243][2],s0[h +   243][3]),hideTrace($w[h +   243])=(s1[h +   243]),rgb($w[h +   244])=(s0[h +   244][0],s0[h +   244][1],s0[h +   244][2],s0[h +   244][3]),hideTrace($w[h +   244])=(s1[h +   244]),rgb($w[h +   245])=(s0[h +   245][0],s0[h +   245][1],s0[h +   245][2],s0[h +   245][3]),hideTrace($w[h +   245])=(s1[h +   245]),rgb($w[h +   246])=(s0[h +   246][0],s0[h +   246][1],s0[h +   246][2],s0[h +   246][3]),hideTrace($w[h +   246])=(s1[h +   246]),rgb($w[h +   247])=(s0[h +   247][0],s0[h +   247][1],s0[h +   247][2],s0[h +   247][3]),hideTrace($w[h +   247])=(s1[h +   247]) \
				,rgb($w[h +   248])=(s0[h +   248][0],s0[h +   248][1],s0[h +   248][2],s0[h +   248][3]),hideTrace($w[h +   248])=(s1[h +   248]),rgb($w[h +   249])=(s0[h +   249][0],s0[h +   249][1],s0[h +   249][2],s0[h +   249][3]),hideTrace($w[h +   249])=(s1[h +   249]),rgb($w[h +   250])=(s0[h +   250][0],s0[h +   250][1],s0[h +   250][2],s0[h +   250][3]),hideTrace($w[h +   250])=(s1[h +   250]),rgb($w[h +   251])=(s0[h +   251][0],s0[h +   251][1],s0[h +   251][2],s0[h +   251][3]),hideTrace($w[h +   251])=(s1[h +   251]),rgb($w[h +   252])=(s0[h +   252][0],s0[h +   252][1],s0[h +   252][2],s0[h +   252][3]),hideTrace($w[h +   252])=(s1[h +   252]),rgb($w[h +   253])=(s0[h +   253][0],s0[h +   253][1],s0[h +   253][2],s0[h +   253][3]),hideTrace($w[h +   253])=(s1[h +   253]),rgb($w[h +   254])=(s0[h +   254][0],s0[h +   254][1],s0[h +   254][2],s0[h +   254][3]),hideTrace($w[h +   254])=(s1[h +   254]),rgb($w[h +   255])=(s0[h +   255][0],s0[h +   255][1],s0[h +   255][2],s0[h +   255][3]),hideTrace($w[h +   255])=(s1[h +   255])
				break
			case 128:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31]) \
				,rgb($w[h +    32])=(s0[h +    32][0],s0[h +    32][1],s0[h +    32][2],s0[h +    32][3]),hideTrace($w[h +    32])=(s1[h +    32]),rgb($w[h +    33])=(s0[h +    33][0],s0[h +    33][1],s0[h +    33][2],s0[h +    33][3]),hideTrace($w[h +    33])=(s1[h +    33]),rgb($w[h +    34])=(s0[h +    34][0],s0[h +    34][1],s0[h +    34][2],s0[h +    34][3]),hideTrace($w[h +    34])=(s1[h +    34]),rgb($w[h +    35])=(s0[h +    35][0],s0[h +    35][1],s0[h +    35][2],s0[h +    35][3]),hideTrace($w[h +    35])=(s1[h +    35]),rgb($w[h +    36])=(s0[h +    36][0],s0[h +    36][1],s0[h +    36][2],s0[h +    36][3]),hideTrace($w[h +    36])=(s1[h +    36]),rgb($w[h +    37])=(s0[h +    37][0],s0[h +    37][1],s0[h +    37][2],s0[h +    37][3]),hideTrace($w[h +    37])=(s1[h +    37]),rgb($w[h +    38])=(s0[h +    38][0],s0[h +    38][1],s0[h +    38][2],s0[h +    38][3]),hideTrace($w[h +    38])=(s1[h +    38]),rgb($w[h +    39])=(s0[h +    39][0],s0[h +    39][1],s0[h +    39][2],s0[h +    39][3]),hideTrace($w[h +    39])=(s1[h +    39]) \
				,rgb($w[h +    40])=(s0[h +    40][0],s0[h +    40][1],s0[h +    40][2],s0[h +    40][3]),hideTrace($w[h +    40])=(s1[h +    40]),rgb($w[h +    41])=(s0[h +    41][0],s0[h +    41][1],s0[h +    41][2],s0[h +    41][3]),hideTrace($w[h +    41])=(s1[h +    41]),rgb($w[h +    42])=(s0[h +    42][0],s0[h +    42][1],s0[h +    42][2],s0[h +    42][3]),hideTrace($w[h +    42])=(s1[h +    42]),rgb($w[h +    43])=(s0[h +    43][0],s0[h +    43][1],s0[h +    43][2],s0[h +    43][3]),hideTrace($w[h +    43])=(s1[h +    43]),rgb($w[h +    44])=(s0[h +    44][0],s0[h +    44][1],s0[h +    44][2],s0[h +    44][3]),hideTrace($w[h +    44])=(s1[h +    44]),rgb($w[h +    45])=(s0[h +    45][0],s0[h +    45][1],s0[h +    45][2],s0[h +    45][3]),hideTrace($w[h +    45])=(s1[h +    45]),rgb($w[h +    46])=(s0[h +    46][0],s0[h +    46][1],s0[h +    46][2],s0[h +    46][3]),hideTrace($w[h +    46])=(s1[h +    46]),rgb($w[h +    47])=(s0[h +    47][0],s0[h +    47][1],s0[h +    47][2],s0[h +    47][3]),hideTrace($w[h +    47])=(s1[h +    47]) \
				,rgb($w[h +    48])=(s0[h +    48][0],s0[h +    48][1],s0[h +    48][2],s0[h +    48][3]),hideTrace($w[h +    48])=(s1[h +    48]),rgb($w[h +    49])=(s0[h +    49][0],s0[h +    49][1],s0[h +    49][2],s0[h +    49][3]),hideTrace($w[h +    49])=(s1[h +    49]),rgb($w[h +    50])=(s0[h +    50][0],s0[h +    50][1],s0[h +    50][2],s0[h +    50][3]),hideTrace($w[h +    50])=(s1[h +    50]),rgb($w[h +    51])=(s0[h +    51][0],s0[h +    51][1],s0[h +    51][2],s0[h +    51][3]),hideTrace($w[h +    51])=(s1[h +    51]),rgb($w[h +    52])=(s0[h +    52][0],s0[h +    52][1],s0[h +    52][2],s0[h +    52][3]),hideTrace($w[h +    52])=(s1[h +    52]),rgb($w[h +    53])=(s0[h +    53][0],s0[h +    53][1],s0[h +    53][2],s0[h +    53][3]),hideTrace($w[h +    53])=(s1[h +    53]),rgb($w[h +    54])=(s0[h +    54][0],s0[h +    54][1],s0[h +    54][2],s0[h +    54][3]),hideTrace($w[h +    54])=(s1[h +    54]),rgb($w[h +    55])=(s0[h +    55][0],s0[h +    55][1],s0[h +    55][2],s0[h +    55][3]),hideTrace($w[h +    55])=(s1[h +    55]) \
				,rgb($w[h +    56])=(s0[h +    56][0],s0[h +    56][1],s0[h +    56][2],s0[h +    56][3]),hideTrace($w[h +    56])=(s1[h +    56]),rgb($w[h +    57])=(s0[h +    57][0],s0[h +    57][1],s0[h +    57][2],s0[h +    57][3]),hideTrace($w[h +    57])=(s1[h +    57]),rgb($w[h +    58])=(s0[h +    58][0],s0[h +    58][1],s0[h +    58][2],s0[h +    58][3]),hideTrace($w[h +    58])=(s1[h +    58]),rgb($w[h +    59])=(s0[h +    59][0],s0[h +    59][1],s0[h +    59][2],s0[h +    59][3]),hideTrace($w[h +    59])=(s1[h +    59]),rgb($w[h +    60])=(s0[h +    60][0],s0[h +    60][1],s0[h +    60][2],s0[h +    60][3]),hideTrace($w[h +    60])=(s1[h +    60]),rgb($w[h +    61])=(s0[h +    61][0],s0[h +    61][1],s0[h +    61][2],s0[h +    61][3]),hideTrace($w[h +    61])=(s1[h +    61]),rgb($w[h +    62])=(s0[h +    62][0],s0[h +    62][1],s0[h +    62][2],s0[h +    62][3]),hideTrace($w[h +    62])=(s1[h +    62]),rgb($w[h +    63])=(s0[h +    63][0],s0[h +    63][1],s0[h +    63][2],s0[h +    63][3]),hideTrace($w[h +    63])=(s1[h +    63]) \
				,rgb($w[h +    64])=(s0[h +    64][0],s0[h +    64][1],s0[h +    64][2],s0[h +    64][3]),hideTrace($w[h +    64])=(s1[h +    64]),rgb($w[h +    65])=(s0[h +    65][0],s0[h +    65][1],s0[h +    65][2],s0[h +    65][3]),hideTrace($w[h +    65])=(s1[h +    65]),rgb($w[h +    66])=(s0[h +    66][0],s0[h +    66][1],s0[h +    66][2],s0[h +    66][3]),hideTrace($w[h +    66])=(s1[h +    66]),rgb($w[h +    67])=(s0[h +    67][0],s0[h +    67][1],s0[h +    67][2],s0[h +    67][3]),hideTrace($w[h +    67])=(s1[h +    67]),rgb($w[h +    68])=(s0[h +    68][0],s0[h +    68][1],s0[h +    68][2],s0[h +    68][3]),hideTrace($w[h +    68])=(s1[h +    68]),rgb($w[h +    69])=(s0[h +    69][0],s0[h +    69][1],s0[h +    69][2],s0[h +    69][3]),hideTrace($w[h +    69])=(s1[h +    69]),rgb($w[h +    70])=(s0[h +    70][0],s0[h +    70][1],s0[h +    70][2],s0[h +    70][3]),hideTrace($w[h +    70])=(s1[h +    70]),rgb($w[h +    71])=(s0[h +    71][0],s0[h +    71][1],s0[h +    71][2],s0[h +    71][3]),hideTrace($w[h +    71])=(s1[h +    71]) \
				,rgb($w[h +    72])=(s0[h +    72][0],s0[h +    72][1],s0[h +    72][2],s0[h +    72][3]),hideTrace($w[h +    72])=(s1[h +    72]),rgb($w[h +    73])=(s0[h +    73][0],s0[h +    73][1],s0[h +    73][2],s0[h +    73][3]),hideTrace($w[h +    73])=(s1[h +    73]),rgb($w[h +    74])=(s0[h +    74][0],s0[h +    74][1],s0[h +    74][2],s0[h +    74][3]),hideTrace($w[h +    74])=(s1[h +    74]),rgb($w[h +    75])=(s0[h +    75][0],s0[h +    75][1],s0[h +    75][2],s0[h +    75][3]),hideTrace($w[h +    75])=(s1[h +    75]),rgb($w[h +    76])=(s0[h +    76][0],s0[h +    76][1],s0[h +    76][2],s0[h +    76][3]),hideTrace($w[h +    76])=(s1[h +    76]),rgb($w[h +    77])=(s0[h +    77][0],s0[h +    77][1],s0[h +    77][2],s0[h +    77][3]),hideTrace($w[h +    77])=(s1[h +    77]),rgb($w[h +    78])=(s0[h +    78][0],s0[h +    78][1],s0[h +    78][2],s0[h +    78][3]),hideTrace($w[h +    78])=(s1[h +    78]),rgb($w[h +    79])=(s0[h +    79][0],s0[h +    79][1],s0[h +    79][2],s0[h +    79][3]),hideTrace($w[h +    79])=(s1[h +    79]) \
				,rgb($w[h +    80])=(s0[h +    80][0],s0[h +    80][1],s0[h +    80][2],s0[h +    80][3]),hideTrace($w[h +    80])=(s1[h +    80]),rgb($w[h +    81])=(s0[h +    81][0],s0[h +    81][1],s0[h +    81][2],s0[h +    81][3]),hideTrace($w[h +    81])=(s1[h +    81]),rgb($w[h +    82])=(s0[h +    82][0],s0[h +    82][1],s0[h +    82][2],s0[h +    82][3]),hideTrace($w[h +    82])=(s1[h +    82]),rgb($w[h +    83])=(s0[h +    83][0],s0[h +    83][1],s0[h +    83][2],s0[h +    83][3]),hideTrace($w[h +    83])=(s1[h +    83]),rgb($w[h +    84])=(s0[h +    84][0],s0[h +    84][1],s0[h +    84][2],s0[h +    84][3]),hideTrace($w[h +    84])=(s1[h +    84]),rgb($w[h +    85])=(s0[h +    85][0],s0[h +    85][1],s0[h +    85][2],s0[h +    85][3]),hideTrace($w[h +    85])=(s1[h +    85]),rgb($w[h +    86])=(s0[h +    86][0],s0[h +    86][1],s0[h +    86][2],s0[h +    86][3]),hideTrace($w[h +    86])=(s1[h +    86]),rgb($w[h +    87])=(s0[h +    87][0],s0[h +    87][1],s0[h +    87][2],s0[h +    87][3]),hideTrace($w[h +    87])=(s1[h +    87]) \
				,rgb($w[h +    88])=(s0[h +    88][0],s0[h +    88][1],s0[h +    88][2],s0[h +    88][3]),hideTrace($w[h +    88])=(s1[h +    88]),rgb($w[h +    89])=(s0[h +    89][0],s0[h +    89][1],s0[h +    89][2],s0[h +    89][3]),hideTrace($w[h +    89])=(s1[h +    89]),rgb($w[h +    90])=(s0[h +    90][0],s0[h +    90][1],s0[h +    90][2],s0[h +    90][3]),hideTrace($w[h +    90])=(s1[h +    90]),rgb($w[h +    91])=(s0[h +    91][0],s0[h +    91][1],s0[h +    91][2],s0[h +    91][3]),hideTrace($w[h +    91])=(s1[h +    91]),rgb($w[h +    92])=(s0[h +    92][0],s0[h +    92][1],s0[h +    92][2],s0[h +    92][3]),hideTrace($w[h +    92])=(s1[h +    92]),rgb($w[h +    93])=(s0[h +    93][0],s0[h +    93][1],s0[h +    93][2],s0[h +    93][3]),hideTrace($w[h +    93])=(s1[h +    93]),rgb($w[h +    94])=(s0[h +    94][0],s0[h +    94][1],s0[h +    94][2],s0[h +    94][3]),hideTrace($w[h +    94])=(s1[h +    94]),rgb($w[h +    95])=(s0[h +    95][0],s0[h +    95][1],s0[h +    95][2],s0[h +    95][3]),hideTrace($w[h +    95])=(s1[h +    95]) \
				,rgb($w[h +    96])=(s0[h +    96][0],s0[h +    96][1],s0[h +    96][2],s0[h +    96][3]),hideTrace($w[h +    96])=(s1[h +    96]),rgb($w[h +    97])=(s0[h +    97][0],s0[h +    97][1],s0[h +    97][2],s0[h +    97][3]),hideTrace($w[h +    97])=(s1[h +    97]),rgb($w[h +    98])=(s0[h +    98][0],s0[h +    98][1],s0[h +    98][2],s0[h +    98][3]),hideTrace($w[h +    98])=(s1[h +    98]),rgb($w[h +    99])=(s0[h +    99][0],s0[h +    99][1],s0[h +    99][2],s0[h +    99][3]),hideTrace($w[h +    99])=(s1[h +    99]),rgb($w[h +   100])=(s0[h +   100][0],s0[h +   100][1],s0[h +   100][2],s0[h +   100][3]),hideTrace($w[h +   100])=(s1[h +   100]),rgb($w[h +   101])=(s0[h +   101][0],s0[h +   101][1],s0[h +   101][2],s0[h +   101][3]),hideTrace($w[h +   101])=(s1[h +   101]),rgb($w[h +   102])=(s0[h +   102][0],s0[h +   102][1],s0[h +   102][2],s0[h +   102][3]),hideTrace($w[h +   102])=(s1[h +   102]),rgb($w[h +   103])=(s0[h +   103][0],s0[h +   103][1],s0[h +   103][2],s0[h +   103][3]),hideTrace($w[h +   103])=(s1[h +   103]) \
				,rgb($w[h +   104])=(s0[h +   104][0],s0[h +   104][1],s0[h +   104][2],s0[h +   104][3]),hideTrace($w[h +   104])=(s1[h +   104]),rgb($w[h +   105])=(s0[h +   105][0],s0[h +   105][1],s0[h +   105][2],s0[h +   105][3]),hideTrace($w[h +   105])=(s1[h +   105]),rgb($w[h +   106])=(s0[h +   106][0],s0[h +   106][1],s0[h +   106][2],s0[h +   106][3]),hideTrace($w[h +   106])=(s1[h +   106]),rgb($w[h +   107])=(s0[h +   107][0],s0[h +   107][1],s0[h +   107][2],s0[h +   107][3]),hideTrace($w[h +   107])=(s1[h +   107]),rgb($w[h +   108])=(s0[h +   108][0],s0[h +   108][1],s0[h +   108][2],s0[h +   108][3]),hideTrace($w[h +   108])=(s1[h +   108]),rgb($w[h +   109])=(s0[h +   109][0],s0[h +   109][1],s0[h +   109][2],s0[h +   109][3]),hideTrace($w[h +   109])=(s1[h +   109]),rgb($w[h +   110])=(s0[h +   110][0],s0[h +   110][1],s0[h +   110][2],s0[h +   110][3]),hideTrace($w[h +   110])=(s1[h +   110]),rgb($w[h +   111])=(s0[h +   111][0],s0[h +   111][1],s0[h +   111][2],s0[h +   111][3]),hideTrace($w[h +   111])=(s1[h +   111]) \
				,rgb($w[h +   112])=(s0[h +   112][0],s0[h +   112][1],s0[h +   112][2],s0[h +   112][3]),hideTrace($w[h +   112])=(s1[h +   112]),rgb($w[h +   113])=(s0[h +   113][0],s0[h +   113][1],s0[h +   113][2],s0[h +   113][3]),hideTrace($w[h +   113])=(s1[h +   113]),rgb($w[h +   114])=(s0[h +   114][0],s0[h +   114][1],s0[h +   114][2],s0[h +   114][3]),hideTrace($w[h +   114])=(s1[h +   114]),rgb($w[h +   115])=(s0[h +   115][0],s0[h +   115][1],s0[h +   115][2],s0[h +   115][3]),hideTrace($w[h +   115])=(s1[h +   115]),rgb($w[h +   116])=(s0[h +   116][0],s0[h +   116][1],s0[h +   116][2],s0[h +   116][3]),hideTrace($w[h +   116])=(s1[h +   116]),rgb($w[h +   117])=(s0[h +   117][0],s0[h +   117][1],s0[h +   117][2],s0[h +   117][3]),hideTrace($w[h +   117])=(s1[h +   117]),rgb($w[h +   118])=(s0[h +   118][0],s0[h +   118][1],s0[h +   118][2],s0[h +   118][3]),hideTrace($w[h +   118])=(s1[h +   118]),rgb($w[h +   119])=(s0[h +   119][0],s0[h +   119][1],s0[h +   119][2],s0[h +   119][3]),hideTrace($w[h +   119])=(s1[h +   119]) \
				,rgb($w[h +   120])=(s0[h +   120][0],s0[h +   120][1],s0[h +   120][2],s0[h +   120][3]),hideTrace($w[h +   120])=(s1[h +   120]),rgb($w[h +   121])=(s0[h +   121][0],s0[h +   121][1],s0[h +   121][2],s0[h +   121][3]),hideTrace($w[h +   121])=(s1[h +   121]),rgb($w[h +   122])=(s0[h +   122][0],s0[h +   122][1],s0[h +   122][2],s0[h +   122][3]),hideTrace($w[h +   122])=(s1[h +   122]),rgb($w[h +   123])=(s0[h +   123][0],s0[h +   123][1],s0[h +   123][2],s0[h +   123][3]),hideTrace($w[h +   123])=(s1[h +   123]),rgb($w[h +   124])=(s0[h +   124][0],s0[h +   124][1],s0[h +   124][2],s0[h +   124][3]),hideTrace($w[h +   124])=(s1[h +   124]),rgb($w[h +   125])=(s0[h +   125][0],s0[h +   125][1],s0[h +   125][2],s0[h +   125][3]),hideTrace($w[h +   125])=(s1[h +   125]),rgb($w[h +   126])=(s0[h +   126][0],s0[h +   126][1],s0[h +   126][2],s0[h +   126][3]),hideTrace($w[h +   126])=(s1[h +   126]),rgb($w[h +   127])=(s0[h +   127][0],s0[h +   127][1],s0[h +   127][2],s0[h +   127][3]),hideTrace($w[h +   127])=(s1[h +   127])
				break
			case 64:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31]) \
				,rgb($w[h +    32])=(s0[h +    32][0],s0[h +    32][1],s0[h +    32][2],s0[h +    32][3]),hideTrace($w[h +    32])=(s1[h +    32]),rgb($w[h +    33])=(s0[h +    33][0],s0[h +    33][1],s0[h +    33][2],s0[h +    33][3]),hideTrace($w[h +    33])=(s1[h +    33]),rgb($w[h +    34])=(s0[h +    34][0],s0[h +    34][1],s0[h +    34][2],s0[h +    34][3]),hideTrace($w[h +    34])=(s1[h +    34]),rgb($w[h +    35])=(s0[h +    35][0],s0[h +    35][1],s0[h +    35][2],s0[h +    35][3]),hideTrace($w[h +    35])=(s1[h +    35]),rgb($w[h +    36])=(s0[h +    36][0],s0[h +    36][1],s0[h +    36][2],s0[h +    36][3]),hideTrace($w[h +    36])=(s1[h +    36]),rgb($w[h +    37])=(s0[h +    37][0],s0[h +    37][1],s0[h +    37][2],s0[h +    37][3]),hideTrace($w[h +    37])=(s1[h +    37]),rgb($w[h +    38])=(s0[h +    38][0],s0[h +    38][1],s0[h +    38][2],s0[h +    38][3]),hideTrace($w[h +    38])=(s1[h +    38]),rgb($w[h +    39])=(s0[h +    39][0],s0[h +    39][1],s0[h +    39][2],s0[h +    39][3]),hideTrace($w[h +    39])=(s1[h +    39]) \
				,rgb($w[h +    40])=(s0[h +    40][0],s0[h +    40][1],s0[h +    40][2],s0[h +    40][3]),hideTrace($w[h +    40])=(s1[h +    40]),rgb($w[h +    41])=(s0[h +    41][0],s0[h +    41][1],s0[h +    41][2],s0[h +    41][3]),hideTrace($w[h +    41])=(s1[h +    41]),rgb($w[h +    42])=(s0[h +    42][0],s0[h +    42][1],s0[h +    42][2],s0[h +    42][3]),hideTrace($w[h +    42])=(s1[h +    42]),rgb($w[h +    43])=(s0[h +    43][0],s0[h +    43][1],s0[h +    43][2],s0[h +    43][3]),hideTrace($w[h +    43])=(s1[h +    43]),rgb($w[h +    44])=(s0[h +    44][0],s0[h +    44][1],s0[h +    44][2],s0[h +    44][3]),hideTrace($w[h +    44])=(s1[h +    44]),rgb($w[h +    45])=(s0[h +    45][0],s0[h +    45][1],s0[h +    45][2],s0[h +    45][3]),hideTrace($w[h +    45])=(s1[h +    45]),rgb($w[h +    46])=(s0[h +    46][0],s0[h +    46][1],s0[h +    46][2],s0[h +    46][3]),hideTrace($w[h +    46])=(s1[h +    46]),rgb($w[h +    47])=(s0[h +    47][0],s0[h +    47][1],s0[h +    47][2],s0[h +    47][3]),hideTrace($w[h +    47])=(s1[h +    47]) \
				,rgb($w[h +    48])=(s0[h +    48][0],s0[h +    48][1],s0[h +    48][2],s0[h +    48][3]),hideTrace($w[h +    48])=(s1[h +    48]),rgb($w[h +    49])=(s0[h +    49][0],s0[h +    49][1],s0[h +    49][2],s0[h +    49][3]),hideTrace($w[h +    49])=(s1[h +    49]),rgb($w[h +    50])=(s0[h +    50][0],s0[h +    50][1],s0[h +    50][2],s0[h +    50][3]),hideTrace($w[h +    50])=(s1[h +    50]),rgb($w[h +    51])=(s0[h +    51][0],s0[h +    51][1],s0[h +    51][2],s0[h +    51][3]),hideTrace($w[h +    51])=(s1[h +    51]),rgb($w[h +    52])=(s0[h +    52][0],s0[h +    52][1],s0[h +    52][2],s0[h +    52][3]),hideTrace($w[h +    52])=(s1[h +    52]),rgb($w[h +    53])=(s0[h +    53][0],s0[h +    53][1],s0[h +    53][2],s0[h +    53][3]),hideTrace($w[h +    53])=(s1[h +    53]),rgb($w[h +    54])=(s0[h +    54][0],s0[h +    54][1],s0[h +    54][2],s0[h +    54][3]),hideTrace($w[h +    54])=(s1[h +    54]),rgb($w[h +    55])=(s0[h +    55][0],s0[h +    55][1],s0[h +    55][2],s0[h +    55][3]),hideTrace($w[h +    55])=(s1[h +    55]) \
				,rgb($w[h +    56])=(s0[h +    56][0],s0[h +    56][1],s0[h +    56][2],s0[h +    56][3]),hideTrace($w[h +    56])=(s1[h +    56]),rgb($w[h +    57])=(s0[h +    57][0],s0[h +    57][1],s0[h +    57][2],s0[h +    57][3]),hideTrace($w[h +    57])=(s1[h +    57]),rgb($w[h +    58])=(s0[h +    58][0],s0[h +    58][1],s0[h +    58][2],s0[h +    58][3]),hideTrace($w[h +    58])=(s1[h +    58]),rgb($w[h +    59])=(s0[h +    59][0],s0[h +    59][1],s0[h +    59][2],s0[h +    59][3]),hideTrace($w[h +    59])=(s1[h +    59]),rgb($w[h +    60])=(s0[h +    60][0],s0[h +    60][1],s0[h +    60][2],s0[h +    60][3]),hideTrace($w[h +    60])=(s1[h +    60]),rgb($w[h +    61])=(s0[h +    61][0],s0[h +    61][1],s0[h +    61][2],s0[h +    61][3]),hideTrace($w[h +    61])=(s1[h +    61]),rgb($w[h +    62])=(s0[h +    62][0],s0[h +    62][1],s0[h +    62][2],s0[h +    62][3]),hideTrace($w[h +    62])=(s1[h +    62]),rgb($w[h +    63])=(s0[h +    63][0],s0[h +    63][1],s0[h +    63][2],s0[h +    63][3]),hideTrace($w[h +    63])=(s1[h +    63])
				break
			case 32:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15]) \
				,rgb($w[h +    16])=(s0[h +    16][0],s0[h +    16][1],s0[h +    16][2],s0[h +    16][3]),hideTrace($w[h +    16])=(s1[h +    16]),rgb($w[h +    17])=(s0[h +    17][0],s0[h +    17][1],s0[h +    17][2],s0[h +    17][3]),hideTrace($w[h +    17])=(s1[h +    17]),rgb($w[h +    18])=(s0[h +    18][0],s0[h +    18][1],s0[h +    18][2],s0[h +    18][3]),hideTrace($w[h +    18])=(s1[h +    18]),rgb($w[h +    19])=(s0[h +    19][0],s0[h +    19][1],s0[h +    19][2],s0[h +    19][3]),hideTrace($w[h +    19])=(s1[h +    19]),rgb($w[h +    20])=(s0[h +    20][0],s0[h +    20][1],s0[h +    20][2],s0[h +    20][3]),hideTrace($w[h +    20])=(s1[h +    20]),rgb($w[h +    21])=(s0[h +    21][0],s0[h +    21][1],s0[h +    21][2],s0[h +    21][3]),hideTrace($w[h +    21])=(s1[h +    21]),rgb($w[h +    22])=(s0[h +    22][0],s0[h +    22][1],s0[h +    22][2],s0[h +    22][3]),hideTrace($w[h +    22])=(s1[h +    22]),rgb($w[h +    23])=(s0[h +    23][0],s0[h +    23][1],s0[h +    23][2],s0[h +    23][3]),hideTrace($w[h +    23])=(s1[h +    23]) \
				,rgb($w[h +    24])=(s0[h +    24][0],s0[h +    24][1],s0[h +    24][2],s0[h +    24][3]),hideTrace($w[h +    24])=(s1[h +    24]),rgb($w[h +    25])=(s0[h +    25][0],s0[h +    25][1],s0[h +    25][2],s0[h +    25][3]),hideTrace($w[h +    25])=(s1[h +    25]),rgb($w[h +    26])=(s0[h +    26][0],s0[h +    26][1],s0[h +    26][2],s0[h +    26][3]),hideTrace($w[h +    26])=(s1[h +    26]),rgb($w[h +    27])=(s0[h +    27][0],s0[h +    27][1],s0[h +    27][2],s0[h +    27][3]),hideTrace($w[h +    27])=(s1[h +    27]),rgb($w[h +    28])=(s0[h +    28][0],s0[h +    28][1],s0[h +    28][2],s0[h +    28][3]),hideTrace($w[h +    28])=(s1[h +    28]),rgb($w[h +    29])=(s0[h +    29][0],s0[h +    29][1],s0[h +    29][2],s0[h +    29][3]),hideTrace($w[h +    29])=(s1[h +    29]),rgb($w[h +    30])=(s0[h +    30][0],s0[h +    30][1],s0[h +    30][2],s0[h +    30][3]),hideTrace($w[h +    30])=(s1[h +    30]),rgb($w[h +    31])=(s0[h +    31][0],s0[h +    31][1],s0[h +    31][2],s0[h +    31][3]),hideTrace($w[h +    31])=(s1[h +    31])
				break
			case 16:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7]) \
				,rgb($w[h +     8])=(s0[h +     8][0],s0[h +     8][1],s0[h +     8][2],s0[h +     8][3]),hideTrace($w[h +     8])=(s1[h +     8]),rgb($w[h +     9])=(s0[h +     9][0],s0[h +     9][1],s0[h +     9][2],s0[h +     9][3]),hideTrace($w[h +     9])=(s1[h +     9]),rgb($w[h +    10])=(s0[h +    10][0],s0[h +    10][1],s0[h +    10][2],s0[h +    10][3]),hideTrace($w[h +    10])=(s1[h +    10]),rgb($w[h +    11])=(s0[h +    11][0],s0[h +    11][1],s0[h +    11][2],s0[h +    11][3]),hideTrace($w[h +    11])=(s1[h +    11]),rgb($w[h +    12])=(s0[h +    12][0],s0[h +    12][1],s0[h +    12][2],s0[h +    12][3]),hideTrace($w[h +    12])=(s1[h +    12]),rgb($w[h +    13])=(s0[h +    13][0],s0[h +    13][1],s0[h +    13][2],s0[h +    13][3]),hideTrace($w[h +    13])=(s1[h +    13]),rgb($w[h +    14])=(s0[h +    14][0],s0[h +    14][1],s0[h +    14][2],s0[h +    14][3]),hideTrace($w[h +    14])=(s1[h +    14]),rgb($w[h +    15])=(s0[h +    15][0],s0[h +    15][1],s0[h +    15][2],s0[h +    15][3]),hideTrace($w[h +    15])=(s1[h +    15])
				break
			case 8:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3]),rgb($w[h +     4])=(s0[h +     4][0],s0[h +     4][1],s0[h +     4][2],s0[h +     4][3]),hideTrace($w[h +     4])=(s1[h +     4]),rgb($w[h +     5])=(s0[h +     5][0],s0[h +     5][1],s0[h +     5][2],s0[h +     5][3]),hideTrace($w[h +     5])=(s1[h +     5]),rgb($w[h +     6])=(s0[h +     6][0],s0[h +     6][1],s0[h +     6][2],s0[h +     6][3]),hideTrace($w[h +     6])=(s1[h +     6]),rgb($w[h +     7])=(s0[h +     7][0],s0[h +     7][1],s0[h +     7][2],s0[h +     7][3]),hideTrace($w[h +     7])=(s1[h +     7])
				break
			case 4:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1]),rgb($w[h +     2])=(s0[h +     2][0],s0[h +     2][1],s0[h +     2][2],s0[h +     2][3]),hideTrace($w[h +     2])=(s1[h +     2]),rgb($w[h +     3])=(s0[h +     3][0],s0[h +     3][1],s0[h +     3][2],s0[h +     3][3]),hideTrace($w[h +     3])=(s1[h +     3])
				break
			case 2:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0]),rgb($w[h +     1])=(s0[h +     1][0],s0[h +     1][1],s0[h +     1][2],s0[h +     1][3]),hideTrace($w[h +     1])=(s1[h +     1])
				break
			case 1:
				ModifyGraph/W=$graph \
				 rgb($w[h +     0])=(s0[h +     0][0],s0[h +     0][1],s0[h +     0][2],s0[h +     0][3]),hideTrace($w[h +     0])=(s1[h +     0])
				break
				// END AUTOMATED CODE
			default:
				ASSERT(0, "Fail")
		endswitch
	while(h)
End

///@brief Accelerated setting of line size of multiple traces in a graph
///@param[in] graph name of graph window
///@param[in] w 1D text wave with trace names
///@param[in] h number of traces in text wave
///@param[in] l new line size
Function AccelerateModLineSizeTraces(string graph, WAVE/T w, variable h, variable l)

	variable step

	if(h)
		do
			step = min(2 ^ trunc(log(h) / log(2)), 136)
			h -= step
			switch(step)
				case 136:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l,lsize($w[h+8])=l,lsize($w[h+9])=l,lsize($w[h+10])=l,lsize($w[h+11])=l,lsize($w[h+12])=l,lsize($w[h+13])=l,lsize($w[h+14])=l,lsize($w[h+15])=l,lsize($w[h+16])=l,lsize($w[h+17])=l,lsize($w[h+18])=l,lsize($w[h+19])=l,lsize($w[h+20])=l,lsize($w[h+21])=l,lsize($w[h+22])=l,lsize($w[h+23])=l,lsize($w[h+24])=l,lsize($w[h+25])=l,lsize($w[h+26])=l,lsize($w[h+27])=l,lsize($w[h+28])=l,lsize($w[h+29])=l,lsize($w[h+30])=l,lsize($w[h+31])=l,lsize($w[h+32])=l,lsize($w[h+33])=l,lsize($w[h+34])=l,lsize($w[h+35])=l,lsize($w[h+36])=l,lsize($w[h+37])=l,lsize($w[h+38])=l,lsize($w[h+39])=l,lsize($w[h+40])=l,lsize($w[h+41])=l,lsize($w[h+42])=l,lsize($w[h+43])=l,lsize($w[h+44])=l,lsize($w[h+45])=l,lsize($w[h+46])=l,lsize($w[h+47])=l,lsize($w[h+48])=l,lsize($w[h+49])=l,lsize($w[h+50])=l,lsize($w[h+51])=l,lsize($w[h+52])=l,lsize($w[h+53])=l,lsize($w[h+54])=l,lsize($w[h+55])=l,lsize($w[h+56])=l,lsize($w[h+57])=l,lsize($w[h+58])=l,lsize($w[h+59])=l,lsize($w[h+60])=l,lsize($w[h+61])=l,lsize($w[h+62])=l,lsize($w[h+63])=l,lsize($w[h+64])=l,lsize($w[h+65])=l,lsize($w[h+66])=l,lsize($w[h+67])=l,lsize($w[h+68])=l,lsize($w[h+69])=l,lsize($w[h+70])=l,lsize($w[h+71])=l,lsize($w[h+72])=l,lsize($w[h+73])=l,lsize($w[h+74])=l,lsize($w[h+75])=l,lsize($w[h+76])=l,lsize($w[h+77])=l,lsize($w[h+78])=l,lsize($w[h+79])=l,lsize($w[h+80])=l,lsize($w[h+81])=l,lsize($w[h+82])=l,lsize($w[h+83])=l,lsize($w[h+84])=l,lsize($w[h+85])=l,lsize($w[h+86])=l,lsize($w[h+87])=l,lsize($w[h+88])=l,lsize($w[h+89])=l,lsize($w[h+90])=l,lsize($w[h+91])=l,lsize($w[h+92])=l,lsize($w[h+93])=l,lsize($w[h+94])=l,lsize($w[h+95])=l,lsize($w[h+96])=l,lsize($w[h+97])=l,lsize($w[h+98])=l,lsize($w[h+99])=l,lsize($w[h+100])=l,lsize($w[h+101])=l,lsize($w[h+102])=l,lsize($w[h+103])=l,lsize($w[h+104])=l,lsize($w[h+105])=l,lsize($w[h+106])=l,lsize($w[h+107])=l,lsize($w[h+108])=l,lsize($w[h+109])=l,lsize($w[h+110])=l,lsize($w[h+111])=l,lsize($w[h+112])=l,lsize($w[h+113])=l,lsize($w[h+114])=l,lsize($w[h+115])=l,lsize($w[h+116])=l,lsize($w[h+117])=l,lsize($w[h+118])=l,lsize($w[h+119])=l,lsize($w[h+120])=l,lsize($w[h+121])=l,lsize($w[h+122])=l,lsize($w[h+123])=l,lsize($w[h+124])=l,lsize($w[h+125])=l,lsize($w[h+126])=l,lsize($w[h+127])=l,lsize($w[h+128])=l,lsize($w[h+129])=l,lsize($w[h+130])=l,lsize($w[h+131])=l,lsize($w[h+132])=l,lsize($w[h+133])=l,lsize($w[h+134])=l,lsize($w[h+135])=l
					break
				case 128:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l,lsize($w[h+8])=l,lsize($w[h+9])=l,lsize($w[h+10])=l,lsize($w[h+11])=l,lsize($w[h+12])=l,lsize($w[h+13])=l,lsize($w[h+14])=l,lsize($w[h+15])=l,lsize($w[h+16])=l,lsize($w[h+17])=l,lsize($w[h+18])=l,lsize($w[h+19])=l,lsize($w[h+20])=l,lsize($w[h+21])=l,lsize($w[h+22])=l,lsize($w[h+23])=l,lsize($w[h+24])=l,lsize($w[h+25])=l,lsize($w[h+26])=l,lsize($w[h+27])=l,lsize($w[h+28])=l,lsize($w[h+29])=l,lsize($w[h+30])=l,lsize($w[h+31])=l,lsize($w[h+32])=l,lsize($w[h+33])=l,lsize($w[h+34])=l,lsize($w[h+35])=l,lsize($w[h+36])=l,lsize($w[h+37])=l,lsize($w[h+38])=l,lsize($w[h+39])=l,lsize($w[h+40])=l,lsize($w[h+41])=l,lsize($w[h+42])=l,lsize($w[h+43])=l,lsize($w[h+44])=l,lsize($w[h+45])=l,lsize($w[h+46])=l,lsize($w[h+47])=l,lsize($w[h+48])=l,lsize($w[h+49])=l,lsize($w[h+50])=l,lsize($w[h+51])=l,lsize($w[h+52])=l,lsize($w[h+53])=l,lsize($w[h+54])=l,lsize($w[h+55])=l,lsize($w[h+56])=l,lsize($w[h+57])=l,lsize($w[h+58])=l,lsize($w[h+59])=l,lsize($w[h+60])=l,lsize($w[h+61])=l,lsize($w[h+62])=l,lsize($w[h+63])=l,lsize($w[h+64])=l,lsize($w[h+65])=l,lsize($w[h+66])=l,lsize($w[h+67])=l,lsize($w[h+68])=l,lsize($w[h+69])=l,lsize($w[h+70])=l,lsize($w[h+71])=l,lsize($w[h+72])=l,lsize($w[h+73])=l,lsize($w[h+74])=l,lsize($w[h+75])=l,lsize($w[h+76])=l,lsize($w[h+77])=l,lsize($w[h+78])=l,lsize($w[h+79])=l,lsize($w[h+80])=l,lsize($w[h+81])=l,lsize($w[h+82])=l,lsize($w[h+83])=l,lsize($w[h+84])=l,lsize($w[h+85])=l,lsize($w[h+86])=l,lsize($w[h+87])=l,lsize($w[h+88])=l,lsize($w[h+89])=l,lsize($w[h+90])=l,lsize($w[h+91])=l,lsize($w[h+92])=l,lsize($w[h+93])=l,lsize($w[h+94])=l,lsize($w[h+95])=l,lsize($w[h+96])=l,lsize($w[h+97])=l,lsize($w[h+98])=l,lsize($w[h+99])=l,lsize($w[h+100])=l,lsize($w[h+101])=l,lsize($w[h+102])=l,lsize($w[h+103])=l,lsize($w[h+104])=l,lsize($w[h+105])=l,lsize($w[h+106])=l,lsize($w[h+107])=l,lsize($w[h+108])=l,lsize($w[h+109])=l,lsize($w[h+110])=l,lsize($w[h+111])=l,lsize($w[h+112])=l,lsize($w[h+113])=l,lsize($w[h+114])=l,lsize($w[h+115])=l,lsize($w[h+116])=l,lsize($w[h+117])=l,lsize($w[h+118])=l,lsize($w[h+119])=l,lsize($w[h+120])=l,lsize($w[h+121])=l,lsize($w[h+122])=l,lsize($w[h+123])=l,lsize($w[h+124])=l,lsize($w[h+125])=l,lsize($w[h+126])=l,lsize($w[h+127])=l
					break
				case 64:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l,lsize($w[h+8])=l,lsize($w[h+9])=l,lsize($w[h+10])=l,lsize($w[h+11])=l,lsize($w[h+12])=l,lsize($w[h+13])=l,lsize($w[h+14])=l,lsize($w[h+15])=l,lsize($w[h+16])=l,lsize($w[h+17])=l,lsize($w[h+18])=l,lsize($w[h+19])=l,lsize($w[h+20])=l,lsize($w[h+21])=l,lsize($w[h+22])=l,lsize($w[h+23])=l,lsize($w[h+24])=l,lsize($w[h+25])=l,lsize($w[h+26])=l,lsize($w[h+27])=l,lsize($w[h+28])=l,lsize($w[h+29])=l,lsize($w[h+30])=l,lsize($w[h+31])=l,lsize($w[h+32])=l,lsize($w[h+33])=l,lsize($w[h+34])=l,lsize($w[h+35])=l,lsize($w[h+36])=l,lsize($w[h+37])=l,lsize($w[h+38])=l,lsize($w[h+39])=l,lsize($w[h+40])=l,lsize($w[h+41])=l,lsize($w[h+42])=l,lsize($w[h+43])=l,lsize($w[h+44])=l,lsize($w[h+45])=l,lsize($w[h+46])=l,lsize($w[h+47])=l,lsize($w[h+48])=l,lsize($w[h+49])=l,lsize($w[h+50])=l,lsize($w[h+51])=l,lsize($w[h+52])=l,lsize($w[h+53])=l,lsize($w[h+54])=l,lsize($w[h+55])=l,lsize($w[h+56])=l,lsize($w[h+57])=l,lsize($w[h+58])=l,lsize($w[h+59])=l,lsize($w[h+60])=l,lsize($w[h+61])=l,lsize($w[h+62])=l,lsize($w[h+63])=l
					break
				case 32:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l,lsize($w[h+8])=l,lsize($w[h+9])=l,lsize($w[h+10])=l,lsize($w[h+11])=l,lsize($w[h+12])=l,lsize($w[h+13])=l,lsize($w[h+14])=l,lsize($w[h+15])=l,lsize($w[h+16])=l,lsize($w[h+17])=l,lsize($w[h+18])=l,lsize($w[h+19])=l,lsize($w[h+20])=l,lsize($w[h+21])=l,lsize($w[h+22])=l,lsize($w[h+23])=l,lsize($w[h+24])=l,lsize($w[h+25])=l,lsize($w[h+26])=l,lsize($w[h+27])=l,lsize($w[h+28])=l,lsize($w[h+29])=l,lsize($w[h+30])=l,lsize($w[h+31])=l
					break
				case 16:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l,lsize($w[h+8])=l,lsize($w[h+9])=l,lsize($w[h+10])=l,lsize($w[h+11])=l,lsize($w[h+12])=l,lsize($w[h+13])=l,lsize($w[h+14])=l,lsize($w[h+15])=l
					break
				case 8:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l,lsize($w[h+4])=l,lsize($w[h+5])=l,lsize($w[h+6])=l,lsize($w[h+7])=l
					break
				case 4:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l,lsize($w[h+2])=l,lsize($w[h+3])=l
					break
				case 2:
					ModifyGraph/W=$graph lsize($w[h])=l,lsize($w[h+1])=l
					break
				case 1:
					ModifyGraph/W=$graph lsize($w[h])=l
					break
				default:
					ASSERT(0, "Fail")
					break
			endswitch
		while(h)
	endif
End

/// @brief Return the value and type of the popupmenu list
///
/// @retval value extracted string with the contents of `value` from the recreation macro
/// @retval type  popup menu list type, one of @ref PopupMenuListTypes
Function [string value, variable type] ParsePopupMenuValue(string recMacro)

	string listOrFunc, path, cmd, builtinPopupMenu

	SplitString/E="\\s*,\\s*value\\s*=\\s*(.*)$" recMacro, listOrFunc
	if(V_Flag != 1)
		Bug("Could not find popupmenu \"value\" entry")
		return ["", NaN]
	endif

	listOrFunc = trimstring(listOrFunc, 1)

	// unescape quotes
	listOrFunc = ReplaceString("\\\"", listOrFunc, "\"")

	// misc cleanup
	listOrFunc = RemovePrefix(listOrFunc, start = "#")
	listOrFunc = RemovePrefix(listOrFunc, start = "\"")
	listOrFunc = RemoveEnding(listOrFunc, "\"")

	SplitString/E="^\"\*([A-Z]{1,})\*\"$" listOrFunc, builtinPopupMenu

	if(V_flag == 1)
		return [builtinPopupMenu, POPUPMENULIST_TYPE_BUILTIN]
	endif

	return [listOrFunc, POPUPMENULIST_TYPE_OTHER]
End

/// @brief Return the popupmenu list entries
///
/// @param value String with a list or function (what you enter with PopupMenu value=\#XXX)
/// @param type  One of @ref PopupMenuListTypes
Function/S GetPopupMenuList(string value, variable type)
	string path, cmd

	switch(type)
		case POPUPMENULIST_TYPE_BUILTIN:
			strswitch(value)
				case "COLORTABLEPOP":
					return CTabList()
				default:
					ASSERT(0, "Not implemented")
			endswitch
		case POPUPMENULIST_TYPE_OTHER:
			path = GetTemporaryString()

			sprintf cmd, "%s = %s", path, value
			Execute/Z/Q cmd

			if(V_Flag)
				Bug("Execute returned an error :(")
				return ""
			endif

			SVAR str = $path
			return str
		default:
			ASSERT(0, "Missing popup menu list type")
	endswitch
End

/// @brief Enable show trace info tags globally
Function ShowTraceInfoTags()

	DoIgorMenu/C "Graph", "Show Trace Info Tags"

	if(cmpStr(S_value,"Hide Trace Info Tags"))
		// add graph so that the menu item is available
		Display
		DoIgorMenu/OVRD "Graph", "Show Trace Info Tags"
		KillWindow/Z $S_name
	endif
End

/// @brief Return the recreation macro and the type of the given control
Function [string recMacro, variable type] GetRecreationMacroAndType(string win, string control)

	ControlInfo/W=$win $control
	if(!V_flag)
		ASSERT(WindowExists(win), "The panel " + win + " does not exist.")
		ASSERT(0, "The control " + control + " in the panel " + win + " does not exist.")
	endif

	return [S_recreation, abs(V_flag)]
End

/// @brief Query a numeric GUI control property
Function GetControlSettingVar(string win, string control, string setting, [variable defValue])
	string match
	variable found

	if(ParamIsDefault(defValue))
		defValue = NaN
	endif

	[match, found] = GetControlSettingImpl(win, control, setting)

	if(!found)
		return defValue
	endif

	return str2numSafe(match)
End

/// @brief Query a string GUI control property
Function/S GetControlSettingStr(string win, string control, string setting, [string defValue])
	string match
	variable found

	if(ParamIsDefault(defValue))
		defValue = ""
	endif

	[match, found] = GetControlSettingImpl(win, control, setting)

	if(!found)
		return defValue
	endif

	return PossiblyUnquoteName(match, "\"")
End

static Function [string match, variable found] GetControlSettingImpl(string win, string control, string setting)
	string recMacro, str
	variable controlType

	[recMacro, controlType] = GetRecreationMacroAndType(win, control)

	SplitString/E=("(?i)\\Q" + setting + "\\E[[:space:]]*=[[:space:]]*([^,]+)") recMacro, str

	ASSERT(V_Flag == 0 || V_Flag == 1, "Unexpected number of matches")

	return [str, !!V_flag]
End

/// @brief Set the checked/unchecked and enabled/disabled state of the given list of controls
///
/// Allows to set a number of related checkbox controls depending on the state of the main control.
///
/// \rst
///
/// ============== ========== ======== ======================
///  Main default   Main new   Mode     Action on controls
/// ============== ========== ======== ======================
///      ON           OFF      same     unchecked & disabled
///      ON           OFF      invert   checked & disabled
///      ON           ON        ?       enabled & restored
/// -------------- ---------- -------- ----------------------
///      OFF          ON       same     checked & disabled
///      OFF          ON       invert   unchecked & disabled
///      OFF          OFF       ?       enabled & restored
/// ============== ========== ======== ======================
///
/// \endrst
Function AdaptDependentControls(string win, string controls, variable defaultMainState, variable newMainState, variable mode)

	variable numControls, oldState, i, newState
	string ctrl

	defaultMainState = !!defaultMainState
	newMainState = !!newMainState
	numControls = ItemsInList(controls)

	if(defaultMainState == newMainState)
		// enabled controls and restore the previous state
		EnableControls(win, controls)

		for(i = 0; i < numControls; i += 1)
			ctrl = StringFromList(i, controls)

			// and read old state
			oldState = str2num(GetUserData(win, ctrl, "oldState"))

			// invalidate old state
			SetControlUserData(win, ctrl, "oldState", "")

			// set old state
			PGC_SetAndActivateControl(win, ctrl, val = oldState)
		endfor

		return NaN
	endif

	newState = (mode == DEP_CTRLS_SAME) ? newMainState : !newMainState

	for(i = 0; i < numControls; i += 1)
		ctrl = StringFromList(i, controls)
		// store current state
		oldState = DAG_GetNumericalValue(win, ctrl)
		SetControlUserData(win, ctrl, "oldState", num2str(oldState))

		// and apply new state
		PGC_SetAndActivateControl(win, ctrl, val = newState)
	endfor

	// and disable
	DisableControls(win, controls)
End

/// @brief Adjust the "Normal" ruler in the notebook so that all text is visible.
Function ReflowNotebookText(string win)
	variable width

	GetWindow $win wsizeDC
	width = V_right - V_left
	// make it a bit shorter
	width -= 10
	// pixel -> points
	width = width * (72/ScreenResolution)
	// redefine ruler
	Notebook $win ruler=Normal, rulerUnits=0, margins={0, 0, width}
	// select everything
	Notebook $win selection={startOfFile, endOfFile}
	// apply ruler to selection
	Notebook $win ruler=Normal
	// deselect selection
	Notebook $win selection={endOfFile, endOfFile}
End

/// @brief In a formatted notebook sets a location where keyWord appear to the given color
Function ColorNotebookKeywords(string win, string keyWord, variable r, variable g, variable b)

	if(IsEmpty(keyWord))
		return NaN
	endif

	Notebook $win, selection={startOfFile, startOfFile}
	Notebook $win, findText={"", 0}

	do
		Notebook $win, findText={keyWord, 6}
		if(V_flag == 1)
			Notebook $win, textRGB=(r, g, b)
		endif
	while(V_flag == 1)
End

/// @brief Marquee helper
///
/// @param[in]  axisName coordinate system to use for returned values
/// @param[in]  kill     [optional, defaults to false] should the marquee be killed afterwards
/// @param[in]  doAssert [optional, defaults to true] ASSERT out if nothing can be returned
/// @param[in]  horiz    [optional] direction to return, exactly one of horiz/vert must be defined
/// @param[in]  vert     [optional] direction to return, exactly one of horiz/vert must be defined
/// @param[out] win      [optional] allows to query the window as returned by GetMarquee
///
/// @retval first start of the range
/// @retval last  end of the range
Function [variable first, variable last] GetMarqueeHelper(string axisName, [variable kill, variable doAssert, variable horiz, variable vert, string &win])

	first = NaN
	last  = NaN

	if(!ParamIsDefault(win))
		win = ""
	endif

	if(ParamIsDefault(kill))
		kill = 0
	else
		kill = !!kill
	endif

	if(ParamIsDefault(doAssert))
		doAssert = 1
	else
		doAssert = !!doAssert
	endif

	ASSERT(ParamIsDefault(horiz) + ParamIsDefault(vert) == 1, "Required exactly one of horiz/vert")

	if(ParamIsDefault(horiz))
		horiz = 0
	else
		horiz = !!horiz
	endif

	if(ParamIsDefault(vert))
		vert = 0
	else
		vert = !!vert
	endif

	AssertOnAndClearRTError()
	try
		if(kill)
			GetMarquee/K/Z $axisName; AbortOnRTE
		else
			GetMarquee/Z $axisName; AbortOnRTE
		endif
	catch
		ClearRTError()
		ASSERT(!doAssert, "Missing axis")

		return [first, last]
	endtry

	if(!V_Flag)
		ASSERT(!doAssert, "Missing marquee")
		return [first, last]
	endif

	if(!ParamIsDefault(win))
		win = S_MarqueeWin
	endif

	if(horiz)
		return [V_left, V_right]
	elseif(vert)
		return [V_bottom, V_top]
	else
		ASSERT(0, "Impossible state")
	endif
End
