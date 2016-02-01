Attribute VB_Name = "Module6"
Option Explicit
Private Const CCDEVICENAME = 32
Private Const CCFORMNAME = 32
Private Const DM_BITSPERPEL = &H40000
Private Const DM_PELSWIDTH = &H80000
Private Const DM_PELSHEIGHT = &H100000
Private Const CDS_UPDATEREGISTRY = &H1
Private Const CDS_TEST = &H4
Private Const DISP_CHANGE_SUCCESSFUL = 0
Private Const DISP_CHANGE_RESTART = 1
Private Const BITSPIXEL = 12
Private Type DEVMODE
dmDeviceName As String * CCDEVICENAME
dmSpecVersion As Integer
dmDriverVersion As Integer
dmSize As Integer
dmDriverExtra As Integer
dmFields As Long
dmOrientation As Integer
dmPaperSize As Integer
dmPaperLength As Integer
dmPaperWidth As Integer
dmScale As Integer
dmCopies As Integer
dmDefaultSource As Integer
dmPrintQuality As Integer
dmColor As Integer
dmDuplex As Integer
dmYResolution As Integer
dmTTOption As Integer
dmCollate As Integer
dmFormName As String * CCFORMNAME
dmUnusedPadding As Integer
dmBitsPerPel As Integer
dmPelsWidth As Long
dmPelsHeight As Long
dmDisplayFlags As Long
dmDisplayFrequency As Long
End Type
Private Declare Function EnumDisplaySettings Lib "user32" Alias "EnumDisplaySettingsA" (ByVal lpszDeviceName As Long, ByVal iModeNum As Long, lpDevMode As Any) As Boolean
Private Declare Function ChangeDisplaySettings Lib "user32" Alias "ChangeDisplaySettingsA" (lpDevMode As Any, ByVal dwFlags As Long) As Long
Private Declare Function GetDeviceCaps Lib "gdi32" (ByVal hDC As Long, ByVal nIndex As Long) As Long
Private Declare Function CreateDC Lib "gdi32" Alias "CreateDCA" (ByVal lpDriverName As String, ByVal lpDeviceName As String, ByVal lpOutput As String, ByVal lpInitData As Any) As Long
Private Declare Function DeleteDC Lib "gdi32" (ByVal hDC As Long) As Long
Private oldx As Long, oldy As Long
Private Const MAX_PATH As Long = 260
Private Const MAX_PATH_UNICODE As Long = 260 * 2 - 1

Private Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

Private Type WIN32_FIND_DATA
dwFileAttributes As Long
ftCreationTime As FILETIME
ftLastAccessTime As FILETIME
ftLastWriteTime As FILETIME
nFileSizeHigh As Long
nFileSizeLow As Long
dwReserved0 As Long
dwReserved1 As Long
cFileName(MAX_PATH * 2 - 1) As Byte
cAlternate(14 * 2 - 1) As Byte
End Type
Private Declare Function FindFirstFile Lib "kernel32" Alias "FindFirstFileW" (ByVal lpFileName As Long, lpFindFileData As WIN32_FIND_DATA) As Long
Private Declare Function FindClose Lib "kernel32.dll" (ByVal hFindFile As Long) As Long

Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hwnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
'
Private Const GWL_WNDPROC = (-4)
Private Const WM_MOUSEWHEEL = &H20A
Private Const WM_MOUSELAST = &H20A
Private Const WM_MOUSEHWHEEL = &H20E
Public defWndProc As Long, defWndProc2 As Long
Public LastGlist As gList, LastGlist2 As gList
Public defWndProc3 As Long
Public LastGlist3 As gList
Public Sub Hook3(hwnd As Long, A As gList)
' work in IDE but for development and a fear...of a crash...

If m_bInIDE Then Exit Sub

   If defWndProc3 = 0 Then

      defWndProc3 = SetWindowLong(hwnd, _
                                 GWL_WNDPROC, _
                                 AddressOf WindowProc3)
                                 MyDoEvents
         If defWndProc3 = 0 Then Set LastGlist3 = Nothing
    End If
           Set LastGlist3 = A
End Sub
Public Sub UnHook3(hwnd As Long)
If m_bInIDE Then Exit Sub
    If defWndProc3 > 0 Then
    
      Call SetWindowLong(hwnd, GWL_WNDPROC, defWndProc3)
      defWndProc3 = 0
   End If
  
End Sub
Public Sub Hook2(hwnd As Long, A As gList)
' work in IDE but for development and a fear...of a crash...

If m_bInIDE Then Exit Sub

   If defWndProc2 = 0 Then

      defWndProc2 = SetWindowLong(hwnd, _
                                 GWL_WNDPROC, _
                                 AddressOf WindowProc2)
                                 MyDoEvents
         If defWndProc2 = 0 Then Set LastGlist2 = Nothing
    End If
           Set LastGlist2 = A
End Sub
Public Sub UnHook2(hwnd As Long)
If m_bInIDE Then Exit Sub
    If defWndProc2 > 0 Then
    
      Call SetWindowLong(hwnd, GWL_WNDPROC, defWndProc2)
      defWndProc2 = 0
   End If
  
End Sub

Public Sub Hook(hwnd As Long, A As gList)
' work in IDE but for development and a fear...of a crash...

If m_bInIDE Then Exit Sub

   If defWndProc = 0 Then

      defWndProc = SetWindowLong(hwnd, _
                                 GWL_WNDPROC, _
                                 AddressOf WindowProc)
                                 MyDoEvents
         If defWndProc = 0 Then Set LastGlist = Nothing
    End If
           Set LastGlist = A
