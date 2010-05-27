VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2250
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   4395
   LinkTopic       =   "Form1"
   ScaleHeight     =   2250
   ScaleWidth      =   4395
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox tb 
      Height          =   1995
      Left            =   660
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   3615
   End
   Begin VB.Timer Timer1 
      Interval        =   10
      Left            =   120
      Top             =   720
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim myCon As Long
Dim timeout As Integer

Private Sub Form_Load()
    Dim i As Long
    Dim x As Byte
    Dim ctype, addrH, addrL As Long
    Me.Show
    DoEvents
    
    ' Connect to the XBee on COM1 with a baud rate of 57600
    ' The XBee should be in API mode 2 (ATAP2)
    If xbee_setup("COM1", 57600) <> 0 Then
        MsgBox "Error while setting up the local XBee module", vbCritical, "xbee_setup()"
        End
    End If
    
    ' Create a Remote AT connection to a node using 64-bit addressing
    myCon = xbee_newcon_64bit(&H30, xbee_64bitRemoteAT, &H13A200, &H403CB26A)
    
    ' Send the AT command NI (Node Identifier)
    tb.Text = "Sending 'ATNI'..."
    xbee_sendstring myCon, "NI"
    timeout = 100
    
End Sub

Private Sub Timer1_Timer()
    Dim thePkt As xbee_pkt
    Dim i As Integer
    
    ' Check if a packet is avaliable on the connection
    If xbee_getpacket(myCon, thePkt) = 0 Then
        timeout = timeout - 1
        If timeout = 0 Then
            Timer1.Enabled = False
            tb.Text = tb.Text & vbNewLine & "The command timedout..."
        End If
        Exit Sub
    End If
    
    ' If it is, disable this timer
    Timer1.Enabled = False
    
    ' Check the returned status, if it isnt 0 then an error occured
    If thePkt.status <> 0 Then
        tb.Text = tb.Text & vbNewLine & "An error occured (" & thePkt.status & ")"
        Exit Sub
    End If
    
    ' Display the Node Identifier
    tb.Text = tb.Text & vbNewLine & "Node Identifier:"
    For i = 0 To thePkt.datalen
        tb.Text = tb.Text & Chr(thePkt.data(i))
    Next
End Sub
