#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

#ifdef AUTOMATED_TESTING
#pragma ModuleName=MIES_UTILS_FILE
#endif

/// @file MIES_Utilities_File.ipf
/// @brief utility functions for file handling

/// @brief Returns a unique and non-existing file or folder name
///
/// @warning This function must *not* be used for security relevant purposes,
/// as for that the check-and-file-creation must be an atomic operation.
///
/// @param symbPath  symbolic path
/// @param baseName  base name of the file, must not be empty
/// @param suffix    file/folder suffix
Function/S UniqueFileOrFolder(symbPath, baseName, [suffix])
	string symbPath, baseName, suffix

	string file
	variable i = 1

	PathInfo $symbPath
	ASSERT(V_flag == 1, "Symbolic path does not exist")
	ASSERT(!isEmpty(baseName), "baseName must not be empty")

	if(ParamIsDefault(suffix))
		suffix = ""
	endif

	file = baseName + suffix

	do
		GetFileFolderInfo/Q/Z/P=$symbPath file

		if(V_flag)
			return file
		endif

		file = baseName + "_" + num2str(i) + suffix
		i   += 1

	while(i < 10000)

	ASSERT(0, "Could not find a unique file with 10000 trials")
End

/// @brief Return true if the given absolute path refers to an existing drive letter
Function IsDriveValid(absPath)
	string absPath

	string drive

	drive = GetDrive(absPath)
	return FolderExists(drive)
End

/// @brief Return the drive letter of the given path (Windows) or the volume name (Macintosh)
Function/S GetDrive(string path)

	string drive

	path  = GetHFSPath(path)
	drive = StringFromList(0, path, ":")

	return drive
End

/// @brief Create a folder recursively on disk given an absolute path
///
/// If you pass windows style paths using backslashes remember to always *double* them.
Function CreateFolderOnDisk(absPath)
	string absPath

	string path, partialPath, tempPath
	variable numParts, i

	path = GetHFSPath(absPath)
	ASSERT(!FileExists(path), "The path which we should create exists, but points to a file")

	tempPath    = UniqueName("tempPath", 12, 0)
	numParts    = ItemsInList(path, ":")
	partialPath = GetDrive(path)

	// we skip the first one as that is the drive letter
	for(i = 1; i < numParts; i += 1)
		partialPath += ":" + StringFromList(i, path, ":")

		ASSERT(!FileExists(partialPath), "The path which we should create exists, but points to a file")

		NewPath/O/C/Q/Z $tempPath, partialPath
	endfor

	KillPath/Z $tempPath

	ASSERT(FolderExists(partialPath), "Could not create the path, maybe the permissions were insufficient")
End

/// @brief Return the base name of the file
///
/// Given `path/file.suffix` this gives `file`.
///
/// @param filePathWithSuffix full path
/// @param sep                [optional, defaults to ":"] character
///                           separating the path components
threadsafe Function/S GetBaseName(filePathWithSuffix, [sep])
	string filePathWithSuffix, sep

	if(ParamIsDefault(sep))
		sep = ":"
	endif

	return ParseFilePath(3, filePathWithSuffix, sep, 1, 0)
End

/// @brief Return the file extension (suffix)
///
/// Given `path/file.suffix` this gives `suffix`.
///
/// @param filePathWithSuffix full path
/// @param sep                [optional, defaults to ":"] character
///                           separating the path components
threadsafe Function/S GetFileSuffix(filePathWithSuffix, [sep])
	string filePathWithSuffix, sep

	if(ParamIsDefault(sep))
		sep = ":"
	endif

	return ParseFilePath(4, filePathWithSuffix, sep, 0, 0)
End

/// @brief Return the folder of the file
///
/// Given `path/file.suffix` this gives `path`.
/// The returned result has a trailing separator.
///
/// @param filePathWithSuffix full path
/// @param sep                [optional, defaults to ":"] character
///                           separating the path components
threadsafe Function/S GetFolder(filePathWithSuffix, [sep])
	string filePathWithSuffix, sep

	if(ParamIsDefault(sep))
		sep = ":"
	endif

	return ParseFilePath(1, filePathWithSuffix, sep, 1, 0)
