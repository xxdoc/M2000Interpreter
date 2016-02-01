Attribute VB_Name = "gpp1"
Option Explicit
Public pw As Long, ph As Long, psw As Long, psh As Long, pwox As Long, phoy As Long, mydpi As Long

      Private Type DOCINFO
          cbSize As Long
          lpszDocName As String
          lpszOutput As String
      End Type
            Private Declare Function StartDoc Lib "gdi32" Alias "StartDocA" _
          (ByVal hDC As Long, lpdi As DOCINFO) As Long

      Private Declare Function StartPage Lib "gdi32" (ByVal hDC As Long) _
          As Long

      Private Declare Function EndDoc Lib "gdi32" (ByVal hDC As Long) _
          As Long

      Private Declare Function EndPage Lib "gdi32" (ByVal hDC As Long) _
          As Long
Private mp_hdc As Long
Public MyDM() As Byte
Private Const PHYSICALOFFSETX As Long = 112
Private Const PHYSICALOFFSETY As Long = 113
Private Const HORZRES As Long = 8
Private Const VERTRES As Long = 10
Private Const PHYSICALHEIGHT As Long = 111
Private Const PHYSICALWIDTH As Long = 110
Private Const LOGPIXELSX = 88
Private Const LOGPIXELSY = 90

Private Declare Function GetDeviceCaps Lib "gdi32" (ByVal hDC As Long, ByVal iCapabilitiy As Long) As Long

      Private Declare Function ResetDC Lib "gdi32" Alias "ResetDCA" _
          (ByVal hDC As Long, lpInitData As Any) As Long
Private Declare Function CreateIC Lib "gdi32" Alias "CreateICA" _
          (ByVal lpDriverName As String, ByVal lpDeviceName As String, _
          ByVal lpOutput As String, lpInitData As Any) As Long

      'Private Declare Function CreateDC Lib "gdi32" Alias "CreateDCA" _
          (ByVal lpDriverName As String, ByVal lpDeviceName As String, _
          ByVal lpOutput As Long, ByVal lpInitData As Long) As Long
      Private Declare Function CreateDC Lib "gdi32" Alias "CreateDCA" _
          (ByVal lpDriverName As String, ByVal lpDeviceName As String, _
          ByVal lpOutput As Long, lpInitData As Any) As Long
      Private Declare Function DeleteDC Lib "gdi32" (ByVal hDC As Long) _
          As Long
      Private Const NULLPTR = 0&
      ' Constants for DEVMODE
      Private Const CCHDEVICENAME = 32
      Private Const CCHFORMNAME = 32
      ' Constants for DocumentProperties
      Private Const DM_MODIFY = 8
      Private Const DM_COPY = 2
      Private Const DM_IN_BUFFER = DM_MODIFY
      Private Const DM_OUT_BUFFER = DM_COPY
      Private Const DM_PROMPT = 4  'DM_IN_PROMPT = 0x04

      ' Constants for dmOrientation
      Private Const DM_ORIENTATION = &H1&
      Private Const DMORIENT_PORTRAIT = 1
      Private Const DMORIENT_LANDSCAPE = 2
      ' Constants for dmPrintQuality
      Private Const DMRES_DRAFT = (-1)
      Private Const DMRES_HIGH = (-4)
      Private Const DMRES_LOW = (-2)
      Private Const DMRES_MEDIUM = (-3)
      ' Constants for dmTTOption
      Private Const DMTT_BITMAP = 1
      Private Const DMTT_DOWNLOAD = 2
      Private Const DMTT_DOWNLOAD_OUTLINE = 4
      Private Const DMTT_SUBDEV = 3
      ' Constants for dmColor
      Private Const DMCOLOR_COLOR = 2
      Private Const DMCOLOR_MONOCHROME = 1
      ' Constants for dmCollate
      Private Const DMCOLLATE_FALSE = 0
      Private Const DMCOLLATE_TRUE = 1
      Private Const DM_COLLATE As Long = &H8000
      ' Constants for dmDuplex
      Private Const DM_DUPLEX = &H1000&
      Private Const DMDUP_HORIZONTAL = 3
      Private Const DMDUP_SIMPLEX = 1
      Private Const DMDUP_VERTICAL = 2

      Private Type DEVMODE
          dmDeviceName(1 To CCHDEVICENAME) As Byte
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
          dmFormName(1 To CCHFORMNAME) As Byte
          dmUnusedPadding As Integer
          dmBitsPerPel As Integer
          dmPelsWidth As Long
          dmPelsHeight As Long
          dmDisplayFlags As Long
          dmDisplayFrequency As Long
        dmPAD As String * 26
      End Type
      Private Const PRINTER_ACCESS_ADMINISTER As Long = &H4
