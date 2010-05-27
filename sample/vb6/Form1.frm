VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3030
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   6270
   LinkTopic       =   "Form1"
   ScaleHeight     =   3030
   ScaleWidth      =   6270
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox tb 
      Height          =   1995
      Left            =   1980
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   420
      Width           =   3615
   End
   Begin VB.Timer Timer1 
      Interval        =   10
      Left            =   960
      Top             =   1320
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim myCon As Long
Dim pkt As xbee_pkt

Private Sub Form_Load()
    Dim i As Long
    Dim x As Byte
    Dim ctype, addrH, addrL As Long
    Me.Show
    DoEvents
    
    If xbee_setup("COM8", 57600) <> 0 Then
        MsgBox "Error while setting up the local XBee module", vbCritical, "xbee_setup()"
        End
    End If
    
    myCon = xbee_newcon_64bit(&H30, xbee_64bitRemoteAT, &H13A200, &H403CB26A)
    
    tb.Text = "Sending 'ATNI'..."
    xbee_sendstring myCon, "NI"
    
End Sub

Private Sub Timer1_Timer()
    Dim thePkt As xbee_pkt
    Dim i As Integer
    
    If xbee_getpacket(myCon, thePkt) = 0 Then
        Exit Sub
    End If
    Timer1.Enabled = False
    tb.Text = tb.Text & vbNewLine & "Node Identifier:" & vbTab
    For i = 0 To thePkt.datalen
        tb.Text = tb.Text & Chr(thePkt.data(i))
    Next
End Sub