End

/// @brief Return the filename with extension
///
/// Given `path/file.suffix` this gives `file.suffix`.
///
/// @param filePathWithSuffix full path
/// @param sep                [optional, defaults to ":"] character
///                           separating the path components
threadsafe Function/S GetFile(filePathWithSuffix, [sep])
	string filePathWithSuffix, sep

	if(ParamIsDefault(sep))
		sep = ":"
	endif

	return ParseFilePath(0, filePathWithSuffix, sep, 1, 0)
End

/// @brief Return the path converted to a windows style path
threadsafe Function/S GetWindowsPath(path)
	string path

	return ParseFilepath(5, path, "\\", 0, 0)
End

/// @brief Return the path converted to a HFS style (aka ":" separated) path
threadsafe Function/S GetHFSPath(string path)

#if defined(WINDOWS)
	return ParseFilePath(5, path, ":", 0, 0)
#elif defined(MACINTOSH)
	return ParseFilePath(5, path, "*", 0, 0)
#else
	ASSERT_TS(0, "Unsupported OS")
#endif
End

/// @brief Recursively resolve shortcuts to files/directories
///
/// @return full path or an empty string if the file does not exist or the
/// 		shortcut points to a non existing file/folder
Function/S ResolveAlias(path, [pathName])
	string pathName, path

	if(ParamIsDefault(pathName))
		GetFileFolderInfo/Q/Z path
	else
		GetFileFolderInfo/P=$pathName/Q/Z path
	endif

	if(V_flag)
		return ""
	endif

	if(!V_IsAliasShortcut)
		return path
	endif

	if(ParamIsDefault(pathName))
		return ResolveAlias(S_aliasPath)
	else
		return ResolveAlias(S_aliasPath, pathName = pathName)
	endif
End

/// @brief Return a unique symbolic path name
///
/// \rst
/// .. code-block:: igorpro
///
///		string symbPath = GetUniqueSymbolicPath()
///		NewPath/Q/O $symbPath, "C:"
/// \endrst
Function/S GetUniqueSymbolicPath([prefix])
	string prefix

	if(ParamIsDefault(prefix))
		prefix = "temp_"
	else
		prefix = CleanupName(prefix, 0)
	endif

	NewRandomSeed()
	return prefix + num2istr(GetUniqueInteger())
End

/// @brief Return a list of all files from the given symbolic path
///        and its subfolders. The list is pipe (`FILE_LIST_SEP`) separated as
///        the semicolon (`;`) is a valid character in filenames.
///
/// Note: This function does *not* work on MacOSX as there filenames are allowed
///       to have pipe symbols in them.
///
/// @param pathName igor symbolic path to search recursively
/// @param extension [optional, defaults to all files] file suffixes to search for
Function/S GetAllFilesRecursivelyFromPath(pathName, [extension])
	string pathName, extension

	string fileOrPath, folders, subFolderPathName, fileName
	string files, allFilesList
	string allFiles         = ""
	string foldersFromAlias = ""
	variable err

	PathInfo $pathName
	ASSERT(V_flag, "Given symbolic path does not exist")

	if(ParamIsDefault(extension))
		extension = "????"
	endif

	AssertOnAndClearRTError()
	allFilesList = IndexedFile($pathName, -1, extension, "????", FILE_LIST_SEP); err = GetRTError(1)
	WAVE/T allFilesInDir = ListToTextWave(allFilesList, FILE_LIST_SEP)
	for(fileName : allFilesInDir)

		fileOrPath = ResolveAlias(fileName, pathName = pathName)

		if(isEmpty(fileOrPath))
			// invalid shortcut, try next file
			continue
		endif

		GetFileFolderInfo/P=$pathName/Q/Z fileOrPath
		ASSERT(!V_Flag, "Error in GetFileFolderInfo")

		if(V_isFile)
			allFiles = AddListItem(S_path, allFiles, FILE_LIST_SEP, Inf)
		elseif(V_isFolder)
			foldersFromAlias = AddListItem(S_path, foldersFromAlias, FILE_LIST_SEP, Inf)
		else
			ASSERT(0, "Unexpected file type")
		endif
	endfor

	AssertOnAndClearRTError()
	folders = IndexedDir($pathName, -1, 1, FILE_LIST_SEP); err     = GetRTError(1)
	folders = folders + foldersFromAlias
	WAVE/T wFolders = ListToTextWave(folders, FILE_LIST_SEP)
	for(folder : wFolders)

		subFolderPathName = GetUniqueSymbolicPath()

		NewPath/Q/O $subFolderPathName, folder
		files = GetAllFilesRecursivelyFromPath(subFolderPathName, extension = extension)
		KillPath/Z $subFolderPathName

		if(!isEmpty(files))
			allFiles = AddListItem(RemoveEnding(files, FILE_LIST_SEP), allFiles, FILE_LIST_SEP, Inf)
		endif
	endfor

	return allFiles
