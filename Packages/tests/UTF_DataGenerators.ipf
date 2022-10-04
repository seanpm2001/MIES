#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=DataGenerators

Function/WAVE MajorNWBVersions()

	Make/FREE wv = {1, 2}

	SetDimensionLabels(wv, "v1;v2", ROWS)

	return wv
End

Function/WAVE IndexingPossibilities()
	Make/FREE wv = {0, 1}

	SetDimensionLabels(wv, "UnlockedIndexing;LockedIndexing", ROWS)

	return wv
End

Function/WAVE SingleMultiDeviceDAQ()

	WAVE multiDevices = DeviceNameGeneratorMD1()
	WAVE singleDevices = DeviceNameGeneratorMD0()

	Make/FREE wv = {1}
	SetDimLabel ROWS, 0, MultiDevice, wv

	if(DimSize(singleDevices, ROWS) > 0)
		InsertPoints/M=(ROWS)/V=0 0, 1, wv
		SetDimLabel ROWS, 0, SingleDevice, wv
	endif

	return wv
End

Function/WAVE DeviceNameGenerator()
	return DeviceNameGeneratorMD1()
End

Function/WAVE DeviceNameGeneratorMD1()

	string devList = ""
	string lblList = ""
	variable i

#ifdef TESTS_WITH_NI_HARDWARE

#ifdef TESTS_WITH_YOKING
#define *** NI Hardware has no Yoking support
#else
	devList = AddListItem("Dev1", devList, ":")
	lblList = AddListItem("NI", lblList)
#endif

#endif

#ifdef TESTS_WITH_ITC18USB_HARDWARE

#ifdef TESTS_WITH_YOKING
#define *** ITC18USB has no Yoking support
#else
	devList = AddListItem("ITC18USB_Dev_0", devList, ":")
	lblList = AddListItem("ITC", lblList)
#endif

#endif

#ifdef TESTS_WITH_ITC1600_HARDWARE

#ifdef TESTS_WITH_YOKING
	devList = AddListItem("ITC1600_Dev_0;ITC1600_Dev_1", devList, ":")
	lblList = AddListItem("ITC600_YOKED", lblList)
#else
	devList = AddListItem("ITC1600_Dev_1", devList, ":")
	lblList = AddListItem("ITC1600", lblList)
#endif

#endif

	WAVE data = ListToTextWave(devList, ":")
	for(i = 0; i < DimSize(data, ROWS); i += 1)
		SetDimLabel ROWS, i, $StringFromList(i, lblList), data
	endfor

	return data
End

Function/WAVE DeviceNameGeneratorMD0()

#ifdef TESTS_WITH_NI_HARDWARE
	// NI Hardware has no single device support
	Make/FREE/T/N=0 data
	return data
#endif

#ifdef TESTS_WITH_ITC18USB_HARDWARE

#ifdef TESTS_WITH_YOKING
	// Yoking with ITC hardware is only supported in multi device mode
	Make/FREE/T/N=0 data
	return data
#else
	return DeviceNameGeneratorMD1()
#endif

#endif

#ifdef TESTS_WITH_ITC1600_HARDWARE

#ifdef TESTS_WITH_YOKING
	// Yoking with ITC hardware is only supported in multi device mode
	Make/FREE/T/N=0 data
	return data
#else
	return DeviceNameGeneratorMD1()
#endif

#endif

End

Function/WAVE NWBVersionStrings()
	variable i, numEntries
	string name

	Make/T/FREE data = {"2.0b", "2.0.1", "2.1.0", "2.2.0"}
	return data
End

Function/WAVE NeuroDataRefTree()
	variable i, numEntries
	string name

	Make/T/FREE data = {"VoltageClampSeries:TimeSeries;PatchClampSeries;VoltageClampSeries;", \
						"CurrentClampSeries:TimeSeries;PatchClampSeries;CurrentClampSeries;", \
						"IZeroClampSeries:TimeSeries;PatchClampSeries;CurrentClampSeries;IZeroClampSeries;" \
						}
	return data
End

Function/WAVE SpikeCountsStateValues()
	variable numEntries = 6
	variable idx

	Make/FREE/WAVE/N=(numEntries) wv

	wv[idx++] = WaveRef({2, 2, 2, SC_SPIKE_COUNT_NUM_GOOD})
	wv[idx++] = WaveRef({1, 1, 1, SC_SPIKE_COUNT_NUM_GOOD})
	wv[idx++] = WaveRef({1, 2, 1, SC_SPIKE_COUNT_NUM_TOO_MANY})
	wv[idx++] = WaveRef({1, 2, 2, SC_SPIKE_COUNT_NUM_TOO_FEW})
	wv[idx++] = WaveRef({1, 3, 2, SC_SPIKE_COUNT_NUM_MIXED})
	wv[idx++] = WaveRef({NaN, NaN, 2, SC_SPIKE_COUNT_NUM_MIXED})

	Make/FREE/N=(numEntries) indexHelper = SetDimensionLabels(wv[p], "minimum;maximum;idealNumber;expectedState", ROWS)

	return wv
End

Function/WAVE GenerateBaselineValues()

	Make/FREE wv = {25, 35, 45}

	SetDimensionLabels(wv, "BL_25;BL_35;BL_45", ROWS)

	return wv
End