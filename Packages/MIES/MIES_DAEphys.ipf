#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

#ifdef AUTOMATED_TESTING
#pragma ModuleName=MIES_DAP
#endif

/// @file MIES_DAEphys.ipf
/// @brief __DAP__ Main data acquisition panel routines

static Constant DATA_ACQU_TAB_NUM         = 0
static Constant HARDWARE_TAB_NUM          = 6

static StrConstant YOKE_LIST_OF_CONTROLS  = "group_Hardware_YokeInner;button_Hardware_Lead1600;button_Hardware_Independent;button_Hardware_AddFollower;popup_Hardware_AvailITC1600s;popup_Hardware_YokedDACs;button_Hardware_RemoveYoke"
static StrConstant YOKE_CONTROLS_DISABLE  = "StartTestPulseButton;DataAcquireButton;Button_DataAcq_SkipBackwards;Button_DataAcq_SkipForward"
/// Synced with `desc` in DAP_CheckSettingsAcrossYoked()
static StrConstant YOKE_CONTROLS_DISABLE_AND_LINK = "Check_DataAcq1_RepeatAcq;Check_DataAcq1_DistribDaq;SetVar_DataAcq_dDAQDelay;Check_DataAcq_Indexing;SetVar_DataAcq_ITI;SetVar_DataAcq_SetRepeats;Check_DataAcq_Get_Set_ITI;Setvar_DataAcq_dDAQOptOvPre;Setvar_DataAcq_dDAQOptOvPost;Check_DataAcq1_dDAQOptOv;setvar_DataAcq_dDAQOptOvRes"
static StrConstant FOLLOWER               = "Follower"
static StrConstant LEADER                 = "Leader"

static StrConstant COMMENT_PANEL          = "UserComments"
static StrConstant COMMENT_PANEL_NOTEBOOK = "NB"

static StrConstant AMPLIFIER_DEF_FORMAT   = "AmpNo %d Chan %d"

static StrConstant GUI_CONTROLSAVESTATE_DISABLED = "oldDisabledState"

// PCIe-6343 | PXI-6259 | PCIe-6341
static StrConstant NI_DAC_PATTERNS = "AI:32;AO:4;COUNTER:4;DIOPORTS:3;LINES:32,8,8|AI:32;AO:4;COUNTER:2;DIOPORTS:3;LINES:32,8,8|AI:16;AO:2;COUNTER:4;DIOPORTS:3;LINES:8,8,8"

static Constant DAP_WAITFORTPANALYSIS_TIMEOUT = 2

/// @brief Creates meta information about coupled CheckBoxes (Radio Button) controls
///        Used for saving/restoring the GUI state
/// @return Free text wave with lists of coupled CheckBox controls
Function/WAVE DAP_GetRadioButtonCoupling()

	Make/FREE/T/N=10 w

	w[0] = "Radio_ClampMode_0;Radio_ClampMode_1;Radio_ClampMode_1IZ;"
	w[1] = "Radio_ClampMode_2;Radio_ClampMode_3;Radio_ClampMode_3IZ;"
	w[2] = "Radio_ClampMode_4;Radio_ClampMode_5;Radio_ClampMode_5IZ;"
	w[3] = "Radio_ClampMode_6;Radio_ClampMode_7;Radio_ClampMode_7IZ;"
	w[4] = "Radio_ClampMode_8;Radio_ClampMode_9;Radio_ClampMode_9IZ;"
	w[5] = "Radio_ClampMode_10;Radio_ClampMode_11;Radio_ClampMode_11IZ;"
	w[6] = "Radio_ClampMode_12;Radio_ClampMode_13;Radio_ClampMode_13IZ;"
	w[7] = "Radio_ClampMode_14;Radio_ClampMode_15;Radio_ClampMode_15IZ;"
	w[8] = "Radio_ClampMode_AllVClamp;Radio_ClampMode_AllIClamp;Radio_ClampMode_AllIZero;"
	w[9] = "check_Settings_Option_3;check_Settings_SetOption_5;"

	return w
End

/// @brief Returns a list of DAC devices for NI devices
/// @return list of NI DAC devices
Function/S DAP_GetNIDeviceList()
	variable i, j, numPattern
	string DAQmxDevice, DAQmxDevName
	string devList, pattern

	SVAR globalNIDevList = $GetNIDeviceList()
	devList = globalNIDevList

	if(!isEmpty(devList))
		return devList
	endif

	numPattern = ItemsInList(NI_DAC_PATTERNS, "|")

	for(i = 0;i < HARDWARE_MAX_DEVICES;i += 1)
		DAQmxDevice = HW_NI_GetPropertyListOfDevices(i)

		if(IsEmpty(DAQmxDevice))
			break
		endif

#ifdef EVIL_KITTEN_EATING_MODE
		devList += StringByKey("NAME", DAQmxDevice) + ";"
#else
		for(j = 0; j < numPattern; j += 1)
			pattern = StringFromList(j, NI_DAC_PATTERNS, "|")
			if(!(strsearch(DAQmxDevice, pattern, 0) == -1))
				DAQmxDevName = StringByKey("NAME", DAQmxDevice)
				if(!isEmpty(DAQmxDevName))
					if(!IsValidObjectName(DAQmxDevName))
						Print "NI device " + DAQmxDevName + " has a name that is incompatible for use in MIES. Please change the device name in NI MAX to a simple name, e.g. DeviceX."
					else
						devList += DAQmxDevName + ";"
					endif
				endif
			endif
		endfor
#endif
	endfor

	globalNIDevList = devList

	// we want to have device infos for all NI devices
	// devList holds only the ones suitable for DAQ but
	// skips the ones used for pressure
	DAP_UpdateDeviceInfoWaves(HW_NI_ListDevices(), HARDWARE_NI_DAC)

	return devList
End

/// @brief Returns a list of ITC devices for DAC
Function/S DAP_GetITCDeviceList()

	string devList

	SVAR globalITCDevList = $GetITCDeviceList()
	devList = globalITCDevList

	if(!isEmpty(devList))
		return devList
	endif

	globalITCDevList = HW_ITC_ListDevices()

	DAP_UpdateDeviceInfoWaves(globalITCDevList, HARDWARE_ITC_DAC)

	return globalITCDevList
End

/// @brief Returns a list of available ITC and NI devices
///
/// @return list of DAC devices
Function/S DAP_GetDACDeviceList()

	string list = NONE
	string devices

	devices = DAP_GetITCDeviceList()

	if(!IsEmpty(devices))
		list = AddListItem(devices, list, ";", inf)
	endif

	devices = DAP_GetNIDeviceList()

	if(!IsEmpty(devices))
		list = AddListItem(devices, list, ";", inf)
	endif

	return list
End

/// @brief Restores the base state of the DA_Ephys panel.
/// Useful when adding controls to GUI. Facilitates use of auto generation of GUI code.
/// Useful when template experiment file has been overwritten.
Function DAP_EphysPanelStartUpSettings()
	string panelTitle

	variable i
	string popValue

	panelTitle = GetMainWindow(GetCurrentWindow())

	if(!windowExists(panelTitle))
		print "The top panel does not exist"
		ControlWindowToFront()
		return NaN
	endif

	DAP_UnlockDevice(panelTitle)

	panelTitle = GetMainWindow(GetCurrentWindow())

	if(cmpstr(panelTitle, BASE_WINDOW_TITLE))
		printf "The top window is not named \"%s\"\r", BASE_WINDOW_TITLE
		return NaN
	endif

	// remove tools
	HideTools/W=$panelTitle/A

	SetWindow $panelTitle, userData(panelVersion) = ""
	SetWindow $panelTitle, userdata(Config_FileName) = ""
	SetWindow $panelTitle, userdata(Config_FileHash) = ""

	CheckBox Check_AD_00 WIN = $panelTitle,value= 0
	CheckBox Check_AD_01 WIN = $panelTitle,value= 0
	CheckBox Check_AD_02 WIN = $panelTitle,value= 0
	CheckBox Check_AD_03 WIN = $panelTitle,value= 0
	CheckBox Check_AD_04 WIN = $panelTitle,value= 0
	CheckBox Check_AD_05 WIN = $panelTitle,value= 0
	CheckBox Check_AD_06 WIN = $panelTitle,value= 0
	CheckBox Check_AD_07 WIN = $panelTitle,value= 0
	CheckBox Check_AD_08 WIN = $panelTitle,value= 0
	CheckBox Check_AD_09 WIN = $panelTitle,value= 0
	CheckBox Check_AD_10 WIN = $panelTitle,value= 0
	CheckBox Check_AD_11 WIN = $panelTitle,value= 0
	CheckBox Check_AD_12 WIN = $panelTitle,value= 0
	CheckBox Check_AD_13 WIN = $panelTitle,value= 0
	CheckBox Check_AD_14 WIN = $panelTitle,value= 0
	CheckBox Check_AD_15 WIN = $panelTitle,value= 0
	CheckBox Check_AD_All WIN = $panelTitle,value= 0

	CheckBox Check_DA_00 WIN = $panelTitle,value= 0
	CheckBox Check_DA_01 WIN = $panelTitle,value= 0
	CheckBox Check_DA_02 WIN = $panelTitle,value= 0
	CheckBox Check_DA_03 WIN = $panelTitle,value= 0
	CheckBox Check_DA_04 WIN = $panelTitle,value= 0
	CheckBox Check_DA_05 WIN = $panelTitle,value= 0
	CheckBox Check_DA_06 WIN = $panelTitle,value= 0
	CheckBox Check_DA_07 WIN = $panelTitle,value= 0
	CheckBox Check_DA_All WIN = $panelTitle,value= 0
	CheckBox Check_DA_AllVClamp WIN = $panelTitle,value= 0
	CheckBox Check_DA_AllIClamp WIN = $panelTitle,value= 0

	CheckBox Check_TTL_00 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_01 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_02 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_03 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_04 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_05 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_06 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_07 WIN = $panelTitle,value= 0
	CheckBox Check_TTL_All WIN = $panelTitle,value= 0

	CheckBox Check_DataAcqHS_00 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_01 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_02 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_03 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_04 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_05 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_06 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_07 WIN = $panelTitle,value= 0
	CheckBox Check_DataAcqHS_All WIN = $panelTitle,value= 0

	PGC_SetAndActivateControl(panelTitle, "ADC", val = 6)
	DoUpdate/W=$panelTitle

	SetVariable Gain_AD_00 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_01 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_02 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_03 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_04 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_05 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_06 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_07 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_08 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_09 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_10 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_11 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_12 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_13 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_14 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_AD_15 WIN = $panelTitle, value = _NUM:0.00

	SetVariable Gain_DA_00 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_01 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_02 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_03 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_04 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_05 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_06 WIN = $panelTitle, value = _NUM:0.00
	SetVariable Gain_DA_07 WIN = $panelTitle, value = _NUM:0.00

	popValue = DAP_FormatStimSetPopupValue(CHANNEL_TYPE_DAC)
	PopupMenu Wave_DA_00 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_01 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_02 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_03 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_04 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_05 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_06 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_07 WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_All WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_AllVClamp WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_DA_AllIClamp WIN = $panelTitle,mode=1, userdata(MenuExp) = "", value=#popValue

	SetVariable Scale_DA_00 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_01 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_02 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_03 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_04 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_05 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_06 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_07 WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_All WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_AllVClamp WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}
	SetVariable Scale_DA_AllIClamp WIN = $panelTitle, value = _NUM:1,limits={-inf,inf,10}

	SetVariable SetVar_DataAcq_Comment WIN = $panelTitle,value= _STR:""

	CheckBox Check_DataAcq1_RepeatAcq Win = $panelTitle, value = 1
	CheckBox Check_DataAcq1_DistribDaq Win = $panelTitle, value = 0
	CheckBox Check_DataAcq1_dDAQOptOv Win = $panelTitle, value = 0

	SetVariable SetVar_DataAcq_ITI WIN = $panelTitle, value = _NUM:0

	SetVariable SetVar_DataAcq_TPDuration  WIN = $panelTitle,value= _NUM:10
	SetVariable SetVar_DataAcq_TPAmplitude  WIN = $panelTitle,value= _NUM:10
	SetVariable SetVar_DataAcq_TPBaselinePerc  WIN = $panelTitle,value= _NUM:25

	popValue = DAP_FormatStimSetPopupValue(CHANNEL_TYPE_TTL)
	PopupMenu Wave_TTL_00 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_01 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_02 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_03 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_04 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_05 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_06 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_07 Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu Wave_TTL_All Win = $panelTitle ,mode=1, userdata(MenuExp) = "", value=#popValue

	CheckBox Check_Settings_TrigOut Win = $panelTitle, value = 0
	CheckBox Check_Settings_TrigIn Win = $panelTitle, value = 0

	SetVariable SetVar_DataAcq_SetRepeats WIN = $panelTitle,value= _NUM:1

	CheckBox Check_Settings_UseDoublePrec WIN = $panelTitle, value= 0
	CheckBox Check_Settings_SkipAnalysFuncs WIN = $panelTitle, value= 0
	PopupMenu Popup_Settings_SampIntMult WIN = $panelTitle, mode = 1

	CheckBox Check_AsyncAD_00 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_01 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_02 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_03 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_04 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_05 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_06 WIN = $panelTitle,value= 0
	CheckBox Check_AsyncAD_07 WIN = $panelTitle,value= 0

	SetVariable Gain_AsyncAD_00 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_01 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_02 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_03 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_04 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_05 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_06 WIN = $panelTitle,value= _NUM:1
	SetVariable Gain_AsyncAD_07 WIN = $panelTitle,value= _NUM:1

	SetVariable Title_AsyncAD_00 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_01 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_02 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_03 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_04 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_05 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_06 WIN = $panelTitle,value= _STR:""
	SetVariable Title_AsyncAD_07 WIN = $panelTitle,value= _STR:""

	SetVariable Unit_AsyncAD_00 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_01 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_02 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_03 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_04 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_05 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_06 WIN = $panelTitle,value= _STR:""
	SetVariable Unit_AsyncAD_07 WIN = $panelTitle,value= _STR:""

	CheckBox Radio_ClampMode_0 WIN = $panelTitle,value= 1,mode=1

	// Sets MIES headstage to V-Clamp
	CheckBox Radio_ClampMode_0 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_1 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_2 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_3 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_4 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_5 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_6 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_7 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_8 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_9 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_10 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_11 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_12 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_13 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_14 WIN = $panelTitle, value= 1,mode=1
	CheckBox Radio_ClampMode_15 WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_1IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_3IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_5IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_7IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_9IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_11IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_13IZ WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_15IZ WIN = $panelTitle, value= 0,mode=1

	// clamp mode sub tab
	PGC_SetAndActivateControl(panelTitle, "tab_DataAcq_Amp", val = 0)
	PGC_SetAndActivateControl(panelTitle, "ADC", val = 6)

	CheckBox Radio_ClampMode_AllVClamp WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_AllIClamp WIN = $panelTitle, value= 0,mode=1
	CheckBox Radio_ClampMode_AllIZero WIN = $panelTitle, value= 0,mode=1

	CheckBox Check_DataAcq_SendToAllAmp WIN = $panelTitle, value= 0

	SetVariable SetVar_Settings_VC_DAgain WIN = $panelTitle, value= _NUM:20
	SetVariable SetVar_Settings_VC_ADgain WIN = $panelTitle, value= _NUM:0.00999999977648258
	SetVariable SetVar_Settings_IC_ADgain WIN = $panelTitle, value= _NUM:0.00999999977648258

	PopupMenu Popup_Settings_VC_DA WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_VC_AD WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_IC_AD WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_HeadStage WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_IC_DA WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_IC_DA WIN = $panelTitle, mode=1

	SetVariable SetVar_Settings_IC_DAgain WIN = $panelTitle, value= _NUM:400

	SetVariable Search_DA_00 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_01 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_02 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_03 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_04 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_05 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_06 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_07 WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_All WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_AllVClamp WIN = $panelTitle, value= _STR:""
	SetVariable Search_DA_AllIClamp WIN = $panelTitle, value= _STR:""

	SetVariable Search_TTL_00 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_01 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_02 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_03 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_04 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_05 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_06 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_07 WIN = $panelTitle, value= _STR:""
	SetVariable Search_TTL_All WIN = $panelTitle, value= _STR:""

	popValue = DAP_FormatStimSetPopupValue(CHANNEL_TYPE_DAC)
	PopupMenu IndexEnd_DA_00 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_01 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_02 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_03 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_04 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_05 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_06 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_07 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_All WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_AllVClamp WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_DA_AllICLamp WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue

	popValue = DAP_FormatStimSetPopupValue(CHANNEL_TYPE_TTL)
	PopupMenu IndexEnd_TTL_00 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_01 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_02 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_03 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_04 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_05 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_06 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_07 WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue
	PopupMenu IndexEnd_TTL_All WIN = $panelTitle, mode=1, userdata(MenuExp) = "", value=#popValue

	PopupMenu popup_Settings_Amplifier,mode=1,popvalue="- none -"
	// don't make the scope subwindow part of the recreation macro
	CheckBox check_Settings_ShowScopeWindow WIN = $panelTitle, value= 0
	SCOPE_KillScopeWindowIfRequest(panelTitle)
	CheckBox check_Settings_ShowScopeWindow WIN = $panelTitle, value= 1

	CheckBox check_Settings_ITITP WIN = $panelTitle, value= 1
	CheckBox check_Settings_TPAfterDAQ WIN = $panelTitle, value= 0

	CheckBox Check_Settings_NwbExport WIN = $panelTitle,value= 0
	PopupMenu Popup_Settings_NwbVersion WIN = $panelTitle, mode=2, popvalue="2"

	PopupMenu Popup_Settings_DecMethod, mode=2, popvalue="MinMax"

	SetVariable min_AsyncAD_00 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_00 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_00  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_01 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_01 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_01  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_02 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_02 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_02  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_03 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_03 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_03  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_04 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_04 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_04  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_05 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_05 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_05  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_06 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_06 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_06  WIN = $panelTitle,value= 0

	SetVariable min_AsyncAD_07 WIN = $panelTitle,value= _NUM:0
	SetVariable max_AsyncAD_07 WIN = $panelTitle,value= _NUM:0
	CheckBox check_AsyncAlarm_07  WIN = $panelTitle,value= 0

	CheckBox check_DataAcq_RepAcqRandom WIN = $panelTitle,value= 0
	CheckBox check_Settings_Option_3 WIN = $panelTitle,value= 0
	CheckBox check_Settings_ScalingZero WIN = $panelTitle,value= 0
	CheckBox check_Settings_SetOption_04 WIN = $panelTitle,fColor=(65280,43520,0),value= 0

	PopupMenu popup_MoreSettings_Devices WIN=$paneltitle, mode=1

	SetVariable SetVar_Sweep WIN = $panelTitle, limits={0,0,1}, value= _NUM:0

	SetVariable SetVar_DataAcq_dDAQDelay WIN = $panelTitle,value= _NUM:0
	SetVariable setvar_DataAcq_dDAQOptOvPost WIN = $panelTitle,value= _NUM:0
	SetVariable setvar_DataAcq_dDAQOptOvPre WIN = $panelTitle,value= _NUM:0
	SetVariable SetVar_DataAcq_OnsetDelayUser WIN = $panelTitle,value= _NUM:0
	ValDisplay valdisp_DataAcq_OnsetDelayAuto WIN = $panelTitle,value= _NUM:0
	ValDisplay valdisp_DataAcq_SweepsInSet WIN = $panelTitle,value= _NUM:1
	ValDisplay valdisp_DataAcq_SweepsActiveSet WIN = $panelTitle,value= _NUM:1
	ValDisplay valdisp_DataAcq_TrialsCountdown WIN = $panelTitle,value= _NUM:1
	ValDisplay valdisp_DataAcq_ITICountdown WIN = $panelTitle,value= _NUM:0

	SetVariable SetVar_DataAcq_TerminationDelay WIN = $panelTitle,value= _NUM:0

	CheckBox check_Settings_SetOption_5 WIN = $panelTitle,value= 1
	CheckBox Check_DataAcq1_IndexingLocked WIN = $panelTitle, value= 0
	CheckBox Check_DataAcq_Indexing WIN = $panelTitle, value= 0

	SetVariable SetVar_DataAcq_ListRepeats WIN = $panelTitle,limits={1,inf,1},value= _NUM:1

	SetVariable setvar_Settings_TPBuffer WIN = $panelTitle, value= _NUM:1

	CheckBox check_DataAcq_IndexRandom WIN = $panelTitle, fColor=(65280,43520,0),value= 0

	ValDisplay ValDisp_DataAcq_SamplingInt win = $panelTitle, value= _NUM:0

	SetVariable SetVar_DataAcq_TPAmplitudeIC WIN = $panelTitle,value= _NUM:-50
	SetVariable SetVar_Hardware_VC_DA_Unit WIN = $panelTitle,value= _STR:"mV"
	SetVariable SetVar_Hardware_IC_DA_Unit WIN = $panelTitle,value= _STR:"pA"
	SetVariable SetVar_Hardware_VC_AD_Unit WIN = $panelTitle,value= _STR:"pA"
	SetVariable SetVar_Hardware_IC_AD_Unit WIN = $panelTitle,value= _STR:"mV"

	SetVariable Unit_DA_00 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_01 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_02 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_03 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_04 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_05 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_06 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_DA_07 WIN = $panelTitle,limits={0,inf,1},value= _STR:""

	SetVariable Unit_AD_00 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_01 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_02 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_03 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_04 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_05 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_06 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_07 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_08 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_09 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_10 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_11 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_12 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_13 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_14 WIN = $panelTitle,limits={0,inf,1},value= _STR:""
	SetVariable Unit_AD_15 WIN = $panelTitle,limits={0,inf,1},value= _STR:""

	PopupMenu popup_Hardware_AvailITC1600s WIN = $panelTitle,mode=1
	PopupMenu popup_Hardware_YokedDACs WIN = $panelTitle,mode=1

	SetVariable SetVar_Hardware_Status WIN = $panelTitle,value= _STR:"Independent",noedit= 1
	SetVariable SetVar_Hardware_YokeList WIN = $panelTitle,value= _STR:"No Yoked Devices",noedit= 1
	PopupMenu popup_Hardware_YokedDACs WIN = $panelTitle, mode=0,value=DAP_GUIListOfYokedDevices()

	SetVariable SetVar_DataAcq_Hold_IC WIN = $panelTitle, value= _NUM:0
	SetVariable Setvar_DataAcq_PipetteOffset_VC WIN = $panelTitle, value= _NUM:0
	SetVariable Setvar_DataAcq_PipetteOffset_IC WIN = $panelTitle, value= _NUM:0
	SetVariable SetVar_DataAcq_BB WIN = $panelTitle,limits={0,inf,1},value= _NUM:0
	SetVariable SetVar_DataAcq_CN WIN = $panelTitle,limits={-8,16,1},value= _NUM:0

	CheckBox check_DatAcq_HoldEnable WIN = $panelTitle,value= 0
	CheckBox check_DatAcq_RsCompEnable WIN = $panelTitle,value= 0
	CheckBox check_DatAcq_CNEnable WIN = $panelTitle,value= 0

	Slider slider_DataAcq_ActiveHeadstage  WIN = $panelTitle,value= 0
	CheckBox check_DataAcq_AutoBias WIN = $panelTitle,value= 0

	// auto bias default: -70 plus/minus 0.5 mV @ 200 pA
	SetVariable SetVar_DataAcq_AutoBiasV      WIN = $panelTitle, value = _NUM:-70
	SetVariable SetVar_DataAcq_AutoBiasVrange WIN = $panelTitle, value = _NUM:0.5
	SetVariable setvar_DataAcq_IbiasMax       WIN = $panelTitle, value = _NUM:200

	// settings tab
	SetVariable setvar_Settings_AutoBiasPerc  WIN = $panelTitle, value = _NUM:15
	SetVariable setvar_Settings_AutoBiasInt   WIN = $panelTitle, value = _NUM:1

	SetVariable SetVar_DataAcq_Hold_VC WIN = $panelTitle,value= _NUM:0
	CheckBox check_DatAcq_HoldEnableVC WIN = $panelTitle,value= 0
	SetVariable SetVar_DataAcq_WCR WIN = $panelTitle,value= _NUM:0
	CheckBox check_DatAcq_WholeCellEnable WIN = $panelTitle,value= 0
	SetVariable SetVar_DataAcq_WCC  WIN = $panelTitle,value= _NUM:0
	SetVariable SetVar_DataAcq_RsCorr WIN = $panelTitle,value= _NUM:0
	SetVariable SetVar_DataAcq_RsPred WIN = $panelTitle,value= _NUM:0
	CheckBox Check_Settings_AlarmPauseAcq WIN = $panelTitle,value= 0
	CheckBox Check_Settings_AlarmAutoRepeat WIN = $panelTitle,value= 0
	CheckBox check_Settings_AmpMCCdefault WIN = $panelTitle,value= 0
	CheckBox check_Settings_SyncMiesToMCC WIN = $panelTitle,value= 0
	CheckBox check_DataAcq_Amp_Chain WIN = $panelTitle,value= 0
	CheckBox check_DatAcq_BBEnable WIN = $panelTitle,value= 0
	CheckBox check_Settings_MD WIN = $panelTitle,value= 1
	EnableControls(panelTitle, "check_Settings_MD")
	SetVariable setvar_Settings_TP_RTolerance WIN = $panelTitle,value= _NUM:1
	CheckBox check_Settings_SaveAmpSettings WIN = $panelTitle,value= 0
	CheckBox check_Settings_AmpIEQZstep WIN = $panelTitle,value= 0
	CheckBox Check_Settings_ITImanualStart WIN = $panelTitle,value= 0

	SetControlUserData(panelTitle, "Check_Settings_BkgTP", "oldState", "")
	SetControlUserData(panelTitle, "Check_Settings_BackgrndDataAcq", "oldState", "")

	CheckBox Check_Settings_BkgTP WIN = $panelTitle,value= 1
	CheckBox Check_Settings_BackgrndDataAcq WIN = $panelTitle, value= 1

	CheckBox Check_Settings_InsertTP WIN = $panelTitle,value= 1
	CheckBox Check_DataAcq_Get_Set_ITI WIN = $panelTitle, value = 1
	CheckBox check_Settings_TP_SaveTP WIN = $panelTitle, value = 0
	CheckBox check_settings_TP_show_steady WIN = $panelTitle, value = 1
	CheckBox check_settings_TP_show_peak WIN = $panelTitle, value = 1
	CheckBox check_Settings_DisablePressure WIN = $panelTitle, value = 0
	CheckBox check_Settings_RequireAmpConn WIN = $panelTitle, value = 1
	// Oscilloscope section in setting tab
	CheckBox check_settings_show_power WIN = $panelTitle, value = 0
	SetVariable setvar_Settings_OsciUpdInt, win=$panelTitle, value= _NUM:500
	SetVariable setvar_Settings_OsciUpdExt, win=$panelTitle, value= _NUM:10
	PopupMenu Popup_Settings_OsciUpdMode WIN = $panelTitle, value=DAP_GetOsciUpdModes(), mode=3
	EnableControls(panelTitle, "Popup_Settings_OsciUpdMode")

	// defaults are also hardcoded in P_GetPressureDataWaveRef
	// and P_PressureDataTxtWaveRef
	SetPopupMenuVal(panelTitle, "popup_Settings_Pressure_dev", NONE)
	SetPopupMenuIndex(panelTitle, "popup_Settings_Pressure_dev", 0)
	SetPopupMenuIndex(panelTitle, "Popup_Settings_Pressure_DA", 0)
	SetPopupMenuIndex(panelTitle, "Popup_Settings_Pressure_AD", 0)
	SetPopupMenuIndex(panelTitle, "Popup_Settings_Pressure_TTLA", 1)
	SetPopupMenuIndex(panelTitle, "Popup_Settings_Pressure_TTLB", 0)
	SetSetVariable(panelTitle, "setvar_Settings_Pressure_DAgain", 2)
	SetSetVariable(panelTitle, "setvar_Settings_Pressure_ADgain", 0.5)
	SetSetVariableString(panelTitle, "SetVar_Hardware_Pressur_DA_Unit", "psi")
	SetSetVariableString(panelTitle, "SetVar_Hardware_Pressur_AD_Unit", "psi")
	SetVariable setvar_Settings_InAirP         , win=$panelTitle, value= _NUM:3.8
	SetVariable setvar_Settings_InBathP        , win=$panelTitle, value= _NUM:0.55
	SetVariable setvar_Settings_InSliceP       , win=$panelTitle, value= _NUM:0.2
	SetVariable setvar_Settings_NearCellP      , win=$panelTitle, value= _NUM:0.6
	SetVariable setvar_Settings_SealStartP     , win=$panelTitle, value= _NUM:-0.2
	SetVariable setvar_Settings_SealMaxP       , win=$panelTitle, value= _NUM:-1.4
	SetVariable setvar_Settings_SurfaceHeight  , win=$panelTitle, value= _NUM:3500
	SetVariable setvar_Settings_SliceSurfHeight, win=$panelTitle, value= _NUM:350
	CheckBox check_Settings_DisablePressure    , win=$panelTitle, value= 0
	CheckBox check_DatAcq_ApproachAll          , win=$panelTitle, value= 0
	CheckBox check_DatAcq_BreakInAll           , win=$panelTitle, value= 0
	CheckBox check_DatAcq_SealALl              , win=$panelTitle, value= 0
	CheckBox check_DatAcq_ClearEnable          , win=$panelTitle, value= 0
	CheckBox check_Settings_AmpIEQZstep        , win=$panelTitle, value= 0
	CheckBox check_DatAcq_SealAtm              , win=$panelTitle, value= 0
	CheckBox check_DatAcq_ApproachNear         , win=$panelTitle, value= 0
	CheckBox check_DataAcq_ManPressureAll      , win=$panelTitle, value= 0
	CheckBox check_Settings_SaveAmpSettings    , win=$panelTitle, value= 1
	SetVariable setvar_DataAcq_PPDuration, win=$panelTitle, value= _NUM:0,limits={0,300,1}
	SetVariable setvar_DataAcq_PPPressure, win=$panelTitle, value= _NUM:0,limits={-10,10,1}
	SetVariable setvar_DataAcq_SSPressure, win=$panelTitle, value= _NUM:0,limits={-10,10,1}

	// user pressure
	PGC_SetAndActivateControl(panelTitle, "tab_DataAcq_Pressure", val = 0, switchtab = 1)
	PopupMenu popup_Settings_UserPressure WIN = $panelTitle, mode=1,value= #"\"- none -;\""
	EnableControl(panelTitle, "popup_Settings_UserPressure")
	PopupMenu Popup_Settings_UserPressure_ADC  WIN = $panelTitle, mode=1
	EnableControl(panelTitle, "Popup_Settings_UserPressure_ADC")
	EnableControl(panelTitle, "button_Hardware_PUser_Enable")
	DisableControl(panelTitle, "button_Hardware_PUser_Disable")
	PGC_SetAndActivateControl(panelTitle, "ADC", val = 6)

   ValDisplay valdisp_DataAcq_P_LED_0 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_1 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_2 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_3 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_4 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_5 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_6 WIN = $panelTitle, value= _NUM:-1
   ValDisplay valdisp_DataAcq_P_LED_7 WIN = $panelTitle, value= _NUM:-1

   ValDisplay valdisp_DataAcq_P_LED_0,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_1,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_2,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_3,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_4,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_5,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_6,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)
   ValDisplay valdisp_DataAcq_P_LED_7,limits={-1,2,0},barmisc={0,0},mode= 2,highColor= (65535,49000,49000),lowColor= (65535,65535,65535),zeroColor= (49151,53155,65535)

   ValDisplay valdisp_DataAcq_P_0,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_0,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_1,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_1,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_2,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_2,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_3,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_3,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_4,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_4,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_5,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_5,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_6,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_6,limits={0,0,0},barmisc={0,1000},value= #"0.00"
   ValDisplay valdisp_DataAcq_P_7,valueBackColor=(65535,65535,65535,0)
   ValDisplay valdisp_DataAcq_P_7,limits={0,0,0},barmisc={0,1000},value= #"0.00"

	ValDisplay valdisp_DataAcq_P_LED_Approach WIN = $panelTitle, value= _NUM:0
	ValDisplay valdisp_DataAcq_P_LED_Seal WIN = $panelTitle, value= _NUM:0
	ValDisplay valdisp_DataAcq_P_LED_Breakin WIN = $panelTitle, value= _NUM:0
	ValDisplay valdisp_DataAcq_P_LED_Clear WIN = $panelTitle, value= _NUM:0

	CheckBox check_Settings_UserP_Approach WIN = $panelTitle, value=0
	CheckBox check_Settings_UserP_BreakIn WIN = $panelTitle, value=0
	CheckBox check_Settings_UserP_Seal WIN = $panelTitle, value=0
	CheckBox check_Settings_UserP_Clear WIN = $panelTitle, value=0
	CheckBox check_DataACq_Pressure_AutoOFF WIN = $panelTitle, value=0
	CheckBox check_DataACq_Pressure_User WIN = $panelTitle, value=0
	CheckBox check_DA_applyOnModeSwitch WIN = $panelTitle, value=0

	PopupMenu Popup_Settings_SampIntMult WIN = $panelTitle, mode=1
	PopupMenu Popup_Settings_FixedFreq WIN = $panelTitle, mode=1
	EnableControls(panelTitle, "Popup_Settings_SampIntMult;Popup_Settings_FixedFreq")

	SetVariable setvar_dataAcq_skipAhead win=$panelTitle,limits={0,0,1},value= _NUM:0
	EnableControl(panelTitle, "button_Hardware_P_Enable")
	DisableControl(panelTitle, "button_Hardware_P_Disable")
	EnableControls(panelTitle, "Button_DataAcq_SkipBackwards;Button_DataAcq_SkipForward")

	SearchForInvalidControlProcs(panelTitle)

	Execute/P/Z "DoWindow/R " + BASE_WINDOW_TITLE
	Execute/P/Q/Z "COMPILEPROCEDURES "