End

/// @brief Open a folder selection dialog
///
/// @return a string denoting the selected folder, or an empty string if
/// nothing was supplied.
Function/S AskUserForExistingFolder(string baseFolder)

	string symbPath, selectedFolder

	symbPath = GetUniqueSymbolicPath()

	NewPath/O/Q/Z $symbPath, baseFolder
	// preset next undirected NewPath/Open call using the contents of a
	// *symbolic* folder
	PathInfo/S $symbPath

	// let the user choose a folder, starts in $baseFolder if supplied
	NewPath/O/Q/Z $symbPath
	if(V_flag == -1)
		return ""
	endif
	PathInfo $symbPath
	selectedFolder = S_path
	KillPath/Z $symbPath

	return selectedFolder
End

/// @brief Check that the given path on disk has enough free space
///
/// @param diskPath          path on disk to check
/// @param requiredFreeSpace required free space in GB
Function HasEnoughDiskspaceFree(diskPath, requiredFreeSpace)
	string   diskPath
	variable requiredFreeSpace

	variable leftOverBytes

	ASSERT(FolderExists(diskPath), "discPath does not point to an existing folder")

	leftOverBytes = MU_GetFreeDiskSpace(GetWindowsPath(diskPath))

	return IsFinite(leftOverBytes) && leftOverBytes >= requiredFreeSpace
End

/// @brief Return a `/Z` flag value for the `Open` operation which works with
/// automated testing
Function GetOpenZFlag()
#ifdef AUTOMATED_TESTING
	return 1 // no dialog if the file does not exist
#else
	return 2
#endif
End

/// @brief Saves string data to a file
///
/// @param[in] data string containing data to save
/// @param[in] fileName fileName to use. If the fileName is empty or invalid a file save dialog will be shown.
/// @param[in] fileFilter [optional, default = "Plain Text Files (*.txt):.txt;All Files:.*;"] file filter string in Igor specific notation.
/// @param[in] message [optional, default = "Create file"] window title of the save file dialog.
/// @param[out] savedFileName [optional, default = ""] file name of the saved file
/// @param[in] showDialogOnOverwrite [optional, default = 0] opens save file dialog, if the current fileName would cause an overwrite, to allow user to change fileName
/// @returns NaN if file open dialog was aborted or an error was encountered, 0 otherwise
Function SaveTextFile(data, fileName, [fileFilter, message, savedFileName, showDialogOnOverwrite])
	string data, fileName, fileFilter, message, &savedFileName
	variable showDialogOnOverwrite

	variable fNum, dialogCode

	if(!ParamIsDefault(savedFileName))
		savedFileName = ""
	endif

#ifdef AUTOMATED_TESTING
	string S_fileName = fileName
