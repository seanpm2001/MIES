#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function ITCOscilloscope(WaveToPlot, panelTitle)
	wave WaveToPlot
	string panelTitle
	string NameOfWaveBeingPlotted = nameOfwave(WaveToPlot)
	string oscilloscopeSubWindow = panelTitle + "#oscilloscope"
	//ModifyGraph /w = $oscilloscopeSubWindow Live = 0
	variable i =  0
	string WavePath = HSU_DataFullFolderPathString(PanelTitle) + ":"
	wave ITCDataWave = $WavePath + "ITCDataWave"
	wave TestPulseITC = $WavePath+"TestPulse:TestPulseITC", ITCChanConfigWave =$WavePath + "ITCChanConfigWave"
	wave ChannelClampMode = $WavePath + "ChannelClampMode"
	wave SSResistanceWave = $WavePath + "TestPulse:SSResistance"
	wave InstResistanceWave = $WavePath + "TestPulse:InstResistance"
	string ADChannelName= "AD"
	string ADChannelList = RefToPullDatafrom2DWave(0,0, 1, ITCChanConfigWave)
	string UnitWaveNote = note(ITCChanConfigWave)
	string Unit
	string SSResistanceTraceName = "SSResistance"
	string InstResistanceTraceName = "InstResistance"
	RemoveTracesOnGraph(oscilloscopeSubWindow)
	variable Yoffset = 40/(itemsinlist(ADChannelList))
	string cmd
	ModifyGraph /w = $oscilloscopeSubWindow freePos=0

	variable YaxisLow, YaxisHigh, YaxisSpacing, Spacer
	YaxisSpacing = 1 / ((itemsinlist(ADChannelList)))
	Spacer = 0.025
	
	YaxisHigh = 1
	YaxisLow = YaxisHigh-YaxisSpacing + spacer
	for(i = 0; i < (itemsinlist(ADChannelList)); i += 1)
		ADChannelName ="AD"+stringfromlist(i, ADChannelList,";")
		appendtograph /W = $oscilloscopeSubWindow /L = $ADChannelName WaveToPlot[][(i+((NoOfChannelsSelected("da", "check", panelTitle))))]
		ModifyGraph/w=$oscilloscopeSubWindow axisEnab($ADChannelName) = {YaxisLow,YaxisHigh}, freepos($ADChannelName) = {0, kwFraction}
		SetAxis /w = $oscilloscopeSubWindow /A =2 /N =2 $ADchannelName // this line should autoscale only the visible data; /N makes the autoscaling range larger
		Unit = stringfromlist(i + NoOfChannelsSelected("da", "check", panelTitle), UnitWaveNote, ";")// extracts unit from string list that contains units in same sequence as columns in the ITCDatawave
		Label /w = $oscilloscopeSubWindow $ADChannelName, ADChannelName + " (" + Unit + ")"
		ModifyGraph /w = $oscilloscopeSubWindow lblPosMode = 1
		Label /w = $oscilloscopeSubWindow bottom "Time (\\U)"
		
		if(cmpstr(NameOfWaveBeingPlotted, "TestPulseITC") == 0)
			appendtograph /W = $oscilloscopeSubWindow /R = $"SSResistance" + num2str(i) SSResistanceWave[][i] , InstResistanceWave[][i]
			ModifyGraph /W = $oscilloscopeSubWindow noLabel($"SSResistance" + num2str(i)) = 2, axThick($"SSResistance" + num2str(i)) = 0, width = 25
			ModifyGraph /W = $oscilloscopeSubWindow axisEnab($"SSResistance" + num2str(i)) = {YaxisLow,YaxisHigh}, freepos($"SSResistance" + num2str(i)) = {1, kwFraction}
			ModifyGraph  /W = $oscilloscopeSubWindow mode($"SSResistance") = 2, lsize($"SSResistance") = 0
			SetAxis /W = $oscilloscopeSubWindow /A = 2 /N = 2 /E = 2 $"SSResistance" + num2str(i) -20000000, 20000000
			if(i > 0)
				SSResistanceTraceName = "SSResistance#"+num2str(i)
				InstResistanceTraceName = "InstResistance#"+num2str(i)
				ModifyGraph  /W = $oscilloscopeSubWindow mode($"SSResistance#" + num2str(i)) = 2, lsize($"SSResistance#" + num2str(i)) = 0
			endif
			Tag /W = $oscilloscopeSubWindow /C /N = $"SSR" + num2str(i) /F = 0 /X = -5 /Y = (-Yoffset) /B = 1 /L = 0 /Z = 0 /A = MC /I = 1 $SSResistanceTraceName, 0,"R\Bss\M\\OY \\Z10(M\\F'Symbol'W\M)"
			Tag /W = $oscilloscopeSubWindow /C /N = $"InstR" + num2str(i) /F = 0 /B = 1 /A = LT /X = -15 /Y = (-Yoffset) /L = 0 $InstResistanceTraceName, 5.01,"R\Bpeak\M \\OY \Z10(M\\F'Symbol'W\M)"// \\Z10\r(Mohm)"
			// dynamic tag can call a function that returns a string
		//	SetAxis /w = $oscilloscopeSubWindow bottom 0, ( ( (CalculateITCDataWaveLength(panelTitle) * (ITCMinSamplingInterval(panelTitle) / 1000)) / 4) 
		endif
		YaxisHigh -= YaxisSpacing
		YaxisLow -= YaxisSpacing

	endfor
	SetAxis /w = $oscilloscopeSubWindow bottom 0, (dimsize(ITCDataWave, 0) /5) * (ITCMinSamplingInterval(panelTitle) / 1000) //( (CalculateITCDataWaveLength(panelTitle) + ReturnTotalLengthIncrease(PanelTitle)) * ((ITCMinSamplingInterval(panelTitle) / 1000))) / 4) 

	doupdate