End

Function DAP_WindowHook(s)
	STRUCT WMWinHookStruct &s

	string panelTitle, ctrl
	variable sgn, i

	switch(s.eventCode)
		case EVENT_KILL_WINDOW_HOOK:
			panelTitle = s.winName

			NVAR JSONid = $GetSettingsJSONid()
			PS_StoreWindowCoordinate(JSONid, panelTitle)

			try
				ClearRTError()
				DAP_UnlockDevice(panelTitle); AbortOnRTE
			catch
				// do nothing
			endtry

			// return zero so that other hooks are called as well
			break
		case 22: // mouse wheel
			panelTitle = s.winName

			if(GetTabID(panelTitle, "ADC") != DATA_ACQU_TAB_NUM)
				break
			endif

			for(i = 0; i < NUM_HEADSTAGES; i += 1)
				ctrl = StringFromList(i, PRESSURE_CONTROL_LED_DASHBOARD)

				STRUCT RectF ctrlRect
				GetControlCoordinates(panelTitle, ctrl, ctrlRect)

				// help the user by allowing some more vertical space
				ctrlRect.top    -= 20
				ctrlRect.bottom += 20

				if(IsInsideRect(s.mouseLoc, ctrlRect))
					P_SetPressureOffset(s.winName, i, 0.1 * sign(s.wheelDy))
					break
				endif
			endfor
			break
	endswitch

	return 0
End

/// @brief Return a popValue string suitable for stimsets
/// @todo rework the code to have a fixed popValue
Function/S DAP_FormatStimSetPopupValue(variable channelType, [string searchString])
	if(ParamIsDefault(searchString))
		searchString = "*"
	endif

	string str
	sprintf str, "\"%s;\"+WB_GetStimsetList(channelType = %d, searchString = \"%s\")", NONE, channelType, searchString

	return str
End

/// @brief Check by querying the GUI if the device is a leader
///
/// Outside callers should use DeviceHasFollower() instead.
static Function DAP_DeviceIsLeader(panelTitle)
	string panelTitle

	return cmpstr(DAG_GetTextualValue(panelTitle, "setvar_Hardware_Status"),LEADER) == 0
End

/// @brief Updates the yoking controls on all locked/unlocked panels
static Function DAP_UpdateAllYokeControls()

	string   ListOfLockedITC1600    = GetListOfLockedITC1600Devices()
	variable ListOfLockedITC1600Num = ItemsInList(ListOfLockedITC1600)
	string   ListOfLockedITC        = GetListOfLockedDevices()
	variable ListOfLockedITCNum     = ItemsInList(ListOfLockedITC)

	string panelTitle
	variable i
	for(i=0; i<ListOfLockedITCNum; i+=1)
		panelTitle = StringFromList(i,ListOfLockedITC)

		// don't touch the current leader
		if(DAP_DeviceIsLeader(panelTitle))
			continue
		endif

		DisableControls(panelTitle,YOKE_LIST_OF_CONTROLS)
		DAP_UpdateYokeControls(panelTitle)

		if(ListOfLockedITC1600Num >= 2 && DeviceCanLead(panelTitle))
			// ensures yoking controls are only enabled on the ITC1600_Dev_0
			// a requirement of the ITC XOP
			EnableControl(panelTitle,"button_Hardware_Lead1600")
		endif
	endfor

	string   ListOfUnlockedITC     = GetListOfUnlockedDevices()
	variable ListOfUnlockedITCNum  = ItemsInList(ListOfUnlockedITC)

	for(i=0; i<ListOfUnLockedITCNum; i+=1)
		panelTitle = StringFromList(i,ListOfUnLockedITC)
		DisableControls(panelTitle,YOKE_LIST_OF_CONTROLS)
	endfor
End

Function/S DAP_GUIListOfYokedDevices()

	SVAR listOfFollowerDevices = $GetFollowerList(ITC1600_FIRST_DEVICE)
	if(cmpstr(listOfFollowerDevices, "") != 0)
		return listOfFollowerDevices
	endif

	return "No Yoked Devices"
End

Function DAP_UpdateYokeControls(panelTitle)
	string panelTitle

	if(GetTabID(panelTitle, "ADC") != HARDWARE_TAB_NUM)
		return NaN
	endif

	if(!DeviceCanFollow(panelTitle))
		HideControls(panelTitle,YOKE_LIST_OF_CONTROLS)
		SetVariable setvar_Hardware_YokeList win = $panelTitle, value = _STR:"Device is not yokeable"
	elseif(DeviceIsFollower(panelTitle))
		HideControls(panelTitle,YOKE_LIST_OF_CONTROLS)
	else
		ShowControls(panelTitle,YOKE_LIST_OF_CONTROLS)
		SetVariable setvar_Hardware_YokeList win = $panelTitle, value = _STR:DAP_GUIListOfYokedDevices()
	endif
End

/// @brief Called by ACL tab control after the tab is updated.
/// see line 257 of ACL_TabUtilities.ipf
Function DAP_TabControlFinalHook(tca)
	STRUCT WMTabControlAction &tca

	DAP_UpdateYokeControls(tca.win)

	if(DAP_DeviceIsUnLocked(tca.win))
		print "Please lock the panel to a DAC in the Hardware tab"
		ControlWindowToFront()
		return 0
	endif

	return 0
End

Function DAP_SetVarProc_Channel_Search(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable channelIndex, channelType, channelControl
	variable i, isCustomSearchString
	string ctrl, searchString, str
	string popupValue, listOfWaves
	string panelTitle, varstr, sel

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			panelTitle = sva.win
			ctrl       = sva.ctrlName
			varstr     = sva.sval

			ASSERT(!DAP_ParsePanelControl(ctrl, channelIndex, channelType, channelControl), "Invalid control format")
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval, str = sva.sval)

			if(isEmpty(varstr))
				searchString = "*"
			else
				isCustomSearchString = 1
				searchString = varStr
			endif

			listOfWaves = WB_GetStimsetList(channelType = channelType, searchString = searchString)
			popupValue = DAP_FormatStimSetPopupValue(channelType, searchString = searchString)

			ctrl = GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_WAVE)
			PopupMenu $ctrl win=$panelTitle, value=#popupValue, userdata(MenuExp)=listOfWaves
			sel = GetPopupMenuString(panelTitle, ctrl)
			PopupMenu $ctrl win=$panelTitle, popmatch=sel

			ctrl = GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_INDEX_END)
			PopupMenu $ctrl win=$panelTitle, value=#popupValue
			sel = GetPopupMenuString(panelTitle, ctrl)
			PopupMenu $ctrl win=$panelTitle, popmatch=sel

			if(DAP_IsAllControl(channelIndex))
				for(i = 0; i < GetNumberFromType(var=channelType); i += 1)

					if(!DAP_DACHasExpectedClampMode(panelTitle, channelIndex, i, channelType))
						continue
					endif

					ctrl = GetPanelControl(i, channelType, CHANNEL_CONTROL_SEARCH)
					str = SelectString(isCustomSearchString, "", searchString)
					PGC_SetAndActivateControl(panelTitle, ctrl, str = str)
					DAG_Update(panelTitle, ctrl, str = str)

					ctrl = GetPanelControl(i, channelType, CHANNEL_CONTROL_WAVE)
					PopupMenu $ctrl win=$panelTitle, value=#popupValue, userdata(MenuExp)=listOfWaves
					sel = GetPopupMenuString(panelTitle, ctrl)
					PopupMenu $ctrl win=$panelTitle, popmatch=sel

					ctrl = GetPanelControl(i, channelType, CHANNEL_CONTROL_INDEX_END)
					PopupMenu $ctrl win=$panelTitle, value=#popupValue
					sel = GetPopupMenuString(panelTitle, ctrl)
					PopupMenu $ctrl win=$panelTitle, popmatch=sel
				endfor
			endif
			break
	endswitch

	return 0
End

Function DAP_DAorTTLCheckProc(cba) : CheckBoxControl
	struct WMCheckboxAction &cba

	string panelTitle, control

	switch(cba.eventCode)
		case 2:
			try
				paneltitle = cba.win
				control    = cba.ctrlName
				DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
				DAP_AdaptAssocHeadstageState(panelTitle, control)
				DAP_UpdateDAQControls(panelTitle, REASON_STIMSET_CHANGE | REASON_HEADSTAGE_CHANGE)
			catch
				SetCheckBoxState(panelTitle, control, !cba.checked)
				DAG_Update(cba.win, cba.ctrlName, val = !cba.checked)
				Abort
			endtry

			break
	endswitch
End

Function DAP_CheckProc_Channel_All(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string panelTitle, control, lbl
	variable i, checked, allChecked, channelIndex, channelType, controlType, numEntries

	switch(cba.eventCode)
		case 2: // mouse up
			paneltitle = cba.win
			allChecked = cba.checked
			ASSERT(!DAP_ParsePanelControl(cba.ctrlName, channelIndex, channelType, controlType), "Invalid control format")
			ASSERT(controlType  == CHANNEL_CONTROL_CHECK, "Invalid control type")
			ASSERT(DAP_ISAllControl(channelIndex), "Invalid channel index")
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)

			numEntries = GetNumberFromType(var=channelType)

			lbl = GetSpecialControlLabel(channelType, CHANNEL_CONTROL_CHECK)

			for(i = 0; i < numEntries; i += 1)
				checked = DAG_GetNumericalValue(panelTitle, lbl, index = i)

				if(checked == allChecked)
					continue
				endif

				if(!DAP_DACHasExpectedClampMode(panelTitle, channelIndex, i, channelType))
					continue
				endif

				control = GetPanelControl(i, channelType, CHANNEL_CONTROL_CHECK)
				PGC_SetAndActivateControl(panelTitle, control, val=allChecked)
			endfor
			break
	endswitch

	return 0
End

/// @brief Determines if the control refers to an "All" control
Function DAP_IsAllControl(channelIndex)
	variable channelIndex

	return channelIndex == CHANNEL_INDEX_ALL \
	       || channelIndex == CHANNEL_INDEX_ALL_V_CLAMP \
	       || channelIndex == CHANNEL_INDEX_ALL_I_CLAMP
End

/// @brief Helper for "All" controls in the DA tab
///
/// @returns 0 if the given channel is a DA channel and not in the expected
///          clamp mode as determined by `controlChannelIndex`, 1 otherwise
Function DAP_DACHasExpectedClampMode(panelTitle, controlChannelIndex, channelNumber, channelType)
	string panelTitle
	variable controlChannelIndex, channelNumber, channelType

	variable headstage, clampMode

	ASSERT(DAP_IsAllControl(controlChannelIndex), "Invalid controlChannelIndex")

	if(channelType != CHANNEL_TYPE_DAC || controlChannelIndex == CHANNEL_INDEX_ALL)
		return 1 // don't care
	endif

	headstage = AFH_GetHeadstageFromDAC(panelTitle, channelNumber)

	if(!IsFinite(headstage)) // unassociated AD/DA channels
		return 0
	endif

	clampMode = DAG_GetHeadstageMode(panelTitle, headStage)

	if(clampMode == V_CLAMP_MODE && controlChannelIndex == CHANNEL_INDEX_ALL_V_CLAMP)
		return 1
	endif

	if(clampMode == I_CLAMP_MODE && controlChannelIndex == CHANNEL_INDEX_ALL_I_CLAMP)
		return 1
	endif

	return 0
end

Function DAP_CheckProc_AD(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string panelTitle, control

	switch(cba.eventCode)
		case 2: // mouse up
			try
				paneltitle = cba.win
				control    = cba.ctrlName

				DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
				DAP_AdaptAssocHeadstageState(panelTitle, control)
			catch
				SetCheckBoxState(panelTitle, control, !cba.checked)
				DAG_Update(cba.win, cba.ctrlName, val = !cba.checked)
				Abort
			endtry

			break
	endswitch

	return 0
End

/// @brief Get the headstage for the given channel number and type from the amplifier settings
///
/// This is different from what GetChannelClampMode holds as we here hold the
/// setup information and GetChannelClampMode holds what is currently active.
Function GetHeadstageFromSettings(panelTitle, channelType, channelNumber, clampMode)
	string panelTitle
	variable channelType, channelNumber, clampMode

	variable i, row

	if(!AI_IsValidClampMode(clampMode))
		return NaN
	endif

	WAVE chanAmpAssign = GetChanAmpAssign(panelTitle)

	if(channelType == XOP_CHANNEL_TYPE_ADC)
		row = clampMode == V_CLAMP_MODE ? 2 : 2 + 4
	elseif(channelType == XOP_CHANNEL_TYPE_DAC)
		row = clampMode == V_CLAMP_MODE ? 0 : 0 + 4
	else
		ASSERT(0, "Unexpected clamp mode")
	endif

	for(i = 0; i < NUM_HEADSTAGES; i += 1)
		if(chanAmpAssign[row][i] == channelNumber)
			return i
		endif
	endfor

	return NaN
 End

/// @brief Adapt the state of the associated headstage on DA/AD channel change
///
static Function DAP_AdaptAssocHeadstageState(panelTitle, checkboxCtrl)
	string panelTitle
	string checkboxCtrl

	string headStageCheckBox
	variable headstage, idx, channelType, controlType
	variable headstageState, headStageFromSettingsVC, headStageFromSettingsIC
	string checkboxLabel, headstageLabel

	DAP_AbortIfUnlocked(panelTitle)

	ASSERT(!DAP_ParsePanelControl(checkboxCtrl, idx, channelType, controlType), "Invalid control format")
	ASSERT(CHANNEL_CONTROL_CHECK == controlType, "Not a valid control type")

	if(channelType == CHANNEL_TYPE_DAC)
		headStage = AFH_GetHeadstageFromDAC(panelTitle, idx)
		headStageFromSettingsVC = GetHeadstageFromSettings(panelTitle, XOP_CHANNEL_TYPE_DAC, idx, V_CLAMP_MODE)
		headStageFromSettingsIC = GetHeadstageFromSettings(panelTitle, XOP_CHANNEL_TYPE_DAC, idx, I_CLAMP_MODE)
	elseif(channelType == CHANNEL_TYPE_ADC)
		headStage = AFH_GetHeadstageFromADC(panelTitle, idx)
		headStageFromSettingsVC = GetHeadstageFromSettings(panelTitle, XOP_CHANNEL_TYPE_ADC, idx, V_CLAMP_MODE)
		headStageFromSettingsIC = GetHeadstageFromSettings(panelTitle, XOP_CHANNEL_TYPE_ADC, idx, I_CLAMP_MODE)
	elseif(channelType == CHANNEL_TYPE_TTL)
		// nothing to do
		headStageFromSettingsVC = NaN
		headStageFromSettingsIC = NaN
		return NaN
	endif

	// headStage can be NaN for non associated DA/AD channels
	if(!IsFinite(headStage))
		if(headStageFromSettingsIC == headStageFromSettingsVC)
			// be nice to users and activate the headstage for them
			headStage = headStageFromSettingsIC
		else
			return NaN
		endif
	endif

	checkboxLabel  = GetSpecialControlLabel(channelType, CHANNEL_CONTROL_CHECK)
	headstageLabel = GetSpecialControlLabel(CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK)
	headstageState = DAG_GetNumericalValue(panelTitle, headstageLabel, index = headstage)

	if(DAG_GetNumericalValue(panelTitle, checkboxLabel, index = idx) == headstageState)
		// nothing to do
		return NaN
	endif

	headStageCheckBox = GetPanelControl(headstage, CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK)
	PGC_SetAndActivateControl(panelTitle, headStageCheckBox, val=!headstageState)
End

/// @brief Return the repeated acquisition cycle ID for the given devide.
///
/// Follower and leader will have the same repeated acquisition cycle ID.
static Function DAP_GetRAAcquisitionCycleID(panelTitle)
	string panelTitle

	DAP_AbortIfUnlocked(panelTitle)

	if(DeviceIsFollower(panelTitle))
		NVAR raCycleIDLead = $GetRepeatedAcquisitionCycleID(ITC1600_FIRST_DEVICE)
		return raCycleIDLead
	else
		return GetNextRandomNumberForDevice(panelTitle)
	endif
End

/// @brief One time initialization before data acquisition
///
/// @param panelTitle device
/// @param runMode    One of @ref DAQRunModes except DAQ_NOT_RUNNING
Function DAP_OneTimeCallBeforeDAQ(panelTitle, runMode)
	string panelTitle
	variable runMode

	variable i, DAC, ADC, multiDevGUIEnState, hardwareType

	ASSERT(runMode != DAQ_NOT_RUNNING, "Invalid running mode")

	NVAR count = $GetCount(panelTitle)
	count = 0

	NVAR activeSetCount = $GetActiveSetCount(panelTitle)
	activeSetCount = IDX_CalculcateActiveSetCount(panelTitle)

	NVAR repurposeTime = $GetRepurposedSweepTime(panelTitle)
	repurposeTime = 0

	NVAR raCycleID = $GetRepeatedAcquisitionCycleID(panelTitle)
	raCycleID = DAP_GetRAAcquisitionCycleID(panelTitle)

	NVAR fifoPosition = $GetFifoPosition(panelTitle)
	fifoPosition = NaN

	WAVE stimsetAcqIDHelper = GetStimsetAcqIDHelperWave(panelTitle)
	stimsetAcqIDHelper = NaN

	DAP_ClearDelayedClampModeChange(panelTitle)

	WAVE setEventFlag = GetSetEventFlag(panelTitle)
	setEventFlag[][%PRE_SET_EVENT] = 1

	if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing"))
		IDX_StoreStartFinishForIndexing(panelTitle)
	endif

	// disable the clamp mode checkboxes of all active headstages
	WAVE statusHS = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE)

	for(i = 0; i < NUM_HEADSTAGES; i += 1)

		if(!statusHS[i])
			continue
		endif

		DisableControl(panelTitle, GetPanelControl(i, CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK))

		DAC = AFH_GetDACFromHeadstage(paneltitle, i)

		// DA controls
		DisableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK))
		DisableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN))
		DisableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_UNIT))

		ADC = AFH_GetDACFromHeadstage(paneltitle, i)

		// AD controls
		DisableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK))
		DisableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN))
		DisableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_UNIT))
	endfor

	DisableControls(panelTitle, CONTROLS_DISABLE_DURING_DAQ)

	if(DAG_GetNumericalvalue(panelTitle, "Check_DataAcq_Indexing"))
		DisableControls(panelTitle, CONTROLS_DISABLE_DURING_IDX)
	endif

	NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
	dataAcqRunMode = runMode
	hardwareType = GetHardwareType(panelTitle)
	if(hardwareType == HARDWARE_NI_DAC)
		multiDevGUIEnState = IsControlDisabled(panelTitle, "check_Settings_MD")
		SetControlUserData(panelTitle, "check_Settings_MD", GUI_CONTROLSAVESTATE_DISABLED, num2str(multiDevGUIEnState))

		HW_NI_ResetTaskIDs(panelTitle)
	endif
	DisableControls(panelTitle, "check_Settings_MD")

	DAP_ToggleAcquisitionButton(panelTitle, DATA_ACQ_BUTTON_TO_STOP)
	DisableControls(panelTitle, CONTROLS_DISABLE_DURING_DAQ_TP)

	// turn off active pressure control modes
	if(DAG_GetNumericalValue(panelTitle, "check_Settings_DisablePressure"))
		P_SetAllHStoAtmospheric(panelTitle)
	endif

	RA_StepSweepsRemaining(panelTitle)

	if(DC_GotTPChannelWhileDAQ(panelTitle))
		TP_SetupCommon(panelTitle)
		P_InitBeforeTP(panelTitle)
	endif
End

static Function DAP_ResetClampModeTitle(panelTitle, ctrl)
	string panelTitle, ctrl

	SetControlTitle(panelTitle, ctrl, "")
	SetControlTitleColor(panelTitle, ctrl, 0, 0, 0)
End

