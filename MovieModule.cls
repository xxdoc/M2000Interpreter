VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MovieModule"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'Programmer: Jason Hensley

'Email: elitecobra@hotmail.com

'Website: www16.brinkster.com/codesource

'Description: Easily create a MOVIE player to play
'avi, mpeg, mpeg2, quicktime, divx(need divx codec) and more
'Designed to be easy to use and small in size. Please email
'me if you have any feedback or problems.

'Problems/Bugs: If you use the mpegvideo device type
'and it skips the video just don't use the getPositionInFrames
'function



Private myid As Long

Private Declare Function mciGetErrorString Lib "winmm.dll" Alias "mciGetErrorStringA" (ByVal dwError As Long, ByVal lpstrBuffer As String, ByVal uLength As Long) As Long 'Get the error message of the mcidevice if any
Private Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long 'Send command strings to the mci device
Private data As String * 128 ' Used to store our return data
Public error As Long ' Used to store our error message
Public Height As Long
Public Width As Long
Public Length As Long
 Private mFilename  As String ' Used to store our file
 Private Const MIXER_SETCONTROLDETAILSF_VALUE = &H0&

      Private Const MMSYSERR_NOERROR = 0
      Private Const MAXPNAMELEN = 32
      Private Const MIXER_LONG_NAME_CHARS = 64
      Private Const MIXER_SHORT_NAME_CHARS = 16
      Private Const MIXER_GETLINEINFOF_COMPONENTTYPE = &H3&
      Private Const MIXER_GETCONTROLDETAILSF_VALUE = &H0&
      Private Const MIXER_GETLINECONTROLSF_ONEBYTYPE = &H2&
      Private Const MIXERLINE_COMPONENTTYPE_DST_FIRST = &H0&
      Private Const MIXERLINE_COMPONENTTYPE_SRC_FIRST = &H1000&

      Private Const MIXERLINE_COMPONENTTYPE_DST_SPEAKERS = _
                     (MIXERLINE_COMPONENTTYPE_DST_FIRST + 4)

      Private Const MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE = _
                     (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 3)

      Private Const MIXERLINE_COMPONENTTYPE_SRC_LINE = _
                     (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 2)

      Private Const MIXERCONTROL_CT_CLASS_FADER = &H50000000
      Private Const MIXERCONTROL_CT_UNITS_UNSIGNED = &H30000

      Private Const MIXERCONTROL_CONTROLTYPE_FADER = _
                     (MIXERCONTROL_CT_CLASS_FADER Or _
                     MIXERCONTROL_CT_UNITS_UNSIGNED)

      Private Const MIXERCONTROL_CONTROLTYPE_VOLUME = _
                     (MIXERCONTROL_CONTROLTYPE_FADER + 1)

      Private Declare Function mixerClose Lib "winmm.dll" _
                     (ByVal hmx As Long) As Long

     Private Declare Function mixerGetControlDetails Lib "winmm.dll" _
                     Alias "mixerGetControlDetailsA" _
                     (ByVal hmxobj As Long, _
                     pmxcd As MIXERCONTROLDETAILS, _
                     ByVal fdwDetails As Long) As Long

     Private Declare Function mixerGetDevCaps Lib "winmm.dll" _
                     Alias "mixerGetDevCapsA" _
                     (ByVal uMxId As Long, _
                     ByVal pmxcaps As MIXERCAPS, _
                     ByVal cbmxcaps As Long) As Long

      Private Declare Function mixerGetID Lib "winmm.dll" _
                     (ByVal hmxobj As Long, _
                     pumxID As Long, _
                     ByVal fdwId As Long) As Long

     Private Declare Function mixerGetLineControls Lib "winmm.dll" _
                     Alias "mixerGetLineControlsA" _
                     (ByVal hmxobj As Long, _
                     pmxlc As MIXERLINECONTROLS, _
                     ByVal fdwControls As Long) As Long

     Private Declare Function mixerGetLineInfo Lib "winmm.dll" _
                     Alias "mixerGetLineInfoA" _
                     (ByVal hmxobj As Long, _
                     pmxl As MIXERLINE, _
                     ByVal fdwInfo As Long) As Long

     Private Declare Function mixerGetNumDevs Lib "winmm.dll" () As Long

     Private Declare Function mixerMessage Lib "winmm.dll" _
                     (ByVal hmx As Long, _
                     ByVal uMsg As Long, _
                     ByVal dwParam1 As Long, _
                     ByVal dwParam2 As Long) As Long

     Private Declare Function mixerOpen Lib "winmm.dll" _
                     (phmx As Long, _
                     ByVal uMxId As Long, _
                     ByVal dwCallback As Long, _
                     ByVal dwInstance As Long, _
                     ByVal fdwOpen As Long) As Long

   Private Declare Function mixerSetControlDetails Lib "winmm.dll" _
                     (ByVal hmxobj As Long, _
                     pmxcd As MIXERCONTROLDETAILS, _
                     ByVal fdwDetails As Long) As Long

    Private Declare Sub CopyStructFromPtr Lib "kernel32" _
                     Alias "RtlMoveMemory" _
                     (struct As Any, _
                     ByVal Ptr As Long, _
                     ByVal cb As Long)

    Private Declare Sub CopyPtrFromStruct Lib "kernel32" _
                     Alias "RtlMoveMemory" _
                     (ByVal Ptr As Long, _
                     struct As Any, _
                     ByVal cb As Long)

    Private Declare Function GlobalAlloc Lib "kernel32" _
                     (ByVal wFlags As Long, _
                     ByVal dwBytes As Long) As Long

    Private Declare Function GlobalLock Lib "kernel32" _
                     (ByVal hMem As Long) As Long

    Private Declare Function GlobalFree Lib "kernel32" _
                     (ByVal hMem As Long) As Long

      Private Type MIXERCAPS
         wMid As Integer                   '  manufacturer id
         wPid As Integer                   '  product id
         vDriverVersion As Long            '  version of the driver
         szPname As String * MAXPNAMELEN   '  product name
         fdwSupport As Long                '  misc. support bits
         cDestinations As Long             '  count of destinations
      End Type

      Private Type MIXERCONTROL
         cbStruct As Long           '  size in Byte of MIXERCONTROL
         dwControlID As Long        '  unique control id for mixer device
         dwControlType As Long      '  MIXERCONTROL_CONTROLTYPE_xxx
         fdwControl As Long         '  MIXERCONTROL_CONTROLF_xxx
         cMultipleItems As Long     '  if MIXERCONTROL_CONTROLF_MULTIPLE
                                    '  set
         szShortName As String * MIXER_SHORT_NAME_CHARS  ' short name of
                                                         ' control
         szName As String * MIXER_LONG_NAME_CHARS        ' long name of
                                                         ' control
         lMinimum As Long           '  Minimum value
         lMaximum As Long           '  Maximum value
         reserved(10) As Long       '  reserved structure space
         End Type

    Private Type MIXERCONTROLDETAILS
         cbStruct As Long       '  size in Byte of MIXERCONTROLDETAILS
         dwControlID As Long    '  control id to get/set details on
         cChannels As Long      '  number of channels in paDetails array
         item As Long           '  hwndOwner or cMultipleItems
         cbDetails As Long      '  size of _one_ details_XX struct
         paDetails As Long      '  pointer to array of details_XX structs
      End Type

    Private Type MIXERCONTROLDETAILS_UNSIGNED
         dwValue As Long        '  value of the control
      End Type

    Private Type MIXERLINE
         cbStruct As Long               '  size of MIXERLINE structure
         dwDestination As Long          '  zero based destination index
         dwSource As Long               '  zero based source index (if
                                        '  source)
         dwLineID As Long               '  unique line id for mixer device
         fdwLine As Long                '  state/information about line
         dwUser As Long                 '  driver specific information
         dwComponentType As Long        '  component type line connects to
         cChannels As Long              '  number of channels line supports
         cConnections As Long           '  number of connections (possible)
         cControls As Long              '  number of controls at this line
         szShortName As String * MIXER_SHORT_NAME_CHARS
         szName As String * MIXER_LONG_NAME_CHARS
         dwType As Long
         dwDeviceID As Long
         wMid  As Integer
         wPid As Integer
         vDriverVersion As Long
         szPname As String * MAXPNAMELEN
      End Type

    Private Type MIXERLINECONTROLS
         cbStruct As Long       '  size in Byte of MIXERLINECONTROLS
         dwLineID As Long       '  line id (from MIXERLINE.dwLineID)
                                '  MIXER_GETLINECONTROLSF_ONEBYID or
         dwControl As Long      '  MIXER_GETLINECONTROLSF_ONEBYTYPE
         cControls As Long      '  count of controls pmxctrl points to
         cbmxctrl As Long       '  size in Byte of _one_ MIXERCONTROL
         pamxctrl As Long       '  pointer to first MIXERCONTROL array
      End Type

    Private Function GetVolumeControl(ByVal hmixer As Long, _
                              ByVal componentType As Long, _
                              ByVal ctrlType As Long, _
                              ByRef mxc As MIXERCONTROL) As Boolean

      ' This function attempts to obtain a mixer control.
      ' Returns True if successful.
         Dim mxlc As MIXERLINECONTROLS
         Dim mxl As MIXERLINE
         Dim hMem As Long
         Dim rc As Long

         mxl.cbStruct = Len(mxl)
         mxl.dwComponentType = componentType

         ' Obtain a line corresponding to the component type
         rc = mixerGetLineInfo(hmixer, _
                               mxl, _
                               MIXER_GETLINEINFOF_COMPONENTTYPE)

         If (MMSYSERR_NOERROR = rc) Then
             mxlc.cbStruct = Len(mxlc)
             mxlc.dwLineID = mxl.dwLineID
             mxlc.dwControl = ctrlType
             mxlc.cControls = 1
             mxlc.cbmxctrl = Len(mxc)

             ' Allocate a buffer for the control
             hMem = GlobalAlloc(&H40, Len(mxc))
             mxlc.pamxctrl = GlobalLock(hMem)
             mxc.cbStruct = Len(mxc)

             ' Get the control
             rc = mixerGetLineControls(hmixer, _
                                       mxlc, _
                                       MIXER_GETLINECONTROLSF_ONEBYTYPE)

             If (MMSYSERR_NOERROR = rc) Then
                 GetVolumeControl = True

                 ' Copy the control into the destination structure
                 CopyStructFromPtr mxc, mxlc.pamxctrl, Len(mxc)
             Else
                 GetVolumeControl = False
             End If
             GlobalFree (hMem)
             Exit Function
         End If

         GetVolumeControl = False
      End Function

    Private Function SetVolumeControl(ByVal hmixer As Long, _
                              mxc As MIXERCONTROL, _
                              ByVal volume As Long) As Boolean
      ' This function sets the value for a volume control.
      ' Returns True if successful

         Dim mxcd As MIXERCONTROLDETAILS
         Dim vol As MIXERCONTROLDETAILS_UNSIGNED
