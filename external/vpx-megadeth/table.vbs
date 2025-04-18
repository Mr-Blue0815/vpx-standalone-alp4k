' ****************************************************************
'                          VISUAL PINBALL X .7
' 				 				MEGADETH
'    based on: JPSalas Serious Sam Pinball II v3 Script
'  plain VPX script using core.vbs for supporting functions
'                            Script Version 1.32
' ****************************************************************

' DOF Triggers (VPCLE)
' E101		Left Flipper
' E102		Right Flipper
' E105		Left Slingshot
' E106		Right Slingshot
' E110		Chopper Blades On
' E111		Start Battle
' E112		Nuke Bomb Spinning
' E113		Target 12 (Lower Left PF)
' E114		Target 10 (Right Inner)
' E115		Target 1 (Right Reload)
' E116		Target 13 (Left Reload)
' E117		Ball Locked
' E118		GI ON
' E119		VUK
' E120		Target 4 (Left Inner)
' E121		Canon Fire/Auto plunger
' E122		Knocker
' E123		Ball Kick into Shooter Lane
' E124		Spinner 2 (R)
' E125		Credits Exist or Freeplay Mode (ON/OFF)
' E126		Thunder
' E127		Skill Shot
' E128		SW 1 Hit (Top Lane Left)
' E129		SW 6 Hit (Top Lane Right)
' E130		SW 8 (Left Orbital)
' E131		SW 7 (Right Orbital)
' E132		SW 2 Hit (Left Outlane) - NOT LIT
' E133		SW 4 Hit (Left Inlane) - NOT LIT
' E134		SW 3 Hit (Right Inlane) - NOT LIT
' E135		SW 5 Hit (Right Outlane) - NOT LIT
' E136		Spinner 1 (L)
' E137		Bumper #3 (Center)
' E138		Bumper #1 (Upper Left)
' E139		Battle Compare
' E140		Bumper #2 (Upper Right)
' E141		Auto Plunger
' E142		Release Dropped Ball
' E143		Multiball (ON/OFF)
' E144		Ball in Plunger Lane (ON/OFF)
' E145		Attract Mode (ON/OFF)
' E146		Ball Drain
' E147		Ball Has Been Launched
' E148		SW 2 Hit (Left Outlane) - LIT
' E149		SW 5 Hit (Right Outlane) - LIT
' E150		Target 2 (Left Outer)
' E151		Target 5 (Center Left)
' E152		Target 7 (Center Right)
' E153		Target 8 (Right Outer)
' E155		SW 4 Hit (Left Inlane) - LIT
' E156		SW 3 Hit (Right Inlane) - LIT
' E157		Jackpot
' E158		Super Jackpot
' E159		TILT!
' E160		Game Over (ON/OFF)

Option Explicit
Randomize

'***************************************** USER OPTIONS****************************************
Const Videos = False					 ' If using PupPack = True 
Const FlexDMDHighQuality = True		' If using RealDMD set to False
Dim VRRoomChoice: VRRoomChoice = 1   '1 = Prison Room  2 = Minimal Room  3 = Ultra Minimal Room.
'***************MINI GAME ***************************** AOR

'Const bIsMiniGameActive = 0  'is Minigame Active   Don't Launch MiniGame = 0,  Launch Minigame = 1, using Const Videos variable, line 69 :) 
Const PupScreenMiniGame = 2  '5 = FullDMD, Backglass = 2
'*****************************************END OF USER OPTIONS**********************************
'Minigame variable AOR
Dim iMiniGameCnt(4) 'reset to zero on game init, adds one each time player plays minigame (limits to 1 minigame per Player, per Game)
' Scorbit Variables:
Const ScorbitActive				= 0 	' Is Scorbit Active	
Const     ScorbitShowClaimQR		= 0	' If Scorbit is active this will show a QR Code in the bottom left on ball 1 that allows player to claim the active player from the app
Const     ScorbitClaimSmall			= 0	' Make Claim QR Code smaller for high res backglass 
Const     ScorbitUploadLog			= 0	' Store local log and upload after the game is over 
Const     ScorbitAlternateUUID 	 	= 0 	' Force Alternate UUID from Windows Machine and saves it in VPX Users directory (C:\Visual Pinball\User\ScorbitUUID.dat)
Dim TablesDir : TablesDir = GetTablesFolder

Const BallSize = 50    ' 50 is the normal size used in the core.vbs, VP kicker routines uses this value divided by 2
Const BallMass = 1   
Const SongVolume = 0.6 ' 1 is full volume. Value is from 0 to 1

' Define any Constants
Const cGameName = "Megadeth"
Const TableName = "Megadeth"
Const myVersion = "1.32"
Const MaxPlayers = 4     ' from 1 to 4
Const BallSaverTime = 20 ' in seconds
Const MaxMultiplier = 5  ' limit to 5x in this game, both bonus multiplier and playfield multiplier
Const BallsPerGame = 3   ' usually 3 or 5
Const MaxMultiballs = 5  ' max number of balls during multiballs

'----- General Sound Options -----
Const VolumeDial = 0.9			  'Overall Mechanical sound effect volume. Recommended values should be no greater than 1.
Const BallRollVolume = 0.6		  'Level of ball rolling volume. Value between 0 and 1
Const RampRollVolume = 0.6		  'Level of ramp rolling volume. Value between 0 and 1

Const tnob = 10
Const lob = 2
Dim tablewidth:tablewidth = Table1.width
Dim tableheight:tableheight = Table1.height
Dim gilvl: gilvl = 1

' Use FlexDMD if in FS mode
Dim UseFlexDMD
If Table1.ShowDT = True then
    UseFlexDMD = False
Else
    UseFlexDMD = True
End If

' Load the core.vbs for supporting Subs and functions
LoadCoreFiles

Sub LoadCoreFiles
    On Error Resume Next
    ExecuteGlobal GetTextFile("core.vbs")
    If Err Then MsgBox "Can't open core.vbs"
    ExecuteGlobal GetTextFile("controller.vbs")
    If Err Then MsgBox "Can't open controller.vbs"
    On Error Goto 0
End Sub

' VR Room Auto-Detect
' VR uses FlexDMD to display DMD.
Dim VR_Obj

If RenderingMode = 2 Then
    UseFlexDMD = True
	lrail.Visible = 0
	rrail.Visible = 0
	Flasher2.Visible = 0
	Flasher3.Visible = 0
	Primitive002.Size_X = 28
	Primitive002.Size_Y = 28
	Primitive002.Size_Z = 28
	rhand.Size_X = 80
	rhand.Size_Y = 80
	rhand.Size_Z = 80
	lhand.Size_X = -80
	lhand.Size_Y = -80
	lhand.Size_Z = -80
	Primitive084.Size_X = 2200
	Primitive084.Size_Y = 2200
	Primitive084.Size_Z = 2200
	Primitive084.z = 130
	Primitive085.Size_X = 2200
	Primitive085.Size_Y = 2200
	Primitive085.Size_Z = 2200
	Primitive085.z = 130
	Primitive086.Size_X = 2200
	Primitive086.Size_Y = 2200
	Primitive086.Size_Z = 2200
	Primitive086.z = 130
	Primitive091.Size_X = 90
	Primitive091.Size_Y = 90
	Primitive091.Size_Z = 90
	Nuke.Size_X = 0.4
	Nuke.Size_Y = 0.55
	Nuke.Size_Z = 0.4
	Vic.Size_X = 28
	Vic.Size_Y = 28
	Vic.Size_Z = 28
	Pincab_Backglass.BlendDisableLighting = 1

	If VRRoomChoice = 1 then 
		For Each VR_Obj in aDMD:VR_Obj.Visible = 0:Next
		For Each VR_Obj in VRCabinet:VR_Obj.Visible = 1:Next
		For Each VR_Obj in VRRoomPrison:VR_Obj.Visible = 1:Next
		StrobeTimer.enabled = true
		'StrobeRandomSlow
		VRAttractTimer.enabled = true
	End if

	If VRRoomChoice = 2 then 
		For Each VR_Obj in aDMD:VR_Obj.Visible = 0:Next
		For Each VR_Obj in VRCabinet:VR_Obj.Visible = 1:Next
		For Each VR_Obj in VRRoom:VR_Obj.Visible = 1:Next
		PinCab_Cabinet.image = "PinCab_Cabinet"
		PinCab_Backbox.image = "PinCab_Backbox"
		PinCab_Metal.blenddisablelighting = 0.4
		PinCab_Shooter.blenddisablelighting = 0.4
		PinCab_Housing.blenddisablelighting = 0.4
		PinCab_Metal_Fittings.blenddisablelighting = 0.4
		Primary_VRBackleftLeg.blenddisablelighting = 0.4
		Primary_VRBackRightLeg.blenddisablelighting = 0.4
		PinCab_Cabinet.blenddisablelighting = 0.4
		PinCab_Backbox.blenddisablelighting = 0.4
		PinCab_Right_Flipper_Button.blenddisablelighting = 0.4
		PinCab_Right_Flipper_Button_Rin.blenddisablelighting = 0.4
		PinCab_Left_Flipper_Button_Ring.blenddisablelighting = 0.4
		PinCab_Left_Flipper_Button.blenddisablelighting = 0.4
	End if

	If VRRoomChoice = 3 then 	
		PinCab_Backbox.visible = true
		PinCab_Backbox.blenddisablelighting = 0.4
		VR_DMD.visible = true
		PinCab_Backglass.visible = true
		PinCab_Metal.visible = true
	End if

End If

' Define Global Variables
Dim PlayersPlayingGame
Dim CurrentPlayer
Dim Credits
Dim BonusPoints(4)
Dim BonusHeldPoints(4)
Dim BonusMultiplier(4)
Dim PlayfieldMultiplier(4)
Dim bBonusHeld
Dim BallsRemaining(4)
Dim ExtraBallsAwards(4)
Dim Score(4)
Dim HighScore(4)
Dim HighScoreName(4)
Dim Jackpot(4)
Dim SuperJackpot
Dim Tilt
Dim TiltSensitivity
Dim Tilted
Dim TotalGamesPlayed
Dim mBalls2Eject
Dim SkillshotValue(4)
Dim bAutoPlunger
Dim bInstantInfo
Dim bAttractMode

' Define Game Control Variables
Dim LastSwitchHit
Dim BallsOnPlayfield
Dim BallsInLock(4)
Dim BallsInHole

' Define Game Flags
Dim bFreePlay
Dim bGameInPlay
Dim bOnTheFirstBall
Dim bBallInPlungerLane
Dim bBallSaverActive
Dim bBallSaverReady
Dim bMultiBallMode
Dim bMusicOn
Dim bSkillshotReady
Dim bExtraBallWonThisBall
Dim bJustStarted
Dim bJackpot
Dim bSongSelect

' core.vbs variables
Dim plungerIM 'used mostly as an autofire plunger during multiballs
Dim cbRight   'captive ball
Dim bsJackal
Dim ttSpinDisk
Dim x

' *********************************************************************
'                Visual Pinball Defined Script Events
' *********************************************************************

Sub Table1_Init()
    LoadEM
    Dim i
    Randomize

    'Impulse Plunger as autoplunger
    Const IMPowerSetting = 36 ' Plunger Power
    Const IMTime = 1.1        ' Time in seconds for Full Plunge
    Set plungerIM = New cvpmImpulseP
    With plungerIM
        .InitImpulseP swplunger, IMPowerSetting, IMTime
        .Random 1.5
        .InitExitSnd SoundFXDOF("fx_kicker", 141, DOFPulse, DOFContactors), SoundFXDOF("fx_solenoid", 141, DOFPulse, DOFContactors)
        .CreateEvents "plungerIM"
    End With
	
    Set cbRight = New cvpmCaptiveBall
    With cbRight
        .InitCaptive CapTrigger1, CapWall1, Array(CapKicker1, CapKicker1a), 0
        .NailedBalls = 1
        .ForceTrans = .9
        .MinForce = 3.5
        '.CreateEvents "cbRight"
        .Start
    End With
    CapKicker1.CreateSizedBallWithMass BallSize / 2, BallMass

    ' Jackal hole
    Set bsJackal = New cvpmTrough
    With bsJackal
        .size = 5
        .Initexit JackalHole, 160, 35
        '.InitExitVariance 2, 2
        .MaxBallsPerKick = 1
    End With

    ' Turn Table - Spinner disk
    Set ttSpinDisk = New cvpmTurnTable
    With ttSpinDisk
        .InitTurnTable SpinningDiskTrigger1, 50
        .spinCW = True
        .SpinUp = 5
        .SpinDown = 3
        .MotorOn = False
        .CreateEvents "ttSpinDisk"
    End With

    ' Misc. VP table objects Initialisation, droptargets, animations...
    VPObjects_Init

    ' load saved values, highscore, names, jackpot
    Loadhs

    ' Initalise the DMD display
    DMD_Init

    ' freeplay or coins
    bFreePlay = True 'we want coins

    if bFreePlay Then DOF 125, DOFOn

    ' Init main variables and any other flags
    bAttractMode = False
    bOnTheFirstBall = False
    bBallInPlungerLane = False
    bBallSaverActive = False
    bBallSaverReady = False
    bMultiBallMode = False
    bGameInPlay = False
    bAutoPlunger = False
	If Videos = True Then bMusicOn = False : End If
	If Videos = False Then bMusicOn = True : End If
    BallsOnPlayfield = 0
    BallsInLock(1) = 0
    BallsInLock(2) = 0
    BallsInLock(3) = 0
    BallsInLock(4) = 0
    BallsInHole = 0
    LastSwitchHit = ""
    Tilt = 0
    TiltSensitivity = 6
    Tilted = False
    bBonusHeld = False
    bJustStarted = True
    bJackpot = False
    bInstantInfo = False
    bSongSelect = True
    ' set any lights for the attract mode
    GiOff
    StartAttractMode
	If Videos = False Then PlayRandomSong : End If
	'PlayRandomSong
	'PLaySelectedSong
    ' Start the RealTime timer
    RealTime.Enabled = 1
	'PlaySong "m_AngryAgain"
    ' Load table color
    LoadLut

	StartScorbit() 

End Sub

'******************
' Captive Ball Subs
'******************
Sub CapTrigger1_Hit:cbRight.TrigHit ActiveBall:End Sub
Sub CapTrigger1_UnHit:cbRight.TrigHit 0:End Sub
Sub CapWall1_Hit:cbRight.BallHit ActiveBall:PlaySoundAtBall "fx_collide":Shaketank: End Sub
Sub CapKicker1a_Hit:cbRight.BallReturn Me:End Sub

'******
' Keys
'******
Const ReflipAngle = 20

Sub Table1_KeyDown(ByVal Keycode)

    If keycode = LeftMagnaSave Then bLutActive = True
    If keycode = RightMagnaSave Then
        If bLutActive Then NextLUT:End If
    End If

    If Keycode = AddCreditKey Then
        Credits = Credits + 1
        if bFreePlay = False Then DOF 125, DOFOn
        If(Tilted = False)Then
            DMDFlush
            DMD "_", CL(1, "CREDITS: " & Credits), "", eNone, eNone, eNone, 500, True, "fx_coin"
            If NOT bGameInPlay Then ShowTableInfo
			bsongSelect = True
        End If
    End If

    If keycode = PlungerKey Then
        Plunger.Pullback
        SoundPlungerPull()
        PlaySoundAt "fx_reload", plunger
		TimerVRPlunger.Enabled = True
		TimerVRPlunger2.Enabled = False
    End If

	If keycode = LeftFlipperKey Then
		if Renderingmode = 2 and VRRoomChoice < 3 then PinCab_Left_Flipper_Button.X = PinCab_Left_Flipper_Button.X + 10
	End If

	If keycode = RightFlipperKey Then
		if Renderingmode = 2 and VRRoomChoice < 3 then PinCab_Right_Flipper_Button.X = PinCab_Right_Flipper_Button.X - 10
	End If

    If hsbModeActive Then
        EnterHighScoreKey(keycode)
        Exit Sub
    End If

    ' Table specific
    If bsongSelect Then
        SelectSong(keycode)
    End If

    ' Normal flipper action
    If bGameInPlay AND NOT Tilted Then

        If keycode = LeftTiltKey Then Nudge 90, 8:SoundNudgeLeft():CheckTilt
        If keycode = RightTiltKey Then Nudge 270, 8:SoundNudgeRight():CheckTilt
        If keycode = CenterTiltKey Then Nudge 0, 9:SoundNudgeCenter():CheckTilt

        If keycode = LeftFlipperKey Then 

			If PuPGameRunning Then 'AOR
			PuPGameInfo= PuPlayer.GameUpdate(PuPMiniGameTitle, 1 , 87 , "")  'w
			Else
		
		

		DOF 101, DOFOn						'VPCLE
        leftflipper.enabled= true
		FlipperActivate LeftFlipper, LFPress
        SolLFlipper 1:InstantInfoTimer.Enabled = True 
        end if  
			End If 'AOR
		
        If keycode = RightFlipperKey Then 

				If PuPGameRunning Then 'AOR
				PuPGameInfo= PuPlayer.GameUpdate(PuPMiniGameTitle, 1 , 83 , "")  's
				Else

			DOF 102, DOFOn						'VPCLE
             rightflipper.enabled= true 
			 FlipperActivate RightFlipper, RFPress
            SolRFlipper 1:InstantInfoTimer.Enabled = True 
         end if
				end if 'AOR

        If keycode = StartGameKey Then

            If((PlayersPlayingGame < MaxPlayers)AND(bOnTheFirstBall = True))Then

                If(bFreePlay = True)Then
                    PlayersPlayingGame = PlayersPlayingGame + 1
                    TotalGamesPlayed = TotalGamesPlayed + 1
                    DMD "_", CL(1, PlayersPlayingGame & " PLAYERS"), "", eNone, eBlink, eNone, 500, True, "so_fanfare1"
                Else
                    If(Credits > 0)then
                        PlayersPlayingGame = PlayersPlayingGame + 1
                        TotalGamesPlayed = TotalGamesPlayed + 1
                        Credits = Credits - 1
                        DMD "_", CL(1, PlayersPlayingGame & " PLAYERS"), "", eNone, eBlink, eNone, 500, True, "so_fanfare1"
                        If Credits < 1 And bFreePlay = False Then DOF 125, DOFOff:DOF 160, DOFOff		'VPCLE
                        Else
                            ' Not Enough Credits to start a game.
                            DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 500, True, "so_nocredits"
                    End If
                End If
            End If
        End If
        Else ' If (GameInPlay)

            If keycode = StartGameKey Then
                If(bFreePlay = True)Then
                    If(BallsOnPlayfield = 0)Then
                        ResetForNewGame()
                    End If
                Else
                    If(Credits > 0)Then
                        If(BallsOnPlayfield = 0)Then
                            Credits = Credits - 1
                            If Credits < 1 And bFreePlay = False Then DOF 125, DOFOff
                            ResetForNewGame()
                        End If
                    Else
                        ' Not Enough Credits to start a game.
                        DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 500, True, "so_nocredits"
                        ShowTableInfo
                    End If
                End If
            End If
    End If ' If (GameInPlay)

'test keys
If keycode = "3" Then

StartSpinner
'aor
'AwardSkillshot 'testing picks

end If

End Sub

Sub Table1_KeyUp(ByVal keycode)

    If keycode = LeftMagnaSave Then bLutActive = False

    If keycode = PlungerKey Then
        Plunger.Fire 
        If bBallInPlungerLane Then
			SoundPlungerReleaseBall()
		Else
			SoundPlungerReleaseNoBall() 
		End If
		if Renderingmode = 2 and VRRoomChoice < 3 then TimerVRPlunger.Enabled = False
		if Renderingmode = 2 and VRRoomChoice < 3 then TimerVRPlunger2.Enabled = True
		Pincab_Shooter.Y = 0
    End If

	If keycode = LeftFlipperKey Then
			If PuPGameRunning Then 'AOR
		PuPGameInfo= PuPlayer.GameUpdate(PuPMiniGameTitle, 2 , 87 , "")  'w
		Else

		if Renderingmode = 2 and VRRoomChoice < 3 then PinCab_Left_Flipper_Button.X = PinCab_Left_Flipper_Button.X - 10
	End If
		end if 'AOR
	If keycode = RightFlipperKey Then
		If PuPGameRunning Then 'AOR
		PuPGameInfo= PuPlayer.GameUpdate(PuPMiniGameTitle, 2 , 83 , "")  'w
	
		Else

		if Renderingmode = 2 and VRRoomChoice < 3 then PinCab_Right_Flipper_Button.X = PinCab_Right_Flipper_Button.X + 10
	End If
		end if 'AOR
    If hsbModeActive Then
        Exit Sub
    End If

    ' Table specific
    If bGameInPLay AND NOT Tilted Then
        If keycode = LeftFlipperKey Then
			DOF 101, DOFOff						'VPCLE
			FlipperDeActivate LeftFlipper, LFPress
            SolLFlipper 0
            InstantInfoTimer.Enabled = False
            If bInstantInfo Then
                DMDScoreNow
                bInstantInfo = False
            End If
        End If
        If keycode = RightFlipperKey Then
			DOF 102, DOFOff						'VPCLE
            FlipperDeActivate RightFlipper, RFPress
            SolRFlipper 0
            InstantInfoTimer.Enabled = False
            If bInstantInfo Then
                DMDScoreNow
                bInstantInfo = False
            End If
        End If
    End If

If keycode = "3" Then StopSpinner
End Sub

Sub InstantInfoTimer_Timer
    InstantInfoTimer.Enabled = False
    If NOT hsbModeActive Then
        bInstantInfo = True
        DMDFlush
        InstantInfo
    End If
End Sub

Sub InstantInfo
    DMD CL(0, "INSTANT INFO"), "", "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "JACKPOT VALUE"), CL(1, Jackpot(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "SPINNER VALUE"), CL(1, spinnervalue(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "BUMPER VALUE"), CL(1, bumpervalue(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "BONUS X"), CL(1, BonusMultiplier(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "PLAYFIELD X"), CL(1, PlayfieldMultiplier(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "LOCKED BALLS"), CL(1, BallsInLock(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "LANE BONUS"), CL(1, LaneBonus), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "TARGET BONUS"), CL(1, TargetBonus), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "RAMP BONUS"), CL(1, RampBonus), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "CONCERTS ROCKED"), CL(1, MonstersKilled(CurrentPlayer)), "", eNone, eNone, eNone, 800, False, ""
    DMD CL(0, "HIGHEST SCORE"), CL(1, HighScoreName(0) & " " & HighScore(0)), "", eNone, eNone, eNone, 800, False, ""
End Sub

'*************
' Pause Table
'*************

Sub table1_Paused
End Sub

Sub table1_unPaused
End Sub

Sub Table1_Exit
    Savehs
    If UseFlexDMD Then FlexDMD.Run = False
    If B2SOn = true Then Controller.Stop
End Sub

'********************
'     Flippers
'********************

Sub SolLFlipper(Enabled)
    If Enabled Then
		LF.Fire
		If leftflipper.currentangle < leftflipper.endangle + ReflipAngle Then 
			RandomSoundReflipUpLeft LeftFlipper
		Else 
			SoundFlipperUpAttackLeft LeftFlipper
			RandomSoundFlipperUpLeft LeftFlipper
		End If		
	Else
		LeftFlipper.RotateToStart
		If LeftFlipper.currentangle < LeftFlipper.startAngle - 5 Then
			RandomSoundFlipperDownLeft LeftFlipper
		End If
		FlipperLeftHitParm = FlipperUpSoundLevel
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
		RF.Fire
		If rightflipper.currentangle > rightflipper.endangle - ReflipAngle Then
			RandomSoundReflipUpRight RightFlipper
			'RotateLaneLightsRight
		Else 
			SoundFlipperUpAttackRight RightFlipper
			RandomSoundFlipperUpRight RightFlipper
			'RotateLaneLightsRight
		End If
	Else
		RightFlipper.RotateToStart
		If RightFlipper.currentangle > RightFlipper.startAngle + 5 Then
			RandomSoundFlipperDownRight RightFlipper
		End If	
		FlipperRightHitParm = FlipperUpSoundLevel
    End If
End Sub

Sub LeftFlipper_Collide(parm)
	LeftFlipperCollide parm
End Sub

Sub RightFlipper_Collide(parm)
	RightFlipperCollide parm
End Sub

'*********
' TILT
'*********

'NOTE: The TiltDecreaseTimer Subtracts .01 from the "Tilt" variable every round

Sub CheckTilt                                    'Called when table is nudged
    Tilt = Tilt + TiltSensitivity                'Add to tilt count
    TiltDecreaseTimer.Enabled = True
    If(Tilt > TiltSensitivity)AND(Tilt < 15)Then 'show a warning
        DMD "_", CL(1, "CAREFUL!"), "_", eNone, eBlinkFast, eNone, 500, True, ""
		PlaySound "vo_carefull" 
    End if
    If Tilt > 15 Then 'If more that 15 then TILT the table
        DOF 159, DOFPulse		'VPCLE
	Tilted = True
        'display Tilt
        DMDFlush
        DMD "", "", "TILT", eNone, eNone, eBlink, 200, False, ""
		PlaySound "vo_tilt" 
        DisableTable True
        TiltRecoveryTimer.Enabled = True 'start the Tilt delay to check for all the balls to be drained
    End If
End Sub

Sub TiltDecreaseTimer_Timer
    ' DecreaseTilt
    If Tilt > 0 Then
        Tilt = Tilt - 0.1
    Else
        TiltDecreaseTimer.Enabled = False
    End If
End Sub

Sub DisableTable(Enabled)
    If Enabled Then
        'turn off GI and turn off all the lights
        GiOff
        LightSeqTilt.Play SeqAllOff
        'Disable slings, bumpers etc
        LeftFlipper.RotateToStart
        RightFlipper.RotateToStart
        Bumper1.Threshold = 100
        Bumper2.Threshold = 100
        Bumper3.Threshold = 100
        LeftSlingshot.Disabled = 1
        RightSlingshot.Disabled = 1
    Else
        'turn back on GI and the lights
        GiOn
        LightSeqTilt.StopPlay
        Bumper1.Threshold = 1
        Bumper2.Threshold = 1
        Bumper3.Threshold = 1
        LeftSlingshot.Disabled = 0
        RightSlingshot.Disabled = 0
        'clean up the buffer display
        DMDFlush
    End If
End Sub

Sub TiltRecoveryTimer_Timer()
    ' if all the balls have been drained then..
    If(BallsOnPlayfield = 0)Then
        ' do the normal end of ball thing (this doesn't give a bonus if the table is tilted)
        EndOfBall()
        TiltRecoveryTimer.Enabled = False
    End If
' else retry (checks again in another second or so)
End Sub

' Ramp Sounds
Sub LeftRampStart_Hit
	if VRRoomChoice = 1 then StrobeBlueLeft ' VR Callout
	WireRampOn False
	ActiveBall.VelY = ActiveBall.VelY * 1.05 ' Ramp Helper for balance
End Sub

Sub RightRampStart_Hit
	if VRRoomChoice = 1 then StrobeBlueRight ' VR Callout
	WireRampOn False
End Sub

'********************
' Music as wav sounds
'********************

Dim Song, Songnr
Song = ""
Songnr = INT(RND * 14)

Sub PlaySong(name)
    If bMusicOn Then
        If Song <> name Then
            StopSound Song
            Song = name
            PlaySound Song, -1, SongVolume
        End If
    End If
End Sub

Sub PlayRandomSong
    Songnr = INT(RND * 14)
    PLaySelectedSong :pupevent 900
End Sub
 