/// @brief Enable all controls which were disabled before DAQ by #DAP_OneTimeCallBeforeDAQ
static Function DAP_ResetGUIAfterDAQ(panelTitle)
	string panelTitle

	variable i, ADC, DAC

	for(i = 0; i < NUM_HEADSTAGES; i += 1)
		EnableControl(panelTitle, GetPanelControl(i, CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK))

		DAC = AFH_GetDACFromHeadstage(paneltitle, i)

		// DA controls
		if(IsFinite(DAC))
			EnableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK))
			EnableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN))
			EnableControl(panelTitle, GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_UNIT))
		endif

		ADC = AFH_GetDACFromHeadstage(paneltitle, i)

		// AD controls
		if(IsFinite(ADC))
			EnableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK))
			EnableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN))
			EnableControl(panelTitle, GetPanelControl(ADC, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_UNIT))
		endif

		DAP_ResetClampModeTitle(panelTitle, DAP_GetClampModeControl(I_CLAMP_MODE, i))
		DAP_ResetClampModeTitle(panelTitle, DAP_GetClampModeControl(V_CLAMP_MODE, i))
		DAP_ResetClampModeTitle(panelTitle, DAP_GetClampModeControl(I_EQUAL_ZERO_MODE, i))
	endfor

	EnableControls(panelTitle, CONTROLS_DISABLE_DURING_DAQ)
	EnableControls(panelTitle, CONTROLS_DISABLE_DURING_IDX)

	DAP_ToggleAcquisitionButton(panelTitle, DATA_ACQ_BUTTON_TO_DAQ)
	EnableControls(panelTitle, CONTROLS_DISABLE_DURING_DAQ_TP)

	// fix multi device mode dependent checkbox disabling
	DAP_SwitchSingleMultiMode(panelTitle)
End

/// @brief One time cleaning up after data acquisition
///
/// @param panelTitle      device
/// @param stopReason      One of @ref DAQStoppingFlags
/// @param forcedStop      [optional, defaults to false] if DAQ was aborted (true) or stopped by itself (false)
/// @param startTPAfterDAQ [optional, defaults to true]  start "TP after DAQ" if enabled at the end
Function DAP_OneTimeCallAfterDAQ(string panelTitle, variable stopReason, [variable forcedStop, variable startTPAfterDAQ])
	variable hardwareType

	forcedStop      = ParamIsDefault(forcedStop)      ? 0 : !!forcedStop
	startTPAfterDAQ = ParamIsDefault(startTPAfterDAQ) ? 1 : !!startTPAfterDAQ

	DAP_ResetGUIAfterDAQ(panelTitle)

	NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
	dataAcqRunMode = DAQ_NOT_RUNNING

	// needs to be done before changing the acquisition state
	DAP_DocumentStopReason(panelTitle, stopReason)

	AS_HandlePossibleTransition(panelTitle, AS_POST_DAQ, call = !forcedStop)

	hardwareType = GetHardwareType(panelTitle)
	switch(hardwareType)
		case HARDWARE_NI_DAC:
			if(str2num(GetUserData(panelTitle, "check_Settings_MD", GUI_CONTROLSAVESTATE_DISABLED)) > 0)
				DisableControl(panelTitle, "check_Settings_MD")
			endif
			HW_NI_ResetTaskIDs(panelTitle)
			break
		default:
			EnableControl(panelTitle, "check_Settings_MD")
			break
	endswitch

	NVAR count = $GetCount(panelTitle)
	count = 0

	NVAR activeSetCount = $GetActiveSetCount(panelTitle)
	activeSetCount = NaN

	SetValDisplay(panelTitle, "valdisp_DataAcq_ITICountdown", var = 0)

	NVAR raCycleID = $GetRepeatedAcquisitionCycleID(panelTitle)
	raCycleID = NaN // invalidate

	NVAR fifoPosition = $GetFifoPosition(panelTitle)
	fifoPosition = NaN

	// restore the selected sets before DAQ
	if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing"))
		IDX_ResetStartFinishForIndexing(panelTitle)
	endif

	if(DC_GotTPChannelWhileDAQ(panelTitle))
		TP_TeardownCommon(panelTitle)
	endif

	DAP_ApplyDelayedClampModeChange(panelTitle)

	AS_HandlePossibleTransition(panelTitle, AS_INACTIVE)

	if(!DAG_GetNumericalValue(panelTitle, "check_Settings_TPAfterDAQ") || !startTPAfterDAQ)
		return NaN
	endif

	// 0: holds all calling functions
	// 1: is the current function
	ASSERT(ItemsInList(ListMatch(GetRTStackInfo(0), GetRTStackInfo(1))) == 1 , "Recursion detected, aborting")

	if(DAG_GetNumericalValue(panelTitle, "check_Settings_MD"))
		TPM_StartTestPulseMultiDevice(panelTitle)
	else
		TPS_StartTestPulseSingleDevice(panelTitle)
	endif
End

static Function DAP_DocumentStopReason(string panelTitle, variable stopReason)
	variable sweepNo

	Make/FREE/N=(3, 1)/T keys

	keys[0][0] =  "DAQ stop reason"
	keys[1][0] =  "" // @todo: use enumeration as unit once available
	keys[2][0] =  LABNOTEBOOK_NO_TOLERANCE

	Make/FREE/D/N=(1, 1, LABNOTEBOOK_LAYER_COUNT) values = NaN
	values[][][INDEP_HEADSTAGE] = stopReason

	sweepNo = AS_GetSweepNumber(panelTitle)
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, panelTitle, UNKNOWN_MODE)
End

