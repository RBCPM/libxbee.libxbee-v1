Attribute VB_Name = "libxbee"
Option Explicit

Enum xbee_types
    xbee_unknown
    
    xbee_localAT
    xbee_remoteAT
    
    xbee_16bitRemoteAT
    xbee_64bitRemoteAT
    
    xbee_16bitData
    xbee_64bitData
    
    xbee_16bitIO
    xbee_64bitIO
    
    xbee_txStatus
    xbee_modemStatus
End Enum

Type xbee_sample
    '# X  A5 A4 A3 A2 A1 A0 D8    D7 D6 D5 D4 D3 D2 D1 D0
    IOmask As Integer
    '# X  X  X  X  X  X  X  D8    D7 D6 D5 D4 D3 D2 D1 D0
    IOdigital As Integer
    '# X  X  X  X  X  D  D  D     D  D  D  D  D  D  D  D
    IOanalog(0 To 5) As Integer
End Type

Type xbee_pkt
    flags As Long               '# bit 0 - is64
                                '# bit 1 - dataPkt
                                '# bit 2 - txStatusPkt
                                '# bit 3 - modemStatusPkt
                                '# bit 4 - remoteATPkt
                                '# bit 5 - IOPkt
    frameID As Byte
    atCmd(0 To 1) As Byte
    
    status As Byte
    samples As Byte
    RSSI As Byte
    
    Addr16(0 To 1) As Byte
    
    Addr64(0 To 7) As Byte
    
    data(0 To 127) As Byte
    
    datalen As Long
    
    type As Long ' enum xbee_types
    
    SPARE As Long ' IGNORE THIS (is the pointer to the next packet in C... this will ALWAYS be 0 in VB)
    
    IOdata As xbee_sample
End Type

Private OldhWndHandler As Long
Private ActhWndHandler As Long
Private Callbacks As Collection

Public Declare Sub xbee_free Lib "libxbee.dll" (ByVal ptr As Long)

Public Declare Function xbee_setup Lib "libxbee.dll" (ByVal port As String, ByVal baudRate As Long) As Long
Public Declare Function xbee_setupDebug Lib "libxbee.dll" (ByVal port As String, ByVal baudRate As Long) As Long
Private Declare Function xbee_setupAPIRaw Lib "libxbee.dll" Alias "xbee_setupAPI" (ByVal port As String, ByVal baudRate As Long, ByVal cmdSeq As Byte, ByVal cmdTime As Long) As Long

Public Declare Function xbee_newcon_simple Lib "libxbee.dll" (ByVal frameID As Byte, ByVal conType As Long) As Long 'xbee_con *
Public Declare Function xbee_newcon_16bit Lib "libxbee.dll" (ByVal frameID As Byte, ByVal conType As Long, ByVal addr16bit As Long) As Long  'xbee_con *
Public Declare Function xbee_newcon_64bit Lib "libxbee.dll" (ByVal frameID As Byte, ByVal conType As Long, ByVal addr64bitLow As Long, ByVal addr64bitHigh As Long) As Long  'xbee_con *

Private Declare Sub xbee_attachCallbackRaw Lib "libxbee.dll" Alias "xbee_attachCallback" (ByVal con As Long, ByVal hWnd As Long, ByVal uMsg As Long)
Public Declare Sub xbee_detachCallback Lib "libxbee.dll" (ByVal con As Long)
Private Declare Function xbee_runCallback Lib "libxbee.dll" (ByVal func As Long, ByVal con As Long, ByVal pkt As Long) As Long

Public Declare Sub xbee_endcon Lib "libxbee.dll" Alias "xbee_endcon2" (ByVal con As Long)
Public Declare Sub xbee_flushcon Lib "libxbee.dll" (ByVal con As Long)

Public Declare Function xbee_senddata Lib "libxbee.dll" Alias "xbee_nsenddata" (ByVal con As Long, ByRef data() As Byte, ByVal Length As Long) As Long
Private Declare Function xbee_senddata_str Lib "libxbee.dll" Alias "xbee_nsenddata" (ByVal con As Long, ByVal data As String, ByVal Length As Long) As Long

Public Declare Function xbee_getpacketRaw Lib "libxbee.dll" Alias "xbee_getpacket" (ByVal con As Long) As Long 'xbee_pkt *

Public Declare Function xbee_hasanalog Lib "libxbee.dll" (ByRef pkt As xbee_pkt, ByVal sample As Long, ByVal inputPin As Long) As Long
Public Declare Function xbee_getanalog Lib "libxbee.dll" (ByRef pkt As xbee_pkt, ByVal sample As Long, ByVal inputPin As Long, ByVal Vref As Double) As Double

Public Declare Function xbee_hasdigital Lib "libxbee.dll" (ByRef pkt As xbee_pkt, ByVal sample As Long, ByVal inputPin As Long) As Long
Public Declare Function xbee_getdigital Lib "libxbee.dll" (ByRef pkt As xbee_pkt, ByVal sample As Long, ByVal inputPin As Long) As Long