Private Const PRINTER_ACCESS_USE As Long = &H8
Private Const STANDARD_RIGHTS_REQUIRED As Long = &HF0000
Private Const PRINTER_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED _
    Or _
    PRINTER_ACCESS_ADMINISTER Or PRINTER_ACCESS_USE)

Private Type PRINTER_DEFAULTS
        pDataType As String
        pDevMode As Long
        DesiredAccess As Long
End Type
      Private Declare Function OpenPrinter Lib "winspool.drv" Alias _
      "OpenPrinterA" (ByVal pPrinterName As String, phPrinter As Long, _
     pDefault As Any) As Long

      Private Declare Function DocumentProperties Lib "winspool.drv" _
      Alias "DocumentPropertiesA" (ByVal hWnd As Long, _
      ByVal hPrinter As Long, ByVal pDeviceName As String, _
       pDevModeOutput As Any, pDevModeInput As Any, ByVal fMode As Long) As Long

      Private Declare Function ClosePrinter Lib "winspool.drv" _
      (ByVal hPrinter As Long) As Long

      Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" _
      (hpvDest As Any, hpvSource As Any, ByVal cbCopy As Long)
      Private Declare Function GlobalLock Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare Function GlobalUnlock Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare Function GlobalAlloc Lib "kernel32" (ByVal wFlags As Long, ByVal dwBytes As Long) As Long
Private Declare Function GlobalFree Lib "kernel32" (ByVal hMem As Long) As Long
Const GMEM_MOVEABLE = &H2
Const GMEM_ZEROINIT = &H40

Sub CopiesCount(c As Long, dm() As Byte)
Dim pDevMode As DEVMODE
        Call CopyMemory(pDevMode, dm(1), Len(pDevMode))
        pDevMode.dmCopies = c
        
         Call CopyMemory(dm(1), pDevMode, Len(pDevMode))
End Sub


      Function StripNulls(OriginalStr As String) As String
         If (InStr(OriginalStr, Chr(0)) > 0) Then
            OriginalStr = Left(OriginalStr, InStr(OriginalStr, Chr(0)) - 1)
         End If
         StripNulls = Trim(OriginalStr)
      End Function

      Function ByteToString(ByteArray() As Byte) As String
        Dim TempStr As String
        Dim i As Integer

        For i = 1 To CCHDEVICENAME
            TempStr = TempStr & Chr(ByteArray(i))
        Next i
        ByteToString = StripNulls(TempStr)
      End Function

      Function ShowProperties(f As Object, szPrinterName As String, adevmode() As Byte) As Boolean
      Dim hPrinter As Long, i As Long
      Dim nsize As Long
     '' Dim pDevMode As DEVMODE
     ' Dim adevmode() As Byte
      Dim TempStr As String, oldfields As Long
      Dim pd As PRINTER_DEFAULTS
      pd.DesiredAccess = PRINTER_ACCESS_USE
        If OpenPrinter(szPrinterName, hPrinter, pd) <> 0 Then
           nsize = DocumentProperties(NULLPTR, hPrinter, szPrinterName, NULLPTR, NULLPTR, 0)
          ' Form1.Caption = nSize
          If nsize < 1 Then
            ShowProperties = False
            Exit Function
          End If
          If UBound(adevmode) <> nsize + 100 Then
         ReDim adevmode(1 To nsize + 100) As Byte
         
           nsize = DocumentProperties(NULLPTR, hPrinter, szPrinterName, adevmode(1), ByVal NULLPTR, DM_OUT_BUFFER)
          
          If nsize < 0 Then
            ShowProperties = False
            Exit Function
          End If
   
      ''Call CopyMemory(pDevMode, adevmode(1), Len(pDevMode))
''  if you need to check fileds for any bit use these copies to do the check.
        
      '' Call CopyMemory(adevmode(1), pDevMode, Len(pDevMode))
   End If
         If Not f Is Nothing Then
          nsize = DocumentProperties(f.hWnd, hPrinter, szPrinterName, adevmode(1), adevmode(1), DM_PROMPT Or DM_IN_BUFFER Or DM_OUT_BUFFER)  '
         Else
         nsize = DocumentProperties(0, hPrinter, szPrinterName, adevmode(1), adevmode(1), DM_IN_BUFFER Or DM_OUT_BUFFER)
        End If

       ''  Call CopyMemory(pDevMode, adevmode(1), Len(pDevMode))
          
 On Error Resume Next

                
         Call ClosePrinter(hPrinter)
         ShowProperties = True
      Else
         ShowProperties = False
      End If
      End Function