Dim hMem As Long
 Dim rc As Long
         mxcd.item = 0
         mxcd.dwControlID = mxc.dwControlID
         mxcd.cbStruct = Len(mxcd)
         mxcd.cbDetails = Len(vol)

         ' Allocate a buffer for the control value buffer
         hMem = GlobalAlloc(&H40, Len(vol))
         mxcd.paDetails = GlobalLock(hMem)
         mxcd.cChannels = 1
         vol.dwValue = volume
         ' Copy the data into the control value buffer
         CopyPtrFromStruct mxcd.paDetails, vol, Len(vol)

         ' Set the control value
         
         rc = mixerSetControlDetails(hmixer, mxcd, MIXER_SETCONTROLDETAILSF_VALUE)

         GlobalFree (hMem)
         If (MMSYSERR_NOERROR = rc) Then
             SetVolumeControl = True
         Else
             SetVolumeControl = False
         End If
      End Function
  
Public Property Let FileName(n As String)
'If mFilename = n Then
'Exit Property
'End If
mFilename = n
If mFilename <> "" Then
openMovie

extractDefaultMovieSize Width, Height
Length = getLengthInMS
End If
closeMovie
End Property

Public Property Get FileName() As String
FileName = mFilename
End Property

Public Function stepFrames(Value As Long)
    'Step ahead a specified amount of frames
    'Ex. If the m"+cstr(myID)+" was on frame 20. And if you stepped
    '10 frames the m"+cstr(myID)+" would skip ahead 10 frames and
    'would be on frame 30.
    error = mciSendString("step m" & CStr(myid) & " by " & Value, 0, 0, 0)
