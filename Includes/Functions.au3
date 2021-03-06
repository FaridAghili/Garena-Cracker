#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <GDIPlus.au3>
#include <Memory.au3>
#include <WinAPIRes.au3>
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

Func Debug($sOutput, $iScriptLineNumber)
	Local $sDateTime = StringFormat('%04u-%02u-%02u %02u:%02u:%02u', @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	Local $sError = StringFormat('[%s] %u: %s\r\n', $sDateTime, $iScriptLineNumber, $sOutput)

	If @Compiled Then
		Local $hFile = FileOpen(@ScriptDir & '\Errors.txt', $FO_APPEND)
		FileWrite($hFile, $sError)
		FileClose($hFile)
	Else
		ConsoleWrite('!' & $sError)
	EndIf
EndFunc

Func GetStringSize($sText, $iSize, $iWeight, $iAttribute, $sName)
	Local $hDC = _WinAPI_GetDC(Null)
	If $hDC Then
		; --- Nothing to do
	Else
		Return SetError(1, 0, Null)
	EndIf

	Local $iInfo = _WinAPI_GetDeviceCaps($hDC, $LOGPIXELSY)
	If $iInfo Then
		; --- Nothing to do
	Else
		_WinAPI_ReleaseDC(Null, $hDC)
		Return SetError(2, 0, Null)
	EndIf

	Local $hFont = _WinAPI_CreateFont(-$iInfo * $iSize / 72, 0, 0, 0, $iWeight, BitAND($iAttribute, 2), BitAND($iAttribute, 4), BitAND($iAttribute, 8), 0, 0, 0, 5, 0, $sName)
	If $hFont Then
		; --- Nothing to do
	Else
		_WinAPI_ReleaseDC(Null, $hDC)
		Return SetError(3, 0, Null)
	EndIf

	Local $hPreviousFont = _WinAPI_SelectObject($hDC, $hFont)
	If $hPreviousFont <= 0 Then
		_WinAPI_DeleteObject($hFont)
		_WinAPI_ReleaseDC(Null, $hDC)
		Return SetError(4, 0, Null)
	EndIf

	Local $tSize = _WinAPI_GetTextExtentPoint32($hDC, $sText)
	If @error Then
		_WinAPI_SelectObject($hDC, $hPreviousFont)

		_WinAPI_DeleteObject($hFont)
		_WinAPI_ReleaseDC(Null, $hDC)
		Return SetError(5, 0, Null)
	EndIf

	_WinAPI_SelectObject($hDC, $hPreviousFont)

	_WinAPI_DeleteObject($hFont)
	_WinAPI_ReleaseDC(Null, $hDC)

	Local $avSizeInfo[] = [$sText, DllStructGetData($tSize, 'X'), DllStructGetData($tSize, 'Y')]
	Return $avSizeInfo
EndFunc

Func GUICtrlCreatePicEx($sResourceName, $iX, $iY, $iWidth, $iHeight, $iStyle = -1, $iExStyle = -1)
	Local $hBitmap = 0, $hPreviousBitmap = 0
	Local $iCtrlId = 0

	If @Compiled Then
		Local $hModule = _WinAPI_GetModuleHandle(Null)
		If $hModule Then
			; --- Nothing to do
		Else
			Return SetError(1, 0, 0)
		EndIf

		Local $hResourceInfo = _WinAPI_FindResource($hModule, $RT_RCDATA, $sResourceName)
		If $hResourceInfo Then
			; --- Nothing to do
		Else
			Return SetError(2, 0, 0)
		EndIf

		Local $hResourceData = _WinAPI_LoadResource($hModule, $hResourceInfo)
		If $hResourceData Then
			; --- Nothing to do
		Else
			Return SetError(3, 0, 0)
		EndIf

		Local $pResourceData = _WinAPI_LockResource($hResourceData)
		If $pResourceData Then
			; --- Nothing to do
		Else
			Return SetError(4, 0, 0)
		EndIf

		Local $iResourceSize = _WinAPI_SizeOfResource($hModule, $hResourceInfo)
		If $iResourceSize Then
			; --- Nothing to do
		Else
			Return SetError(5, 0, 0)
		EndIf

		Local $hMemory = _MemGlobalAlloc($iResourceSize, $GMEM_MOVEABLE)
		If $hMemory Then
			; --- Nothing to do
		Else
			Return SetError(6, 0, 0)
		EndIf

		Local $pMemory = _MemGlobalLock($hMemory)
		If $pMemory Then
			; --- Nothing to do
		Else
			_MemGlobalFree($hMemory)
			Return SetError(7, 0, 0)
		EndIf

		_MemMoveMemory($pResourceData, $pMemory, $iResourceSize)
		If @error Then
			_MemGlobalUnlock($hMemory)
			_MemGlobalFree($hMemory)
			Return SetError(8, 0, 0)
		EndIf

		_MemGlobalUnlock($hMemory)

		Local $pStream = _WinAPI_CreateStreamOnHGlobal($hMemory)
		If $pStream Then
			; --- Nothing to do
		Else
			_MemGlobalFree($hMemory)
			Return SetError(9, 0, 0)
		EndIf

		Local $hBitmapFromStream = _GDIPlus_BitmapCreateFromStream($pStream)
		If $hBitmapFromStream Then
			; --- Nothing to do
		Else
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
			Return SetError(10, 0, 0)
		EndIf

		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmapFromStream)
		If $hBitmap Then
			; --- Nothing to do
		Else
			_GDIPlus_BitmapDispose($hBitmapFromStream)
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
			Return SetError(11, 0, 0)
		EndIf

		$iCtrlId = GUICtrlCreatePic('', $iX, $iY, $iWidth, $iHeight, $iStyle, $iExStyle)
		If $iCtrlId Then
			; --- Nothing to do
		Else
			_WinAPI_DeleteObject($hBitmap)
			_GDIPlus_BitmapDispose($hBitmapFromStream)
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
		EndIf

		$hPreviousBitmap = GUICtrlSendMsg($iCtrlId, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
		If $hPreviousBitmap Then
			_WinAPI_DeleteObject($hPreviousBitmap)
		EndIf

		_WinAPI_DeleteObject($hBitmap)
		_GDIPlus_BitmapDispose($hBitmapFromStream)
		_WinAPI_ReleaseStream($pStream)
		_MemGlobalFree($hMemory)

		Return $iCtrlId
	Else
		Local $hImage = _GDIPlus_ImageLoadFromFile('Resources\' & $sResourceName & '.png')
		If @error Then
			Return SetError(1, 0, 0)
		EndIf

		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
		If @error Then
			_GDIPlus_ImageDispose($hImage)
			Return SetError(2, 0, 0)
		EndIf

		_GDIPlus_ImageDispose($hImage)

		$iCtrlId = GUICtrlCreatePic('', $iX, $iY, $iWidth, $iHeight, $iStyle, $iExStyle)

		$hPreviousBitmap = GUICtrlSendMsg($iCtrlId, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
		If $hPreviousBitmap Then
			_WinAPI_DeleteObject($hPreviousBitmap)
		EndIf

		_WinAPI_DeleteObject($hBitmap)

		Return $iCtrlId
	EndIf
EndFunc

Func IsDotNetFramework4Installed()
	If RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client\1033', 'Install') = 1 Then
		Return True
	EndIf

	If RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033', 'Install') = 1 Then
		Return True
	EndIf

	Return False
EndFunc

Func RunAutoItScript($sHostPath, $sScriptPath, $sCommandLine, $sWorkingDirectory)
	Return Run('"' & $sHostPath & '" /AutoIt3ExecuteScript "' & $sScriptPath & '" ' & $sCommandLine, $sWorkingDirectory)
EndFunc