Sub PLaySelectedSong
			'StopSound Song
    Select Case Songnr
        Case 0:PlaySong "m_Trust" :DMD CL(0, "MEGADETH " ), CL(1, "TRUST"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 800
        Case 1:PlaySong "m_TornadoOfSouls": DMD CL(0, "MEGADETH " ), CL(1, "TORNADO OF SOULS"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 801
        Case 2:PlaySong "m_ThisWasMyLife": DMD CL(0, "MEGADETH " ), CL(1, "THIS WAS MY LIFE"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 802
        Case 3:PlaySong "m_TheScorpion": DMD CL(0, "MEGADETH " ), CL(1, "THE SCORPION"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 803
        Case 4:PlaySong "m_TakeNoPrisoners": DMD CL(0, "MEGADETH "), CL(1, "TAKE NO PRISONERS"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 804
        Case 5:PlaySong "m_SymphonyOfDestruction": DMD CL(0, "MEGADETH "), CL(1, "SYMPHONY DESTRUCTION"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 805
        Case 6:PlaySong "m_SweatingBullets":DMD CL(0, "MEGADETH "), CL(1, "SWEATING BULLETS"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 806
        Case 7:PlaySong "m_SkinOMyTeeth":DMD CL(0, "MEGADETH "), CL(1, "SKYN ON MY TEETH"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 807
        Case 8:PlaySong "m_PeaceSells":DMD CL(0, "MEGADETH " ), CL(1, "PEACE SELLS"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 808
        Case 9:PlaySong "m_DreadAndTheFugitiveMind":DMD CL(0, "MEGADETH "), CL(1, "DREAD&FUGITIVE MIND"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 809
        Case 10:PlaySong "m_CountdownToExtinction" : DMD CL(0, "MEGADETH "), CL(1, "COUNTDOWN EXTINCTION"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 810
        Case 11:PlaySong "m_AToutLMonde":DMD CL(0, "MEGADETH " ), CL(1, "ATOUT LMOUND"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 811
        Case 12:PlaySong "m_ArchitectureOfAggression": DMD CL(0, "MEGADETH "), CL(1, "ARCHIT.OF AGGRESSION"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 812
        Case 13::PlaySong "m_AngryAgain":DMD CL(0, "MEGADETH "), CL(1, "ANGRY AGAIN"), "", eNone, eBlink, eNone, 900, True, "" : pupevent 813
		'DMDFlush
    End Select
End Sub

Sub SelectSong(keycode)
    If keycode = PlungerKey Then
        bsongSelect = False
    End If
    If keycode = LeftFlipperKey Then
        Songnr = (Songnr - 1)MOD 14
        If Songnr <0 Then Songnr = 13
		PLaySelectedSong
 '       UpdateDMDSong
    End If
    If keycode = RightFlipperKey Then
        Songnr = (Songnr + 1)MOD 14
		PLaySelectedSong
 '       UpdateDMDSong
    End If
	'If keycode = StartGameKey Then
		'PlayRandomSong
	'End If
End Sub


'********************
' Play random quotes
'********************

Sub PlayQuote
    Dim tmp
    tmp = INT(RND * 68) + 1
    PlaySound "quote_" &tmp
End Sub

'**********************
'     GI effects
' independent routine
' it turns on the gi
' when there is a ball
' in play
'**********************

Dim OldGiState
OldGiState = -1   'start witht the Gi off

Sub ChangeGi(col) 'changes the gi color
    Dim bulb
    For each bulb in aGILights
        SetLightColor bulb, col, -1
    Next
End Sub

Sub GIUpdateTimer_Timer
    Dim tmp, obj
    tmp = Getballs
    If UBound(tmp) <> OldGiState Then
        OldGiState = Ubound(tmp)
        If UBound(tmp) = 1 Then 'we have 2 captive balls on the table (-1 means no balls, 0 is the first ball, 1 is the second..)
            GiOff               ' turn off the gi if no active balls on the table, we could also have used the variable ballsonplayfield.
        Else
            Gion
        End If
    End If
End Sub

Sub GiOn
    DOF 118, DOFOn
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 1
    Next
    For each bulb in aBumperLights
        bulb.State = 1
    Next
End Sub

Sub GiOff
    DOF 118, DOFOff
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 0
    Next
    For each bulb in aBumperLights
        bulb.State = 0
    Next
End Sub

' GI, light & flashers sequence effects

Sub GiEffect(n)
    Dim ii
    Select Case n
        Case 0 'all off
            LightSeqGi.Play SeqAlloff
        Case 1 'all blink
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqBlinking, , 15, 10
        Case 2 'random
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqRandom, 50, , 1000
        Case 3 'all blink fast
            LightSeqGi.UpdateInterval = 10
            LightSeqGi.Play SeqBlinking, , 10, 10
    End Select
End Sub

Sub LightEffect(n)
    Select Case n
        Case 0 ' all off
            LightSeqInserts.Play SeqAlloff
        Case 1 'all blink
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqBlinking, , 15, 10
        Case 2 'random
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqRandom, 50, , 1000
        Case 3 'all blink fast
            LightSeqInserts.UpdateInterval = 10
            LightSeqInserts.Play SeqBlinking, , 10, 10
    End Select
End Sub

Sub FlashEffect(n)
    Dim ii
    Select case n
        Case 0 ' all off
            LightSeqFlasher.Play SeqAlloff
        Case 1 'all blink
            LightSeqFlasher.UpdateInterval = 10
            LightSeqFlasher.Play SeqBlinking, , 10, 10
        Case 2 'random
            LightSeqFlasher.UpdateInterval = 10
            LightSeqFlasher.Play SeqRandom, 50, , 1000
        Case 3 'all blink fast
            LightSeqFlasher.UpdateInterval = 10
            LightSeqFlasher.Play SeqBlinking, , 5, 10
    End Select
End Sub

' *********************************************************************
'                        User Defined Script Events
' *********************************************************************

' Initialise the Table for a new Game
'
Sub ResetForNewGame()
	if VRRoomChoice = 1 then VRAttractTimer.enabled = false: SolidGreen ' VR Strobe Callout
    Dim i
	'PLaySelectedSong
    bGameInPLay = True
	'bsongSelect
    'resets the score display, and turn off attract mode
    StopAttractMode
    GiOn
	Playstart
    TotalGamesPlayed = TotalGamesPlayed + 1
    CurrentPlayer = 1
    PlayersPlayingGame = 1
    bOnTheFirstBall = True
    For i = 1 To MaxPlayers
        Score(i) = 0
        BonusPoints(i) = 0
        BonusHeldPoints(i) = 0
        BonusMultiplier(i) = 1
        PlayfieldMultiplier(i) = 1
        BallsRemaining(i) = BallsPerGame
        ExtraBallsAwards(i) = 0
    Next

	   
	If Not IsNull(Scorbit) Then
        If ScorbitActive = 1 And Scorbit.bNeedsPairing = False Then         
			Scorbit.StartSession()
        End If
    End If

    ' initialise any other flags
    Tilt = 0

    ' initialise Game variables
    Game_Init()

    ' you may wish to start some music, play a sound, do whatever at this point

    vpmtimer.addtimer 1500, "FirstBall '"
End Sub

' This is used to delay the start of a game to allow any attract sequence to
' complete.  When it expires it creates a ball for the player to start playing with

Sub FirstBall
    ' reset the table for a new ball
    ResetForNewPlayerBall()
    ' create a new ball in the shooters lane
    CreateNewBall()
	pupevent 852
End Sub

' (Re-)Initialise the Table for a new ball (either a new ball after the player has
' lost one or we have moved onto the next player (if multiple are playing))

Sub ResetForNewPlayerBall()
    ' make sure the correct display is upto date
    AddScore 0

    ' set the current players bonus multiplier back down to 1X
    SetBonusMultiplier 1

    ' reduce the playfield multiplier
	SetPlayfieldMultiplier 1

    ' reset any drop targets, lights, game Mode etc..

    BonusPoints(CurrentPlayer) = 0
    bBonusHeld = False
    bExtraBallWonThisBall = False

    'Reset any table specific
    ResetNewBallVariables
    ResetNewBallLights()

    'This is a new ball, so activate the ballsaver
    bBallSaverReady = True

    'and the skillshot
    bSkillShotReady = True
    'bSongSelect = True
'Change the music ?
End Sub

' Create a new ball on the Playfield

Sub CreateNewBall()
    ' create a ball in the plunger lane kicker.
    BallRelease.CreateSizedBallWithMass BallSize / 2, BallMass

    ' There is a (or another) ball on the playfield
    BallsOnPlayfield = BallsOnPlayfield + 1

    ' kick it out..
    PlaySoundAt SoundFXDOF("fx_Ballrel", 123, DOFPulse, DOFContactors), BallRelease
    BallRelease.Kick 90, 4

' if there is 2 or more balls then set the multibal flag (remember to check for locked balls and other balls used for animations)
' set the bAutoPlunger flag to kick the ball in play automatically
    If BallsOnPlayfield > 1 Then
        DOF 143, DOFOn				'VPCLE
        bMultiBallMode = True
        bAutoPlunger = True
		ChangeGi 5
    End If
End Sub

' Add extra balls to the table with autoplunger
' Use it as AddMultiball 4 to add 4 extra balls to the table

Sub AddMultiball(nballs)
    mBalls2Eject = mBalls2Eject + nballs
    CreateMultiballTimer.Enabled = True
    'and eject the first ball
    CreateMultiballTimer_Timer
End Sub

' Eject the ball after the delay, AddMultiballDelay
Sub CreateMultiballTimer_Timer()
    ' wait if there is a ball in the plunger lane
    If bBallInPlungerLane Then
        Exit Sub
    Else
        If BallsOnPlayfield < MaxMultiballs Then
            CreateNewBall()
            mBalls2Eject = mBalls2Eject -1
            If mBalls2Eject = 0 Then 'if there are no more balls to eject then stop the timer
                CreateMultiballTimer.Enabled = False
            End If
        Else 'the max number of multiballs is reached, so stop the timer
            mBalls2Eject = 0
            CreateMultiballTimer.Enabled = False
        End If
    End If
End Sub

' The Player has lost his ball (there are no more balls on the playfield).
' Handle any bonus points awarded

Sub EndOfBall()
    Dim AwardPoints, TotalBonus, ii
    AwardPoints = 0
    TotalBonus = 0
    ' the first ball has been lost. From this point on no new players can join in
    bOnTheFirstBall = False
	PlayBallLost
    ' only process any of this if the table is not tilted.  (the tilt recovery
    ' mechanism will handle any extra balls or end of game)

    If NOT Tilted Then

'add in any bonus points (multipled by the bonus multiplier)
'AwardPoints = BonusPoints(CurrentPlayer) * BonusMultiplier(CurrentPlayer)
'AddScore AwardPoints
'debug.print "Bonus Points = " & AwardPoints
'DMD "", CL(1, "BONUS: " & BonusPoints(CurrentPlayer) & " X" & BonusMultiplier(CurrentPlayer) ), "", eNone, eBlink, eNone, 1000, True, ""

'Count the bonus. This table uses several bonus
'Lane Bonus
        AwardPoints = LaneBonus * 1000
        TotalBonus = AwardPoints
        DMD CL(0, FormatScore(AwardPoints)), CL(1, "LANE BONUS " & LaneBonus), "", eBlink, eNone, eNone, 800, False, "" : pupevent 851

        'Number of Target hits
        AwardPoints = TargetBonus * 2000
        TotalBonus = TotalBonus + AwardPoints
        DMD CL(0, FormatScore(AwardPoints)), CL(1, "TARGET BONUS " & TargetBonus), "", eBlink, eNone, eNone, 800, False, ""

        'Number of Ramps completed
        AwardPoints = RampBonus * 10000
        TotalBonus = TotalBonus + AwardPoints
        DMD CL(0, FormatScore(AwardPoints)), CL(1, "RAMP BONUS " & RampBonus), "", eBlink, eNone, eNone, 800, False, ""

        'Number of Monsters Killed
        AwardPoints = MonstersKilled(CurrentPlayer) * 25000
        TotalBonus = TotalBonus + AwardPoints
        DMD CL(0, FormatScore(AwardPoints)), CL(1, "CONCERTS ROCKED " & MonstersKilled(CurrentPlayer)), "", eBlink, eNone, eNone, 800, False, ""

        ' calculate the totalbonus
        TotalBonus = TotalBonus * BonusMultiplier(CurrentPlayer) + BonusHeldPoints(CurrentPlayer)

        ' handle the bonus held
        ' reset the bonus held value since it has been already added to the bonus
        BonusHeldPoints(CurrentPlayer) = 0

        ' the player has won the bonus held award so do something with it :)
        If bBonusHeld Then
            If Balls = BallsPerGame Then ' this is the last ball, so if bonus held has been awarded then double the bonus
                TotalBonus = TotalBonus * 2
            End If
        Else ' this is not the last ball so save the bonus for the next ball
            BonusHeldPoints(CurrentPlayer) = TotalBonus
        End If
        bBonusHeld = False

        ' Add the bonus to the score
        DMD CL(0, FormatScore(TotalBonus)), CL(1, "TOTAL BONUS " & " X" & BonusMultiplier(CurrentPlayer)), "", eBlinkFast, eNone, eNone, 1500, True, ""

        AddScore TotalBonus

        ' add a bit of a delay to allow for the bonus points to be shown & added up
        vpmtimer.addtimer 6000, "EndOfBall2 '"
    Else 'if tilted then only add a short delay
        vpmtimer.addtimer 100, "EndOfBall2 '"
    End If
End Sub


' The Timer which delays the machine to allow any bonus points to be added up
' has expired.  Check to see if there are any extra balls for this player.
' if not, then check to see if this was the last ball (of the CurrentPlayer)
'
Sub EndOfBall2()
    ' if were tilted, reset the internal tilted flag (this will also
    ' set TiltWarnings back to zero) which is useful if we are changing player LOL
    Tilted = False
    Tilt = 0
    DisableTable False 'enable again bumpers and slingshots

    ' has the player won an extra-ball ? (might be multiple outstanding)
    If(ExtraBallsAwards(CurrentPlayer) <> 0)Then
        'debug.print "Extra Ball"

        ' yep got to give it to them
        ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer)- 1

        ' if no more EB's then turn off any shoot again light
        If(ExtraBallsAwards(CurrentPlayer) = 0)Then
            LightShootAgain.State = 0
        End If

        ' You may wish to do a bit of a song AND dance at this point
        DMD CL(0, "EXTRA BALL"), CL(1, "SHOOT AGAIN"), "", eNone, eNone, eBlink, 1000, True, ""

        ' In this table an extra ball will have the skillshot and ball saver, so we reset the playfield for the new ball
        ResetForNewPlayerBall()

        ' Create a new ball in the shooters lane
        CreateNewBall()
    Else ' no extra balls

        BallsRemaining(CurrentPlayer) = BallsRemaining(CurrentPlayer)- 1

        ' was that the last ball ?
        If(BallsRemaining(CurrentPlayer) <= 0)Then
            'debug.print "No More Balls, High Score Entry"

            ' Submit the CurrentPlayers score to the High Score system
            CheckHighScore()
        ' you may wish to play some music at this point

        Else

            ' not the last ball (for that player)
            ' if multiple players are playing then move onto the next one
            EndOfBallComplete()
        End If
    End If
End Sub

' This function is called when the end of bonus display
' (or high score entry finished) AND it either end the game or
' move onto the next player (or the next ball of the same player)
'
Sub EndOfBallComplete()
    Dim NextPlayer

    'debug.print "EndOfBall - Complete"

    ' are there multiple players playing this game ?
    If(PlayersPlayingGame > 1)Then
        ' then move to the next player
        NextPlayer = CurrentPlayer + 1
        ' are we going from the last player back to the first
        ' (ie say from player 4 back to player 1)
        If(NextPlayer > PlayersPlayingGame)Then
            NextPlayer = 1
        End If
    Else
        NextPlayer = CurrentPlayer
    End If

    'debug.print "Next Player = " & NextPlayer

    ' is it the end of the game ? (all balls been lost for all players)
    If((BallsRemaining(CurrentPlayer) <= 0)AND(BallsRemaining(NextPlayer) <= 0))Then
        ' you may wish to do some sort of Point Match free game award here
        ' generally only done when not in free play mode

        ' set the machine into game over mode
        DOF 160, DOFOn		'VPCLE
	EndOfGame()
		PlayOver
		'PlaySound "vo_gameover"
    ' you may wish to put a Game Over message on the desktop/backglass

    Else
        ' set the next player
        CurrentPlayer = NextPlayer

        ' make sure the correct display is up to date
        AddScore 0

        ' reset the playfield for the new player (or new ball)
        ResetForNewPlayerBall()

        ' AND create a new ball
        CreateNewBall()

        ' play a sound if more than 1 player
        If PlayersPlayingGame > 1 Then
            PlaySound "vo_player" &CurrentPlayer
            DMD "_", CL(1, "PLAYER " &CurrentPlayer), "_", eNone, eNone, eNone, 800, True, ""
        End If
    End If
End Sub

' This function is called at the End of the Game, it should reset all
' Drop targets, AND eject any 'held' balls, start any attract sequences etc..

Sub EndOfGame()

	if VRRoomChoice = 1 then VRAttractTimer.enabled = true ' VR Callout
    'debug.print "End Of Game"
    bGameInPLay = False
    ' just ended your game then play the end of game tune
    If NOT bJustStarted Then
        'ChangeSong
    End If

    bJustStarted = False
    ' ensure that the flippers are down
    SolLFlipper 0
    SolRFlipper 0
	
	If Not IsNull(Scorbit) Then
        If ScorbitActive = 1 And Scorbit.bNeedsPairing = False Then         
			Scorbit.StopSession Score(0), Score(1), Score(2), Score(3), PlayersPlayingGame
        End If
    End If
	
    ' terminate all Mode - eject locked balls
    ' most of the Mode/timers terminate at the end of the ball

    ' set any lights for the attract mode
    GiOff
    StartAttractMode
' you may wish to light any Game Over Light you may have
End Sub

Function Balls
    Dim tmp
    tmp = BallsPerGame - BallsRemaining(CurrentPlayer) + 1
    If tmp > BallsPerGame Then
        Balls = BallsPerGame
    Else
        Balls = tmp
    End If
End Function

' *********************************************************************
'                      Drain / Plunger Functions
' *********************************************************************

' lost a ball ;-( check to see how many balls are on the playfield.
' if only one then decrement the remaining count AND test for End of game
' if more than 1 ball (multi-ball) then kill of the ball but don't create
' a new one
'
Sub Drain_Hit()
	

	if VRRoomChoice = 1 then SolidRed ' VR Callout
    ' Destroy the ball
    Drain.DestroyBall
    ' Exit Sub ' only for debugging - this way you can add balls from the debug window

    BallsOnPlayfield = BallsOnPlayfield - 1

    ' pretend to knock the ball into the ball storage mech
    RandomSoundDrain Drain
    'if Tilted the end Ball Mode
    If Tilted Then
        StopEndOfBallMode
    End If

    ' if there is a game in progress AND it is not Tilted
    If(bGameInPLay = True)AND(Tilted = False)Then

        ' is the ball saver active,
        If(bBallSaverActive = True)Then

            ' yep, create a new ball in the shooters lane
            ' we use the Addmultiball in case the multiballs are being ejected
            AddMultiball 1
            ' we kick the ball with the autoplunger
            bAutoPlunger = True
            ' you may wish to put something on a display or play a sound at this point
            DMD "_", CL(1, "BALL SAVED"), "_", eNone, eBlinkfast, eNone, 800, True, "" : pupevent 850
			PlayBallSaved
			'PlaySound "vo_ballsaved"
        Else
        HidePick 'AOR 'show picks if ball saver is active, hide if not    
		
		' cancel any multiball if on last ball (ie. lost all other balls)
            If(BallsOnPlayfield = 1)Then
                ' AND in a multi-ball??
                If(bMultiBallMode = True)then
                    ' not in multiball mode any more
                    bMultiBallMode = False
                    ' you may wish to change any music over at this point and
                    ' turn off any multiball specific lights
                    StopSpinner
                    ResetJackpotLights
                    Select Case Battle(CurrentPlayer, 0)
                        Case 13:WinBattle
                    End Select
					DOF 143, DOFOff			'VPCLE
                    ChangeGi white
                    'ChangeSong
                End If
            End If

            ' was that the last ball on the playfield
            If(BallsOnPlayfield = 0)Then
		        DOF 146, DOFPulse		'VPCLE
                ' End Mode and timers
                'ChangeSong
                ChangeGi white
                ' Show the end of ball animation
                ' and continue with the end of ball
                ' DMD something?
                StopEndOfBallMode
                vpmtimer.addtimer 200, "EndOfBall '" 'the delay is depending of the animation of the end of ball, since there is no animation then move to the end of ball
            End If
        End If
    End If
End Sub

' The Ball has rolled out of the Plunger Lane and it is pressing down the trigger in the shooters lane
' Check to see if a ball saver mechanism is needed and if so fire it up.

Sub swPlungerRest_Hit()
	If bOnTheFirstBall = True Then 	DMD CL(0, "USE FLIPPERS TO"), CL(1, "PICK A SONG"), "", eNone, eBlink, eNone, 2000, True, "" : End If
    'debug.print "ball in plunger lane"
    ' some sound according to the ball position
    PlaySoundAt "fx_sensor", swPlungerRest

	'bSongSelect = True
    bBallInPlungerLane = True
    DOF 144, DOFOn		'VPCLE
    ' turn on Launch light is there is one
    'LaunchLight.State = 2

    'be sure to update the Scoreboard after the animations, if any

    ' kick the ball in play if the bAutoPlunger flag is on
    If bAutoPlunger Then
        'debug.print "autofire the ball"
        PlungerIM.AutoFire
        DOF 121, DOFPulse
        PlaySoundAt "fx_fire", swPlungerRest
        bAutoPlunger = False
    End If
    ' if there is a need for a ball saver, then start off a timer
    ' only start if it is ready, and it is currently not running, else it will reset the time period
    If(bBallSaverReady = True)AND(BallSaverTime <> 0)And(bBallSaverActive = False)Then
        EnableBallSaver BallSaverTime
    Else
        ' show the message to shoot the ball in case the player has fallen sleep
        swPlungerRest.TimerEnabled = 1
    End If
    'Start the Selection of the skillshot if ready
    If bSkillShotReady Then
        UpdateSkillshot()
    End If
    ' remember last trigger hit by the ball.
    LastSwitchHit = "swPlungerRest"
End Sub

' The ball is released from the plunger turn off some flags and check for skillshot

Sub swPlungerRest_UnHit()
    bBallInPlungerLane = False
	DOF 144, DOFOff		'VPCLE
	bsongSelect = False
    swPlungerRest.TimerEnabled = 0 'stop the launch ball timer if active
    If bSkillShotReady Then
        ResetSkillShotTimer.Enabled = 1
    End If
	If bMultiballMode Then
		If BallsOnPlayfield = 2 Then
			'ChangeSong
		End If
	Else
    'ChangeSong
	End If
' turn off LaunchLight
' LaunchLight.State = 0
End Sub

' swPlungerRest timer to show the "launch ball" if the player has not shot the ball during 6 seconds

Sub swPlungerRest_Timer
	'debug.print "ball in plunger lane"
    DMD "_", CL(1, "SHOOT THE BALL"), "_", eNone, eNone, eNone, 800, True, ""
	PlayPlungerRest
End Sub

sub swPungerRest2_Hit
	swPungerRest2.TimerEnabled = 1 'stop the launch ball timer if active
	if VRRoomChoice = 1 then StrobeWhiteSlow ' VR Callout
End Sub

sub swPungerRest2_UnHit
	swPungerRest2.TimerEnabled = 0 'stop the launch ball timer if active
	if VRRoomChoice = 1 then StrobeYellowSlow ' VR Callout
End Sub


Sub swPungerRest2_Timer
	'debug.print "Finalmente"
    DMD "_", CL(1, "SHOOT THE BALL"), "_", eNone, eNone, eNone, 800, True, ""
	PlayPlungerRest
End Sub


Sub EnableBallSaver(seconds)
    'debug.print "Ballsaver started"
    ' set our game flag
    bBallSaverActive = True
    bBallSaverReady = False
    ' start the timer
    BallSaverTimerExpired.Interval = 1000 * seconds
    BallSaverTimerExpired.Enabled = True
    BallSaverSpeedUpTimer.Interval = 1000 * seconds -(1000 * seconds) / 3
    BallSaverSpeedUpTimer.Enabled = True
    ' if you have a ball saver light you might want to turn it on at this point (or make it flash)
    LightShootAgain.BlinkInterval = 160
    LightShootAgain.State = 2
End Sub

' The ball saver timer has expired.  Turn it off AND reset the game flag
'
Sub BallSaverTimerExpired_Timer()
    'debug.print "Ballsaver ended"
    BallSaverTimerExpired.Enabled = False
    ' clear the flag
    bBallSaverActive = False
    ' if you have a ball saver light then turn it off at this point
    LightShootAgain.State = 0
End Sub

Sub BallSaverSpeedUpTimer_Timer()
    'debug.print "Ballsaver Speed Up Light"
    BallSaverSpeedUpTimer.Enabled = False
    ' Speed up the blinking
    LightShootAgain.BlinkInterval = 80
    LightShootAgain.State = 2
End Sub

' *********************************************************************
'                      Supporting Score Functions
' *********************************************************************

' Add points to the score AND update the score board
' In this table we use SecondRound variable to double the score points in the second round after killing Malthael
Sub AddScore(points)
    If(Tilted = False)Then
        ' add the points to the current players score variable
        Score(CurrentPlayer) = Score(CurrentPlayer) + points * PlayfieldMultiplier(CurrentPlayer)

		If Not IsNull(Scorbit) Then
			If ScorbitActive = 1 And Scorbit.bNeedsPairing = False Then         
				Scorbit.SendUpdate Score(1), Score(2), Score(3), Score(4), Balls, CurrentPlayer, PlayersPlayingGame
			End If
		End If

		
    End if
' you may wish to check to see if the player has gotten a replay
End Sub

' Add bonus to the bonuspoints AND update the score board
Sub AddBonus(points) 'not used in this table, since there are many different bonus items.
    If(Tilted = False)Then
        ' add the bonus to the current players bonus variable
        BonusPoints(CurrentPlayer) = BonusPoints(CurrentPlayer) + points
    End if
End Sub

' Add some points to the current Jackpot.
'
Sub AddJackpot(points)
    ' Jackpots only generally increment in multiball mode AND not tilted
    ' but this doesn't have to be the case
    If(Tilted = False)Then

        ' If(bMultiBallMode = True) Then
        Jackpot(CurrentPlayer) = Jackpot(CurrentPlayer) + points
        DMD "_", CL(1, "INCREASED JACKPOT"), "_", eNone, eNone, eNone, 800, True, ""
    ' you may wish to limit the jackpot to a upper limit, ie..
    '	If (Jackpot >= 6000) Then
    '		Jackpot = 6000
    ' 	End if
    'End if
    End if
End Sub

Sub AddSuperJackpot(points) 'not used in this table
    If(Tilted = False)Then
    End if
End Sub

Sub AddBonusMultiplier(n)
    Dim NewBonusLevel
    ' if not at the maximum bonus level
    if(BonusMultiplier(CurrentPlayer) + n <= MaxMultiplier)then
        ' then add and set the lights
        NewBonusLevel = BonusMultiplier(CurrentPlayer) + n
        SetBonusMultiplier(NewBonusLevel)
        DMD "_", CL(1, "BONUS X " &NewBonusLevel), "_", eNone, eNone, eNone, 2000, True, "fx_bonus"
    Else
        AddScore 50000
        DMD "_", CL(1, "50000"), "_", eNone, eNone, eNone, 800, True, ""
    End if
End Sub

' Set the Bonus Multiplier to the specified level AND set any lights accordingly

Sub SetBonusMultiplier(Level)
    ' Set the multiplier to the specified level
    BonusMultiplier(CurrentPlayer) = Level
    UPdateBonusXLights(Level)
End Sub

Sub UpdateBonusXLights(Level)
    ' Update the lights
    Select Case Level
        Case 1:light56.State = 0:light57.State = 0:light58.State = 0:light59.State = 0
        Case 2:light56.State = 1:light57.State = 0:light58.State = 0:light59.State = 0	:PlaySound "multi1"
        Case 3:light56.State = 0:light57.State = 1:light58.State = 0:light59.State = 0	:PlaySound "multi2"
        Case 4:light56.State = 0:light57.State = 0:light58.State = 1:light59.State = 0	:PlaySound "multi3"
        Case 5:light56.State = 0:light57.State = 0:light58.State = 0:light59.State = 1	:PlaySound "multi4"
    End Select
End Sub

Sub AddPlayfieldMultiplier(n)
    Dim NewPFLevel
    ' if not at the maximum level x
    if(PlayfieldMultiplier(CurrentPlayer) + n <= MaxMultiplier)then
        ' then add and set the lights
        NewPFLevel = PlayfieldMultiplier(CurrentPlayer) + n
        SetPlayfieldMultiplier(NewPFLevel)
        DMD "_", CL(1, "PLAYFIELD X " &NewPFLevel), "_", eNone, eNone, eNone, 2000, True, "fx_bonus"
    Else 'if the 5x is already lit
        AddScore 50000
        DMD "_", CL(1, "50000"), "_", eNone, eNone, eNone, 2000, True, ""
    End if
    'Start the timer to reduce the playfield x every 30 seconds
    ' pfxtimer.Enabled = 0
    ' pfxtimer.Enabled = 1
End Sub

' Set the Playfield Multiplier to the specified level AND set any lights accordingly

Sub SetPlayfieldMultiplier(Level)
    ' Set the multiplier to the specified level
    PlayfieldMultiplier(CurrentPlayer) = Level
    UpdatePFXLights(Level)
End Sub

Sub UpdatePFXLights(Level)
' Update the lights
Select Case Level
    Case 1:Light029.State = 0:Light030.State = 0:Light031.State = 0:Light032.State = 0
    Case 2:Light029.State = 1:Light030.State = 0:Light031.State = 0:Light032.State = 0
    Case 3:Light029.State = 0:Light030.State = 1:Light031.State = 0:Light032.State = 0
    Case 4:Light029.State = 0:Light030.State = 0:Light031.State = 1:Light032.State = 0
    Case 5:Light029.State = 0:Light030.State = 0:Light031.State = 0:Light032.State = 1
End Select
End Sub

Sub AwardExtraBall()
    If NOT bExtraBallWonThisBall Then
        DMD "_", CL(1, ("EXTRA BALL WON")), "_", eNone, eBlink, eNone, 1000, True, SoundFXDOF("fx_Knocker", 122, DOFPulse, DOFKnocker)
        DOF 121, DOFPulse
        ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer) + 1
        bExtraBallWonThisBall = True
        LightShootAgain.State = 1 'light the shoot again lamp
        GiEffect 2
        LightEffect 2
    END If
End Sub

Sub AwardSpecial()
    DMD "_", CL(1, ("EXTRA GAME WON")), "_", eNone, eBlink, eNone, 1000, True, SoundFXDOF("fx_Knocker", 122, DOFPulse, DOFKnocker)
    DOF 121, DOFPulse
    Credits = Credits + 1
    If bFreePlay = False Then DOF 125, DOFOn
    LightEffect 2
    FlashEffect 2
End Sub

Sub AwardJackpot() 'award a normal jackpot, double or triple jackpot
    Dim tmp
    DMD CL(0, FormatScore(Jackpot(CurrentPlayer))), CL(1, "JACKPOT"), "bkborder", eBlinkFast, eBlinkFast, eNone, 1000, True, ""
    DOF 157, DOFPulse		'VPCLE
    tmp = INT(RND * 2)
    Select Case tmp
        Case 0:PlaySound "vo_Jackpot"
        Case 1:PlaySound "vo_Jackpot2"
        Case 2:PlaySound "vo_Jackpot3"
    End Select
    AddScore Jackpot(CurrentPlayer)
    LightEffect 2
    FlashEffect 2
    'sjekk for superjackpot
    EnableSuperJackpot
End Sub

Sub AwardSuperJackpot() 'this is actually 4 times a jackpot
    SuperJackpot = Jackpot(CurrentPlayer) * 4
    DMD CL(0, FormatScore(SuperJackpot)), CL(1, "SUPER JACKPOT"), "bkborder", eBlinkFast, eBlinkFast, eNone, 1000, True, "vo_superjackpot"
    DOF 158, DOFPulse				'VPCLE
    AddScore SuperJackpot
    LightEffect 2
    FlashEffect 2
    'enabled jackpots again
    StartJackpots
End Sub

Sub AwardSkillshot()
    ResetSkillShotTimer_Timer
    'show dmd animation
    DMD CL(0, FormatScore(SkillshotValue(CurrentPlayer))), CL(1, ("SKILLSHOT")), "bkborder", eBlinkFast, eBlink, eNone, 1000, True, ""
    DOF 127, DOFPulse
    PlaySound "fx_fanfare2"
    Addscore SkillShotValue(CurrentPlayer)
    ' increment the skillshot value with 250.000
    SkillShotValue(CurrentPlayer) = SkillShotValue(CurrentPlayer) + 250000
    'do some light show
    GiEffect 2
    LightEffect 2

	if ((Videos = True) and iMiniGameCnt(CurrentPlayer) = 0) Then  'AOR
	ShowPick
	Else	
	HidePick
	end If


End Sub

'*****************************
'    Load / Save / Highscore
'*****************************

Sub Loadhs
    Dim x
    x = LoadValue(TableName, "HighScore1")
    If(x <> "")Then HighScore(0) = CDbl(x)Else HighScore(0) = 100000 End If
    x = LoadValue(TableName, "HighScore1Name")
    If(x <> "")Then HighScoreName(0) = x Else HighScoreName(0) = "AAA" End If
    x = LoadValue(TableName, "HighScore2")
    If(x <> "")then HighScore(1) = CDbl(x)Else HighScore(1) = 100000 End If
    x = LoadValue(TableName, "HighScore2Name")
    If(x <> "")then HighScoreName(1) = x Else HighScoreName(1) = "BBB" End If
    x = LoadValue(TableName, "HighScore3")
    If(x <> "")then HighScore(2) = CDbl(x)Else HighScore(2) = 100000 End If
    x = LoadValue(TableName, "HighScore3Name")
    If(x <> "")then HighScoreName(2) = x Else HighScoreName(2) = "CCC" End If
    x = LoadValue(TableName, "HighScore4")
    If(x <> "")then HighScore(3) = CDbl(x)Else HighScore(3) = 100000 End If
    x = LoadValue(TableName, "HighScore4Name")
    If(x <> "")then HighScoreName(3) = x Else HighScoreName(3) = "DDD" End If
    x = LoadValue(TableName, "Credits")
    If(x <> "")then Credits = CInt(x)Else Credits = 0:If bFreePlay = False Then DOF 125, DOFOff:End If
    x = LoadValue(TableName, "TotalGamesPlayed")
    If(x <> "")then TotalGamesPlayed = CInt(x)Else TotalGamesPlayed = 0 End If
End Sub

Sub Savehs
    SaveValue TableName, "HighScore1", HighScore(0)
    SaveValue TableName, "HighScore1Name", HighScoreName(0)
    SaveValue TableName, "HighScore2", HighScore(1)
    SaveValue TableName, "HighScore2Name", HighScoreName(1)
    SaveValue TableName, "HighScore3", HighScore(2)
    SaveValue TableName, "HighScore3Name", HighScoreName(2)
    SaveValue TableName, "HighScore4", HighScore(3)
    SaveValue TableName, "HighScore4Name", HighScoreName(3)
    SaveValue TableName, "Credits", Credits
    SaveValue TableName, "TotalGamesPlayed", TotalGamesPlayed
End Sub

Sub Reseths
    HighScoreName(0) = "AAA"
    HighScoreName(1) = "BBB"
    HighScoreName(2) = "CCC"
    HighScoreName(3) = "DDD"
    HighScore(0) = 100000
    HighScore(1) = 100000
    HighScore(2) = 100000
    HighScore(3) = 100000
    Savehs
End Sub

' ***********************************************************
'  High Score Initals Entry Functions - based on Black's code
' ***********************************************************

Dim hsbModeActive
Dim hsEnteredName
Dim hsEnteredDigits(3)
Dim hsCurrentDigit
Dim hsValidLetters
Dim hsCurrentLetter
Dim hsLetterFlash

Sub CheckHighscore()
    Dim tmp
    tmp = Score(1)
    If Score(2) > tmp Then tmp = Score(2)
    If Score(3) > tmp Then tmp = Score(3)
    If Score(4) > tmp Then tmp = Score(4)

    If tmp > HighScore(1)Then 'add 1 credit for beating the highscore
        Credits = Credits + 1
        DOF 125, DOFOn
    End If

    If tmp > HighScore(3)Then
        PlaySound SoundFXDOF("fx_Knocker", 122, DOFPulse, DOFKnocker)
        DOF 121, DOFPulse
        HighScore(3) = tmp
        'enter player's name
        HighScoreEntryInit()
    Else
        EndOfBallComplete()
    End If
End Sub

Sub HighScoreEntryInit()
	Playname
    hsbModeActive = True
    'ChangeSong
    hsLetterFlash = 0

    hsEnteredDigits(0) = " "
    hsEnteredDigits(1) = " "
    hsEnteredDigits(2) = " "
    hsCurrentDigit = 0

    hsValidLetters = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<" ' ` is back arrow
    hsCurrentLetter = 1
    DMDFlush()
    HighScoreDisplayNameNow()

    HighScoreFlashTimer.Interval = 250
    HighScoreFlashTimer.Enabled = True
End Sub

Sub EnterHighScoreKey(keycode)
    If keycode = LeftFlipperKey Then
        playsound "fx_Previous"
        hsCurrentLetter = hsCurrentLetter - 1
        if(hsCurrentLetter = 0)then
            hsCurrentLetter = len(hsValidLetters)
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = RightFlipperKey Then
        playsound "fx_Next"
        hsCurrentLetter = hsCurrentLetter + 1
        if(hsCurrentLetter > len(hsValidLetters))then
            hsCurrentLetter = 1
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = PlungerKey OR keycode = StartGameKey Then
        if(mid(hsValidLetters, hsCurrentLetter, 1) <> "<")then
            playsound "fx_Enter"
            hsEnteredDigits(hsCurrentDigit) = mid(hsValidLetters, hsCurrentLetter, 1)
            hsCurrentDigit = hsCurrentDigit + 1
            if(hsCurrentDigit = 3)then
                HighScoreCommitName()
            else
                HighScoreDisplayNameNow()
            end if
        else
            playsound "fx_Esc"
            hsEnteredDigits(hsCurrentDigit) = " "
            if(hsCurrentDigit > 0)then
                hsCurrentDigit = hsCurrentDigit - 1
            end if
            HighScoreDisplayNameNow()
        end if
    end if
End Sub

Sub HighScoreDisplayNameNow()
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = 0
    HighScoreDisplayName()
    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreDisplayName()
    Dim i
    Dim TempTopStr
    Dim TempBotStr

    TempTopStr = "YOUR NAME:"
    dLine(0) = ExpandLine(TempTopStr, 0)
    DMDUpdate 0

    TempBotStr = "    > "
    if(hsCurrentDigit > 0)then TempBotStr = TempBotStr & hsEnteredDigits(0)
    if(hsCurrentDigit > 1)then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit > 2)then TempBotStr = TempBotStr & hsEnteredDigits(2)

    if(hsCurrentDigit <> 3)then
        if(hsLetterFlash <> 0)then
            TempBotStr = TempBotStr & "_"
        else
            TempBotStr = TempBotStr & mid(hsValidLetters, hsCurrentLetter, 1)
        end if
    end if

    if(hsCurrentDigit < 1)then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit < 2)then TempBotStr = TempBotStr & hsEnteredDigits(2)

    TempBotStr = TempBotStr & " <    "
    dLine(1) = ExpandLine(TempBotStr, 1)
    DMDUpdate 1
End Sub

Sub HighScoreFlashTimer_Timer()
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = hsLetterFlash + 1
    if(hsLetterFlash = 2)then hsLetterFlash = 0
    HighScoreDisplayName()
    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreCommitName()
    HighScoreFlashTimer.Enabled = False
    hsbModeActive = False
    'ChangeSong
    hsEnteredName = hsEnteredDigits(0) & hsEnteredDigits(1) & hsEnteredDigits(2)
    if(hsEnteredName = "   ")then
        hsEnteredName = "YOU"
    end if

    HighScoreName(3) = hsEnteredName
    SortHighscore
    EndOfBallComplete()
End Sub

Sub SortHighscore
    Dim tmp, tmp2, i, j
    For i = 0 to 3
        For j = 0 to 2
            If HighScore(j) < HighScore(j + 1)Then
                tmp = HighScore(j + 1)
                tmp2 = HighScoreName(j + 1)
                HighScore(j + 1) = HighScore(j)
                HighScoreName(j + 1) = HighScoreName(j)
                HighScore(j) = tmp
                HighScoreName(j) = tmp2
            End If
        Next
    Next
End Sub

' *************************************************************************
'   JP's Reduced Display Driver Functions (based on script by Black)
' only 5 effects: none, scroll left, scroll right, blink and blinkfast
' 3 Lines, treats all 3 lines as text. 3rd line is just 1 character
' Example format:
' DMD "text1","text2","backpicture", eNone, eNone, eNone, 250, True, "sound"
' Short names:
' dq = display queue
' de = display effect
' *************************************************************************

Const eNone = 0        ' Instantly displayed
Const eScrollLeft = 1  ' scroll on from the right
Const eScrollRight = 2 ' scroll on from the left
Const eBlink = 3       ' Blink (blinks for 'TimeOn')
Const eBlinkFast = 4   ' Blink (blinks for 'TimeOn') at user specified intervals (fast speed)

Const dqSize = 64

Dim dqHead
Dim dqTail
Dim deSpeed
Dim deBlinkSlowRate
Dim deBlinkFastRate

Dim dCharsPerLine(2)
Dim dLine(2)
Dim deCount(2)
Dim deCountEnd(2)
Dim deBlinkCycle(2)

Dim dqText(2, 64)
Dim dqEffect(2, 64)
Dim dqTimeOn(64)
Dim dqbFlush(64)
Dim dqSound(64)

Dim FlexDMD
Dim DMDScene


Sub DMD_Init() 'default/startup values
    Dim i, j
    If UseFlexDMD Then
        Set FlexDMD = CreateObject("FlexDMD.FlexDMD")
        If Not FlexDMD is Nothing Then
            If FlexDMDHighQuality Then
				FlexDMD.TableFile = Table1.Filename & ".vpx"
                FlexDMD.RenderMode = 2
                FlexDMD.Width = 256
                FlexDMD.Height = 64
                FlexDMD.Clear = True
                FlexDMD.GameName = cGameName
                FlexDMD.Run = True
'msgbox "test0"
                Set DMDScene = FlexDMD.NewGroup("Scene")
'msgbox "test0"
                DMDScene.AddActor FlexDMD.NewImage("Back", "VPX.bkempty")
'msgbox "test0"
                DMDScene.GetImage("Back").SetSize FlexDMD.Width, FlexDMD.Height
'msgbox "test0" 
               For i = 0 to 40
'if i = 0 then msgbox "textfistletter"
                    DMDScene.AddActor FlexDMD.NewImage("Dig" & i, "VPX.dempty&dmd=2")
                    Digits(i).Visible = False
                Next
'msgbox "test1"
                digitgrid.Visible = False
                For i = 0 to 19 ' Top
                    DMDScene.GetImage("Dig" & i).SetBounds 8 + i * 12, 6, 12, 22
                Next
                For i = 20 to 39 ' Bottom
                    DMDScene.GetImage("Dig" & i).SetBounds 8 + (i - 20) * 12, 34, 12, 22
                Next
'msgbox "test2"
                FlexDMD.LockRenderThread
                FlexDMD.Stage.AddActor DMDScene
                FlexDMD.UnlockRenderThread
            Else
                FlexDMD.TableFile = Table1.Filename & ".vpx"
                FlexDMD.RenderMode = 2
                FlexDMD.Width = 128
                FlexDMD.Height = 32
                FlexDMD.Clear = True
                FlexDMD.GameName = cGameName
                FlexDMD.Run = True
                Set DMDScene = FlexDMD.NewGroup("Scene")
                DMDScene.AddActor FlexDMD.NewImage("Back", "VPX.bkempty")
                DMDScene.GetImage("Back").SetSize FlexDMD.Width, FlexDMD.Height
                For i = 0 to 40
                    DMDScene.AddActor FlexDMD.NewImage("Dig" & i, "VPX.dempty&dmd=2")
                    Digits(i).Visible = False
                Next
                digitgrid.Visible = False
                For i = 0 to 19 ' Top
                    DMDScene.GetImage("Dig" & i).SetBounds 4 + i * 6, 3, 6, 11
                Next
                For i = 20 to 39 ' Bottom
                    DMDScene.GetImage("Dig" & i).SetBounds 4 + (i - 20) * 6, 17, 6, 11
                Next
                FlexDMD.LockRenderThread
                FlexDMD.Stage.AddActor DMDScene
                FlexDMD.UnlockRenderThread
            End If
        End If
    End If

    DMDFlush()
    deSpeed = 20
    deBlinkSlowRate = 10
    deBlinkFastRate = 5
    dCharsPerLine(0) = 20 'characters lower line
    dCharsPerLine(1) = 20 'characters top line
    dCharsPerLine(2) = 1  'characters back line
    For i = 0 to 2
        dLine(i) = Space(dCharsPerLine(i))
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
        dqTimeOn(i) = 0
        dqbFlush(i) = True
        dqSound(i) = ""
    Next
    dLine(2) = " "
    For i = 0 to 2
        For j = 0 to 64
            dqText(i, j) = ""
            dqEffect(i, j) = eNone
        Next
    Next
    DMD dLine(0), dLine(1), dLine(2), eNone, eNone, eNone, 25, True, ""
End Sub


Sub DMDFlush()
    Dim i
    DMDTimer.Enabled = False
    DMDEffectTimer.Enabled = False
    dqHead = 0
    dqTail = 0
    For i = 0 to 2
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
    Next
End Sub

Sub DMDScore()
    Dim tmp, tmp1, tmp2
    if(dqHead = dqTail)Then
        tmp = RL(FormatScore(Score(Currentplayer)))
        'tmp = CL(0, FormatScore(Score(Currentplayer) ) )
        'tmp1 = CL(1, "PLAYER " & CurrentPlayer & " BALL " & Balls)
        'tmp1 = FormatScore(Bonuspoints(Currentplayer) ) & " X" &BonusMultiplier(Currentplayer)

        Select Case Battle(CurrentPlayer, 0)
            Case 0:tmp1 = CL(1, "PLAYER " & CurrentPlayer & " BALL " & Balls & " X" & PlayfieldMultiplier(CurrentPlayer))
            Case 1:tmp1 = CL(1, "SPINNERS LEFT " & 100-SpinCount)
            Case 2:tmp1 = CL(1, "BUMPER HITS LEFT " & 25-SuperBumperHIts)
            Case 3:tmp1 = CL(1, "RAMP HITS LEFT " & 6-ramphits3)
            Case 4:tmp1 = CL(1, "ORBIT HITS LEFT " & 6-orbithits)
            Case 5:tmp1 = CL(1, "HIT THE LIGHTS")
            Case 6:tmp1 = CL(1, "HIT THE LIGHTS")
            Case 7:tmp1 = CL(1, "HIT THE TARGETS " & 20-TargetHits7)
            Case 8:tmp1 = CL(1, "HIT THE TARGETS " & 6-TargetHits8)
            Case 9:tmp1 = CL(1, "HIT THE LIT LIGHT " & 8-LightHits9)
            Case 10:tmp1 = CL(1, "HIT THE LOOPS " & 6-loopCount)
            Case 11:tmp1 = CL(1, "HIT THE LIT LIGHT " & 8-LightHits11)
            Case 12:tmp1 = CL(1, "HIT RAMPS ORBITS " & 6-RampHits12)
            Case 13:tmp1 = CL(1, "MORDEKAI BATTLE")
        End Select
        tmp2 = ""
    End If
    DMD tmp, tmp1, tmp2, eNone, eNone, eNone, 25, True, ""
End Sub

Sub DMDScoreNow
    DMDFlush
    DMDScore
End Sub

Sub DMD(Text0, Text1, Text2, Effect0, Effect1, Effect2, TimeOn, bFlush, Sound)
    if(dqTail < dqSize)Then
        if(Text0 = "_")Then
            dqEffect(0, dqTail) = eNone
            dqText(0, dqTail) = "_"
        Else
            dqEffect(0, dqTail) = Effect0
            dqText(0, dqTail) = ExpandLine(Text0, 0)
        End If

        if(Text1 = "_")Then
            dqEffect(1, dqTail) = eNone
            dqText(1, dqTail) = "_"
        Else
            dqEffect(1, dqTail) = Effect1
            dqText(1, dqTail) = ExpandLine(Text1, 1)
        End If

        if(Text2 = "_")Then
            dqEffect(2, dqTail) = eNone
            dqText(2, dqTail) = "_"
        Else
            dqEffect(2, dqTail) = Effect2
            dqText(2, dqTail) = Text2 'it is always 1 letter in this table
        End If

        dqTimeOn(dqTail) = TimeOn
        dqbFlush(dqTail) = bFlush
        dqSound(dqTail) = Sound
        dqTail = dqTail + 1
        if(dqTail = 1)Then
            DMDHead()
        End If
    End If
End Sub

Sub DMDHead()
    Dim i
    deCount(0) = 0
    deCount(1) = 0
    deCount(2) = 0
    DMDEffectTimer.Interval = deSpeed

    For i = 0 to 2
        Select Case dqEffect(i, dqHead)
            Case eNone:deCountEnd(i) = 1
            Case eScrollLeft:deCountEnd(i) = Len(dqText(i, dqHead))
            Case eScrollRight:deCountEnd(i) = Len(dqText(i, dqHead))
            Case eBlink:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
            Case eBlinkFast:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
        End Select
    Next
    if(dqSound(dqHead) <> "")Then
        PlaySound(dqSound(dqHead))
    End If
    DMDEffectTimer.Enabled = True
End Sub

Sub DMDEffectTimer_Timer()
    DMDEffectTimer.Enabled = False
    DMDProcessEffectOn()
End Sub

Sub DMDTimer_Timer()
    Dim Head
    DMDTimer.Enabled = False
    Head = dqHead
    dqHead = dqHead + 1
    if(dqHead = dqTail)Then
        if(dqbFlush(Head) = True)Then
            DMDScoreNow()
        Else
            dqHead = 0
            DMDHead()
        End If
    Else
        DMDHead()
    End If
End Sub

Sub DMDProcessEffectOn()
    Dim i
    Dim BlinkEffect
    Dim Temp

    BlinkEffect = False

    For i = 0 to 2
        if(deCount(i) <> deCountEnd(i))Then
            deCount(i) = deCount(i) + 1

            select case(dqEffect(i, dqHead))
                case eNone:
                    Temp = dqText(i, dqHead)
                case eScrollLeft:
                    Temp = Right(dLine(i), dCharsPerLine(i)- 1)
                    Temp = Temp & Mid(dqText(i, dqHead), deCount(i), 1)
                case eScrollRight:
                    Temp = Mid(dqText(i, dqHead), (dCharsPerLine(i) + 1)- deCount(i), 1)
                    Temp = Temp & Left(dLine(i), dCharsPerLine(i)- 1)
                case eBlink:
                    BlinkEffect = True
                    if((deCount(i)MOD deBlinkSlowRate) = 0)Then
                        deBlinkCycle(i) = deBlinkCycle(i)xor 1
                    End If

                    if(deBlinkCycle(i) = 0)Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i))
                    End If
                case eBlinkFast:
                    BlinkEffect = True
                    if((deCount(i)MOD deBlinkFastRate) = 0)Then
                        deBlinkCycle(i) = deBlinkCycle(i)xor 1
                    End If

                    if(deBlinkCycle(i) = 0)Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i))
                    End If
            End Select

            if(dqText(i, dqHead) <> "_")Then
                dLine(i) = Temp
                DMDUpdate i
            End If
        End If
    Next

    if(deCount(0) = deCountEnd(0))and(deCount(1) = deCountEnd(1))and(deCount(2) = deCountEnd(2))Then

        if(dqTimeOn(dqHead) = 0)Then
            DMDFlush()
        Else
            if(BlinkEffect = True)Then
                DMDTimer.Interval = 10
            Else
                DMDTimer.Interval = dqTimeOn(dqHead)
            End If

            DMDTimer.Enabled = True
        End If
    Else
        DMDEffectTimer.Enabled = True
    End If
End Sub

Function ExpandLine(TempStr, id) 'id is the number of the dmd line
    If TempStr = "" Then
        TempStr = Space(dCharsPerLine(id))
    Else
        if(Len(TempStr) > Space(dCharsPerLine(id)))Then
            TempStr = Left(TempStr, Space(dCharsPerLine(id)))
        Else
            if(Len(TempStr) < dCharsPerLine(id))Then
                TempStr = TempStr & Space(dCharsPerLine(id)- Len(TempStr))
            End If
        End If
    End If
    ExpandLine = TempStr
End Function

Function FormatScore(ByVal Num) 'it returns a string with commas (as in Black's original font)
    dim i
    dim NumString

    NumString = CStr(abs(Num))

    For i = Len(NumString)-3 to 1 step -3
        if IsNumeric(mid(NumString, i, 1))then
            NumString = left(NumString, i-1) & chr(asc(mid(NumString, i, 1)) + 48) & right(NumString, Len(NumString)- i)
        end if
    Next
    FormatScore = NumString
End function

Function CL(id, NumString)
    Dim Temp, TempStr
    If Len(NumString) > 20 Then NumString = Left(NumString, 20)
	Temp = (20 - Len(NumString)) \ 2
    TempStr = Space(Temp) & NumString & Space(Temp)
    CL = TempStr
End Function

Function RL(NumString) 'right line
    Dim Temp, TempStr
    If Len(NumString) > 20 Then NumString = Left(NumString, 20)
    Temp = 20 - Len(NumString)
    TempStr = Space(Temp) & NumString
    RL = TempStr
End Function

'**************
' Update DMD
'**************

Sub DMDUpdate(id)
    Dim digit, value
    If UseFlexDMD Then FlexDMD.LockRenderThread
    Select Case id
        Case 0 'top text line
            For digit = 0 to 19
                DMDDisplayChar mid(dLine(0), digit + 1, 1), digit
            Next
        Case 1 'bottom text line
            For digit = 20 to 39
                DMDDisplayChar mid(dLine(1), digit -19, 1), digit
            Next
        Case 2 ' back image - back animations
            If dLine(2) = "" OR dLine(2) = " " Then dLine(2) = "bkempty"
            Digits(40).ImageA = dLine(2)
            If UseFlexDMD Then DMDScene.GetImage("Back").Bitmap = FlexDMD.NewImage("", "VPX." & dLine(2) & "&dmd=2").Bitmap
    End Select
    If UseFlexDMD Then FlexDMD.UnlockRenderThread
End Sub

Sub DMDDisplayChar(achar, adigit)
    If achar = "" Then achar = " "
    achar = ASC(achar)
    Digits(adigit).ImageA = Chars(achar)
    If UseFlexDMD Then DMDScene.GetImage("Dig" & adigit).Bitmap = FlexDMD.NewImage("", "VPX." & Chars(achar) & "&dmd=2&add").Bitmap
End Sub

'****************************
' JP's new DMD using flashers
'****************************

Dim Digits, DigitsBack, Chars(255), Images(255)

DMDInit

Sub DMDInit
    Dim i
    Digits = Array(digit001, digit002, digit003, digit004, digit005, digit006, digit007, digit008, digit009, digit010, _
        digit011, digit012, digit013, digit014, digit015, digit016, digit017, digit018, digit019, digit020,            _
        digit021, digit022, digit023, digit024, digit025, digit026, digit027, digit028, digit029, digit030,            _
        digit031, digit032, digit033, digit034, digit035, digit036, digit037, digit038, digit039, digit040,            _
        digit041)
    For i = 0 to 255:Chars(i) = "dempty":Images(i) = "dempty":Next

    Chars(32) = "dempty"
    '    Chars(34) = '"
    '    Chars(36) = '$
    '    Chars(39) = ''
    '    Chars(42) = '*
    '    Chars(43) = '+
    '    Chars(45) = '-
    '    Chars(47) = '/
    Chars(48) = "d0"     '0
    Chars(49) = "d1"     '1
    Chars(50) = "d2"     '2
    Chars(51) = "d3"     '3
    Chars(52) = "d4"     '4
    Chars(53) = "d5"     '5
    Chars(54) = "d6"     '6
    Chars(55) = "d7"     '7
    Chars(56) = "d8"     '8
    Chars(57) = "d9"     '9
    Chars(60) = "dless"  '<
    Chars(61) = "dequal" '=
    Chars(62) = "dmore"  '>
    '   Chars(64) = '@
    Chars(65) = "da" 'A
    Chars(66) = "db" 'B
    Chars(67) = "dc" 'C
    Chars(68) = "dd" 'D
    Chars(69) = "de" 'E
    Chars(70) = "df" 'F
    Chars(71) = "dg" 'G
    Chars(72) = "dh" 'H
    Chars(73) = "di" 'I
    Chars(74) = "dj" 'J
    Chars(75) = "dk" 'K
    Chars(76) = "dl" 'L
    Chars(77) = "dm" 'M
    Chars(78) = "dn" 'N
    Chars(79) = "do" 'O
    Chars(80) = "dp" 'P
    Chars(81) = "dq" 'Q
    Chars(82) = "dr" 'R
    Chars(83) = "ds" 'S
    Chars(84) = "dt" 'T
    Chars(85) = "du" 'U
    Chars(86) = "dv" 'V
    Chars(87) = "dw" 'W
    Chars(88) = "dx" 'X
    Chars(89) = "dy" 'Y
    Chars(90) = "dz" 'Z
    'Chars(91) = "dball" '[
    'Chars(92) = "dcoin" '|
    'Chars(93) = "dpika" ']
    '    Chars(94) = '^
    '    Chars(95) = '_
    Chars(96) = "d0a"  '0.
    Chars(97) = "d1a"  '1.
    Chars(98) = "d2a"  '2.
    Chars(99) = "d3a"  '3.
    Chars(100) = "d4a" '4.
    Chars(101) = "d5a" '5.
    Chars(102) = "d6a" '6.
    Chars(103) = "d7a" '7.
    Chars(104) = "d8a" '8.
    Chars(105) = "d9a" '9
End Sub

'****************************************
' Real Time updatess using the GameTimer
'****************************************
'used for all the real time updates

Sub Realtime_Timer
    ' add any other real time update subs, like gates or diverters
    DoorPL.Roty = DoorFL.CurrentAngle -90
    DoorPR.Roty = DoorFR.CurrentAngle +90
    Propellertop.Roty = Spinner001.CurrentAngle
    Nuke.Roty = Spinner002.CurrentAngle
    LFLogo.RotZ = LeftFlipper.CurrentAngle
    RFLogo.RotZ = RightFlipper.CurrentAngle
End Sub

'********************************************************************************************
' Only for VPX 10.2 and higher.
' FlashForMs will blink light or a flasher for TotalPeriod(ms) at rate of BlinkPeriod(ms)
' When TotalPeriod done, light or flasher will be set to FinalState value where
' Final State values are:   0=Off, 1=On, 2=Return to previous State
'********************************************************************************************

Sub FlashForMs(MyLight, TotalPeriod, BlinkPeriod, FinalState) 'thanks gtxjoe for the first version

    If TypeName(MyLight) = "Light" Then

        If FinalState = 2 Then
            FinalState = MyLight.State 'Keep the current light state
        End If
        MyLight.BlinkInterval = BlinkPeriod
        MyLight.Duration 2, TotalPeriod, FinalState
    ElseIf TypeName(MyLight) = "Flasher" Then

        Dim steps

        ' Store all blink information
        steps = Int(TotalPeriod / BlinkPeriod + .5) 'Number of ON/OFF steps to perform
        If FinalState = 2 Then                      'Keep the current flasher state
            FinalState = ABS(MyLight.Visible)
        End If
        MyLight.UserValue = steps * 10 + FinalState 'Store # of blinks, and final state

        ' Start blink timer and create timer subroutine
        MyLight.TimerInterval = BlinkPeriod
        MyLight.TimerEnabled = 0
        MyLight.TimerEnabled = 1
        ExecuteGlobal "Sub " & MyLight.Name & "_Timer:" & "Dim tmp, steps, fstate:tmp=me.UserValue:fstate = tmp MOD 10:steps= tmp\10 -1:Me.Visible = steps MOD 2:me.UserValue = steps *10 + fstate:If Steps = 0 then Me.Visible = fstate:Me.TimerEnabled=0:End if:End Sub"
    End If
End Sub

'******************************************
' Change light color - simulate color leds
' changes the light color and state
' 10 colors: red, orange, amber, yellow...
'******************************************
' in this table this colors are use to keep track of the progress during the acts and battles

'colors
Dim red, orange, amber, yellow, darkgreen, green, blue, darkblue, purple, white

red = 10
orange = 9
amber = 8
yellow = 7
darkgreen = 6
green = 5
blue = 4
darkblue = 3
purple = 2
white = 1

Sub SetLightColor(n, col, stat)
    Select Case col
        Case 0
            n.color = RGB(18, 0, 0)
            n.colorfull = RGB(255, 0, 0)
        Case red
            n.color = RGB(18, 0, 0)
            n.colorfull = RGB(255, 0, 0)
        Case orange
            n.color = RGB(18, 3, 0)
            n.colorfull = RGB(255, 64, 0)
        Case amber
            n.color = RGB(193, 49, 0)
            n.colorfull = RGB(255, 153, 0)
        Case yellow
            n.color = RGB(18, 18, 0)
            n.colorfull = RGB(255, 255, 0)
        Case darkgreen
            n.color = RGB(0, 8, 0)
            n.colorfull = RGB(0, 64, 0)
        Case green
            n.color = RGB(0, 16, 0)
            n.colorfull = RGB(0, 128, 0)
        Case blue
            n.color = RGB(0, 18, 18)
            n.colorfull = RGB(0, 255, 255)
        Case darkblue
            n.color = RGB(0, 8, 8)
            n.colorfull = RGB(0, 64, 64)
        Case purple
            n.color = RGB(64, 0, 96)
            n.colorfull = RGB(128, 0, 192)
        Case white
            n.color = RGB(255, 252, 224)
            n.colorfull = RGB(193, 91, 0)
        Case white
            n.color = RGB(255, 252, 224)
            n.colorfull = RGB(193, 91, 0)
    End Select
    If stat <> -1 Then
        n.State = 0
        n.State = stat
    End If
End Sub

'*************************
' Rainbow Changing Lights
'*************************

Dim RGBStep, RGBFactor, rRed, rGreen, rBlue, RainbowLights

Sub StartRainbow(n)
    set RainbowLights = n
    RGBStep = 0
    RGBFactor = 5
    rRed = 255
    rGreen = 0
    rBlue = 0
    RainbowTimer.Enabled = 1
End Sub

Sub StopRainbow()
    Dim obj
    RainbowTimer.Enabled = 0
    RainbowTimer.Enabled = 0
End Sub

Sub RainbowTimer_Timer 'rainbow led light color changing
    Dim obj
    Select Case RGBStep
        Case 0 'Green
            rGreen = rGreen + RGBFactor
            If rGreen > 255 then
                rGreen = 255
                RGBStep = 1
            End If
        Case 1 'Red
            rRed = rRed - RGBFactor
            If rRed < 0 then
                rRed = 0
                RGBStep = 2
            End If
        Case 2 'Blue
            rBlue = rBlue + RGBFactor
            If rBlue > 255 then
                rBlue = 255
                RGBStep = 3
            End If
        Case 3 'Green
            rGreen = rGreen - RGBFactor
            If rGreen < 0 then
                rGreen = 0
                RGBStep = 4
            End If
        Case 4 'Red
            rRed = rRed + RGBFactor
            If rRed > 255 then
                rRed = 255
                RGBStep = 5
            End If
        Case 5 'Blue
            rBlue = rBlue - RGBFactor
            If rBlue < 0 then
                rBlue = 0
                RGBStep = 0
            End If
    End Select
    For each obj in RainbowLights
        obj.color = RGB(rRed \ 10, rGreen \ 10, rBlue \ 10)
        obj.colorfull = RGB(rRed, rGreen, rBlue)
    Next
End Sub

' ********************************
'   Table info & Attract Mode
' ********************************

Sub ShowTableInfo
    Dim ii
    'info goes in a loop only stopped by the credits and the startkey
    If Score(1)Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 1 " &FormatScore(Score(1))), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(2)Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 2 " &FormatScore(Score(2))), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(3)Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 3 " &FormatScore(Score(3))), "", eNone, eNone, eNone, 3000, False, ""
    End If
    If Score(4)Then
        DMD CL(0, "LAST SCORE"), CL(1, "PLAYER 4 " &FormatScore(Score(4))), "", eNone, eNone, eNone, 3000, False, ""
    End If
    DMD "", "", "gameover", eNone, eNone, eBlink, 2000, False, ""
    If bFreePlay Then
        DMD "", CL(1, "FREE PLAY"), "", eNone, eBlink, eNone, 2000, False, ""
    Else
        If Credits > 0 Then
            DMD CL(0, "CREDITS " & Credits), CL(1, "PRESS START"), "", eNone, eBlink, eNone, 2000, False, ""
        Else
            DMD CL(0, "CREDITS " & Credits), CL(1, "INSERT COIN"), "", eNone, eBlink, eNone, 2000, False, ""
        End If
    End If
    DMD "", "", "jppresents", eNone, eNone, eNone, 3000, False, ""
    DMD "", "", "SeriousSam2", eNone, eNone, eNone, 4000, False, ""
    DMD CL(0, "HIGHSCORES"), Space(dCharsPerLine(1)), "", eScrollLeft, eScrollLeft, eNone, 20, False, ""
    DMD CL(0, "HIGHSCORES"), "", "", eBlinkFast, eNone, eNone, 1000, False, ""
    DMD CL(0, "HIGHSCORES"), "1> " &HighScoreName(0) & " " &FormatScore(HighScore(0)), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "2> " &HighScoreName(1) & " " &FormatScore(HighScore(1)), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "3> " &HighScoreName(2) & " " &FormatScore(HighScore(2)), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD "_", "4> " &HighScoreName(3) & " " &FormatScore(HighScore(3)), "", eNone, eScrollLeft, eNone, 2000, False, ""
    DMD Space(dCharsPerLine(0)), Space(dCharsPerLine(1)), "", eScrollLeft, eScrollLeft, eNone, 500, False, ""
End Sub

Sub StartAttractMode
    DOF 145, DOFOn		'VPCLE
    'ChangeSong
    StartLightSeq
    DMDFlush
    ShowTableInfo
	pupevent 901
End Sub

Sub StopAttractMode
    DOF 145, DOFOff		'VPCLE
    DMDScoreNow
    LightSeqAttract.StopPlay
    LightSeqFlasher.StopPlay
	PlayRandomSong
	'pupevent 900
End Sub

Sub StartLightSeq()
    'lights sequences
    LightSeqFlasher.UpdateInterval = 150
    LightSeqFlasher.Play SeqRandom, 10, , 50000
    LightSeqAttract.UpdateInterval = 25
    LightSeqAttract.Play SeqBlinking, , 5, 150
    LightSeqAttract.Play SeqRandom, 40, , 4000
    LightSeqAttract.Play SeqAllOff
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqCircleOutOn, 15, 3
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqLeftOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 40, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 40, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqRightOn, 30, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqLeftOn, 30, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
    LightSeqAttract.UpdateInterval = 10
    LightSeqAttract.Play SeqCircleOutOn, 15, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqStripe1VertOn, 50, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe1VertOn, 50, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqCircleOutOn, 15, 2
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe2VertOn, 50, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe1VertOn, 25, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqStripe2VertOn, 25, 3
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqUpOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqDownOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 15, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 15, 1
End Sub

Sub LightSeqAttract_PlayDone()
    StartLightSeq()
End Sub

Sub LightSeqTilt_PlayDone()
    LightSeqTilt.Play SeqAllOff
End Sub

Sub LightSeqSkillshot_PlayDone()
    LightSeqSkillshot.Play SeqAllOff
End Sub

' LUT

Dim bLutActive, LUTImage
Sub LoadLUT
    bLutActive = False
    x = LoadValue(cGameName, "LUTImage")
    If(x <> "")Then LUTImage = x Else LUTImage = 0
    UpdateLUT
End Sub

Sub SaveLUT
    SaveValue cGameName, "LUTImage", LUTImage
End Sub

Sub NextLUT:LUTImage = (LUTImage + 1)MOD 10:UpdateLUT:SaveLUT:End Sub

Sub UpdateLUT
    Select Case LutImage
        Case 0:table1.ColorGradeImage = "LUT0"
        Case 1:table1.ColorGradeImage = "LUT1"
        Case 2:table1.ColorGradeImage = "LUT2"
        Case 3:table1.ColorGradeImage = "LUT3"
        Case 4:table1.ColorGradeImage = "LUT4"
        Case 5:table1.ColorGradeImage = "LUT5"
        Case 6:table1.ColorGradeImage = "LUT6"
        Case 7:table1.ColorGradeImage = "LUT7"
        Case 8:table1.ColorGradeImage = "LUT8"
        Case 9:table1.ColorGradeImage = "LUT9"
    End Select
End Sub

'***********************************************************************
' *********************************************************************
'                     Table Specific Script Starts Here
' *********************************************************************
'***********************************************************************

' droptargets, animations, etc
Sub VPObjects_Init
End Sub

' tables variables and Mode init
Dim LaneBonus
Dim TargetBonus
Dim RampBonus
Dim BumperValue(4)
Dim BumperHits
Dim SuperBumperHits
Dim SpinnerValue(4)
Dim MonstersKilled(4)
Dim SpinCount
Dim RampHits3
Dim RampHits12
Dim OrbitHits
Dim TargetHits7
Dim TargetHits8
Dim CaptiveBallHits
Dim LightHits9
Dim LightHits11
Dim loopCount
Dim BattlesWon(4)
Dim Battle(4, 15) '12 battles, 1 final battle
Dim NewBattle
Dim PowerupHits
Dim Cities(4,26)

Sub Game_Init() 'called at the start of a new game
    Dim i, j
    bExtraBallWonThisBall = False
    'Play some Music
    'ChangeSong
    'Init Variables
    LaneBonus = 0 'it gets deleted when a new ball is launched
    TargetBonus = 0
    RampBonus = 0
    BumperHits = 0
    For i = 1 to 4
        SkillshotValue(i) = 500000
        Jackpot(i) = 100000
        MonstersKilled(i) = 0
        BallsInLock(i) = 0
        SpinnerValue(i) = 1000
        BumperValue(i) = 210 'start at 210 and every 30 hits its value is increased by 500 points
    Next
    For i = 0 to 4
        For j = 0 to 26
            Cities(i,j) = 0
        Next
		iMiniGameCnt(i) = 0 'AOR, so we can only play minigame once per player, per game
    Next
    ResetBattles
    SpinCount = 0
    SuperBumperHits = 0
    RampHits3 = 0
    RampHits12 = 0
    OrbitHits = 0
    TargetHits7 = 0
    TargetHits8 = 0
    CaptiveBallHits = 0
    loopCount = 0
    PowerupHits = 0
    LightHits9 = 0
    LightHits11 = 0
    'Init Delays/Timers
    'MainMode Init()
    'Init lights
    TurnOffPlayfieldLights()
    CloseDoor
	
End Sub

Sub StopEndOfBallMode() 'this sub is called after the last ball is drained
    ResetSkillShotTimer_Timer
    StopBattle
End Sub

Sub ResetNewBallVariables() 'reset variables for a new ball or player
    Dim i
    LaneBonus = 0
    TargetBonus = 0
    RampBonus = 0
    BumperHits = 0
    ' select a battle
    SelectBattle
    UpdateCityLights
End Sub

Sub ResetNewBallLights()                                'turn on or off the needed lights before a new ball is released
    ' UpdatePFXLights(PlayfieldMultiplier(CurrentPlayer)) 'ensure the multiplier is displayed right
End Sub

Sub TurnOffPlayfieldLights()
    Dim a
    For each a in aLights
        a.State = 0
    Next
End Sub

Sub UpdateSkillShot() 'Setup and updates the skillshot lights
    LightSeqSkillshot.Play SeqAllOff
    Light48.State = 2
    Light18.State = 2
    Gate2.Open = 1
    Gate3.Open = 1
    DMD CL(0, "HIT LIT LIGHT"), CL(1, "FOR SKILLSHOT"), "", eNone, eNone, eNone, 1500, True, ""
End Sub

Sub ResetSkillShotTimer_Timer 'timer to reset the skillshot lights & variables
    ResetSkillShotTimer.Enabled = 0
    bSkillShotReady = False
    LightSeqSkillshot.StopPlay
    If Light18.State = 2 Then Light18.State = 0
    Light48.State = 0
    Gate2.Open = 0
    Gate3.Open = 0
    DMDScoreNow
End Sub

' *********************************************************************
'                        Table Object Hit Events
'
' Any target hit Sub will follow this:
' - play a sound
' - do some physical movement
' - add a score, bonus
' - check some variables/Mode this trigger is a member of
' - set the "LastSwitchHit" variable in case it is needed later
' *********************************************************************

'*********************************************************
' Slingshots has been hit
' In this table the slingshots change the outlanes lights

Dim LStep, RStep

Sub LeftSlingShot_Slingshot
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeWhiteLeft ' VR Callout
    ShakeVic
    RandomSoundSlingshotLeft Lemk
    DOF 105, DOFPulse
    LeftSling4.Visible = 1
    Lemk.RotX = 26
    LStep = 0
    LeftSlingShot.TimerEnabled = True
    ' add some points
    AddScore 210
    ' add some effect to the table?
    ' remember last trigger hit by the ball
    LastSwitchHit = "LeftSlingShot"
    ChangeOutlanes
	Shakelhand
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 1:LeftSLing4.Visible = 0:LeftSLing3.Visible = 1:Lemk.RotX = 14
        Case 2:LeftSLing3.Visible = 0:LeftSLing2.Visible = 1:Lemk.RotX = 2
        Case 3:LeftSLing2.Visible = 0:Lemk.RotX = -10:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub

Sub RightSlingShot_Slingshot
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeWhiteRight ' VR Callout
    ShakeVic
    RandomSoundSlingshotRight Remk
    DOF 106, DOFPulse
    RightSling4.Visible = 1
    Remk.RotX = 26
    RStep = 0
    RightSlingShot.TimerEnabled = True
    ' add some points
    AddScore 210
    ' add some effect to the table?
    ' remember last trigger hit by the ball
    LastSwitchHit = "RightSlingShot"
    ChangeOutlanes
	Shakerhand
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 1:RightSLing4.Visible = 0:RightSLing3.Visible = 1:Remk.RotX = 14
        Case 2:RightSLing3.Visible = 0:RightSLing2.Visible = 1:Remk.RotX = 2
        Case 3:RightSLing2.Visible = 0:Remk.RotX = -10:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub

Sub ChangeOutlanes
    Dim tmp
    tmp = light13.State
    light13.State = light16.State
    light16.State = tmp
End Sub

'*********
' Bumpers
'*********
' after each 30 hits the bumpers increase their score value by 500 points up to 3210
' and they increase the playfield multiplier.

Sub Bumper1_Hit
    If NOT Tilted Then

		if VRRoomChoice = 1 then SolidYellow ' VR Callout
        ShakeVic
        RandomSoundBumperTop Bumper1
        DOF 138, DOFPulse
		FlashForMs BLight001, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
		FlashForMs BLight001b, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
        ' add some points
        AddScore BumperValue(CurrentPlayer)
        If Battle(CurrentPlayer, 0) = 2 Then
            SuperBumperHits = SuperBumperHits + 1
            Addscore 5000
            CheckWinBattle
        End If
        ' remember last trigger hit by the ball
        LastSwitchHit = "Bumper1"
    End If
    CheckBumpers
End Sub

Sub Bumper2_Hit
    If NOT Tilted Then

		if VRRoomChoice = 1 then SolidGreen ' VR Callout
        ShakeVic
        RandomSoundBumperMiddle Bumper2
        DOF 140, DOFPulse
		FlashForMs BLight002, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
		FlashForMs BLight002b, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
        ' add some points
        ' add some points
        AddScore BumperValue(CurrentPlayer)
        If Battle(CurrentPlayer, 0) = 2 Then
            SuperBumperHits = SuperBumperHits + 1
            Addscore 5000
            CheckWinBattle
        End If
        ' remember last trigger hit by the ball
        LastSwitchHit = "Bumper2"
    End If
    CheckBumpers
End Sub

Sub Bumper3_Hit
    If NOT Tilted Then

		if VRRoomChoice = 1 then SolidWhite ' VR Callout
        ShakeVic
        RandomSoundBumperBottom Bumper3
        DOF 137, DOFPulse
		FlashForMs BLight003, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
		FlashForMs BLight003b, 1000, 50, 0
		'ObjLevel(9) = 1 : FlasherFlash9_Timer
        ' add some points
        ' add some points
        AddScore BumperValue(CurrentPlayer)
        If Battle(CurrentPlayer, 0) = 2 Then
            SuperBumperHits = SuperBumperHits + 1
            Addscore 5000
            CheckWinBattle
        End If
        ' remember last trigger hit by the ball
        LastSwitchHit = "Bumper3"
    End If
    CheckBumpers
End Sub

' Check the bumper hits

Sub CheckBumpers()
    ' increase the bumper hit count and increase the bumper value after each 30 hits
    BumperHits = BumperHits + 1
    If BumperHits MOD 30 = 0 Then
        If BumperValue(CurrentPlayer) < 3210 Then
            BumperValue(CurrentPlayer) = BumperValue(CurrentPlayer) + 500
        End If
        ' lit the playfield multiplier light
        light54.State = 1
    End If
End Sub

'*************************
' Top & Inlanes: Bonus X
'*************************
' lit the 2 top lane lights and the 2 inlane lights to increase the bonus multiplier

Sub sw1_Hit
    DOF 128, DOFPulse			'VPCLE
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeYellow ' VR Callout
    LaneBonus = LaneBonus + 1
    Light17.State = 1
    FlashForMs f8, 1000, 50, 0
    If bSkillShotReady Then
        ResetSkillShotTimer_Timer
    Else
        CheckBonusX
    End If
End Sub

Sub sw6_Hit
    DOF 129, DOFPulse			'VPCLE
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeRed ' VR Callout
    LaneBonus = LaneBonus + 1
    Light18.State = 1
    FlashForMs f8, 1000, 50, 0
    If bSkillShotReady Then
        Awardskillshot
    Else
        CheckBonusX
    End If
End Sub

Sub sw4_Hit				'Left Inlane
    If Tilted Then Exit Sub
    if Light14.State = 1 then
        DOF 155, DOFPulse		'VPCLE
    Else
        DOF 133, DOFPulse		'VPCLE
    End if
    if VRRoomChoice = 1 then StrobeWhiteSlow  'VR Callout
    LaneBonus = LaneBonus + 1
    Light14.State = 1
    FlashForMs f6, 1000, 50, 0
    AddScore 5000
    CheckBonusX
' Do some sound or light effect
End Sub

Sub sw3_Hit				'Right Inlane
    If Tilted Then Exit Sub
    if Light15.State = 1 then
        DOF 156, DOFPulse		'VPCLE
    Else
        DOF 134, DOFPulse		'VPCLE
    End if
    if VRRoomChoice = 1 then StrobeWhiteSlow  'VR Callout
    LaneBonus = LaneBonus + 1
    Light15.State = 1
    FlashForMs f7, 1000, 50, 0
    AddScore 5000
    CheckBonusX
' Do some sound or light effect
End Sub

Sub CheckBonusX
    If Light17.State + Light18.State + Light14.State + Light15.State = 4 Then
        AddBonusMultiplier 1
        GiEffect 1
        FlashForMs Light17, 1000, 50, 0
        FlashForMs Light18, 1000, 50, 0
        FlashForMs Light14, 1000, 50, 0
        FlashForMs Light15, 1000, 50, 0
    End IF
End Sub

'************************************
' Flipper OutLanes: Virtual kickback
'************************************
' if the light is lit then activate the ballsave

Sub sw2_Hit
    If Tilted Then Exit Sub
    if VRRoomChoice = 1 then StrobeRedSlow	'VR Callout
    LaneBonus = LaneBonus + 1
    AddScore 50000
    ' Do some sound or light effect
    ' do some check
    If light13.State = 1 Then
        DOF 147, DOFPulse			'VPCLE
        EnableBallSaver 5
    Else
        DOF 132, DOFPulse			'VPCLE
    End If
End Sub

Sub sw5_Hit
    If Tilted Then Exit Sub
    if VRRoomChoice = 1 then StrobeRedSlow 	'VR Callout
    LaneBonus = LaneBonus + 1
    AddScore 50000
    ' Do some sound or light effect
    ' do some check
    If Light16.State = 1 Then
	DOF 148, DOFPulse			'VPCLE
        EnableBallSaver 5
    Else
	DOF 135, DOFPulse			'VPCLE
    End If
End Sub

'************
'  Spinners
'************

Sub spinner1_Spin
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeRedLeft' VR Callout
    Addscore spinnervalue(CurrentPlayer)
    PlaySoundAt "Spinner", spinner1
    DOF 136, DOFPulse			'VPCLE
    Select Case Battle(CurrentPlayer, 0)
        Case 1
            Addscore 3000
            SpinCount = SpinCount + 1
            CheckWinBattle
    End Select
End Sub

Sub spinner2_Spin
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeRedRight' VR Callout
    PlaySoundAt "Spinner", spinner2
    DOF 124, DOFPulse			'VPCLE
    Addscore spinnervalue(CurrentPlayer)
    Select Case Battle(CurrentPlayer, 0)
        Case 1
            Addscore 3000
            SpinCount = SpinCount + 1
            CheckWinBattle
    End Select
End Sub

Sub spinner001_Spin									'Chopper Blades (VPCLE)
    If Tilted Then Exit Sub
    if ChopperSpinSound.Enabled = False then
	  PlaySound "Chopperblades"
          DOF 110, DOFPulse
          ChopperSpinSound.Enabled = True
	End if
End Sub

Sub spinner002_Spin									'Nuke Spin (VPCLE)
    If Tilted Then Exit Sub
    if NukeSpinSound.Enabled = False then
	  PlaySound "Whistle"
          DOF 112, DOFPulse
	  NukeSpinSound.Enabled = True
	End if
End Sub

Sub NukeSpinSound_Timer()						'VPCLE
	NukeSpinSound.Enabled = False 
End Sub

Sub ChopperSpinSound_Timer()					'VPCLE
	ChopperSpinSound.Enabled = False 
End Sub

'*********************************
'      The Lock Targets
'*********************************

Sub Target13_Hit
    PlaySoundAt SoundFXDOF("fx_target", 116, DOFPulse, DOFTargets), Target10
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeBlue' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    ' Do some sound or light effect
    Light19.State = 1
    FlashForMs f4, 1000, 50, 0
    ' do some check
    Check2BankTargets
    Select Case Battle(CurrentPlayer, 0)
        Case 5
            If Light31.State = 2 Then
                Light31.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light31.State = 2 Then
                Light33.State = 2
                Light31.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 8:TargetHits8 = TargetHits8 + 1:Addscore 25000:CheckWinBattle
        Case 9
            If Light31.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light31.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
    End Select
    LastSwitchHit = "Target13"
End Sub

Sub Target1_Hit
    PlaySoundAt SoundFXDOF("fx_target", 116, DOFPulse, DOFTargets), Target1
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeRandom' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    ' Do some sound or light effect
    Light20.State = 1
    FlashForMs f5, 1000, 50, 0
    ' do some check
    Check2BankTargets
    Select Case Battle(CurrentPlayer, 0)
        Case 5
            If Light29.State = 2 Then
                Light29.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light29.State = 2 Then
                Light29.State = 0
                Addscore 100000
                WinBattle
            End If
        Case 8:TargetHits8 = TargetHits8 + 1:Addscore 25000:CheckWinBattle
        Case 9
            If Light29.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light29.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
    End Select
    LastSwitchHit = "Target1"
End Sub

Sub Check2BankTargets
    If light19.state + light20.state = 2 Then
        light19.state = 0
        light20.state = 0
        LightEffect 1
        FlashEffect 1
        Addscore 20000
        If(Light46.State = 0)AND(bMultiballMode = FALSE)Then 'lit the lock light if it is off, open the sphynx door and activate the lock switch
            Light46.State = 1
            openDoor
            'PlaySound "vo_lockislit"
            DMD "_", CL(1, "LOCK IS LIT"), "_", eNone, eBlinkFast, eNone, 1000, True, ""
        ElseIf light53.State = 0 Then 'lit the increase jackpot light if the lock light is lit
            light53.State = 1
        'PlaySound "vo_IncreaseJakpot"
        Else
            Addscore 30000
        End If
    End If
End Sub

'**************************
' The Lock: Main Multiball
'**************************
' the lock is a virtual lock, where the locked balls are simply counted

Sub Door_Hit

	if VRRoomChoice = 1 then StrobeWhite' VR Callout
    PlaySoundAt "fx_woodhit", doorfl
    OpenDoor
End Sub

Sub lock_Hit

	if VRRoomChoice = 1 then StrobeGreenSlow ' VR Callout
    Dim delay
    delay = 500
    PlaySoundAt "fx_hole_enter", lock
    bsJackal.AddBall Me
    CloseDoor
    If(bJackpot = True)AND(light45.State = 2)Then
        light45.State = 0
        AwardJackpot
    End If
    If light46.State = 1 Then 'lock the ball
		DOF 117, DOFPulse				'VPCLE
        BallsInLock(CurrentPlayer) = BallsInLock(CurrentPlayer) + 1
        delay = 4000
        Select Case BallsInLock(CurrentPlayer)
            Case 1:DMD "_", CL(1, "BALL 1 LOCKED"), "_", eNone, eBlinkFast, eNone, 1000, True, "vo_ball1locked"
            Case 2:DMD "_", CL(1, "BALL 2 LOCKED"), "_", eNone, eBlinkFast, eNone, 1000, True, "vo_ball2locked"
            Case 3:DMD "_", CL(1, "BALL 3 LOCKED"), "_", eNone, eBlinkFast, eNone, 1000, True, "vo_ball3locked"
        End Select
        light46.State = 0
        If BallsInLock(CurrentPlayer) = 3 Then 'start multiball
            vpmtimer.addtimer 2000, "StartMainMultiball '"
        End If
    End If
    Select Case Battle(CurrentPlayer, 0)
        Case 5
            If Light37.State = 2 Then
                Light37.State = 0
                Addscore 100000
                CheckWinBattle
                Delay = 1000
            End If
        Case 6
            If Light37.State = 2 Then
                Light34.State = 2
                Light37.State = 0
                Addscore 100000
				CheckWinBattle
                Delay = 1000
            End If
        Case 9
            If Light37.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light37.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
    End Select
    If(Battle(CurrentPlayer, NewBattle) = 2)AND(Battle(CurrentPlayer, 0) = 0)Then 'the battle is ready, so start it
        vpmtimer.addtimer 2000, "StartBattle '"
        delay = 6000
    End If
    vpmtimer.addtimer delay, "JackalExit '"
End Sub

Sub StartMainMultiball

	if VRRoomChoice = 1 then StrobeRandom ' VR Callout
    AddMultiball 3
    StartSpinner
    DMD "_", CL(1, "MULTIBALL"), "_", eNone, eBlinkFast, eNone, 1000, True, "vo_multiball"
    StartJackpots
    ChangeGi 5
    'reset BallsInLock variable
    BallsInLock(CurrentPlayer) = 0
    ' 20 seconds ball saver
    EnableBallSaver 20
End Sub

Sub OpenDoor
	PlaySoundAt "Door-Squeal", DoorFL
    DoorFL.RotateToEnd
    DoorFR.RotateToEnd
    door.IsDropped = 1
End Sub

Sub CloseDoor
	PlaySoundAt "Door-Closed", DoorFL
    DoorFL.RotateToStart
    DoorFR.RotateToStart
    door.IsDropped = 0
End Sub

'**********
' Jackpots
'**********
' Jackpots are enabled during the Main multiball and the wizard battles

Sub StartJackpots
    bJackpot = true
    'turn on the jackpot lights
    Select Case Battle(CurrentPlayer, 0)
        Case 9 'Anubis - jackpots on the ramps
            light44.State = 2
            light40.State = 2
        Case 10 'Osiris - jackpots on the sphynxs
            light42.State = 2
            light40.State = 2
            light45.State = 2
        Case 11 'Horus - jackpots on the ramps
            light44.State = 2
            light40.State = 2
        Case 12 'Ra - jackpots on the sphynxs
            light42.State = 2
            light40.State = 2
            light45.State = 2
        Case 13 'final battle - all jackpots on
            light42.State = 2
            light41.State = 2
            light40.State = 2
            light44.State = 2
            light45.State = 2
            Light49.State = 2
            light51.State = 2
        Case Else
            If bMultiballMode Then
                light44.State = 2
                light49.State = 2
            End If
    End Select
End Sub

Sub ResetJackpotLights 'when multiball is finished, resets jackpot and superjackpot lights
    bJackpot = False
    light42.State = 0
    light41.State = 0
    light40.State = 0
    light44.State = 0
    light45.State = 0
    Light49.State = 0
    light51.State = 0
End Sub

Sub EnableSuperJackpot
    If bJackpot = True Then
        If light42.State + light41.State + light40.State + light44.State + light45.State + Light49.State + light51.State = 0 Then
            'PlaySound "vo_superjackpotislit"
            light48.State = 2
            light52.State = 2
        End If
    End If
End Sub

'***********************************
' Blue Targets:  The Mummy Targets
'***********************************

Sub Target2_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 150, DOFPulse, DOFTargets)		'VPCLE
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeBlueRight ' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target2"
    ' Do some sound or light effect
    Light23.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Target4_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 120, DOFPulse, DOFTargets)
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeBlueLeft ' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target4"
    ' Do some sound or light effect
    Light24.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Target5_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 151, DOFPulse, DOFTargets)		'VPCLE
    If Tilted Then Exit Sub
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target5"
    ' Do some sound or light effect
    Light25.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Target7_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 152, DOFPulse, DOFTargets)		'VPCLE
    If Tilted Then Exit Sub
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target7"
    ' Do some sound or light effect
    Light26.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Target10_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 114, DOFPulse, DOFTargets)
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeYellowSlow ' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target10"
    ' Do some sound or light effect
    Light27.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Target8_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 153, DOFPulse, DOFTargets)		'VPCLE
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeYellowSlow ' VR Callout
    AddScore 5000
    TargetBonus = TargetBonus + 1
    LastSwitchHit = "Target8"
    ' Do some sound or light effect
    Light28.State = 1
    ' do some check
    Select Case Battle(CurrentPlayer, 0)
        Case 7:TargetHits7 = TargetHits7 + 1:Addscore 10000:CheckWinBattle
    End Select
    Check6BankTargets