Private Declare Function xbee_svn_versionRaw Lib "libxbee.dll" Alias "xbee_svn_version" () As Long

'###########################################################################################################################################################################

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private Declare Function lstrlenW Lib "kernel32" (ByVal lpString As Long) As Long
Private Declare Function RegisterWindowMessage Lib "user32" Alias "RegisterWindowMessageA" (ByVal lpString As String) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Private Const CUSTOM_MSG_MIN = 49152
Private Const CUSTOM_MSG_MAX = 65535
Private Const GWL_WNDPROC = -4

Public Function PointerToString(lngPtr As Long) As String
   Dim strTemp As String
   Dim lngLen As Long
   If lngPtr Then
      lngLen = lstrlenW(lngPtr) * 2
      If lngLen Then
         strTemp = Space(lngLen)
         CopyMemory ByVal strTemp, ByVal lngPtr, lngLen
         PointerToString = Replace(strTemp, Chr(0), "")
      End If
   End If
End Function

Public Function PointerToPacket(lngPtr As Long) As xbee_pkt
    Dim p As xbee_pkt
    CopyMemory p, ByVal lngPtr, Len(p)
    PointerToPacket = p
End Function

Public Sub libxbee_load()
    ' this function is simply to get VB6 to call a libxbee function
    ' if you are using any C DLLs that make use of libxbee, then you should call this function first so that VB6 will load libxbee
    xbee_svn_versionRaw
End Sub

Public Function xbee_svn_version() As String
    xbee_svn_version = PointerToString(xbee_svn_versionRaw())
End Function

Public Function xbee_setupAPI(ByVal port As String, ByVal baudRate As Long, ByVal cmdSeq As String, ByVal cmdTime As Long)
    xbee_setupAPI = xbee_setupAPIRaw(port, baudRate, Asc(cmdSeq), cmdTime)
End Function

Public Sub xbee_attachCallback(ByVal con As Long, ByVal func As Long)
    Dim t As Long
    If ActhWndHandler = 0 Then
        Debug.Print "Callbacks not enabled!"
        Exit Sub
    End If
    t = RegisterWindowMessage(CStr(con))
    xbee_attachCallbackRaw con, ActhWndHandler, t
    On Error Resume Next
    Err.Clear
    Callbacks.Add func, CStr(con)
    If Err.Number <> 0 Then
        Callbacks.Item(con) = CStr(func)
    End If
End Sub

Private Function windowMsgHandler(ByVal hWnd As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    If (uMsg >= CUSTOM_MSG_MIN) And (uMsg <= CUSTOM_MSG_MAX) Then
        Dim t As Long
        On Error Resume Next
        Err.Clear
        t = Callbacks.Item(CStr(wParam))
        If Err.Number = 0 Then
            windowMsgHandler = xbee_runCallback(t, wParam, lParam)
            Exit Function
        End If
        On Error GoTo 0
    End If
    
    windowMsgHandler = CallWindowProc(OldhWndHandler, hWnd, uMsg, wParam, lParam)
End Function

Public Sub xbee_enableCallbacks(ByVal hWnd As Long)
    If ActhWndHandler <> 0 Then
        Debug.Print "Callbacks already enabled!"
        Exit Sub
    End If
    ActhWndHandler = hWnd
    OldhWndHandler = SetWindowLong(hWnd, GWL_WNDPROC, AddressOf libxbee.windowMsgHandler)
    Set Callbacks = Nothing
    Set Callbacks = New Collection
End Sub

Public Sub xbee_disableCallbacks()
    If ActhWndHandler = 0 Then
        Debug.Print "Callbacks not enabled!"
        Exit Sub
    End If
    SetWindowLong ActhWndHandler, GWL_WNDPROC, OldhWndHandler
    ActhWndHandler = 0
    OldhWndHandler = 0
End Sub

Public Function xbee_sendstring(ByVal con As Long, ByVal str As String)
    xbee_sendstring = xbee_senddata_str(con, str, Len(str))
End Function

Public Function xbee_getpacketPtr(ByVal con As Long, ByRef pkt As Long) As Integer
    Dim ptr As Long
    
    ptr = xbee_getpacketRaw(con)
    If ptr = 0 Then
        pkt = 0
        xbee_getpacketPtr = 0
        Exit Function
    End If
    
    pkt = ptr
    xbee_getpacketPtr = 1
End Function

Public Function xbee_getpacket(ByVal con As Long, ByRef pkt As xbee_pkt) As Integer
    Dim ptr As Long
    
    ptr = xbee_getpacketRaw(con)
    If ptr = 0 Then
        xbee_getpacket = 0
        Exit Function
    End If
    
    pkt = PointerToPacket(ptr)
    xbee_free ptr
    
    xbee_getpacket = 1
End Function

