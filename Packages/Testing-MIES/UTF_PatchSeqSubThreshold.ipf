﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=PatchSeqTestSubThreshold

static Constant HEADSTAGE = 0

/// @brief Acquire data with the given DAQSettings
static Function AcquireData(s)
	STRUCT DAQSettings& s

	Initialize_IGNORE()

	string unlockedPanelTitle = DAP_CreateDAEphysPanel()

	PGC_SetAndActivateControl(unlockedPanelTitle, "popup_MoreSettings_DeviceType", val=5)
	PGC_SetAndActivateControl(unlockedPanelTitle, "button_SettingsPlus_LockDevice")

	REQUIRE(WindowExists(DEVICE))

	PGC_SetAndActivateControl(DEVICE, "ADC", val=0)
	DoUpdate/W=$DEVICE

	PGC_SetAndActivateControl(DEVICE, "check_DataAcq_AutoBias", val = 1)
	PGC_SetAndActivateControl(DEVICE, "setvar_DataAcq_AutoBiasV", val = 70)
	PGC_SetAndActivateControl(DEVICE, GetPanelControl(0, CHANNEL_TYPE_HEADSTAGE, CHANNEL_CONTROL_CHECK), val=1)
	PGC_SetAndActivateControl(DEVICE, GetPanelControl(0, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_WAVE), val = GetStimSet("PatchSeqSubThres_DA_0") + 1)

	WAVE ampMCC = GetAmplifierMultiClamps()
	WAVE ampTel = GetAmplifierTelegraphServers()

	CHECK_EQUAL_VAR(DimSize(ampMCC, ROWS), 2)
	CHECK_EQUAL_VAR(DimSize(ampTel, ROWS), 2)

	// HS 0 with Amp
	PGC_SetAndActivateControl(DEVICE, "Popup_Settings_HeadStage", val = HEADSTAGE)
	PGC_SetAndActivateControl(DEVICE, "popup_Settings_Amplifier", val = 1)

	PGC_SetAndActivateControl(DEVICE, DAP_GetClampModeControl(I_CLAMP_MODE, HEADSTAGE), val=1)
	DoUpdate/W=$DEVICE

	PGC_SetAndActivateControl(DEVICE, "button_Hardware_AutoGainAndUnit")

	PGC_SetAndActivateControl(DEVICE, "check_Settings_MD", val = s.MD)
	PGC_SetAndActivateControl(DEVICE, "Check_DataAcq1_RepeatAcq", val = s.RA)
	PGC_SetAndActivateControl(DEVICE, "Check_DataAcq_Indexing", val = s.IDX)
	PGC_SetAndActivateControl(DEVICE, "Check_DataAcq1_IndexingLocked", val = s.LIDX)
	PGC_SetAndActivateControl(DEVICE, "Check_Settings_BackgrndDataAcq", val = s.BKG_DAQ)
	PGC_SetAndActivateControl(DEVICE, "SetVar_DataAcq_SetRepeats", val = s.RES)
	PGC_SetAndActivateControl(DEVICE, "Check_Settings_SkipAnalysFuncs", val = 0)

	DoUpdate/W=$DEVICE

	CtrlNamedBackGround DAQWatchdog, start, period=120, proc=WaitUntilDAQDone_IGNORE
	PGC_SetAndActivateControl(DEVICE, "DataAcquireButton")
End

Function/WAVE GetSweepResults_IGNORE(sweepNo)
	variable sweepNo

	WAVE numericalValues = GetLBNumericalValues(DEVICE)
	WAVE/Z sweeps = AFH_GetSweepsFromSameRACycle(numericalValues, sweepNo)
	CHECK_WAVE(sweeps, NUMERIC_WAVE)

	Make/FREE/N=(DimSize(sweeps, ROWS)) sweepPassed = GetLastSettingIndep(numericalValues, sweeps[p], LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SWEEP_PASS, UNKNOWN_MODE)

	return sweepPassed
End

Function PS_ST_Run1()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// all tests fail
	wv = 0
End

Function PS_ST_Test1()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 7)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 6)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 0)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {0, 0, 0, 0, 0, 0, 0})
End

Function PS_ST_Run2()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// only pre pulse chunk pass, others fail
	wv[]    = 0
	wv[0][] = 1
End

Function PS_ST_Test2()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 7)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 6)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 0)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {0, 0, 0, 0, 0, 0, 0})
End

Function PS_ST_Run3()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk pass
	// first post pulse chunk pass
	wv[]      = 0
	wv[0,1][] = 1
End

Function PS_ST_Test3()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 3)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 2)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 1)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {1, 1, 1})
End

Function PS_ST_Run4()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk pass
	// last post pulse chunk pass
	wv[] = 0
	wv[0][] = 1
	wv[DimSize(wv, ROWS) - 1][] = 1
End

Function PS_ST_Test4()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 3)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 2)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 1)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {1, 1, 1})
End

Function PS_ST_Run5()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk fails
	// all post pulse chunk pass
	wv[]    = 1
	wv[0][] = 0
End

Function PS_ST_Test5()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 7)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 6)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 0)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {0, 0, 0, 0, 0, 0, 0})
End

Function PS_ST_Run6()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk pass
	// second post pulse chunk pass
	wv[]    = 0
	wv[0][] = 1
	wv[2][] = 1
End

Function PS_ST_Test6()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 3)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 2)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 1)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {1, 1, 1})
End

Function PS_ST_Run7()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk pass
	// first post pulse chunk pass
	// of sweeps 2-4
	wv[]          = 0
	wv[0, 1][2,4] = 1
End

Function PS_ST_Test7()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 5)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 4)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 1)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {0, 0, 1, 1, 1})
End

Function PS_ST_Run8()

	STRUCT DAQSettings s
	InitDAQSettingsFromString(s, "DAQ_MD1_RA1_IDX0_LIDX0_BKG_1")
	AcquireData(s)

	WAVE wv = CreateOverrideResults(DEVICE, HEADSTAGE, PATCHSEQ_SUB_THRESHOLD)
	// pre pulse chunk pass
	// first post pulse chunk pass
	// of sweep 0, 3, 7
	wv[]        = 0
	wv[0, 1][0] = 1
	wv[0, 1][3] = 1
	wv[0, 1][7] = 1
End

Function PS_ST_Test8()

	variable sweepNo, setPassed

	CHECK_EQUAL_VAR(GetSetVariable(DEVICE, "SetVar_Sweep"), 8)

	sweepNo = AFH_GetLastSweepAcquired(DEVICE)
	CHECK_EQUAL_VAR(sweepNo, 7)

	WAVE numericalValues = GetLBNumericalValues(DEVICE)

	setPassed = GetLastSettingIndep(numericalValues, sweepNo, LABNOTEBOOK_USER_PREFIX + PATCHSEQ_ST_LBN_SET_PASS, UNKNOWN_MODE)
	CHECK_EQUAL_VAR(setPassed, 1)

	WAVE/Z sweepPassed = GetSweepResults_IGNORE(sweepNo)
	CHECK_EQUAL_WAVES(sweepPassed, {1, 0, 0, 1, 0, 0, 0, 1})
End