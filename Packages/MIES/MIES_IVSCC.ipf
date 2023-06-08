#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

#ifdef AUTOMATED_TESTING
#pragma ModuleName=MIES_IVSCC
#endif

/// @file MIES_IVSCC.ipf
/// @brief __IVS__ Routines for IVSCC/PatchSeq automation
///
/// ZeroMQ Infos:
/// - Listening port for the REP/ROUTER socket starts at #ZEROMQ_BIND_REP_PORT.
/// - Listening port for the PUBLISHER socket starts at #ZEROMQ_BIND_PUB_PORT
/// - If one of those ports is already in use, the next larger port is tried.
/// - The publisher socket does include an automatic heartbeat message every 5 seconds. Subscribe to #ZeroMQ_HEARTBEAT if
///   you want to receive that.
/// - All available message filters can be queried via FFI_GetAvailableMessageFilters().
/// - More information regarding the ZeroMQ-XOP is located [here](https://github.com/AllenInstitute/ZeroMQ-XOP/#readme)
/// - See IVS_PublishQCState() for more infos about the published messages

static Constant    IVS_DEFAULT_NWBVERSION = 2
static Constant    IVS_DEFAULT_HEADSTAGE  = 0
static StrConstant IVS_DEFAULT_DEVICE = "ITC18USB_Dev_0"

Function IVS_ConfigureMCC()
	string device
	variable headstage

	variable oldTab, numErrors, initResult

	device = IVS_DEFAULT_DEVICE
	headstage  = IVS_DEFAULT_HEADSTAGE

	// explicitly switch to the data acquistion tab to avoid having
	// the control layout messed up
	oldTab = GetTabID(device, "ADC")
	PGC_SetAndActivateControl(device, "ADC", val=0)

	if(AI_SelectMultiClamp(device, headstage) != AMPLIFIER_CONNECTION_SUCCESS)
		print "MCC not valid...cannot initialize Amplifier Settings"
		numErrors += 1
	else
		// Do Current Clamp stuff
		// switch to IC
		PGC_SetAndActivateControl(device, DAP_GetClampModeControl(I_CLAMP_MODE, headstage), val=CHECKBOX_SELECTED)

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETBRIDGEBALENABLE_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting Bridge Balance Enable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE,  MCC_SETNEUTRALIZATIONCAP_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting Neutralization Cap to 0.0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETNEUTRALIZATIONENABL_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting Neutralization Enable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETSLOWCURRENTINJENABL_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting  SlowCurrentInjEnable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETSLOWCURRENTINJLEVEL_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting SlowCurrentInjLevel to 0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETSLOWCURRENTINJSETLT_FUNC, 1)
		if(!IsFinite(initResult))
			print "Error setting SlowCurrentInjSetlTime to 1 second"
			numErrors += 1
		endif

		// these commands work for both IC and VC...here's the IC part
		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETHOLDING_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting Holding Voltage to 0.0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETHOLDINGENABLE_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting Holding Enable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, I_CLAMP_MODE, MCC_SETOSCKILLERENABLE_FUNC, 1)
		if(!IsFinite(initResult))
			print "Error setting OscKillerEnable to on"
			numErrors += 1
		endif

		// switch to VC
		PGC_SetAndActivateControl(device, DAP_GetClampModeControl(V_CLAMP_MODE, headstage), val=CHECKBOX_SELECTED)

		// These commands work with both current clamp and voltage clamp...so now do the voltage clamp mode
		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETHOLDING_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting Holding Voltage to 0.0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETHOLDINGENABLE_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting Holding Enable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETOSCKILLERENABLE_FUNC, 1)
		if(!IsFinite(initResult))
			print "Error setting OscKillerEnable to on"
			numErrors += 1
		endif

		// Voltage Clamp Mode only settings
		initResult =  AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETRSCOMPCORRECTION_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting RsCompCorrection to 0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETRSCOMPENABLE_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting RsCompEnable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETRSCOMPPREDICTION_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting RsCompPrediction to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETSLOWCOMPTAUX20ENAB_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting SlowCompTauX20Enable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETRSCOMPBANDWIDTH_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting RsCompBandwidth to 0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETWHOLECELLCOMPCAP_FUNC, 0.0)
		if(!IsFinite(initResult))
			print "Error setting WholeCellCompCap to 0"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETWHOLECELLCOMPENABLE_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting  WholeCellCompEnable to off"
			numErrors += 1
		endif

		initResult = AI_SendToAmp(device, headstage, V_CLAMP_MODE, MCC_SETWHOLECELLCOMPRESIST_FUNC, 0)
		if(!IsFinite(initResult))
			print "Error setting WholeCellCompResist to 0"
			numErrors += 1
		endif
	endif

	if(oldTab != 0)
		PGC_SetAndActivateControl(device, "ADC", val=oldTab)
	endif

	return numErrors
