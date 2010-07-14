VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2250
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   3855
   LinkTopic       =   "Form1"
   ScaleHeight     =   2250
   ScaleWidth      =   3855
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox tb 
      Height          =   1995
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   3615
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim myCon As Long
Dim myDataCon As Long

Private Sub Form_Load()
    Dim i As Long
    Dim x As Byte
    Dim ctype, addrH, addrL As Long
    Me.Show
    DoEvents
    
    ' Enable callbacks, this only needs doing ONCE
    ' The window handle provided must remain in memory (dont unload the form)
    xbee_enableCallbacks Me.hWnd
    
    ' Connect to the XBee on COM1 with a baud rate of 57600
    ' The XBee should be in API mode 2 (ATAP2)
    If xbee_setup("COM1", 57600) <> 0 Then
        MsgBox "Error while setting up the local XBee module", vbCritical, "xbee_setup()"
        End
    End If
    
    ' Create a Remote AT connection to a node using 64-bit addressing
    myCon = xbee_newcon_64bit(&H30, xbee_64bitRemoteAT, &H13A200, &H404B75DE)
    myDataCon = xbee_newcon_64bit(&H31, xbee_64bitData, &H13A200, &H404B75DE)
    
    ' Send the AT command NI (Node Identifier)
    tb.Text = "Sending 'ATNI'..."
    xbee_sendstring myCon, "NI"
    
    xbee_attachCallback myCon, AddressOf Module1.callback1
    xbee_attachCallback myDataCon, AddressOf Module1.callback2
End Sub

Private Sub Form_Unload(Cancel As Integer)
    xbee_disableCallbacks
End Sub