Function DAP_CheckProc_IndexingState(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string panelTitle

	switch(cba.eventCode)
		case 2: // mouse up

			panelTitle = cba.win
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			DAP_UpdateDAQControls(panelTitle, REASON_STIMSET_CHANGE)

			if(cmpstr(cba.ctrlname, "Check_DataAcq1_IndexingLocked") == 0)
				ToggleCheckBoxes(panelTitle, "Check_DataAcq1_IndexingLocked", "check_Settings_SetOption_5", cba.checked)
				EqualizeCheckBoxes(panelTitle, "Check_DataAcq1_IndexingLocked", "check_Settings_Option_3", cba.checked)
			endif


			break
	endswitch

	return 0
End

Function DAP_CheckProc_ShowScopeWin(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string panelTitle

	switch(cba.eventCode)
		case 2: // mouse up
			panelTitle = cba.win

			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)

			if(cba.checked)
				SCOPE_OpenScopeWindow(panelTitle)
			else
				SCOPE_KillScopeWindowIfRequest(panelTitle)
			endif
			break
	endswitch

	return 0
End

static Function DAP_TurnOffAllChannels(panelTitle, channelType)
	string panelTitle
	variable channelType

	variable i, numEntries
	string ctrl

	numEntries = GetNumberFromType(var=channelType)
	for(i = 0; i < numEntries; i += 1)
		ctrl = GetPanelControl(i, channelType, CHANNEL_CONTROL_CHECK)
		PGC_SetAndActivateControl(panelTitle, ctrl, val=CHECKBOX_UNSELECTED)
	endfor

	// we just called the control procedure for each channel, so we just have to set
	// the checkbox to unselected here
	if(channelType == CHANNEL_TYPE_ADC || channelType == CHANNEL_TYPE_DAC || channelType == CHANNEL_TYPE_TTL)
		ctrl = GetPanelControl(CHANNEL_INDEX_ALL, channelType, CHANNEL_CONTROL_CHECK)
		PGC_SetAndActivateControl(panelTitle, ctrl, val=CHECKBOX_UNSELECTED)
	endif
End

Function DAP_ButtonProc_AllChanOff(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle

	switch(ba.eventcode)
		case 2: // mouse up
			panelTitle = ba.win
			DAP_TurnOffAllChannels(panelTitle, CHANNEL_TYPE_HEADSTAGE)
			DAP_TurnOffAllChannels(panelTitle, CHANNEL_TYPE_ADC)
			DAP_TurnOffAllChannels(panelTitle, CHANNEL_TYPE_DAC)
			DAP_TurnOffAllChannels(panelTitle, CHANNEL_TYPE_TTL)
			break
	endswitch
End

/// @brief Update the ITI for the given device, takes care of handling yoked devices
Function DAP_UpdateITIAcrossSets(panelTitle, maxITI)
	string panelTitle
	variable maxITI

	if(DeviceIsFollower(panelTitle) && DAP_DeviceIsLeader(ITC1600_FIRST_DEVICE))
		DAP_UpdateITIAcrossSets(ITC1600_FIRST_DEVICE, maxITI)
		return NaN
	endif

	if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Get_Set_ITI"))
		PGC_SetAndActivateControl(panelTitle, "SetVar_DataAcq_ITI", val = maxITI)
	endif

	if(DAP_DeviceIsLeader(panelTitle))
		DAP_SyncGuiFromLeaderToFollower(panelTitle)
	endif
End

/// @brief Procedure for DA/TTL popupmenus including indexing wave popupmenus
Function DAP_PopMenuChkProc_StimSetList(pa) : PopupMenuControl
	STRUCT WMPopupAction& pa

	string ctrl, list
	string panelTitle, stimSet
	variable channelIndex, channelType, channelControl, isAllControl, indexing
	variable i, numEntries, idx, dataAcqRunMode, headstage, activeChannel

	switch(pa.eventCode)
		case 2:
			panelTitle = pa.win
			ctrl       = pa.ctrlName
			stimSet    = pa.popStr
			idx        = pa.popNum

			DAP_AbortIfUnlocked(panelTitle)
			ASSERT(!DAP_ParsePanelControl(ctrl, channelIndex, channelType, channelControl), "Invalid control format")
			DAG_Update(pa.win, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)

			indexing      = DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing")
			isAllControl  = DAP_IsAllControl(channelIndex)
			activeChannel = isAllControl                                       \
							|| (DAG_GetNumericalValue(panelTitle, GetSpecialControlLabel(channelType, CHANNEL_CONTROL_CHECK), index = channelIndex)        \
			                   && (channelControl == CHANNEL_CONTROL_WAVE      \
			                   || (channelControl == CHANNEL_CONTROL_INDEX_END \
			                   && indexing)))

			if(activeChannel)
				dataAcqRunMode = DQ_StopDAQ(panelTitle, DQ_STOP_REASON_STIMSET_SELECTION, startTPAfterDAQ = 0)

				// stopping DAQ will reset the stimset popupmenu to its initial value
				// so we have to set the now old value again
				if(indexing && channelControl == CHANNEL_CONTROL_WAVE)
					SetPopupMenuIndex(panelTitle, ctrl, idx - 1)
					DAG_Update(pa.win, pa.ctrlName, val = idx - 1, str = pa.popStr)
				endif
			endif

			if(!isAllControl)
				// check if this is a third party stim set which
				// is not yet reflected in the user data
				list = GetUserData(panelTitle, ctrl, USER_DATA_MENU_EXP)
				if(FindListItem(stimSet, list) == -1)
					DAP_UpdateDaEphysStimulusSetPopups()
				endif
			endif

			if(isAllControl)
				numEntries = GetNumberFromType(var=channelType)
				for(i = 0; i < numEntries; i += 1)
					ctrl = GetPanelControl(i, channelType, channelControl)

					if(!DAP_DACHasExpectedClampMode(panelTitle, channelIndex, i, channelType))
						continue
					endif

					SetPopupMenuIndex(panelTitle, ctrl, idx - 1)
					DAG_Update(pa.win, ctrl, val = idx - 1, str = pa.popStr)
				endfor
			endif

			DAP_UpdateDAQControls(panelTitle, REASON_STIMSET_CHANGE)

			if(activeChannel)
				DQ_RestartDAQ(panelTitle, dataAcqRunMode)
			endif

			break
		endswitch
	return 0
End

Function DAP_SetVarProc_DA_Scale(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable val, channelIndex, channelType, controlType, numEntries, i
	string panelTitle, ctrl

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			val        = sva.dval
			ctrl       = sva.ctrlName
			panelTitle = sva.win

			ASSERT(!DAP_ParsePanelControl(ctrl, channelIndex, channelType, controlType), "Invalid control format")
			ASSERT(DAP_IsAllControl(channelIndex), "Unexpected channel index")
			DAG_Update(sva.win, ctrl, val = sva.dval, str = sva.sval)

			numEntries = GetNumberFromType(var=channelType)

			for(i = 0; i < numEntries; i+= 1)
				ctrl = GetPanelControl(i, channelType, controlType)

				if(!DAP_DACHasExpectedClampMode(panelTitle, channelIndex, i, channelType))
					continue
				endif

				SetSetVariable(panelTitle, ctrl, val)
				DAG_Update(sva.win, ctrl, val = sva.dval, str = sva.sval)
			endfor

			break
		case 9: // mouse down
			ShowSetVariableLimitsSelectionPopup(sva)
			break
	endswitch

	return 0
End

Function DAP_SetVarProc_NextSweepLimit(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string panelTitle
	variable sweepNo

	switch(sva.eventCode)
		case 1:
		case 2:
		case 3:
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
			DAP_UpdateSweepLimitsAndDisplay(sva.win)

			panelTitle = sva.win
			sweepNo = AFH_GetLastSweepAcquired(panelTitle)

			// avoid setting the LBN entry when we have not yet acquired any sweeps
			if(IsValidSweepNumber(sweepNo))
				DAP_SweepRollback(paneltitle, sweepNo, sva.dval)
			endif
			break
	endswitch

	return 0
End

Function DAP_SweepRollback(string paneltitle, variable sweepNo, variable newSweepNo)

	variable rollbackCountNum, rollbackCountText

	Make/FREE/N=(1, 1, LABNOTEBOOK_LAYER_COUNT) vals = NaN
	vals[0][0][INDEP_HEADSTAGE] = newSweepNo
	Make/T/FREE/N=(3, 1) keys
	keys[0] = SWEEP_ROLLBACK_KEY
	keys[1] = "a. u."
	keys[2] = LABNOTEBOOK_NO_TOLERANCE
	ED_AddEntriesToLabnotebook(vals, keys, sweepNo, panelTitle, UNKNOWN_MODE)

	// upgrade LBNs
	GetLBNumericalKeys(panelTitle)
	GetLBTextualKeys(panelTitle)

	WAVE/Z numericalValues = GetLBNumericalValues(panelTitle)
	rollbackCountNum = GetNumberFromWaveNote(numericalValues, LABNOTEBOOK_ROLLBACK_COUNT)
	SetNumberInWaveNote(numericalValues, LABNOTEBOOK_ROLLBACK_COUNT, rollbackCountNum + 1)
	WaveClear numericalValues

	WAVE/Z textualValues = GetLBTextualValues(panelTitle)
	rollbackCountText = GetNumberFromWaveNote(textualValues, LABNOTEBOOK_ROLLBACK_COUNT)
	SetNumberInWaveNote(textualValues, LABNOTEBOOK_ROLLBACK_COUNT, rollbackCountText + 1)
	WaveClear textualValues

	ASSERT(rollbackCountNum == rollbackCountText, "Invalid rollback count")
End

static Function DAP_UpdateSweepLimitsAndDisplay(string panelTitle, [variable initial])

	string panelList
	variable sweep, nextSweep, maxNextSweep, numPanels, i

	panelList = GetListofLeaderAndPossFollower(panelTitle)

	if(ParamIsDefault(initial))
		initial = 0
	else
		initial = !!initial
	endif

	if(initial)
		// we are not implementing sweep adjustment for yoked devices
		if(!DeviceHasFollower(panelTitle) && !DeviceIsFollower(panelTitle))
			sweep = AFH_GetLastSweepAcquired(panelTitle) + 1
			if(IsFinite(sweep))
				SetSetVariable(panelTitle, "SetVar_Sweep", sweep)
				DAG_Update(panelTitle, "SetVar_Sweep", val = sweep)
			endif
		else
			sweep = NaN
		endif
	else
		if(DAP_DeviceIsLeader(panelTitle))
			sweep = DAG_GetNumericalValue(panelTitle, "SetVar_Sweep")
		else
			sweep = NaN
		endif
	endif

	// query maximum next sweep
	maxNextSweep = 0
	numPanels = ItemsInList(panelList)
	for(i = 0; i < numPanels; i += 1)
		panelTitle = StringFromList(i, panelList)

		if(IsFinite(sweep) && DeviceIsFollower(panelTitle))
			PGC_SetAndActivateControl(panelTitle, "SetVar_Sweep", val = sweep)
		endif

		nextSweep = AFH_GetLastSweepAcquired(panelTitle) + 1
		if(IsFinite(nextSweep))
			maxNextSweep = max(maxNextSweep, nextSweep)
		endif
	endfor

	for(i = 0; i < numPanels; i += 1)
		panelTitle = StringFromList(i, panelList)

		if(DeviceIsFollower(panelTitle))
			SetVariable SetVar_Sweep win = $panelTitle, noEdit=1, limits = {0, maxNextSweep, 0}
		else
			SetVariable SetVar_Sweep win = $panelTitle, noEdit=0, limits = {0, maxNextSweep, 1}
		endif
	endfor
End

/// @brief Return the sampling interval with taking the mode,
/// the multiplier and the fixed frequency selection into account
///
/// @param[in]  panelTitle  device
/// @param[in]  dataAcqOrTP one of @ref DataAcqModes
/// @param[out] valid       [optional] returns if the choosen
///                         sampling interval is valid or not (DAQ only)
/// @see SI_CalculateMinSampInterval()
Function DAP_GetSampInt(panelTitle, dataAcqOrTP, [valid])
	string panelTitle
	variable dataAcqOrTP
	variable &valid

	variable multiplier, sampInt
	string fixedFreqkHzStr

	if(!ParamIsDefault(valid))
		valid = 1
	endif

	if(dataAcqOrTP == DATA_ACQUISITION_MODE)
		fixedFreqkHzStr = DAG_GetTextualValue(panelTitle, "Popup_Settings_FixedFreq")
		if(cmpstr(fixedFreqkHzStr, "Maximum"))
			sampInt = 1 / (str2num(fixedFreqkHzStr) * 1e3) * 1e6

			if(!ParamIsDefault(valid))
				valid = sampInt >= SI_CalculateMinSampInterval(panelTitle, DATA_ACQUISITION_MODE)
			endif

			return sampInt
		else
			multiplier = str2num(DAG_GetTextualValue(panelTitle, "Popup_Settings_SampIntMult"))
			return SI_CalculateMinSampInterval(panelTitle, dataAcqOrTP) * multiplier
		endif
	elseif(dataAcqOrTP == TEST_PULSE_MODE)
		return SI_CalculateMinSampInterval(panelTitle, dataAcqOrTP)
	else
		ASSERT(0, "unknown mode")
	endif
End

/// @todo display correct values for yoked devices
Function DAP_UpdateSweepSetVariables(panelTitle)
	string panelTitle

	variable numSetRepeats

	if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_RepeatAcq"))
		numSetRepeats = DAG_GetNumericalValue(panelTitle, "SetVar_DataAcq_SetRepeats")

		if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_IndexingLocked"))
			numSetRepeats *= IDX_MaxSweepsLockedIndexing(panelTitle)
		else
			numSetRepeats *= IDX_MaxNoOfSweeps(panelTitle, 0)
		endif
	else
		numSetRepeats = 1
	endif

	SetValDisplay(panelTitle, "valdisp_DataAcq_TrialsCountdown", var=numSetRepeats)
	SetValDisplay(panelTitle, "valdisp_DataAcq_SweepsInSet", var=numSetRepeats)
	SetValDisplay(panelTitle, "valdisp_DataAcq_SweepsActiveSet", var=IDX_MaxNoOfSweeps(panelTitle, 1))
End

Function DAP_SetVarProc_TotSweepCount(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string panelTitle

	switch(sva.eventCode)
		case 1:
		case 2:
		case 3:
			panelTitle = sva.win
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
			DAP_UpdateSweepSetVariables(panelTitle)
			DAP_SyncGuiFromLeaderToFollower(panelTitle)
			break
	endswitch

	return 0
End

Function DAP_ButtonCtrlFindConnectedAmps(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventcode)
		case 2: // mouse up
			AI_FindConnectedAmps()
			break
	endswitch
End

/// @brief Return a nicely layouted list of amplifier channels
Function/S DAP_GetNiceAmplifierChannelList()

	variable i, numRows
	string str
	string list = NONE

	WAVE telegraphServers = GetAmplifierTelegraphServers()

	numRows = DimSize(telegraphServers, ROWS)
	if(!numRows)
		print "Activate Multiclamp Commander software to populate list of available amplifiers"
		ControlWindowToFront()
		list = AddListItem("\\M1(MC not available", list, ";", inf)
		return list
	endif

	for(i=0; i < numRows; i+=1)
		str  = DAP_GetAmplifierDef(telegraphServers[i][0], telegraphServers[i][1])
		list = AddListItem(str, list, ";", inf)
	endfor

	return list
End

Function/S DAP_GetAmplifierDef(ampSerial, ampChannel)
	variable ampSerial, ampChannel

	string str

	sprintf str, AMPLIFIER_DEF_FORMAT, ampSerial, ampChannel

	return str
End

/// @brief Parse the entries which DAP_GetAmplifierDef() created
Function DAP_ParseAmplifierDef(amplifierDef, ampSerial, ampChannelID)
	string amplifierDef
	variable &ampSerial, &ampChannelID

	ampSerial    = NaN
	ampChannelID = NaN

	if(!cmpstr(amplifierDef, NONE))
		return NaN
	endif

	sscanf amplifierDef, AMPLIFIER_DEF_FORMAT, ampSerial, ampChannelID
	ASSERT(V_Flag == 2, "Unexpected amplifier popup list format")
End

Function DAP_SyncDeviceAssocSettToGUI(panelTitle, headStage)
	string panelTitle
	variable headStage

	DAP_AbortIfUnlocked(panelTitle)

	DAP_UpdateChanAmpAssignPanel(panelTitle)
	P_UpdatePressureControls(panelTitle, headStage)
End

Function DAP_PopMenuProc_Headstage(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	string panelTitle
	variable headStage

	switch(pa.eventCode)
		case 2: // mouse up
			panelTitle = pa.win
			headStage  = str2num(pa.popStr)

			DAG_Update(pa.win, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)
			DAP_SyncDeviceAssocSettToGUI(panelTitle, headStage)

			break
	endswitch

	return 0
End

Function DAP_PopMenuProc_CAA(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	string panelTitle

	switch(pa.eventCode)
		case 2: // mouse up
			panelTitle = pa.win
			DAP_AbortIfUnlocked(panelTitle)

			DAP_UpdateChanAmpAssignStorWv(panelTitle)
			P_UpdatePressureDataStorageWv(panelTitle)
			break
	endswitch

	return 0
End

Function DAP_SetVarProc_CAA(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string panelTitle

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
			panelTitle = sva.win
			DAP_AbortIfUnlocked(panelTitle)

			strswitch(sva.ctrlName)
				case "setvar_DataAcq_SSPressure":
				case "setvar_DataAcq_PPPressure":
				case "setvar_DataAcq_PPDuration":
					DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
					break
			endswitch

			DAP_UpdateChanAmpAssignStorWv(panelTitle)
			P_UpdatePressureDataStorageWv(panelTitle)
			break
		case 9: // mouse down
			strswitch(sva.ctrlName)
				case "setvar_DataAcq_SSPressure":
				case "setvar_DataAcq_PPPressure":
				case "setvar_DataAcq_PPDuration":
					ShowSetVariableLimitsSelectionPopup(sva)
					break
			endswitch
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_ClearChanCon(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle
	variable headStage

	switch(ba.eventCode)
		case 2: // mouse up
			panelTitle = ba.win
			DAP_AbortIfUnlocked(panelTitle)

			WAVE ChanAmpAssign = GetChanAmpAssign(panelTitle)

			headStage = str2num(GetPopupMenuString(panelTitle,"Popup_Settings_HeadStage"))

			// set all DA/AD channels for both clamp modes to an invalid channel number
			ChanAmpAssign[0, 6;2][headStage] = NaN
			ChanAmpAssign[8, 9][headStage]   = NaN

			DAP_UpdateChanAmpAssignPanel(panelTitle)
			break
	endswitch

	return 0
End

/// @brief Check the settings across yoked devices
static Function DAP_CheckSettingsAcrossYoked(listOfFollowerDevices, mode)
	string listOfFollowerDevices
	variable mode

	string panelTitle, leaderSampInt
	variable i, j, numEntries, numCtrls

	if(!WindowExists("ArduinoSeq_Panel"))
		ARDLaunchSeqPanel()

		if(!WindowExists("ArduinoSeq_Panel"))
			printf "(%s) The Arduino sequencer panel does not exist. Please open it and load the default sequence.\r", ITC1600_FIRST_DEVICE
			ControlWindowToFront()
			return 1
		endif
	endif

	if(IsControlDisabled("ArduinoSeq_Panel", "ArduinoStartButton"))
		PGC_SetAndActivateControl("ArduinoSeq_Panel", "SendSequenceButton")

		if(IsControlDisabled("ArduinoSeq_Panel", "ArduinoStartButton"))
			printf "(%s) The Arduino sequencer panel has a disabled \"Start\" button. Is it connected? Have you loaded the default sequence?\r", ITC1600_FIRST_DEVICE
			ControlWindowToFront()
			return 1
		endif
	endif

	if(mode == TEST_PULSE_MODE)
		return 0
	endif

	leaderSampInt = GetValDisplayAsString(ITC1600_FIRST_DEVICE, "ValDisp_DataAcq_SamplingInt")

	Make/T/FREE desc = {"Repeated Acquisition", "Distributed Acquisition", "Distributed DAQ delay",            \
						"Indexing", "ITI", "Number of repetitions", "Get ITI from stimset",                    \
						"Optimized overlap dDAQ pre feature time", "Optimized overlap dDAQ post feature time", \
						"Optimized overlap dDAQ", "Optimized overlap dDAQ resolution"}

	numCtrls = DimSize(desc, ROWS)
	ASSERT(ItemsInList(YOKE_CONTROLS_DISABLE_AND_LINK) == numCtrls, "Mismatched yoke linking lists")

	Make/FREE/T/N=(numCtrls) leadEntries = GetGuiControlValue(ITC1600_FIRST_DEVICE, StringFromList(p, YOKE_CONTROLS_DISABLE_AND_LINK))

	numEntries = ItemsInList(listOfFollowerDevices)
	for(i = 0; i < numEntries; i += 1)
		panelTitle = StringFromList(i, listOfFollowerDevices)

		if(cmpstr(leaderSampInt, GetValDisplayAsString(panelTitle, "ValDisp_DataAcq_SamplingInt")))
			// this is no fatal error, we just inform the user
			printf "(%s) Sampling interval does not match leader panel\r", panelTitle
			ValDisplay ValDisp_DataAcq_SamplingInt win=$panelTitle, valueBackColor=(0,65280,33024)
			ControlWindowToFront()
		else
			ValDisplay ValDisp_DataAcq_SamplingInt win=$panelTitle, valueBackColor=(0,0,0)
		endif

		Make/FREE/T/N=(numCtrls) followerEntries = GetGuiControlValue(panelTitle, StringFromList(p, YOKE_CONTROLS_DISABLE_AND_LINK))

		if(EqualWaves(leadEntries, followerEntries, 1))
			continue
		endif

		// find the differing control
		for(j = 0; j < numEntries; j +=1)
			if(!cmpstr(leadEntries[j], followerEntries[j]))
				continue
			endif

			printf "(%s) %s setting does not match leader panel\r", panelTitle, desc[i]
			ControlWindowToFront()
			return 1
		endfor
	endfor

	return 0
End

/// @brief Check if all settings are valid to send a test pulse or acquire data
///
/// For invalid settings an informative message is printed into the history area.
///
/// Callers must ensure to set the acquisition state back to #AS_INACTIVE when
/// calling with #DATA_ACQUISITION_MODE.
///
/// @param panelTitle device
/// @param mode       One of @ref DataAcqModes
///
/// @return 0 for valid settings, 1 for invalid settings
Function DAP_CheckSettings(panelTitle, mode)
	string panelTitle
	variable mode

	variable numDACs, numADCs, numHS, numEntries, i, clampMode, headstage
	variable ampSerial, ampChannelID, minValue, maxValue, hardwareType, hwChannel
	variable lastStartSeconds, lastITI, nextStart, leftTime, sweepNo, validSampInt
	variable DACchannel, ret
	string ctrl, endWave, ttlWave, dacWave, refDacWave, reqParams
	string list, lastStart

	ASSERT(mode == DATA_ACQUISITION_MODE || mode == TEST_PULSE_MODE, "Invalid mode")

	if(mode == DATA_ACQUISITION_MODE)
		AS_HandlePossibleTransition(panelTitle, AS_EARLY_CHECK)
	endif

	if(DAP_DeviceIsUnlocked(panelTitle))
		printf "(%s) Device is unlocked. Please lock the device.\r", panelTitle
		ControlWindowToFront()
		return 1
	endif

	SWS_DeleteDataWaves(panelTitle)

	PathInfo home
	if(V_Flag) // saved experiment
		if(!HasEnoughDiskspaceFree(S_path, MINIMUM_FREE_DISK_SPACE))
			printf "%s: The amount of free disk space on drive \"%s:\" is less than %.0W0PB. Therefore it is not possible to acquire data in MIES.\nPlease contact your hardware administrator.\r", panelTitle, GetDrive(S_path), MINIMUM_FREE_DISK_SPACE
			ControlWindowToFront()
			return 1
		endif
	endif

	if(mode == DATA_ACQUISITION_MODE)
		WAVE statusHS = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE)
		numEntries = DimSize(statusHS, ROWS)
		for(i = 0; i < numEntries; i += 1)
			if(!statusHS[i])
				continue
			endif

			DACchannel = AFH_GetDACFromHeadstage(panelTitle, i)

			if(!IsFinite(DACchannel))
				continue
			endif

			WAVE/T stimsets = IDX_GetSetsInRange(panelTitle, DACchannel, CHANNEL_TYPE_DAC, 1)
			ASSERT(DimSize(stimsets, ROWS) == 1, "Unexpected stimsets size")

			if(DAP_CheckAnalysisFunctionAndParameter(panelTitle, stimsets[0]))
				return 1
			endif
		endfor
	endif

	// update the analysis functions gathered from the stimsets
	AFM_UpdateAnalysisFunctionWave(panelTitle)

	if(mode == DATA_ACQUISITION_MODE && AS_HandlePossibleTransition(panelTitle, AS_PRE_DAQ))
		printf "%s: Pre DAQ analysis function requested an abort\r", panelTitle
		ControlWindowToFront()
		return 1
	endif

	DAP_GetSampInt(panelTitle, mode, valid=validSampInt)
	if(!validSampInt)
		printf "%s: The selected sampling interval is not possible with your hardware.\r", panelTitle
		ControlWindowToFront()
		return 1
	endif

	// check that if multiple devices are locked we are in multi device mode
	if(ItemsInList(GetListOfLockedDevices()) > 1 && !DAG_GetNumericalValue(panelTitle, "check_Settings_MD"))
		print "If multiple devices are locked, DAQ/TP is only possible in multi device mode"
		ControlWindowToFront()
		return 1
	endif

	if(DAG_GetNumericalValue(panelTitle, "Popup_Settings_SampIntMult") > 0 && DAG_GetNumericalValue(panelTitle, "Popup_Settings_FixedFreq") > 0)
		print "It is not possible to combine fixed frequency acquisition with the sampling interval multiplier"
		ControlWindowToFront()
		return 1
	endif

	list = panelTitle

	if(DeviceHasFollower(panelTitle))
		SVAR listOfFollowerDevices = $GetFollowerList(panelTitle)
		if(DAP_CheckSettingsAcrossYoked(listOfFollowerDevices, mode))
			return 1
		endif
		list = AddListItem(list, listOfFollowerDevices, ";", inf)

		// indexing and locked indexing are currently not implemented correctly for yoked devices
		if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing") || DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_IndexingLocked"))
			printf "(%s) Indexing (locked and unlocked) is currently not usable with yoking.\r", panelTitle
			ControlWindowToFront()
			return 1
		elseif(DAG_GetNumericalValue(panelTitle, "check_Settings_TPAfterDAQ"))
			printf "(%s) TP after DAQ is currently not usable with yoking.\r", panelTitle
			ControlWindowToFront()
			return 1
		endif
	endif
	DEBUGPRINT("Checking the panelTitle list: ", str=list)

	numEntries = ItemsInList(list)
	for(i = 0; i < numEntries; i += 1)

		panelTitle = StringFromList(i, list)

		if(DAP_DeviceIsUnlocked(panelTitle))
			printf "(%s) Device is unlocked. Please lock the device.\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		NVAR deviceID = $GetDAQDeviceID(panelTitle)
		hardwareType = GetHardwareType(panelTitle)

#ifndef EVIL_KITTEN_EATING_MODE
		if(HW_SelectDevice(hardwareType, deviceID, flags=HARDWARE_PREVENT_ERROR_POPUP | HARDWARE_PREVENT_ERROR_MESSAGE))
			printf "(%s) Device can not be selected. Please unlock and lock the device.\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		if(hardwareType == HARDWARE_NI_DAC && !DAG_GetNumericalValue(panelTitle, "check_Settings_MD"))
			printf "(%s) NI hardware can only be used in multi device mode.\r", panelTitle
			ControlWindowToFront()
			return 1
		endif
#endif
		if(!HasPanelLatestVersion(panelTitle, DA_EPHYS_PANEL_VERSION))
			printf "(%s) The DA_Ephys panel is too old to be usable. Please close it and open a new one.\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		numHS = sum(DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE))
		if(!numHS)
			printf "(%s) Please activate at least one headstage\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		WAVE statusDA = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_DAC)
		numDACs = sum(statusDA)
		if(!numDACS)
			printf "(%s) Please activate at least one DA channel\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		numADCs = sum(DAG_GetChannelState(panelTitle, CHANNEL_TYPE_ADC))
		if(!numADCs)
			printf "(%s) Please activate at least one AD channel\r", panelTitle
			ControlWindowToFront()
			return 1
		endif

		WAVE statusHS = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE)

		if(mode == DATA_ACQUISITION_MODE)

			if(DAG_GetNumericalValue(panelTitle, "Check_Settings_ITImanualStart"))
				WAVE numericalValues = GetLBNumericalValues(panelTitle)
				WAVE textualValues   = GetLBTextualValues(panelTitle)
				lastITI   = GetLastSweepWithSettingIndep(numericalValues, "Inter-trial interval", sweepNo)

				if(IsFinite(lastITI))
					lastStart = GetLastSettingTextIndep(textualValues, sweepNo, HIGH_PREC_SWEEP_START_KEY, DATA_ACQUISITION_MODE)

					if(IsFinite(lastITI) && !IsEmpty(lastStart))
						lastStartSeconds = ParseISO8601TimeStamp(lastStart)
						nextStart        = DateTimeInUTC()
						leftTime         = lastStartSeconds + lastITI - nextStart

						if(leftTime > 0)
							printf "(%s) The next sweep can not be started as that would break the required inter trial interval. Please wait another %g seconds.\r", panelTitle, leftTime
							ControlWindowToFront()
							return 1
						endif
					endif
				endif
			endif

			// check all selected TTLs
			WAVE statusTTLFiltered = DC_GetFilteredChannelState(panelTitle, mode, CHANNEL_TYPE_TTL)
			numEntries = DimSize(statusTTLFiltered, ROWS)
			for(i=0; i < numEntries; i+=1)
				if(!statusTTLFiltered[i])
					continue
				endif

				if(DAP_CheckStimset(panelTitle, CHANNEL_TYPE_TTL, i, NaN))
					return 1
				endif
			endfor

			if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_RepeatAcq") && DAG_GetNumericalValue(panelTitle, "check_DataAcq_RepAcqRandom") && DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing"))
				printf "(%s) Repeated random acquisition can not be combined with indexing.\r", panelTitle
				printf "(%s) If you need this feature please contact the MIES developers.\r", panelTitle
				ControlWindowToFront()
				return 1
			endif

			if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_DistribDaq") && DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_dDAQOptOv"))
				printf "(%s) Only one of distributed DAQ and optimized overlap distributed DAQ can be checked.\r", panelTitle
				ControlWindowToFront()
				return 1
			endif

			// classic distributed acquisition requires that all stim sets are the same
			// oodDAQ allows different stim sets
			if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_DistribDaq") || DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_dDAQOptOv"))
				WAVE statusDAFiltered = DC_GetFilteredChannelState(panelTitle, mode, CHANNEL_TYPE_DAC)
				numEntries = DimSize(statusDAFiltered, ROWS)
				for(i=0; i < numEntries; i+=1)
					if(!statusDAFiltered[i])
						continue
					endif

					if(!IsFinite(AFH_GetHeadstagefromDAC(panelTitle, i)))
						printf "(%s) Distributed Acquisition does not work with unassociated DA channel %d.\r", panelTitle, i
						ControlWindowToFront()
						return 1
					endif

					if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_dDAQOptOv"))
						continue
					endif

					dacWave = DAG_GetTextualValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE), index = i)
					if(isEmpty(refDacWave))
						refDacWave = dacWave
					elseif(CmpStr(refDacWave, dacWave))
						printf "(%s) Please select the same stim sets for all DACs when distributed acquisition is used\r", panelTitle
						ControlWindowToFront()
						return 1
					endif
				endfor
			endif

			WAVE statusAsync = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_ASYNC)
			WAVE statusAD = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_ADC)

			for(i = 0; i < NUM_ASYNC_CHANNELS ; i += 1)

				if(!statusAsync[i])
					continue
				endif

				hwChannel = HW_ITC_CalculateDevChannelOff(panelTitle) + i

				// AD channel already used
				if(hwChannel < NUM_ASYNC_CHANNELS && statusAD[hwChannel])
					printf "(%s) The Async channel %d is already used for DAQ.\r", panelTitle, i
					ControlWindowToFront()
					return 1
				endif

				// active async channel

				ctrl = GetSpecialControlLabel(CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_GAIN)
				if(!IsFinite(DAG_GetNumericalValue(panelTitle, ctrl, index = i)))
					printf "(%s) Please select a finite gain value for async channel %d\r", panelTitle, i
					ControlWindowToFront()
					return 1
				endif

				ctrl = GetSpecialControlLabel(CHANNEL_TYPE_ALARM, CHANNEL_CONTROL_CHECK)
				if(!DAG_GetNumericalValue(panelTitle, ctrl, index = i))
					continue
				endif

				// with alarm enabled

				ctrl = GetSpecialControlLabel(CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_ALARM_MIN)
				minValue = DAG_GetNumericalValue(panelTitle, ctrl, index = i)
				if(!IsFinite(minValue))
					printf "(%s) Please select a finite minimum value for async channel %d\r", panelTitle, i
					ControlWindowToFront()
					return 1
				endif

				ctrl = GetSpecialControlLabel(CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_ALARM_MAX)
				maxValue = DAG_GetNumericalValue(panelTitle, ctrl, index = i)
				if(!IsFinite(maxValue))
					printf "(%s) Please select a finite maximum value for async channel %d\r", panelTitle, i
					ControlWindowToFront()
					return 1
				endif

				if(!(minValue < maxValue))
					printf "(%s) Please select a minimum value which is strictly smaller than the maximum value for async channel %d\r", panelTitle, i
					ControlWindowToFront()
					return 1
				endif

				if(DAG_GetNumericalValue(panelTitle, "Check_Settings_AlarmAutoRepeat"))
					if(!DAG_GetNumericalValue(panelTitle, "Check_DataAcq1_RepeatAcq"))
						printf "(%s) Repeat sweep on async alarm can only be used with repeated acquisition enabled\r", panelTitle
						ControlWindowToFront()
						return 1
					endif
				endif
			endfor
		endif

		// avoid having different headstages reference the same amplifiers
		// and/or DA/AD channels in the "DAC Channel and Device Associations" menu
		Make/FREE/N=(NUM_HEADSTAGES) DACs, ADCs
		Make/FREE/N=(NUM_HEADSTAGES)/T ampSpec

		WAVE chanAmpAssign = GetChanAmpAssign(panelTitle)

		for(i = 0; i < NUM_HEADSTAGES; i += 1)

			ampSerial    = ChanAmpAssign[%AmpSerialNo][i]
			ampChannelID = ChanAmpAssign[%AmpChannelID][i]
			if(IsFinite(ampSerial) && IsFinite(ampChannelID))
				ampSpec[i] = DAP_GetAmplifierDef(ampSerial, ampChannelID)
			else
				// add a unique alternative entry
				ampSpec[i] = num2str(i)
			endif

			clampMode  = DAG_GetHeadstageMode(panelTitle, i)

			if(clampMode == V_CLAMP_MODE)
				DACs[i] = ChanAmpAssign[%VC_DA][i]
				ADCs[i] = ChanAmpAssign[%VC_AD][i]
			elseif(clampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE)
				DACs[i] = ChanAmpAssign[%IC_DA][i]
				ADCs[i] = ChanAmpAssign[%IC_AD][i]
			else
				printf "(%s) Unhandled mode %d\r", panelTitle, clampMode
				ControlWindowToFront()
				return 1
			endif
		endfor

		if(SearchForDuplicates(DACs))
			printf "(%s) Different headstages in the \"DAC Channel and Device Associations\" menu reference the same DA channels.\r", panelTitle
			printf "Please clear the associations for unused headstages.\r"
			ControlWindowToFront()
			return 1
		endif

		if(SearchForDuplicates(ADCs))
			printf "(%s) Different headstages in the \"DAC Channel and Device Associations\" menu reference the same AD channels.\r", panelTitle
			printf "Please clear the associations for unused headstages.\r"
			ControlWindowToFront()
			return 1
		endif

		if(SearchForDuplicates(ampSpec))
			printf "(%s) Different headstages in the \"DAC Channel and Device Associations\" menu reference the same amplifier-channel-combination.\r", panelTitle
			printf "Please clear the associations for unused headstages.\r"
			ControlWindowToFront()
			return 1
		endif

		// check all active headstages
		numEntries = DimSize(statusHS, ROWS)
		for(i=0; i < numEntries; i+=1)
			if(!statusHS[i])
				continue
			endif

			ret = DAP_CheckHeadStage(panelTitle, i, mode)

			switch(ret)
				case 0:
					// passed, do nothing
					break
				case 1: // non-recoverable error
					return 1
				case 2: // recoverable error, try again once
					if(DAP_CheckHeadStage(panelTitle, i, mode))
						return 1
					endif
					break
				default:
					ASSERT(0, "Unexpected value")
			endswitch
		endfor

		if(DAG_GetNumericalValue(panelTitle, "SetVar_DataAcq_TPDuration") <= 0)
			print "The testpulse duration must be greater than 0 ms"
			ControlWindowToFront()
			return 1
		endif

		if(mode == DATA_ACQUISITION_MODE)
			WAVE/T allSetNames = DAG_GetChannelTextual(panelTitle, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
			WAVE statusDAFiltered = DC_GetFilteredChannelState(panelTitle, DATA_ACQUISITION_MODE, CHANNEL_TYPE_DAC)
			numEntries = DimSize(statusDAFiltered, ROWS)
			for(i = 0; i < numEntries; i += 1)

				if(!statusDAFiltered[i])
					continue
				endif

				if(GetValDisplayAsNum(panelTitle, "valdisp_DataAcq_SweepsInSet") == 0 \
				   && CmpStr(allSetNames[i], STIMSET_TP_WHILE_DAQ))
					printf "(%s) The calculated number of sweeps is zero. This is unexpected and very likely a bug.\r", panelTitle
					ControlWindowToFront()
					return 1
				endif

				headstage = AFH_GetHeadstageFromDAC(panelTitle, i)

				if(IsFinite(headstage) && DAG_GetHeadstageMode(panelTitle, headstage) == I_EQUAL_ZERO_MODE \
				   && !cmpstr(allSetNames[i], STIMSET_TP_WHILE_DAQ))
					printf "(%s) When TP while DAQ is used the channel clamp mode for headstage %d can not be I=0.\r", panelTitle, headstage
					ControlWindowToFront()
					return 1
				endif
			endfor

			if(DC_GotTPChannelWhileDAQ(panelTitle))
				if(DAG_GetNumericalValue(panelTitle, "Popup_Settings_SampIntMult") > 0)
					printf "(%s) When TP while DAQ is used only sample multiplier of 1 is supported.\r", panelTitle
					ControlWindowToFront()
					return 1
				endif
				if(DAG_GetNumericalValue(panelTitle, "Popup_Settings_FixedFreq") > 0)
					printf "(%s) When TP while DAQ is used no fixed frequency acquisition is supported.\r", panelTitle
					ControlWindowToFront()
					return 1
				endif
			endif
		endif

		// unlock DAQDataWave, this happens if user functions error out and we don't catch it
		// note: seems to work even if WAVE/WAVE would be required for NI
		WAVE DAQDataWave = GetDAQDataWave(panelTitle, mode)
		if(NumberByKey("LOCK", WaveInfo(DAQDataWave, 0)))
			printf "(%s) Removing leftover lock on DAQDataWave\r", panelTitle
			ControlWindowToFront()
			SetWaveLock 0, DAQDataWave
		endif
	endfor

	if(DAP_CheckPressureSettings(panelTitle))
		return 1
	endif

	if(DAG_GetNumericalValue(panelTitle, "Check_Settings_NwbExport"))
		NWB_PrepareExport(str2num(DAG_GetTextualValue(panelTitle, "Popup_Settings_NwbVersion")))
	endif

	return 0
End

static Function DAP_CheckPressureSettings(string panelTitle)
	variable ADConfig, ADC
	string pressureDevice, userPressureDevice

#ifndef EVIL_KITTEN_EATING_MODE
	pressureDevice = GetPopupMenuString(panelTitle, "popup_Settings_Pressure_dev")

	if(cmpstr(pressureDevice, NONE))
		if(GetHardwareType(pressureDevice) == HARDWARE_NI_DAC)

			ADC = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_Pressure_AD"))
			ADConfig = HW_NI_GetAnalogInputConfig(pressureDevice, ADC)

			if((ADConfig & HW_NI_CONFIG_DIFFERENTIAL) != HW_NI_CONFIG_DIFFERENTIAL)
				printf "(%s) The AD channel %d of the pressure device %s can not be used in differential mode.\r", panelTitle, ADC, pressureDevice
				printf "Available modes are: %s\r", HW_NI_AnalogInputToString(ADConfig)
				ControlWindowToFront()
				return 1
			endif
		endif
	endif

	userPressureDevice = GetPopupMenuString(panelTitle, "popup_Settings_UserPressure")

	if(cmpstr(userPressureDevice, NONE))
		if(GetHardwareType(userPressureDevice) == HARDWARE_NI_DAC)

			ADC = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_UserPressure_ADC"))
			ADConfig = HW_NI_GetAnalogInputConfig(userPressureDevice, ADC)

			if((ADConfig & HW_NI_CONFIG_DIFFERENTIAL) != HW_NI_CONFIG_DIFFERENTIAL)
				printf "(%s) The AD channel %d of the user pressure device %s can not be used in differential mode.\r", panelTitle, ADC, userPressureDevice
				printf "Available modes are: %s\r", HW_NI_AnalogInputToString(ADConfig)
				ControlWindowToFront()
				return 1
			endif
		endif
	endif
#endif // EVIL_KITTEN_EATING_MODE

	return 0
End

/// @brief Returns zero if everything is okay, 1 if a non-recoverable error was found and 2 on recoverable errors
static Function DAP_CheckHeadStage(panelTitle, headStage, mode)
	string panelTitle
	variable headStage, mode

	string unit, ADUnit, DAUnit
	variable DACchannel, ADCchannel, DAheadstage, ADheadstage, DAGain, ADGain, realMode
	variable gain, scale, clampMode, i, j, ampConnState, needResetting, ADConfig
	variable DAGainMCC, ADGainMCC, numEntries
	string DAUnitMCC, ADUnitMCC

	if(DAP_DeviceIsUnlocked(panelTitle))
		printf "(%s) Device is unlocked. Please lock the device.\r", panelTitle
		ControlWindowToFront()
		return 1
	endif

	Wave ChanAmpAssign       = GetChanAmpAssign(panelTitle)
	Wave/T ChanAmpAssignUnit = GetChanAmpAssignUnit(panelTitle)
	Wave channelClampMode    = GetChannelClampMode(panelTitle)

	if(headstage < 0 || headStage >= DimSize(ChanAmpAssign, COLS))
		printf "(%s) Invalid headstage %d\r", panelTitle, headStage
		ControlWindowToFront()
		return 1
	endif

	ampConnState = AI_SelectMultiClamp(panelTitle, headStage)
	clampMode = DAG_GetHeadstageMode(panelTitle, headstage)

	// needs to be at the beginning as DAP_ApplyClmpModeSavdSettngs writes into
	// ChanAmpAssign/ChanAmpAssignUnit
	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS && AI_IsValidClampMode(clampMode))
		DAP_ApplyClmpModeSavdSettngs(panelTitle, headstage, clampMode)
	endif

	if(clampMode == V_CLAMP_MODE)
		DACchannel = ChanAmpAssign[%VC_DA][headStage]
		ADCchannel = ChanAmpAssign[%VC_AD][headStage]
		DAGain     = ChanAmpAssign[%VC_DAGain][headStage]
		ADGain     = ChanAmpAssign[%VC_ADGain][headStage]
		DAUnit     = ChanAmpAssignUnit[%VC_DAUnit][headStage]
		ADUnit     = ChanAmpAssignUnit[%VC_ADUnit][headStage]
	elseif(clampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE)
		DACchannel = ChanAmpAssign[%IC_DA][headStage]
		ADCchannel = ChanAmpAssign[%IC_AD][headStage]
		DAGain     = ChanAmpAssign[%IC_DAGain][headStage]
		ADGain     = ChanAmpAssign[%IC_ADGain][headStage]
		DAUnit     = ChanAmpAssignUnit[%IC_DAUnit][headStage]
		ADUnit     = ChanAmpAssignUnit[%IC_ADUnit][headStage]
	else
		printf "(%s) Unhandled mode %d\r", panelTitle, clampMode
		ControlWindowToFront()
		return 1
	endif

	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS)

		AI_EnsureCorrectMode(panelTitle, headStage)
		AI_QueryGainsUnitsForClampMode(panelTitle, headStage, clampMode, DAGainMCC, ADGainMCC, DAUnitMCC, ADUnitMCC)

		if(cmpstr(DAUnit, DAUnitMCC))
			printf "(%s) The configured unit for the DA channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%s vs %s).\r", panelTitle, DACchannel, DAUnit, DAUnitMCC
			needResetting = 1
		endif

		if((!CheckIfClose(DAGain, DAGainMCC, tol=1e-4) && clampMode != I_EQUAL_ZERO_MODE) || (clampMode == I_EQUAL_ZERO_MODE && !CheckIfSmall(DAGainMCC)))
			printf "(%s) The configured gain for the DA channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%g vs %g).\r", panelTitle, DACchannel, DAGain, DAGainMCC
			needResetting = 1
		endif

	   if(cmpstr(ADUnit, ADUnitMCC))
			printf "(%s) The configured unit for the AD channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%s vs %s).\r", panelTitle, ADCchannel, ADUnit, ADUnitMCC
			needResetting = 1
	   endif

		if(!CheckIfClose(ADGain, ADGainMCC, tol=1e-4))
			printf "(%s) The configured gain for the AD channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%g vs %g).\r", panelTitle, ADCchannel, ADGain, ADGainMCC
			needResetting = 1
	   endif

		if(needResetting)
			AI_UpdateChanAmpAssign(panelTitle, headStage, clampMode, DAGainMCC, ADGainMCC, DAUnitMCC, ADUnitMCC)
			printf "(%s) The automatically imported gains from MCC were used to overwrite differing manual settings.\r", panelTitle
			ControlWindowToFront()
			DAP_UpdateChanAmpAssignPanel(panelTitle)
			DAP_SyncChanAmpAssignToActiveHS(panelTitle)
			return 2
		endif
	endif

	if(!IsFinite(DACchannel) || !IsFinite(ADCchannel))
		printf "(%s) Please select a valid DA and AD channel in \"DAC Channel and Device Associations\" in the Hardware tab.\r", panelTitle
		ControlWindowToFront()
		return 1
	endif

	realMode = channelClampMode[DACchannel][%DAC][%ClampMode]
	if(realMode != clampMode)
		printf "(%s) The clamp mode of DA %d is %s and differs from the requested mode %s.\r", panelTitle, DACchannel, ConvertAmplifierModeToString(realMode), ConvertAmplifierModeToString(clampMode)
		ControlWindowToFront()
		return 1
	endif

	realMode = channelClampMode[ADCchannel][%ADC][%ClampMode]
	if(realMode != clampMode)
		printf "(%s) The clamp mode of AD %d is %s and differs from the requested mode %s.\r", panelTitle, ADCchannel, ConvertAmplifierModeToString(realMode), ConvertAmplifierModeToString(clampMode)
		ControlWindowToFront()
		return 1
	endif

	ADheadstage = AFH_GetHeadstageFromADC(panelTitle, ADCchannel)
	if(!IsFinite(ADheadstage))
		printf "(%s) Could not determine the headstage for the ADChannel %d.\r", panelTitle, ADCchannel
		ControlWindowToFront()
		return 1
	endif

	DAheadstage = AFH_GetHeadstageFromDAC(panelTitle, DACchannel)
	if(!IsFinite(DAheadstage))
		printf "(%s) Could not determine the headstage for the DACchannel %d.\r", panelTitle, DACchannel
		ControlWindowToFront()
		return 1
	endif

	if(DAheadstage != ADheadstage || headstage != ADheadstage || headstage != DAheadstage)
		printf "(%s) The configured headstages for the DA channel %d and the AD channel %d differ (%d vs %d).\r", panelTitle, DACchannel, ADCchannel, DAheadstage, ADheadstage
		ControlWindowToFront()
		return 1
	endif

	unit = DAG_GetTextualValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_UNIT), index = DACchannel)
	if(isEmpty(unit))
		printf "(%s) The unit for DACchannel %d is empty.\r", panelTitle, DACchannel
		ControlWindowToFront()
		return 1
	endif

	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS && cmpstr(DAUnit, unit))
		printf "(%s) The configured unit for the DA channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%s vs %s).\r", panelTitle, DACchannel, DAUnit, unit
		ControlWindowToFront()
		return 1
	endif

	gain = DAG_GetNumericalValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN), index = DACchannel)
	if(!isFinite(gain) || gain == 0)
		printf "(%s) The gain for DACchannel %d must be finite and non-zero.\r", panelTitle, DACchannel
		ControlWindowToFront()
		return 1
	endif

	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS && !CheckIfClose(DAGain, gain, tol=1e-4))
		printf "(%s) The configured gain for the DA channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%d vs %d).\r", panelTitle, DACchannel, DAGain, gain
		ControlWindowToFront()
		return 1
	endif

	// we allow the scale being zero
	scale = DAG_GetNumericalValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_SCALE), index = DACchannel)
	if(!isFinite(scale))
		printf "(%s) The scale for DACchannel %d must be finite.\r", panelTitle, DACchannel
		ControlWindowToFront()
		return 1
	endif

	unit = DAG_GetTextualValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_UNIT), index = ADCchannel)
	if(isEmpty(unit))
		printf "(%s) The unit for ADCchannel %d is empty.\r", panelTitle, ADCchannel
		ControlWindowToFront()
		return 1
	endif

	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS && cmpstr(ADUnit, unit))
		printf "(%s) The configured unit for the AD channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%s vs %s).\r", panelTitle, ADCchannel, ADUnit, unit
		ControlWindowToFront()
		return 1
	endif

	gain = DAG_GetNumericalValue(panelTitle, GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN), index = ADCchannel)
	if(!isFinite(gain) || gain == 0)
		printf "(%s) The gain for ADCchannel %d must be finite and non-zero.\r", panelTitle, ADCchannel
		ControlWindowToFront()
		return 1
	endif

	if(ampConnState == AMPLIFIER_CONNECTION_SUCCESS && !CheckIfClose(ADGain, gain, tol=1e-4))
		printf "(%s) The configured gain for the AD channel %d differs from the one in the \"DAC Channel and Device Associations\" menu (%g vs %g).\r", panelTitle, ADCchannel, ADGain, gain
		ControlWindowToFront()
		return 1
	endif

	if(mode == DATA_ACQUISITION_MODE)
		if(DAP_CheckStimset(panelTitle, CHANNEL_TYPE_DAC, DACchannel, headstage))
			return 1
		endif
	endif