End Function
Public Function restoreSizeDefault()
    'This function will restore the m"+cstr(myID)+" to its original
    'size. Not if you use a child window
    error = mciSendString("put m" & CStr(myid) & " window", 0, 0, 0)
End Function
Public Function openMovie()

    'Open a m"+cstr(myID)+" in the default window style(Popup)
    Dim A As Long, LASTF As String
    LASTF = """" & FileName & """"
  '  error = mciSendString("close all", 0, 0, 0)
    'Decide which way you want the mci device to work below
    Dim pt$
    pt$ = UCase(ExtractType(FileName))
    'Specify the mpegvideo driver to play the movies
    'type mpegvideo alias
     If pt$ = "MID" Then
    error = mciSendString("open " & LASTF & " type sequencer alias m" & CStr(myid) & " ", 0, 0, 0)
    ElseIf pt$ = "WAV" Then
    error = mciSendString("open " & LASTF & " type waveaudio alias m" & CStr(myid) & " ", 0, 0, 0)
      ElseIf Left$(pt$, 2) = "MP" Then
    error = mciSendString("open " & LASTF & " type mpegvideo alias m" & CStr(myid) & " ", 0, 0, 0)
    Else
    error = mciSendString("open " & LASTF & " alias m" & CStr(myid) & " ", 0, 0, 0)
       If error <> 0 Then
     error = mciSendString("open " & LASTF & " type mpegvideo alias m" & CStr(myid) & " ", 0, 0, 0)

    End If
    End If
    'Let the mci device decide which driver to use
    'Error = mciSendString("open " & Filename & " alias m"+cstr(myID)+"", 0, 0, 0)
