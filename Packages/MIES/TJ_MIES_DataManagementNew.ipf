#pragma rtGlobals=3		// Use modern global access method and strict wave access.

static Constant FLOAT_32BIT = 0x02
static Constant FLOAT_64BIT = 0x04

Function DM_SaveAndScaleITCData(panelTitle)
	string panelTitle

	WAVE ITCDataWave = GetITCDataWave(panelTitle)
	Redimension/Y=(GetRawDataFPType(panelTitle)) ITCDataWave
	DM_ADScaling(ITCDataWave, panelTitle)

	// the checkbox text reads "Do not save data" so we have to check for true
	if(GetCheckBoxState(panelTitle, "Check_Settings_SaveData"))
		return NaN
	endif

	WAVE ITCDataWave = GetITCDataWave(panelTitle)
	WAVE ITCChanConfigWave = GetITCChanConfigWave(panelTitle)
	variable sweepNo = GetSetVariable(panelTitle, "SetVar_Sweep")

	string savedDataWaveName = GetDeviceDataPathAsString(panelTitle)  + ":Sweep_" +  num2str(sweepNo)
	string savedSetUpWaveName = GetDeviceDataPathAsString(panelTitle) + ":Config_Sweep_" + num2str(sweepNo)

	variable rowsToCopy = DC_GetStopCollectionPoint(panelTitle, DATA_ACQUISITION_MODE) - 1

	Duplicate/O/R=[0, rowsToCopy][] ITCDataWave $savedDataWaveName/Wave=dataWave
	Duplicate/O ITCChanConfigWave $savedSetUpWaveName
	note dataWave, Time()
	note dataWave, GetExperimentName()  + " - Igor Pro " + num2str(igorVersion())
	AppendMiesVersionToWaveNote(dataWave)

	if (GetCheckboxState(panelTitle, "check_Settings_SaveAmpSettings"))
		AI_FillAndSendAmpliferSettings(panelTitle, sweepNo)
		// function for debugging
		// AI_createDummySettingsWave(panelTitle, SweepNo)
	endif
	
	// Adding in the post sweep analysis function here
	AM_analysisMasterPostSweep(panelTitle, sweepNo)

	if(GetCheckboxState(panelTitle, "Check_Settings_Append")) // if option is checked, wave note containing single readings from (async) ADs is made
		ITC_ADDataBasedWaveNotes(dataWave, panelTitle)
	endif

	SetVariable SetVar_Sweep, Value = _NUM:(sweepNo + 1), limits={0, sweepNo + 1, 1}, win = $panelTitle

	DM_DAScaling(dataWave, panelTitle)

	//Add wave notes for the stim wave name and scale factor
	ED_createWaveNoteTags(panelTitle, sweepNo)

	//Add wave notes for the factors on the Asyn tab
	ED_createAsyncWaveNoteTags(panelTitle, sweepNo)

	DM_AfterSweepDataSaveHook(panelTitle)
End

/// @brief General hook function which gets always executed after sweep data saving
Function DM_AfterSweepDataSaveHook(panelTitle)
	string panelTitle

	string panelList, dataPath, panel, panelType
	variable numPanels, i

	panelList = WinList("DB_*", ";", "WIN:64")

	numPanels = ItemsInList(panelList)
	for(i = 0; i < numPanels; i += 1)
		panel = StringFromList(i, panelList)

		panelType = GetUserData(panel, "", MIES_PANEL_TYPE_USER_DATA)
		if(!cmpstr(panelType, MIES_DATABROWSER_PANEL))
			dataPath   = GetUserData(panel, "", "DataFolderPath")
			if(!cmpstr(dataPath, GetDevicePathAsString(panelTitle)))
				DB_UpdateToLastSweep(panel)
			endif
		endif
	endfor
End

Function DM_CreateScaleTPHoldingWave(panelTitle)
	string panelTitle

	dfref testPulseDFR = GetDeviceTestPulse(panelTitle)

	NVAR duration = $GetTestpulseDuration(panelTitle)
	WAVE ITCDataWave = GetITCDataWave(panelTitle)

	ASSERT(Duration > 0, "duration is not strictly positive")
	ASSERT(DimSize(ITCDataWave, COLS) > 0, "Expected at least one headStage")

	Duplicate/O/R=[0, (duration * 2)][] ITCDataWave, testPulseDFR:TestPulseITC/Wave=TestPulseITC
	Redimension/Y=(GetRawDataFPType(panelTitle)) TestPulseITC
	DM_ADScaling(TestPulseITC, panelTitle)
End