#ifndef EVIL_KITTEN_EATING_MODE
	if(DAG_GetNumericalValue(panelTitle, "check_Settings_RequireAmpConn") && ampConnState != AMPLIFIER_CONNECTION_SUCCESS || ampConnState == AMPLIFIER_CONNECTION_MCC_FAILED)
		printf "(%s) The amplifier of the headstage %d can not be selected, please call \"Query connected Amps\" from the Hardware Tab\r", panelTitle, headStage
		printf " and ensure that the \"Multiclamp 700B Commander\" application is open.\r"
		ControlWindowToFront()
		return 1
	endif
#endif

#ifndef EVIL_KITTEN_EATING_MODE
	if(GetHardwareType(panelTitle) == HARDWARE_NI_DAC)
		ADConfig = HW_NI_GetAnalogInputConfig(panelTitle, ADCchannel)
		if((ADConfig & HW_NI_CONFIG_DIFFERENTIAL) != HW_NI_CONFIG_DIFFERENTIAL)
			printf "(%s) The AD channel %d from headstage %d can not be used in differential mode.\r", panelTitle, ADCchannel, headstage
			printf "Available modes are: %s\r", HW_NI_AnalogInputToString(ADConfig)
			ControlWindowToFront()
			return 1
		endif
	endif
#endif

	return 0
End

static Function DAP_CheckAnalysisFunctionAndParameter(panelTitle, setName)
	string panelTitle, setName

	string func, listOfAnalysisFunctions
	string info, str, suppParams, suppName, suppType, reqNamesAndTypesFromFunc, reqNames, reqName
	string diff, name, type, suppNames, reqType, errorMessage
	variable i, j, numEntries

	if(!CmpStr(setName, STIMSET_TP_WHILE_DAQ))
		return 0
	endif

	WAVE/Z stimSet = WB_CreateAndGetStimSet(setName)
	if(!WaveExists(stimSet))
		// we complain later on this error
		return 0
	endif

	if(DAG_GetNumericalValue(panelTitle, "Check_Settings_SkipAnalysFuncs"))
		return 0
	endif

	listOfAnalysisFunctions = AFH_GetAnalysisFunctions(ANALYSIS_FUNCTION_VERSION_ALL)

	for(i = 0; i < TOTAL_NUM_EVENTS; i += 1)
		func = ExtractAnalysisFuncFromStimSet(stimSet, i)

		if(isEmpty(func)) // none set
			continue
		endif

		info = FunctionInfo(func)

		if(isEmpty(info))
			printf "(%s) Warning: The analysis function %s for stim set %s and event type \"%s\" could not be found\r", panelTitle, func, setName, StringFromList(i, EVENT_NAME_LIST)
			ControlWindowToFront()
			continue
		endif

		if(WhichListItem(func, listOfAnalysisFunctions) == -1) // not a valid analysis function
			printf "(%s) The analysis function %s for stim set %s and event type \"%s\" has an invalid signature or is in an unlisted location\r", panelTitle, func, setName, StringFromList(i, EVENT_NAME_LIST)
			ControlWindowToFront()
			return 1
		endif

		if(i == MID_SWEEP_EVENT && !DAG_GetNumericalValue(panelTitle, "Check_Settings_BackgrndDataAcq"))
			printf "(%s) The event type \"%s\" for stim set %s can not be used together with foreground DAQ\r", panelTitle, StringFromList(i, EVENT_NAME_LIST), setName
			ControlWindowToFront()
			return 1
		endif

		if(i != GENERIC_EVENT)
			FUNCREF AF_PROTO_ANALYSIS_FUNC_V3 f3 = $func
			if(FuncRefIsAssigned(FuncRefInfo(f3)))
				printf "(%s) The analysis function %s for stim set %s is of type V3 but associated with the event type \"%s\", which is not supported.\nPlease reassign the analysis function to the stimset in the wavebuilder.\r", panelTitle, func, setName, StringFromList(i, EVENT_NAME_LIST)
				ControlWindowToFront()
				return 1
			endif

			continue
		endif

		// check that all required user parameters are supplied
		reqNamesAndTypesFromFunc = AFH_GetListOfAnalysisParams(func, REQUIRED_PARAMS)
		if(IsEmpty(reqNamesAndTypesFromFunc))
			continue
		endif

		reqNames   = AFH_GetListOfAnalysisParamNames(reqNamesAndTypesFromFunc)
		suppParams = ExtractAnalysisFunctionParams(stimSet)
		suppNames  = AFH_GetListOfAnalysisParamNames(suppParams)
		diff = GetListDifference(reqNames, suppNames)
		if(!IsEmpty(diff))
			printf "(%s) The required analysis parameters requested by %s for stim set %s were not all supplied (missing are: %s)\r", panelTitle, func, setName, diff
			ControlWindowToFront()
			return 1
		endif

		numEntries = ItemsInList(reqNames)
		for(j = 0; j < numEntries; j += 1)
			reqName = StringFromList(j, reqNames)

			if(!AFH_IsValidAnalysisParameter(reqName))
				printf "(%s) The required analysis parameter %s for %s in stim set %s has the invalid name %s.\r", panelTitle, name, func, setName, reqName
				ControlWindowToFront()
				return 1
			endif

			reqType = AFH_GetAnalysisParamType(reqName, reqNamesAndTypesFromFunc, typeCheck = 0)
			// no type specification is allowed
			if(IsEmpty(reqType))
				continue
			endif

			// invalid types are not allowed
			if(WhichListItem(reqType, ANALYSIS_FUNCTION_PARAMS_TYPES) == -1)
				printf "(%s) The required analysis parameter %s for %s in stim set %s has type %s which is unknown.\r", panelTitle, reqName, func, setName, type
				ControlWindowToFront()
				return 1
			endif

			// non matching type
			suppType = AFH_GetAnalysisParamType(reqName, suppParams, typeCheck = 0)
			if(cmpstr(reqType, suppType))
				printf "(%s) The analysis parameter %s for %s in stim set %s has type %s but the required type is %s.\r", panelTitle, reqName, func, setName, suppType, reqType
				ControlWindowToFront()
				return 1
			endif

			strswitch(reqType)
				case "wave":
					WAVE/Z wv = AFH_GetAnalysisParamWave(reqName, suppParams)
					if(!WaveExists(wv) || DimSize(wv, ROWS) == 0)
						printf "(%s) The analysis parameter %s for %s in stim set %s is a non-existing or empty numeric wave.\r", panelTitle, reqName, func, setName
						ControlWindowToFront()
						return 1
					endif
					break
				case "textwave":
					WAVE/Z wv = AFH_GetAnalysisParamTextWave(reqName, suppParams)
					if(!WaveExists(wv) || DimSize(wv, ROWS) == 0)
						printf "(%s) The analysis parameter %s for %s in stim set %s is a non-existing or empty text wave.\r", panelTitle, reqName, func, setName
						ControlWindowToFront()
						return 1
					endif
					break
				default:
					// do nothing
					break
			endswitch
		endfor

		errorMessage = AFH_CheckAnalysisParameter(func, suppParams)
		if(!IsEmpty(errorMessage))
			printf "(%s) The analysis parameter check for function %s in stim set %s did not pass.\r", panelTitle, func, setName
			print errorMessage
			ControlWindowToFront()
			return 1
		endif
	endfor
End

static Function DAP_CheckStimset(panelTitle, channelType, channel, headstage)
	string panelTitle
	variable channelType, channel, headstage

	string setName, setNameEnd, channelTypeStr, str
	variable i, numSets

	if(channelType == CHANNEL_TYPE_DAC)
		channelTypeStr = "DA"
	elseif(channelType == CHANNEL_TYPE_TTL)
		channelTypeStr = "TTL"
	else
		ASSERT(0, "Unexpected channelType")
	endif

	setName = DAG_GetTextualValue(panelTitle, GetSpecialControlLabel(channelType, CHANNEL_CONTROL_WAVE), index = channel)
	if(!CmpStr(setName, NONE))
		printf "(%s) Please select a stimulus set for %s channel %d referenced by headstage %g\r", panelTitle, channelTypeStr, channel, headStage
		ControlWindowToFront()
		return 1
	endif

	if(DAG_GetNumericalValue(panelTitle, "Check_DataAcq_Indexing") && CmpStr(setName, STIMSET_TP_WHILE_DAQ))
		setNameEnd = DAG_GetTextualValue(panelTitle, GetSpecialControlLabel(channelType, CHANNEL_CONTROL_INDEX_END), index = channel)
		if(!CmpStr(setNameEnd, NONE))
			printf "(%s) Please select a valid indexing end wave for %s channel %d referenced by headstage %g\r", panelTitle, channelTypeStr, channel, headStage
			ControlWindowToFront()
			return 1
		elseif(!CmpStr(setName, setNameEnd))
			printf "(%s) Please select a different indexing end setimset for %s channel %d referenced by headstage %g\r", panelTitle, channelTypeStr, channel, headStage
			return 1
		endif
	endif

	WAVE/T stimsets = IDX_GetSetsInRange(panelTitle, channel, channelType, 0)

	numSets = DimSize(stimsets, ROWS)
	for(i = 0; i < numSets; i += 1)
		setName = stimsets[i]

		if(!CmpStr(setName, STIMSET_TP_WHILE_DAQ))
			continue
		endif

		// third party stim sets might not match our expectations
		WAVE/Z stimSet = WB_CreateAndGetStimSet(setName)

		if(!WaveExists(stimSet))
			printf "(%s) The stim set %s of headstage %g does not exist or could not be created.\r", panelTitle, setName, headstage
			ControlWindowToFront()
			return 1
		elseif(DimSize(stimSet, ROWS) == 0)
			printf "(%s) The stim set %s of headstage %g is empty, but must have at least one row.\r", panelTitle, setName, headstage
			ControlWindowToFront()
			return 1
		endif

		// non fatal errors which we fix ourselves
		if(DimDelta(stimSet, ROWS) != WAVEBUILDER_MIN_SAMPINT || DimOffset(stimSet, ROWS) != 0.0 || cmpstr(WaveUnits(stimSet, ROWS), "ms"))
			sprintf str, "(%s) The stim set %s for %s channel of headstage %g must have a row dimension delta of %g, " + \
						 "row dimension offset of zero and row unit \"ms\".\r", panelTitle, setName, channelTypeStr, headstage, WAVEBUILDER_MIN_SAMPINT
			DEBUGPRINT(str)
			DEBUGPRINT("The stim set is now automatically fixed")
			SetScale/P x 0, WAVEBUILDER_MIN_SAMPINT, "ms", stimSet
		endif

		if(DAG_GetNumericalValue(panelTitle, "Check_Settings_SkipAnalysFuncs") || channelType != CHANNEL_TYPE_DAC)
			continue
		endif

		if(DAP_CheckAnalysisFunctionAndParameter(panelTitle, setName))
			return 1
		endif
	endfor
End

/// @brief Synchronizes the contents of `ChanAmpAssign` and
/// `ChanAmpAssignUnit` to all active headstages
static Function DAP_SyncChanAmpAssignToActiveHS(panelTitle)
	string panelTitle

	variable i, clampMode
	WAVE statusHS = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE)

	for(i = 0; i < NUM_HEADSTAGES; i += 1)

		if(!statusHS[i])
			continue
		endif

		clampMode = DAG_GetHeadstageMode(panelTitle, i)
		DAP_ApplyClmpModeSavdSettngs(panelTitle, i, clampMode)
	endfor
End

/// @brief Reads the channel amp waves and inserts that info into the DA_EPHYS panel
static Function DAP_ApplyClmpModeSavdSettngs(panelTitle, headStage, clampMode)
	string panelTitle
	variable headStage, clampMode

	string ctrl, ADUnit, DAUnit
	variable DAGain, ADGain
	variable DACchannel, ADCchannel

	Wave ChanAmpAssign       = GetChanAmpAssign(panelTitle)
	Wave ChannelClampMode    = GetChannelClampMode(panelTitle)
	Wave/T ChanAmpAssignUnit = GetChanAmpAssignUnit(panelTitle)
	WAVE GuiState            = GetDA_EphysGuiStateNum(panelTitle)
	WAVE/T GuiStateTxT       = GetDA_EphysGuiStateTxT(panelTitle)

	if(clampMode == V_CLAMP_MODE)
		DACchannel = ChanAmpAssign[%VC_DA][headStage]
		ADCchannel = ChanAmpAssign[%VC_AD][headStage]
		DAGain     = ChanAmpAssign[%VC_DAGain][headStage]
		ADGain     = ChanAmpAssign[%VC_ADGain][headStage]
		DAUnit     = ChanAmpAssignUnit[%VC_DAUnit][headStage]
		ADUnit     = ChanAmpAssignUnit[%VC_ADUnit][headStage]
	elseif(ClampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE)
		DACchannel = ChanAmpAssign[%IC_DA][headStage]
		ADCchannel = ChanAmpAssign[%IC_AD][headStage]
		DAGain     = ChanAmpAssign[%IC_DAGain][headStage]
		ADGain     = ChanAmpAssign[%IC_ADGain][headStage]
		DAUnit     = ChanAmpAssignUnit[%IC_DAUnit][headStage]
		ADUnit     = ChanAmpAssignUnit[%IC_ADUnit][headStage]
	endif

	if(!IsFinite(DACchannel) || !IsFinite(ADCchannel))
		return NaN
	endif

	// DAC channels
	ctrl = GetPanelControl(DACchannel, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK)
	SetCheckBoxState(panelTitle, 	ctrl, CHECKBOX_SELECTED)
	GuiState[DACchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK)] = CHECKBOX_SELECTED
	ctrl = GetPanelControl(DACchannel, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN)
	SetSetVariable(panelTitle, ctrl, DaGain)
	GuiState[DACchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN)] = DAGain
	ctrl = GetPanelControl(DACchannel, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_UNIT)
	SetSetVariableString(panelTitle, ctrl, DaUnit)
	GuiStateTxT[DACchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_UNIT)] = DAUnit
	ChannelClampMode[DACchannel][%DAC][%ClampMode] = clampMode
	ChannelClampMode[DACchannel][%DAC][%Headstage] = headStage

	// ADC channels
	ctrl = GetPanelControl(ADCchannel, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK)
	SetCheckBoxState(panelTitle, ctrl, CHECKBOX_SELECTED)
	GuiState[ADCchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK)] = CHECKBOX_SELECTED
	ctrl = GetPanelControl(ADCchannel, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN)
	SetSetVariable(panelTitle, ctrl, ADGain)
	GuiState[ADCchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN)] = ADGain
	ctrl = GetPanelControl(ADCchannel, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_UNIT)
	SetSetVariableString(panelTitle, ctrl, ADUnit)
	GuiStateTxT[ADCchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_UNIT)] = ADUnit
	ChannelClampMode[ADCchannel][%ADC][%ClampMode] = clampMode
	ChannelClampMode[ADCchannel][%ADC][%Headstage] = headStage
End

static Function DAP_RemoveClampModeSettings(panelTitle, headStage, clampMode)
	string panelTitle
	variable headStage, clampMode

	string ctrl
	variable DACchannel, ADCchannel

	Wave ChanAmpAssign    = GetChanAmpAssign(panelTitle)
	Wave ChannelClampMode = GetChannelClampMode(panelTitle)
	WAVE GuiState         = GetDA_EphysGuiStateNum(panelTitle)

	if(ClampMode == V_CLAMP_MODE)
		DACchannel = ChanAmpAssign[%VC_DA][headStage]
		ADCchannel = ChanAmpAssign[%VC_AD][headStage]
	elseif(ClampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE)
		DACchannel = ChanAmpAssign[%IC_DA][headStage]
		ADCchannel = ChanAmpAssign[%IC_AD][headStage]
	endIf

	if(!IsFinite(DACchannel) || !IsFinite(ADCchannel))
		ChannelClampMode[][][%Headstage] = ChannelClampMode[p][q][%Headstage] == headstage ? NaN : ChannelClampMode[p][q][%Headstage]
		return NaN
	endif

	ctrl = GetPanelControl(DACchannel, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK)
	SetCheckBoxState(panelTitle, ctrl, CHECKBOX_UNSELECTED)
	ChannelClampMode[DACchannel][%DAC][] = NaN
	GuiState[DACchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_DAC, CHANNEL_CONTROL_CHECK)] = CHECKBOX_UNSELECTED

	ctrl = GetPanelControl(ADCchannel, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK)
	SetCheckBoxState(panelTitle, ctrl, CHECKBOX_UNSELECTED)
	ChannelClampMode[ADCchannel][%ADC][] = NaN
	GuiState[ADCchannel][%$GetSpecialControlLabel(CHANNEL_TYPE_ADC, CHANNEL_CONTROL_CHECK)] = CHECKBOX_UNSELECTED
End

/// @brief Returns the name of the checkbox control (radio button) handling the clamp mode of the given headstage or all headstages
/// @param mode			One of the amplifier modes @ref AmplifierClampModes
/// @param headstage	number of the headstage or one of @ref AllHeadstageModeConstants
Function/S DAP_GetClampModeControl(mode, headstage)
	variable mode, headstage

	ASSERT(headStage >= CHANNEL_INDEX_ALL_I_ZERO && headStage < NUM_HEADSTAGES, "invalid headStage index")

	if(headstage >= 0)
		switch(mode)
			case V_CLAMP_MODE:
				return "Radio_ClampMode_" + num2str(headstage * 2)
			case I_CLAMP_MODE:
				return "Radio_ClampMode_" + num2str(headstage * 2 + 1)
			case I_EQUAL_ZERO_MODE:
				return "Radio_ClampMode_" + num2str(headstage * 2 + 1) + "IZ"
			default:
				ASSERT(0, "invalid mode")
			break
		endswitch
	else
		switch(mode)
			case V_CLAMP_MODE:
				return "Radio_ClampMode_AllVClamp"
			case I_CLAMP_MODE:
				return "Radio_ClampMode_AllIClamp"
			case I_EQUAL_ZERO_MODE:
				return "Radio_ClampMode_AllIZero"
			default:
				ASSERT(0, "invalid mode")
			break
		endswitch
	endif
End

/// @brief Return information readout from headstage and clamp mode controls
///
/// Users interested in the clamp mode of a known headstage should prefer DAG_GetHeadstageMode() instead.
///
/// @param[in]  panelTitle  panel
/// @param[in]  ctrl        control can be either `Radio_ClampMode_*` or `Check_DataAcqHS_*`
///                         referring to an existing control
/// @param[out] mode        I_CLAMP_MODE, V_CLAMP_MODE or I_EQUAL_ZERO_MODE, the currently active mode for headstage controls
///                         and the clamp mode of the control for clamp mode controls
/// @param[out] headStage   number of the headstage or one of @ref AllHeadstageModeConstants
Function DAP_GetInfoFromControl(panelTitle, ctrl, mode, headStage)
	string panelTitle, ctrl
	variable &mode, &headStage

	string clampMode     = "Radio_ClampMode_"
	string headStageCtrl = "Check_DataAcqHS_"
	variable pos1, pos2, ctrlNo
	string ICctrl, VCctrl, iZeroCtrl, ctrlClean, ctrlSuffix

	mode      = NaN
	headStage = NaN

	ASSERT(!isEmpty(ctrl), "Empty control")

	pos1 = strsearch(ctrl, clampMode, 0)
	pos2 = strsearch(ctrl, headStageCtrl, 0)

	if(pos1 != -1)
		ctrlClean = RemoveEnding(ctrl, "IZ")
		ctrlSuffix = ctrlClean[pos1 + strlen(clampMode), inf]
			if(!cmpstr(ctrlSuffix, "AllVclamp"))
				headStage = CHANNEL_INDEX_ALL_V_CLAMP
				mode = V_CLAMP_MODE
			elseif(!cmpstr(ctrlSuffix, "AllIclamp"))
				headStage = CHANNEL_INDEX_ALL_I_CLAMP
				mode = I_CLAMP_MODE
			elseif(!cmpstr(ctrlSuffix, "AllIzero"))
				headStage = CHANNEL_INDEX_ALL_I_ZERO
				mode = I_EQUAL_ZERO_MODE
			else
				ctrlNo = str2num(ctrlSuffix)
				ASSERT(IsFinite(ctrlNo), "non finite number parsed from control")
				if(IsEven(ctrlNo))
					mode = V_CLAMP_MODE
					headStage = ctrlNo / 2
				else
					if(!cmpstr(ctrlClean, ctrl))
						mode = I_CLAMP_MODE
					else
						mode = I_EQUAL_ZERO_MODE
					endif
					headStage = (ctrlNo - 1) / 2
				endif
			endif
	elseif(pos2 != -1)
		ctrlNo = str2num(ctrl[pos2 + strlen(headStageCtrl), inf])
		ASSERT(IsFinite(ctrlNo), "non finite number parsed from control")
		headStage = ctrlNo

		VCctrl    = DAP_GetClampModeControl(V_CLAMP_MODE, headstage)
		ICctrl    = DAP_GetClampModeControl(I_CLAMP_MODE, headstage)
		iZeroCtrl = DAP_GetClampModeControl(I_EQUAL_ZERO_MODE, headstage)

		mode = V_CLAMP_MODE // safe default

		// deliberately not using the GUI state wave
		if(GetCheckBoxState(panelTitle, VCctrl))
			mode = V_CLAMP_MODE
		elseif(GetCheckBoxState(panelTitle, ICctrl))
			mode = I_CLAMP_MODE
		elseif(GetCheckBoxState(panelTitle, iZeroCtrl))
			mode = I_EQUAL_ZERO_MODE
		endif
	else
		ASSERT(0, "unhandled control")
	endif

	AI_AssertOnInvalidClampMode(mode)
End