End Function

Public Function openMovieWindow(hWnd As Long, WindowStyle As String)
    'Style types = popup , child or overlapped
    'Child window would be a .hwnd window of your choice.
    'Ex. A picturebox control or a frame control would be
    'a child window
    Dim LASTF As String
    LASTF = """" & FileName & """"
  '  error = mciSendString("close m"+cstr(myID)+"", 0, 0, 0)
    'Decide which way you want the mci device to work below
    
    'use the command below to play divx movies. Must have the Divx codec installed
   ' error = mciSendString("open " & LASTF & " type mpegvideo alias m"+cstr(myID)+" parent " & hWnd & " style " & WindowStyle & " ", 0, 0, 0)
    
    'Let the mci device decide which driver to use
      error = mciSendString("open " & LASTF & " alias m" & CStr(myid) & " parent " & hWnd & " style " & WindowStyle & " ", 0, 0, 0)
 
    If error <> 0 Then
    error = mciSendString("open " & LASTF & " type mpegvideo alias m" & CStr(myid) & " parent " & hWnd & " style " & WindowStyle & " ", 0, 0, 0)
    
    
    End If
    End Function
Public Function minimizeMovie()
    'Minimize the m"+cstr(myID)+" window
    error = mciSendString("window m" & CStr(myid) & " state minimized", 0, 0, 0)
End Function
Public Function playMovie()


    'Play the m"+cstr(myID)+" after you open it
    error = mciSendString("play m" & CStr(myid) & "", 0, 0, 0)

End Function


Public Function hideMovie()
    'Hides the m"+cstr(myID)+" window
    error = mciSendString("window m" & CStr(myid) & " state hide", 0, 0, 0)
End Function
Public Function showMovie()
    'Will show the window if it was hidden with the
    'hideMovie function
    error = mciSendString("window m" & CStr(myid) & " state show", 0, 0, 0)
End Function
Public Function restoreMovie()
    'Will restore the window to its original state
    error = mciSendString("window m" & CStr(myid) & " state restore", 0, 0, 0)
End Function
Public Function stopMovie()
    'Stops the playing of the m"+cstr(myID)+"

    error = mciSendString("stop m" & CStr(myid) & "", 0, 0, 0)
    
End Function
Public Function extractCurrentMovieSize(wLeft As Long, wTop As Long, wWidth As Long, wHeight As Long)
    'Returns the size parameters of the m"+cstr(myID)+"
    On Error Resume Next
    Dim A As String
    Dim b As String
    Dim c As String
    Dim f As String
    Dim g As String
    A = getCurrentSize
    b = InStr(1, A, " ")
    c = InStr(b + 1, A, " ")
    f = Mid(A, c + 1)
    g = InStr(1, f, " ")
    wWidth = Val(Left(f, g)) 'width
    wHeight = Val(Mid(f, g)) 'height