End Sub

Sub Check6BankTargets
    Dim tmp
    FlashForMs f1, 1000, 50, 0
    FlashForMs f3, 1000, 50, 0
    FlashForMs f4, 1000, 50, 0
    FlashForMs f4, 1000, 50, 0
    tmp = INT(RND * 26) + 1
    PlaySoundAtBall "enemy_" &tmp
    ' if all 6 targets are hit then kill a monster & activate the mystery light
    If light23.state + light24.state + light25.state + light26.state + light27.state + light28.state = 6 Then
        ' kill a monster
        MonstersKilled(CurrentPlayer) = MonstersKilled(CurrentPlayer) + 1
        AddCityLight
        LightEffect 1
        FlashEffect 1
        ' Lit the Mystery light if it is off
        If Light38.State = 1 Then
            AddScore 50000
        Else
            Light38.State = 1
            AddScore 25000
        End If
        ' reset the lights
        light23.state = 0
        light24.state = 0
        light25.state = 0
        light26.state = 0
        light27.state = 0
        light28.state = 0
    End If
End Sub

' Playfiel Multiplier timer: reduces the multiplier after 30 seconds

Sub pfxtimer_Timer
    If PlayfieldMultiplier(CurrentPlayer) > 1 Then
        PlayfieldMultiplier(CurrentPlayer) = PlayfieldMultiplier(CurrentPlayer)-1
        SetPlayfieldMultiplier PlayfieldMultiplier(CurrentPlayer)
    Else
        pfxtimer.Enabled = 0
    End If