Function DM_CreateScaleTPHoldWaveChunk(panelTitle,startPoint, NoOfPointsInTP)
	string panelTitle
	variable startPoint, NoOfPointsInTP

	variable RowsToCopy = NoOfPointsInTP
	WAVE ITCDataWave = GetITCDataWave(panelTitle)
	WAVE TestPulseITC = GetTestPulseITCWave(panelTitle)

	ITCDataWave[0][0] += 0
	startPoint += RowsToCopy / 4
	Duplicate/O/R=[startPoint,(startPoint + RowsToCopy)][] ITCDataWave, TestPulseITC
	Redimension/Y=(GetRawDataFPType(panelTitle)) TestPulseITC
	SetScale/P x 0,deltax(TestPulseITC),"ms", TestPulseITC
	DM_ADScaling(TestPulseITC, panelTitle)
End

static Function DM_ADScaling(WaveToScale, panelTitle)
	wave WaveToScale
	string panelTitle

	WAVE ITCChanConfigWave = GetITCChanConfigWave(panelTitle)
	string ADChannelList   = GetADCListFromConfig(ITCChanConfigWave)
	variable StartOfADColumns = DC_NoOfChannelsSelected("da", panelTitle)
	variable gain, i, numEntries, adc
	Wave ChannelClampMode    = GetChannelClampMode(panelTitle)
	string ctrl

	numEntries = ItemsInList(ADChannelList)
	for(i = 0; i < numEntries; i += 1)
		adc = str2num(StringFromList(i, ADChannelList))

		ctrl = GetPanelControl(panelTitle, adc, CHANNEL_TYPE_ADC, CHANNEL_CONTROL_GAIN)
		gain = GetSetVariable(panelTitle, ctrl)

		if(ChannelClampMode[adc][1] == V_CLAMP_MODE || ChannelClampMode[adc][1] == I_CLAMP_MODE)
			// w' = w  / (g * s)
			gain *= 3200
			MultiThread WaveToScale[][(StartOfADColumns + i)] /= gain
		endif
	endfor
end

static Function DM_DAScaling(WaveToScale, panelTitle)
	wave WaveToScale
	string panelTitle

	string ctrl
	variable gain, i, dac, numEntries
	DFREF deviceDFR       = GetDevicePath(panelTitle)
	Wave ChannelClampMode = GetChannelClampMode(panelTitle)
	WAVE/SDFR=deviceDFR ITCDataWave, ITCChanConfigWave
	string DAChannelList  = GetDACListFromConfig(ITCChanConfigWave)

	numEntries = ItemsInList(DAChannelList)
	for(i = 0; i < numEntries ; i += 1)
		dac = str2num(StringFromList(i, DAChannelList))
		ctrl = GetPanelControl(panelTitle, dac, CHANNEL_TYPE_DAC, CHANNEL_CONTROL_GAIN)
		gain = GetSetVariable(panelTitle, ctrl)

		if(ChannelClampMode[dac][0] == V_CLAMP_MODE || ChannelClampMode[dac][0] == I_CLAMP_MODE)
			// w' = w * g / s
			gain /= 3200
			MultiThread WaveToScale[][i] *= gain
		endif
	endfor
end

Function DM_ReturnLastSweepAcquired(panelTitle)
	string panelTitle
	
	string list

	list = GetListOfWaves(GetDeviceDataPath(panelTitle), DATA_SWEEP_REGEXP, waveProperty="MINCOLS:2")
	return ItemsInList(list) - 1
End
//=============================================================================================================
Function DM_IsLastSwpGreatrThnNxtSwp(panelTitle)
	string panelTitle
	variable NextSweep
	controlinfo /w = $panelTitle SetVar_Sweep
	NextSweep = v_value
	
	if(NextSweep > DM_ReturnLastSweepAcquired(panelTitle))
		return 0
	else
		return 1
	endif
End
//=============================================================================================================
Function DM_DeleteDataWaves(panelTitle, SweepNo)
	string panelTitle
	variable SweepNo
	variable i = SweepNo

	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder GetDeviceDataPath(panelTitle)

	string ListOfDataWaves = wavelist("Sweep_*", ";", "MINCOLS:2")
	string WaveNameUnderConsideration
	do
		WaveNameUnderConsideration = stringfromlist(i, ListOfDataWaves, ";")
		if(itemsinlist(ListOfDataWaves) > 0)
			killwaves /z /f $WaveNameUnderConsideration
		endif
		i+=1
	while(i < itemsinlist(ListOfDataWaves))

	i = SweepNo
	ListOfDataWaves = wavelist("Config_Sweep_*", ";", "MINCOLS:2")
	do
		WaveNameUnderConsideration = stringfromlist(i, ListOfDataWaves, ";")
		if(itemsinlist(ListOfDataWaves) > 0)
			killwaves /z /f $WaveNameUnderConsideration
		endif
		i += 1
	while(i < itemsinlist(ListOfDataWaves))

	SetDataFolder saveDFR
End

/// @brief Return the floating point type for storing the raw data
///
/// The returned values are the same as for `WaveType`
static Function GetRawDataFPType(panelTitle)
	string panelTitle

	return GetCheckboxState(panelTitle, "Check_Settings_UseDoublePrec") ? FLOAT_64BIT : FLOAT_32BIT
End