End Function
Public Function MovieHeight() As Long
    'Returns the size parameters of the m"+cstr(myID)+"
    On Error Resume Next
    Dim A As String
    Dim b As String
    Dim c As String
    Dim f As String
    Dim g As String
    A = getCurrentSize
    b = InStr(1, A, " ")
    c = InStr(b + 1, A, " ")
    f = Mid(A, c + 1)
    g = InStr(1, f, " ")
       MovieHeight = Val(Mid(f, g)) 'height
End Function
Public Function extractDefaultMovieSize(wWidth As Long, wHeight As Long)
    'Returns the default size of the m"+cstr(myID)+" even if the size
    'of the m"+cstr(myID)+" has been changed
    On Error Resume Next
    Dim A As String
    Dim b As String
    Dim c As String
    Dim f As String
    Dim g As String
    A = getDefaultSize
    b = InStr(1, A, " ") '2
    c = InStr(b + 1, A, " ") '4
    f = Mid(A, c + 1) '9
    g = InStr(1, f, " ")
    wWidth = Val(Left(f, g)) 'width
    wHeight = Val(Mid(f, g)) 'height
End Function
Public Function getBitsPerPixel()
    'Will get the m"+cstr(myID)+" bitsperpixel
    'Works with avi movies only
    error = mciSendString("status m" & CStr(myid) & " bitsperpel", data, 128, 0)
    getBitsPerPixel = Val(data)
End Function
Public Function getMovieInput() As String
    'Returns the current input source
    error = mciSendString("status m" & CStr(myid) & " monitor input", data, 128, 0)
    getMovieInput = data
End Function
Public Function getMovieOutput() As String
    'Returns the current output source
    error = mciSendString("status m" & CStr(myid) & " monitor output", data, 128, 0)
    getMovieOutput = data
End Function
Public Function getAudioStatus() As String
    'Check to see if the audio is on or off
    error = mciSendString("status m" & CStr(myid) & " audio", data, 128, 0)
    getAudioStatus = CStr(data)
End Function
Public Function sizeLocateMovie(Left As Long, top As Long, Width As Long, Height As Long)
    'Change the size of the m"+cstr(myID)+" and the location of
    'the m"+cstr(myID)+" in Pixels
' 120 120 200 200 frame 0 0 200 200 source 0 0 200 200
    error = mciSendString("put m" & CStr(myid) & " window at " & Left & " " & top & " " & Width & " " & Height, 0, 0, 0)

'error = mciSendString("put m"+cstr(myID)+" video 120 120 200 200 frame 0 0 200 200 source 0 0 200 200 ", 0, 0, 0)

End Function
Public Function isMoviePlaying() As Boolean
    'Checks the status of the m"+cstr(myID)+" whether it is playing
    'or not
    
    Dim isPlaying As String

    error = mciSendString("status m" & CStr(myid) & " mode", data, 128, 0)
   MyDoEvents
     isPlaying = Left(data, 7)
    If isPlaying = "playing" And Not NOEXECUTION Then
        isMoviePlaying = True
    Else
        isMoviePlaying = False
        End If
    
End Function
Public Function checkError() As String
    'A very useful function for getting any errors
    'associated with the mci device
    checkError = Space$(255)
    mciGetErrorString error, checkError, Len(checkError)
End Function
Public Function getDeviceName() As String
    'Returns the current device name in use
    error = mciSendString("info m" & CStr(myid) & " product", data, 128, 0)
    getDeviceName = data
End Function
Public Function getDeviceVersion() As String
    'Returns the current version of the mci device in use
    error = mciSendString("info m" & CStr(myid) & " version", data, 128, 0)
    getDeviceVersion = data
End Function
Public Function getNominalFrameRate() As Long
    'Returns the nominal frame rate of the m"+cstr(myID)+" file
    error = mciSendString("status m" & CStr(myid) & " nominal frame rate ", data, 128, 0) ' wait
    getNominalFrameRate = Val(data)
End Function
Public Function getFramePerSecRate() As Long
    'Returns the Frames Per Second of the m"+cstr(myID)+" file
    'avi and mpeg movies
    error = mciSendString("status m" & CStr(myid) & " frame rate", data, 128, 0)
    getFramePerSecRate = Val(data) \ 1000
