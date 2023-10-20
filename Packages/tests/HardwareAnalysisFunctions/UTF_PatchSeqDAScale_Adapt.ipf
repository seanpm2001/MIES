#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=PatchSeqTestDAScaleAdapt

/// Test matrix
/// @rst
///
/// .. Column order: test overrides, analysis parameters
///
///============= ==================== ===================== ====================== ============================ ======================= ================================== ============ ==================== ================== ====================== ============================== ========== ============= ================= ===================== ============================== =========================== ===================
///  Test case    Baseline chunk0 QC   Enough supra sweeps   Passing supra sweeps   Valid initial f-I slope QC   Valid initial f-I fit   Initial f-I data is dense enough   Failed f-I   Valid f-I slope QC   Fit f-I slope QC   Enough f-I points QC   Measured all future DAScales   Async QC   Sampling QC   SlopePercentage   NumPointsForLineFit   NumInvalidSlopeSweepsAllowed   MaxFrequencyChangePercent   SamplingFrequency
///============= ==================== ===================== ====================== ============================ ======================= ================================== ============ ==================== ================== ====================== ============================== ========== ============= ================= ===================== ============================== =========================== ===================
///  PS_DS_AD1    -                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    -                  ✓                      ✓                              -          ✓             def               def                   def                            25                          def
///  PS_DS_AD2    ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD3    [-,✓]                ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD4    ✓                    ✓                     -                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD5    ✓                    -                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               3                     def                            25                          def
///  PS_DS_AD6    ✓                    ✓                     ✓                      -                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD7    ✓                    ✓                     ✓                      -                            ✓                       -                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD8    ✓                    ✓                     ✓                      ✓                            -                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD9    ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            [-,-]                ✓                  ✓                      ✓                              ✓          ✓             def               def                   2                              def                         def
///  PS_DS_AD10   ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      -                              ✓          ✓             def               def                   def                            def                         def
///  PS_DS_AD11   ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    [-,-,✓]            ✓                      ✓                              ✓          ✓             10                4                     1                              45                          def
///  PS_DS_AD12   [✓,-,✓,✓]            ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    [-,-,-,✓]          ✓                      [-,✓-,✓]                       ✓          ✓             def               def                   def                            25                          def
///  PS_DS_AD13   ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  ✓            ✓                    ✓                  ✓                      ✓                              ✓          ✓             def               def                   def                            def                         def
///  PS_DS_AD14   ✓                    ✓                     ✓                      ✓                            ✓                       ✓                                  -            ✓                    ✓                  ✓                      ✓                              ✓          -             def               def                   def                            def                         def
///============= ==================== ===================== ====================== ============================ ======================= ================================== ============ ==================== ================== ====================== ============================== ========== ============= ================= ===================== ============================== =========================== ===================
///
/// @endrst

static Function [STRUCT DAQSettings s] PS_GetDAQSettings(string device)

	InitDAQSettingsFromString(s, "MD1_RA1_I0_L0_BKG1_DB1"                                                         + \
	                             "__HS" + num2str(PSQ_TEST_HEADSTAGE) + "_DA0_AD0_CM:IC:_ST:PSQ_DaScale_Adapt_DA_0:")
	return [s]
End

static Function GlobalPreInit(string device)

	ST_SetStimsetParameter("PSQ_DaScale_Adapt_DA_0", "Analysis function (generic)", str = "PSQ_DAScale")
	ST_SetStimsetParameter("PSQ_DaScale_Adapt_DA_0", "Total number of steps", var = 3)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "OperationMode", str = PSQ_DS_ADAPT)

	AdjustAnalysisParamsForPSQ(device, "PSQ_DaScale_Adapt_DA_0")

	// Ensure that PRE_SET_EVENT already sees the test override as enabled
	Make/O/N=(0) root:overrideResults/WAVE=overrideResults
	Note/K overrideResults
End

static Function GlobalPreAcq(string device)

	PGC_SetAndActivateControl(device, "check_DataAcq_AutoBias", val = 1)
	PGC_SetAndActivateControl(device, "setvar_DataAcq_AutoBiasV", val = 70)

	PGC_SetAndActivateControl(device, "SetVar_DataAcq_TPBaselinePerc", val = 25)
