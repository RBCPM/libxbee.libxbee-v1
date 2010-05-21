VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3030
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   17460
   LinkTopic       =   "Form1"
   ScaleHeight     =   3030
   ScaleWidth      =   17460
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Interval        =   100
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
    
    xbee_setup "COM5", 57600
    
    myCon = xbee_newcon_64bit(&H30, xbee_64bitData, &H13A200, &H404B75DE)
    
    xbee_sendstring myCon, "TESTING!"
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    xbee_end
    End
End Sub

Private Sub Timer1_Timer()
    Dim thePkt As xbee_pkt
    Dim ret As Integer
    Do
        ret = xbee_getpacket(myCon, thePkt)
        If (ret = 0) Then Exit Do
        Me.Caption = thePkt.datalen & " -=- " & _
                        thePkt.data(0) & " -=- " & _
                        thePkt.Addr16(0) & " " & thePkt.Addr16(1) & " -=- " & _
                        thePkt.Addr64(0) & " " & thePkt.Addr64(1) & " " & thePkt.Addr64(2) & " " & thePkt.Addr64(3) & " " & _
                        thePkt.Addr64(4) & " " & thePkt.Addr64(5) & " " & thePkt.Addr64(6) & " " & thePkt.Addr64(7) & " -=- " & _
                        "-" & thePkt.RSSI & "dB"
        xbee_sendstring myCon, Chr(thePkt.data(0))
    Loop Until ret = 0
End Sub