End Function
Public Function getCurrentSize() As String
    'Returns the current width, height of the m"+cstr(myID)+"
    error = mciSendString("where m" & CStr(myid) & " destination max", data, 128, 0)
    If error > 0 Then
    getCurrentSize = "0 0 0 0"
    Else
    getCurrentSize = data
    End If
End Function
Public Function getDefaultSize() As String
    'Returns the default width, height the m"+cstr(myID)+"
  
    error = mciSendString("where m" & CStr(myid) & " source", data, 128, 0)
 
        If error > 0 Then
    getDefaultSize = "0 0"
    Else
    getDefaultSize = data
    End If
End Function
Public Function getLengthInFrames() As Long
    'Get the length of the m"+cstr(myID)+" in frames

    error = mciSendString("set m" & CStr(myid) & " time format frames", 0, 0, 0)
    error = mciSendString("status m" & CStr(myid) & " length", data, 128, 0)
    getLengthInFrames = Val(data)
End Function
Public Function getLengthInMS() As Long
    'Get the length of the m"+cstr(myID)+" in milliseconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("status m" & CStr(myid) & " length", data, 128, 0)
    getLengthInMS = Val(data)
End Function
Public Function playFullScreen()
    'Play the m"+cstr(myID)+" in full screen mode
    error = mciSendString("play m" & CStr(myid) & " fullscreen", 0, 0, 0)
End Function
Public Function getLengthInSec() As Long
    'Get the length of the m"+cstr(myID)+" in seconds
    getLengthInSec = getLengthInMS \ 1000
End Function
Public Function setVideoOff()
    'Set the video device off
    error = mciSendString("set all video off", 0, 0, 0)
End Function
Public Function setVideoOn()
    'Set the video device on
    error = mciSendString("set all video on", 0, 0, 0)
End Function
Public Function pauseMovie()
    'Pause the m"+cstr(myID)+"
    If AVIRUN Then
    AVI.Timer1.Enabled = False
    If (Me.getLengthInMS - Me.getPositionInMS) > 0 Then
    
    AVI.Timer1.Interval = Me.getLengthInMS - Me.getPositionInMS
    Else
     AVI.Timer1.Interval = 10000
    End If
    End If
    error = mciSendString("pause m" & CStr(myid) & "", 0, 0, 0)
End Function
Public Function resumeMovie()
    'Resumes the m"+cstr(myID)+"
    error = mciSendString("resume m" & CStr(myid) & "", 0, 0, 0)
End Function
Public Function getPositionInMS() As Long
    'Get the position of the m"+cstr(myID)+" in milliseconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("status m" & CStr(myid) & " position", data, 128, 0) 'wait
    getPositionInMS = Val(data)
End Function
Public Function getRate() As Long
    'Get the current speed of the m"+cstr(myID)+"
    error = mciSendString("status m" & CStr(myid) & " speed", data, 128, 0)
    getRate = Val(data)
End Function
Public Function getPositionInFrames() As Long
    'Get the position of the m"+cstr(myID)+" in frames
    error = mciSendString("set m" & CStr(myid) & " time format frames", 0, 0, 0) 'wait
    error = mciSendString("status m" & CStr(myid) & " position", data, 128, 0)
    getPositionInFrames = Val(data)
End Function
Public Function getStatus() As String
    'Get the current mode of the m"+cstr(myID)+"
    'Playing, Stopped, Paused, Not Ready
    error = mciSendString("status m" & CStr(myid) & " mode", data, 128, 0)
    getStatus = StrConv(data, vbProperCase)
End Function
Public Function closeMovie()
    'Close the mci device
    error = mciSendString("close m" & CStr(myid) & "", 0, 0, 0)
End Function
Public Function getFormatPosition() As String
    'Get the position in a userfriendly time format
    getFormatPosition = getThisTime(getPositionInMS)
End Function
Public Function getFormatLength() As String
    'Get the length in a userfriendly time format
    getFormatLength = getThisTime(getLengthInMS)
End Function