#else
	showDialogOnOverwrite = ParamIsDefault(showDialogOnOverwrite) ? 0 : !!showDialogOnOverwrite
	dialogCode            = showDialogOnOverwrite && FileExists(fileName) ? 1 : 2
	if(ParamIsDefault(fileFilter) && ParamIsDefault(message))
		Open/D=(dialogCode) fnum as fileName
	elseif(ParamIsDefault(fileFilter) && !ParamIsDefault(message))
		Open/D=(dialogCode)/M=message fnum as fileName
	elseif(!ParamIsDefault(fileFilter) && ParamIsDefault(message))
		Open/D=(dialogCode)/F=fileFilter fnum as fileName
	else
		Open/D=(dialogCode)/F=fileFilter/M=message fnum as fileName
	endif

	if(IsEmpty(S_fileName))
		return NaN
	endif
#endif

	Open/Z fnum as S_fileName
	ASSERT(!V_flag, "Could not open file for writing!")
	if(!ParamIsDefault(savedFileName))
		savedFileName = S_fileName
	endif

	FBinWrite fnum, data
	Close fnum

	return 0
End

/// @brief Load data from file to a string. The file size must be < 2GB.
///
/// @param[in] fileName fileName to use. If the fileName is empty or invalid a file load dialog will be shown.
/// @param[in] fileFilter [optional, default = "Plain Text Files (*.txt):.txt;All Files:.*;"] file filter string in Igor specific notation.
/// @param[in] message [optional, default = "Select file"] window title of the save file dialog.
/// @returns loaded string data and full path fileName
Function [string data, string fName] LoadTextFile(string fileName, [string fileFilter, string message])

	variable fNum, zFlag

	zFlag = GetOpenZFlag()

	if(ParamIsDefault(fileFilter) && ParamIsDefault(message))
		Open/R/Z=(zFlag) fnum as fileName
	elseif(ParamIsDefault(fileFilter) && !ParamIsDefault(message))
		Open/R/Z=(zFlag)/M=message fnum as fileName
	elseif(!ParamIsDefault(fileFilter) && ParamIsDefault(message))
		Open/R/Z=(zFlag)/F=fileFilter fnum as fileName
	else
		Open/R/Z=(zFlag)/F=fileFilter/M=message fnum as fileName
	endif

	if(IsEmpty(S_fileName) || V_flag)
		return ["", ""]
	endif

	FStatus fnum
	ASSERT(V_logEOF < STRING_MAX_SIZE, "Can't load " + num2istr(V_logEOF) + " bytes to string.")
	data = PadString("", V_logEOF, 0x20)
	FBinRead fnum, data
	Close fnum

	return [data, S_Path + S_fileName]
End

/// @brief Load data from a file to a text wave.
///
/// @param[in] fullFilePath full path to the file to be loaded
/// @param[in] sep          separator string that splits the file data to the wave cells, typically the line ending
/// @returns free text wave with the data, a null wave if the file could not be found or there was a problem reading the file
Function/WAVE LoadTextFileToWave(string fullFilePath, string sep)

	variable loadFlags, err

	if(!FileExists(fullFilePath))
		return $""
	endif

	loadFlags = LOADWAVE_V_FLAGS_DISABLELINEPRECOUNTING | LOADWAVE_V_FLAGS_DISABLEUNESCAPEBACKSLASH | LOADWAVE_V_FLAGS_DISABLESUPPORTQUOTEDSTRINGS
	AssertOnAndClearRTError()
	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder NewFreeDataFolder()

	LoadWave/Q/H/A/J/K=2/V={sep, "", 0, loadFlags} fullFilePath; err = GetRTError(1)
	if(!V_flag)
		SetDataFolder saveDFR
		return $""
	elseif(V_flag > 1)
		SetDataFolder saveDFR
		ASSERT(0, "Expected to load a single text wave")
	endif

	WAVE/T wv = $StringFromList(0, S_waveNames)
	SetDataFolder saveDFR

	return wv
