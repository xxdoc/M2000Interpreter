VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "myButton"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Dim WithEvents glistN As gList
Attribute glistN.VB_VarHelpID = -1
Dim mCaptext As String
Dim mIndex As Long
Private mCallback As InterPress

Public Property Set Container(glistNN As gList)
Set glistN = glistNN
With glistN
.NoCaretShow = True
.NoPanRight = False
.restrictLines = 1
.CenterText = True
.VerticalCenterText = True
.Text = mCaptext
.BackColor = rgb(200, 120, 60)

''.FontSize = 12
.Enabled = True
.ShowMe
End With
End Property

Private Sub Class_Initialize()
mCaptext = "Button"
End Sub

Private Sub Class_Terminate()
Set glistN = Nothing
Set mCallback = Nothing
End Sub

Private Sub glistN_CheckGotFocus()
glistN.BackColor = rgb(100, 200, 160)
glistN.ShowMe
End Sub

Private Sub glistN_CheckLostFocus()
If Me.Enabled Then
glistN.BackColor = rgb(200, 120, 60)
glistN.PanPos = 0
glistN.ShowMe
End If
End Sub

Private Sub glistN_PanLeftRight(Direction As Boolean)
    If (Not mCallback Is Nothing) Then mCallback.Press Index
End Sub

Private Sub glistN_RegisterGlist(this As gList)
this.NoWheel = True
End Sub

Private Sub glistN_Selected2(item As Long)
If item >= 0 Then
    If (Not mCallback Is Nothing) Then mCallback.Press Index
    End If
End Sub
Property Set Callback(ByRef newObj As InterPress)
    Set mCallback = newObj
End Property

Property Get Callback() As InterPress
    Set Callback = mCallback
End Property
Public Property Let Caption(myCap As String)
'
mCaptext = myCap
If Not glistN Is Nothing Then
If glistN.CenterText Then
glistN.List(0) = mCaptext
Else
glistN.List(0) = "  " + mCaptext
End If
glistN.ShowMe
End If
End Property
Public Property Get Caption() As String
Caption = mCaptext
End Property

Public Property Get Index() As Long
Index = mIndex
End Property

Public Property Let Index(ByVal rhs As Long)
mIndex = rhs
End Property
Public Property Get Enabled() As Long
Enabled = glistN.Enabled
End Property

Public Property Let Enabled(ByVal rhs As Long)
glistN.Enabled = rhs
End Property

Public Sub Shutdown()
glistN.Shutdown
glistN.Enabled = False

End Sub