Function DAP_CheckProc_ClampMode(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	variable mode, headStage
	string panelTitle, control

	switch(cba.eventCode)
		case 2: // mouse up
			try
				panelTitle = cba.win
				control    = cba.ctrlName
				DAP_GetInfoFromControl(panelTitle, control, mode, headStage)

				NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
				if(dataAcqRunMode == DAQ_NOT_RUNNING)
					DAP_ChangeHeadStageMode(panelTitle, mode, headstage, DO_MCC_MIES_SYNCING)
				else
					WAVE GuiState = GetDA_EphysGuiStateNum(panelTitle)
					GuiState[headstage][%HSmode_delayed] = mode
					DAP_SetAmpModeControls(panelTitle, headstage, mode, delayed = 1)
				endif
			catch
				SetCheckBoxState(panelTitle, control, !cba.checked)
				Abort
			endtry
		break
	endswitch

	return 0
End

Function DAP_CheckProc_HedstgeChck(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	string panelTitle, control
	variable checked

	switch(cba.eventCode)
		case 2: // mouse up
			try
				panelTitle = cba.win
				control    = cba.ctrlName
				checked    = cba.checked
				DAP_ChangeHeadstageState(panelTitle, control, checked)
			catch
				SetCheckBoxState(panelTitle, control, !checked)
				Abort
			endtry

			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			break
	endswitch

	return 0
End

/// @brief Change the clamp mode of the given headstage
/// @param panelTitle Device
/// @param clampMode  Clamp mode to activate
/// @param headstage  Headstage [0, 8[ or use one of @ref AllHeadstageModeConstants
/// @param options    One of @ref ClampModeChangeOptions
Function DAP_ChangeHeadStageMode(panelTitle, clampMode, headstage, options)
	string panelTitle
	variable headstage, clampMode, options

	string iZeroCtrl, VCctrl, ICctrl, headstageCtrl, ctrl
	variable activeHS, testPulseMode, oppositeMode, DAC, ADC, i, oldTab, oldState, newSliderPos

	AI_AssertOnInvalidClampMode(clampMode)
	DAP_AbortIfUnlocked(panelTitle)

	if(options != MCC_SKIP_UPDATES)
		// explicitly switch to the data acquistion tab to avoid having
		// the control layout messed up
		oldTab = GetTabID(panelTitle, "ADC")
		if(oldTab != 0)
			PGC_SetAndActivateControl(panelTitle, "ADC", val=0)
		endif
	endif

	WAVE ChanAmpAssign = GetChanAmpAssign(panelTitle)
	WAVE GuiState = GetDA_EphysGuiStateNum(panelTitle)

   Make/FREE/N=(NUM_HEADSTAGES) changeHS = 0
	if(headstage < 0)
		changeHS[] = 1
		DAP_SetAmpModeControls(panelTitle, headstage, clampMode)
		newSliderPos = DAG_GetNumericalValue(panelTitle, "slider_DataAcq_ActiveHeadstage")
	else
		changeHS[headstage] = 1
		activeHS = DAG_GetHeadstageState(panelTitle, headstage)
		newSliderPos = headstage
	endif

	if(options != MCC_SKIP_UPDATES)
		if(activeHS || headstage < 0)
			testPulseMode = TP_StopTestPulse(panelTitle)
		endif
	endif

	for(i = 0; i < NUM_HEADSTAGES ; i +=1)
		if(!changeHS[i])
			continue
		endif

		if(clampMode == V_CLAMP_MODE)
			DAC = ChanAmpAssign[%VC_DA][i]
			ADC = ChanAmpAssign[%VC_AD][i]
		elseif(clampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE)
			DAC = ChanAmpAssign[%IC_DA][i]
			ADC = ChanAmpAssign[%IC_AD][i]
		endif

		if(!IsFinite(DAC) || !IsFinite(ADC))
			printf "(%s) Could not switch the clamp mode to %s as no DA and/or AD channels are associated with headstage %d.\r", panelTitle, ConvertAmplifierModeToString(clampMode), headstage
			continue
		endif

		GuiState[i][%HSmode] = clampMode

		if(options != MCC_SKIP_UPDATES)
			DAP_SetAmpModeControls(panelTitle, i, clampMode)
			DAP_SetHeadstageChanControls(panelTitle, i, clampMode, delayed = IsFinite(GuiState[i][%HSmode_delayed]))
		endif

		AI_SetClampMode(panelTitle, i, clampMode, zeroStep = DAG_GetNumericalValue(panelTitle, "check_Settings_AmpIEQZstep"))
	endfor

	if(options == MCC_SKIP_UPDATES)
		// we are done
		return NaN
	elseif(options == DO_MCC_MIES_SYNCING)
		PGC_SetAndActivateControl(panelTitle, "slider_DataAcq_ActiveHeadstage", val = newSliderPos)
	elseif(options == NO_SLIDER_MOVEMENT)
		// do nothing
	else
		ASSERT(0, "Unsupported option: " + num2str(options))
	endif

	DAP_UpdateDAQControls(panelTitle, REASON_HEADSTAGE_CHANGE)

	if(activeHS || headstage < 0)
		TP_RestartTestPulse(panelTitle, testPulseMode)
	endif

	if(oldTab != 0)
		PGC_SetAndActivateControl(panelTitle, "ADC", val=oldTab)
	endif
End

///@brief Sets the control state of the radio buttons used for setting the clamp mode on the Data Acquisition Tab of the DA_Ephys panel
///@param panelTitle	device
///@param headstage		controls associated with headstage are set
///@param clampMode		clamp mode to activate
///@param delayed       indicate on the control that the change is delayed
static Function DAP_SetAmpModeControls(panelTitle, headstage, clampMode, [delayed])
	string panelTitle
	variable headstage
	variable clampMode
	variable delayed

	if(ParamIsDefault(delayed))
		delayed = 0
	else
		delayed = !!delayed
	endif

	string VCctrl    = DAP_GetClampModeControl(V_CLAMP_MODE, headstage)
	string ICctrl    = DAP_GetClampModeControl(I_CLAMP_MODE, headstage)
	string iZeroCtrl = DAP_GetClampModeControl(I_EQUAL_ZERO_MODE, headstage)
	string ctrl      = DAP_GetClampModeControl(clampMode, headstage)

	SetCheckboxState(panelTitle, VCctrl, CHECKBOX_UNSELECTED)
	SetCheckboxState(panelTitle, ICctrl, CHECKBOX_UNSELECTED)
	SetCheckboxState(panelTitle, iZeroCtrl, CHECKBOX_UNSELECTED)

	if(headstage >= 0)
		SetCheckboxState(panelTitle, ctrl, CHECKBOX_SELECTED)
	endif

	if(delayed)
		SetControlTitle(panelTitle, ctrl, "D")
		SetControlTitleColor(panelTitle, ctrl, 1, 39321, 19939)
	else
		DAP_ResetClampModeTitle(panelTitle, ctrl)
	endif
End

/// @brief Sets the DA and AD channel settings according to the headstage mode
///
/// @param panelTitle Device (used for data acquisition)
/// @param headstage  Channels associated with headstage are set
/// @param clampMode  Clamp mode to activate
/// @param delayed    [optional, defaults to false] Indicate that this is a delayed clamp mode change
static Function DAP_SetHeadstageChanControls(panelTitle, headstage, clampMode, [delayed])
	string panelTitle
	variable headstage
	variable clampMode, delayed

	variable oppositeMode

	if(!DAG_GetHeadstageState(panelTitle, headstage))
		return NaN
	endif

	oppositeMode = (clampMode == I_CLAMP_MODE || clampMode == I_EQUAL_ZERO_MODE ? V_CLAMP_MODE : I_CLAMP_MODE)
	DAP_RemoveClampModeSettings(panelTitle, headstage, oppositeMode)
	DAP_ApplyClmpModeSavdSettngs(panelTitle, headstage, clampMode)
	DAP_AllChanDASettings(panelTitle, headStage, delayed = delayed)
End

static Function DAP_UpdateClampmodeTabs(panelTitle, headStage, clampMode)
	string panelTitle
	variable headStage, clampMode

	string highlightSpec = "\\f01\\Z11"

	AI_AssertOnInvalidClampMode(clampMode)

	AI_SyncAmpStorageToGUI(panelTitle, headStage)
	PGC_SetAndActivateControl(panelTitle, "tab_DataAcq_Amp", val = clampMode)

	if(DAG_GetNumericalValue(panelTitle, "check_Settings_SyncMiesToMCC"))
		AI_SyncGUIToAmpStorageAndMCCApp(panelTitle, headStage, clampMode)
	endif

	TabControl tab_DataAcq_Amp win=$panelTitle, tabLabel(V_CLAMP_MODE)      = SelectString(clampMode == V_CLAMP_MODE,      "", highlightSpec) + "V-Clamp"
	TabControl tab_DataAcq_Amp win=$panelTitle, tabLabel(I_CLAMP_MODE)      = SelectString(clampMode == I_CLAMP_MODE,      "", highlightSpec) + "I-Clamp"
	TabControl tab_DataAcq_Amp win=$panelTitle, tabLabel(I_EQUAL_ZERO_MODE) = SelectString(clampMode == I_EQUAL_ZERO_MODE, "", highlightSpec) + "I = 0"
End

static Function DAP_ChangeHeadstageState(panelTitle, headStageCtrl, enabled)
	string panelTitle, headStageCtrl
	variable enabled

	variable clampMode, headStage, TPState, ICstate, VCstate, IZeroState
	variable channelType, controlType, i
	string VCctrl, ICctrl, IZeroCtrl

	DAP_AbortIfUnlocked(panelTitle)

	WAVE GUIState = GetDA_EphysGuiStateNum(panelTitle)

	ASSERT(!DAP_ParsePanelControl(headStageCtrl, headstage, channelType, controlType), "Invalid control format")
	ASSERT(channelType == CHANNEL_TYPE_HEADSTAGE && controlType == CHANNEL_CONTROL_CHECK, "Expected headstage checkbox control")

	TPState = TP_StopTestPulse(panelTitle)

	Make/FREE/N=(NUM_HEADSTAGES) changeHS = 0
	if(headstage >= 0)
		changeHS[headstage] = 1
	else
		changeHS[] = 1
	endif

	for(i = 0; i < NUM_HEADSTAGES ; i +=1)
		if(!changeHS[i])
			continue
		endif

		headStageCtrl = GetPanelControl(i, CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK)
		SetCheckBoxState(panelTitle, headStageCtrl, enabled)

		GuiState[i][%$GetSpecialControlLabel(CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK)] = enabled

		clampMode = GuiState[i][%HSmode]
		if(!enabled)
			DAP_RemoveClampModeSettings(panelTitle, i, clampMode)
			P_SetPressureMode(panelTitle, i, PRESSURE_METHOD_ATM)
			P_UpdatePressureType(panelTitle)
		else
			DAP_ApplyClmpModeSavdSettngs(panelTitle, i, clampMode)
		endif

		VCctrl    = DAP_GetClampModeControl(V_CLAMP_MODE, i)
		ICctrl    = DAP_GetClampModeControl(I_CLAMP_MODE, i)
		IZeroCtrl = DAP_GetClampModeControl(I_EQUAL_ZERO_MODE, i)

		// deliberately not using the GUI state wave
		VCstate    = GetCheckBoxState(panelTitle, VCctrl)
		ICstate    = GetCheckBoxState(panelTitle, ICctrl)
		IZeroState = GetCheckBoxState(panelTitle, IZeroCtrl)

		if(VCstate + ICstate + IZeroState != 1) // someone messed up the radio button logic, reset to V_CLAMP_MODE
			PGC_SetAndActivateControl(panelTitle, VCctrl, val=CHECKBOX_SELECTED)
		else
			if(enabled && DAG_GetNumericalValue(panelTitle, "check_Settings_SyncMiesToMCC"))
				PGC_SetAndActivateControl(panelTitle, DAP_GetClampModeControl(clampMode, i), val=CHECKBOX_SELECTED)
			endif
		endif
	endfor

	DAP_UpdateDAQControls(panelTitle, REASON_STIMSET_CHANGE | REASON_HEADSTAGE_CHANGE)

	WAVE statusHS = DAG_GetChannelState(panelTitle, CHANNEL_TYPE_HEADSTAGE)
	if(Sum(statusHS) > 0 )
		TP_RestartTestPulse(panelTitle, TPState)
	endif
End

/// @brief Set the acquisition button text
///
/// @param panelTitle device
/// @param mode       One of @ref ToggleAcquisitionButtonConstants
Function DAP_ToggleAcquisitionButton(panelTitle, mode)
	string panelTitle
	variable mode

	ASSERT(mode == DATA_ACQ_BUTTON_TO_STOP || mode == DATA_ACQ_BUTTON_TO_DAQ, "Invalid mode")

	string text

	if(mode == DATA_ACQ_BUTTON_TO_STOP)
		text = "\\Z14\\f01Stop\rAcquistion"
	elseif(mode == DATA_ACQ_BUTTON_TO_DAQ)
		text = "\\Z14\\f01Acquire\rData"
	endif

	Button DataAcquireButton title=text, win = $panelTitle
End

/// @brief Set the testpulse button text
///
/// @param panelTitle device
/// @param mode       One of @ref ToggleTestpulseButtonConstants
Function DAP_ToggleTestpulseButton(panelTitle, mode)
	string panelTitle
	variable mode

	ASSERT(mode == TESTPULSE_BUTTON_TO_STOP || mode == TESTPULSE_BUTTON_TO_START, "Invalid mode")

	string text

	if(mode == TESTPULSE_BUTTON_TO_STOP)
		text = "\\Z14\\f01Stop Test \rPulse"
	elseif(mode == TESTPULSE_BUTTON_TO_START)
		text = "\\Z14\\f01Start Test \rPulse"
	endif

	Button StartTestPulseButton title=text, win = $panelTitle
End

/// Returns the list of potential followers for yoking.
///
/// Used by popup_Hardware_AvailITC1600s from the hardware tab
Function /s DAP_ListOfITCDevices()

	string listOfPotentialFollowerDevices = RemoveFromList(ITC1600_FIRST_DEVICE,GetListOfLockedITC1600Devices())
	return SortList(listOfPotentialFollowerDevices, ";", 16)
End

/// @brief The Lead button in the yoking controls sets the attached ITC1600 as the device that will trigger all the other devices yoked to it.
Function DAP_ButtonProc_Lead(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle

	switch(ba.eventcode)
		case 2:
			panelTitle = ba.win
			ASSERT(DeviceCanLead(panelTitle),"This device can not lead")

			EnableControls(panelTitle,"button_Hardware_Independent;button_Hardware_AddFollower;title_hardware_Follow;popup_Hardware_AvailITC1600s")
			DisableControl(panelTitle,"button_Hardware_Lead1600")
			PGC_SetAndActivateControl(panelTitle, "setvar_Hardware_Status", str = LEADER)
			createDFWithAllParents("root:ImageHardware:Arduino")
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_Independent(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle

	switch(ba.eventcode)
		case 2:
			panelTitle = ba.win

			DisableControls(panelTitle,"button_Hardware_Independent;button_Hardware_AddFollower;popup_Hardware_YokedDACs;button_Hardware_RemoveYoke;title_hardware_Follow;title_hardware_Release;popup_Hardware_AvailITC1600s")
			EnableControl(panelTitle,"button_Hardware_Lead1600")
			PGC_SetAndActivateControl(panelTitle, "setvar_Hardware_Status", str = "Independent")

			DAP_RemoveAllYokedDACs(panelTitle)
			DAP_UpdateAllYokeControls()
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_Follow(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string leadPanel, panelToYoke

	switch(ba.eventcode)
		case 2: // mouse up

			leadPanel = ba.win

			ControlUpdate/W=$leadPanel popup_Hardware_AvailITC1600s
			ControlInfo/W=$leadPanel popup_Hardware_AvailITC1600s
			if(V_flag > 0 && V_Value >= 1)
				panelToYoke = S_Value
			endif

			if(!windowExists(panelToYoke))
				break
			endif

			ASSERT(CmpStr(panelToYoke, ITC1600_FIRST_DEVICE) != 0, "Can't follow the lead device")

			DAP_SetITCDACasFollower(leadPanel, panelToYoke)
			DAP_UpdateFollowerControls(leadPanel, panelToYoke)
			PGC_SetAndActivateControl(leadPanel, "check_Settings_MD", val = 1)
			PGC_SetAndActivateControl(panelToYoke, "check_Settings_MD", val = 1)
			DisableControls(panelToYoke, YOKE_CONTROLS_DISABLE)
			DisableControls(panelToYoke, YOKE_CONTROLS_DISABLE_AND_LINK)
			EnableControl(leadPanel, "button_Hardware_RemoveYoke")
			EnableControl(leadPanel, "popup_Hardware_YokedDACs")
			EnableControl(leadPanel, "title_hardware_Release")
			break
	endswitch

	return 0
End

static Function DAP_SyncGuiFromLeaderToFollower(panelTitle)
	string panelTitle

	variable numPanels, numEntries
	string panelList

	if(!windowExists(panelTitle) || !DAP_DeviceIsLeader(panelTitle))
		return NaN
	endif

	panelList = GetListofLeaderAndPossFollower(panelTitle)
	DAP_UpdateSweepLimitsAndDisplay(panelTitle)

	numPanels = ItemsInList(panelList)

	if(!numPanels)
		return NaN
	endif

	numEntries = ItemsInList(YOKE_CONTROLS_DISABLE_AND_LINK)

	Make/FREE/T/N=(numEntries) leadEntries    = GetGuiControlValue(panelTitle, StringFromList(p, YOKE_CONTROLS_DISABLE_AND_LINK))
	Make/FREE/N=(numPanels, numEntries) dummy = SetGuiControlValue(StringFromList(p, panelList), StringFromList(q, YOKE_CONTROLS_DISABLE_AND_LINK), leadEntries[q])
End

Function DAP_ButtonProc_YokeRelease(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle
	string panelToDeYoke

	switch(ba.eventcode)
		case 2:
			panelTitle = ba.win

			ControlUpdate/W=$panelTitle popup_Hardware_YokedDACs
			ControlInfo/W=$panelTitle popup_Hardware_YokedDACs
			if(V_flag > 0 && V_Value >= 1)
				panelToDeYoke = S_Value
			endif

			if(!windowExists(panelToDeYoke))
				return 0
			endif

			DAP_RemoveYokedDAC(panelToDeYoke)
			DAP_UpdateYokeControls(panelToDeYoke)
			break
	endswitch

	return 0
End

Function DAP_RemoveYokedDAC(panelToDeYoke)
	string panelToDeYoke

	string leadPanel = ITC1600_FIRST_DEVICE
	string str

	if(!windowExists(leadPanel))
		return 0
	endif

	SVAR listOfFollowerDevices = $GetFollowerList(leadPanel)
	if(ItemsInList(listOfFollowerDevices) == 0)
		return 0
	endif

	if(WhichListItem(panelToDeYoke, listOfFollowerDevices) == -1)
		return 0
	endif

	listOfFollowerDevices = RemoveFromList(panelToDeYoke, listOfFollowerDevices)

	str = listOfFollowerDevices
	if(ItemsInList(listOfFollowerDevices) == 0 )
		// there are no more followers, disable the release button and its popup menu
		DisableControl(leadPanel,"popup_Hardware_YokedDACs")
		DisableControl(leadPanel,"button_Hardware_RemoveYoke")
		str = "No Yoked Devices"
	endif

	PGC_SetAndActivateControl(leadPanel, "setvar_Hardware_YokeList", str = str)
	PGC_SetAndActivateControl(panelToDeYoke, "setvar_Hardware_Status", str = "Independent")

	DisableControl(panelToDeYoke,"setvar_Hardware_YokeList")
	EnableControls(panelToDeYoke, YOKE_CONTROLS_DISABLE)
	EnableControls(panelToDeYoke, YOKE_CONTROLS_DISABLE_AND_LINK)

	PGC_SetAndActivateControl(panelToDeYoke, "setvar_Hardware_YokeList", str = "None")

	NVAR followerdeviceID = $GetDAQDeviceID(panelToDeYoke)
	HW_DisableYoking(HARDWARE_ITC_DAC, followerdeviceID)
End

Function DAP_RemoveAllYokedDACs(panelTitle)
	string panelTitle

	string panelToDeYoke, list
	variable i, listNum

	SVAR listOfFollowerDevices = $GetFollowerList(ITC1600_FIRST_DEVICE)
	if(ItemsInList(listOfFollowerDevices) == 0)
		return 0
	endif

	list = listOfFollowerDevices

	// we have to operate on a copy of ListOfFollowerITC1600s as
	// DAP_RemoveYokedDAC modifies it.

	listNum = ItemsInList(list)

	for(i=0; i < listNum; i+=1)
		panelToDeYoke =  StringFromList(i, list)
		DAP_RemoveYokedDAC(panelToDeYoke)
	endfor
End

/// Sets the lists and buttons on the follower device actively being yoked
Function DAP_UpdateFollowerControls(panelTitle, panelToYoke)
	string panelTitle, panelToYoke

	PGC_SetAndActivateControl(panelToYoke, "setvar_Hardware_Status", str = FOLLOWER)

	EnableControl(panelToYoke,"setvar_Hardware_YokeList")
	PGC_SetAndActivateControl(panelToYoke, "setvar_Hardware_YokeList", str = "Lead device = " + panelTitle)
	DAP_UpdateYokeControls(panelToYoke)
End

Function DAP_ButtonProc_AutoFillGain(ba) : ButtonControl
	struct WMButtonAction &ba

	string panelTitle
	variable numConnAmplifiers

	switch(ba.eventCode)
		case 2: // mouse up
			panelTitle = ba.win

			DAP_AbortIfUnlocked(panelTitle)

			numConnAmplifiers = AI_QueryGainsFromMCC(panelTitle)

			if(numConnAmplifiers)
				DAP_UpdateChanAmpAssignPanel(panelTitle)
				DAP_SyncChanAmpAssignToActiveHS(panelTitle)
			else
				printf "(%s) Could not find any amplifiers connected with headstages.\r", panelTitle
			endif
			break
	endswitch

	return 0
End

Function DAP_SliderProc_MIESHeadStage(sc) : SliderControl
	struct WMSliderAction &sc

	variable mode, headstage
	string panelTitle

	// eventCode is a bitmask as opposed to a plain value
	// compared to other controls
	if(sc.eventCode > 0 && sc.eventCode & 0x1)
		headstage  = sc.curval
		panelTitle = sc.win
		DAG_Update(panelTitle, sc.ctrlName, val = headstage)

		DAP_AbortIfUnlocked(panelTitle)
		mode = DAG_GetHeadstageMode(panelTitle, headStage)
		P_PressureDisplayHighlite(panelTitle, 0)
		P_SaveUserSelectedHeadstage(panelTitle, headStage)
		P_GetAutoUserOff(panelTitle)
		P_UpdatePressureType(panelTitle)
		P_LoadPressureButtonState(panelTitle)
		P_UpdatePressureModeTabs(panelTitle, headStage)
		DAP_UpdateClampmodeTabs(panelTitle, headStage, mode)
		SCOPE_SetADAxisLabel(panelTitle, UNKNOWN_MODE, HeadStage)
		P_RunP_ControlIfTPOFF(panelTitle)
	endif

	return 0
End

Function DAP_SetVarProc_AmpCntrls(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string panelTitle, ctrl
	variable headStage

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			panelTitle = sva.win
			ctrl       = sva.ctrlName
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
			headStage = DAG_GetNumericalValue(panelTitle, "slider_DataAcq_ActiveHeadstage")
			AI_UpdateAmpModel(panelTitle, ctrl, headStage)
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_AmpCntrls(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle, ctrl
	variable headStage

	switch( ba.eventCode )
		case 2: // mouse up
			panelTitle = ba.win
			ctrl       = ba.ctrlName

			headStage = DAG_GetNumericalValue(panelTitle, "slider_DataAcq_ActiveHeadstage")
			AI_UpdateAmpModel(panelTitle, ctrl, headstage)
			break
	endswitch

	return 0
End

Function DAP_CheckProc_AmpCntrls(cba) : CheckBoxControl
	struct WMCheckboxAction &cba

	string panelTitle, ctrl
	variable headStage

	switch( cba.eventCode )
		case 2: // mouse up
			panelTitle = cba.win
			ctrl       = cba.ctrlName

			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			headStage = DAG_GetNumericalValue(panelTitle, "slider_DataAcq_ActiveHeadstage")
			AI_UpdateAmpModel(panelTitle, ctrl, headStage)
			break
	endswitch

	return 0
End

/// @brief Check box procedure for multiple device (MD) support
Function DAP_CheckProc_MDEnable(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch(cba.eventCode)
		case 2: // mouse up
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			DAP_SwitchSingleMultiMode(cba.win, stateChange = 1)
			break
	endswitch

	return 0
End

/// @brief Enable/Disable the related controls for single and multi device DAQ
///
/// @param panelTitle  device
/// @param stateChange [optional, defaults to false] multi device support has been changed from being
///                                                  enabled/disabled or vice versa.
Function DAP_SwitchSingleMultiMode(panelTitle, [stateChange])
	string panelTitle
	variable stateChange

	variable checkedState, useMultiDevice

	if(ParamIsDefault(stateChange))
		stateChange = 0
	else
		stateChange = !!stateChange
	endif

	useMultiDevice = DAG_GetNumericalValue(panelTitle, "check_Settings_MD")

	if(useMultiDevice)
		if(stateChange)
			checkedState = DAG_GetNumericalValue(panelTitle, "Check_Settings_BkgTP")
			SetControlUserData(panelTitle, "Check_Settings_BkgTP", "oldState", num2str(checkedState))
			checkedState = DAG_GetNumericalValue(panelTitle, "Check_Settings_BackgrndDataAcq")
			SetControlUserData(panelTitle, "Check_Settings_BackgrndDataAcq", "oldState", num2str(checkedState))
		endif

		PGC_SetAndActivateControl(panelTitle, "Check_Settings_BkgTP", val = CHECKBOX_SELECTED)
		PGC_SetAndActivateControl(panelTitle, "Check_Settings_BackgrndDataAcq", val = CHECKBOX_SELECTED)
		DisableControls(panelTitle, "Check_Settings_BkgTP;Check_Settings_BackgrndDataAcq")
	else
		EnableControls(panelTitle, "Check_Settings_BkgTP;Check_Settings_BackgrndDataAcq")

		if(stateChange)
			checkedState = str2num(GetUserData(panelTitle, "Check_Settings_BkgTP", "oldState"))
			PGC_SetAndActivateControl(panelTitle, "Check_Settings_BkgTP", val = checkedState)
			checkedState = str2num(GetUserData(panelTitle, "Check_Settings_BackgrndDataAcq", "oldState"))
			PGC_SetAndActivateControl(panelTitle, "Check_Settings_BackgrndDataAcq", val = checkedState)
		endif
	endif
End

/// @brief Controls TP Insertion into set sweeps before the sweep begins
Function DAP_CheckProc_InsertTP(cba) : CheckBoxControl
	struct WMCheckBoxAction &cba

	string panelTitle

	switch(cba.eventCode)
		case 2:
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			DAP_UpdateOnsetDelay(cba.win)
		break
	endswitch

	return 0
End

/// @brief Update the onset delay due to the `Insert TP` setting
Function DAP_UpdateOnsetDelay(panelTitle)
	string panelTitle

	variable pulseDuration, baselineFrac
	variable testPulseDurWithBL

	if(DAG_GetNumericalValue(panelTitle, "Check_Settings_InsertTP"))
		pulseDuration = DAG_GetNumericalValue(panelTitle, "SetVar_DataAcq_TPDuration")
		baselineFrac = DAG_GetNumericalValue(panelTitle, "SetVar_DataAcq_TPBaselinePerc") / 100
		testPulseDurWithBL = TP_CalculateTestPulseLength(pulseDuration, baselineFrac)
	else
		testPulseDurWithBL = 0
	endif

	SetValDisplay(paneltitle, "valdisp_DataAcq_OnsetDelayAuto", var=testPulseDurWithBL)
End

Function DAP_SetVarProc_TestPulseSett(sva) : SetVariableControl
	struct WMSetVariableAction &sva

	variable TPState
	string panelTitle

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			sva.blockReentry = 1
			panelTitle = sva.win
			DAP_AbortIfUnlocked(panelTitle)
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)

			// don't stop the testpulse if we are currently doing DAQ
			NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
			if(dataAcqRunMode != DAQ_NOT_RUNNING)
				DAP_UpdateOnsetDelay(panelTitle)
				break
			endif

			TPState = TP_StopTestPulse(panelTitle)
			DAP_UpdateOnsetDelay(panelTitle)
			TP_RestartTestPulse(panelTitle, TPState)
			break
	endswitch

	return 0
End

Function DAP_UnlockAllDevices()

	string list = GetListOfLockedDevices()
	string win
	variable i, numItems

	// unlock the first ITC1600 device as that might be yoking other devices
	if(WhichListItem(ITC1600_FIRST_DEVICE,list) != -1)
		DAP_UnlockDevice(ITC1600_FIRST_DEVICE)
	endif

	// refetch the, possibly changed, list of locked devices and unlock them all
	list = GetListOfLockedDevices()
	numItems = ItemsInList(list)
	for(i=0; i < numItems; i+=1)
		win = StringFromList(i, list)
		DAP_UnlockDevice(win)
	endfor
End

Function DAP_CheckProc_RepeatedAcq(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch(cba.eventCode)
		case 2: // mouse up
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			DAP_UpdateSweepSetVariables(cba.win)
			DAP_SyncGuiFromLeaderToFollower(cba.win)
			break
	endswitch

	return 0
End

/// @brief Allows two checkboxes to be treated
///        as a group where only one can be checked at a time.
///
/// Write into the GUI state wave as well
static Function DAP_ToggleCheckBoxes(win, ctrl, list, checked)
	string win, ctrl, list
	variable checked

	string partner

	ASSERT(!IsEmpty(ctrl), "Expected non empty control")
	ASSERT(ItemsInList(list) == 2, "Expected a list of two")

	partner = StringFromList(mod(WhichListItem(ctrl, list) + 1, 2), list)
	ASSERT(!IsEmpty(partner), "Invalid ctrl or list")

	DAG_Update(win, partner, val = !checked)
	SetCheckBoxState(win, partner, !checked)
End

Function DAP_CheckProc_SyncCtrl(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch(cba.eventCode)
		case 2: // mouse up

			if(cba.checked)
				DAP_ToggleCheckBoxes(cba.win, cba.ctrlName, "Check_DataAcq1_DistribDaq;Check_DataAcq1_dDAQOptOv", cba.checked)
			endif

			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			DAP_SyncGuiFromLeaderToFollower(cba.win)

			break
	endswitch

	return 0
End

Function DAP_SetVarProc_SyncCtrl(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
			DAP_SyncGuiFromLeaderToFollower(sva.win)
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_TPDAQ(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle
	variable testpulseRunMode

	switch(ba.eventcode)
		case 2:
			ba.blockreentry = 1
			panelTitle = ba.win

			DAP_AbortIfUnlocked(panelTitle)

			if(!cmpstr(ba.ctrlName, "StartTestPulseButton"))

				NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)

				// if data acquisition is currently running we just
				// call TP_StartTestPulse* which automatically ends DAQ
				if(dataAcqRunMode == DAQ_NOT_RUNNING && TP_CheckIfTestpulseIsRunning(panelTitle))
					TP_StopTestPulse(panelTitle)
				elseif(DAG_GetNumericalValue(panelTitle, "check_Settings_MD"))
					TPM_StartTestPulseMultiDevice(panelTitle)
				else
					TPS_StartTestPulseSingleDevice(panelTitle)
				endif
			elseif(!cmpstr(ba.ctrlName, "DataAcquireButton"))

				NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)

				if(dataAcqRunMode == DAQ_NOT_RUNNING)
					testpulseRunMode = TP_StopTestPulse(panelTitle)
					if(DAP_CheckSettings(panelTitle, DATA_ACQUISITION_MODE))
						AS_HandlePossibleTransition(panelTitle, AS_INACTIVE)
						TP_RestartTestPulse(panelTitle, testpulseRunMode)
						Abort
					endif

					if(DAG_GetNumericalValue(panelTitle, "check_Settings_MD"))
						DQM_StartDAQMultiDevice(panelTitle)
					else
						DQS_StartDAQSingleDevice(panelTitle)
					endif
				else // data acquistion is ongoing, stop data acq
					DQ_StopDAQ(panelTitle, DQ_STOP_REASON_DAQ_BUTTON)
				endif
			else
				ASSERT(0, "invalid control")
			endif
			break
	endswitch

	return 0
End

/// @brief Return the comment panel name
Function/S DAP_GetCommentPanel(panelTitle)
	string panelTitle

	return panelTitle + "#" + COMMENT_PANEL
End

/// @brief Return the full window path to the comment notebook
Function/S  DAP_GetCommentNotebook(panelTitle)
	string panelTitle

	return DAP_GetCommentPanel(panelTitle) + "#" + COMMENT_PANEL_NOTEBOOK
End

/// @brief Create the comment panel
static Function DAP_OpenCommentPanel(panelTitle)
	string panelTitle

	string commentPanel, commentNotebook

	DAP_AbortIfUnlocked(panelTitle)

	commentPanel = DAP_GetCommentPanel(panelTitle)
	if(windowExists(commentPanel))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)

	NewPanel/HOST=$panelTitle/N=$COMMENT_PANEL/EXT=1/W=(400,0,0,200)
	NewNotebook/HOST=$commentPanel/F=0/N=$COMMENT_PANEL_NOTEBOOK/FG=(FL,FT,FR,FB)
	ModifyPanel/W=$commentPanel fixedSize=0
	SetWindow $commentPanel, hook(mainHook)=DAP_CommentPanelHook

	SVAR userComment = $GetUserComment(panelTitle)
	ReplaceNotebookText(commentNotebook, userComment)
End

Function DAP_ButtonProc_OpenCommentNB(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	string panelTitle

	switch(ba.eventCode)
		case 2: // mouse up
			panelTitle = ba.win

			DAP_AbortIfUnlocked(panelTitle)
			DAP_AddUserComment(panelTitle)
			break
	endswitch

	return 0
End

static Function/S DAP_FormatCommentString(panelTitle, comment, sweepNo)
	string panelTitle
	string comment
	variable sweepNo

	string str, contents, commentNotebook
	variable length

	ASSERT(!IsEmpty(comment), "Comment can not be empty")
	sweepNo = IsNaN(sweepNo) ? -1 : sweepNo

	sprintf str, "%s, % 5d: %s\r", GetTimeStamp(humanReadable=1), sweepNo, comment

	DAP_OpenCommentPanel(panelTitle)
	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	contents = GetNotebookText(commentNotebook)

	// add a carriage return if the last line does not end with one
	length = strlen(contents)
	if(length > 0 && cmpstr(contents[length - 1], "\r"))
		str = "\r" + str
	endif

	return str
End

/// @brief Add the current user comment of the previous sweep
///        to the comment notebook and to the labnotebook.
///
/// The `SetVariable` for the user comment is also cleared
Function DAP_AddUserComment(panelTitle)
	string panelTitle

	string commentNotebook, comment, formattedComment
	variable sweepNo

	DAP_OpenCommentPanel(panelTitle)

	sweepNo = AFH_GetLastSweepAcquired(panelTitle)
	comment = DAG_GetTextualValue(panelTitle, "SetVar_DataAcq_Comment")

	if(isEmpty(comment))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	formattedComment = DAP_FormatCommentString(panelTitle, comment, sweepNo)
	AppendToNotebookText(commentNotebook, formattedComment)
	NotebookSelectionAtEnd(commentNotebook)

	// after writing the user comment, clear it
	ED_WriteUserCommentToLabNB(panelTitle, comment, sweepNo)
	PGC_SetAndActivateControl(panelTitle, "SetVar_DataAcq_Comment", str = "")
End

/// @brief Make the comment notebook read-only
Function DAP_LockCommentNotebook(panelTitle)
	string panelTitle

	string commentPanel, commentNotebook

	commentPanel = DAP_GetCommentPanel(panelTitle)
	if(!windowExists(commentPanel))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	Notebook $commentNotebook, writeProtect=1, changeableByCommandOnly=1
	DoWindow/W=$commentPanel/T $COMMENT_PANEL, COMMENT_PANEL + " (Lock device to make it writeable again)"
End

/// @brief Make the comment notebook writeable
Function DAP_UnlockCommentNotebook(panelTitle)
	string panelTitle

	string commentPanel, commentNotebook

	commentPanel = DAP_GetCommentPanel(panelTitle)
	if(!windowExists(commentPanel))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	Notebook $commentNotebook, writeProtect=0, changeableByCommandOnly=0

	DoWindow/W=$commentPanel/T $COMMENT_PANEL, COMMENT_PANEL
End

/// @brief Clear the comment notebook's content and the serialized string
Function DAP_ClearCommentNotebook(panelTitle)
	string panelTitle

	string commentPanel, commentNotebook

	SVAR userComment = $GetUserComment(panelTitle)
	userComment = ""

	commentPanel = DAP_GetCommentPanel(panelTitle)
	if(!windowExists(commentPanel))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	ReplaceNotebookText(commentNotebook, "")
End

/// @brief Serialize all comment notebooks
Function DAP_SerializeAllCommentNBs()

	string list = GetListOfLockedDevices()
	CallFunctionForEachListItem(DAP_SerializeCommentNotebook, list)
End

/// @brief Copy the contents of the comment notebook to the user comment string
Function DAP_SerializeCommentNotebook(panelTitle)
	string panelTitle

	string commentPanel, commentNotebook, text

	commentPanel = DAP_GetCommentPanel(panelTitle)
	if(!windowExists(commentPanel))
		return NaN
	endif

	commentNotebook = DAP_GetCommentNotebook(panelTitle)
	text = GetNotebookText(commentNotebook)

	if(isEmpty(text))
		return NaN
	endif

	SVAR userComment = $GetUserComment(panelTitle)
	userComment = text

	NotebookSelectionAtEnd(commentNotebook)
End

Function DAP_CommentPanelHook(s)
	STRUCT WMWinHookStruct &s

	string panelTitle

	switch(s.eventCode)
		case 2: // kill
			panelTitle = GetMainWindow(s.winName)

			if(!DAP_DeviceIsUnlocked(panelTitle))
				DAP_SerializeCommentNotebook(panelTitle)
			endif
			break
	endswitch

	// return zero so that other hooks are called as well
	return 0
End

Function DAP_SetVarProc_TPAmp(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	string panelTitle
	variable TPState

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update

			panelTitle = sva.win
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)

			// don't stop the testpulse if we are currently doing DAQ
			NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
			if(dataAcqRunMode != DAQ_NOT_RUNNING)
				break
			endif

			TPState = TP_StopTestPulse(panelTitle)
			TP_RestartTestPulse(panelTitle, TPState)

			break
	endswitch

	return 0
End

/// @brief Create a new DA_Ephys panel
///
/// @returns panel name
Function/S DAP_CreateDAEphysPanel()

	string panel

	if(!WindowExists("HistoryCarbonCopy"))
		CreateHistoryNotebook()
	endif

	// upgrade folder locations
	GetDAQDevicesFolder()

	// fetch device lists
	DAP_GetNIDeviceList()
	DAP_GetITCDeviceList()

	Execute "DA_Ephys()"
	panel = GetCurrentWindow()
	SCOPE_OpenScopeWindow(panel)
	AddVersionToPanel(panel, DA_EPHYS_PANEL_VERSION)

	NVAR JSONid = $GetSettingsJSONid()
	PS_InitCoordinates(JSONid, panel, "daephys")

	return panel
End

/// @brief	Sets the locked indexing logic checkbox states
Function DAP_CheckProc_LockedLogic(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			string checkBoxPartener = SelectString(cmpstr(cba.ctrlName, "check_Settings_Option_3"),"check_Settings_SetOption_5","check_Settings_Option_3")
			ToggleCheckBoxes(cba.win, cba.ctrlName, checkBoxPartener, cba.checked)
			EqualizeCheckBoxes(cba.win, "check_Settings_Option_3", "Check_DataAcq1_IndexingLocked", DAG_GetNumericalValue(cba.win, "check_Settings_Option_3"))
			if(cmpstr(cba.win, "check_Settings_Option_3") == 0 && cba.checked)
				PGC_SetAndActivateControl(cba.win, "Check_DataAcq_Indexing", val = 1)
			endif
			break
	endswitch

	return 0
End

/// @brief Extracts `channelType`, `controlType` and `channelIndex` from `ctrl`
///
/// Counterpart to GetPanelControl()
///
/// @return 0 if the control name could be parsed, one otherwise
Function DAP_ParsePanelControl(ctrl, channelIndex, channelType, controlType)
	string ctrl
	variable &channelIndex, &channelType, &controlType

	string elem0, elem1, elem2
	variable numUnderlines

	channelIndex = NaN
	channelType  = NaN
	controlType  = NaN

	if(isEmpty(ctrl))
		return 1
	endif

	numUnderlines = ItemsInList(ctrl, "_")
	if(numUnderlines < 2)
		return 1
	endif

	elem0 = StringFromList(0, ctrl, "_")
	elem1 = StringFromList(1, ctrl, "_")
	elem2 = StringFromList(numUnderlines - 1, ctrl, "_")

	strswitch(elem0)
		case "Wave":
			controlType = CHANNEL_CONTROL_WAVE
			break
		case "IndexEnd":
			controlType = CHANNEL_CONTROL_INDEX_END
			break
		case "Unit":
			controlType = CHANNEL_CONTROL_UNIT
			break
		case "Gain":
			controlType = CHANNEL_CONTROL_GAIN
			break
		case "Scale":
			controlType = CHANNEL_CONTROL_SCALE
			break
		case "Check":
			controlType = CHANNEL_CONTROL_CHECK
			break
		case "Min":
			controlType = CHANNEL_CONTROL_ALARM_MIN
			break
		case "Max":
			controlType = CHANNEL_CONTROL_ALARM_MAX
			break
		case "Search":
			controlType = CHANNEL_CONTROL_SEARCH
			break
		case "Title":
			controlType = CHANNEL_CONTROL_TITLE
			break
		default:
			channelIndex = NaN
			channelType  = NaN
			controlType  = NaN
			return 1
			break
	endswitch

	strswitch(elem1)
		case "DataAcqHS":
			channelType = CHANNEL_TYPE_HEADSTAGE
			break
		case "DA":
			channelType = CHANNEL_TYPE_DAC
			break
		case "AD":
			channelType = CHANNEL_TYPE_ADC
			break
		case "TTL":
			channelType = CHANNEL_TYPE_TTL
			break
		case "AsyncAlarm":
			channelType = CHANNEL_TYPE_ALARM
			break
		case "AsyncAD":
			channelType = CHANNEL_TYPE_ASYNC
			break
		default:
			channelIndex = NaN
			channelType  = NaN
			controlType  = NaN
			return 1
			break
	endswitch

	strswitch(elem2)
		case "All":
			channelIndex = CHANNEL_INDEX_ALL
			break
		case "AllVClamp":
			channelIndex = CHANNEL_INDEX_ALL_V_CLAMP
			break
		case "AllIClamp":
			channelIndex = CHANNEL_INDEX_ALL_I_CLAMP
			break
		default:
			channelIndex = str2numSafe(elem2)
			if(!IsFinite(channelIndex))
				channelIndex = NaN
				channelType  = NaN
				controlType  = NaN
				return 1
			endif
			break
	endswitch

	return 0
End

/// @brief Update the list of available pressure devices on all locked device panels
Function DAP_UpdateListOfPressureDevices()

	string list, panelTitle
	variable i, numItems

	list = GetListOfLockedDevices()
	numItems = ItemsInList(list)

	for(i = 0; i < numItems; i += 1)
		panelTitle = StringFromList(i, list)
		PGC_SetAndActivateControl(panelTitle, "button_Settings_UpdateDACList")
	endfor
End

/// @brief Query the device lock status
///
/// @returns device lock status, 1 if unlocked, 0 if locked
Function DAP_DeviceIsUnlocked(panelTitle)
	string panelTitle

	return WhichListItem(panelTitle, GetListOfLockedDevices(), ";", 0, 0) == -1
End

Function DAP_AbortIfUnlocked(panelTitle)
	string panelTitle

	if(DAP_DeviceIsUnlocked(panelTitle))
		DoAbortNow("A device must be locked (see Hardware tab) to proceed")
	endif
End

/// @brief GUI procedure which has the only purpose
///        of storing the control state in the GUI state wave
Function DAP_CheckProc_UpdateGuiState(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			break
	endswitch

	return 0
End

Function DAP_SetVar_SetScale(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
		case 8: // end edit
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval, str = sva.sval)
			break
		case 9: // mouse down
			ShowSetVariableLimitsSelectionPopup(sva)
			break
	endswitch

	return 0
End

Function DAP_SetVar_UpdateGuiState(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
		case 8: // end edit
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval, str = sva.sval)
			break
	endswitch

	return 0
End

Function DAP_CheckProc_Settings_PUser(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	variable headstage

	switch(cba.eventCode)
		case 2: // mouse up
			DAP_AbortIfUnlocked(cba.win)
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			WAVE pressureDataWv = P_GetPressureDataWaveRef(cba.win)
			P_RunP_ControlIfTPOFF(cba.win)
			headstage = PressureDataWv[0][%UserSelectedHeadStage]
			if(P_ValidatePressureSetHeadstage(cba.win, headstage))
				P_SetPressureValves(cba.win, headstage, P_GetUserAccess(cba.win, headstage,PressureDataWv[headstage][%Approach_Seal_BrkIn_Clear]))
			endif
			P_UpdatePressureType(cba.win)

			break
	endswitch

	return 0
End

Function DAP_ButtonProc_LockDev(ba) : ButtonControl
	struct WMButtonAction& ba

	switch(ba.eventCode)
		case 2: // mouse up
			ba.blockReentry = 1
			DAP_LockDevice(ba.win)
			break
	endswitch

	return 0
End

Function DAP_ButProc_Hrdwr_UnlckDev(ba) : ButtonControl
	struct WMButtonAction& ba

	switch(ba.eventCode)
		case 2: // mouse up
			ba.blockReentry = 1
			DAP_UnlockDevice(ba.win)
			break
	endswitch

	return 0
End

static Function DAP_UpdateDataFolderDisplay(panelTitle, locked)
	string panelTitle
	variable locked

	string title
	if(locked)
		title = "Data folder path = " + GetDevicePathAsString(panelTitle)
	else
		title = "Lock a device to generate device folder structure"
	endif

	GroupBox group_Hardware_FolderPath win = $panelTitle, title = title
End

Function DAP_LockDevice(string win)

	variable locked, hardwareType, headstage
	string panelTitleLocked, msg

	SVAR miesVersion = $GetMiesVersion()

	if(!cmpstr(miesVersion, UNKNOWN_MIES_VERSION))
		DEBUGPRINT_OR_ABORT("The MIES version is unknown, locking devices is therefore only allowed in debug mode.")
	endif

	panelTitleLocked = GetPopupMenuString(win, "popup_MoreSettings_Devices")
	if(windowExists(panelTitleLocked))
		DoAbortNow("Attempt to duplicate device connection! Please choose another device number as that one is already in use.")
	endif

	if(!cmpstr(panelTitleLocked, NONE))
		DoAbortNow("Please select a valid device.")
	endif

	if(!HasPanelLatestVersion(win, DA_EPHYS_PANEL_VERSION))
		DoAbortNow("Can not lock the device. The DA_Ephys panel is too old to be usable. Please close it and open a new one.")
	endif

	NVAR deviceID = $GetDAQDeviceID(paneltitleLocked)
	deviceID = HW_OpenDevice(paneltitleLocked, hardwareType)

	if(deviceID < 0 || deviceID >= HARDWARE_MAX_DEVICES)
#ifndef EVIL_KITTEN_EATING_MODE
		DoAbortNow("Can not lock the device.")
#else
		print "EVIL_KITTEN_EATING_MODE is ON: Forcing deviceID to zero"
		ControlWindowToFront()
		deviceID = 0
#endif
	endif

	DisableControls(win,"button_SettingsPlus_LockDevice;popup_MoreSettings_Devices;button_hardware_rescan")
	EnableControl(win,"button_SettingsPlus_unLockDevic")

	DoWindow/W=$win/C $panelTitleLocked

	KillOrMoveToTrash(wv = GetDA_EphysGuiStateNum(panelTitleLocked))
	KillOrMoveToTrash(wv = GetDA_EphysGuiStateTxT(panelTitleLocked))
	// initial fill of the GUI state wave
	// all other changes are propagated immediately to the GUI state waves
	DAG_RecordGuiStateNum(panelTitleLocked)
	DAG_RecordGuiStateTxT(panelTitleLocked)

	locked = 1
	DAP_UpdateDataFolderDisplay(panelTitleLocked, locked)

	AI_FindConnectedAmps()
	DAP_UpdateListOfLockedDevices()
	DAP_UpdateListOfPressureDevices()
	headstage = str2num(GetPopupMenuString(panelTitleLocked, "Popup_Settings_HeadStage"))
	DAP_SyncDeviceAssocSettToGUI(paneltitleLocked, headstage)

	DAP_UpdateDAQControls(panelTitleLocked, REASON_STIMSET_CHANGE | REASON_HEADSTAGE_CHANGE)
	DAP_UpdateAllYokeControls()
	// create the amplifier settings waves
	GetAmplifierParamStorageWave(panelTitleLocked)
	DAP_UpdateDaEphysStimulusSetPopups(panelTitle=panelTitleLocked)
	DAP_UnlockCommentNotebook(panelTitleLocked)
	DAP_ToggleAcquisitionButton(panelTitleLocked, DATA_ACQ_BUTTON_TO_DAQ)
	SI_CalculateMinSampInterval(panelTitleLocked, DATA_ACQUISITION_MODE)

	// deliberately not using the GUIState wave
	headstage = GetSliderPositionIndex(panelTitleLocked, "slider_DataAcq_ActiveHeadstage")
	P_SaveUserSelectedHeadstage(panelTitleLocked, headstage)

	// upgrade all four labnotebook waves in wanna-be atomic way
	GetLBNumericalKeys(panelTitleLocked)
	GetLBNumericalValues(panelTitleLocked)
	GetLBTextualKeys(panelTitleLocked)
	GetLBTextualValues(panelTitleLocked)

	NVAR sessionStartTime = $GetSessionStartTime()
	sessionStartTime = DateTimeInUTC()

	NVAR acqState = $GetAcquisitionState(panelTitleLocked)
	acqState = AS_INACTIVE

	NVAR rngSeed = $GetRNGSeed(panelTitleLocked)
	NewRandomSeed()
	rngSeed = GetReproducibleRandom()

	DAP_UpdateOnsetDelay(panelTitleLocked)

	HW_RegisterDevice(panelTitleLocked, hardwareType, deviceID)
	if(ItemsInList(GetListOfLockedDevices()) == 1)
		DAP_LoadBuiltinStimsets()
		GetPxPVersion()
		SetupBackgroundTasks()
		CtrlNamedBackground _all_, noevents=1
		UploadCrashDumpsDaily()
		// avoid problems with IP not keeping the dimension labels
		// of columns when we have no rows
		// we kill the wave here so that it is recreated properly
		KillOrMoveToTrash(wv = GetDQMActiveDeviceList())
	endif

	DAP_UpdateSweepLimitsAndDisplay(panelTitleLocked, initial = 1)
	DAP_AdaptPanelForDeviceSpecifics(panelTitleLocked)

	LOG_AddEntry(PACKAGE_MIES, "locking", keys = {"device"}, values = {panelTitleLocked})
End

static Function DAP_AdaptPanelForDeviceSpecifics(string panelTitle)

	variable i
	string controls

	WAVE deviceInfo = GetDeviceInfoWave(panelTitle)

	for(i = 0; i < NUM_DA_TTL_CHANNELS; i += 1)

		controls = DAP_GetControlsForChannelIndex(i, CHANNEL_TYPE_DAC)

		if(i < deviceInfo[%DA])
			EnableControls(panelTitle, controls)
		else
#ifndef EVIL_KITTEN_EATING_MODE
			DisableControls(panelTitle, controls)
#endif
		endif
	endfor

	for(i = 0; i < NUM_AD_CHANNELS; i += 1)

		controls = DAP_GetControlsForChannelIndex(i, CHANNEL_TYPE_ADC)

		if(i < deviceInfo[%AD])
			EnableControls(panelTitle, controls)
		else
#ifndef EVIL_KITTEN_EATING_MODE
			DisableControls(panelTitle, controls)
#endif
		endif
	endfor

	for(i = 0; i < NUM_DA_TTL_CHANNELS; i += 1)

		controls = DAP_GetControlsForChannelIndex(i, CHANNEL_TYPE_TTL)

		if(i < deviceInfo[%TTL])
			EnableControls(panelTitle, controls)
		else
#ifndef EVIL_KITTEN_EATING_MODE
			DisableControls(panelTitle, controls)
#endif
		endif
	endfor

	for(i = 0; i < NUM_DA_TTL_CHANNELS; i += 1)

		controls = DAP_GetControlsForChannelIndex(i, CHANNEL_TYPE_ASYNC)

		if(i < deviceInfo[%TTL])
			EnableControls(panelTitle, controls)
		else
#ifndef EVIL_KITTEN_EATING_MODE
			DisableControls(panelTitle, controls)
#endif
		endif
	endfor
End

static Function/S DAP_GetControlsForChannelIndex(variable channelIndex, variable channelType)

	string controls = ""

	switch(channelType)
		case CHANNEL_TYPE_DAC:
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_CHECK), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_GAIN), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_UNIT), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_WAVE), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_SEARCH), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_SCALE), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_INDEX_END), controls, ";", Inf)
			break
		case CHANNEL_TYPE_ADC:
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_CHECK), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_GAIN), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_UNIT), controls, ";", Inf)
			break
		case CHANNEL_TYPE_TTL:
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_CHECK), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_WAVE), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_SEARCH), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_INDEX_END), controls, ";", Inf)
			break
		case CHANNEL_TYPE_ASYNC:
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_TITLE), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_CHECK), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_GAIN), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_UNIT), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, CHANNEL_TYPE_ALARM, CHANNEL_CONTROL_CHECK), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_ALARM_MIN), controls, ";", Inf)
			controls = AddListItem(GetPanelControl(channelIndex, channelType, CHANNEL_CONTROL_ALARM_MAX), controls, ";", Inf)
			break
	endswitch

	return controls