End

/// @brief Check wether the given path points to an existing file
///
/// Resolves shortcuts and symlinks recursively.
Function FileExists(filepath)
	string filepath

	filepath = ResolveAlias(filepath)
	AssertOnAndClearRTError()
	try
		GetFileFolderInfo/Q/Z filepath; AbortOnRTE
	catch
		ASSERT(0, "Error: " + GetRTErrMessage())
	endtry

	return !V_Flag && V_IsFile
End

/// @brief Check wether the given path points to an existing folder
Function FolderExists(folderpath)
	string folderpath

	folderpath = ResolveAlias(folderpath)
	AssertOnAndClearRTError()
	try
		GetFileFolderInfo/Q/Z folderpath; AbortOnRTE
	catch
		ASSERT(0, "Error: " + GetRTErrMessage())
	endtry

	return !V_Flag && V_isFolder
End

/// @brief Return the file version
Function/S GetFileVersion(filepath)
	string filepath

	filepath = ResolveAlias(filepath)
	AssertOnAndClearRTError()
	try
		GetFileFolderInfo/Q/Z filepath; AbortOnRTE
	catch
		ASSERT(0, "Error: " + GetRTErrMessage())
	endtry

	if(V_flag || !V_isFile)
		return ""
	endif

	return S_FileVersion
End

/// @brief Return the file size in bytes
Function GetFileSize(string filepath)

	filepath = ResolveAlias(filepath)

	AssertOnAndClearRTError()
	try
		GetFileFolderInfo/Q/Z filepath; AbortOnRTE
	catch
		ASSERT(0, "Error: " + GetRTErrMessage())
	endtry

	if(V_flag || !V_isFile)
		return NaN
	endif

	return V_logEOF
End

/// @brief Convert a HFS path (`:`) to a POSIX path (`/`)
///
/// The path *must* exist.
Function/S HFSPathToPosix(string path)
	return ParseFilePath(9, path, "*", 0, 0)
End

/// @brief Convert a HFS path (`:`) to a Windows path (`\\`)
Function/S HFSPathToWindows(string path)
	return ParseFilePath(5, path, "\\", 0, 0)
End

/// @brief Convert HFS path (`:`) to OS native path (`\\` or `/`)
Function/S HFSPathToNative(string path)

#if defined(MACINTOSH)
	return HFSPathToPosix(path)
#elif defined(WINDOWS)
	return HFSPathToWindows(path)
#else
	ASSERT(0, "Unsupported OS")
#endif
End

/// @brief Return the name of a symbolic path which points to the crash dump
/// directory on windows
Function/S GetSymbolicPathForDiagnosticsDirectory()

	string userName, path, symbPath

	userName = GetSystemUserName()

	sprintf path, "C:Users:%s:AppData:Roaming:WaveMetrics:Igor Pro %d:Diagnostics:", userName, GetIgorProMajorVersion()

	if(!FolderExists(path))
		CreateFolderOnDisk(path)
	endif

	symbPath = "crashInfo"

	NewPath/O/Q $symbPath, path

	return symbPath
End

Function ShowDiagnosticsDirectory()

	string symbPath = GetSymbolicPathForDiagnosticsDirectory()
	PathInfo/SHOW $symbPath
End

/// @brief Sanitize the given name so that it is a nice file name
Function/S SanitizeFilename(string name)

	variable numChars, i
	string result, regexp

	numChars = strlen(name)

	ASSERT(numChars > 0, "name can not be empty")

	result = ""
	regexp = "^[A-Za-z_\-0-9\.]+$"

	for(i = 0; i < numChars; i += 1)
		if(GrepString(name[i], regexp))
			result[i] = name[i]
		else
			result[i] = "_"
		endif
	endfor

	ASSERT(GrepString(result, regexp), "Invalid file name")

	return result
End

