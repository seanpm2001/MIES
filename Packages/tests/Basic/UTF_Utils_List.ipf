#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTILSTEST_LIST

// Missing Tests for:
// ListMatchesExpr
// ListFromList
// BuildList
// WaveListHasSameWaveNames
// MergeLists

// AddPrefixToEachListItem
/// @{

Function APTEA_WorksWithList()

	string list, ref

	list = AddPrefixToEachListItem("ab-", "c;d")
	ref  = "ab-c;ab-d;"
	CHECK_EQUAL_STR(list, ref)
End

Function APTEA_WorksWithListAndCustomSep()

	string list, ref

	list = AddPrefixToEachListItem("ab-", "c|d", sep = "|")
	ref  = "ab-c|ab-d|"
	CHECK_EQUAL_STR(list, ref)
End

Function APTEA_WorksOnEmptyBoth()

	string list

	list = AddPrefixToEachListItem("", "")
	CHECK_EMPTY_STR(list)
End

/// @}

// AddSuffixToEachListItem
/// @{

Function ASTEA_WorksWithList()

	string list, ref

	list = AddSuffixToEachListItem("-ab", "c;d")
	ref  = "c-ab;d-ab;"
	CHECK_EQUAL_STR(list, ref)
End

Function ASTEA_WorksWithListAndCustomSep()

	string list, ref

	list = AddSuffixToEachListItem("-ab", "c|d", sep = "|")
	ref  = "c-ab|d-ab|"
	CHECK_EQUAL_STR(list, ref)
End

Function ASTEA_WorksOnEmptyBoth()

	string list

	list = AddSuffixToEachListItem("", "")
	CHECK_EMPTY_STR(list)
End

/// @}

/// RemovePrefixFromListItem
/// @{

Function RPFLI_Works()

	string ref, str

	// empty list
	str = RemovePrefixFromListItem("abcd", "")
	CHECK_EMPTY_STR(str)

	// empty prefix
	str = RemovePrefixFromListItem("", "abcd")
	ref = "abcd;"
	CHECK_EQUAL_STR(ref, str)

	// works
	str = RemovePrefixFromListItem("a", "aa;ab")
	ref = "a;b;"
	CHECK_EQUAL_STR(ref, str)

	// works with custom list sep
	str = RemovePrefixFromListItem("a", "aa|ab", listSep = "|")
	ref = "a|b|"
	CHECK_EQUAL_STR(ref, str)

	// regexp works
	str = RemovePrefixFromListItem("[a-z]*", "a12;bcdf45", regExp = 1)
	ref = "12;45;"
	CHECK_EQUAL_STR(ref, str)
End

/// @}