Private Function getThisTime(ByVal timein As Long) As String
    'Used to format the position and duration
    On Error GoTo TrapIt
    Dim conH As Integer
    Dim conM As Integer
    Dim conS As Integer
    Dim remTime As Long
    Dim strRetTime As String
    remTime = timein / 1000
    conH = Int(remTime / 3600)
    remTime = remTime Mod 3600
    conM = Int(remTime / 60)
    remTime = remTime Mod 60
    conS = remTime
    If conH > 0 Then
        strRetTime = Trim(Str(conH)) & ":"
    Else
        strRetTime = ""
    End If
    If conM >= 10 Then
        strRetTime = strRetTime & Trim(Str(conM))
    ElseIf conM > 0 Then
        strRetTime = strRetTime & Trim(Str(conM))
    Else
        strRetTime = strRetTime & "0"
    End If
    strRetTime = strRetTime & ":"
    If conS >= 10 Then
        strRetTime = strRetTime & Trim(Str(conS))
    ElseIf conS > 0 Then
        strRetTime = strRetTime & "0" & Trim(Str(conS))
    Else
        strRetTime = strRetTime & "00"
    End If
    getThisTime = strRetTime
    Exit Function
TrapIt:      MsgBox Err.Description, , " Error"
End Function
Public Function getVolume() As Long
    'Get the current volume level
    error = mciSendString("status m" & CStr(myid) & " volume", data, 128, 0)
    getVolume = Val(data)
End Function
Public Function getVideoStatus() As String
    'Get the status of the video. Returns on or off
    error = mciSendString("status m" & CStr(myid) & " video", data, 128, 0)
    getVideoStatus = data
End Function
Public Function getTimeFormat() As String
    'Returns the current time format. Frames or Millisecond
    error = mciSendString("status m" & CStr(myid) & " time format", data, 128, 0)
    getTimeFormat = data
End Function
Public Function getLeftVolume() As Long
    'Returns the volume value of the left channel
    error = mciSendString("status m" & CStr(myid) & " left volume", data, 128, 0)
    getLeftVolume = Val(data)
End Function
Public Function getPositionInSec() As Double
    'Get the position of the m"+cstr(myID)+" in seconds
    getPositionInSec = getPositionInMS / 1000
End Function
Public Function getRightVolume() As Long
    'Get the volume value of the right channel
    error = mciSendString("status m" & CStr(myid) & " right volume", data, 128, 0)
    getRightVolume = Val(data)
End Function
Public Function setAudioOff()
    'Turns of the audio device
    error = mciSendString("set m" & CStr(myid) & " audio all off", 0, 0, 0)
End Function
Public Function setAudioOn()
    'turns on the audio device
    error = mciSendString("set m" & CStr(myid) & " audio all on", 0, 0, 0)
End Function
Public Function setLeftOff()
    'Turns of the left channel
    error = mciSendString("set m" & CStr(myid) & " audio left off", 0, 0, 0)
End Function
Public Function setRightOff()
    'Turns of the right channel
    error = mciSendString("set m" & CStr(myid) & " audio right off", 0, 0, 0)
End Function
Public Function setLeftOn()
    'Turns on the left channel
    error = mciSendString("set m" & CStr(myid) & " audio left on", 0, 0, 0)
End Function
Public Function setRightOn()
    'Truns on the right channel
    error = mciSendString("set m" & CStr(myid) & " audio right on", 0, 0, 0)
End Function
Public Function setDoorOpen()
    'Open the cdrom door
    error = mciSendString("set cdaudio door open", 0, 0, 0)
End Function
Public Function setDoorClosed()
    'Close the cdrom door
    error = mciSendString("set cdaudio door closed", 0, 0, 0)
End Function
Public Function setVolume(Value As Long)
     'Raise or lower the volume for both channels
    '1000 max - 0 min

'     error = mciSendString("setaudio sequencer volume to " & Value, 0, 0, 0)
 error = mciSendString("setaudio m" & CStr(myid) & " volume to " & CStr(Value), 0, 0, 0)
End Function
Public Function setPositionTo(Second As Double)
    'Sets the position of the m"+cstr(myID)+" to play at
    On Error Resume Next
    Second = CLng(Second * 1000)
    
    If isMoviePlaying = True Then
    mciSendString "play m" & CStr(myid) & " from " & Second, 0, 0, 0
    ElseIf isMoviePlaying = False Then
    mciSendString "seek m" & CStr(myid) & " to " & Second, 0, 0, 0
    End If
     If AVIRUN Then
    AVI.Timer1.Enabled = False
    
     If (Me.getLengthInMS - Me.getPositionInMS) > 0 Then
    
    AVI.Timer1.Interval = Me.getLengthInMS - Me.getPositionInMS
    Else
     AVI.Timer1.Interval = 10000
    End If
    End If
    On Error GoTo 0
    End Function