End Sub
Public Sub UnHook(hwnd As Long)
If m_bInIDE Then Exit Sub
    If defWndProc > 0 Then
    
      Call SetWindowLong(hwnd, GWL_WNDPROC, defWndProc)
      defWndProc = 0
   End If
       
End Sub
Public Function WindowProc3(ByVal hwnd As Long, _
                           ByVal uMsg As Long, _
                           ByVal wParam As Long, _
                           ByVal lParam As Long) As Long
On Error GoTo there3:
   Select Case uMsg
         Case WM_MOUSEWHEEL
        Select Case Sgn(wParam)
        Case 1:

        If Not LastGlist3 Is Nothing Then
        
        With LastGlist3
        If .Spinner Then
        .Value = .Value - .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageUp, 0
        .CalcAndShowBar
        End If

        End With
        End If
        
        Case -1:
      
          If Not LastGlist3 Is Nothing Then
        With LastGlist3
        If .Spinner Then
        .Value = .Value + .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageDown, 0
        .CalcAndShowBar
        End If

        End With
        End If
        End Select
      Case Else
there3:
         WindowProc3 = CallWindowProc(defWndProc3, _
                                     hwnd, _
                                     uMsg, _
                                     wParam, _
                                     lParam)
   End Select
    
End Function
Public Function WindowProc2(ByVal hwnd As Long, _
                           ByVal uMsg As Long, _
                           ByVal wParam As Long, _
                           ByVal lParam As Long) As Long
On Error GoTo there2:
   Select Case uMsg
         Case WM_MOUSEWHEEL
        Select Case Sgn(wParam)
        Case 1:

        If Not LastGlist2 Is Nothing Then
        
        With LastGlist2
        If .Spinner Then
        .Value = .Value - .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageUp, 0
        .CalcAndShowBar
        End If

        End With
        End If
        
        Case -1:
      
          If Not LastGlist2 Is Nothing Then
        With LastGlist2
        If .Spinner Then
        .Value = .Value + .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageDown, 0
        .CalcAndShowBar
        End If

        End With
        End If
        End Select
      Case Else
there2:
         WindowProc2 = CallWindowProc(defWndProc2, _
                                     hwnd, _
                                     uMsg, _
                                     wParam, _
                                     lParam)
   End Select
    
End Function
Public Function WindowProc(ByVal hwnd As Long, _
                           ByVal uMsg As Long, _
                           ByVal wParam As Long, _
                           ByVal lParam As Long) As Long

   Select Case uMsg
         Case WM_MOUSEWHEEL
        Select Case Sgn(wParam)
        Case 1:

        If Not LastGlist Is Nothing Then
        
        With LastGlist
        If .Spinner Then
        .Value = .Value - .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageUp, 0
        .CalcAndShowBar
        End If

        End With
        End If
        
        Case -1:
      
          If Not LastGlist Is Nothing Then
        With LastGlist
        If .Spinner Then
        .Value = .Value + .smallchange
        Else
        .LargeBar1KeyDown vbKeyPageDown, 0
        .CalcAndShowBar
        End If

        End With
        End If
        End Select
      Case Else
      
         WindowProc = CallWindowProc(defWndProc, _
                                     hwnd, _
                                     uMsg, _
                                     wParam, _
                                     lParam)
   End Select
    
End Function
Public Function ExistFileT(A$, TIMESTAMP As Double) As Boolean
Dim WFD As WIN32_FIND_DATA
On Error GoTo there2
Dim fhandle As Long
fhandle = FindFirstFile(StrPtr(A$), WFD)
ExistFileT = (fhandle > 0)
If ExistFileT Then FindClose fhandle: TIMESTAMP = uintnew(WFD.ftLastAccessTime.dwLowDateTime)
Exit Function
there2:
End Function
Public Sub ChangeScreenRes(x As Long, y As Long)
' this is a modified version that i found in internet
Static Once As Boolean
Dim DevM As DEVMODE, erg As Long, BITS As Long, nDc As Long
On Error GoTo abort
If Not Once Then
oldx = ScrX() / Screen.TwipsPerPixelX
oldy = ScrY() / Screen.TwipsPerPixelY
Once = True
End If
nDc = CreateDC("DISPLAY", vbNullString, vbNullString, ByVal 0&)
BITS = GetDeviceCaps(nDc, BITSPIXEL)
erg = EnumDisplaySettings(0&, 0&, DevM)
DevM.dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL
DevM.dmPelsWidth = x
DevM.dmPelsHeight = y
DevM.dmBitsPerPel = BITS
erg = ChangeDisplaySettings(DevM, CDS_TEST)
DeleteDC nDc
abort:
End Sub
Sub StartingRes()
oldx = ScrX() / Screen.TwipsPerPixelX
oldy = ScrY() / Screen.TwipsPerPixelY
End Sub
Sub ScreenRestore()
Dim DevM As DEVMODE, erg As Long, BITS As Long, nDc As Long
If oldx * oldy = 0 Then Exit Sub
On Error GoTo abort
nDc = CreateDC("DISPLAY", vbNullString, vbNullString, ByVal 0&)
BITS = GetDeviceCaps(nDc, BITSPIXEL)
erg = EnumDisplaySettings(0&, 0&, DevM)
DevM.dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL
DevM.dmPelsWidth = oldx
DevM.dmPelsHeight = oldy
DevM.dmBitsPerPel = BITS
erg = ChangeDisplaySettings(DevM, CDS_TEST)
DeleteDC nDc
abort:
End Sub