End

static Function DAP_LoadBuiltinStimsets()

	string symbPath, stimset, files, filename
	variable i, numEntries

	symbPath = GetUniqueSymbolicPath()
	NewPath/Q $symbPath, GetFolder(FunctionPath("")) + "..:Stimsets"

	PathInfo $symbPath
	if(!V_flag)
		KillPath $symbPath
		return NaN
	endif

	files = GetAllFilesRecursivelyFromPath(symbPath, extension = ".nwb")
	numEntries = ItemsInList(files, "|")
	for(i = 0; i < numEntries; i += 1)
		filename = StringFromList(i, files, "|")
		NWB_LoadAllStimsets(filename = filename, overwrite = 1, loadOnlyBuiltins = 1)
	endfor

	KillPath $symbPath
End

static Function DAP_ClearWaveIfExists(wv)
	WAVE/Z wv

	if(WaveExists(wv))
		Redimension/N=(0, -1, -1, -1) wv
	endif
End

static Function DAP_UnlockDevice(panelTitle)
	string panelTitle

	variable flags, state, hardwareType
	string lockedDevices

	if(!windowExists(panelTitle))
		DEBUGPRINT("Can not unlock the non-existing panel", str=panelTitle)
		return NaN
	endif

	if(DAP_DeviceIsUnlocked(panelTitle))
		DEBUGPRINT("Device is not locked, doing nothing", str=panelTitle)
		return NaN
	endif

	// we need to turn off TP after DAQ as this could prevent stopping the TP,
	// especially for foreground TP
	state = DAG_GetNumericalValue(panelTitle, "check_Settings_TPAfterDAQ")
	PGC_SetAndActivateControl(panelTitle, "check_Settings_TPAfterDAQ", val = CHECKBOX_UNSELECTED)
	DQ_StopDAQ(panelTitle, DQ_STOP_REASON_UNLOCKED_DEVICE)
	TP_StopTestPulse(panelTitle)
	ASSERT(!ASYNC_WaitForWLCToFinishAndRemove(WORKLOADCLASS_TP + panelTitle, DAP_WAITFORTPANALYSIS_TIMEOUT), "TP analysis did not finish within timeout")
	NWB_ASYNC_FinishWriting(panelTitle)

	PGC_SetAndActivateControl(panelTitle, "check_Settings_TPAfterDAQ", val = state)

	DAP_SerializeCommentNotebook(panelTitle)
	DAP_LockCommentNotebook(panelTitle)
	PGC_SetAndActivateControl(panelTitle, "button_Hardware_P_Disable")
	PGC_SetAndActivateControl(panelTitle, "button_Hardware_PUser_Disable")

	if(DeviceHasFollower(panelTitle))
		DAP_RemoveALLYokedDACs(panelTitle)
	else
		DAP_RemoveYokedDAC(panelTitle)
	endif

	EnableControls(panelTitle,"button_SettingsPlus_LockDevice;popup_MoreSettings_Devices;button_hardware_rescan")
	DisableControl(panelTitle,"button_SettingsPlus_unLockDevic")
	EnableControls(panelTitle, "StartTestPulseButton;DataAcquireButton;Check_DataAcq1_RepeatAcq;Check_DataAcq_Indexing;SetVar_DataAcq_ITI;SetVar_DataAcq_SetRepeats;Check_DataAcq_Get_Set_ITI")
	SetVariable setvar_Hardware_Status Win = $panelTitle, value= _STR:"Independent"
	DAP_ResetGUIAfterDAQ(panelTitle)
	DAP_ToggleTestpulseButton(panelTitle, TESTPULSE_BUTTON_TO_START)

	KillOrMoveToTrash(wv = GetDA_EphysGuiStateNum(panelTitle))
	KillOrMoveToTrash(wv = GetDA_EphysGuiStateTxT(panelTitle))

	string panelTitleUnlocked = BASE_WINDOW_TITLE
	if(CheckName(panelTitleUnlocked,CONTROL_PANEL_TYPE))
		panelTitleUnlocked = UniqueName(BASE_WINDOW_TITLE + "_",CONTROL_PANEL_TYPE,1)
	endif
	DoWindow/W=$panelTitle/C $panelTitleUnlocked

	variable locked = 0
	DAP_UpdateDataFolderDisplay(panelTitleUnlocked,locked)

	NVAR/SDFR=GetDevicePath(panelTitle) deviceID

	hardwareType = GetHardwareType(panelTitle)
	// shutdown the FIFO thread now in case it is still running (which should never be the case)
	TFH_StopFIFODaemon(hardwareType, deviceID)

	flags = HARDWARE_PREVENT_ERROR_POPUP | HARDWARE_PREVENT_ERROR_MESSAGE
	HW_CloseDevice(hardwareType, deviceID, flags=flags)
	HW_ResetDevice(hardwareType, deviceID, flags=flags)
	HW_DeRegisterDevice(hardwareType, deviceID, flags=flags)

	DAP_UpdateYokeControls(panelTitleUnlocked)
	DAP_UpdateListOfLockedDevices()
	DAP_UpdateAllYokeControls()

	// reset our state variables to safe defaults
	NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)
	dataAcqRunMode = DAQ_NOT_RUNNING
	NVAR count = $GetCount(panelTitle)
	count = 0
	NVAR runMode = $GetTestpulseRunMode(panelTitle)
	runMode = TEST_PULSE_NOT_RUNNING

	lockedDevices = GetListOfLockedDevices()
	if(IsEmpty(lockedDevices))
		CloseNWBFile()

		WAVE ActiveDevicesTPMD = GetActiveDevicesTPMD()
		ActiveDevicesTPMD = NaN
		SetNumberInWaveNote(ActiveDevicesTPMD, NOTE_INDEX, 0)

		DFREF dfr = GetActiveDAQDevicesFolder()
		WAVE/Z/SDFR=dfr ActiveDeviceList
		DAP_ClearWaveIfExists(ActiveDeviceList)

		DFREF dfr = GetActiveDAQDevicesTimerFolder()
		WAVE/Z/SDFR=dfr ActiveDevTimeParam, TimerFunctionListWave
		DAP_ClearWaveIfExists(ActiveDevTimeParam)
		DAP_ClearWaveIfExists(TimerFunctionListWave)

		SVAR listOfFollowers = $GetFollowerList(ITC1600_FIRST_DEVICE)
		listOfFollowers = ""

		KillOrMoveToTrash(wv = GetDeviceMapping())
	endif

	KillOrMoveToTrash(wv = GetDA_EphysGuiStateNum(panelTitleUnlocked))
	KillOrMoveToTrash(wv = GetDA_EphysGuiStateTxT(panelTitleUnlocked))