Sub PrinterDim(pw As Long, ph As Long, psw As Long, psh As Long, lpx As Long, lpy As Long)
          Dim Ret As Long
          Dim LastError As Long
          Dim dummy3 As Object
       '   If mp_hdc <> 0 Then Exit Sub
          
If UBound(MyDM) = 1 Then
ShowProperties dummy3, Printer.DeviceName, MyDM
End If
 Dim pDevMode As Long
        pDevMode = GlobalLock(VarPtr(MyDM(1)))
          mp_hdc = CreateIC(Printer.DriverName, Printer.DeviceName, 0, ByVal pDevMode)

pw = GetDeviceCaps(mp_hdc, PHYSICALWIDTH)
ph = GetDeviceCaps(mp_hdc, PHYSICALHEIGHT)
psw = GetDeviceCaps(mp_hdc, HORZRES)
psh = GetDeviceCaps(mp_hdc, VERTRES)
lpx = GetDeviceCaps(mp_hdc, LOGPIXELSX)
lpy = GetDeviceCaps(mp_hdc, LOGPIXELSY)

          Ret = DeleteDC(mp_hdc)
          pDevMode = GlobalUnlock(pDevMode)
          mp_hdc = 0
End Sub

Function PrinterCap(Cap As Long) As Long
        Dim p_hdc As Long
          Dim Ret As Long
          Dim LastError As Long
          Dim dummy3 As Object
        If UBound(MyDM) = 1 Then
            ShowProperties dummy3, Printer.DeviceName, MyDM
        End If
          
          p_hdc = CreateIC(Printer.DriverName, Printer.DeviceName, 0, MyDM(1))
PrinterCap = GetDeviceCaps(p_hdc, Cap)
Ret = DeleteDC(p_hdc)
End Function

Function ChangeOrientation(f As Object, szPrinterName As String, adevmode() As Byte) As Boolean
      Dim hPrinter As Long, i As Long
      Dim nsize As Long
      Dim pDevMode As DEVMODE
      Dim TempStr As String, oldfields As Long
      Dim pd As PRINTER_DEFAULTS
      pd.DesiredAccess = PRINTER_ACCESS_USE
        If OpenPrinter(szPrinterName, hPrinter, pd) <> 0 Then
           nsize = DocumentProperties(NULLPTR, hPrinter, szPrinterName, _
           NULLPTR, NULLPTR, 0)
          If nsize < 1 Then
            ChangeOrientation = False
            Exit Function
          End If
          If UBound(adevmode) <> nsize Then
         ReDim adevmode(1 To nsize) As Byte
         
           nsize = DocumentProperties(NULLPTR, hPrinter, szPrinterName, adevmode(1), ByVal NULLPTR, DM_OUT_BUFFER)
          
          If nsize < 0 Then
            ChangeOrientation = False
            Exit Function
          End If
   
   End If
         If Not f Is Nothing Then
          nsize = DocumentProperties(f.hWnd, hPrinter, szPrinterName, adevmode(1), adevmode(1), DM_PROMPT Or DM_OUT_BUFFER Or DM_IN_BUFFER)
         Else

      
     Call CopyMemory(pDevMode, adevmode(1), Len(pDevMode))
    pDevMode.dmOrientation = 3 - pDevMode.dmOrientation
    
     Call CopyMemory(adevmode(1), pDevMode, Len(pDevMode))
      
      
         nsize = DocumentProperties(0, hPrinter, szPrinterName, adevmode(1), adevmode(1), DM_IN_BUFFER Or DM_OUT_BUFFER)
        End If

         Call CopyMemory(pDevMode, adevmode(1), Len(pDevMode))
          
 On Error Resume Next

         Call ClosePrinter(hPrinter)
         ChangeOrientation = True
      Else
         ChangeOrientation = False
      End If
      End Function


Function propA(dm() As Byte) As Long
Dim pDevMode As DEVMODE
        Call CopyMemory(pDevMode, dm(1), Len(pDevMode))
        'pDevMode.dmOrientation = 3 - pDevMode.dmOrientation
     propA = pDevMode.dmDriverExtra
     
     
         Call CopyMemory(dm(1), pDevMode, Len(pDevMode))
         
