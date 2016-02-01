Attribute VB_Name = "mdlIDispatch"
' ************************************************************************
' Copyright:    All rights reserved.  � 2004
' Project:      AsyncServer
' Module:       mdlIDispatch
' Original Author:       james b tollan
' Changed by George Karras
' Change TLB to take care named arguments
'
    Const DISPATCH_METHOD = 1
    Const DISPATCH_PROPERTYGET = 2
    Const DISPATCH_PROPERTYPUT = 4
    Const DISPATCH_PROPERTYPUTREF = 8
    Const DISPID_UNKNOWN = -1
    Const DISPID_VALUE = 0
    Const DISPID_PROPERTYPUT = -3
    Const DISPID_NEWENUM = -4
    Const DISPID_EVALUATE = -5
    Const DISPID_CONSTRUCTOR = -6
    Const DISPID_DESTRUCTOR = -7
    Const DISPID_COLLECT = -8
Option Explicit
Enum cbnCallTypes
    VbLet = DISPATCH_PROPERTYPUT
    VbGet = DISPATCH_PROPERTYGET
    VbSet = DISPATCH_PROPERTYPUTREF
    VbMethod = DISPATCH_METHOD
End Enum
' Maybe need this http://support2.microsoft.com/kb/2870467/
'To update oleaut32
Private Declare Sub VariantCopy Lib "oleaut32.dll" (ByRef pvargDest As Variant, ByRef pvargSrc As Variant)
Private KnownProp As Collection
Private Init As Boolean
Private Declare Function VarPtrArray Lib "msvbvm60.dll" Alias "VarPtr" (Ptr() As Any) As Long
Public Function FindDISPID(pobjTarget As Object, ByVal pstrProcName As Variant) As Long

    Dim IDsp        As IDispatch.IDispatchM2000
    Dim rIid        As IDispatch.IID
    Dim DISPID      As Long

    Dim lngRet      As Long
    FindDISPID = -1
    Dim a$(0 To 0), arrdispid(0 To 0) As Long, myptr() As Long
    ReDim myptr(0 To 0)
    myptr(0) = StrPtr(pstrProcName)
    
 Set IDsp = pobjTarget
If Not getone(Typename(pobjTarget) & "." & pstrProcName, DISPID) Then
      lngRet = IDsp.GetIDsOfNames(rIid, myptr(0), 1&, cLid, arrdispid(0))
     
      If lngRet = 0 Then DISPID = arrdispid(0): PushOne Typename(pobjTarget) & "." & pstrProcName, DISPID
      
      Else
      lngRet = 0
End If
If lngRet = 0 Then FindDISPID = DISPID
End Function
Public Function CallByNameFixParamArray _
    (pobjTarget As Object, _
    ByVal pstrProcName As Variant, _
    ByVal CallType As cbnCallTypes, _
     pArgs(), pargs2() As String, items As Long, Optional robj As Object, Optional fixnamearg As Long = 0) As Variant


    ' pobjTarget    :   Class or form object that contains the procedure/property
    ' pstrProcName  :   Name of the procedure or property
    ' CallType      :   vbLet/vbGet/vbSet/vbMethod
    ' pArgs()       :   Param Array of parameters required for methode/property
    ' New by George
     ' pargs2() the names of arguments
     ' fixnamearg = the number of named arguments
    
    Dim IDsp        As IDispatch.IDispatchM2000
    Dim rIid        As IDispatch.IID
    Dim Params      As IDispatch.DISPPARAMS
    Dim Excep       As IDispatch.EXCEPINFO
    ' Do not remove TLB because those types
    ' are also defined in stdole
    Dim DISPID      As Long
    Dim lngArgErr   As Long
    Dim varRet      As Variant
    Dim varArr()    As Variant
    Dim varDISPID() As Long
    Dim lngRet      As Long
    Dim lngLoop     As Long
    Dim lngMax      As Long
Dim myptr() As Long

    ' Get IDispatch from object
    Set IDsp = pobjTarget

    ' Get DISPIP from pstrProcName
    If fixnamearg = 0 Then
        ReDim varDISPID(0 To 0)
