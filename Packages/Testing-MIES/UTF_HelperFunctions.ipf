#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=TestHelperFunctions

/// @file UTF_HelperFunctions.ipf
/// @brief This file holds helper functions for the tests

Function/S PrependExperimentFolder_IGNORE(filename)
	string filename

	PathInfo home
	CHECK(V_flag)

	return S_path + filename
End

/// Kill all left-over windows and remove the trash
Function AdditionalExperimentCleanup()

	string win, list, name
	variable i, numWindows, reopenDebugPanel

	list = WinList("*", ";", "WIN:67") // Panels, Graphs and tables

	numWindows = ItemsInList(list)
	for(i = 0; i < numWindows; i += 1)
		win = StringFromList(i, list)

		if(!cmpstr(win, "BW_MiesBackgroundWatchPanel"))
			continue
		endif

		if(!cmpstr(win, "DP_DebugPanel"))
			reopenDebugPanel = 1
		endif

		KillWindow $win
	endfor

	DFREF dfr = GetDebugPanelFolder()
	name = GetDataFolder(0, dfr)
	MoveDataFolder/O=1 dfr, root:

	CloseNWBFile()
	HDF5CloseFile/A/Z 0

	KillOrMoveToTrash(dfr=root:MIES)

	NewDataFolder root:MIES
	MoveDataFolder root:$name, root:MIES

	if(reopenDebugPanel)
		DP_OpenDebugPanel()
	endif

	// currently superfluous as we remove root:MIES above
	// but might be needed in the future and helps in understanding the code
	CA_FlushCache()

	NVAR interactiveMode = $GetInteractiveMode()
	interactiveMode = 0

	NVAR bugCount = $GetBugCount()
	KillVariables bugCount

	TUFXOP_AcquireLock/N=(TSDS_BUGCOUNT)
	TSDS_Write(TSDS_BUGCOUNT, var = 0)
	TUFXOP_ReleaseLock/N=(TSDS_BUGCOUNT)
End

static Function WaitForPubSubHeartbeat()
	variable i, foundHeart
	string msg, filter

	// wait until we get the first heartbeat
	for(i = 0; i < 200; i += 1)
		msg = zeromq_sub_recv(filter)
		if(!cmpstr(filter, ZEROMQ_HEARTBEAT))
			PASS()
			return NaN
		endif

		Sleep/S 0.1
	endfor

	FAIL()
End

Function PrepareForPublishTest()

	variable numTrials = StartZeroMQSockets(forceRestart = 1)
	REQUIRE_EQUAL_VAR(numTrials, 0)

	zeromq_sub_remove_filter("")

	zeromq_sub_add_filter("")
	zeromq_sub_connect("tcp://127.0.0.1:" + num2str(ZEROMQ_BIND_PUB_PORT))

	WaitForPubSubHeartbeat()
End

static Function CheckMessageFilters_IGNORE(string filter)
	WAVE/T/Z allFilters = FFI_GetAvailableMessageFilters()
	CHECK_WAVE(allFilters, TEXT_WAVE)

	FindValue/TXOP=4/TEXT=(filter) allFilters
	CHECK_GE_VAR(V_Value, 0)
End

Function/S FetchPublishedMessage(string expectedFilter)
	variable i
	string msg, filter

	for(i = 0; i < 100; i += 1)
		msg = zeromq_sub_recv(filter)

		if(!cmpstr(filter, expectedFilter))
			break
		endif

		Sleep/S 0.1
	endfor

	CHECK_EQUAL_STR(filter, expectedFilter)
	CheckMessageFilters_IGNORE(filter)

	return msg
End

Function AdjustAnalysisParamsForPSQ(string device, string stimset)

	variable samplingFrequency
	samplingFrequency = PSQ_GetDefaultSamplingFrequencyForSingleHeadstage(device)

	AFH_AddAnalysisParameter(stimset, "SamplingMultiplier", var = 4)
	AFH_AddAnalysisParameter(stimset, "SamplingFrequency", var = samplingFrequency)
End

Function DoInstrumentation()
	variable instru = str2numSafe(GetEnvironmentVariable("BAMBOO_INSTRUMENT_TESTS")) == 1           \
	                  || !cmpstr(GetEnvironmentVariable("bamboo_repository_git_branch"), "main")

	return instru
End

