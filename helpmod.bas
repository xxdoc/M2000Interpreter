Attribute VB_Name = "helpmod"
Option Explicit
Global Const gstrSEP_DIR$ = "\"
Public Const gstrSEP_URLDIR$ = "/"
Public Type RECT1
        Left As Long
        top As Long
        Right As Long
        Bottom As Long
End Type
Public Const DC_ACTIVE = &H1
Public Const DC_ICON = &H4
Public Const DC_TEXT = &H8
Public Const BDR_SUNKENOUTER = &H2
Public Const BDR_RAISEDINNER = &H4
Public Const EDGE_ETCHED = (BDR_SUNKENOUTER Or BDR_RAISEDINNER)
Public Const BF_BOTTOM = &H8
Public Const BF_LEFT = &H1
Public Const BF_RIGHT = &H4
Public Const BF_TOP = &H2
Public Const BF_RECT = (BF_LEFT Or BF_TOP Or BF_RIGHT Or BF_BOTTOM)
Public Const DFC_BUTTON = 4
Public Const DFC_POPUPMENU = 5            'Only Win98/2000 !!
Public Const DFCS_BUTTON3STATE = &H10

Public Const DC_GRADIENT = &H20          'Only Win98/2000 !!
Public Declare Function FillRect Lib "user32" (ByVal hdc As Long, lpRect As RECT, ByVal hBrush As Long) As Long
Public Declare Function CreateSolidBrush Lib "gdi32" (ByVal crColor As Long) As Long
Public Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Public Declare Function SetTextColor Lib "gdi32" (ByVal hdc As Long, ByVal crColor As Long) As Long
Public Const OPAQUE = 2
Public Declare Function SetBkMode Lib "gdi32" (ByVal hdc As Long, ByVal nBkMode As Long) As Long
Public Declare Function DrawFrameControl Lib "user32" (ByVal hdc As Long, lpRect As RECT, ByVal un1 As Long, ByVal un2 As Long) As Long
Public Declare Function DrawText Lib "user32" Alias "DrawTextW" (ByVal hdc As Long, ByVal lpStr As Long, ByVal nCount As Long, lpRect As RECT, ByVal wFormat As Long) As Long
Public Declare Function SetRect Lib "user32" (lpRect As RECT, ByVal x1 As Long, ByVal Y1 As Long, ByVal x2 As Long, ByVal y2 As Long) As Long
Public Declare Function OffsetRect Lib "user32" (lpRect As RECT, ByVal X As Long, ByVal Y As Long) As Long

Public Const DT_BOTTOM As Long = &H8&
Public Const DT_CALCRECT As Long = &H400&
Public Const DT_CENTER As Long = &H1&
Public Const DT_EDITCONTROL As Long = &H2000&
Public Const DT_END_ELLIPSIS As Long = &H8000&
Public Const DT_EXPANDTABS As Long = &H40&
Public Const DT_EXTERNALLEADING As Long = &H200&
Public Const DT_HIDEPREFIX As Long = &H100000
Public Const DT_INTERNAL As Long = &H1000&
Public Const DT_LEFT As Long = &H0&
Public Const DT_MODIFYSTRING As Long = &H10000
Public Const DT_NOCLIP As Long = &H100&
Public Const DT_NOFULLWIDTHCHARBREAK As Long = &H80000
Public Const DT_NOPREFIX As Long = &H800&
Public Const DT_PATH_ELLIPSIS As Long = &H4000&
Public Const DT_PREFIXONLY As Long = &H200000
Public Const DT_RIGHT As Long = &H2&
Public Const DT_SINGLELINE As Long = &H20&
Public Const DT_TABSTOP As Long = &H80&
Public Const DT_TOP As Long = &H0&
Public Const DT_VCENTER As Long = &H4&
Public Const DT_WORDBREAK As Long = &H10&
Public Const DT_WORD_ELLIPSIS As Long = &H40000

Private Declare Function GetLogicalDriveStrings Lib "kernel32" _
  Alias "GetLogicalDriveStringsA" (ByVal nBufferLength As Long, _
  ByVal lpBuffer As String) As Long
   Private Declare Function GetComputerName Lib "kernel32" Alias "GetComputerNameW" (ByVal lpBuffer As Long, nSize As Long) As Long
 Private Declare Function GetDiskFreeSpace Lib "kernel32" _
 Alias "GetDiskFreeSpaceA" (ByVal lpRootPathName As String, _
 lpSectorsPerCluster As Long, lpBytesPerSector As Long, _
 lpNumberOfFreeClusters As Long, lpTtoalNumberOfClusters As Long) _
 As Long
 Function FreeDiskSpace(DriveLetter As String) As Double