End

/// @brief Run the baseline QC check
///
/// @sa PSQ_PipetteInBath
Function IVS_runBaselineCheckQC()
	string device, ctrl
	variable headstage

	device = IVS_DEFAULT_DEVICE
	headstage  = IVS_DEFAULT_HEADSTAGE

	DoWindow/F $device
	ctrl = GetPanelControl(headstage, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
	PGC_SetAndActivateControl(device, ctrl, str = "EXTPINBATH*")

	PGC_SetAndActivateControl(device, "DataAcquireButton")
End

/// @brief Run the initial access resistance smoke from the WSE
Function IVS_runInitAccessResisQC()
	string device, ctrl
	variable headstage

	device = IVS_DEFAULT_DEVICE
	headstage  = IVS_DEFAULT_HEADSTAGE

	ctrl = GetPanelControl(headstage, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
	PGC_SetAndActivateControl(device, ctrl, str = "EXTPBREAKN*")

	PGC_SetAndActivateControl(device, "DataAcquireButton")
End

/// @brief Run PSQ_SealEvaluation()
Function IVS_RunGigOhmSealQC()
	string device, ctrl
	variable headstage

	device = IVS_DEFAULT_DEVICE
	headstage  = IVS_DEFAULT_HEADSTAGE

	ctrl = GetPanelControl(headstage, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
	PGC_SetAndActivateControl(device, ctrl, str = "EXTPCllATT*")

	PGC_SetAndActivateControl(device, "DataAcquireButton")
End

/// @brief Loads a single stimulus for the user when using the ZMQ Proxy
Function IVS_Load_StimSet(stim_filename)

	string stim_filename

	print "Stimulus loading...." + stim_filename
	NWB_LoadAllStimSets(overwrite = 1, fileName = stim_filename)
End

Function IVS_ExportAllData(filePath)
	string filePath

	printf "Saving experiment data in NWB format to %s\r", filePath

	return NWB_ExportAllData(IVS_DEFAULT_NWBVERSION, overrideFilePath = filePath, overwrite = 1)
End

Function/S IVS_ReturnNWBFileLocation()
	SVAR path = $GetNWBFilePathExport()
	return path
End

Function IVS_SaveExperiment(filename)
	string filename

	variable err

	AssertOnAndClearRTError()
	try
		SaveExperiment/C/F={1,"",2}/P=home as filename + ".pxp"; AbortOnRTE
	catch
		err = ClearRTError()
		ASSERT(0, "Could not save experiment due to code: " + num2istr(err))
	endtry
End

/// @brief Run a designated stim wave
///
/// @param stimWaveName stimWaveName to be used
/// @param scaleFactor  scale factor to run the stim wave at
Function IVS_runStimWave(stimWaveName, scaleFactor)
	string stimWaveName
	variable scaleFactor

	variable headstage
	string device, ctrl

	device = IVS_DEFAULT_DEVICE
	headstage = IVS_DEFAULT_HEADSTAGE

	DoWindow/F $device

	ctrl = GetPanelControl(headstage, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE)
	PGC_SetAndActivateControl(device, ctrl, str = stimWaveName + "*")

	ctrl = GetPanelControl(headstage, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_SCALE)
	PGC_SetAndActivateControl(device, ctrl, val = scaleFactor)
	PGC_SetAndActivateControl(device, "DataAcquireButton")
End

Function IVS_ButtonProc_Setup(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			IVS_ConfigureMCC()
			break
	endswitch

	return 0
End

Function IVS_ButtonProc_BaselineQC(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			IVS_runBaselineCheckQC()
			break
	endswitch

	return 0
End

Function IVS_ButtonProc_AccessResist(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			IVS_runInitAccessResisQC()
			break
	endswitch

	return 0
End

Function IVS_ButtonProc_GOhmSeal(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			IVS_RunGigOhmSealQC()
			break
	endswitch

	return 0
End

Function IVS_CreatePanel()
	Execute "IVSCCControlPanel()"
End

Window IVSCCControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(392,734,683,925) as "IVSCC control panel"
	Button button_ivs_setup,pos={86.00,19.00},size={130.00,30.00},proc=IVS_ButtonProc_Setup,title="Setup DAEphys panel"
	Button button_runGigOhmSealQC,pos={48.00,103.00},size={190.00,30.00},proc=IVS_ButtonProc_GOhmSeal,title="Run GΩ seal check"
	Button button_runBaselineQC,pos={48.00,61.00},size={190.00,30.00},proc=IVS_ButtonProc_BaselineQC,title="Run baseline QC"
	Button button_runAccessResisQC,pos={48.00,145.00},size={190.00,30.00},proc=IVS_ButtonProc_AccessResist,title="Run access resistance QC check"
	SetWindow kwTopWin,userdata(Config_PanelType)="IVSCControlPanel"
EndMacro

/// @brief Return the Set QC passed/failed state for the given sweep
///
/// @return 1 if passed, 0 if not (or not yet) and
/// asserts out on all other errors.
Function IVS_GetSetQCForSweep(device, sweepNo)
	string device
	variable sweepNo

	string key
	variable headstage, anaFuncType

	WAVE numericalValues = GetLBNumericalValues(device)
	WAVE/T textualValues = GetLBTextualValues(device)

	WAVE/Z headstages = GetLastSetting(numericalValues, sweepNo, "Headstage Active", DATA_ACQUISITION_MODE)
	ASSERT(WaveExists(headstages), "The given sweep number does not exist.")

	WaveStats/Q/M=1 headstages
	ASSERT(V_sum == 1, "More than one headstage active")

	headstage = headstages[V_minloc]

	key = StringFromList(GENERIC_EVENT, EVENT_NAME_LIST_LBN)
	WAVE/Z/T anaFuncs = GetLastSetting(textualValues, sweepNo, key, DATA_ACQUISITION_MODE)

	ASSERT(WaveExists(anaFuncs), "The queried sweep did not use an analysis function.")

	WAVE anaFuncTypes = LBN_GetNumericWave()
	anaFuncTypes[] = MapAnaFuncToConstant(anaFuncs[p])

	anaFuncType = anaFuncTypes[headstage]
	ASSERT(anaFuncType != INVALID_ANALYSIS_FUNCTION, "The used analysis function is not a patch-seq one.")

	key = CreateAnaFuncLBNKey(anaFuncType, PSQ_FMT_LBN_SET_PASS, query = 1)
	return GetLastSettingIndepSCI(numericalValues, sweepNo, key, headstage, UNKNOWN_MODE) == 1
End

Function IVS_EnableStoringEveryTP(string device)
	PGC_SetAndActivateControl(device, "check_Settings_TP_SaveTP", val = CHECKBOX_SELECTED)
End

Function IVS_DisableStoringEveryTP(string device)
	PGC_SetAndActivateControl(device, "check_Settings_TP_SaveTP", val = CHECKBOX_UNSELECTED)
End