Function [string key, string keyTxt] PrepareLBN_IGNORE(string device)

	variable sweepNo

	key    = LABNOTEBOOK_USER_PREFIX + "some key"
	keyTxt = LABNOTEBOOK_USER_PREFIX + "other key"

	WAVE numericalValues = GetLBNumericalValues(device)
	WAVE textualValues   = GetLBTextualValues(device)

	// prepare the LBN
	Make/FREE/N=(1, 1, LABNOTEBOOK_LAYER_COUNT) values, valuesDAC, valuesADC
	Make/T/FREE/N=(1, 1, LABNOTEBOOK_LAYER_COUNT) valuesTxt
	Make/T/FREE/N=(3, 1, 1) keys

	sweepNo = 0

	// HS 0: DAC 2 and ADC 6
	// HS 1: DAC 3 and ADC 7
	valuesDAC[]  = NaN
	valuesDAC[0][0][0] = 2
	valuesDAC[0][0][1] = 3
	keys[0][0][0] = "DAC"
	keys[2][0][0] = "0.1"
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	valuesADC[]  = NaN
	valuesADC[0][0][0] = 6
	valuesADC[0][0][1] = 7
	keys[0][0][0] = "ADC"
	keys[2][0][0] = "0.1"
	ED_AddEntriesToLabnotebook(valuesADC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[]  = 0
	values[0][0][0] = 1
	values[0][0][1] = 1
	keys[0][0][0] = "Headstage Active"
	keys[1][0][0] = LABNOTEBOOK_BINARY_UNIT
	keys[2][0][0] = LABNOTEBOOK_NO_TOLERANCE
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	keys = ""

	// numerical entries

	// DAC 4: unassoc (old)
	values[] = NaN
	values[0][0][INDEP_HEADSTAGE] = 123
	keys[0][0][0] = CreateLBNUnassocKey(key, 4, NaN) // old format does not include the channelType
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// ADC 8: unassoc (old)
	values[] = NaN
	values[0][0][INDEP_HEADSTAGE] = 789
	keys[0][0][0] = CreateLBNUnassocKey(key, 8, NaN) // old format does not include the channelType
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// associated
	values[] = NaN
	values[0][0][0] = 131415
	values[0][0][1] = 161718
	keys[0][0][0] = key
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[] = NaN
	values[0][0][0] = I_CLAMP_MODE
	keys[0][0][0] = CLAMPMODE_ENTRY_KEY
	keys[2][0][0] = "-"
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// textual entries

	// DAC 4: unassoc (old)
	valuesTxt[] = ""
	valuesTxt[0][0][INDEP_HEADSTAGE] = "123"
	keys[0][0][0] = CreateLBNUnassocKey(keyTxt, 4, NaN) // old format does not include the channelType
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// ADC 8: unassoc (old)
	valuesTxt[] = ""
	valuesTxt[0][0][INDEP_HEADSTAGE] = "789"
	keys[0][0][0] = CreateLBNUnassocKey(keyTxt, 8, NaN) // old format does not include the channelType
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// associated
	valuesTxt[] = ""
	valuesTxt[0][0][0] = "131415"
	valuesTxt[0][0][1] = "161718"
	keys[0][0][0] = keyTxt
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	sweepNo = 1

	valuesDAC[]  = NaN
	valuesDAC[0][0][0] = 2
	valuesDAC[0][0][1] = 3
	keys[0][0][0] = "DAC"
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	valuesADC[]  = NaN
	valuesADC[0][0][0] = 6
	valuesADC[0][0][1] = 7
	keys[0][0][0] = "ADC"
	ED_AddEntriesToLabnotebook(valuesADC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[]  = 0
	values[0][0][0] = 1
	values[0][0][1] = 1
	keys[0][0][0] = "Headstage Active"
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// numerical entries

	// DAC 5: unassoc (new)
	values[] = NaN
	values[0][0][INDEP_HEADSTAGE] = 456
	keys[0][0][0] = CreateLBNUnassocKey(key, 5, XOP_CHANNEL_TYPE_DAC)
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// ADC 9: unassoc (new)
	values[] = NaN
	values[0][0][INDEP_HEADSTAGE] = 101112
	keys[0][0][0] = CreateLBNUnassocKey(key, 9, XOP_CHANNEL_TYPE_ADC)
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// associated
	values[] = NaN
	values[0][0][0] = 192021
	values[0][0][1] = 222324
	keys[0][0][0] = key
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[] = NaN
	values[0][0][0] = V_CLAMP_MODE
	keys[0][0][0] = CLAMPMODE_ENTRY_KEY
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// textual entries

	// DAC 5: unassoc (new)
	valuesTxt[] = ""
	valuesTxt[0][0][INDEP_HEADSTAGE] = "456"
	keys[0]= CreateLBNUnassocKey(keyTxt, 5, XOP_CHANNEL_TYPE_DAC)
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// ADC 9: unassoc (new)
	valuesTxT[] = ""
	valuesTxT[0][0][INDEP_HEADSTAGE] = "101112"
	keys[0][0][0] = CreateLBNUnassocKey(keyTxt, 9, XOP_CHANNEL_TYPE_ADC)
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// associated
	valuesTxT[] = ""
	valuesTxT[0][0][0] = "192021"
	valuesTxT[0][0][1] = "222324"
	keys[0][0][0] = keyTxt
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	sweepNo = 2

	valuesDAC[]  = NaN
	valuesDAC[0][0][0] = 2
	valuesDAC[0][0][1] = 3
	keys[0][0][0] = "DAC"
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	valuesADC[]  = NaN
	valuesADC[0][0][0] = 6
	valuesADC[0][0][1] = 7
	keys[0][0][0] = "ADC"
	ED_AddEntriesToLabnotebook(valuesADC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[]  = 0
	values[0][0][0] = 1
	values[0][0][1] = 1
	keys[0][0][0] = "Headstage Active"
	ED_AddEntriesToLabnotebook(valuesDAC, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	values[] = NaN
	values[0][0][0] = I_EQUAL_ZERO_MODE
	keys[0][0][0] = CLAMPMODE_ENTRY_KEY
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	// indep headstage
	values[] = NaN
	values[0][0][INDEP_HEADSTAGE] = 252627
	keys[0][0][0] = key
	ED_AddEntriesToLabnotebook(values, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	valuesTxt[] = ""
	valuesTxt[0][0][INDEP_HEADSTAGE] = "252627"
	keys[0][0][0] = keyTxt
	ED_AddEntriesToLabnotebook(valuesTxt, keys, sweepNo, device, DATA_ACQUISITION_MODE)

	return [key, keyTxt]
End

Function/WAVE FakeSweepDataGeneratorProto(WAVE sweep, variable numChannels)

	ASSERT(0, "Prototype Function FakeSweepDataGeneratorProto called.")
End

Function/WAVE FakeSweepDataGeneratorDefault(WAVE sweep, variable numChannels)

	Redimension/N=(10, numChannels) sweep
	sweep = p

	return sweep
End

Function CreateFakeSweepData(string device, [variable sweepNo, FUNCREF FakeSweepDataGeneratorProto sweepGen])

	string list, key, keyTxt
	variable numChannels

	sweepNo = ParamIsDefault(sweepNo) ? 0: sweepNo
	if(ParamIsDefault(sweepGen))
		FUNCREF FakeSweepDataGeneratorProto sweepGen = FakeSweepDataGeneratorDefault
	endif

	GetDAQDeviceID(device)

	[key, keyTxt] = PrepareLBN_IGNORE(device)
	numChannels = 4 // from LBN creation in PrepareLBN_IGNORE -> DA2, AD6, DA3, AD7

	WAVE sweepTemplate = GetDAQDataWave(device, DATA_ACQUISITION_MODE)
	WAVE sweep = sweepGen(sweepTemplate, numChannels)

	WAVE config = GetDAQConfigWave(device)
	Redimension/N=(4, -1) config
	// creates HS 0 with DAC 2 and ADC 6
	config[0][%ChannelType]   = XOP_CHANNEL_TYPE_DAC
	config[0][%ChannelNumber] = 2

	config[1][%ChannelType]   = XOP_CHANNEL_TYPE_ADC
	config[1][%ChannelNumber] = 6

	// creates HS 1 with DAC 3 and ADC 7
	config[2][%ChannelType]   = XOP_CHANNEL_TYPE_DAC
	config[2][%ChannelNumber] = 3

	config[3][%ChannelType]   = XOP_CHANNEL_TYPE_ADC
	config[3][%ChannelNumber] = 7

	DFREF dfr = GetDeviceDataPath(device)
	MoveWave sweep, dfr:$GetSweepWaveName(sweepNo)
	MoveWave config, dfr:$GetConfigWaveName(sweepNo)

	list = GetAllDevicesWithContent()
	list = RemoveEnding(list, ";")
	CHECK_EQUAL_VAR(ItemsInList(list), 1)
	CHECK_EQUAL_STR(list, device)
End

Function/S GetDataBrowserWithData()
	string win, device, result

	device = HW_ITC_BuildDeviceString(StringFromList(0, DEVICE_TYPES_ITC), StringFromList(0, DEVICE_NUMBERS))
	CreateFakeSweepData(device)
	win = DB_OpenDataBrowser()
	result = BSP_GetDevice(win)
	CHECK_EQUAL_STR(device, result)

	return win
End

Function/WAVE TrackAnalysisFunctionCalls([numHeadstages])
	variable numHeadstages

	variable i

	DFREF dfr = root:
	WAVE/Z/SDFR=dfr wv = anaFuncTracker

	if(WaveExists(wv))
		return wv
	else
		Make/N=(TOTAL_NUM_EVENTS, numHeadstages) dfr:anaFuncTracker/WAVE=wv
	endif

	for(i = 0; i < TOTAL_NUM_EVENTS; i += 1)
		SetDimLabel ROWS, i, $StringFromList(i, EVENT_NAME_LIST), wv
	endfor

	return wv
End

Function/WAVE TrackAnalysisFunctionOrder([numHeadstages])
	variable numHeadstages

	variable i

	DFREF dfr = root:
	WAVE/D/Z/SDFR=dfr wv = anaFuncOrder

	if(WaveExists(wv))
		return wv
	else
		Make/N=(TOTAL_NUM_EVENTS, numHeadstages)/D dfr:anaFuncOrder/WAVE=wv
	endif

	wv = NaN

	for(i = 0; i < TOTAL_NUM_EVENTS; i += 1)
		SetDimLabel ROWS, i, $StringFromList(i, EVENT_NAME_LIST), wv
	endfor

	return wv
End

Function/WAVE GetTrackActiveSetCount()

	DFREF dfr = root:
	WAVE/Z/SDFR=dfr wv = anaFuncActiveSetCount

	if(WaveExists(wv))
		return wv
	else
		Make/N=(100) dfr:anaFuncActiveSetCount/WAVE=wv
	endif

	wv = NaN

	return wv
End

/// @brief Track at which sweep count an analysis function was called.
Function/WAVE GetTrackSweepCounts()

	variable i

	DFREF dfr = root:
	WAVE/Z/SDFR=dfr wv = anaFuncSweepTracker

	if(WaveExists(wv))
		return wv
	else
		Make/N=(100, TOTAL_NUM_EVENTS, 2) dfr:anaFuncSweepTracker/WAVE=wv
	endif

	for(i = 0; i < TOTAL_NUM_EVENTS; i += 1)
		SetDimLabel COLS, i, $StringFromList(i, EVENT_NAME_LIST), wv
	endfor

	wv = NaN

	return wv
End

Function IsRunningInCI()
	// we always have expensive checks enabled in CI
	return str2numSafe(GetEnvironmentVariable("BAMBOO_EXPENSIVE_CHECKS")) == 1
End

Function RetrieveAllWindowsInCI()

	if(!IsRunningInCI())
		return NaN
	endif

	DoIgorMenu "Control" "Retrieve All Windows"
End

Function SetAsyncChannelProperties(string device, WAVE asyncChannels, variable minValue, variable maxValue)
	variable chan
	string ctrl, title, unit

	for(chan :  asyncChannels)
		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_CHECK)
		PGC_SetAndActivateControl(device, ctrl, val = CHECKBOX_SELECTED)

		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ALARM, CHANNEL_CONTROL_CHECK)
		PGC_SetAndActivateControl(device, ctrl, val = CHECKBOX_SELECTED)

		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_ALARM_MIN)
		PGC_SetAndActivateControl(device, ctrl, val = minValue)

		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_ALARM_MAX)
		PGC_SetAndActivateControl(device, ctrl, val = maxValue)

		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_TITLE)
		sprintf title, "title %d", chan
		PGC_SetAndActivateControl(device, ctrl, str = title)

		ctrl = GetPanelControl(chan, CHANNEL_TYPE_ASYNC, CHANNEL_CONTROL_UNIT)
		sprintf unit, "unit %d", chan
		PGC_SetAndActivateControl(device, ctrl, str = unit)
	endfor