If Not getone(Typename$(pobjTarget) & "." & pstrProcName, DISPID) Then
            ReDim myptr(0 To 0)
            myptr(0) = StrPtr(pstrProcName)
            lngRet = IDsp.GetIDsOfNames(rIid, myptr(0), 1&, cLid, varDISPID(0))
            
            If lngRet = 0 Then DISPID = varDISPID(0): PushOne Typename$(pobjTarget) & "." & pstrProcName, DISPID
            Else
            lngRet = 0
End If
Else
         ReDim myptr(0 To fixnamearg)
            myptr(0) = StrPtr(pstrProcName)
            For lngLoop = 1 To fixnamearg
            myptr(lngLoop) = StrPtr(pargs2(lngLoop))
            Next lngLoop
                ReDim varDISPID(0 To fixnamearg)
            lngRet = IDsp.GetIDsOfNames(rIid, myptr(0), fixnamearg + 1, cLid, varDISPID(0))
 DISPID = varDISPID(0)
End If
    If lngRet = 0 Then
       
        If items > 0 Or fixnamearg > 0 Then
                ReDim varArr(0 To items - 1 + fixnamearg)
               
                For lngLoop = 0 To items - 1 + fixnamearg
                    SwapVariant varArr(fixnamearg + items - 1 - lngLoop), pArgs(lngLoop)
                Next
              With Params
                    .cArgs = items + fixnamearg
                    .rgPointerToVariantArray = VarPtr(varArr(0))
                 If CallType = VbLet Or CallType = VbSet Or fixnamearg > 0 Then
                
        If fixnamearg = 0 Then
                ReDim varDISPID(0 To 0)
                 varDISPID(0) = DISPID_PROPERTYPUT
                   .cNamedArgs = 1
                 Else
                  .cNamedArgs = fixnamearg

      For lngLoop = 0 To fixnamearg - 1
      varDISPID(lngLoop) = varDISPID(fixnamearg - lngLoop)
                    
                Next

                   
                End If
                .rgPointerToDISPIDNamedArgs = VarPtr(varDISPID(0))
                
                Else
                .cNamedArgs = 0
                .rgPointerToDISPIDNamedArgs = 0
              End If
                End With
Else
With Params
.cArgs = 0
.cNamedArgs = 0
End With
        End If

        ' Invoke method/property
        
        lngRet = IDsp.Invoke(DISPID, rIid, 0, CallType, Params, varRet, Excep, lngArgErr)

        If lngRet <> 0 Then
            If lngRet = DISP_E_EXCEPTION Then
                Err.Raise Excep.wCode
            Else
                Err.Raise lngRet
            End If
        End If
    Else
        Err.Raise lngRet
    End If
    If items > 0 Then
                ' Fill parameters arrays. The array must be
                ' filled in reverse order.
                For lngLoop = 0 To items - 1 + fixnamearg
                    SwapVariant varArr(fixnamearg + items - 1 - lngLoop), pArgs(lngLoop)
                Next
    End If
    On Error Resume Next

    Set IDsp = Nothing
    If IsObject(varRet) Then
            Set robj = varRet
            CallByNameFixParamArray = CLng(0)
Else
            CallByNameFixParamArray = varRet
End If
    If Err.Number <> 0 Then CallByNameFixParamArray = varRet
Err.clear
End Function