Public Function restartMovie()
    'Sets the m"+cstr(myID)+" to the beginning and call the playMovie
    'function to start playing from the beginning
    error = mciSendString("seek m" & CStr(myid) & " to start", 0, 0, 0)
     If AVIRUN Then
    AVI.Timer1.Enabled = False
    AVI.Timer1.Enabled = Me.getLengthInMS
      AVI.Timer1.Enabled = True
    End If
    playMovie
End Function
Public Function rewindByMS(numMS As Long)
    'Rewind the m"+cstr(myID)+" a specified number of milliseconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInMS - numMS, 0, 0, 0)
End Function
Public Function rewindByFrames(numFrames As Long)
    'Rewind the m"+cstr(myID)+" by a specified number of frames
    error = mciSendString("set m" & CStr(myid) & " time format frames", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInFrames - numFrames, 0, 0, 0)
End Function
Public Function rewindBySeconds(numSec As Long)
    'Rewind the m"+cstr(myID)+" by a specified number of seconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInMS - 1000 * numSec, 0, 0, 0)
End Function
Public Function forwardByFrames(numFrames As Long)
    'Forward the m"+cstr(myID)+" a specified number of frames
    error = mciSendString("set m" & CStr(myid) & " time format frames", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInFrames + numFrames, 0, 0, 0)
End Function
Public Function forwardByMS(numMS As Long)
    'Forward the m"+cstr(myID)+" a specified number of milliseconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInMS + numMS, 0, 0, 0)
End Function
Public Function forwardBySeconds(numSec As Long)
    'Forward the m"+cstr(myID)+" a specified number of seconds
    error = mciSendString("set m" & CStr(myid) & " time format ms", 0, 0, 0)
    error = mciSendString("play m" & CStr(myid) & " from " & getPositionInMS + 1000 * numSec, 0, 0, 0)
End Function
Public Function checkDeviceReady() As String
    'Returns true or false depending if the mci device
    'is ready or not
    error = mciSendString("status m" & CStr(myid) & " ready", data, 128, 0)
    checkDeviceReady = data
End Function
Public Function setSpeed(Value As Long)
    'Set the current playing spped of the m"+cstr(myID)+"
    '0 = as fast as possible without losing frames
    'Values 1 - 2000 - 2000 being fastest
    error = mciSendString("set m" & CStr(myid) & " speed " & Value, 0, 0, 0)
End Function
Public Function setLeftVolume(Value As Long)
    'Set the value of the left volume
    error = mciSendString("setaudio m" & CStr(myid) & " left volume to " & Value, 0, 0, 0)
End Function
Public Function setRightVolume(Value As Long)
    error = mciSendString("setaudio m" & CStr(myid) & " right volume to " & Value, 0, 0, 0)
End Function
Sub timeOut(duration)
    'Pauses for a specified amount of milliseconds
    Dim StartTime As Long
    Dim x As Long
    StartTime = Timer
    Do While Timer - StartTime < duration
        x = DoEvents()
    Loop
    Exit Sub
End Sub

Private Sub Class_Initialize()
myid = CLng(Timer * 1000 Mod 1000)
error = mciSendString("open m" & CStr(myid), 0, 0, 0)

End Sub

Private Sub Class_Terminate()
error = mciSendString("close m" & CStr(myid), 0, 0, 0)
End Sub
Public Sub SetMasterVolume(MVol As Long)
    Dim hmixer As Long          ' mixer handle
      Dim volCtrl As MIXERCONTROL ' waveout volume control
      Dim micCtrl As MIXERCONTROL ' microphone volume control
      Dim rc As Long              ' return code
      Dim ok As Boolean           ' boolean return code
      Dim ovol As Long
      
       ok = GetVolumeControl(hmixer, _
                              MIXERLINE_COMPONENTTYPE_DST_SPEAKERS, _
                              MIXERCONTROL_CONTROLTYPE_VOLUME, _
                              volCtrl)
                              If ok Then
      ovol = CLng(MVol * ((volCtrl.lMaximum - volCtrl.lMinimum) / 100#)) + volCtrl.lMinimum
SetVolumeControl hmixer, volCtrl, ovol
End If
End Sub