/// @brief Load the wave `$name.itx` from the folder of this procedure file and store
/// it in the static data folder.
Function/WAVE LoadWaveFromDisk(string name)
	string path

	path = GetFolder(FunctionPath("")) + name + ".itx"

	LoadWave/Q/C/T path
	if(!V_flag)
		return $""
	endif

	ASSERT(ItemsInList(S_waveNames) == 1, "Could not find exactly one wave")

	WAVE wv = $StringFromList(0, S_waveNames)

	DFREF dfr = GetStaticDataFolder()
	MoveWave wv, dfr

	return wv
End

/// @brief Store the given wave as `$name.itx` in the same folder as this
/// procedure file on disk.
Function StoreWaveOnDisk(WAVE wv, string name)
	string path

	ASSERT(IsValidObjectName(name), "Name is not a valid igor object name")

	DFREF dfr = GetUniqueTempPath()
	Duplicate wv, dfr:$name/WAVE=storedWave

	path = GetFolder(FunctionPath("")) + name + ".itx"
	Save/O/T/M="\n" storedWave as path
	KillOrMoveToTrash(wv = storedWave)
	RemoveEmptyDataFolder(dfr)
End

/// @brief Returns the path to the users documents folder
Function/S GetUserDocumentsFolderPath()

	string userDir = GetEnvironmentVariable("USERPROFILE")

	userDir = ParseFilePath(2, ParseFilePath(5, userDir, ":", 0, 0), ":", 0, 0)

	return userDir + "Documents:"
End

#ifdef MACINTOSH

threadsafe Function MU_GetFreeDiskSpace(string path)
	ASSERT_TS(0, "Not implemented")
End

#endif

/// @brief Cleanup the experiment name
Function/S CleanupExperimentName(expName)
	string expName

	// Remove the following suffixes:
	// - sibling
	// - time stamp
	// - numerical suffixes added to prevent overwriting files
	expName = RemoveEndingRegExp(expName, "_[[:digit:]]{4}_[[:digit:]]{2}_[[:digit:]]{2}_[[:digit:]]{6}") // example: 2015_03_25_213219
	expName = RemoveEndingRegExp(expName, "_[[:digit:]]{1,5}")                                            // example: _1, _123
	expName = RemoveEnding(expName, SIBLING_FILENAME_SUFFIX)

	return expName
End

/// @brief Calculate a cryptographic hash for the file contents of path
///
/// @param path   absolute path to a file
/// @param method [optional, defaults to #HASH_SHA2_256]
///               Type of cryptographic hash function, one of @ref HASH_SHA2_256
Function/S CalcHashForFile(path, [method])
	string   path
	variable method

	string contents, loadedFilePath

	if(ParamIsDefault(method))
		method = HASH_SHA2_256
	endif

	ASSERT(FileExists(path), "Expected a file")

	[contents, loadedFilePath] = LoadTextFile(path)

	return Hash(contents, method)
End

/// @brief Check if the file paths referenced in `list` are pointing
///        to identical files
Function CheckIfPathsRefIdenticalFiles(list)
	string list

	variable i, numEntries
	string path, refHash, newHash

	if(ItemsInList(list, FILE_LIST_SEP) <= 1)
		return 1
	endif

	numEntries = ItemsInList(list, FILE_LIST_SEP)
	for(i = 0; i < numEntries; i += 1)
		path = StringFromList(i, list, FILE_LIST_SEP)

		if(i == 0)
			refHash = CalcHashForFile(path)
			continue
		endif

		newHash = CalcHashForFile(path)

		if(cmpstr(newHash, refHash))
			return 0
		endif
	endfor

	return 1
End

/// @brief Return a path to the program folder with trailing dir separator
///
/// Hardcoded as Igor does not allow to query that information.
///
/// Distinguishes between i386 and x64 Igor versions
Function/S GetProgramFilesFolder()

#if defined(IGOR64)
	return "C:\\Program Files\\"
#else
	return "C:\\Program Files (x86)\\"
#endif
End