Public Function ReadOneParameter(pobjTarget As Object, DISPID As Long, ERrR$) As Variant
    
    Dim CallType As cbnCallTypes
    
    CallType = VbGet
    Dim IDsp        As IDispatch.IDispatchM2000
    Dim rIid        As IDispatch.IID
    Dim Params      As IDispatch.DISPPARAMS
    Dim Excep       As IDispatch.EXCEPINFO
    ' Do not remove TLB because those types
    ' are also defined in stdole
        Dim lngArgErr   As Long
    Dim varRet      As Variant
    Dim varArr()    As Variant

    Dim lngRet      As Long
    Dim lngLoop     As Long
    Dim lngMax      As Long

    ' Get IDispatch from object
    Set IDsp = pobjTarget

    ' WE HAVE DISPIP

    If lngRet = 0 And False Then
       ' wrong
      
                ReDim varArr(0 To 0)
                varArr(0) = True
                With Params
                    .cArgs = 1
                    .rgPointerToVariantArray = VarPtr(varArr(0))
                                    Dim aa As Long
        
                aa = DISPID_VALUE
                .cNamedArgs = 1
                .rgPointerToDISPIDNamedArgs = VarPtr(aa)
                End With
        End If

        ' Invoke method/property
        Err.clear
        On Error Resume Next
        lngRet = IDsp.Invoke(DISPID, rIid, 0, CallType, Params, varRet, Excep, lngArgErr)
If Err > 0 Then
ERrR$ = Err.Description
Exit Function
Else
        If lngRet <> 0 Then
            If lngRet = DISP_E_EXCEPTION Then
             ERrR$ = Str$(Excep.wCode)
            Else
              ERrR$ = Str$(lngRet)
            End If
            Exit Function
        End If
  End If
    On Error Resume Next

    Set IDsp = Nothing
    If IsObject(varRet) Then

    Set ReadOneParameter = varRet
    Else
    ReadOneParameter = varRet
    End If

  ''  If Err.Number <> 0 Then ReadOneParameter = varRet
Err.clear
End Function
Public Sub ChangeOneParameter(pobjTarget As Object, DISPID As Long, VAL1, ERrR$)
    
    Dim CallType As cbnCallTypes
    
    CallType = VbLet
    Dim IDsp        As IDispatch.IDispatchM2000
    Dim rIid        As IDispatch.IID
    Dim Params      As IDispatch.DISPPARAMS
    Dim Excep       As IDispatch.EXCEPINFO
    ' Do not remove TLB because those types
    ' are also defined in stdole
        Dim lngArgErr   As Long
    Dim varRet      As Variant
    Dim varArr()    As Variant

    Dim lngRet      As Long
    Dim lngLoop     As Long
    Dim lngMax      As Long

    ' Get IDispatch from object
    Set IDsp = pobjTarget

    ' WE HAVE DISPIP

    If lngRet = 0 Then
       
      
                ReDim varArr(0 To 0)
                varArr(0) = VAL1
                With Params
                    .cArgs = 1
                    .rgPointerToVariantArray = VarPtr(varArr(0))
                                    Dim aa As Long
        
                aa = DISPID_PROPERTYPUT
                .cNamedArgs = 1
                .rgPointerToDISPIDNamedArgs = VarPtr(aa)
                End With
        End If

        ' Invoke method/property
        
        lngRet = IDsp.Invoke(DISPID, rIid, 0, CallType, Params, varRet, Excep, lngArgErr)

        If lngRet <> 0 Then
            If lngRet = DISP_E_EXCEPTION Then
             ERrR$ = Str$(Excep.wCode)
            Else
              ERrR$ = Str$(lngRet)
            End If
            Exit Sub
        End If
    
    
    

    Set IDsp = Nothing
    
End Sub
Private Sub PushOne(KnownPropName As String, ByVal V As Long)
On Error Resume Next
KnownProp.Add V, LCase$(KnownPropName)
End Sub
Private Function getone(KnownPropName As String, this As Long) As Boolean
On Error Resume Next
Dim V As Long
InitMe
Err.clear
V = KnownProp(LCase$(KnownPropName))
If Err.Number = 0 Then getone = True: this = V
Err.clear
End Function

Private Sub InitMe()
If Init Then Exit Sub
Set KnownProp = New Collection
' from this collection we never delete items.
Init = True
End Sub
Public Function MakeObjectFromString(obj As Variant, objstr As String) As Object
Dim o As Object, strvar, varg(), obj1 As Object, varg2() As String
strvar = objstr
Set o = obj
CallByNameFixParamArray o, strvar, VbGet, varg(), varg2(), 0, obj1
Set MakeObjectFromString = obj1
End Function