End Sub

'*****************
'  Captive Target
'*****************

Sub Target9_Hit
    PlaySoundAtBall SoundFXDOF("fx_target", 154, DOFPulse, DOFTargets)		'VPCLE
    If Tilted Then Exit Sub
	if VRRoomChoice = 1 then StrobeBlueSlow ' VR Callout
    If bSkillShotReady Then
        Awardskillshot
        Exit Sub
    End If
    AddScore 5000 'all targets score 5000
    ' Do some sound or light effect
    ' do some check
    If(bJackpot = True)AND(light52.State = 2)Then
        AwardSuperJackpot
        light52.State = 0
        light48.State = 0
        StartJackpots
    End If
    Select Case Battle(CurrentPlayer, 0)
        Case 0:SelectBattle 'no battle is active then change to another battle
    End Select

    ' increase the playfield multiplier for 30 seconds
    If light54.State = 1 Then
        AddPlayfieldMultiplier 1
        light54.State = 0
    End If

    ' increase Jackpot
    If light53.State = 1 Then
        AddJackpot 50000
        light53.State = 0
    End If
End Sub

'****************************
'  Jackal Hole Hit & Awards
'****************************

Sub JackalHole_Hit
    Dim Delay
    Delay = 200
    PlaySoundAt "fx_hole_enter", JackalHole
    bsJackal.AddBall Me
    If NOT Tilted Then

		if VRRoomChoice = 1 then StrobeRandomSlow 'VR Callout
        ' do something
        If(bJackpot = True)AND(light40.State = 2)Then
            light40.State = 0
            AwardJackpot
            Delay = 2000
        End If
        If light38.State = 1 Then ' mystery light is lit
            light38.State = 0
            GiveRandomAward
            Delay = 3500
        End If
        If light39.State = 2 Then ' extra ball is lit
            light39.State = 0
            AwardExtraBall
            Delay = 2000
        End If
        Select Case Battle(CurrentPlayer, 0)
            Case 5
                If Light32.State = 2 Then
                    Light32.State = 0
                    Addscore 100000
                    CheckWinBattle
                    Delay = 1000
                End If
            Case 6
                If Light32.State = 2 Then
                    Light36.State = 2
                    Light32.State = 0
                    Addscore 100000
					CheckWinBattle
                    Delay = 1000
                End If
            Case 9
                If Light32.State = 2 Then
                    AddScore 100000
                    FlashEffect 3
                    DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
                End If
            Case 11
                If Light32.State = 2 Then
                    AddScore 120000
                    FlashEffect 3
                    DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
                End If
        End Select
    End If
    vpmtimer.addtimer Delay, "JackalExit '"
End Sub

Sub JackalExit()
    If bsJackal.Balls > 0 Then

		if VRRoomChoice = 1 then StrobeWhiteLeft ' VR Callout
        FlashForMs f1, 1000, 50, 0
        PlaySoundAt SoundFXDOF("fx_kicker", 119, DOFPulse, DOFContactors), JackalHole
        DOF 121, DOFPulse
        PlaySoundAt "fx_cannon", JackalHole
		'add a small delay before actually kicking the ball
        vpmtimer.addtimer 500, "bsJackal.ExitSol_On '"
    End If
    'kick out all the balls
    If bsJackal.Balls > 0 Then
        vpmtimer.Addtimer 500, "JackalExit '"
    End If
End Sub