End

static Function/WAVE GetResultsSingleEntry_IGNORE(string name)
	WAVE/T textualResultsValues = GetTextualResultsValues()

	WAVE/Z indizesName = GetNonEmptyLBNRows(textualResultsValues, name)
	WAVE/Z indizesType = GetNonEmptyLBNRows(textualResultsValues, "EntrySourceType")

	if(!WaveExists(indizesName) || !WaveExists(indizesType))
		return $""
	endif

	indizesType[] = (str2numSafe(textualResultsValues[indizesType[p]][%$"EntrySourceType"][INDEP_HEADSTAGE]) == SWEEP_FORMULA_RESULT) ? indizesType[p] : NaN

	WAVE/Z indizesTypeClean = ZapNaNs(indizesType)

	if(!WaveExists(indizesTypeClean))
		return $""
	endif

	WAVE/Z indizes = GetSetIntersection(indizesName, indizesTypeClean)

	if(!WaveExists(indizes))
		return $""
	endif

	Make/FREE/T/N=(DimSize(indizes, ROWS)) entries = textualResultsValues[indizes[p]][%$name][INDEP_HEADSTAGE]

	return entries
End

static Function/WAVE GetLBNSingleEntry_IGNORE(device, sweepNo, name)
	string   device
	variable sweepNo
	string   name

	variable val, type
	string key, str

	CHECK(IsValidSweepNumber(sweepNo))
	CHECK_LE_VAR(sweepNo, AFH_GetLastSweepAcquired(device))

	WAVE numericalValues = GetLBNumericalValues(device)
	WAVE textualValues   = GetLBTextualValues(device)

	type = PSQ_DA_SCALE

	strswitch(name)
		case PSQ_FMT_LBN_SWEEP_PASS:
		case PSQ_FMT_LBN_SAMPLING_PASS:
		case PSQ_FMT_LBN_ASYNC_PASS:
		case PSQ_FMT_LBN_DA_AT_FUTURE_DASCALES_PASS:
		case PSQ_FMT_LBN_DA_fI_SLOPE_REACHED_PASS:
		case PSQ_FMT_LBN_DA_AT_ENOUGH_FI_POINTS_PASS:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			return GetLastSettingIndepEachSCI(numericalValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
		case PSQ_FMT_LBN_DA_AT_FREQ:
		case PSQ_FMT_LBN_DA_AT_VALID_SLOPE_PASS:
		case PSQ_FMT_LBN_DA_AT_INIT_VALID_SLOPE_PASS:
		case PSQ_FMT_LBN_DA_AT_MAX_SLOPE:
		case PSQ_FMT_LBN_DA_AT_FI_OFFSET:
		case PSQ_FMT_LBN_DA_FI_SLOPE:
		case PSQ_FMT_LBN_BL_QC_PASS:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			return GetLastSettingEachSCI(numericalValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
		case PSQ_FMT_LBN_SET_PASS:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			val = GetLastSettingIndepSCI(numericalValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
			Make/D/FREE wv = {val}
			return wv
		case PSQ_FMT_LBN_RMS_SHORT_PASS:
		case PSQ_FMT_LBN_RMS_LONG_PASS:
			key = CreateAnaFuncLBNKey(type, name, chunk = 0, query = 1)
			return GetLastSettingEachSCI(numericalValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
		case PSQ_FMT_LBN_DA_AT_FUTURE_DASCALES:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			return GetLastSettingTextEachSCI(numericalValues, textualValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
		case PSQ_FMT_LBN_DA_AT_FI_SLOPES:
		case PSQ_FMT_LBN_DA_AT_FI_OFFSETS:
		case PSQ_FMT_LBN_DA_AT_FREQ_SUPRA:
		case PSQ_FMT_LBN_DA_AT_DASCALE_SUPRA:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			WAVE/T settings = GetLastSettingTextSCI(numericalValues, textualValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
			return ListToNumericWave(settings[PSQ_TEST_HEADSTAGE], ";")
		case STIMSET_SCALE_FACTOR_KEY:
			return GetLastSettingEachSCI(numericalValues, sweepNo, name, PSQ_TEST_HEADSTAGE, DATA_ACQUISITION_MODE)
		case PSQ_FMT_LBN_DA_OPMODE:
			key = CreateAnaFuncLBNKey(type, name, query = 1)
			str = GetLastSettingTextIndepSCI(numericalValues, textualValues, sweepNo, key, PSQ_TEST_HEADSTAGE, UNKNOWN_MODE)
			Make/T/FREE wvTxt = {str}
			return wvTxt
		default:
			FAIL()
	endswitch
End

static Function/WAVE GetWave_IGNORE()

	string list = "sweepPass;setPass;rmsShortPass;rmsLongPass;baselinePass;"  + \
	              "samplingPass;asyncPass;"                                   + \
	              "futureDAScalesPass;fiSlopeReachedPass;enoughFIPointsPass;" + \
	              "validSlopePass;initialValidSlopePass;"                     + \
	              "opMode;apFreq;maxSlope;fiSlope;fiOffset;futureDAScales;"   + \
	              "fiSlopesFromSupra;fiOffsetsFromSupra;daScale;"             + \
	              "apFreqFromSupra;daScaleFromSupra;"

	Make/FREE/WAVE/N=(ItemsInList(list)) wv
	SetDimensionLabels(wv, list, ROWS)

	return wv
End

static Function/WAVE GetEntries_IGNORE(string device, variable sweepNo)

	WAVE numericalValues = GetLBNumericalValues(device)

	WAVE/WAVE wv = GetWave_IGNORE()

	wv[%sweepPass]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_SWEEP_PASS)
	wv[%setPass]      = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_SET_PASS)
	wv[%samplingPass] = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_SAMPLING_PASS)
	wv[%asyncPass]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_ASYNC_PASS)

	wv[%rmsShortPass] = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_RMS_SHORT_PASS)
	wv[%rmsLongPass]  = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_RMS_LONG_PASS)
	wv[%baselinePass] = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_BL_QC_PASS)

	wv[%opMode]             = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_OPMODE)
	wv[%apFreq]             = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FREQ)
	wv[%maxSlope]           = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_MAX_SLOPE)
	wv[%fiSlope]            = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_fI_SLOPE)
	wv[%fiOffset]           = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FI_OFFSET)
	wv[%daScale]            = GetLBNSingleEntry_IGNORE(device, sweepNo, STIMSET_SCALE_FACTOR_KEY)
	wv[%futureDAScales]     = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FUTURE_DASCALES)
	wv[%fiSlopesFromSupra]  = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FI_SLOPES)
	wv[%fiOffsetsFromSupra] = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FI_OFFSETS)
	wv[%dascale]            = GetLBNSingleEntry_IGNORE(device, sweepNo, STIMSET_SCALE_FACTOR_KEY)
	wv[%apFreqFromSupra]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FREQ_SUPRA)
	wv[%dascaleFromSupra]   = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_DASCALE_SUPRA)

	wv[%futureDAScalesPass]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_FUTURE_DASCALES_PASS)
	wv[%fiSlopeReachedPass]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_fI_SLOPE_REACHED_PASS)
	wv[%enoughFIPointsPass]    = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_ENOUGH_FI_POINTS_PASS)
	wv[%validSlopePass]        = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_VALID_SLOPE_PASS)
	wv[%initialValidSlopePass] = GetLBNSingleEntry_IGNORE(device, sweepNo, PSQ_FMT_LBN_DA_AT_INIT_VALID_SLOPE_PASS)

	Make/FREE/N=(DimSize(wv, ROWS)) junk
	junk[] = WaveExists(wv[p]) ? ChangeFreeWaveName(wv[p], GetDimLabel(wv, ROWS, p)) : NaN

	return wv