End

Function/WAVE ExtractSweepsFromSFPairs(WAVE/T/Z wv)
	variable numEntries, i

	if(!WaveExists(wv))
		return $""
	endif

	ASSERT(IsTextWave(wv), "Expected text wave")

	// Pairs are "A;B;C,X;Y;Z,"
	// where A and X are the sweep numbers which we want
	numEntries = DimSize(wv, ROWS)
	for(i = 0; i < numEntries; i += 1)
		WAVE/T data = ListToTextWave(wv[i], ",")
		data[] = StringFromList(0, data)
		wv[i] = TextWaveToList(data, ";")
	endfor

	return wv
End

Function CheckForBugMessages()
	variable bugCount_ts

	NVAR bugCount = $GetBugCount()
	if(IsFinite(bugCount))
		CHECK_EQUAL_VAR(bugCount, 0)
	else
		CHECK_EQUAL_VAR(bugCount, NaN)
	endif

	TUFXOP_AcquireLock/N=(TSDS_BUGCOUNT)
	bugCount_ts = TSDS_ReadVar(TSDS_BUGCOUNT, defValue = 0)
	TUFXOP_ReleaseLock/N=(TSDS_BUGCOUNT)

	if(IsFinite(bugCount_ts))
		CHECK_EQUAL_VAR(bugCount_ts, 0)
	else
		CHECK_EQUAL_VAR(bugCount_ts, NaN)
	endif
End

Function DisableBugChecks()

	NVAR bugCount = $GetBugCount()
	bugCount = NaN

	TSDS_Write(TSDS_BUGCOUNT, var = NaN)
End