End

/// @brief Update the list of locked devices
static Function DAP_UpdateListOfLockedDevices()
	variable i, numDevs, numItm
	string NIPanelList = ""
	string ITCPanelList = WinList("ITC*", ";", "WIN:64")
	string allPanelList = WinList("*", ";", "WIN:64")
	string NIDevList = DAP_GetNIDeviceList()

	numDevs = ItemsInList(NIDevList)
	for(i = 0;i < numDevs; i += 1)
		numItm = WhichListItem(StringFromList(i, NIDevList), allPanelList)
		if(numItm > -1)
			NIPanelList = AddListItem(StringFromList(numItm, allPanelList), NIPanelList, ";")
		endif
	endfor

	SVAR panelList = $GetDevicePanelTitleList()
	panelList = ITCPanelList + NIPanelList
End

static Function DAP_UpdateChanAmpAssignStorWv(panelTitle)
	string panelTitle

	variable HeadStageNo, ampSerial, ampChannelID
	string amplifierDef
	Wave ChanAmpAssign       = GetChanAmpAssign(panelTitle)
	Wave/T ChanAmpAssignUnit = GetChanAmpAssignUnit(panelTitle)

	HeadStageNo = str2num(GetPopupMenuString(panelTitle,"Popup_Settings_HeadStage"))

	// Assigns V-clamp settings for a particular headstage
	ChanAmpAssign[%VC_DA][HeadStageNo]     = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_VC_DA"))
	ChanAmpAssign[%VC_DAGain][HeadStageNo] = GetSetVariable(panelTitle, "setvar_Settings_VC_DAgain")
	ChanAmpAssignUnit[%VC_DAUnit][HeadStageNo]      = GetSetVariableString(panelTitle, "SetVar_Hardware_VC_DA_Unit")
	ChanAmpAssign[%VC_AD][HeadStageNo]     = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_VC_AD"))
	ChanAmpAssign[%VC_ADGain][HeadStageNo] = GetSetVariable(panelTitle, "setvar_Settings_VC_ADgain")
	ChanAmpAssignUnit[%VC_ADUnit][HeadStageNo]      = GetSetVariableString(panelTitle, "SetVar_Hardware_VC_AD_Unit")

	//Assigns I-clamp settings for a particular headstage
	ChanAmpAssign[%IC_DA][HeadStageNo]     = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_IC_DA"))
	ChanAmpAssign[%IC_DAGain][HeadStageNo] = GetSetVariable(panelTitle, "setvar_Settings_IC_DAgain")
	ChanAmpAssignUnit[%IC_DAUnit][HeadStageNo]      = GetSetVariableString(panelTitle, "SetVar_Hardware_IC_DA_Unit")
	ChanAmpAssign[%IC_AD][HeadStageNo]     = str2num(GetPopupMenuString(panelTitle, "Popup_Settings_IC_AD"))
	ChanAmpAssign[%IC_ADGain][HeadStageNo] = GetSetVariable(panelTitle, "setvar_Settings_IC_ADgain")
	ChanAmpAssignUnit[%IC_ADUnit][HeadStageNo]      = GetSetVariableString(panelTitle, "SetVar_Hardware_IC_AD_Unit")

	// Assigns amplifier to a particular headstage
	// sounds weird because this relationship is predetermined in hardware
	// but now you are telling the software what it is
	amplifierDef = GetPopupMenuString(panelTitle, "popup_Settings_Amplifier")
	DAP_ParseAmplifierDef(amplifierDef, ampSerial, ampChannelID)

	if(IsFinite(ampSerial) && IsFinite(ampChannelID))
		ChanAmpAssign[%AmpSerialNo][HeadStageNo]  = ampSerial
		ChanAmpAssign[%AmpChannelID][HeadStageNo] = ampChannelID
	else
		ChanAmpAssign[%AmpSerialNo][HeadStageNo]  = nan
		ChanAmpAssign[%AmpChannelID][HeadStageNo] = nan
	endif
End

static Function DAP_UpdateChanAmpAssignPanel(panelTitle)
	string panelTitle

	variable HeadStageNo, channel, ampSerial, ampChannelID
	string entry

	Wave ChanAmpAssign       = GetChanAmpAssign(panelTitle)
	Wave/T ChanAmpAssignUnit = GetChanAmpAssignUnit(panelTitle)

	HeadStageNo = str2num(GetPopupMenuString(panelTitle,"Popup_Settings_HeadStage"))

	// VC DA settings
	channel = ChanAmpAssign[%VC_DA][HeadStageNo]
	Popupmenu Popup_Settings_VC_DA win = $panelTitle, mode = (IsFinite(channel) ? channel : NUM_MAX_CHANNELS) + 1
	Setvariable setvar_Settings_VC_DAgain win = $panelTitle, value = _num:ChanAmpAssign[%VC_DAGain][HeadStageNo]
	Setvariable SetVar_Hardware_VC_DA_Unit win = $panelTitle, value = _str:ChanAmpAssignUnit[%VC_DAUnit][HeadStageNo]

	// VC AD settings
	channel = ChanAmpAssign[%VC_AD][HeadStageNo]
	Popupmenu Popup_Settings_VC_AD win = $panelTitle, mode = (IsFinite(channel) ? channel : NUM_MAX_CHANNELS) + 1
	Setvariable setvar_Settings_VC_ADgain win = $panelTitle, value = _num:ChanAmpAssign[%VC_ADGain][HeadStageNo]
	Setvariable SetVar_Hardware_VC_AD_Unit win = $panelTitle, value = _str:ChanAmpAssignUnit[%VC_ADUnit][HeadStageNo]

	// IC DA settings
	channel = ChanAmpAssign[%IC_DA][HeadStageNo]
	Popupmenu Popup_Settings_IC_DA win = $panelTitle, mode = (IsFinite(channel) ? channel : NUM_MAX_CHANNELS) + 1
	Setvariable setvar_Settings_IC_DAgain win = $panelTitle, value = _num:ChanAmpAssign[%IC_DAGain][HeadStageNo]
	Setvariable SetVar_Hardware_IC_DA_Unit win = $panelTitle, value = _str:ChanAmpAssignUnit[%IC_DAUnit][HeadStageNo]

	// IC AD settings
	channel = ChanAmpAssign[%IC_AD][HeadStageNo]
	Popupmenu  Popup_Settings_IC_AD win = $panelTitle, mode = (IsFinite(channel) ? channel : NUM_MAX_CHANNELS) + 1
	Setvariable setvar_Settings_IC_ADgain win = $panelTitle, value = _num:ChanAmpAssign[%IC_ADGain][HeadStageNo]
	Setvariable SetVar_Hardware_IC_AD_Unit win = $panelTitle, value = _str:ChanAmpAssignUnit[%IC_ADUnit][HeadStageNo]

	if(cmpstr(DAP_GetNiceAmplifierChannelList(), NONE))
		ampSerial    = ChanAmpAssign[%AmpSerialNo][HeadStageNo]
		ampChannelID = ChanAmpAssign[%AmpChannelID][HeadStageNo]
		if(isFinite(ampSerial) && isFinite(ampChannelID))
			entry = DAP_GetAmplifierDef(ampSerial, ampChannelID)
			Popupmenu popup_Settings_Amplifier win = $panelTitle, popmatch=entry
		else
			Popupmenu popup_Settings_Amplifier win = $panelTitle, popmatch=NONE
		endif
	endif
End

/// This function sets a ITC1600 device as a follower, ie. The internal clock is used to synchronize 2 or more PCI-1600
static Function DAP_SetITCDACasFollower(leadDAC, followerDAC)
	string leadDAC, followerDAC

	SVAR listOfFollowerDevices = $GetFollowerList(leadDAC)
	NVAR followerdeviceID = $GetDAQDeviceID(followerDAC)

	if(WhichListItem(followerDAC, listOfFollowerDevices) == -1)
		listOfFollowerDevices = AddListItem(followerDAC, listOfFollowerDevices,";",inf)
		HW_EnableYoking(HARDWARE_ITC_DAC, followerdeviceID)
		setvariable setvar_Hardware_YokeList Win = $leadDAC, value= _STR:listOfFollowerDevices, disable = 0
	endif
	// TB: what does this comment mean?
	// set the internal clock of the device
End

/// @brief Helper function to update all DAQ related controls after something changed.
///
/// @param panelTitle device
/// @param updateFlag One of @ref UpdateControlsFlags
Function DAP_UpdateDAQControls(panelTitle, updateFlag)
	string panelTitle
	variable updateFlag

	DEBUGPRINT("updateFlag", var = updateFlag)

	if(updateFlag & REASON_STIMSET_CHANGE)
		DAP_UpdateSweepSetVariables(panelTitle)
		AFM_UpdateAnalysisFunctionWave(panelTitle)
	elseif(updateFlag & REASON_STIMSET_CHANGE_DUR_DAQ)
		AFM_UpdateAnalysisFunctionWave(panelTitle)
		SetValDisplay(panelTitle, "valdisp_DataAcq_SweepsActiveSet", var=IDX_MaxNoOfSweeps(panelTitle, 1))
	endif

	if(updateFlag & REASON_HEADSTAGE_CHANGE)
		SetValDisplay(panelTitle, "ValDisp_DataAcq_SamplingInt", var=DAP_GetSampInt(panelTitle, DATA_ACQUISITION_MODE))
	endif

	if((updateFlag & REASON_HEADSTAGE_CHANGE) || (updateFlag & REASON_STIMSET_CHANGE))
		DAP_CheckSkipAhead(panelTitle)
	endif
End

/// @brief Applies user settings for the clamp mode stimulus sets (DA Set and Indexing End Set) on mode switch
///
/// @param panelTitle device
/// @param headStage  MIES headstage number, must be in the range [0, NUM_HEADSTAGES]
/// @param delayed    [optional, defaults to false] On a delayed clamp mode change the stimulus set is not set.
static Function DAP_AllChanDASettings(panelTitle, headStage, [delayed])
	string panelTitle
	variable headStage, delayed

	string ctrl
	variable scalar, index, indexEnd, DAC, clampMode

	if(!DAG_GetNumericalValue(panelTitle, "check_DA_applyOnModeSwitch"))
		return NaN
	endif

	if(ParamIsDefault(delayed))
		delayed = 0
	else
		delayed = !!delayed
	endif

	DAC = AFH_GetDACFromHeadstage(paneltitle, headstage)

	if(IsNan(DAC))
		return NaN
	endif

	clampMode = DAG_GetHeadstageMode(panelTitle, headStage)

	if(clampMode == V_CLAMP_MODE)
		scalar = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_V_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_SCALE))
		index = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_V_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_WAVE))
		indexEnd = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_V_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_INDEX_END))
	elseif(clampMode == I_CLAMP_MODE)
		scalar = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_I_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_SCALE))
		index = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_I_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_WAVE))
		indexEnd = DAG_GetNumericalValue(panelTitle, GetPanelControl(CHANNEL_INDEX_ALL_I_CLAMP,CHANNEL_TYPE_DAC,CHANNEL_CONTROL_INDEX_END))
	endif

	// update the scalar
	ctrl = GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_SCALE)
	PGC_SetAndActivateControl(panelTitle, ctrl, val = scalar)

	// update the stimulus/index end set if not delayed clamp mode change
	if(!delayed)
		ctrl = GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
		PGC_SetAndActivateControl(panelTitle, ctrl, val = index)

		ctrl = GetPanelControl(DAC, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_INDEX_END)
		PGC_SetAndActivateControl(panelTitle, ctrl, val = indexEnd)
	endif
End

Function DAP_ButtonProc_skipSweep(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2:
			RA_SkipSweeps(ba.win, 1, limitToSetBorder = 1, document = 1)
			break
	endswitch

	return 0
End

Function DAP_ButtonProc_skipBack(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2:
			RA_SkipSweeps(ba.win, -1, limitToSetBorder = 1, document = 1)
			break
	endswitch

	return 0
End

Function DAP_GetskipAhead(panelTitle)
	string panelTitle

	return GetDA_EphysGuiStateNum(panelTitle)[0][%SetVar_DataAcq_skipAhead]
End

Function DAP_ResetskipAhead(panelTitle)
	string panelTitle

	WAVE guiState = GetDA_EphysGuiStateNum(panelTitle)
	guiState[0][%SetVar_DataAcq_skipAhead] = 0
	PGC_SetAndActivateControl(panelTitle, "SetVar_DataAcq_skipAhead", val=0)
End

Function DAP_getFilteredSkipAhead(panelTitle, skipAhead)
	string panelTitle
	variable skipAhead

	variable maxSkipAhead = max(0, IDX_MinNoOfSweeps(panelTitle) - 1)
	return skipAhead > maxSkipAhead ? maxSkipAhead : skipAhead
End

Function DAP_setSkipAheadLimit(panelTitle, filteredSkipAhead)
	string panelTitle
	variable filteredSkipAhead

	SetSetVariableLimits(panelTitle, "SetVar_DataAcq_skipAhead", 0, max(0, filteredSkipAhead), 1)
End

Function DAP_SetVarProc_skipAhead(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1:
		case 2:
		case 3:
			DAG_Update(sva.win, sva.ctrlName, val = sva.dval)
			DAP_setSkipAheadLimit(sva.win,  IDX_MinNoOfSweeps(sva.win) - 1)
			break
	endswitch

	return 0
End

Function DAP_CheckProc_RandomRA(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2:
			DAG_Update(cba.win, cba.ctrlName, val = cba.checked)
			if(cba.checked)
				disableControl(cba.win, "SetVar_DataAcq_skipAhead")
				PGC_SetAndActivateControl(cba.win, "SetVar_DataAcq_skipAhead", val=0)
			else
				enableControl(cba.win, "SetVar_DataAcq_skipAhead")
			endif
			break
	endswitch

	return 0
End

Function DAP_CheckSkipAhead(panelTitle)
	string panelTitle

	variable activeSkipAhead = DAG_GetNumericalValue(panelTitle, "SetVar_DataAcq_skipAhead")
	variable filteredSkipAhead = DAP_getFilteredSkipAhead(panelTitle, activeSkipAhead)
	if(activeSkipAhead > filteredSkipAhead)
		printf "Skip ahead value exceeds allowed limit for new selection and has been set to %d \r", filteredSkipAhead
		PGC_SetAndActivateControl(panelTitle, "SetVar_DataAcq_skipAhead", val=filteredSkipAhead)
		controlWindowToFront()
	endif

	DAP_setSkipAheadLimit(panelTitle, filteredSkipAhead)
End

Function DAP_PopMenuProc_UpdateGuiState(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch(pa.eventCode)
		case 2: // mouse up
			DAG_Update(pa.win, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)
			break
	endswitch

	return 0
End

/// @brief Return the list of available sampling multipliers
///
/// Has no `NONE` element as `1` means no multiplier.
Function/S DAP_GetSamplingMultiplier()

	return "1;2;4;8;16;32;64"
End

Function DAP_PopMenuProc_SampMult(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch(pa.eventCode)
		case 2: // mouse up
			DAG_Update(pa.win, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)
			DAP_UpdateDAQControls(pa.win, REASON_HEADSTAGE_CHANGE)

			if(!cmpstr(pa.popStr, "1"))
				EnableControl(pa.win, "Popup_Settings_FixedFreq")
			else
				DisableControl(pa.win, "Popup_Settings_FixedFreq")
			endif
			break
	endswitch

	return 0
End

/// @brief Return the list of available fixed sampling frequencies
Function/S DAP_GetSamplingFrequencies()

	return "Maximum;100;50;25;10"
End

Function DAP_PopMenuProc_FixedSampInt(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch(pa.eventCode)
		case 2: // mouse up
			DAG_Update(pa.win, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)
			DAP_UpdateDAQControls(pa.win, REASON_HEADSTAGE_CHANGE)

			if(!cmpstr(pa.popStr, "Maximum"))
				EnableControl(pa.win, "Popup_Settings_SampIntMult")
			else
				DisableControl(pa.win, "Popup_Settings_SampIntMult")
			endif
			break
	endswitch

	return 0
End

/// @brief Return the list of available Oscilloscope Update Modes
Function/S DAP_GetOsciUpdModes()

	string list = ""
	list = AddListItem("Interval", list, ";", GUI_SETTING_OSCI_SCALE_INTERVAL)
	list = AddListItem("Auto Scale", list, ";", GUI_SETTING_OSCI_SCALE_AUTO)
	list = AddListItem("Fixed Scale", list, ";", GUI_SETTING_OSCI_SCALE_FIXED)
	return list
End

Function DAP_PopMenuProc_OsciUpdMode(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	string panelTitle

	switch(pa.eventCode)
		case 2: // mouse up
			panelTitle = pa.win
			DAG_Update(panelTitle, pa.ctrlName, val = pa.popNum - 1, str = pa.popStr)

			NVAR tpRunMode = $GetTestpulseRunMode(panelTitle)
			NVAR dataAcqRunMode = $GetDataAcqRunMode(panelTitle)

			if(IsFinite(tpRunMode) && tpRunMode != TEST_PULSE_NOT_RUNNING)
				SCOPE_CreateGraph(panelTitle, TEST_PULSE_MODE)
			elseif(IsFinite(dataAcqRunMode) && dataAcqRunMode != DAQ_NOT_RUNNING)
				SCOPE_CreateGraph(panelTitle, DATA_ACQUISITION_MODE)
			endif
			break
	endswitch

	return 0
End

Function DAP_ApplyDelayedClampModeChange(panelTitle)
	string panelTitle

	variable i, mode

	WAVE GuiState = GetDA_EphysGuiStateNum(panelTitle)

	for(i = 0; i < NUM_HEADSTAGES; i += 1)
		mode = GuiState[i][%HSmode_delayed]

		if(IsNaN(mode))
			continue
		endif

		DAP_ChangeHeadStageMode(panelTitle, mode, i, NO_SLIDER_MOVEMENT)
	endfor

	DAP_ClearDelayedClampModeChange(panelTitle)
End

Function DAP_ClearDelayedClampModeChange(panelTitle)
	string panelTitle

	WAVE GuiState = GetDA_EphysGuiStateNum(panelTitle)
	GuiState[][%HSmode_delayed] = NaN
End

Function ButtonProc_Hardware_rescan(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			SVAR globalITCDevList = $GetITCDeviceList()
			SVAR globalNIDevList = $GetNIDeviceList()

			KillStrings/Z globalITCDevList, globalNIDevList

			DAP_GetNIDeviceList()
			DAP_GetITCDeviceList()
			break
	endswitch

	return 0
End

/// @brief Update the device info waves for all passed devices
///
/// Usually only called once during startup
///
/// @param deviceList   list of devices usable for DAQ and pressure
/// @param hardwareType One of @ref HardwareDACTypeConstants
Function DAP_UpdateDeviceInfoWaves(string deviceList, variable hardwareType)
	string device
	variable numEntries, i

	numEntries = ItemsInList(deviceList)
	for(i = 0; i < numEntries; i += 1)
		device = StringFromList(i, deviceList)
		WAVE deviceInfo = GetDeviceInfoWave(device)
		WAVE devInfoHW = HW_GetDeviceInfoUnregistered(hardwareType, device)
		hardwareType = GetHardwareType(device)
		HW_WriteDeviceInfo(hardwareType, deviceInfo, devInfoHW)
	endfor
End

Function DAP_CheckProc_PowerSpectrum(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	variable testPulseMode
	string panelTitle

	switch(cba.eventCode)
		case 2: // mouse up
			panelTitle = cba.win
			DAG_Update(panelTitle, cba.ctrlName, val = cba.checked)

			testPulseMode = TP_StopTestPulse(panelTitle)
			TP_RestartTestPulse(panelTitle, testPulseMode)
			break
	endswitch

	return 0
End

/// @brief Update the popup menus and its `MenuExp` user data after stim set changes
///
/// @param panelTitle [optional, defaults to all locked devices] device
Function DAP_UpdateDaEphysStimulusSetPopups([panelTitle])
	string panelTitle

	variable i, j, numPanels
	string ctrlWave, ctrlIndexEnd, DAlist, TTLlist, listOfPanels

	if(ParamIsDefault(panelTitle))
		listOfPanels = GetListOfLockedDevices()

		if(isEmpty(listOfPanels))
			return NaN
		endif
	else
		listOfPanels = panelTitle
	endif

	DEBUGPRINT("Updating", str=listOfPanels)

	DAlist  = WB_GetStimsetList(channelType = CHANNEL_TYPE_DAC)
	TTLlist = WB_GetStimsetList(channelType = CHANNEL_TYPE_TTL)

	numPanels = ItemsInList(listOfPanels)
	for(i = 0; i < numPanels; i += 1)
		panelTitle = StringFromList(i, listOfPanels)

		if(!WindowExists(panelTitle))
			continue
		endif

		for(j = CHANNEL_INDEX_ALL; j < NUM_DA_TTL_CHANNELS; j += 1)
			ctrlWave     = GetPanelControl(j, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
			ctrlIndexEnd = GetPanelControl(j, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_INDEX_END)
			SetControlUserData(panelTitle, ctrlWave, "MenuExp", DAlist)
			SetControlUserData(panelTitle, ctrlIndexEnd, "MenuExp", DAlist)

			ctrlWave     = GetPanelControl(j, CHANNEL_TYPE_TTL, CHANNEL_CONTROL_WAVE)
			ctrlIndexEnd = GetPanelControl(j, CHANNEL_TYPE_TTL, CHANNEL_CONTROL_INDEX_END)
			SetControlUserData(panelTitle, ctrlWave, "MenuExp", TTLlist)
			SetControlUserData(panelTitle, ctrlIndexEnd, "MenuExp", TTLlist)
		endfor

		DAP_UpdateDAQControls(panelTitle, REASON_STIMSET_CHANGE)
	endfor
End

/// @brief Returns the names of the items in the popmenu controls in a list
static Function/S DAP_PopupMenuWaveNameList(panelTitle, channelType, controlType)
	string panelTitle
	variable channelType, controlType

	string ctrl, stimset
	string list = ""
	variable i

	ASSERT(controlType == CHANNEL_CONTROL_WAVE || controlType == CHANNEL_CONTROL_INDEX_END, "Invalid controlType")

	for(i = 0; i < NUM_DA_TTL_CHANNELS; i += 1)
		ctrl = GetPanelControl(i, channelType, controlType)
		stimset = GetPopupMenuString(panelTitle, ctrl)
		list = AddListItem(stimset, list, ";", Inf)
	endfor

	return list
End

static Function DAP_RestorePopupMenuSelection(panelTitle, channelType, controlType, list)
	variable channelType, controlType
	string panelTitle, list

	variable i, stimsetIndex
	string ctrl, stimset

	ASSERT(controlType == CHANNEL_CONTROL_WAVE || controlType == CHANNEL_CONTROL_INDEX_END, "Invalid controlType")

	for(i = 0; i < NUM_DA_TTL_CHANNELS; i += 1)
		ctrl    = GetPanelControl(i, channelType, controlType)
		stimset = GetPopupMenuString(panelTitle, ctrl)

		if(cmpstr(stimset, StringFromList(i, list)) == 1 || isEmpty(stimset))
			stimsetIndex = GetPopupMenuIndex(panelTitle, ctrl)
			PGC_SetAndActivateControl(paneltitle, ctrl, val=(stimsetIndex - 1))
		endif
	endfor
End

/// @brief Delete the stimulus set in the given DAEphys
///
/// Internal use only, outside callers should use WB_RemoveStimulusSet()
Function DAP_DeleteStimulusSet(string setName, [string device])
	variable channelType
	string popupMenuSelectedItemsStart, popupMenuSelectedItemsEnd

	if(ParamIsDefault(device))
		WB_KillParameterWaves(setName)
		WB_KillStimset(setName)
		return NaN
	endif

	channelType = GetStimSetType(setName)

	popupMenuSelectedItemsStart = DAP_PopupMenuWaveNameList(device, channelType, CHANNEL_CONTROL_WAVE)
	popupMenuSelectedItemsEnd = DAP_PopupMenuWaveNameList(device, channelType, CHANNEL_CONTROL_INDEX_END)
	WB_KillParameterWaves(setName)
	WB_KillStimset(setName)
	DAP_RestorePopupMenuSelection(device, channelType, CHANNEL_CONTROL_WAVE, popupMenuSelectedItemsStart)
	DAP_RestorePopupMenuSelection(device, channelType, CHANNEL_CONTROL_INDEX_END, popupMenuSelectedItemsEnd)

	DAP_UpdateDaEphysStimulusSetPopups(panelTitle = device)
End