End

static Function [WAVE apFreqRef, WAVE apfreqFromSupra, WAVE DAScalesFromSupra] ExtractRefValuesFromOverride(variable sweepNo)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)

	Duplicate/FREE/RMD=[0][0, sweepNo][FindDimLabel(overrideResults, LAYERS, "APFrequency")] overrideResults, apFreqRef
	Redimension/N=(DimSize(apFreqRef, COLS)) apFreqRef

	WAVE/Z apfreqFromSupra   = JWN_GetNumericWaveFromWaveNote(overrideResults, "/APFrequenciesSupra")
	WAVE/Z DAScalesFromSupra = JWN_GetNumericWaveFromWaveNote(overrideResults, "/DAScalesSupra")

	return [apFreqRef, apfreqFromSupra, DAScalesFromSupra]
End

static Function PrintSomeValues(WAVE/WAVE entries)

	WAVE wv = entries[%maxSlope]
	print/D wv

	WAVE wv = entries[%fiSlope]
	print/D wv

	WAVE wv = entries[%fiOffset]
	print/D wv

	WAVE wv = entries[%futureDAScales]
	print/D wv

	WAVE wv = entries[%fiSlopesFromSupra]
	print/D wv

	WAVE wv = entries[%fiOffsetsFromSupra]
	print/D wv

	WAVE wv = entries[%dascale]
	print/D wv
