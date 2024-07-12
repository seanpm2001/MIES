#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma rtFunctionErrors=1

#ifdef AUTOMATED_TESTING
#pragma ModuleName=MIES_MIESUTILS_CHECKS
#endif

/// @file MIES_MiesUtilities_Checks.ipf
/// @brief This file holds MIES utility functions for checks

/// @brief Check if the given epoch number is valid
Function IsValidEpochNumber(epochNo)
	variable epochNo

	return IsInteger(epochNo) && epochNo >= 0 && epochNo < WB_TOTAL_NUMBER_OF_EPOCHS
End

/// @brief Check if the two waves are valid and compatible
///
/// @param sweep         sweep wave
/// @param config        config wave
/// @param configVersion [optional, defaults to #DAQ_CONFIG_WAVE_VERSION] minimum required version of the config wave
threadsafe Function IsValidSweepAndConfig(sweep, config, [configVersion])
	WAVE/Z sweep, config
	variable configVersion

	if(ParamIsDefault(configVersion))
		configVersion = DAQ_CONFIG_WAVE_VERSION
	endif

	if(!WaveExists(sweep))
		return 0
	endif

	if(IsWaveRefWave(sweep))
		return IsValidConfigWave(config, version = configVersion) && \
		       IsValidSweepWave(sweep) &&                            \
		       DimSize(sweep, ROWS) == DimSize(config, ROWS)
	elseif(IsTextWave(sweep))
		return IsValidConfigWave(config, version = configVersion) && \
		       IsValidSweepWave(sweep) &&                            \
		       DimSize(sweep, ROWS) == DimSize(config, ROWS)
	else
		return IsValidConfigWave(config, version = configVersion) && \
		       IsValidSweepWave(sweep) &&                            \
		       DimSize(sweep, COLS) == DimSize(config, ROWS)
	endif
End

/// @brief Check if the given multiplier is a valid sampling interval multiplier
///
/// UTF_NOINSTRUMENTATION
Function IsValidSamplingMultiplier(multiplier)
	variable multiplier

	return IsFinite(multiplier) && WhichListItem(num2str(multiplier), DAP_GetSamplingMultiplier()) != -1
End