Sub GiveRandomAward() 'from the Jackal Sphynx
    Dim tmp, tmp2

    ' show some random values on the dmd
    DMD CL(0, "JACKAL AWARD"), "", "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "PLAYFIELD X"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "BUMPER VALUE"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA BALL"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "BONUS X"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "SPINNER VALUE"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "BUMPER VALUE"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "PLAYFIELD X"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "BUMPER VALUE"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA POINTS"), "", eNone, eNone, eNone, 50, False, "fx_spinner"
    DMD "_", CL(1, "EXTRA BALL"), "", eNone, eNone, eNone, 50, False, "fx_spinner"

    tmp = INT(RND(1) * 80)
    Select Case tmp
        Case 1, 2, 3, 4, 5, 6 'Lit Extra Ball
            DMD "", CL(1, "EXTRA BALL IS LIT"), "", eNone, eBlink, eNone, 1500, True, "fx_fanfare1"
            light39.State = 2
        Case 7, 8, 13, 14, 15 '100,000 points
            DMD CL(0, "BIG POINTS"), CL(1, "100000"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddScore 100000
        Case 9, 10, 11, 12 'Hold Bonus
            DMD CL(0, "BONUS HELD"), CL(1, "ACTIVATED"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            bBonusHeld = True
        Case 16, 17, 18 'Increase Bonus Multiplier
            DMD CL(0, "INCREASED"), CL(1, "BONUS X"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddBonusMultiplier 1
        Case 19, 20, 21 'Complete Battle
            If Battle(CurrentPlayer, 0) > 0 AND Battle(CurrentPlayer, 0) < 13 Then
                DMD CL(0, "BATTLE"), CL(1, "COMPLETED"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
                WinBattle
            Else
                DMD CL(0, "BIG POINTS"), CL(1, "100000"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
                AddScore 100000
            End If
        Case 22, 23, 36, 37, 38 'PlayField multiplier
            DMD CL(0, "INCREASED"), CL(1, "PLAYFIELD X"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddPlayfieldMultiplier 1
        Case 24, 25, 26, 27, 28 '100,000 points
            DMD CL(0, "BIG POINTS"), CL(1, "100000"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddScore 100000
        Case 29, 30, 31, 32, 33, 34, 35 'Increase Bumper value
            BumperValue(CurrentPlayer) = BumperValue(CurrentPlayer) + 500
            DMD CL(0, "BUMPER VALUE"), CL(1, BumperValue(CurrentPlayer)), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
        Case 39, 40, 43, 44 'extra multiball
            DMD CL(0, "EXTRA"), CL(1, "MULTIBALL"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddMultiball 1
        Case 45, 46, 47, 48 ' Ball Save
            DMD CL(0, "BALL SAVE"), CL(1, "ACTIVATED"), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            EnableBallSaver 20
        Case ELSE 'Add a Random score from 10.000 to 100,000 points
            tmp2 = INT((RND) * 9) * 10000 + 10000
            DMD CL(0, "EXTRA POINTS"), CL(1, tmp2), "", eBlink, eBlink, eNone, 1500, True, "fx_fanfare1"
            AddScore tmp2
    End Select
End Sub

'*****************
' Ball Launched
'*****************
Sub sw99_Hit			'VPCLE
    If Tilted Then Exit Sub
    DOF 147, DOFPulse
End Sub

'*******************
'   The Orbit lanes
'*******************

Sub sw8_Hit
    DOF 130, DOFPulse
    If Tilted Then Exit Sub
    LaneBonus = LaneBonus + 1
    If(bJackpot = True)AND(light41.State = 2)Then
        light41.State = 0
        AwardJackpot
    End If
    Select Case Battle(CurrentPlayer, 0)
        Case 4:OrbitHits = OrbitHits + 1:Addscore 70000:CheckWinBattle
        Case 5
            If Light33.State = 2 Then
                Light33.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light33.State = 2 Then
                Light32.State = 2
                Light33.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 9
            If Light33.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 10
            If LastSwitchHit = "sw7" Then
                LastSwitchHit = ""
                loopCount = loopCount + 1
                Addscore 140000
                CheckWinBattle
            End If
        Case 11
            If Light33.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 12
            If Light33.State = 2 Then
                RampHits12 = RampHits12 + 1
                Light34.State = 2
                Light36.State = 2
                Light33.State = 0
                Light35.State = 0
                Addscore 100000
                CheckWinBattle
            End If
    End Select
    LastSwitchHit = "sw8"
End Sub

Sub sw7_Hit
    DOF 131, DOFPulse
    If Tilted Then Exit Sub
    LaneBonus = LaneBonus + 1
    If(bJackpot = True)AND(light51.State = 2)Then
        light51.State = 0
        AwardJackpot
    End If
    Select Case Battle(CurrentPlayer, 0)
        Case 4:OrbitHits = OrbitHits + 1:Addscore 70000:CheckWinBattle
        Case 5
            If Light35.State = 2 Then
                Light35.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light35.State = 2 Then
                Light29.State = 2
                Light35.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 9
            If Light35.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 10
            If LastSwitchHit = "sw8" Then
                LastSwitchHit = ""
                loopCount = loopCount + 1
                Addscore 140000
                CheckWinBattle
            End If
        Case 11
            If Light35.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 12
            If Light35.State = 2 Then
                RampHits12 = RampHits12 + 1
                Light34.State = 2
                Light36.State = 2
                Light33.State = 0
                Light35.State = 0
                Addscore 100000
                CheckWinBattle
            End If
    End Select
    LastSwitchHit = "sw7"
End Sub

'****************
'     Ramps
'****************

Sub LeftRampDone_Hit
    Dim tmp
    If Tilted Then Exit Sub
    'increase the ramp bonus
    RampBonus = RampBonus + 1
    If(bJackpot = True)AND(light44.State = 2)Then
        light44.State = 0
        AwardJackpot
    End If
    'PowerUp - left ramp only counts the variable
    PowerupHits = PowerupHits + 1
    CheckPowerup
    'Battles
    Select Case Battle(CurrentPlayer, 0)
        Case 3:RampHits3 = RampHits3 + 1:Addscore 100000:CheckWinBattle
        Case 5
            If Light36.State = 2 Then
                Light36.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light36.State = 2 Then
                Light37.State = 2
                Light36.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 9
            If Light36.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light36.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 12
            If Light36.State = 2 Then
                RampHits12 = RampHits12 + 1
                Light34.State = 0
                Light36.State = 0
                Light33.State = 2
                Light35.State = 2
                Addscore 100000
                CheckWinBattle
            End If
        Case else
            ' play ss quote
            PlayQuote
    End Select
    'check for combos
    if LastSwitchHit = "RightRampDone" OR LastSwitchHit = "LeftRampDone" Then
        Addscore jackpot(CurrentPlayer)
        DMD CL(0, "COMBO"), CL(1, jackpot(CurrentPlayer)), "_", eNone, eBlinkFast, eNone, 1000, True, ""
    End If
    LastSwitchHit = "LeftRampDone"
End Sub

Sub RightRampDone_Hit
    Dim tmp
    If Tilted Then Exit Sub
    ' Start the helicopter blades
    StartHelicopterBlades
    'increase the ramp bonus
    RampBonus = RampBonus + 1
    If(bJackpot = True)AND(light49.State = 2)Then
        light49.State = 0
        AwardJackpot
    End If
    'Powerup - rightt ramp counts the variable and give the jackpot if light31 is lit
    If light50.State = 2 Then
        DMD CL(0, "POWERUP AWARD"), CL(1, jackpot(CurrentPlayer)), "_", eNone, eBlinkFast, eNone, 1000, True, "vo_Jackpot"
        AddScore Jackpot(CurrentPlayer)
        LightEffect 2
        FlashEffect 2
    Else
        PowerupHits = PowerupHits + 1
        CheckPowerup
    End If
    'Battles
    Select Case Battle(CurrentPlayer, 0)
        Case 3:RampHits3 = RampHits3 + 1:Addscore 100000:CheckWinBattle
        Case 5
            If Light34.State = 2 Then
                Light34.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light34.State = 2 Then
                Light35.State = 2
                Light34.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 9
            If Light34.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light34.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 12
            If Light34.State = 2 Then
                RampHits12 = RampHits12 + 1
                Light34.State = 0
                Light36.State = 0
                Light33.State = 2
                Light35.State = 2
                Addscore 100000
                CheckWinBattle
            End If
        Case else
            ' play ss quote
            PlayQuote
    End Select

    'check for combos
    if LastSwitchHit = "RightRampDone" OR LastSwitchHit = "LeftRampDone" Then
        Addscore jackpot(CurrentPlayer)
        DMD CL(0, "COMBO"), CL(1, jackpot(CurrentPlayer)), "_", eNone, eBlinkFast, eNone, 1000, True, ""
    End If
    LastSwitchHit = "RightRampDone"
End Sub

Sub StartHelicopterBlades
End Sub

'******************
' Left Sphynx : Ram
'******************

Sub Target12_Hit
    If Tilted Then Exit Sub
    PlaySoundAtBall "fx_target"
    DOF 113, DOFPulse			'VPCLE
	if VRRoomChoice = 1 then StrobeRandom ' VR Callout
    If(bJackpot = True)AND(light42.State = 2)Then
        light42.State = 0
        AwardJackpot
    End If
    Select Case Battle(CurrentPlayer, 0)
        Case 5
            If Light30.State = 2 Then
                Light30.State = 0
                Addscore 100000
                CheckWinBattle
            End If
        Case 6
            If Light30.State = 2 Then
                Light31.State = 2
                Light30.State = 0
                Addscore 100000
				CheckWinBattle
            End If
        Case 9
            If Light30.State = 2 Then
                AddScore 100000
                FlashEffect 3
                LightHits9 = LightHits9 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("100000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
        Case 11
            If Light30.State = 2 Then
                AddScore 120000
                FlashEffect 3
                LightHits11 = LightHits11 + 1
                CheckWinBattle
                DMD "_", CL(1, FormatScore("120000")), "_", eNone, eBlinkFast, eNone, 500, True, ""
            End If
    End Select
    LastSwitchHit = "Target12"
End Sub

'************************
'       Battles
'************************

' This table has 12 main battles, and a final battle
' you may choose any the 12 main battles you want to play
' After completing all 12 battles you play the final battle

' current active battle number is stored in Battle(CurrentPlayer,0)

Sub SelectBattle 'select a new random battle if none is active
    Dim i
    If Battle(CurrentPlayer, 0) = 0 Then
        ' reset the battles that are not finished
        For i = 1 to 12
            If Battle(CurrentPlayer, i) = 2 Then Battle(CurrentPlayer, i) = 0
        Next
        If BattlesWon(CurrentPlayer) = 12 tHEN
          '  NewBattle = 13:Battle(CurrentPlayer, NewBattle) = 2:UpdateBattleLights:StartBattle '13 battle is the wizard
        Else
            NewBattle = INT(RND * 12 + 1)
            do while Battle(CurrentPlayer, NewBattle) <> 0
                NewBattle = INT(RND * 11 + 1)
            loop
            Battle(CurrentPlayer, NewBattle) = 2
            Light47.State = 2
            'UpdateBattleLights
        End iF
    'debug.print "newbatle " & newbattle
    End If
End Sub

' Update the lights according to the battle's state
'Sub UpdateBattleLights
   ' Light11.State = Battle(CurrentPlayer, 1)
   ' Light12.State = Battle(CurrentPlayer, 2)
   ' Light9.State = Battle(CurrentPlayer, 3)
   ' Light10.State = Battle(CurrentPlayer, 4)
   ' Light7.State = Battle(CurrentPlayer, 5)
   ' Light8.State = Battle(CurrentPlayer, 6)
   ' Light5.State = Battle(CurrentPlayer, 7)
    'Light6.State = Battle(CurrentPlayer, 8)
  '  Light1.State = Battle(CurrentPlayer, 9)
    'Light2.State = Battle(CurrentPlayer, 10)
   ' Light4.State = Battle(CurrentPlayer, 11)
   ' Light3.State = Battle(CurrentPlayer, 12)
'End Sub

' Starting a battle means to setup some lights and variables, maybe timers
' Battle lights will always blink during an active battle
Sub StartBattle
    Battle(CurrentPlayer, 0) = NewBattle
    Light47.State = 0
    'ChangeSong
    PlaySound "fx_alarm"
	vpmtimer.addtimer 700, "Playmode '"
    Select Case NewBattle
        Case 1 'Bast = Super Spinners
            DMD CL(0, "TRUST"), CL(1, "SHOOT THE SPINNERS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_Trust": pupevent 800
            Light33.State = 2
            Light35.State = 2
        Case 2 'Isis = Super Pop Bumpers
            DMD CL(0, "TORNADO OF SOULS"), CL(1, "HIT THE POP BUMPERS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_TornadoOfSouls": pupevent 801
            Light55.State = 2
            LightSeqBumpers.Play SeqRandom, 10, , 1000
        Case 3 'Amon = Ramps
            DMD CL(0, "THIS IS MY LIFE"), CL(1, "SHOOT THE RAMPS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_ThisWasMyLife": pupevent 802
            Light36.State = 2
            Light34.State = 2
        Case 4 'Shu = Orbits
            DMD CL(0, "THE SCORPION"), CL(1, "SHOOT THE ORBITS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_TheScorpion":pupevent 803
            Light33.State = 2
            Light35.State = 2
        Case 5 'Set = Shoot the lights 2
            DMD CL(0, "TAKE NO PRISIONERS"), CL(1, "SHOOT THE LIGHTS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_TakeNoPrisoners" : pupevent 804
            Light29.State = 2
            Light30.State = 2
            Light31.State = 2
            Light32.State = 2
            Light33.State = 2
            Light34.State = 2
            Light35.State = 2
            Light36.State = 2
            Light37.State = 2
        Case 6 'Nepthys= Shoot the lights 1
            DMD CL(0, "SYMPHONY DESTRUCTION"), CL(1, "SHOOT THE LIGHTS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_SymphonyOfDestruction": pupevent 805
            Light30.State = 2
        Case 7 'Bes =  Blue Target Frenzy
            DMD CL(0, "SWEATING BULLETS"), CL(1, "SHOOT THE TARGETS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_SweatingBullets": pupevent 806
            LightSeqBlueTargets.Play SeqRandom, 10, , 1000
        Case 8 'Serget = Left & Right Targets
            DMD CL(0, "SKIN ON MY TEETH"), CL(1, "SHOOT THE TARGETS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_SkinOMyTeeth": pupevent 807
            Light31.State = 2
            Light29.State = 2
        Case 9 'Anubis = Follow the Lights 1
            DMD CL(0, "PEACE SELLS"), CL(1, "SHOOT LIT LIGHTS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_PeaceSells": pupevent 808
            FollowTheLights.Enabled = 1
        Case 10 'Osiris = Super Loops
            DMD CL(0, "DREAD FUGITIVE MIND"), CL(1, "SHOOT THE LOOPS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_DreadAndTheFugitiveMind" : pupevent 809
            Light33.State = 2
            Light35.State = 2
            Gate2.Open = 1
            Gate3.Open = 1
        Case 11 'Horus = Follow the Lights 2
            DMD CL(0, "COUNTDOWN EXTINCTION"), CL(1, "SHOOT LIT LIGHTS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_CountdownToExtinction": pupevent 810
            FollowTheLights.Enabled = 1
        Case 12 'Ra = Ramps and Orbits
            'uses the ramphits12 to count the hits
            DMD CL(0, "A TOUT LMONDE"), CL(1, "SHOOT RAMPS ORBITS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_AToutLMonde" : pupevent 811
            Light36.State = 2
            Light34.State = 2
        Case 13 'Mordekai the Summoner - the final battle
            DMD CL(0, "AGGRESSION"), CL(1, "SHOOT THE JACKPOTS"), "", eNone, eNone, eNone, 1000, True, ""
			PlaySong "m_ArchitectureOfAggression" : pupevent 812
            AddMultiball 4
            StartSpinner
            StartJackpots
            ChangeGi 5
            '20 seconds ball saver
            EnableBallSaver 20
    End Select
End Sub

' check if the battle is completed
Sub CheckWinBattle
    dim tmp
    tmp = INT(RND * 7) + 1
    PlaySound "fx_thunder" & tmp
    DOF 126, DOFPulse
    LightSeqInserts.StopPlay 'stop the light effects before starting again so they don't play too long.
    LightEffect 3
	FlashEffect 3
    Select Case NewBattle
        Case 1
            If SpinCount = 100 Then WinBattle:End if
        Case 2
            If SuperBumperHits = 25 Then WinBattle:End if
        Case 3
            If RampHits3 = 6 Then WinBattle:End if
        Case 4
            If OrbitHits = 6 Then WinBattle:End if
        Case 5
            If Light29.State + Light30.State + Light31.State + Light32.State + Light33.State + Light34.State + Light35.State + Light36.State + Light37.State = 0 Then WinBattle:End if
        Case 6 'the last light win the battle
        Case 7
            If TargetHits7 = 20 Then WinBattle:End if
        Case 8
            If TargetHits8 = 6 Then WinBattle:End if
        Case 9
            If LightHits9 = 8 Then WinBattle:End if
        Case 10:
            If loopCount = 6 Then WinBattle
        Case 11
            If LightHits11 = 8 Then WinBattle:End if
        Case 12
            If RampHits12 = 6 Then WinBattle:End if
    End Select
End Sub

Sub StopBattle 'called at the end of a ball
    Dim i
    Battle(CurrentPlayer, 0) = 0
    For i = 0 to 15
        If Battle(CurrentPlayer, i) = 2 Then Battle(CurrentPlayer, i) = 0
    Next
    'UpdateBattleLights
    StopBattle2
    NewBattle = 0
End Sub

'called after completing a battle
Sub WinBattle
	PlayComplete
    Dim tmp
    BattlesWon(CurrentPlayer) = BattlesWon(CurrentPlayer) + 1
    Battle(CurrentPlayer, 0) = 0
    Battle(CurrentPlayer, NewBattle) = 1
    'UpdateBattleLights
    FlashEffect 2
    LightEffect 2
    GiEffect 2
    DMD "", CL(1, "BATTLE COMPLETED"), "_", eNone, eBlinkFast, eNone, 1000, True, "fx_Explosion01"
    DOF 139, DOFPulse
    tmp = INT(RND * 4)
    Select Case tmp
        Case 0:vpmtimer.addtimer 1500, "PlayComplete '"
        Case 1:vpmtimer.addtimer 1500, "PlayComplete '"
        Case 2:vpmtimer.addtimer 1500, "PlayComplete '"
        Case 3:vpmtimer.addtimer 1500, "PlayComplete '"
    End Select
    StopBattle2
    NewBattle = 0
    SelectBattle 'automatically select a new battle
	'add a multiball after each 2 won battles
    Select Case BattlesWon(CurrentPlayer)
		Case 3,6,9: AddMultiball 2: StartSpinner: EnableBallSaver 20
	End Select	
    'ChangeSong
End Sub

Sub StopBattle2
    'Turn off the bomb lights
    Light29.State = 0
    Light30.State = 0
    Light31.State = 0
    Light32.State = 0
    Light33.State = 0
    Light34.State = 0
    Light35.State = 0
    Light36.State = 0
    Light37.State = 0
    ' stop some timers or reset battle variables
    Select Case NewBattle
        Case 1:SpinCount = 0
        Case 2:Light55.State = 0:LightSeqBumpers.StopPlay:SuperBumperHits = 0
        Case 3,12:
        Case 4:OrbitHits = 0
        Case 7:LightSeqBlueTargets.StopPlay
        Case 8:
        Case 9,11:FollowTheLights.Enabled = 0
        Case 10:LoopCount = 0:Gate2.Open = 0:Gate3.Open = 0
        Case 13:ResetBattles:SelectBattle
    End Select
End Sub

Sub ResetBattles
    Dim i, j
    For j = 0 to 4
        BattlesWon(j) = 0
        For i = 0 to 12
            Battle(CurrentPlayer, i) = 0
        Next
    Next
    NewBattle = 0
End Sub

'Extra subs for the battles

Sub LightSeqAllTargets_PlayDone()
    LightSeqAllTargets.Play SeqRandom, 10, , 1000
End Sub

Sub LightSeqBumpers_PlayDone()
    LightSeqBumpers.Play SeqRandom, 10, , 1000
End Sub

Sub LightSeqBlueTargets_PlayDone()
    LightSeqBlueTargets.Play SeqRandom, 10, , 1000
End Sub

' Wizards modes timer
Dim FTLstep:FTLstep = 0

Sub FollowTheLights_Timer
    Light29.State = 0
    Light30.State = 0
    Light31.State = 0
    Light32.State = 0
    Light33.State = 0
    Light34.State = 0
    Light35.State = 0
    Light36.State = 0
    Light37.State = 0
    Select Case Battle(CurrentPlayer, 0)
        Case 9
            Select case FTLstep
                Case 0:FTLstep = 1:Light29.State = 2
                Case 1:FTLstep = 2:Light30.State = 2
                Case 2:FTLstep = 3:Light31.State = 2
                Case 3:FTLstep = 4:Light32.State = 2
                Case 4:FTLstep = 5:Light33.State = 2
                Case 5:FTLstep = 6:Light34.State = 2
                Case 6:FTLstep = 7:Light35.State = 2
                Case 7:FTLstep = 8:Light36.State = 2
                Case 8:FTLstep = 0:Light37.State = 2
            End Select
        Case 11
            FTLstep = INT(RND * 9)
            Select case FTLstep
                Case 0:Light29.State = 2
                Case 1:Light30.State = 2
                Case 2:Light31.State = 2
                Case 3:Light32.State = 2
                Case 4:Light33.State = 2
                Case 5:Light34.State = 2
                Case 6:Light35.State = 2
                Case 7:Light36.State = 2
                Case 8:Light37.State = 2
            End Select
    End Select
End Sub

'**********************
' Power up Jackpot
'**********************
' 30 seconds hurry up with jackpots on the right ramp
' uses variable PowerupHits and the light50

Sub CheckPowerup
    If light50.State = 0 Then
        If PowerupHits MOD 10 = 0 Then
            EnablePowerup
        End If
    End If
End Sub

Sub EnablePowerup
    ' start the timers
    PowerupTimerExpired.Enabled = True
    PowerupSpeedUpTimer.Enabled = True
    ' turn on the light
    Light50.BlinkInterval = 160
    Light50.State = 2
End Sub

Sub PowerupTimerExpired_Timer()
    PowerupTimerExpired.Enabled = False
    ' turn off the light
    Light50.State = 0
End Sub

Sub PowerupSpeedUpTimer_Timer()
    PowerupSpeedUpTimer.Enabled = False
    ' Speed up the blinking
    Light50.BlinkInterval = 80
    Light50.State = 2
End Sub

 'Shake Subs

' Tank head
Dim MyPi, tankStep, tankDir
MyPi = Round(4 * Atn(1), 6) / 10

Sub Shaketank
    tankStep = 0
    tankTimer.Enabled = 1
End Sub

Sub tankTimer_Timer
    tankDir = SIN(tankStep * MyPi)
    tankStep = (tankStep + 1)MOD 40
    Tankhead.RotY = tankDir * 20
    If tankStep = 0 Then 
        tanktimer.Enabled = 0
    End If
End Sub

' Vic shake
Dim VicPos

Sub ShakeVic
    VicPos = 8
    VicTimer.Enabled = 1
End Sub

Sub VicTimer_Timer
    Vic.TransY = VicPos
    If VicPos = 0 Then Me.Enabled = 0:Exit Sub
    If VicPos < 0 Then
        VicPos = ABS(VicPos) - 1
    Else
        VicPos = - VicPos + 1
    End If
End Sub

' left and right hands
Dim lhandPos, rhandPos

Sub Shakelhand
    lhandPos = 8
    lhandTimer.Enabled = 1
End Sub

Sub lhandTimer_Timer
    lhand.TransY = lhandPos
    If lhandPos = 0 Then Me.Enabled = 0:Exit Sub
    If lhandPos < 0 Then
        lhandPos = ABS(lhandPos) - 1
    Else
        lhandPos = - lhandPos + 1
    End If
End Sub

Sub Shakerhand
    rhandPos = 8
    rhandTimer.Enabled = 1
End Sub

Sub rhandTimer_Timer
    rhand.TransY = rhandPos
    If rhandPos = 0 Then Me.Enabled = 0:Exit Sub
    If rhandPos < 0 Then
        rhandPos = ABS(rhandPos) - 1
    Else
        rhandPos = - rhandPos + 1
    End If
End Sub

' Turntable - Spinner disk

Sub StartSpinner
    ttSpinDisk.MotorOn = True
    TurnTT.Enabled = True
End Sub

Sub StopSpinner
    ttSpinDisk.MotorOn = False
    If ttSpinDisk.Speed < 5 Then
        TurnTT.Enabled = False
    End If
End Sub

Sub TurnTT_Timer
    Dim tmp
    tmp = (SpinnDisk.Rotz + ttSpinDisk.Speed) MOD 360
    SpinnDisk.Rotz = tmp
End Sub

'*******************************************************************
'-------------------------------------------------------------------
'*******************************************************************
'****** PuP Variables ******

Dim usePUP: Dim cPuPPack: Dim PuPlayer: Dim PUPStatus: PUPStatus=false ' dont edit this line!!!

'*************************** PuP Settings for this table ********************************

If Videos = True Then usePUP = True : End If
If Videos = False Then usePUP = False : End If               ' enable Pinup Player functions for this table
cPuPPack = "Megadeth"    ' name of the PuP-Pack / PuPVideos folder for this table

'//////////////////// PINUP PLAYER: STARTUP & CONTROL SECTION //////////////////////////

' This is used for the startup and control of Pinup Player

Sub PuPStart(cPuPPack)
    If PUPStatus=true then Exit Sub
    If usePUP=true then
        Set PuPlayer = CreateObject("PinUpPlayer.PinDisplay")
        If PuPlayer is Nothing Then
            usePUP=false
            PUPStatus=false
        Else
            PuPlayer.B2SInit "",cPuPPack 'start the Pup-Pack
            PUPStatus=true
        End If
    End If
End Sub

Sub pupevent(EventNum)
    if (usePUP=false or PUPStatus=false) then Exit Sub
    PuPlayer.B2SData "E"&EventNum,1  'send event to Pup-Pack
End Sub

PuPStart(cPuPPack) 'Check for PuP - If found, then start Pinup Player / PuP-Pack	

'*******************************************************************
'-------------------------------------------------------------------
'*******************************************************************


'Sounds Call Outs

Sub PlayBallSaved
    Dim tmp
    tmp = INT(RND * 13) + 1
    PlaySound "saved_" &tmp
End Sub

Sub PlayBallLost
    Dim tmp
    tmp = INT(RND * 15) + 1
    PlaySound "lost_" &tmp
End Sub

Sub PlayPlungerRest
    Dim tmp
    tmp = INT(RND * 6) + 1
    PlaySound "rest_" &tmp
End Sub

Sub Playname
    Dim tmp
    tmp = INT(RND * 3) + 1
    PlaySound "name_" &tmp
End Sub


Sub PlayOver
    Dim tmp
    tmp = INT(RND * 7) + 1
    PlaySound "gameover_" &tmp
End Sub

Sub Playmode
    Dim tmp
    tmp = INT(RND * 4) + 1
    PlaySound "mode_" &tmp
End Sub

Sub PlayComplete
    Dim tmp
    tmp = INT(RND * 7) + 1
    PlaySound "complete_" &tmp
End Sub

Sub Playstart
    Dim tmp
    tmp = INT(RND * 9) + 1
    PlaySound "start_" &tmp
End Sub

' City Lights

Sub AddCityLight
Dim tmp
If MonstersKilled(CurrentPlayer) < 27 Then
    tmp = INT(RndNum(0,26))
    Do Until Cities(CurrentPlayer, tmp) = 0
        tmp = INT(RndNum(0,26))
    Loop
    Cities(CurrentPlayer, tmp) = 1
    tmp = tmp +1 'due to the images are named from 1 to 27
    DMD "", "", "monster_" &tmp, eNone, eNone, eBlink, 1500, True, ""
    UpdateCityLights
End If
End Sub

Sub UpdateCityLights
Dim i
For i = 0 to 26
    aCityLights(i).State = Cities(CurrentPlayer, i)
Next
End Sub

'******************************************************
'	ZPHY:  GENREAL ADVICE ON PHYSICS
'******************************************************
'
' It's advised that flipper corrections, dampeners, and general physics settings should all be updated per these
' examples as all of these improvements work together to provide a realistic physics simulation.
'
' Tutorial videos provided by Bord
' Adding nFozzy roth physics : pt1 rubber dampeners 				https://youtu.be/AXX3aen06FM
' Adding nFozzy roth physics : pt2 flipper physics 					https://youtu.be/VSBFuK2RCPE
' Adding nFozzy roth physics : pt3 other elements 					https://youtu.be/JN8HEJapCvs
'
' Note: BallMass must be set to 1. BallSize should be set to 50 (in other words the ball radius is 25)
'
' Recommended Table Physics Settings
' | Gravity Constant             | 0.97      |
' | Playfield Friction           | 0.15-0.25 |
' | Playfield Elasticity         | 0.25      |
' | Playfield Elasticity Falloff | 0         |
' | Playfield Scatter            | 0         |
' | Default Element Scatter      | 2         |
'
' Bumpers
' | Force         | 9.5-10.5 |
' | Hit Threshold | 1.6-2    |
' | Scatter Angle | 2        |
'
' Slingshots
' | Hit Threshold      | 2    |
' | Slingshot Force    | 4-5  |
' | Slingshot Theshold | 2-3  |
' | Elasticity         | 0.85 |
' | Friction           | 0.8  |
' | Scatter Angle      | 1    |



'******************************************************
'	ZNFF:  FLIPPER CORRECTIONS by nFozzy
'******************************************************

'******************************************************
' Flippers Polarity (Select appropriate sub based on era)
'******************************************************

Dim LF
Set LF = New FlipperPolarity
Dim RF
Set RF = New FlipperPolarity

InitPolarity

'*******************************************
' Early 90's and after

Sub InitPolarity()
	Dim x, a
	a = Array(LF, RF)
	For Each x In a
		x.AddPt "Ycoef", 0, RightFlipper.Y-65, 1 'disabled
		x.AddPt "Ycoef", 1, RightFlipper.Y-11, 1
		x.enabled = True
		x.TimeDelay = 60
		x.DebugOn=False ' prints some info in debugger
		
		x.AddPt "Polarity", 0, 0, 0
		x.AddPt "Polarity", 1, 0.05, -5.5
		x.AddPt "Polarity", 2, 0.4, -5.5
		x.AddPt "Polarity", 3, 0.6, -5.0
		x.AddPt "Polarity", 4, 0.65, -4.5
		x.AddPt "Polarity", 5, 0.7, -4.0
		x.AddPt "Polarity", 6, 0.75, -3.5
		x.AddPt "Polarity", 7, 0.8, -3.0
		x.AddPt "Polarity", 8, 0.85, -2.5
		x.AddPt "Polarity", 9, 0.9,-2.0
		x.AddPt "Polarity", 10, 0.95, -1.5
		x.AddPt "Polarity", 11, 1, -1.0
		x.AddPt "Polarity", 12, 1.05, -0.5
		x.AddPt "Polarity", 13, 1.1, 0
		x.AddPt "Polarity", 14, 1.3, 0
		
		x.AddPt "Velocity", 0, 0,	   1
		x.AddPt "Velocity", 1, 0.160, 1.06
		x.AddPt "Velocity", 2, 0.410, 1.05
		x.AddPt "Velocity", 3, 0.530, 1'0.982
		x.AddPt "Velocity", 4, 0.702, 0.968
		x.AddPt "Velocity", 5, 0.95,  0.968
		x.AddPt "Velocity", 6, 1.03,  0.945
	Next
	
	' SetObjects arguments: 1: name of object 2: flipper object: 3: Trigger object around flipper
	LF.SetObjects "LF", LeftFlipper, TriggerLF
	RF.SetObjects "RF", RightFlipper, TriggerRF
End Sub

'******************************************************
'  FLIPPER CORRECTION FUNCTIONS
'******************************************************

' modified 2023 by nFozzy
' Removed need for 'endpoint' objects
' Added 'createvents' type thing for TriggerLF / TriggerRF triggers.
' Removed AddPt function which complicated setup imo
' made DebugOn do something (prints some stuff in debugger)
'   Otherwise it should function exactly the same as before

Class FlipperPolarity
	Public DebugOn, Enabled
	Private FlipAt		'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay		'delay before trigger turns off and polarity is disabled
	Private Flipper, FlipperStart, FlipperEnd, FlipperEndY, LR, PartialFlipCoef
	Private Balls(20), balldata(20)
	Private Name
	
	Dim PolarityIn, PolarityOut
	Dim VelocityIn, VelocityOut
	Dim YcoefIn, YcoefOut
	Public Sub Class_Initialize
		ReDim PolarityIn(0)
		ReDim PolarityOut(0)
		ReDim VelocityIn(0)
		ReDim VelocityOut(0)
		ReDim YcoefIn(0)
		ReDim YcoefOut(0)
		Enabled = True
		TimeDelay = 50
		LR = 1
		Dim x
		For x = 0 To UBound(balls)
			balls(x) = Empty
			Set Balldata(x) = new SpoofBall
		Next
	End Sub
	
	Public Sub SetObjects(aName, aFlipper, aTrigger)
		
		If TypeName(aName) <> "String" Then MsgBox "FlipperPolarity: .SetObjects error: first argument must be a String (And name of Object). Found:" & TypeName(aName) End If
		If TypeName(aFlipper) <> "Flipper" Then MsgBox "FlipperPolarity: .SetObjects error: Second argument must be a flipper. Found:" & TypeName(aFlipper) End If
		If TypeName(aTrigger) <> "Trigger" Then MsgBox "FlipperPolarity: .SetObjects error: third argument must be a trigger. Found:" & TypeName(aTrigger) End If
		If aFlipper.EndAngle > aFlipper.StartAngle Then LR = -1 Else LR = 1 End If
		Name = aName
		Set Flipper = aFlipper
		FlipperStart = aFlipper.x
		FlipperEnd = Flipper.Length * Sin((Flipper.StartAngle / 57.295779513082320876798154814105)) + Flipper.X ' big floats for degree to rad conversion
		FlipperEndY = Flipper.Length * Cos(Flipper.StartAngle / 57.295779513082320876798154814105)*-1 + Flipper.Y
		
		Dim str
		str = "Sub " & aTrigger.name & "_Hit() : " & aName & ".AddBall ActiveBall : End Sub'"
		ExecuteGlobal(str)
		str = "Sub " & aTrigger.name & "_UnHit() : " & aName & ".PolarityCorrect ActiveBall : End Sub'"
		ExecuteGlobal(str)
		
	End Sub
	
	' Legacy: just no op
	Public Property Let EndPoint(aInput)
		
	End Property
	
	Public Sub AddPt(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out)
		Select Case aChooseArray
			Case "Polarity"
				ShuffleArrays PolarityIn, PolarityOut, 1
				PolarityIn(aIDX) = aX
				PolarityOut(aIDX) = aY
				ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity"
				ShuffleArrays VelocityIn, VelocityOut, 1
				VelocityIn(aIDX) = aX
				VelocityOut(aIDX) = aY
				ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef"
				ShuffleArrays YcoefIn, YcoefOut, 1
				YcoefIn(aIDX) = aX
				YcoefOut(aIDX) = aY
				ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
	End Sub
	
	Public Sub AddBall(aBall)
		Dim x
		For x = 0 To UBound(balls)
			If IsEmpty(balls(x)) Then
				Set balls(x) = aBall
				Exit Sub
			End If
		Next
	End Sub
	
	Private Sub RemoveBall(aBall)
		Dim x
		For x = 0 To UBound(balls)
			If TypeName(balls(x) ) = "IBall" Then
				If aBall.ID = Balls(x).ID Then
					balls(x) = Empty
					Balldata(x).Reset
				End If
			End If
		Next
	End Sub
	
	Public Sub Fire()
		Flipper.RotateToEnd
		processballs
	End Sub
	
	Public Property Get Pos 'returns % position a ball. For debug stuff.
		Dim x
		For x = 0 To UBound(balls)
			If Not IsEmpty(balls(x) ) Then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next
	End Property
	
	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		Dim x
		For x = 0 To UBound(balls)
			If Not IsEmpty(balls(x) ) Then
				balldata(x).Data = balls(x)
			End If
		Next
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
	End Sub
	'Timer shutoff for polaritycorrect
	Private Function FlipperOn()
		If GameTime < FlipAt+TimeDelay Then
			FlipperOn = True
		End If
	End Function
	
	Public Sub PolarityCorrect(aBall)
		If FlipperOn() Then
			Dim tmp, BallPos, x, IDX, Ycoef
			Ycoef = 1
			
			'y safety Exit
			If aBall.VelY > -8 Then 'ball going down
				RemoveBall aBall
				Exit Sub
			End If
			
			'Find balldata. BallPos = % on Flipper
			For x = 0 To UBound(Balls)
				If aBall.id = BallData(x).id And Not IsEmpty(BallData(x).id) Then
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					If ballpos > 0.65 Then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)								'find safety coefficient 'ycoef' data
				End If
			Next
			
			If BallPos = 0 Then 'no ball data meaning the ball is entering and exiting pretty close to the same position, use current values.
				BallPos = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
				If ballpos > 0.65 Then  Ycoef = LinearEnvelope(aBall.Y, YcoefIn, YcoefOut)												'find safety coefficient 'ycoef' data
			End If
			
			'Velocity correction
			If Not IsEmpty(VelocityIn(0) ) Then
				Dim VelCoef
				VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)
				
				If partialflipcoef < 1 Then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)
				
				If Enabled Then aBall.Velx = aBall.Velx*VelCoef
				If Enabled Then aBall.Vely = aBall.Vely*VelCoef
			End If
			
			'Polarity Correction (optional now)
			If Not IsEmpty(PolarityIn(0) ) Then
				Dim AddX
				AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
				
				If Enabled Then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef)
			End If
			If DebugOn Then debug.print "PolarityCorrect" & " " & Name & " @ " & GameTime & " " & Round(BallPos*100) & "%" & " AddX:" & Round(AddX,2) & " Vel%:" & Round(VelCoef*100)
		End If
		RemoveBall aBall
	End Sub
End Class

'******************************************************
'  FLIPPER POLARITY AND RUBBER DAMPENER SUPPORTING FUNCTIONS
'******************************************************

' Used for flipper correction and rubber dampeners
Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	Dim x, aCount
	aCount = 0
	ReDim a(UBound(aArray) )
	For x = 0 To UBound(aArray)		'Shuffle objects in a temp array
		If Not IsEmpty(aArray(x) ) Then
			If IsObject(aArray(x)) Then
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	If offset < 0 Then offset = 0
	ReDim aArray(aCount-1+offset)		'Resize original array
	For x = 0 To aCount-1				'set objects back into original array
		If IsObject(a(x)) Then
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

' Used for flipper correction and rubber dampeners
Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub

' Used for flipper correction, rubber dampeners, and drop targets
Function BallSpeed(ball) 'Calculates the ball speed
	BallSpeed = Sqr(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
End Function

' Used for flipper correction and rubber dampeners
Function PSlope(Input, X1, Y1, X2, Y2)		'Set up line via two points, no clamping. Input X, output Y
	Dim x, y, b, m
	x = input
	m = (Y2 - Y1) / (X2 - X1)
	b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

' Used for flipper correction
Class spoofball
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius
	Public Property Let Data(aBall)
		With aBall
			x = .x
			y = .y
			z = .z
			velx = .velx
			vely = .vely
			velz = .velz
			id = .ID
			mass = .mass
			radius = .radius
		End With
	End Property
	Public Sub Reset()
		x = Empty
		y = Empty
		z = Empty
		velx = Empty
		vely = Empty
		velz = Empty
		id = Empty
		mass = Empty
		radius = Empty
	End Sub
End Class

' Used for flipper correction and rubber dampeners
Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	Dim y 'Y output
	Dim L 'Line
	'find active line
	Dim ii
	For ii = 1 To UBound(xKeyFrame)
		If xInput <= xKeyFrame(ii) Then
			L = ii
			Exit For
		End If
	Next
	If xInput > xKeyFrame(UBound(xKeyFrame) ) Then L = UBound(xKeyFrame)		'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )
	
	If xInput <= xKeyFrame(LBound(xKeyFrame) ) Then Y = yLvl(LBound(xKeyFrame) )		 'Clamp lower
	If xInput >= xKeyFrame(UBound(xKeyFrame) ) Then Y = yLvl(UBound(xKeyFrame) )		'Clamp upper
	
	LinearEnvelope = Y
End Function

'******************************************************
'  FLIPPER TRICKS
'******************************************************

RightFlipper.timerinterval = 1
Rightflipper.timerenabled = True

Sub RightFlipper_timer()
	FlipperTricks LeftFlipper, LFPress, LFCount, LFEndAngle, LFState
	FlipperTricks RightFlipper, RFPress, RFCount, RFEndAngle, RFState
	FlipperNudge RightFlipper, RFEndAngle, RFEOSNudge, LeftFlipper, LFEndAngle
	FlipperNudge LeftFlipper, LFEndAngle, LFEOSNudge,  RightFlipper, RFEndAngle
End Sub

Dim LFEOSNudge, RFEOSNudge

Sub FlipperNudge(Flipper1, Endangle1, EOSNudge1, Flipper2, EndAngle2)
	Dim b
	Dim gBOT
	gBOT = GetBalls
	
	If Flipper1.currentangle = Endangle1 And EOSNudge1 <> 1 Then
		EOSNudge1 = 1
		'   debug.print Flipper1.currentangle &" = "& Endangle1 &"--"& Flipper2.currentangle &" = "& EndAngle2
		If Flipper2.currentangle = EndAngle2 Then
			For b = 0 To UBound(gBOT)
				If FlipperTrigger(gBOT(b).x, gBOT(b).y, Flipper1) Then
					'Debug.Print "ball in flip1. exit"
					Exit Sub
				End If
			Next
			For b = 0 To UBound(gBOT)
				If FlipperTrigger(gBOT(b).x, gBOT(b).y, Flipper2) Then
					gBOT(b).velx = gBOT(b).velx / 1.3
					gBOT(b).vely = gBOT(b).vely - 0.5
				End If
			Next
		End If
	Else
		If Abs(Flipper1.currentangle) > Abs(EndAngle1) + 30 Then EOSNudge1 = 0
	End If
End Sub

'*****************
' Maths
'*****************

Dim PI
PI = 4 * Atn(1)

Function dSin(degrees)
	dsin = Sin(degrees * Pi / 180)
End Function

Function dCos(degrees)
	dcos = Cos(degrees * Pi / 180)
End Function

Function Atn2(dy, dx)
	If dx > 0 Then
		Atn2 = Atn(dy / dx)
	ElseIf dx < 0 Then
		If dy = 0 Then
			Atn2 = pi
		Else
			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
		End If
	ElseIf dx = 0 Then
		If dy = 0 Then
			Atn2 = 0
		Else
			Atn2 = Sgn(dy) * pi / 2
		End If
	End If
End Function

'*************************************************
'  Check ball distance from Flipper for Rem
'*************************************************

Function Distance(ax,ay,bx,by)
	Distance = Sqr((ax - bx) ^ 2 + (ay - by) ^ 2)
End Function

Function DistancePL(px,py,ax,ay,bx,by) 'Distance between a point and a line where point Is px,py
	DistancePL = Abs((by - ay) * px - (bx - ax) * py + bx * ay - by * ax) / Distance(ax,ay,bx,by)
End Function

Function Radians(Degrees)
	Radians = Degrees * PI / 180
End Function

Function AnglePP(ax,ay,bx,by)
	AnglePP = Atn2((by - ay),(bx - ax)) * 180 / PI
End Function

Function DistanceFromFlipper(ballx, bally, Flipper)
	DistanceFromFlipper = DistancePL(ballx, bally, Flipper.x, Flipper.y, Cos(Radians(Flipper.currentangle + 90)) + Flipper.x, Sin(Radians(Flipper.currentangle + 90)) + Flipper.y)
End Function

Function FlipperTrigger(ballx, bally, Flipper)
	Dim DiffAngle
	DiffAngle = Abs(Flipper.currentangle - AnglePP(Flipper.x, Flipper.y, ballx, bally) - 90)
	If DiffAngle > 180 Then DiffAngle = DiffAngle - 360
	
	If DistanceFromFlipper(ballx,bally,Flipper) < 48 And DiffAngle <= 90 And Distance(ballx,bally,Flipper.x,Flipper.y) < Flipper.Length Then
		FlipperTrigger = True
	Else
		FlipperTrigger = False
	End If
End Function

'*************************************************
'  End - Check ball distance from Flipper for Rem
'*************************************************

Dim LFPress, RFPress, LFCount, RFCount
Dim LFState, RFState
Dim EOST, EOSA,Frampup, FElasticity,FReturn
Dim RFEndAngle, LFEndAngle

Const FlipperCoilRampupMode = 0 '0 = fast, 1 = medium, 2 = slow (tap passes should work)

LFState = 1
RFState = 1
EOST = leftflipper.eostorque
EOSA = leftflipper.eostorqueangle
Frampup = LeftFlipper.rampup
FElasticity = LeftFlipper.elasticity
FReturn = LeftFlipper.return
'Const EOSTnew = 1 'EM's to late 80's
Const EOSTnew = 0.8 '90's and later
Const EOSAnew = 1
Const EOSRampup = 0
Dim SOSRampup
Select Case FlipperCoilRampupMode
	Case 0
		SOSRampup = 2.5
	Case 1
		SOSRampup = 6
	Case 2
		SOSRampup = 8.5
End Select

Const LiveCatch = 16
Const LiveElasticity = 0.45
Const SOSEM = 0.815
'   Const EOSReturn = 0.055  'EM's
'   Const EOSReturn = 0.045  'late 70's to mid 80's
Const EOSReturn = 0.035  'mid 80's to early 90's
'   Const EOSReturn = 0.025  'mid 90's and later

LFEndAngle = Leftflipper.endangle
RFEndAngle = RightFlipper.endangle

Sub FlipperActivate(Flipper, FlipperPress)
	FlipperPress = 1
	Flipper.Elasticity = FElasticity
	
	Flipper.eostorque = EOST
	Flipper.eostorqueangle = EOSA
End Sub

Sub FlipperDeactivate(Flipper, FlipperPress)
	FlipperPress = 0
	Flipper.eostorqueangle = EOSA
	Flipper.eostorque = EOST * EOSReturn / FReturn
	
	If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 0.1 Then
		Dim b, gBOT
		gBOT = GetBalls
		
		For b = 0 To UBound(gBOT)
			If Distance(gBOT(b).x, gBOT(b).y, Flipper.x, Flipper.y) < 55 Then 'check for cradle
				If gBOT(b).vely >= - 0.4 Then gBOT(b).vely =  - 0.4
			End If
		Next
	End If
End Sub

Sub FlipperTricks (Flipper, FlipperPress, FCount, FEndAngle, FState)
	Dim Dir
	Dir = Flipper.startangle / Abs(Flipper.startangle) '-1 for Right Flipper
	
	If Abs(Flipper.currentangle) > Abs(Flipper.startangle) - 0.05 Then
		If FState <> 1 Then
			Flipper.rampup = SOSRampup
			Flipper.endangle = FEndAngle - 3 * Dir
			Flipper.Elasticity = FElasticity * SOSEM
			FCount = 0
			FState = 1
		End If
	ElseIf Abs(Flipper.currentangle) <= Abs(Flipper.endangle) And FlipperPress = 1 Then
		If FCount = 0 Then FCount = GameTime
		
		If FState <> 2 Then
			Flipper.eostorqueangle = EOSAnew
			Flipper.eostorque = EOSTnew
			Flipper.rampup = EOSRampup
			Flipper.endangle = FEndAngle
			FState = 2
		End If
	ElseIf Abs(Flipper.currentangle) > Abs(Flipper.endangle) + 0.01 And FlipperPress = 1 Then
		If FState <> 3 Then
			Flipper.eostorque = EOST
			Flipper.eostorqueangle = EOSA
			Flipper.rampup = Frampup
			Flipper.Elasticity = FElasticity
			FState = 3
		End If
	End If
End Sub

Const LiveDistanceMin = 30  'minimum distance In vp units from flipper base live catch dampening will occur
Const LiveDistanceMax = 114 'maximum distance in vp units from flipper base live catch dampening will occur (tip protection)

Sub CheckLiveCatch(ball, Flipper, FCount, parm) 'Experimental new live catch
	Dim Dir
	Dir = Flipper.startangle / Abs(Flipper.startangle)	'-1 for Right Flipper
	Dim LiveCatchBounce																														'If live catch is not perfect, it won't freeze ball totally
	Dim CatchTime
	CatchTime = GameTime - FCount
	
	If CatchTime <= LiveCatch And parm > 6 And Abs(Flipper.x - ball.x) > LiveDistanceMin And Abs(Flipper.x - ball.x) < LiveDistanceMax Then
		If CatchTime <= LiveCatch * 0.5 Then												'Perfect catch only when catch time happens in the beginning of the window
			LiveCatchBounce = 0
		Else
			LiveCatchBounce = Abs((LiveCatch / 2) - CatchTime)		'Partial catch when catch happens a bit late
		End If
		
		If LiveCatchBounce = 0 And ball.velx * Dir > 0 Then ball.velx = 0
		ball.vely = LiveCatchBounce * (32 / LiveCatch) ' Multiplier for inaccuracy bounce
		ball.angmomx = 0
		ball.angmomy = 0
		ball.angmomz = 0
	Else
		If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 1 Then FlippersD.Dampenf ActiveBall, parm
	End If
End Sub

'******************************************************
'****  END FLIPPER CORRECTIONS
'******************************************************





'******************************************************
' 	ZDMP:  RUBBER  DAMPENERS
'******************************************************
' These are data mined bounce curves,
' dialed in with the in-game elasticity as much as possible to prevent angle / spin issues.
' Requires tracking ballspeed to calculate COR

Sub dPosts_Hit(idx)
	RubbersD.dampen ActiveBall
	TargetBouncer ActiveBall, 1
End Sub

Sub dSleeves_Hit(idx)
	SleevesD.Dampen ActiveBall
	TargetBouncer ActiveBall, 0.7
End Sub

Dim RubbersD				'frubber
Set RubbersD = New Dampener
RubbersD.name = "Rubbers"
RubbersD.debugOn = False	'shows info in textbox "TBPout"
RubbersD.Print = False	  'debug, reports In debugger (In vel, out cor); cor bounce curve (linear)

'for best results, try to match in-game velocity as closely as possible to the desired curve
'   RubbersD.addpoint 0, 0, 0.935   'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 0, 0, 1.1		 'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 1, 3.77, 0.97
RubbersD.addpoint 2, 5.76, 0.967	'dont take this as gospel. if you can data mine rubber elasticitiy, please help!
RubbersD.addpoint 3, 15.84, 0.874
RubbersD.addpoint 4, 56, 0.64	   'there's clamping so interpolate up to 56 at least

Dim SleevesD	'this is just rubber but cut down to 85%...
Set SleevesD = New Dampener
SleevesD.name = "Sleeves"
SleevesD.debugOn = False	'shows info in textbox "TBPout"
SleevesD.Print = False	  'debug, reports In debugger (In vel, out cor)
SleevesD.CopyCoef RubbersD, 0.85

'######################### Add new FlippersD Profile
'######################### Adjust these values to increase or lessen the elasticity

Dim FlippersD
Set FlippersD = New Dampener
FlippersD.name = "Flippers"
FlippersD.debugOn = False
FlippersD.Print = False
FlippersD.addpoint 0, 0, 1.1
FlippersD.addpoint 1, 3.77, 0.99
FlippersD.addpoint 2, 6, 0.99

Class Dampener
	Public Print, debugOn   'tbpOut.text
	Public name, Threshold  'Minimum threshold. Useful for Flippers, which don't have a hit threshold.
	Public ModIn, ModOut
	Private Sub Class_Initialize
		ReDim ModIn(0)
		ReDim Modout(0)
	End Sub
	
	Public Sub AddPoint(aIdx, aX, aY)
		ShuffleArrays ModIn, ModOut, 1
		ModIn(aIDX) = aX
		ModOut(aIDX) = aY
		ShuffleArrays ModIn, ModOut, 0
		If GameTime > 100 Then Report
	End Sub
	
	Public Sub Dampen(aBall)
		If threshold Then
			If BallSpeed(aBall) < threshold Then Exit Sub
		End If
		Dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id) + 0.0001)
		coef = desiredcor / realcor
		If debugOn Then str = name & " In vel:" & Round(cor.ballvel(aBall.id),2 ) & vbNewLine & "desired cor: " & Round(desiredcor,4) & vbNewLine & _
		"actual cor: " & Round(realCOR,4) & vbNewLine & "ballspeed coef: " & Round(coef, 3) & vbNewLine
		If Print Then Debug.print Round(cor.ballvel(aBall.id),2) & ", " & Round(desiredcor,3)
		
		aBall.velx = aBall.velx * coef
		aBall.vely = aBall.vely * coef
		If debugOn Then TBPout.text = str
	End Sub
	
	Public Sub Dampenf(aBall, parm) 'Rubberizer is handle here
		Dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id) + 0.0001)
		coef = desiredcor / realcor
		If Abs(aball.velx) < 2 And aball.vely < 0 And aball.vely >  - 3.75 Then
			aBall.velx = aBall.velx * coef
			aBall.vely = aBall.vely * coef
		End If
	End Sub
	
	Public Sub CopyCoef(aObj, aCoef) 'alternative addpoints, copy with coef
		Dim x
		For x = 0 To UBound(aObj.ModIn)
			addpoint x, aObj.ModIn(x), aObj.ModOut(x) * aCoef
		Next
	End Sub
	
	Public Sub Report() 'debug, reports all coords in tbPL.text
		If Not debugOn Then Exit Sub
		Dim a1, a2
		a1 = ModIn
		a2 = ModOut
		Dim str, x
		For x = 0 To UBound(a1)
			str = str & x & ": " & Round(a1(x),4) & ", " & Round(a2(x),4) & vbNewLine
		Next
		TBPout.text = str
	End Sub
End Class

'******************************************************
'  TRACK ALL BALL VELOCITIES
'  FOR RUBBER DAMPENER AND DROP TARGETS
'******************************************************

Dim cor
Set cor = New CoRTracker

Class CoRTracker
	Public ballvel, ballvelx, ballvely
	
	Private Sub Class_Initialize
		ReDim ballvel(0)
		ReDim ballvelx(0)
		ReDim ballvely(0)
	End Sub
	
	Public Sub Update()	'tracks in-ball-velocity
		Dim str, b, AllBalls, highestID
		allBalls = GetBalls
		
		For Each b In allballs
			If b.id >= HighestID Then highestID = b.id
		Next
		
		If UBound(ballvel) < highestID Then ReDim ballvel(highestID)	'set bounds
		If UBound(ballvelx) < highestID Then ReDim ballvelx(highestID)	'set bounds
		If UBound(ballvely) < highestID Then ReDim ballvely(highestID)	'set bounds
		
		For Each b In allballs
			ballvel(b.id) = BallSpeed(b)
			ballvelx(b.id) = b.velx
			ballvely(b.id) = b.vely
		Next
	End Sub
End Class

' Note, cor.update must be called in a 10 ms timer. The example table uses the GameTimer for this purpose, but sometimes a dedicated timer call RDampen is used.
'
Sub RDampen_Timer
	Cor.Update
End Sub

'******************************************************
'****  END PHYSICS DAMPENERS
'******************************************************



'******************************************************
' 	ZBOU: VPW TargetBouncer for targets and posts by Iaakki, Wrd1972, Apophis
'******************************************************

Const TargetBouncerEnabled = 1	  '0 = normal standup targets, 1 = bouncy targets
Const TargetBouncerFactor = 0.7	 'Level of bounces. Recommmended value of 0.7

Sub TargetBouncer(aBall,defvalue)
	Dim zMultiplier, vel, vratio
	If TargetBouncerEnabled = 1 And aball.z < 30 Then
		'   debug.print "velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		vel = BallSpeed(aBall)
		If aBall.velx = 0 Then vratio = 1 Else vratio = aBall.vely / aBall.velx
		Select Case Int(Rnd * 6) + 1
			Case 1
				zMultiplier = 0.2 * defvalue
			Case 2
				zMultiplier = 0.25 * defvalue
			Case 3
				zMultiplier = 0.3 * defvalue
			Case 4
				zMultiplier = 0.4 * defvalue
			Case 5
				zMultiplier = 0.45 * defvalue
			Case 6
				zMultiplier = 0.5 * defvalue
		End Select
		aBall.velz = Abs(vel * zMultiplier * TargetBouncerFactor)
		aBall.velx = Sgn(aBall.velx) * Sqr(Abs((vel ^ 2 - aBall.velz ^ 2) / (1 + vratio ^ 2)))
		aBall.vely = aBall.velx * vratio
		'   debug.print "---> velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		'   debug.print "conservation check: " & BallSpeed(aBall)/vel
	End If
End Sub

'Add targets or posts to the TargetBounce collection if you want to activate the targetbouncer code from them
Sub TargetBounce_Hit(idx)
	TargetBouncer ActiveBall, 1
End Sub

'******************************************************
' 	ZFLE:  FLEEP MECHANICAL SOUNDS
'******************************************************


'///////////////////////////////  SOUNDS PARAMETERS  //////////////////////////////
Dim GlobalSoundLevel, CoinSoundLevel, PlungerReleaseSoundLevel, PlungerPullSoundLevel, NudgeLeftSoundLevel
Dim NudgeRightSoundLevel, NudgeCenterSoundLevel, StartButtonSoundLevel, RollingSoundFactor

CoinSoundLevel = 1					  'volume level; range [0, 1]
NudgeLeftSoundLevel = 1				 'volume level; range [0, 1]
NudgeRightSoundLevel = 1				'volume level; range [0, 1]
NudgeCenterSoundLevel = 1			   'volume level; range [0, 1]
StartButtonSoundLevel = 0.1			 'volume level; range [0, 1]
PlungerReleaseSoundLevel = 0.8 '1 wjr   'volume level; range [0, 1]
PlungerPullSoundLevel = 1			   'volume level; range [0, 1]
RollingSoundFactor = 1.1 / 5

'///////////////////////-----Solenoids, Kickers and Flash Relays-----///////////////////////
Dim FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel, FlipperUpAttackLeftSoundLevel, FlipperUpAttackRightSoundLevel
Dim FlipperUpSoundLevel, FlipperDownSoundLevel, FlipperLeftHitParm, FlipperRightHitParm
Dim SlingshotSoundLevel, BumperSoundFactor, KnockerSoundLevel

FlipperUpAttackMinimumSoundLevel = 0.010		'volume level; range [0, 1]
FlipperUpAttackMaximumSoundLevel = 0.635		'volume level; range [0, 1]
FlipperUpSoundLevel = 1.0					   'volume level; range [0, 1]
FlipperDownSoundLevel = 0.45					'volume level; range [0, 1]
FlipperLeftHitParm = FlipperUpSoundLevel		'sound helper; not configurable
FlipperRightHitParm = FlipperUpSoundLevel	   'sound helper; not configurable
SlingshotSoundLevel = 0.95					  'volume level; range [0, 1]
BumperSoundFactor = 4.25						'volume multiplier; must not be zero
KnockerSoundLevel = 1						   'volume level; range [0, 1]

'///////////////////////-----Ball Drops, Bumps and Collisions-----///////////////////////
Dim RubberStrongSoundFactor, RubberWeakSoundFactor, RubberFlipperSoundFactor,BallWithBallCollisionSoundFactor
Dim BallBouncePlayfieldSoftFactor, BallBouncePlayfieldHardFactor, PlasticRampDropToPlayfieldSoundLevel, WireRampDropToPlayfieldSoundLevel, DelayedBallDropOnPlayfieldSoundLevel
Dim WallImpactSoundFactor, MetalImpactSoundFactor, SubwaySoundLevel, SubwayEntrySoundLevel, ScoopEntrySoundLevel
Dim SaucerLockSoundLevel, SaucerKickSoundLevel

BallWithBallCollisionSoundFactor = 3.2		  'volume multiplier; must not be zero
RubberStrongSoundFactor = 0.055 / 5			 'volume multiplier; must not be zero
RubberWeakSoundFactor = 0.075 / 5			   'volume multiplier; must not be zero
RubberFlipperSoundFactor = 0.375 / 5			'volume multiplier; must not be zero
BallBouncePlayfieldSoftFactor = 0.025		   'volume multiplier; must not be zero
BallBouncePlayfieldHardFactor = 0.025		   'volume multiplier; must not be zero
DelayedBallDropOnPlayfieldSoundLevel = 0.8	  'volume level; range [0, 1]
WallImpactSoundFactor = 0.075				   'volume multiplier; must not be zero
MetalImpactSoundFactor = 0.075 / 3
SaucerLockSoundLevel = 0.8
SaucerKickSoundLevel = 0.8

'///////////////////////-----Gates, Spinners, Rollovers and Targets-----///////////////////////

Dim GateSoundLevel, TargetSoundFactor, SpinnerSoundLevel, RolloverSoundLevel, DTSoundLevel

GateSoundLevel = 0.5 / 5			'volume level; range [0, 1]
TargetSoundFactor = 0.0025 * 10	 'volume multiplier; must not be zero
DTSoundLevel = 0.25				 'volume multiplier; must not be zero
RolloverSoundLevel = 0.25		   'volume level; range [0, 1]
SpinnerSoundLevel = 0.5			 'volume level; range [0, 1]

'///////////////////////-----Ball Release, Guides and Drain-----///////////////////////
Dim DrainSoundLevel, BallReleaseSoundLevel, BottomArchBallGuideSoundFactor, FlipperBallGuideSoundFactor

DrainSoundLevel = 0.8				   'volume level; range [0, 1]
BallReleaseSoundLevel = 1			   'volume level; range [0, 1]
BottomArchBallGuideSoundFactor = 0.2	'volume multiplier; must not be zero
FlipperBallGuideSoundFactor = 0.015	 'volume multiplier; must not be zero

'///////////////////////-----Loops and Lanes-----///////////////////////
Dim ArchSoundFactor
ArchSoundFactor = 0.025 / 5			 'volume multiplier; must not be zero

'/////////////////////////////  SOUND PLAYBACK FUNCTIONS  ////////////////////////////
'/////////////////////////////  POSITIONAL SOUND PLAYBACK METHODS  ////////////////////////////
' Positional sound playback methods will play a sound, depending on the X,Y position of the table element or depending on ActiveBall object position
' These are similar subroutines that are less complicated to use (e.g. simply use standard parameters for the PlaySound call)
' For surround setup - positional sound playback functions will fade between front and rear surround channels and pan between left and right channels
' For stereo setup - positional sound playback functions will only pan between left and right channels
' For mono setup - positional sound playback functions will not pan between left and right channels and will not fade between front and rear channels

' PlaySound full syntax - PlaySound(string, int loopcount, float volume, float pan, float randompitch, int pitch, bool useexisting, bool restart, float front_rear_fade)
' Note - These functions will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position
Sub PlaySoundAtLevelStatic(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelExistingStatic(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 1, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelStaticLoop(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, - 1, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelStaticRandomPitch(playsoundparams, aVol, randomPitch, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelActiveBall(playsoundparams, aVol)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtLevelExistingActiveBall(playsoundparams, aVol)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 1, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtLeveTimerActiveBall(playsoundparams, aVol, ballvariable)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 0, 0, AudioFade(ballvariable)
End Sub

Sub PlaySoundAtLevelTimerExistingActiveBall(playsoundparams, aVol, ballvariable)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 1, 0, AudioFade(ballvariable)
End Sub

Sub PlaySoundAtLevelRoll(playsoundparams, aVol, pitch)
	PlaySound playsoundparams, - 1, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub

' Previous Positional Sound Subs

Sub PlaySoundAt(soundname, tableobj)
	PlaySound soundname, 1, 1 * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtVol(soundname, tableobj, aVol)
	PlaySound soundname, 1, aVol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBall(soundname)
	PlaySoundAt soundname, ActiveBall
End Sub

Sub PlaySoundAtBallVol (Soundname, aVol)
	PlaySound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 1, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBallVolM (Soundname, aVol)
	PlaySound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtVolLoops(sound, tableobj, Vol, Loops)
	PlaySound sound, Loops, Vol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'******************************************************
'  Fleep  Supporting Ball & Sound Functions
'******************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
	Dim tmp
	tmp = tableobj.y * 2 / tableheight - 1
	
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp <  - 7000 Then
		tmp =  - 7000
	End If
	
	If tmp > 0 Then
		AudioFade = CSng(tmp ^ 10)
	Else
		AudioFade = CSng( - (( - tmp) ^ 10) )
	End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
	Dim tmp
	tmp = tableobj.x * 2 / tablewidth - 1
	
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp <  - 7000 Then
		tmp =  - 7000
	End If
	
	If tmp > 0 Then
		AudioPan = CSng(tmp ^ 10)
	Else
		AudioPan = CSng( - (( - tmp) ^ 10) )
	End If
End Function

Function Vol(ball) ' Calculates the volume of the sound based on the ball speed
	Vol = CSng(BallVel(ball) ^ 2)
End Function

Function Volz(ball) ' Calculates the volume of the sound based on the ball speed
	Volz = CSng((ball.velz) ^ 2)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
	Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
	BallVel = Int(Sqr((ball.VelX ^ 2) + (ball.VelY ^ 2) ) )
End Function

Function VolPlayfieldRoll(ball) ' Calculates the roll volume of the sound based on the ball speed
	VolPlayfieldRoll = RollingSoundFactor * 0.0005 * CSng(BallVel(ball) ^ 3)
End Function

Function PitchPlayfieldRoll(ball) ' Calculates the roll pitch of the sound based on the ball speed
	PitchPlayfieldRoll = BallVel(ball) ^ 2 * 15
End Function

Function RndInt(min, max) ' Sets a random number integer between min and max
	RndInt = Int(Rnd() * (max - min + 1) + min)
End Function

Function RndNum(min, max) ' Sets a random number between min and max
	RndNum = Rnd() * (max - min) + min
End Function

'/////////////////////////////  GENERAL SOUND SUBROUTINES  ////////////////////////////

Sub SoundStartButton()
	PlaySound ("Start_Button"), 0, StartButtonSoundLevel, 0, 0.25
End Sub

Sub SoundNudgeLeft()
	PlaySound ("Nudge_" & Int(Rnd * 2) + 1), 0, NudgeLeftSoundLevel * VolumeDial, - 0.1, 0.25
End Sub

Sub SoundNudgeRight()
	PlaySound ("Nudge_" & Int(Rnd * 2) + 1), 0, NudgeRightSoundLevel * VolumeDial, 0.1, 0.25
End Sub

Sub SoundNudgeCenter()
	PlaySound ("Nudge_" & Int(Rnd * 2) + 1), 0, NudgeCenterSoundLevel * VolumeDial, 0, 0.25
End Sub

Sub SoundPlungerPull()
	PlaySoundAtLevelStatic ("Plunger_Pull_1"), PlungerPullSoundLevel, Plunger
End Sub

Sub SoundPlungerReleaseBall()
	PlaySoundAtLevelStatic ("Plunger_Release_Ball"), PlungerReleaseSoundLevel, Plunger
End Sub

Sub SoundPlungerReleaseNoBall()
	PlaySoundAtLevelStatic ("Plunger_Release_No_Ball"), PlungerReleaseSoundLevel, Plunger
End Sub

'/////////////////////////////  KNOCKER SOLENOID  ////////////////////////////

Sub KnockerSolenoid()
	PlaySoundAtLevelStatic SoundFX("Knocker_1",DOFKnocker), KnockerSoundLevel, KnockerPosition
End Sub

'/////////////////////////////  DRAIN SOUNDS  ////////////////////////////

Sub RandomSoundDrain(drainswitch)
	PlaySoundAtLevelStatic ("Drain_" & Int(Rnd * 11) + 1), DrainSoundLevel, drainswitch
End Sub

'/////////////////////////////  TROUGH BALL RELEASE SOLENOID SOUNDS  ////////////////////////////

Sub RandomSoundBallRelease(drainswitch)
	PlaySoundAtLevelStatic SoundFX("BallRelease" & Int(Rnd * 7) + 1,DOFContactors), BallReleaseSoundLevel, drainswitch
End Sub

'/////////////////////////////  SLINGSHOT SOLENOID SOUNDS  ////////////////////////////

Sub RandomSoundSlingshotLeft(sling)
	PlaySoundAtLevelStatic SoundFX("Sling_L" & Int(Rnd * 10) + 1,DOFContactors), SlingshotSoundLevel, Sling
End Sub

Sub RandomSoundSlingshotRight(sling)
	PlaySoundAtLevelStatic SoundFX("Sling_R" & Int(Rnd * 8) + 1,DOFContactors), SlingshotSoundLevel, Sling
End Sub

'/////////////////////////////  BUMPER SOLENOID SOUNDS  ////////////////////////////

Sub RandomSoundBumperTop(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Top_" & Int(Rnd * 5) + 1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub

Sub RandomSoundBumperMiddle(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Middle_" & Int(Rnd * 5) + 1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub

Sub RandomSoundBumperBottom(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Bottom_" & Int(Rnd * 5) + 1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub

'/////////////////////////////  SPINNER SOUNDS  ////////////////////////////

Sub SoundSpinner(spinnerswitch)
	PlaySoundAtLevelStatic ("Spinner"), SpinnerSoundLevel, spinnerswitch
End Sub

'/////////////////////////////  FLIPPER BATS SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  FLIPPER BATS SOLENOID ATTACK SOUND  ////////////////////////////

Sub SoundFlipperUpAttackLeft(flipper)
	FlipperUpAttackLeftSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
	PlaySoundAtLevelStatic SoundFX("Flipper_Attack-L01",DOFFlippers), FlipperUpAttackLeftSoundLevel, flipper
End Sub

Sub SoundFlipperUpAttackRight(flipper)
	FlipperUpAttackRightSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
	PlaySoundAtLevelStatic SoundFX("Flipper_Attack-R01",DOFFlippers), FlipperUpAttackLeftSoundLevel, flipper
End Sub

'/////////////////////////////  FLIPPER BATS SOLENOID CORE SOUND  ////////////////////////////

Sub RandomSoundFlipperUpLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_L0" & Int(Rnd * 9) + 1,DOFFlippers), FlipperLeftHitParm, Flipper
End Sub

Sub RandomSoundFlipperUpRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_R0" & Int(Rnd * 9) + 1,DOFFlippers), FlipperRightHitParm, Flipper
End Sub

Sub RandomSoundReflipUpLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_L0" & Int(Rnd * 3) + 1,DOFFlippers), (RndNum(0.8, 1)) * FlipperUpSoundLevel, Flipper
End Sub

Sub RandomSoundReflipUpRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_R0" & Int(Rnd * 3) + 1,DOFFlippers), (RndNum(0.8, 1)) * FlipperUpSoundLevel, Flipper
End Sub

Sub RandomSoundFlipperDownLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_Left_Down_" & Int(Rnd * 7) + 1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub

Sub RandomSoundFlipperDownRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_Right_Down_" & Int(Rnd * 8) + 1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub

'/////////////////////////////  FLIPPER BATS BALL COLLIDE SOUND  ////////////////////////////

Sub LeftFlipperCollide(parm)
	FlipperLeftHitParm = parm / 10
	If FlipperLeftHitParm > 1 Then
		FlipperLeftHitParm = 1
	End If
	FlipperLeftHitParm = FlipperUpSoundLevel * FlipperLeftHitParm
	RandomSoundRubberFlipper(parm)
End Sub

Sub RightFlipperCollide(parm)
	FlipperRightHitParm = parm / 10
	If FlipperRightHitParm > 1 Then
		FlipperRightHitParm = 1
	End If
	FlipperRightHitParm = FlipperUpSoundLevel * FlipperRightHitParm
	RandomSoundRubberFlipper(parm)
End Sub

Sub RandomSoundRubberFlipper(parm)
	PlaySoundAtLevelActiveBall ("Flipper_Rubber_" & Int(Rnd * 7) + 1), parm * RubberFlipperSoundFactor
End Sub

'/////////////////////////////  ROLLOVER SOUNDS  ////////////////////////////

Sub RandomSoundRollover()
	PlaySoundAtLevelActiveBall ("Rollover_" & Int(Rnd * 4) + 1), RolloverSoundLevel
End Sub

Sub Rollovers_Hit(idx)
	RandomSoundRollover
End Sub

'/////////////////////////////  VARIOUS PLAYFIELD SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  RUBBERS AND POSTS  ////////////////////////////
'/////////////////////////////  RUBBERS - EVENTS  ////////////////////////////

Sub Rubbers_Hit(idx)
	Dim finalspeed
	finalspeed = Sqr(ActiveBall.velx * ActiveBall.velx + ActiveBall.vely * ActiveBall.vely)
	If finalspeed > 5 Then
		RandomSoundRubberStrong 1
	End If
	If finalspeed <= 5 Then
		RandomSoundRubberWeak()
	End If
End Sub

'/////////////////////////////  RUBBERS AND POSTS - STRONG IMPACTS  ////////////////////////////

Sub RandomSoundRubberStrong(voladj)
	Select Case Int(Rnd * 10) + 1
		Case 1
			PlaySoundAtLevelActiveBall ("Rubber_Strong_1"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 2
			PlaySoundAtLevelActiveBall ("Rubber_Strong_2"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 3
			PlaySoundAtLevelActiveBall ("Rubber_Strong_3"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 4
			PlaySoundAtLevelActiveBall ("Rubber_Strong_4"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 5
			PlaySoundAtLevelActiveBall ("Rubber_Strong_5"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 6
			PlaySoundAtLevelActiveBall ("Rubber_Strong_6"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 7
			PlaySoundAtLevelActiveBall ("Rubber_Strong_7"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 8
			PlaySoundAtLevelActiveBall ("Rubber_Strong_8"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 9
			PlaySoundAtLevelActiveBall ("Rubber_Strong_9"), Vol(ActiveBall) * RubberStrongSoundFactor * voladj
		Case 10
			PlaySoundAtLevelActiveBall ("Rubber_1_Hard"), Vol(ActiveBall) * RubberStrongSoundFactor * 0.6 * voladj
	End Select
End Sub

'/////////////////////////////  RUBBERS AND POSTS - WEAK IMPACTS  ////////////////////////////

Sub RandomSoundRubberWeak()
	PlaySoundAtLevelActiveBall ("Rubber_" & Int(Rnd * 9) + 1), Vol(ActiveBall) * RubberWeakSoundFactor
End Sub

'/////////////////////////////  WALL IMPACTS  ////////////////////////////

Sub Walls_Hit(idx)
	RandomSoundWall()
End Sub

Sub RandomSoundWall()
	Dim finalspeed
	finalspeed = Sqr(ActiveBall.velx * ActiveBall.velx + ActiveBall.vely * ActiveBall.vely)
	If finalspeed > 16 Then
		Select Case Int(Rnd * 5) + 1
			Case 1
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_1"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_2"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_5"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 4
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_7"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 5
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_9"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End If
	If finalspeed >= 6 And finalspeed <= 16 Then
		Select Case Int(Rnd * 4) + 1
			Case 1
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_3"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 4
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End If
	If finalspeed < 6 Then
		Select Case Int(Rnd * 3) + 1
			Case 1
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3
				PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End If
End Sub

'/////////////////////////////  METAL TOUCH SOUNDS  ////////////////////////////

Sub RandomSoundMetal()
	PlaySoundAtLevelActiveBall ("Metal_Touch_" & Int(Rnd * 13) + 1), Vol(ActiveBall) * MetalImpactSoundFactor
End Sub

'/////////////////////////////  METAL - EVENTS  ////////////////////////////

Sub Metals_Hit (idx)
	RandomSoundMetal
End Sub

Sub ShooterDiverter_collide(idx)
	RandomSoundMetal
End Sub

'/////////////////////////////  BOTTOM ARCH BALL GUIDE  ////////////////////////////
'/////////////////////////////  BOTTOM ARCH BALL GUIDE - SOFT BOUNCES  ////////////////////////////

Sub RandomSoundBottomArchBallGuide()
	Dim finalspeed
	finalspeed = Sqr(ActiveBall.velx * ActiveBall.velx + ActiveBall.vely * ActiveBall.vely)
	If finalspeed > 16 Then
		PlaySoundAtLevelActiveBall ("Apron_Bounce_" & Int(Rnd * 2) + 1), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
	End If
	If finalspeed >= 6 And finalspeed <= 16 Then
		Select Case Int(Rnd * 2) + 1
			Case 1
				PlaySoundAtLevelActiveBall ("Apron_Bounce_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
			Case 2
				PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
		End Select
	End If
	If finalspeed < 6 Then
		Select Case Int(Rnd * 2) + 1
			Case 1
				PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
			Case 2
				PlaySoundAtLevelActiveBall ("Apron_Medium_3"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
		End Select
	End If
End Sub

'/////////////////////////////  BOTTOM ARCH BALL GUIDE - HARD HITS  ////////////////////////////

Sub RandomSoundBottomArchBallGuideHardHit()
	PlaySoundAtLevelActiveBall ("Apron_Hard_Hit_" & Int(Rnd * 3) + 1), BottomArchBallGuideSoundFactor * 0.25
End Sub

Sub Apron_Hit (idx)
	If Abs(cor.ballvelx(ActiveBall.id) < 4) And cor.ballvely(ActiveBall.id) > 7 Then
		RandomSoundBottomArchBallGuideHardHit()
	Else
		RandomSoundBottomArchBallGuide
	End If
End Sub

'/////////////////////////////  FLIPPER BALL GUIDE  ////////////////////////////

Sub RandomSoundFlipperBallGuide()
	Dim finalspeed
	finalspeed = Sqr(ActiveBall.velx * ActiveBall.velx + ActiveBall.vely * ActiveBall.vely)
	If finalspeed > 16 Then
		Select Case Int(Rnd * 2) + 1
			Case 1
				PlaySoundAtLevelActiveBall ("Apron_Hard_1"),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
			Case 2
				PlaySoundAtLevelActiveBall ("Apron_Hard_2"),  Vol(ActiveBall) * 0.8 * FlipperBallGuideSoundFactor
		End Select
	End If
	If finalspeed >= 6 And finalspeed <= 16 Then
		PlaySoundAtLevelActiveBall ("Apron_Medium_" & Int(Rnd * 3) + 1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
	End If
	If finalspeed < 6 Then
		PlaySoundAtLevelActiveBall ("Apron_Soft_" & Int(Rnd * 7) + 1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
	End If
End Sub

'/////////////////////////////  TARGET HIT SOUNDS  ////////////////////////////

Sub RandomSoundTargetHitStrong()
	PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd * 4) + 5,DOFTargets), Vol(ActiveBall) * 0.45 * TargetSoundFactor
End Sub

Sub RandomSoundTargetHitWeak()
	PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd * 4) + 1,DOFTargets), Vol(ActiveBall) * TargetSoundFactor
End Sub

Sub PlayTargetSound()
	Dim finalspeed
	finalspeed = Sqr(ActiveBall.velx * ActiveBall.velx + ActiveBall.vely * ActiveBall.vely)
	If finalspeed > 10 Then
		RandomSoundTargetHitStrong()
		RandomSoundBallBouncePlayfieldSoft ActiveBall
	Else
		RandomSoundTargetHitWeak()
	End If
End Sub

Sub Targets_Hit (idx)
	PlayTargetSound
End Sub

'/////////////////////////////  BALL BOUNCE SOUNDS  ////////////////////////////

Sub RandomSoundBallBouncePlayfieldSoft(aBall)
	Select Case Int(Rnd * 9) + 1
		Case 1
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_1"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
		Case 2
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
		Case 3
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_3"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.8, aBall
		Case 4
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_4"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
		Case 5
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_5"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
		Case 6
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_1"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 7
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 8
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_5"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 9
			PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_7"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.3, aBall
	End Select
End Sub

Sub RandomSoundBallBouncePlayfieldHard(aBall)
	PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_" & Int(Rnd * 7) + 1), volz(aBall) * BallBouncePlayfieldHardFactor, aBall
End Sub

'/////////////////////////////  DELAYED DROP - TO PLAYFIELD - SOUND  ////////////////////////////

Sub RandomSoundDelayedBallDropOnPlayfield(aBall)
	Select Case Int(Rnd * 5) + 1
		Case 1
			PlaySoundAtLevelStatic ("Ball_Drop_Playfield_1_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 2
			PlaySoundAtLevelStatic ("Ball_Drop_Playfield_2_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 3
			PlaySoundAtLevelStatic ("Ball_Drop_Playfield_3_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 4
			PlaySoundAtLevelStatic ("Ball_Drop_Playfield_4_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 5
			PlaySoundAtLevelStatic ("Ball_Drop_Playfield_5_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
	End Select
End Sub

'/////////////////////////////  BALL GATES AND BRACKET GATES SOUNDS  ////////////////////////////

Sub SoundPlayfieldGate()
	PlaySoundAtLevelStatic ("Gate_FastTrigger_" & Int(Rnd * 2) + 1), GateSoundLevel, ActiveBall
End Sub

Sub SoundHeavyGate()
	PlaySoundAtLevelStatic ("Gate_2"), GateSoundLevel, ActiveBall
End Sub

Sub Gates_hit(idx)
	SoundHeavyGate
End Sub

Sub GatesWire_hit(idx)
	SoundPlayfieldGate
End Sub

'/////////////////////////////  LEFT LANE ENTRANCE - SOUNDS  ////////////////////////////

Sub RandomSoundLeftArch()
	PlaySoundAtLevelActiveBall ("Arch_L" & Int(Rnd * 4) + 1), Vol(ActiveBall) * ArchSoundFactor
End Sub

Sub RandomSoundRightArch()
	PlaySoundAtLevelActiveBall ("Arch_R" & Int(Rnd * 4) + 1), Vol(ActiveBall) * ArchSoundFactor
End Sub

Sub Arch1_hit()
	If ActiveBall.velx > 1 Then SoundPlayfieldGate
	StopSound "Arch_L1"
	StopSound "Arch_L2"
	StopSound "Arch_L3"
	StopSound "Arch_L4"
End Sub

Sub Arch1_unhit()
	If ActiveBall.velx <  - 8 Then
		RandomSoundRightArch
	End If
End Sub

Sub Arch2_hit()
	If ActiveBall.velx < 1 Then SoundPlayfieldGate
	StopSound "Arch_R1"
	StopSound "Arch_R2"
	StopSound "Arch_R3"
	StopSound "Arch_R4"
End Sub

Sub Arch2_unhit()
	If ActiveBall.velx > 10 Then
		RandomSoundLeftArch
	End If
End Sub

'/////////////////////////////  SAUCERS (KICKER HOLES)  ////////////////////////////

Sub SoundSaucerLock()
	PlaySoundAtLevelStatic ("Saucer_Enter_" & Int(Rnd * 2) + 1), SaucerLockSoundLevel, ActiveBall
End Sub

Sub SoundSaucerKick(scenario, saucer)
	Select Case scenario
		Case 0
			PlaySoundAtLevelStatic SoundFX("Saucer_Empty", DOFContactors), SaucerKickSoundLevel, saucer
		Case 1
			PlaySoundAtLevelStatic SoundFX("Saucer_Kick", DOFContactors), SaucerKickSoundLevel, saucer
	End Select
End Sub

'/////////////////////////////  BALL COLLISION SOUND  ////////////////////////////

Sub OnBallBallCollision(ball1, ball2, velocity)
	Dim snd
	Select Case Int(Rnd * 7) + 1
		Case 1
			snd = "Ball_Collide_1"
		Case 2
			snd = "Ball_Collide_2"
		Case 3
			snd = "Ball_Collide_3"
		Case 4
			snd = "Ball_Collide_4"
		Case 5
			snd = "Ball_Collide_5"
		Case 6
			snd = "Ball_Collide_6"
		Case 7
			snd = "Ball_Collide_7"
	End Select
	
	PlaySound (snd), 0, CSng(velocity) ^ 2 / 200 * BallWithBallCollisionSoundFactor * VolumeDial, AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub


'///////////////////////////  DROP TARGET HIT SOUNDS  ///////////////////////////

Sub RandomSoundDropTargetReset(obj)
	PlaySoundAtLevelStatic SoundFX("Drop_Target_Reset_" & Int(Rnd * 6) + 1,DOFContactors), 1, obj
End Sub

Sub SoundDropTargetDrop(obj)
	PlaySoundAtLevelStatic ("Drop_Target_Down_" & Int(Rnd * 6) + 1), 200, obj
End Sub

'/////////////////////////////  GI AND FLASHER RELAYS  ////////////////////////////

Const RelayFlashSoundLevel = 0.315  'volume level; range [0, 1];
Const RelayGISoundLevel = 1.05	  'volume level; range [0, 1];

Sub Sound_GI_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_GI_On"), 0.025 * RelayGISoundLevel, obj
		Case 0
			PlaySoundAtLevelStatic ("Relay_GI_Off"), 0.025 * RelayGISoundLevel, obj
	End Select
End Sub

Sub Sound_Flash_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_Flash_On"), 0.025 * RelayFlashSoundLevel, obj
		Case 0
			PlaySoundAtLevelStatic ("Relay_Flash_Off"), 0.025 * RelayFlashSoundLevel, obj
	End Select
End Sub

'/////////////////////////////////////////////////////////////////
'					End Mechanical Sounds
'/////////////////////////////////////////////////////////////////

'******************************************************
'****  END FLEEP MECHANICAL SOUNDS
'******************************************************

'******************************************************
'	ZBRL:  BALL ROLLING AND DROP SOUNDS
'******************************************************

' Be sure to call RollingUpdate in a timer with a 10ms interval see the GameTimer_Timer() sub

Sub GameTimer_Timer
	RollingUpdate
End Sub

ReDim rolling(tnob)
InitRolling

Dim DropCount
ReDim DropCount(tnob)

Sub InitRolling
	Dim i
	For i = 0 To tnob
		rolling(i) = False
	Next
End Sub

Sub RollingUpdate()
	Dim b
	Dim gBOT
	gBOT = GetBalls
	
	' stop the sound of deleted balls
	For b = UBound(gBOT) + 1 To tnob - 1
		' Comment the next line if you are not implementing Dyanmic Ball Shadows
		'If AmbientBallShadowOn = 0 Then BallShadowA(b).visible = 0
		rolling(b) = False
		StopSound("BallRoll_" & b)
	Next
	
	' exit the sub if no balls on the table
	If UBound(gBOT) =  - 1 Then Exit Sub
	
	' play the rolling sound for each ball
	For b = 0 To UBound(gBOT)
		If BallVel(gBOT(b)) > 1 And gBOT(b).z < 30 Then
			rolling(b) = True
			PlaySound ("BallRoll_" & b), - 1, VolPlayfieldRoll(gBOT(b)) * BallRollVolume * VolumeDial, AudioPan(gBOT(b)), 0, PitchPlayfieldRoll(gBOT(b)), 1, 0, AudioFade(gBOT(b))
		Else
			If rolling(b) = True Then
				StopSound("BallRoll_" & b)
				rolling(b) = False
			End If
		End If
		
		' Ball Drop Sounds
		If gBOT(b).VelZ <  - 1 And gBOT(b).z < 55 And gBOT(b).z > 27 Then 'height adjust for ball drop sounds
			If DropCount(b) >= 5 Then
				DropCount(b) = 0
				If gBOT(b).velz >  - 7 Then
					RandomSoundBallBouncePlayfieldSoft gBOT(b)
				Else
					RandomSoundBallBouncePlayfieldHard gBOT(b)
				End If
			End If
		End If
		
		If DropCount(b) < 5 Then
			DropCount(b) = DropCount(b) + 1
		End If
		
		' "Static" Ball Shadows
		' Comment the next If block, if you are not implementing the Dynamic Ball Shadows
		'If AmbientBallShadowOn = 0 Then
		'	If gBOT(b).Z > 30 Then
		'		BallShadowA(b).height = gBOT(b).z - BallSize / 4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping the ramp
		'	Else
		'		BallShadowA(b).height = 0.1
		'	End If
		'	BallShadowA(b).Y = gBOT(b).Y + offsetY
		'	BallShadowA(b).X = gBOT(b).X + offsetX
		'	BallShadowA(b).visible = 1
		'End If
	Next
End Sub

'******************************************************
'****  END BALL ROLLING AND DROP SOUNDS
'******************************************************




'******************************************************
' 	ZRRL: RAMP ROLLING SFX
'******************************************************

Dim RampMinLoops
RampMinLoops = 4

' RampBalls
' Setup:  Set the array length of x in RampBalls(x,2) Total Number of Balls on table + 1:  if tnob = 5, then RampBalls(6,2)
Dim RampBalls(6,2)
'x,0 = ball x,1 = ID, 2 = Protection against ending early (minimum amount of updates)

'0,0 is boolean on/off, 0,1 unused for now
RampBalls(0,0) = False

' RampType
' Setup: Set this array to the number Total number of balls that can be tracked at one time + 1.  5 ball multiball then set value to 6
' Description: Array type indexed on BallId and a values used to deterimine what type of ramp the ball is on: False = Wire Ramp, True = Plastic Ramp
Dim RampType(6)

Sub WireRampOn(input)
	Waddball ActiveBall, input
	RampRollUpdate
End Sub

Sub WireRampOff()
	WRemoveBall ActiveBall.ID
End Sub

' WaddBall (Active Ball, Boolean)
Sub Waddball(input, RampInput) 'This subroutine is called from WireRampOn to Add Balls to the RampBalls Array
	' This will loop through the RampBalls array checking each element of the array x, position 1
	' To see if the the ball was already added to the array.
	' If the ball is found then exit the subroutine
	Dim x
	For x = 1 To UBound(RampBalls)	'Check, don't add balls twice
		If RampBalls(x, 1) = input.id Then
			If Not IsEmpty(RampBalls(x,1) ) Then Exit Sub	'Frustating issue with BallId 0. Empty variable = 0
		End If
	Next
	
	' This will itterate through the RampBalls Array.
	' The first time it comes to a element in the array where the Ball Id (Slot 1) is empty.  It will add the current ball to the array
	' The RampBalls assigns the ActiveBall to element x,0 and ball id of ActiveBall to 0,1
	' The RampType(BallId) is set to RampInput
	' RampBalls in 0,0 is set to True, this will enable the timer and the timer is also turned on
	For x = 1 To UBound(RampBalls)
		If IsEmpty(RampBalls(x, 1)) Then
			Set RampBalls(x, 0) = input
			RampBalls(x, 1) = input.ID
			RampType(x) = RampInput
			RampBalls(x, 2) = 0
			'exit For
			RampBalls(0,0) = True
			RampRoll.Enabled = 1	 'Turn on timer
			'RampRoll.Interval = RampRoll.Interval 'reset timer
			Exit Sub
		End If
		If x = UBound(RampBalls) Then	 'debug
			Debug.print "WireRampOn error, ball queue Is full: " & vbNewLine & _
			RampBalls(0, 0) & vbNewLine & _
			TypeName(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & "type:" & RampType(1) & vbNewLine & _
			TypeName(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & "type:" & RampType(2) & vbNewLine & _
			TypeName(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & "type:" & RampType(3) & vbNewLine & _
			TypeName(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & "type:" & RampType(4) & vbNewLine & _
			TypeName(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & "type:" & RampType(5) & vbNewLine & _
			" "
		End If
	Next
End Sub

' WRemoveBall (BallId)
Sub WRemoveBall(ID) 'This subroutine is called from the RampRollUpdate subroutine and is used to remove and stop the ball rolling sounds
	'   Debug.Print "In WRemoveBall() + Remove ball from loop array"
	Dim ballcount
	ballcount = 0
	Dim x
	For x = 1 To UBound(RampBalls)
		If ID = RampBalls(x, 1) Then 'remove ball
			Set RampBalls(x, 0) = Nothing
			RampBalls(x, 1) = Empty
			RampType(x) = Empty
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		End If
		'if RampBalls(x,1) = Not IsEmpty(Rampballs(x,1) then ballcount = ballcount + 1
		If Not IsEmpty(Rampballs(x,1)) Then ballcount = ballcount + 1
	Next
	If BallCount = 0 Then RampBalls(0,0) = False	'if no balls in queue, disable timer update
End Sub

Sub RampRoll_Timer()
	RampRollUpdate
End Sub

Sub RampRollUpdate()	'Timer update
	Dim x
	For x = 1 To UBound(RampBalls)
		If Not IsEmpty(RampBalls(x,1) ) Then
			If BallVel(RampBalls(x,0) ) > 1 Then ' if ball is moving, play rolling sound
				If RampType(x) Then
					PlaySound("RampLoop" & x), - 1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitchV(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))
					StopSound("wireloop" & x)
				Else
					StopSound("RampLoop" & x)
					PlaySound("wireloop" & x), - 1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitch(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))
				End If
				RampBalls(x, 2) = RampBalls(x, 2) + 1
			Else
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
			End If
			If RampBalls(x,0).Z < 30 And RampBalls(x, 2) > RampMinLoops Then	'if ball is on the PF, remove  it
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
				Wremoveball RampBalls(x,1)
			End If
		Else
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		End If
	Next
	If Not RampBalls(0,0) Then RampRoll.enabled = 0
End Sub

' This can be used to debug the Ramp Roll time.  You need to enable the tbWR timer on the TextBox
Sub tbWR_Timer()	'debug textbox
	Me.text = "on? " & RampBalls(0, 0) & " timer: " & RampRoll.Enabled & vbNewLine & _
	"1 " & TypeName(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & " type:" & RampType(1) & " Loops:" & RampBalls(1, 2) & vbNewLine & _
	"2 " & TypeName(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & " type:" & RampType(2) & " Loops:" & RampBalls(2, 2) & vbNewLine & _
	"3 " & TypeName(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & " type:" & RampType(3) & " Loops:" & RampBalls(3, 2) & vbNewLine & _
	"4 " & TypeName(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & " type:" & RampType(4) & " Loops:" & RampBalls(4, 2) & vbNewLine & _
	"5 " & TypeName(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & " type:" & RampType(5) & " Loops:" & RampBalls(5, 2) & vbNewLine & _
	"6 " & TypeName(RampBalls(6, 0)) & " ID:" & RampBalls(6, 1) & " type:" & RampType(6) & " Loops:" & RampBalls(6, 2) & vbNewLine & _
	" "
End Sub

Function BallPitch(ball) ' Calculates the pitch of the sound based on the ball speed
	BallPitch = pSlope(BallVel(ball), 1, - 1000, 60, 10000)
End Function

Function BallPitchV(ball) ' Calculates the pitch of the sound based on the ball speed Variation
	BallPitchV = pSlope(BallVel(ball), 1, - 4000, 60, 7000)
End Function

'******************************************************
'**** END RAMP ROLLING SFX
'******************************************************

'***************************************************************************
' VR Plunger Code
'***************************************************************************
Sub TimerVRPlunger_Timer
	If PinCab_Shooter.Y < 100 then
		PinCab_Shooter.Y = PinCab_Shooter.Y + 5
	End If
End Sub

Sub TimerVRPlunger1_Timer
	PinCab_Shooter.Y = 0 + (5* Plunger.Position) - 20
End Sub
'***************************************************************************




'*****   VR Prison Room - Rawd -  ******

Dim Strobe: Strobe = 1
Dim StrobeState
Dim AttractSequence: AttractSequence = 0

VRLampLight.blenddisablelighting = 150


sub SetVRRGBGreen
	dim c, x
	c = RGB(0,255,0)
	For Each x in VRRGB:x.color = c:Next
End Sub

sub SetVRRGBYellow
	dim c, x
	c = RGB(255,255,0) 
	For Each x in VRRGB:x.color = c:Next
End Sub

sub SetVRRGBWhite
	dim c, x
	c = RGB(255,255,255)
	For Each x in VRRGB:x.color = c:Next
End Sub

sub SetVRRGBRed
	dim c, x
	c = RGB(255,0,0)
	For Each x in VRRGB:x.color = c:Next
End Sub

sub SetVRRGBBlue
	dim c, x
	c = RGB(0,0,255)
	For Each x in VRRGB:x.color = c:Next
End Sub

sub SetVRRGBRandom()
    dim c, x

Select Case Int(rnd*5)
			Case 0: c = RGB(255,255,0) 'Yellow
			Case 1: c = RGB(255,0,0) 'RED
			Case 2: c = RGB(255,255,255)  'white
			Case 3: c = RGB(0,255,0) 'GREEN
			Case 4: c = RGB(0,0,255) 'Blue
		End Select

    For Each x in VRRGB:x.color = c:Next
end Sub


Sub NS()  ' No Strobe
VRStrobe1.blenddisablelighting = 0
VRStrobe1.visible = false
VRStrobe2.blenddisablelighting = 0
VRStrobe2.visible = false
VRRoomBase.image = "RoomSpot"
PinCab_Cabinet.image = "CabSpot"
PinCab_Backbox.image = "BoxSpot"
VRDoor.Image = "DoorSpot"
VRCeiling.Image = "CeilingSpotb"
VRLamp.Image = "LampSpot"
VRDoorMetals.Image = "DoorMetalSpot"
PinCab_Right_Flipper_Button.blenddisablelighting = 0
PinCab_Right_Flipper_Button_Rin.blenddisablelighting = 0
PinCab_Left_Flipper_Button_Ring.blenddisablelighting = 0
PinCab_Left_Flipper_Button.blenddisablelighting = 0
PinCab_Metal.blenddisablelighting = 0
PinCab_Shooter.blenddisablelighting = 0
PinCab_Housing.blenddisablelighting = 0
PinCab_Metal_Fittings.blenddisablelighting = 0
Primary_VRBackleftLeg.blenddisablelighting = 0
Primary_VRBackRightLeg.blenddisablelighting = 0
VRDoorMetals.blenddisablelighting = 0
End Sub


Sub RS() 'Right Strobe
VRStrobe1.blenddisablelighting = 150
VRStrobe1.visible = true
VRStrobe2.blenddisablelighting = 0
VRStrobe2.visible = false
VRRoomBase.image = "RoomStrobe1"
PinCab_Cabinet.image = "CabSTROBE1"
PinCab_Backbox.image = "BoxSTROBE1"
VRDoor.Image = "DoorStrobe1"
VRCeiling.Image = "CeilingStrobe1b"
VRLamp.Image = "LampStrobe1"
VRDoorMetals.Image = "DoorMetalStrobe1"
PinCab_Right_Flipper_Button.blenddisablelighting = 1
PinCab_Right_Flipper_Button_Rin.blenddisablelighting = 1
PinCab_Left_Flipper_Button_Ring.blenddisablelighting = 0
PinCab_Left_Flipper_Button.blenddisablelighting = 0
PinCab_Metal.blenddisablelighting = 0.4
PinCab_Shooter.blenddisablelighting = 0.4
PinCab_Housing.blenddisablelighting = 0.4
PinCab_Metal_Fittings.blenddisablelighting = 0.4
Primary_VRBackleftLeg.blenddisablelighting = 0.4
Primary_VRBackRightLeg.blenddisablelighting = 0.4
VRDoorMetals.blenddisablelighting = 0.6
end Sub


Sub LS() ' Left Strobe
VRStrobe1.blenddisablelighting = 0
VRStrobe1.visible = false
VRStrobe2.blenddisablelighting = 150
VRStrobe2.visible = true
VRRoomBase.image = "RoomStrobe2"
PinCab_Cabinet.image = "CabSTROBE2"
PinCab_Backbox.image = "BoxSTROBE2"
VRDoor.Image = "DoorStrobe2"
VRCeiling.Image = "CeilingStrobe2b"
VRLamp.Image = "LampStrobe2"
VRDoorMetals.Image = "DoorMetalStrobe2"
PinCab_Right_Flipper_Button.blenddisablelighting = 0
PinCab_Right_Flipper_Button_Rin.blenddisablelighting = 0
PinCab_Left_Flipper_Button_Ring.blenddisablelighting = 1
PinCab_Left_Flipper_Button.blenddisablelighting = 1
PinCab_Metal.blenddisablelighting = 0.4
PinCab_Shooter.blenddisablelighting = 0.4
PinCab_Housing.blenddisablelighting = 0.4
PinCab_Metal_Fittings.blenddisablelighting = 0.4
Primary_VRBackleftLeg.blenddisablelighting = 0.4
Primary_VRBackRightLeg.blenddisablelighting = 0.4
VRDoorMetals.blenddisablelighting = 0.4
end Sub


Sub StrobeTimer_Timer()

If StrobeState = 1 then  ' Regular Strobe
	Strobe = Strobe + 1
	If Strobe = 1 then RS
	If Strobe = 2 then LS
	If Strobe = 3 then NS: Strobe = 0
end if

If StrobeState = 2 then ' Multicolor Strobe

	Strobe = Strobe + 1
	If Strobe = 1 then RS
	If Strobe = 2 then LS
	If Strobe = 3 then NS : Strobe = 0: SetVRRGBRandom
end if

If StrobeState = 3 then '  Strobe left
	Strobe = Strobe + 1
	If Strobe = 1 then LS
	If Strobe = 2 then NS: Strobe = 0
end if

If StrobeState = 4 then '  Strobe Right
	Strobe = Strobe + 1
	If Strobe = 1 then RS
	If Strobe = 2 then NS: Strobe = 0
end if

End Sub


'VRStrobe Callouts

Sub StrobeWhite() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBWhite: StrobeState = 1: StrobeTimer.interval = 33: End Sub
Sub StrobeGreen() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBGreen: StrobeState = 1: StrobeTimer.interval = 33: End Sub
Sub StrobeYellow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBYellow: StrobeState = 1: StrobeTimer.interval = 33: End Sub
Sub StrobeRed() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBRed: StrobeState = 1: StrobeTimer.interval = 33: End Sub
Sub StrobeBlue() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBBlue: StrobeState = 1: StrobeTimer.interval = 99: End Sub
Sub StrobeRandom() Strobe = 1:StrobeTimer.enabled = True: StrobeState = 2: StrobeTimer.interval = 33: End Sub

Sub StrobeWhiteSlow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBWhite: StrobeState = 1: StrobeTimer.interval = 1000: End Sub
Sub StrobeGreenSlow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBGreen: StrobeState = 1: StrobeTimer.interval = 1000: End Sub
Sub StrobeYellowSlow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBYellow: StrobeState = 1: StrobeTimer.interval = 1000: End Sub
Sub StrobeRedSlow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBRed: StrobeState = 1: StrobeTimer.interval = 1000: End Sub
Sub StrobeBlueSlow() Strobe = 1:StrobeTimer.enabled = True: SetVRRGBBlue: StrobeState = 1: StrobeTimer.interval = 1000: End Sub
Sub StrobeRandomSlow() Strobe = 1:StrobeTimer.enabled = True: StrobeState = 2: StrobeTimer.interval = 1000: End Sub

Sub StrobeWhiteLeft() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBWhite: StrobeState = 3: StrobeTimer.interval = 33: End Sub
Sub StrobeGreenLeft() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBGreen: StrobeState = 3: StrobeTimer.interval = 33: End Sub
Sub StrobeYellowLeft() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBYellow: StrobeState = 3: StrobeTimer.interval = 33: End Sub
Sub StrobeRedLeft() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBRed: StrobeState = 3: StrobeTimer.interval = 33: End Sub
Sub StrobeBlueLeft() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBBlue: StrobeState = 3: StrobeTimer.interval = 99: End Sub

Sub StrobeWhiteRight() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBWhite: StrobeState = 4: StrobeTimer.interval = 33: End Sub
Sub StrobeGreenRight() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBGreen: StrobeState = 4: StrobeTimer.interval = 33: End Sub
Sub StrobeYellowRight() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBYellow: StrobeState = 4: StrobeTimer.interval = 33: End Sub
Sub StrobeRedRight() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBRed: StrobeState = 4: StrobeTimer.interval = 33: End Sub
Sub StrobeBlueRight() Strobe = 1: StrobeTimer.enabled = True: SetVRRGBBlue: StrobeState = 4: StrobeTimer.interval = 99: End Sub

Sub SolidWhite() Strobe = 1: StrobeTimer.enabled = False: SetVRRGBWhite: NS: End Sub
Sub SolidGreen() Strobe = 1: StrobeTimer.enabled = False: SetVRRGBGreen: NS: End Sub
Sub SolidYellow() Strobe = 1: StrobeTimer.enabled = False: SetVRRGBYellow: NS: End Sub
Sub SolidRed() Strobe = 1: StrobeTimer.enabled = False: SetVRRGBRed: NS: End Sub


Sub VRAttractTimer_timer()

AttractSequence = AttractSequence +1

if AttractSequence = 1 then StrobeRandomSlow
if AttractSequence = 2 then StrobeWhiteRight: VRAttracttimer.Interval = 700
if AttractSequence = 3 then StrobeWhiteLeft
if AttractSequence = 4 then StrobeYellowLeft
if AttractSequence = 5 then StrobeBlueRight
if AttractSequence = 6 then StrobeRedRight
if AttractSequence = 7 then StrobeGreenLeft
if AttractSequence = 8 then Strobewhite
if AttractSequence = 9 then SetVRRGBRandom: AttractSequence = 0 : VRAttracttimer.Interval = 5000

End Sub

'***** End VR Prison Room code - Rawd - *****






'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
' X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  X  
'/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
'  SCORBIT Interface
' To Use:
' 1) Define a timer tmrScorbit
' 2) Call DoInit at the end of PupInit or in Table Init if you are nto using pup with the appropriate parameters
'		if Scorbit.DoInit(389, "PupOverlays", "1.0.0", "GRWvz-MP37P") then 
'			tmrScorbit.Interval=2000
'			tmrScorbit.UserValue = 0
'			tmrScorbit.Enabled=True 
'		End if 
' 3) Customize helper functions below for different events if you want or make your own 
' 4) Call 
'		StartSession - When a game starts 
'		StopSession - When the game is over
'		SendUpdate - When Score Changes
'		SetGameMode - When different game events happen like starting a mode, MB etc.  (ScorbitBuildGameModes helper function shows you how)
' 5) Drop the binaries sQRCode.exe and sToken.exe in your Pup Root so we can create session kets and QRCodes.
' 6) Callbacks 
'		Scorbit_Paired   		- Called when machine is successfully paired.  Hide QRCode and play a sound 
'		Scorbit_PlayerClaimed	- Called when player is claimed.  Hide QRCode, play a sound and display name 
'
'
'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
' TABLE CUSTOMIZATION START HERE 


Sub Scorbit_NeedsPairing()								' Scorbit callback when new machine needs pairing 
	on error resume next
	debug.print("needs pairing")
	LoadTexture "", TablesDir &"\MEGADETH\QRcode.png"
	scorbitQRFlasher.Visible = True
	scorbitQRFlasher.ImageA = "QRCode"
	On error goto 0 
End Sub 

Sub Scorbit_Paired()								' Scorbit callback when new machine is paired 
	on error resume next
	debug.print("paired")
	LoadTexture "", TablesDir &"\MEGADETH\QRclaim.png"
	scorbitQRFlasher.Visible = True
	scorbitQRFlasher.ImageA = "QRClaim"
	On error goto 0 
End Sub 

Sub Scorbit_PlayerClaimed(PlayerNum, PlayerName)	' Scorbit callback when QR Is Claimed 


End Sub 


Sub ScorbitClaimQR(bShow)						'  Show QRCode on first ball for users to claim this position
	
End Sub 

Sub ScorbitBuildGameModes()		' Custom function to build the game modes for better stats 
	dim GameModeStr
	
	Scorbit.SetGameMode(GameModeStr)

End Sub 

Sub Scorbit_LOGUpload(state)	' Callback during the log creation process.  0=Creating Log, 1=Uploading Log, 2=Done 
	Select Case state 
		case 0:
			'Debug.print "CREATING LOG"
		case 1:
			'Debug.print "Uploading LOG"
		case 2:
			'Debug.print "LOG Complete"
	End Select 
End Sub 
'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
' TABLE CUSTOMIZATION END HERE - NO NEED TO EDIT BELOW THIS LINE


dim Scorbit : Scorbit = Null
' Workaround - Call get a reference to Member Function
Sub tmrScorbit_Timer()								' Timer to send heartbeat 
	Scorbit.DoTimer(tmrScorbit.UserValue)
	tmrScorbit.UserValue=tmrScorbit.UserValue+1
	if tmrScorbit.UserValue>5 then tmrScorbit.UserValue=0
End Sub 
Function ScorbitIF_Callback()
	Scorbit.Callback()
End Function 
Class ScorbitIF

	Public bSessionActive
	Public bNeedsPairing
	Private bUploadLog
	Private bActive
	Private LOGFILE(10000000)
	Private LogIdx

	Private bProduction

	Private TypeLib
	Private MyMac
	Private Serial
	Private MyUUID
	Private TableVersion

	Private SessionUUID
	Private SessionSeq
	Private SessionTimeStart
	Private bRunAsynch
	Private bWaitResp
	Private GameMode
	Private GameModeOrig		' Non escaped version for log
	Private VenueMachineID
	Private CachedPlayerNames(4)
	Private SaveCurrentPlayer

	Public bEnabled
	Private sToken
	Private machineID
	Private dirQRCode
	Private opdbID
	Private wsh

	Private objXmlHttpMain
	Private objXmlHttpMainAsync
	Private fso
	Private Domain

	Public Sub Class_Initialize()
		bActive="false"
		bSessionActive=False
		bEnabled=False 
	End Sub 

	Property Let UploadLog(bValue)
		bUploadLog = bValue
	End Property

	Sub DoTimer(bInterval)	' 2 second interval
		dim holdScores(4)
		dim i

		if bInterval=0 then 
			SendHeartbeat()
		elseif bRunAsynch then ' Game in play
			'debug.Print("Scorbit.SendUpdate " & TotalScore(1) & ", " & TotalScore(2) & ", " & TotalScore(3) & ", " & TotalScore(4) & ", " & 4-CurrentBall & ", " & CurrentPlayer & ", " & Players)
			Scorbit.SendUpdate Score(1), Score(2), Score(3), Score(4), Balls, CurrentPlayer, PlayersPlayingGame
		End if 
	End Sub 

	Function GetName(PlayerNum)	' Return Parsed Players name  
		if PlayerNum<1 or PlayerNum>4 then 
			GetName=""
		else 
			GetName=CachedPlayerNames(PlayerNum)
		End if 
	End Function 

	Function DoInit(MyMachineID, Directory_PupQRCode, Version, opdb)
		dim Nad
		Dim EndPoint
		Dim resultStr 
		Dim UUIDParts 
		Dim UUIDFile

		bProduction=1
'		bProduction=0
		SaveCurrentPlayer=0
		VenueMachineID=""
		bWaitResp=False 
		bRunAsynch=False 
		DoInit=False 
		opdbID=opdb
		dirQrCode=Directory_PupQRCode
		MachineID=MyMachineID
		TableVersion=version
		bNeedsPairing=False 
		if bProduction then 
			domain = "api.scorbit.io"
		else 
			domain = "staging.scorbit.io"
			domain = "scorbit-api-staging.herokuapp.com"
		End if 
		'msgbox "production: " & bProduction
		Set fso = CreateObject("Scripting.FileSystemObject")
		dim objLocator:Set objLocator = CreateObject("WbemScripting.SWbemLocator")
		Dim objService:Set objService = objLocator.ConnectServer(".", "root\cimv2")
		Set objXmlHttpMain = CreateObject("Msxml2.ServerXMLHTTP")
		Set objXmlHttpMainAsync = CreateObject("Microsoft.XMLHTTP")
		objXmlHttpMain.onreadystatechange = GetRef("ScorbitIF_Callback")
		Set wsh = CreateObject("WScript.Shell")

		' Get Mac for Serial Number 
		dim Nads: set Nads = objService.ExecQuery("Select * from Win32_NetworkAdapter where physicaladapter=true")
		for each Nad in Nads
			if not isnull(Nad.MACAddress) then
				'msgbox "Using MAC Addresses:" & Nad.MACAddress & " From Adapter:" & Nad.description   
				MyMac=replace(Nad.MACAddress, ":", "")
				Exit For 
			End if 
		Next
		Serial=eval("&H" & mid(MyMac, 5))
'		Serial=123456
	'	debug.print "Serial: " & Serial
		serial = serial + MachineID
	'	debug.print "New Serial with machine id: " & Serial

		' Get System UUID
		set Nads = objService.ExecQuery("SELECT * FROM Win32_ComputerSystemProduct")
		for each Nad in Nads
			'msgbox "Using UUID:" & Nad.UUID   
			MyUUID=Nad.UUID
			Exit For 
		Next

		if MyUUID="" then 
			MsgBox "SCORBIT - Can get UUID, Disabling."
			Exit Function
		elseif MyUUID="03000200-0400-0500-0006-000700080009" or ScorbitAlternateUUID then
			If fso.FolderExists(UserDirectory) then 
				If fso.FileExists(UserDirectory & "ScorbitUUID.dat") then
					Set UUIDFile = fso.OpenTextFile(UserDirectory & "ScorbitUUID.dat",1)
					MyUUID = UUIDFile.ReadLine()
					UUIDFile.Close
					Set UUIDFile = Nothing
				Else 
					MyUUID=GUID()
					Set UUIDFile=fso.CreateTextFile(UserDirectory & "ScorbitUUID.dat",True)
					UUIDFile.WriteLine MyUUID
					UUIDFile.Close
					Set UUIDFile=Nothing
		End if
			End if 
		End if

		' Clean UUID
		UUIDParts=split(MyUUID, "-")
		'msgbox UUIDParts(0)
		MyUUID=LCASE(Hex(eval("&h" & UUIDParts(0))+MyMachineID)) & UUIDParts(1) &  UUIDParts(2) &  UUIDParts(3) & UUIDParts(4)		 ' Add MachineID to UUID
		'msgbox UUIDParts(0)
		MyUUID=LPad(MyUUID, 32, "0")
'		MyUUID=Replace(MyUUID, "-",  "")
	'	Debug.print "MyUUID:" & MyUUID 


' Debug
'		myUUID="adc12b19a3504453a7414e722f58737f"
'		Serial="123456778"

		'create own folder for table QRCodes TablesDir & "\" & dirQrCode
		If Not fso.FolderExists(TablesDir & "\" & dirQrCode) then
			fso.CreateFolder(TablesDir & "\" & dirQrCode)
		end if

		' Authenticate and get our token 
		if getStoken() then 
			bEnabled=True 
'			SendHeartbeat
			DoInit=True
		End if 
	End Function 



	Sub Callback()
		Dim ResponseStr
		Dim i 
		Dim Parts
		Dim Parts2
		Dim Parts3
		if bEnabled=False then Exit Sub 

		if bWaitResp and objXmlHttpMain.readystate=4 then 
			'Debug.print "CALLBACK: " & objXmlHttpMain.Status & " " & objXmlHttpMain.readystate
			if objXmlHttpMain.Status=200 and objXmlHttpMain.readystate = 4 then 
				ResponseStr=objXmlHttpMain.responseText
				'Debug.print "RESPONSE: " & ResponseStr

				' Parse Name 
				if CachedPlayerNames(SaveCurrentPlayer-1)="" then  ' Player doesnt have a name
					if instr(1, ResponseStr, "cached_display_name") <> 0 Then	' There are names in the result
						Parts=Split(ResponseStr,",{")							' split it 
						if ubound(Parts)>=SaveCurrentPlayer-1 then 				' Make sure they are enough avail
							if instr(1, Parts(SaveCurrentPlayer-1), "cached_display_name")<>0 then 	' See if mine has a name 
								CachedPlayerNames(SaveCurrentPlayer-1)=GetJSONValue(Parts(SaveCurrentPlayer-1), "cached_display_name")		' Get my name
								CachedPlayerNames(SaveCurrentPlayer-1)=Replace(CachedPlayerNames(SaveCurrentPlayer-1), """", "")
								Scorbit_PlayerClaimed SaveCurrentPlayer, CachedPlayerNames(SaveCurrentPlayer-1)
								'Debug.print "Player Claim:" & SaveCurrentPlayer & " " & CachedPlayerNames(SaveCurrentPlayer-1)
							End if 
						End if
					End if 
				else												    ' Check for unclaim 
					if instr(1, ResponseStr, """player"":null")<>0 Then	' Someone doesnt have a name
						Parts=Split(ResponseStr,"[")						' split it 
'Debug.print "Parts:" & Parts(1)
						Parts2=Split(Parts(1),"}")							' split it 
						for i = 0 to Ubound(Parts2)
'Debug.print "Parts2:" & Parts2(i)
						if instr(1, Parts2(i), """player"":null")<>0 Then
								CachedPlayerNames(i)=""
							End if 
						Next 
					End if 
				End if
			End if 
			bWaitResp=False
		End if 
	End Sub



	Public Sub StartSession()
		if bEnabled=False then Exit Sub 
'msgbox  "Scorbit Start Session" 
		CachedPlayerNames(0)=""
		CachedPlayerNames(1)=""
		CachedPlayerNames(2)=""
		CachedPlayerNames(3)=""
		bRunAsynch=True 
		bActive="true"
		bSessionActive=True
		SessionSeq=0
		SessionUUID=GUID()
		SessionTimeStart=GameTime
		LogIdx=0
		SendUpdate 0, 0, 0, 0, 1, 1, 1
	End Sub 

	Public Sub StopSession(P1Score, P2Score, P3Score, P4Score, NumberPlayers)
		StopSession2 P1Score, P2Score, P3Score, P4Score, NumberPlayers, False
	End Sub 

	Public Sub StopSession2(P1Score, P2Score, P3Score, P4Score, NumberPlayers, bCancel)
		Dim i
		dim objFile
		if bEnabled=False then Exit Sub 
		if bSessionActive=False then Exit Sub 
'Debug.print "Scorbit Stop Session" 

		bRunAsynch=False 
		bActive="false" 
		bSessionActive=False
		SendUpdate P1Score, P2Score, P3Score, P4Score, -1, -1, NumberPlayers
'		SendHeartbeat

		if bUploadLog and LogIdx<>0 and bCancel=False then 
	'		Debug.print "Creating Scorbit Log: Size" & LogIdx
			Scorbit_LOGUpload(0)
'			Set objFile = fso.CreateTextFile(puplayer.getroot&"\" & cGameName & "\sGameLog.csv")
			Set objFile = fso.CreateTextFile(TablesDir & "\"&dirQrCode&"\sGameLog.csv")
			For i = 0 to LogIdx-1 
				objFile.Writeline LOGFILE(i)
			Next 
			objFile.Close
			LogIdx=0
			Scorbit_LOGUpload(1)
'			pvPostFile "https://" & domain & "/api/session_log/", puplayer.getroot&"\" & cGameName & "\sGameLog.csv", False
			pvPostFile "https://" & domain & "/api/session_log/", TablesDir & "\"&dirQrCode&"\sGameLog.csv", False
			Scorbit_LOGUpload(2)
			on error resume next
'			fso.DeleteFile(puplayer.getroot&"\" & cGameName & "\sGameLog.csv")
			fso.DeleteFile(TablesDir & "\"&dirQrCode&"\sGameLog.csv")
			on error goto 0
		End if 

	End Sub 

	Public Sub SetGameMode(GameModeStr)
		GameModeOrig=GameModeStr
		GameMode=GameModeStr
		GameMode=Replace(GameMode, ":", "%3a")
		GameMode=Replace(GameMode, ";", "%3b")
		GameMode=Replace(GameMode, " ", "%20")
		GameMode=Replace(GameMode, "{", "%7B")
		GameMode=Replace(GameMode, "}", "%7D")
	End sub 

	Public Sub SendUpdate(P1Score, P2Score, P3Score, P4Score, CurrentBall, CurrentPlayer, NumberPlayers)
		SendUpdateAsynch P1Score, P2Score, P3Score, P4Score, CurrentBall, CurrentPlayer, NumberPlayers, bRunAsynch
	End Sub 

	Public Sub SendUpdateAsynch(P1Score, P2Score, P3Score, P4Score, CurrentBall, CurrentPlayer, NumberPlayers, bAsynch)
		dim i
		Dim PostData
		Dim resultStr
		dim LogScores(4)

		if bUploadLog then 
			if NumberPlayers>=1 then LogScores(0)=P1Score
			if NumberPlayers>=2 then LogScores(1)=P2Score
			if NumberPlayers>=3 then LogScores(2)=P3Score
			if NumberPlayers>=4 then LogScores(3)=P4Score
			LOGFILE(LogIdx)=DateDiff("S", "1/1/1970", Now()) & "," & LogScores(0) & "," & LogScores(1) & "," & LogScores(2) & "," & LogScores(3) & ",,," &  CurrentPlayer & "," & CurrentBall & ",""" & GameModeOrig & """"
			LogIdx=LogIdx+1
		End if 

		if bEnabled=False then Exit Sub 
		if bWaitResp then exit sub ' Drop message until we get our next response 
'		debug.print "Current players: " & CurrentPlayer
		SaveCurrentPlayer=CurrentPlayer
'		PostData = "session_uuid=" & SessionUUID & "&session_time=" & DateDiff("S", "1/1/1970", Now()) & _
'					"&session_sequence=" & SessionSeq & "&active=" & bActive
		PostData = "session_uuid=" & SessionUUID & "&session_time=" & GameTime-SessionTimeStart+1 & _
					"&session_sequence=" & SessionSeq & "&active=" & bActive

		SessionSeq=SessionSeq+1
		if NumberPlayers > 0 then 
			for i = 0 to NumberPlayers-1
				PostData = PostData & "&current_p" & i+1 & "_score="
				if i <= NumberPlayers-1 then 
                    if i = 0 then PostData = PostData & P1Score
                    if i = 1 then PostData = PostData & P2Score
                    if i = 2 then PostData = PostData & P3Score
                    if i = 3 then PostData = PostData & P4Score
				else 
					PostData = PostData & "-1"
				End if 
			Next 

			PostData = PostData & "&current_ball=" & CurrentBall & "&current_player=" & CurrentPlayer
			if GameMode<>"" then PostData=PostData & "&game_modes=" & GameMode
		End if 
		resultStr = PostMsg("https://" & domain, "/api/entry/", PostData, bAsynch)
'		if resultStr<>"" then Debug.print "SendUpdate Resp:" & resultStr
	End Sub 

' PRIVATE BELOW 
	Private Function LPad(StringToPad, Length, CharacterToPad)
	  Dim x : x = 0
	  If Length > Len(StringToPad) Then x = Length - len(StringToPad)
	  LPad = String(x, CharacterToPad) & StringToPad
	End Function

	Private Function GUID()		
		Dim TypeLib
		Set TypeLib = CreateObject("Scriptlet.TypeLib")
		GUID = Mid(TypeLib.Guid, 2, 36)

'		Set wsh = CreateObject("WScript.Shell")
'		Set fso = CreateObject("Scripting.FileSystemObject")
'
'		dim rc
'		dim result
'		dim objFileToRead
'		Dim sessionID:sessionID=puplayer.getroot&"\" & cGameName & "\sessionID.txt"
'
'		on error resume next
'		fso.DeleteFile(sessionID)
'		On error goto 0 
'
'		rc = wsh.Run("powershell -Command ""(New-Guid).Guid"" | out-file -encoding ascii " & sessionID, 0, True)
'		if FileExists(sessionID) and rc=0 then
'			Set objFileToRead = fso.OpenTextFile(sessionID,1)
'			result = objFileToRead.ReadLine()
'			objFileToRead.Close
'			GUID=result
'		else 
'			MsgBox "Cant Create SessionUUID through powershell. Disabling Scorbit"
'			bEnabled=False 
'		End if

	End Function

	Private Function GetJSONValue(JSONStr, key)
		dim i 
		Dim tmpStrs,tmpStrs2
		if Instr(1, JSONStr, key)<>0 then 
			tmpStrs=split(JSONStr,",")
			for i = 0 to ubound(tmpStrs)
				if instr(1, tmpStrs(i), key)<>0 then 
					tmpStrs2=split(tmpStrs(i),":")
					GetJSONValue=tmpStrs2(1)
					exit for
				End if 
			Next 
		End if 
	End Function

	Private Sub SendHeartbeat()
		Dim resultStr
		dim TmpStr
		Dim Command
		Dim rc
'		Dim QRFile:QRFile=puplayer.getroot&"\" & cGameName & "\" & dirQrCode
		Dim QRFile:QRFile=TablesDir & "\" & dirQrCode
		if bEnabled=False then Exit Sub 
		resultStr = GetMsgHdr("https://" & domain, "/api/heartbeat/", "Authorization", "SToken " & sToken)
'Debug.print "Heartbeat Resp:" & resultStr
		If VenueMachineID="" then 

			if resultStr<>"" and Instr(resultStr, """unpaired"":true")=0 then 	' We Paired
				bNeedsPairing=False
		'		debug.print "Paired"
				Scorbit_Paired()
			else 
		'		debug.print "Needs Pairing"
				bNeedsPairing=True
				Scorbit_NeedsPairing()
'				if not FScorbitQRIcon.visible then showQRPairImage
			End if 

			TmpStr=GetJSONValue(resultStr, "venuemachine_id")
			if TmpStr<>"" then 
				VenueMachineID=TmpStr
'Debug.print "VenueMachineID=" & VenueMachineID			
'				Command = puplayer.getroot&"\" & cGameName & "\sQRCode.exe " & VenueMachineID & " " & opdbID & " " & QRFile
			'	debug.print "RUN sqrcode"
				Command = """" & TablesDir & "\sQRCode.exe"" " & VenueMachineID & " " & opdbID & " """ & QRFile & """"
'				msgbox Command
				rc = wsh.Run(Command, 0, False)
			End if 
		End if 
	End Sub 

	Private Function getStoken()
		Dim result
		Dim results
'		dim wsh
		Dim tmpUUID:tmpUUID="adc12b19a3504453a7414e722f58736b"
		Dim tmpVendor:tmpVendor="vscorbitron"
		Dim tmpSerial:tmpSerial="999990104"
'		Dim QRFile:QRFile=puplayer.getroot&"\" & cGameName & "\" & dirQrCode
		Dim QRFile:QRFile=TablesDir & "\" & dirQrCode
'		Dim sTokenFile:sTokenFile=puplayer.getroot&"\" & cGameName & "\sToken.dat"
		Dim sTokenFile:sTokenFile=TablesDir & "\"&dirQrCode&"\sToken.dat"

		' Set everything up
		tmpUUID=MyUUID
		tmpVendor="vpin"
		tmpSerial=Serial
		
		on error resume next
		fso.DeleteFile("""" & sTokenFile & """")
		On error goto 0 

		' get sToken and generate QRCode
'		Set wsh = CreateObject("WScript.Shell")
		Dim waitOnReturn: waitOnReturn = True
		Dim windowStyle: windowStyle = 0
		Dim Command 
		Dim rc
		Dim objFileToRead

'		msgbox """" & " 55"

'		Command = puplayer.getroot&"\" & cGameName & "\sToken.exe " & tmpUUID & " " & tmpVendor & " " &  tmpSerial & " " & MachineID & " " & QRFile & " " & sTokenFile & " " & domain
	'	debug.print "RUN sToken"
		Command = """" & TablesDir & "\sToken.exe"" " & tmpUUID & " " & tmpVendor & " " &  tmpSerial & " " & MachineID & " """ & QRFile & """ """ & sTokenFile & """ " & domain
'msgbox "RUNNING:" & Command
		rc = wsh.Run(Command, windowStyle, waitOnReturn)
'msgbox "Return:" & rc
'		if FileExists(puplayer.getroot&"\" & cGameName & "\sToken.dat") and rc=0 then
'		msgbox """" & TablesDir & "\sToken.dat"""
		if FileExists(TablesDir & "\sToken.dat") and rc=0 then
'			Set objFileToRead = fso.OpenTextFile(puplayer.getroot&"\" & cGameName & "\sToken.dat",1)
'			msgbox """" & TablesDir & "\sToken.dat"""
			Set objFileToRead = fso.OpenTextFile(TablesDir & "\sToken.dat",1)
			result = objFileToRead.ReadLine()
			objFileToRead.Close
			Set objFileToRead = Nothing
'msgbox result

			if Instr(1, result, "Invalid timestamp")<> 0 then 
				MsgBox "Scorbit Timestamp Error: Please make sure the time on your system is exact"
				getStoken=False
			elseif Instr(1, result, "Internal Server error")<> 0 then 
				MsgBox "Scorbit Internal Server error ??"
				getStoken=False
			elseif Instr(1, result, ":")<>0 then 
				results=split(result, ":")
				sToken=results(1)
				sToken=mid(sToken, 3, len(sToken)-4)
'Debug.print "Got TOKEN:" & sToken
				getStoken=True
			Else 
'Debug.print "ERROR:" & result
				getStoken=False
			End if 
		else 
'msgbox "ERROR No File:" & rc
		End if 

	End Function 

	private Function FileExists(FilePath)
		If fso.FileExists(FilePath) Then
			FileExists=CBool(1)
		Else
			FileExists=CBool(0)
		End If
	End Function

	Private Function GetMsg(URLBase, endpoint)
		GetMsg = GetMsgHdr(URLBase, endpoint, "", "")
	End Function

	Private Function GetMsgHdr(URLBase, endpoint, Hdr1, Hdr1Val)
		Dim Url
		Url = URLBase + endpoint & "?session_active=" & bActive
'Debug.print "Url:" & Url  & "  Async=" & bRunAsynch
		objXmlHttpMain.open "GET", Url, bRunAsynch
'		objXmlHttpMain.setRequestHeader "Content-Type", "text/xml"
		objXmlHttpMain.setRequestHeader "Cache-Control", "no-cache"
		if Hdr1<> "" then objXmlHttpMain.setRequestHeader Hdr1, Hdr1Val

'		on error resume next
			err.clear
			objXmlHttpMain.send ""
			if err.number=-2147012867 then 
				MsgBox "Multiplayer Server is down (" & err.number & ") " & Err.Description
				bEnabled=False
			elseif err.number <> 0 then 
				debug.print "Server error: (" & err.number & ") " & Err.Description
			End if 
			if bRunAsynch=False then 
			    Debug.print "Status: " & objXmlHttpMain.status
			    If objXmlHttpMain.status = 200 Then
				    GetMsgHdr = objXmlHttpMain.responseText
				Else 
				    GetMsgHdr=""
			    End if 
			Else 
				bWaitResp=True
				GetMsgHdr=""
			End if 
'		On error goto 0

	End Function

	Private Function PostMsg(URLBase, endpoint, PostData, bAsynch)
		Dim Url

		Url = URLBase + endpoint
'debug.print "PostMSg:" & Url & " " & PostData

		objXmlHttpMain.open "POST",Url, bAsynch
		objXmlHttpMain.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
		objXmlHttpMain.setRequestHeader "Content-Length", Len(PostData)
		objXmlHttpMain.setRequestHeader "Cache-Control", "no-cache"
		objXmlHttpMain.setRequestHeader "Authorization", "SToken " & sToken
		if bAsynch then bWaitResp=True 

		on error resume next
			objXmlHttpMain.send PostData
			if err.number=-2147012867 then 
				MsgBox "Multiplayer Server is down (" & err.number & ") " & Err.Description
				bEnabled=False
			elseif err.number <> 0 then 
				'debug.print "Multiplayer Server error (" & err.number & ") " & Err.Description
			End if 
			If objXmlHttpMain.status = 200 Then
				PostMsg = objXmlHttpMain.responseText
			else 
				PostMsg="ERROR: " & objXmlHttpMain.status & " >" & objXmlHttpMain.responseText & "<"
			End if 
		On error goto 0
	End Function

	Private Function pvPostFile(sUrl, sFileName, bAsync)
'Debug.print "Posting File " & sUrl & " " & sFileName & " " & bAsync & " File:" & Mid(sFileName, InStrRev(sFileName, "\") + 1)
		Dim STR_BOUNDARY:STR_BOUNDARY  = GUID()
		Dim nFile  
		Dim baBuffer()
		Dim sPostData
		Dim Response

		'--- read file
		Set nFile = fso.GetFile(sFileName)
		With nFile.OpenAsTextStream()
			sPostData = .Read(nFile.Size)
			.Close
		End With
'		fso.Open sFileName For Binary Access Read As nFile
'		If LOF(nFile) > 0 Then
'			ReDim baBuffer(0 To LOF(nFile) - 1) As Byte
'			Get nFile, , baBuffer
'			sPostData = StrConv(baBuffer, vbUnicode)
'		End If
'		Close nFile

		'--- prepare body
		sPostData = "--" & STR_BOUNDARY & vbCrLf & _
			"Content-Disposition: form-data; name=""uuid""" & vbCrLf & vbCrLf & _
			SessionUUID & vbcrlf & _
			"--" & STR_BOUNDARY & vbCrLf & _
			"Content-Disposition: form-data; name=""log_file""; filename=""" & SessionUUID & ".csv""" & vbCrLf & _
			"Content-Type: application/octet-stream" & vbCrLf & vbCrLf & _
			sPostData & vbCrLf & _
			"--" & STR_BOUNDARY & "--"

'Debug.print "POSTDATA: " & sPostData & vbcrlf

		'--- post
		With objXmlHttpMain
			.Open "POST", sUrl, bAsync
			.SetRequestHeader "Content-Type", "multipart/form-data; boundary=" & STR_BOUNDARY
			.SetRequestHeader "Authorization", "SToken " & sToken
			.Send sPostData ' pvToByteArray(sPostData)
			If Not bAsync Then
				Response= .ResponseText
				pvPostFile = Response
'Debug.print "Upload Response: " & Response
			End If
		End With

	End Function

	Private Function pvToByteArray(sText)
		pvToByteArray = StrConv(sText, 128)		' vbFromUnicode
	End Function

End Class 
'  END SCORBIT 
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


Sub StartScorbit
	If IsNull(Scorbit) Then
		If ScorbitActive = 1 then 
			ScorbitExesCheck ' Check the exe's are in the tables folder.
			If ScorbitActive = 1 then ' check again as the check exes may have disabled scorbit
				Set Scorbit = New ScorbitIF
				If Scorbit.DoInit(4193, "MEGADETH", myVersion, "megadeth-vpin") then 	' Prod
					tmrScorbit.Interval=2000
					tmrScorbit.UserValue = 0
					tmrScorbit.Enabled=True 
					Scorbit.UploadLog = 1
				End If 
			End If
		End If
	End If
End Sub

''QRView support by iaakki
Function GetTablesFolder()
    Dim GTF
    Set GTF = CreateObject("Scripting.FileSystemObject")
    GetTablesFolder= GTF.GetParentFolderName(userdirectory) & "\Tables"
    set GTF = nothing 
End Function

' Checks that all needed binaries are available in correct place..
Sub ScorbitExesCheck
	dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")

	If fso.FileExists(TablesDir & "\sToken.exe") then
'		msgbox "Stoken.exe found at: " & TablesDir & "\sToken.exe"
	else
		msgbox "Stoken.exe NOT found at: " & TablesDir & "\sToken.exe Disabling Scorbit for now."
		Scorbitactive = 0
		SaveValue cGameName, "SCORBIT", ScorbitActive
	end if

	If fso.FileExists(TablesDir & "\sQRCode.exe") then
'		msgbox "sQRCode.exe found at: " & TablesDir & "\sQRCode.exe"
	else
		msgbox "sQRCode.exe NOT found at: " & TablesDir & "\sQRCode.exe Disabling Scorbit for now."
		Scorbitactive = 0
		SaveValue cGameName, "SCORBIT", ScorbitActive
	end if
end sub




'******************
'AOR MiniGame code start



sub ShowPick

PrimitivePick1.visible = True
PrimitivePick2.visible = True
PrimitivePick3.visible = True
PrimitivePick4.visible = True
PrimitivePick5.visible = True
TrgPick1.enabled = True
trgpick2.enabled = True
trgpick3.enabled = True
TrgPick4.enabled = True
TrgPick5.enabled = True
kickerMG.enabled = True

TmrRotatePick.enabled = true

end Sub



sub HidePick

PrimitivePick1.visible = False
PrimitivePick2.visible = False
PrimitivePick3.visible = False
PrimitivePick4.visible = False
PrimitivePick5.visible = False
TrgPick1.enabled = False
trgpick2.enabled = False
trgpick3.enabled = False
TrgPick4.enabled = False
TrgPick5.enabled = False
kickerMG.enabled = False

TmrRotatePick.enabled = false

end Sub



'*********************************************MINIGAME*****************************************
'AOR Added
	Dim PuPMiniGameExe    'notice two \\ cuz of json
    Dim PuPMiniGameTitle 
    Dim PuPMiniGameScore 'PuPMiniGameScore="\MiniGame1\score.txt"      'no need to two \\ not json 



	PuPMiniGameExe  ="MiniGame0\\AORPupBeatGameStdView.exe"  'notice two \\ cuz of json
	PuPMiniGameTitle="AORPupBeatGameStdView"
	PuPMiniGameScore="\MiniGame0\Score.txt"      'no need to two \\ not json 




'AORPupBeatGameStdView

Sub AlwaysOnTop(appName, regExpTitle, setOnTop)
			' @description: Makes a window always on top if setOnTop is true, else makes it normal again. Will wait up to 10 seconds for window to load.
			' @author: Jeremy England (SimplyCoded)
			  If (setOnTop) Then setOnTop = "-1" Else setOnTop = "-2"
			  CreateObject("wscript.shell").Run "powershell -Command """ & _    
				"$Code = Add-Type -MemberDefinition '" & vbcrlf & _
				"  [DllImport(\""user32.dll\"")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X,int Y, int cx, int cy, uint uFlags);" & vbcrlf & _
				"  [DllImport(\""user32.dll\"")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);" & vbcrlf & _
				"  public static void AlwaysOnTop (IntPtr fHandle, int insertAfter) {" & vbcrlf & _
				"    if (insertAfter == -1) { ShowWindow(fHandle, 4); }" & vbcrlf & _
				"    SetWindowPos(fHandle, new IntPtr(insertAfter), 0, 0, 0, 0, 3);" & vbcrlf & _
				"  }' -Name PS -PassThru" & vbcrlf & _
				"for ($s=0;$s -le 9; $s++){$hWnd = (GPS " & appName & " -EA 0 | ? {$_.MainWindowTitle -Match '" & regExpTitle & "'}).MainWindowHandle;Start-Sleep 1;if ($hWnd){break}}" & vbcrlf & _  
				"$Code::AlwaysOnTop($hWnd, " & setOnTop & ")""", 0, True
			End Sub


		DIM PuPGameRunning:PuPGameRunning=false
		DIM PuPGameTimeout
		DIM PuPGameInfo
		DIM PuPGameScore
		Dim inminigame
		

		sub startminigame
		'PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 13, ""FN"":3, ""OT"": 0 }"      'this will hide overlay if applicable
		PupGameStartMiniGame
		end sub
		

		Sub PuPGameStartMiniGame
			'DOF 155, DOFoff 'Turn off Orange Undercab
			'DOF 153, DOFon 'start Superman Logo during mini game
			if PuPGameRunning Then Exit Sub
			


			if PupScreenMiniGame = 2 Then
		
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 2, ""FN"":16, ""EX"": """&PuPMiniGameExe  &""", ""WT"": """&PuPMiniGameTitle&""", ""RS"":1 , ""TO"":15 , ""WZ"":0 , ""SH"": 1 , ""FT"":""Visual Pinball Player"" }" 
			AlwaysOnTop PuPMiniGameTitle, ".", True
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 2, ""FN"":3, ""OT"": 0 }"    '  'AOR, enable this line if using screen 2this will hide overlay if applicable
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 12, ""FN"":3, ""OT"": 0 }"   'AOR, this will hide when no B2s and pup on screen 2 (13 custom pos reference)

			PuPGameTimeout=0'-3    'check for timeout  every 500 ms
			PuPGameRunning=true	
			PuPGameTimer.enabled=true
			PuPlayer.playpause 2
			PuPlayer.playpause 12
			End If

			If PupScreenMiniGame = 5 Then
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 5, ""FN"":16, ""EX"": """&PuPMiniGameExe  &""", ""WT"": """&PuPMiniGameTitle&""", ""RS"":1 , ""TO"":15 , ""WZ"":0 , ""SH"": 1 , ""FT"":""Visual Pinball Player"" }" 
			AlwaysOnTop PuPMiniGameTitle, ".", True
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 11, ""FN"":3, ""OT"": 0 }"    '  'AOR, enable this line if using screen 5this will hide overlay if applicable
			PuPGameTimeout=0'-3    'check for timeout  every 500 ms
			PuPGameRunning=true	
			PuPGameTimer.enabled=true
			Puplayer.playpause 5
			PuPlayer.playpause 12
			End If





			
		End Sub


		dim miniend:miniend=0
		Sub PuPMiniGameEnd(gamescore)
			miniend=1
			
			if PuPGameRunning Then Exit Sub
			inminigame = 0 ': pupevent 992
		
				
			AddScore(PuPGameScore)

		End Sub

		Sub PuPGameTimer_Timer()  'AOR, need to add a timer to the table, 300 milliseconds, Enabled unchecked  



			PuPGameTimeout=PuPGameTimeout+1
			if PuPGameTimeout = 3 then 
							
			End if
			
			PuPGameInfo= PuPlayer.GameUpdate(PuPMiniGameTitle, 0 , 0 , "") '0=game over, 1=game running
			'CHECK GAME OVER
			if PuPGameInfo=0 AND PuPGameTimeOut>12 Then  'gameover if more than 5 seconds passed
			   PuPGameTimer.enabled=false 
			 	PupGameRunning=False
			   '	PuPGameScore= PuPlayer.GameUpdate(PuPMiniGameTitle, 6 , 0 , "\MiniGame0\Score.txt")   'grab score from minigame   3=gms 6=godot 
				PuPGameScore= PuPlayer.GameUpdate(PuPMiniGameTitle, 6 , 0 , PuPMiniGameScore)   'grab score from minigame
			   'msgbox PuPGameScore  'DO something with the score if its over 0!!!
			   PuPMiniGameEnd(PuPGameScore)  

			
			
	
			
			If PupScreenMiniGame = 2 Then
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 2, ""FN"":3, ""OT"": 1 }"  'AOR, enable this line if using screen 2
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 12, ""FN"":3, ""OT"": 1 }"   'AOR, this will hide when no B2s and pup on screen 2 (13 custom pos reference)
			PuPlayer.playresume 2
			PuPlayer.playresume 12

			end If
	
			
			If PupScreenMiniGame = 5 Then
			PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 11, ""FN"":3, ""OT"": 1 }"  'AOR, enable this line if using screen 5
			PuPlayer.playresume 12
			Puplayer.playresume 5
			end If
		
			kickermg.kick 90,4
			kickermg.enabled = False 'turn it off, was relaunching minigame on next ramp hit
			iMiniGameCnt(CurrentPlayer) = iMiniGameCnt(CurrentPlayer) + 1	
			End If 

		

		End Sub





Sub TmrRotatePick_Timer()

	PrimitivePick1.roty = PrimitivePick1.roty + 1
	PrimitivePick2.roty = PrimitivePick2.roty - 1
	PrimitivePick3.roty = PrimitivePick3.roty + 1
	PrimitivePick4.roty = PrimitivePick4.roty - 1
	PrimitivePick5.roty = PrimitivePick5.roty + 1
End Sub

Sub TrgPick1_Hit()
	PrimitivePick1.visible = False
End Sub

Sub TrgPick2_Hit()
		PrimitivePick2.visible = False
End Sub

Sub kickerMG_Hit()
	startminigame
End Sub

Sub TrgPick3_Hit()
	PrimitivePick3.visible = False
End Sub

Sub TrgPick4_Hit()
	PrimitivePick4.visible = False
End Sub

Sub TrgPick5_Hit()
	PrimitivePick5.visible = False
End Sub

''''AOR Minigame code End