End

static Function PS_DS_AD1_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD1([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all tests fail
	wv[][][%APFrequency] = 20 + 5 * (1 + q)^2
	wv[][][%AsyncQC]     = 0
	wv[][][%BaselineQC]  = 0
End

static Function PS_DS_AD1_REENTRY([string str])
	variable sweepNo

	sweepNo = 2

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0, 0, 0}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_WAVE(entries[%rmsLongPass], NULL_WAVE)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, NaN, NaN}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {2.999999970665357e-10, NaN, NaN}
	Make/FREE/T futureDAScalesRef = {"5.22666666666667;", \
	                                 "5.22666666666667;", \
	                                 "5.22666666666667;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {5.226666666666667, 5.226666666666667, 5.226666666666667}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_WAVE(entries[%fiSlope], NULL_WAVE)
	CHECK_WAVE(entries[%fiOffset], NULL_WAVE)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD2_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD2([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all tests pass
	wv[][][%APFrequency] = 16.1 - 5 * q
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD2_REENTRY([string str])
	variable sweepNo

	sweepNo = 0

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {3e-10}
	Make/FREE/D fiSlopeRef = {8.15217391304348e-12}
	Make/FREE/D fiOffsetRef = {15.67391304347826}
	Make/FREE/T futureDAScalesRef = {"5.22666666666667;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {5.226666666666667}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD3_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD3([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// 0: BL fails
	// 1: sweep QC passes and fiSlope reached
	wv[][0][%APFrequency]  = 16.1
	wv[][1,][%APFrequency] = 16.1 - 5 * (q - 1)
	wv[][][%AsyncQC]       = 1
	wv[][1][%BaselineQC]   = 1
End

static Function PS_DS_AD3_REENTRY([string str])
	variable sweepNo

	sweepNo = 1

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {NaN, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1, 1}, mode = WAVE_DATA)
	// first sweep fails, so we redo the fit with only the supra data and that
	// does not result in fit slope reached QC
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {3e-10, 3e-10}
	Make/FREE/D fiSlopeRef = {NaN, 8.152173913043478e-12}
	Make/FREE/D fiOffsetRef = {NaN, 15.67391304347826}
	Make/FREE/T futureDAScalesRef = {"5.22666666666667;", "5.22666666666667;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {5.226666666666667, 5.226666666666667}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD4_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	Make/O/N=0 root:overrideResults

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD4([string str])

	variable ref, sweepNo
	string historyText

	ref = CaptureHistoryStart()

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	historyText = CaptureHistory(ref, 1)
	CHECK_GE_VAR(strsearch(historyText, "Could not find a passing set QC from previous DAScale runs in \"Supra\" mode.", 1), 0)

	sweepNo = AFH_GetLastSweepAcquired(str)
	CHECK_EQUAL_VAR(sweepNo, NaN)
End

static Function PS_DS_AD5_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "NumPointsForLineFit", var = 3)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5})

	Make/FREE/D daScalesFromSupra = {1, 2}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD5([string str])

	variable ref, sweepNo
	string historyText

	ref = CaptureHistoryStart()

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	historyText = CaptureHistory(ref, 1)
	CHECK_GE_VAR(strsearch(historyText, "The f-I fit of the supra data failed due to: \"Not enough points for fit\"", 1), 0)

	sweepNo = AFH_GetLastSweepAcquired(str)
	CHECK_EQUAL_VAR(sweepNo, NaN)
End

static Function PS_DS_AD6_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	// invalid initial valid fit QC
	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 8}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD6([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all tests pass
	wv[][][%APFrequency] = 7 - 5 * q
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD6_REENTRY([string str])
	variable sweepNo

	sweepNo = 0

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {0}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {2e-10}
	Make/FREE/D fiSlopeRef = {3.333333333333333e-11}
	Make/FREE/D fiOffsetRef = {6.666666666666667}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, -5e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 28}
	Make/FREE/D DAScalesRef = {1}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_WAVE(entries[%futureDAScales], NULL_WAVE)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD7_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 50)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	// invalid initial valid fit QC but not dense enough
	Make/FREE/D apFrequenciesFromSupra = {5, 8, 13, 10}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD7([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all tests pass and 6.5 is somewhere between 5 and 8
	wv[][][%APFrequency] = 6.5 + 10 * q
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD7_REENTRY([string str])
	variable sweepNo

	sweepNo = 0

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {0}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {4.999999858590343e-10}
	Make/FREE/D fiSlopeRef = {1.4e-10}
	Make/FREE/D fiOffsetRef = {4.4}
	Make/FREE/T futureDAScalesRef = {"1.5;"}

	Make/FREE/D fiSlopesFromSupraRef = {3e-10, 5e-10, -3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {2, -2, 22}
	Make/FREE/D DAScalesRef = {1.5}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD8_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5})

	Make/FREE/D daScalesFromSupra = {1, 1}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD8([string str])

	variable ref, sweepNo
	string historyText

	ref = CaptureHistoryStart()

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	historyText = CaptureHistory(ref, 1)
	CHECK_GE_VAR(strsearch(historyText, "The f-I fit of the supra data failed due to: \"All fit results are NaN\"", 1), 0)

	sweepNo = AFH_GetLastSweepAcquired(str)
	CHECK_EQUAL_VAR(sweepNo, NaN)
End

static Function PS_DS_AD9_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "NumInvalidSlopeSweepsAllowed", var = 2)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	// invalid initial valid fit QC but not dense enough
	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 15}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD9([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all post sweep fits have an invalid fit QC
	wv[][][%APFrequency] = 6
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD9_REENTRY([string str])
	variable sweepNo

	sweepNo = 1

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0, 0}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {2e-10, 2e-10}
	Make/FREE/D fiSlopeRef = {-6.666666666666667e-10, -6.666666666666667e-10}
	Make/FREE/D fiOffsetRef = {41.66666666666667, 41.66666666666667}
	Make/FREE/T futureDAScalesRef = {"5.35;3.175;", "5.35;3.175;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 2e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 7}
	Make/FREE/D DAScalesRef = {5.35, 5.35}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD10_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD10([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// not dense enough and we are running out of sweeps
	wv[][][%APFrequency] = 17 + 10 * q
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD10_REENTRY([string str])
	variable sweepNo

	sweepNo = 2

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0, 0, 0}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {0, 0, 0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {3e-10, 3e-10, 3e-10}
	Make/FREE/D fiSlopeRef = {-2e-10, -2.2e-09, -4.2e-09}
	Make/FREE/D fiOffsetRef = {24, 104, 184}
	Make/FREE/T futureDAScalesRef = {"3.5;4.96;", "3.5;4.96;3.75;", "3.5;4.96;3.75;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {3.5, 3.5, 3.5}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD11_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	ST_SetStimsetParameter("PSQ_DaScale_Adapt_DA_0", "Total number of steps", var = 4)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "NumInvalidSlopeSweepsAllowed", var = 1)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 45)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "NumPointsForLineFit", var = 4)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "SlopePercentage", var = 60)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD11([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// first two have failing fit slope QC, last one passes
	wv[][0][%APFrequency] = 20
	wv[][1][%APFrequency] = 25
	wv[][2][%APFrequency] = 25.1

	wv[][][%AsyncQC]    = 1
	wv[][][%BaselineQC] = 1
End

static Function PS_DS_AD11_REENTRY([string str])
	variable sweepNo

	sweepNo = 2

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {1, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {0, 0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {2e-10, 2e-10, 2e-10}
	Make/FREE/D fiSlopeRef = {1.538081020918171e-10, 1.129800583785857e-10, 4.846702671982674e-11}
	Make/FREE/D fiOffsetRef = {8.582356940218931, 10.67480711493808, 15.84235744837213}
	Make/FREE/T futureDAScalesRef = {"7.69;13.0146869947276;", "7.69;13.0146869947276;22.1943529193774;", "7.69;13.0146869947276;22.1943529193774;"}

	Make/FREE/D fiSlopesFromSupraRef = {2e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {7.5}
	Make/FREE/D DAScalesRef = {7.69, 13.0146869947276, 22.19435291937739}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD12_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	ST_SetStimsetParameter("PSQ_DaScale_Adapt_DA_0", "Total number of steps", var = 4)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD12([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	wv[][0][%APFrequency] = 22
	wv[][1][%APFrequency] = 18   // future DAScale
	wv[][2][%APFrequency] = 18   // redoing future DAScale
	wv[][3][%APFrequency] = 18.1 // finished

	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
	wv[][1][%BaselineQC] = 0
End

static Function PS_DS_AD12_REENTRY([string str])
	variable sweepNo

	sweepNo = 3

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {1, 0, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1, 0, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1, NaN, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1, 0, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1, 1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {0, 1, 0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 0, 0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1, 1, 1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN, NaN, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {4.891304347826073e-10, 4.891304347826073e-10, 6.521739130434707e-10, 6.521739130434707e-10}
	Make/FREE/D fiSlopeRef = {4.891304347826073e-10, 4.891304347826073e-10, 6.521739130434707e-10, 1.575299306869098e-11}
	Make/FREE/D fiOffsetRef = {-3.565217391304294, -3.565217391304294, -12.08695652173876, 17.27326191976437}
	Make/FREE/T futureDAScalesRef = {"5.22666666666667;4.61333333333333;", "5.22666666666667;4.61333333333333;", "5.22666666666667;4.61333333333333;5.24813333333334;", "5.22666666666667;4.61333333333333;5.24813333333334;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {5.22666666666667, 4.61333333333333, 4.61333333333333, 5.248133333333337}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD13_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier use defaults
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "SamplingFrequency", var = 10)

	// defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5})

	Make/FREE/D daScalesFromSupra = {1, 2}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD13([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// all tests pass, but sampling interval check fails
	wv[][][%APFrequency] = 16.1 - 5 * q
	wv[][][%AsyncQC]     = 1
	wv[][][%BaselineQC]  = 1
End

static Function PS_DS_AD13_REENTRY([string str])
	variable sweepNo

	sweepNo = 0

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {0}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {2.575757575757574e-10}
	Make/FREE/D fiSlopeRef = {2.575757575757574e-10}
	Make/FREE/D fiOffsetRef = {5.848484848484854}
	Make/FREE/T futureDAScalesRef = {"3.98;2.99;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9}
	Make/FREE/D DAScalesRef = {3.979999999999999}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End

static Function PS_DS_AD14_preAcq(string device)

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSLongThreshold", var = 0.5)
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "BaselineRMSShortThreshold", var = 0.07)

	// SamplingMultiplier, SamplingFrequency use defaults

	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "MaxFrequencyChangePercent", var = 25)

	// use defaults for the rest

	Make/FREE asyncChannels = {2, 4}
	AFH_AddAnalysisParameter("PSQ_DaScale_Adapt_DA_0", "AsyncQCChannels", wv = asyncChannels)

	SetAsyncChannelProperties(device, asyncChannels, -1e6, +1e6)

	WAVE/Z overrideResults = GetOverrideResults()
	CHECK_WAVE(overrideResults, NUMERIC_WAVE)
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweep", {7})
	JWN_SetWaveInWaveNote(overrideResults, "PassingSupraSweeps", {4, 5, 6, 7})

	Make/FREE/D daScalesFromSupra = {1, 2, 3, 4}
	JWN_SetWaveInWaveNote(overrideResults, "DAScalesSupra", daScalesFromSupra)

	Make/FREE/D apFrequenciesFromSupra = {10, 11, 13, 16}
	JWN_SetWaveInWaveNote(overrideResults, "APFrequenciesSupra", apFrequenciesFromSupra)
End

// UTF_TD_GENERATOR DeviceNameGeneratorMD1
static Function PS_DS_AD14([string str])

	[STRUCT DAQSettings s] = PS_GetDAQSettings(str)
	AcquireData_NG(s, str)

	WAVE wv = PSQ_CreateOverrideResults(str, PSQ_TEST_HEADSTAGE, PSQ_DA_SCALE, opMode = PSQ_DS_ADAPT)

	// fit error on first sweep, passes on second sweep
	wv[][0][%APFrequency]  = NaN
	wv[][1,][%APFrequency] = 16.1

	wv[][][%AsyncQC]    = 1
	wv[][][%BaselineQC] = 1
End

static Function PS_DS_AD14_REENTRY([string str])
	variable sweepNo

	sweepNo = 1

	WAVE/WAVE entries = GetEntries_IGNORE(str, sweepNo)

	CHECK_EQUAL_TEXTWAVES(entries[%opMode], {PSQ_DS_ADAPT}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%setPass], {1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%sweepPass], {0, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%rmsShortPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%rmsLongPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%baselinePass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%asyncPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%samplingPass], {1, 1}, mode = WAVE_DATA)

	CHECK_EQUAL_WAVES(entries[%futureDAScalesPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopeReachedPass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%enoughFIPointsPass], {1, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%validSlopePass], {0, 1}, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%initialValidSlopePass], {1, NaN}, mode = WAVE_DATA)

	[WAVE apFreqRef, WAVE apFreqFromSupra, WAVE DAScalesFromSupra] = ExtractRefValuesFromOverride(sweepNo)

	CHECK_EQUAL_WAVES(entries[%apfreq], apFreqRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%apfreqFromSupra], apFreqFromSupra, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%dascaleFromSupra], DAScalesFromSupra, mode = WAVE_DATA)

	Make/FREE/D maxSlopeRef = {3e-10, 3e-10}
	Make/FREE/D fiSlopeRef = {NaN, 8.152173913043478e-12}
	Make/FREE/D fiOffsetRef = {NaN, 15.67391304347826}
	Make/FREE/T futureDAScalesRef = {"5.22666666666667;", "5.22666666666667;"}

	Make/FREE/D fiSlopesFromSupraRef = {1e-10, 2e-10, 3e-10}
	Make/FREE/D fiOffsetsFromSupraRef = {9, 7, 4}
	Make/FREE/D DAScalesRef = {5.226666666666667, 5.22666666666667}

	CHECK_EQUAL_WAVES(entries[%maxSlope], maxSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiSlope], fiSlopeRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffset], fiOffsetRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_TEXTWAVES(entries[%futureDAScales], futureDAScalesRef, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(entries[%fiSlopesFromSupra], fiSlopesFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%fiOffsetsFromSupra], fiOffsetsFromSupraRef, mode = WAVE_DATA, tol = 1e-24)
	CHECK_EQUAL_WAVES(entries[%dascale], DAScalesRef, mode = WAVE_DATA, tol = 1e-24)

	CommonAnalysisFunctionChecks(str, sweepNo, entries[%setPass])
End