End Function
Function lookOr(dm() As Byte) As Integer
Dim pDevMode As DEVMODE
        Call CopyMemory(pDevMode, dm(1), Len(pDevMode))
       lookOr = pDevMode.dmOrientation
        
         'Call CopyMemory(dm(1), pDevMode, Len(pDevMode))
End Function
Public Sub associate(EXT As String, FileType As String, _
  ByVal FileName As String)
On Error Resume Next
FileName = mylcasefILE(FileName)
Dim b As Object
Set b = CreateObject("wscript.shell")
EXT = "." & Replace(UCase(EXT), ".", "")
If FileName = "" Then Exit Sub
b.regwrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" & ExtractNameOnly(FileName), FileName
b.regwrite "HKCR\" & EXT & "\", FileType
b.regwrite "HKCR\" & FileType & "\", EXT & " M2000 file"  'EXT & "_auto_file"
b.regwrite "HKCR\" & FileType & "\DefaultIcon\", FileName & ",0"
b.regwrite "HKCR\" & FileType & "\shell\open\command\", FileName & " ""%1"" "
b.regwrite "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\", EXT & " M2000 file"
b.regwrite "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\DefaultIcon\", FileName & ",0"
b.regwrite "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\shell\open\command\", FileName & " ""%1"" "
b.regwrite "HKCR\Applications\" & FileType & "\shell\open\command\", FileName & " ""&l"" "
b.regdelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\Application"
b.regwrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\Application", FileName
b.regdelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\OpenWithList\"
b.regwrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\OpenWithList\", FileName

End Sub
Public Sub deassociate(EXT As String, FileType As String, _
  ByVal FileName As String)
On Error Resume Next
FileName = mylcasefILE(FileName)
Dim b As Object
Set b = CreateObject("wscript.shell")
EXT = "." & ReplaceStr(".", "", EXT)
If FileName = "" Then Exit Sub
b.regdelete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" & ExtractNameOnly(FileName)
b.regdelete "HKCR\" & EXT & "\" ', FileType
b.regdelete "HKCR\" & FileType & "\shell\open\command\" ', Filename & " ""&l"" "
b.regdelete "HKCR\" & FileType & "\DefaultIcon\" ', Filename & ",0"
b.regdelete "HKCR\" & FileType & "\" ', EXT * " file"
b.regdelete "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\shell\open\command\" ', Filename & " ""&l"" "
b.regdelete "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\DefaultIcon\" ', Filename & ",0"
b.regdelete "HKLM\SOFTWARE\Classes\" & ExtractName(FileName) & "\" ', EXT * " file"
b.regdelete "HKCR\Applications\" & FileType & "\shell\open\command\" ', Filename & " ""&l"" "
b.regdelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\Application"
b.regdelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & EXT & "\OpenWithList\"