' Returns the number of free bytes for a drive

    Dim SectorsPerCluster As Long
    Dim BytesPerSector As Long
    Dim NumberofFreeClusters As Long
    Dim TotalClusters As Long
    Dim Dletter, X
    Dletter = Left(DriveLetter, 1) & ":\"
    X = GetDiskFreeSpace(Dletter, SectorsPerCluster, _
      BytesPerSector, NumberofFreeClusters, TotalClusters)
    
    If X = 0 Then 'Error occurred
        FreeDiskSpace = -99 'Assign an arbitrary error value
        Exit Function
    End If
    FreeDiskSpace = _
      CDbl(SectorsPerCluster) * CDbl(BytesPerSector) * CDbl(NumberofFreeClusters) / (1024# * 1024#) * 0.975  '0.025% for the sysrem
End Function
    Function strMachineName() As String

  
    
    strMachineName = String(1000, Chr$(0))
    GetComputerName StrPtr(strMachineName), 1000
    strMachineName = Left$(strMachineName, InStr(1, strMachineName, Chr$(0)) - 1)
  
  End Function
Function NumberofDrives() As Integer
' Returns the number of drives
    
    Dim Buffer As String * 255
    Dim BuffLen As Long
    Dim DriveCount As Integer, i As Integer
   
    BuffLen = GetLogicalDriveStrings(Len(Buffer), Buffer)
    DriveCount = 0
' Search for a null -- which separates the drives
    For i = 1 To BuffLen
        If Asc(Mid(Buffer, i, 1)) = 0 Then _
          DriveCount = DriveCount + 1
    Next i
    NumberofDrives = DriveCount
End Function

Function DriveName(Index As Integer) As String
    
    Dim Buffer As String * 255
    Dim BuffLen As Long
    Dim TheDrive As String
    Dim DriveCount As Integer, i As Integer
   
    BuffLen = GetLogicalDriveStrings(Len(Buffer), Buffer)
    TheDrive = ""
    DriveCount = 0
    For i = 1 To BuffLen
        If Asc(Mid(Buffer, i, 1)) <> 0 Then _
          TheDrive = TheDrive & Mid(Buffer, i, 1)
        If Asc(Mid(Buffer, i, 1)) = 0 Then 'null separates drives
            DriveCount = DriveCount + 1
            If DriveCount = Index Then
                DriveName = UCase(Left(TheDrive, 1))
                Exit Function
            End If
            TheDrive = ""
        End If
    Next i
End Function
Public Function FindNetworkFoldersNames() As String
Dim all As String
Const NET_HOOD = &H13&
Dim oshell, ofile, oFolder
Set oshell = CreateObject("Shell.Application")
If Not oshell Is Nothing Then
Set oFolder = oshell.NameSpace(NET_HOOD)
For Each ofile In oFolder.ITEMS
If ofile.name = "" Then
If all = "" Then
all = "(" + ofile.GetLink.path + ")"
Else
     all = all + vbCrLf + "(" + ofile.GetLink.path + ")"
     End If

Else
If all = "" Then
all = "(" + ofile.name + ")"
Else
     all = all + vbCrLf + "(" + ofile.name + ")"
     End If
     End If
Next
If all <> "" Then
FindNetworkFoldersNames = all + vbCrLf
End If
End If

End Function
Public Function FindNetworkFolderPath(ByVal giveAname As String) As String

If Left(giveAname, 1) = "(" And (Len(giveAname) > 2) Then
giveAname = Mid$(giveAname, 2, Len(giveAname) - 2)
End If
If Left$(giveAname, 2) = "\\" Then
FindNetworkFolderPath = giveAname
Exit Function
End If
Dim oshell, ofile, oFolder
Const NET_HOOD = &H13&
Set oshell = CreateObject("Shell.Application")
If Not oshell Is Nothing Then
Set oFolder = oshell.NameSpace(NET_HOOD)

For Each ofile In oFolder.ITEMS
If ofile.name = giveAname Then
FindNetworkFolderPath = ofile.GetLink.path
Exit For
End If
Next ofile
End If

End Function
Public Function getIP()

Dim WMI     As Object
Dim qryWMI  As Object
Dim item    As Variant

    Set WMI = GetObject("winmgmts:\\.\root\cimv2")

    Set qryWMI = WMI.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration " & _
                               "WHERE IPEnabled = True")

    For Each item In qryWMI
      getIP = item.IPAddress(0)
    Next

    Set WMI = Nothing
    Set qryWMI = Nothing

End Function
Public Sub showmodules()
If Not Form1.EditTextWord Then
fHelp basestack1, "", DialogLang = 1
Else
Beep
End If
End Sub