End

Function/t ReturnStringforTag(panelTitle, waveToconvert, column)
	string panelTitle
	wave waveToConvert
	variable column
	string strValue
	sprintf strValue, "%0.3g", waveToConvert[0][column]
	return strValue
End
//=========================================================================================

Function/s FindValueInColumnof2Dwave(Value, Column, TwoDWave)//DA = 1, AD = 0, DO = 3
	variable Value, Column
	wave TwoDwave
	variable i = 0, a = 2
	string RowsThatContainValue = ""
	
	//duplicate/free/r=[][Column] TwoDwave, F
		do
			if(TwoDWave[i][Column] == Value)
			RowsThatContainValue += num2str(i) + ";"
			endif
		i += 1
		while (i < (DimSize(TwoDWave,0)))
	
	return RowsThatContainValue
 
End

//=========================================================================================
Function/s RefToPullDatafrom2DWave(Value,RefColumn, DataColumn, TwoDWave)// Returns the data from the data column based on matched values in the ref column
	wave TwoDWave// For ITCDataWave 0 (value) in Ref column = AD channel, 1 = DA channel,
	variable Value,RefColumn, DataColumn
	variable i = 0
	string Values = ""
	string RowList = FindValueInColumnof2Dwave(Value, RefColumn, TwoDWave)
	
	do
		values += (num2str(TwoDwave[str2num(stringfromlist(i,RowList,";"))][DataColumn])) + ";"
		i += 1
	while(i < (itemsinlist(RowList,";")))
	
	return Values
End
//=========================================================================================

Function RemoveTracesOnGraph(GraphName)
	string GraphName
	variable i = 0
	string cmd, WaveNameFromList
	string ListOfTracesOnGraph
	string Tracename
	
	ListOfTracesOnGraph = TraceNameList(GraphName, ";", 0 + 1)
	if(itemsinlist(ListOfTracesOnGraph,";") > 0)
	do
	TraceName = "\"#0\""
	sprintf cmd, "removefromgraph/w=%s $%s" GraphName, TraceName
	execute cmd
	i += 1
	while(i < (itemsinlist(ListOfTracesOnGraph,";")))
	endif
End