End Sub
Function signlong(ByVal a As Double) As Double
If a < 0 Then a = 0
If a > 4294967295# Then a = 4294967295#
If a > CDbl(2147483647) Then
signlong = ((CDbl(&H80000000) + a) + CDbl(&H80000000)) ' And &HFFFFFFFF
Else
signlong = a
End If
End Function
Function uintnew(ByVal a As Double) As Double
If a > CDbl(2147483647) Then a = CDbl(2147483647)
If a < CDbl(-2147483648#) Then a = CDbl(-2147483648#)
If a < 0 Then
uintnew = CDbl(&H7FFFFFFF) + (CDbl(&H7FFFFFFF) + a) + 2
Else
uintnew = a
End If
End Function
Function UINT(ByVal a As Long) As Long '����� ���� integer ��� unsign integer �� long
 Dim b As Long
 b = a And &HFFFF
 If b < 0 Then
 UINT = CLng(&H10000 + b)
 Else
 UINT = CLng(b)
 End If
 
 End Function
 
Function cUint(ByVal a As Long) As Long ' ������ ���� unsign integer ��� ��� ����� ������ ����� ������ ��� bits
Dim c As Long

c = Abs(a) And &HFFFF&
If c > 32767 Then
cUint = CInt(c - &H10000)
Else
cUint = CInt(c)
End If

End Function
Function LowWord(a As Long) As Long
Const bb = 65535
LowWord = cUint(CLng(bb And a))
End Function
Function HighLow(h As Long, l As Long) As Long
Const bb = 65536
HighLow = h * bb + l
End Function
Function HighWord(a As Long) As Long
Dim b As Double
b = a
Const bb = 65536
HighWord = Int(b / bb)
End Function
Function cUlng(ByVal a As Double) As Long ' ������ ���� unsign integer ��� ��� ����� ������ ����� ������ ��� bits
On Error GoTo cu1
a = Abs(Int(a))
If a > CDbl(2147483647#) Then
cUlng = a - 4294967296#
Else
cUlng = CLng(a)
End If
Exit Function
cu1:
cUlng = 0
End Function
Function Sput(ByVal Sl As String) As String
' ����������� �� ������ �� 2, ��� ���� �� ������� �� Unsign Hex
Sput = Chr(2) + Right$("00000000" & Hex$(cUlng(CDbl(Len(Sl)))), 8) + Sl
End Function

Function PACKLNG$(ByVal a As Double)
PACKLNG$ = Right$("00000000" & Hex$(cUlng(a)), 8)
End Function
Function PACKLNG2$(ByVal a As Double)  ' with error return..
' this if only for print
On Error GoTo cu22
Dim internal As Long
a = Int(a)
If a > 4294967296# Then
PACKLNG2$ = "???+"
ElseIf a < 0 Then
' error
PACKLNG2$ = "???-"
Else
    If a > CDbl(2147483647#) Then
    internal = a - 4294967296#
    Else
    internal = CLng(a)
    End If

If internal <= 65535 And internal >= 0 Then
PACKLNG2$ = "0x" + Right$("0000" & Hex$(internal), 4)
Else
PACKLNG2$ = "0x" + Right$("00000000" & Hex$(internal), 8)
End If
End If
Exit Function
cu22:
PACKLNG2$ = "?????"
End Function
Function UNPACKLNG(ByVal s$) As Long
If Len(s$) < 8 Then s$ = Right$("00000000" & s$, 8)
If Left$(s$, 4) = "0000" Then
UNPACKLNG = UINT(Val("&H" & s$))
Else
UNPACKLNG = cUlng(Val("&H" & s$))
End If
End Function

Function ORGAN(a As Long) As String
Select Case a
Case 1
ORGAN = "Acoustic Grand Piano"
Case 2
ORGAN = "Bright Acoustic Piano"
Case 3
ORGAN = "Electric Grand Piano"
Case 4
ORGAN = "Honky-tonk Piano"
Case 5
ORGAN = "Electric Piano 1"
Case 6
ORGAN = "Electric Piano 2"
Case 7
ORGAN = "Harpsichord"
Case 8
ORGAN = "Clavinet"
Case 9
ORGAN = "Celesta"
Case 10
ORGAN = "Glockenspiel"
Case 11
ORGAN = "Music Box"
Case 12
ORGAN = "Vibraphone"
Case 13
ORGAN = "Marimba"
Case 14
ORGAN = "Xylophone"
Case 15
ORGAN = "Tubular Bells"
Case 16
ORGAN = "Dulcimer"
Case 17
ORGAN = "Drawbar Organ"
Case 18
ORGAN = "Percussive Organ"
Case 19
ORGAN = "Rock Organ"
Case 20
ORGAN = "Church Organ"
Case 21
ORGAN = "Reed Organ"
Case 22
ORGAN = "Accordion"
Case 23
ORGAN = "Harmonica"
Case 24
ORGAN = "Tango Accordion"
Case 25
ORGAN = "Acoustic Guitar(nylon)"
Case 26
ORGAN = "Acoustic Guitar(Steel)"
Case 27
ORGAN = "Electric Guitar(jazz)"
Case 28
ORGAN = "Electric Guitar(clean)"
Case 29
ORGAN = "Electric Guitar(Muted)"
Case 30
ORGAN = "Overdriven Guitar"
Case 31
ORGAN = "Distortion Guitar"
Case 32
ORGAN = "Guitar harmonics"
Case 33
ORGAN = "Acoustic Bass"
Case 34
ORGAN = "Electric Bass(finger)"
Case 35
ORGAN = "Electric Bass(pick)"
Case 36
ORGAN = "Fretless Bass"
Case 37
ORGAN = "Slap Bass 1"
Case 38
ORGAN = "Slap Bass 2"
Case 39
ORGAN = "Synth Bass 1"
Case 40
ORGAN = "Synth Bass 2"
Case 41
ORGAN = "Violin"
Case 42
ORGAN = "Viola"
Case 43
ORGAN = "Cello"
Case 44
ORGAN = "Contrabass"
Case 45
ORGAN = "Tremolo Strings"
Case 46
ORGAN = "Pizzicato Strings"
Case 47
ORGAN = "Orchestral Harp"
Case 48
ORGAN = "Timpani"
Case 49
ORGAN = "String Ensemble 1"
Case 50
ORGAN = "String Ensemble 2"
Case 51
ORGAN = "Synth Strings 1"
Case 52
ORGAN = "Synth Strings 2"
Case 53
ORGAN = "Choir Aahs"
Case 54
ORGAN = "Voice Oohs"
Case 55
ORGAN = "Synth Voice"
Case 56
ORGAN = "Orchestra Hit"
Case 57
ORGAN = "Trumpet"
Case 58
ORGAN = "Trombone"
Case 59
ORGAN = "Tuba"
Case 60
ORGAN = "Muted Trumpet"
Case 61
ORGAN = "French Horn"
Case 62
ORGAN = "Brass Section"
Case 63
ORGAN = "Synth Brass 1"
Case 64
ORGAN = "Synth Brass 2"
Case 65
ORGAN = "Soprano Sax"
Case 66
ORGAN = "Alto Sax"
Case 67
ORGAN = "Tenor Sax"
Case 68
ORGAN = "Baritone Sax"
Case 69
ORGAN = "Oboe"
Case 70
ORGAN = "English Horn"
Case 71
ORGAN = "Bassoon"
Case 72
ORGAN = "Clarinet"
Case 73
ORGAN = "Piccolo"
Case 74
ORGAN = "Flute"
Case 75
ORGAN = "Recorder"
Case 76
ORGAN = "Pan Flute"
Case 77
ORGAN = "Blown Bottle"
Case 78
ORGAN = "Shakuhachi"
Case 79
ORGAN = "Whistle"
Case 80
ORGAN = "Ocarina"
Case 81
ORGAN = "Lead 1 (square)"
Case 82
ORGAN = "Lead 2 (sawtooth)"
Case 83
ORGAN = "Lead 3 (calliope)"
Case 84
ORGAN = "Lead 4 (chiff)"
Case 85
ORGAN = "Lead 5 (charang)"
Case 86
ORGAN = "Lead 6 (voice)"
Case 87
ORGAN = "Lead 7 (fifths)"
Case 88
ORGAN = "Lead 8 (bass + lead)"
Case 89
ORGAN = "Pad 1 (new age)"
Case 90
ORGAN = "Pad 2 (warm)"
Case 91
ORGAN = "Pad 3 (polysynth)"
Case 92
ORGAN = "Pad 4 (choir)"
Case 93
ORGAN = "Pad 5 (bowed)"
Case 94
ORGAN = "Pad 6 (metallic)"
Case 95
ORGAN = "Pad 7 (halo)"
Case 96
ORGAN = "Pad 8 (sweep)"
Case 97
ORGAN = "FX 1 (rain)"
Case 98
ORGAN = "FX 2 (soundtrack)"
Case 99
ORGAN = "FX 3 (crystal)"
Case 100
ORGAN = "FX 4 (atmosphere)"
Case 101
ORGAN = "FX 5 (brightness)"
Case 102
ORGAN = "FX 6 (goblins)"
Case 103
ORGAN = "FX 7 (echoes)"
Case 104
ORGAN = "FX 8 (sci-fi)"
Case 105
ORGAN = "Sitar"
Case 106
ORGAN = "Banjo"
Case 107
ORGAN = "Shamisen"
Case 108
ORGAN = "Koto"
Case 109
ORGAN = "Kalimba"
Case 110
ORGAN = "Bag Pipe"
Case 111
ORGAN = "Fiddle"
Case 112
ORGAN = "Shanai"
Case 113
ORGAN = "Tinkle Bell"
Case 114
ORGAN = "Agogo"
Case 115
ORGAN = "Steel Drums"
Case 116
ORGAN = "Woodblock"
Case 117
ORGAN = "Taiko Drum"
Case 118
ORGAN = "Melodic Tom"
Case 119
ORGAN = "Synth Drum"
Case 120
ORGAN = "Reverse Cymbal"
Case 121
ORGAN = "Guitar Fret Noise"
Case 122
ORGAN = "Breath Noise"
Case 123
ORGAN = "Seashore"
Case 124
ORGAN = "Bird Tweet"
Case 125
ORGAN = "Telephone Ring"
Case 126
ORGAN = "Helicopter"
Case 127
ORGAN = "Applause"
Case 128
ORGAN = "Gunshot"
End Select
End Function
