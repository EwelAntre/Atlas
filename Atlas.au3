#cs ----------------------------------------------------------------------------
	Collection of Helpfull Functions for Guild Wars Bots
#ce ----------------------------------------------------------------------------

#include "GWA2.au3"
#include <Array.au3>

Global $atlasName

Func InitializeAtlas($aName)
	$atlasName = $aName
EndFunc

Func UseSkillEx($aSkillSlot,$aTarget, $aCoolDown  = 1000, $aUseCoolDown = False)
	$tDeadlock = TimerInit()
	UseSkill($aSkillSlot, $aTarget)
	If $aUseCoolDown = False Then
		Do
			Sleep(250)
			If GetIsDead(-2) = 1 Then Return
		Until GetSkillBarSkillRecharge($aSkillSlot) <> 0 Or TimerDiff($tDeadlock) > 15000
	Else
		Do
			Sleep(250)
			If GetIsDead(-2) = 1 Then Return
		Until TimerDiff($tDeadlock) >= $aUseCoolDown And GetIsCasting(-2) = False
	EndIF
	PingSleep(400)
EndFunc

Func WaitForMapLoad($aTargetMapID , $aTravel = False , $aMaxTime = 120000)

	Local $lTimerStart
	Local $lTimerLoad

	If Not $aTravel Then

		$lTimerStart = TimerInit()

		While GetMapLoading() <> 2 And TimerDiff($lTimerStart) < $aMaxTime
			Sleep(5)
		WEnd

		If TimerDiff($lTimerStart) > $aMaxTime And TimerDiff($lTimerStart) < $aMaxTime + 1000 Then
			Return False
		EndIf
	EndIf

	$lTimerLoad = TimerInit()


	While GetMapLoading() == 2 And TimerDiff($lTimerLoad) < $aMaxTime
		Sleep(5)
	WEnd


	If TimerDiff($lTimerLoad) > $aMaxTime And TimerDiff($lTimerLoad) < $aMaxTime + 1000 Then
		Return False
	EndIf

	If GetMapID() <> $aTargetMapID Then
		Return False
	EndIf

	Return True

EndFunc

Func WaitForTransition($maxTime = 30000)
	Local $lTimerStart = TimerInit()

	Do
		Sleep(10)
	Until GetIsMoving() = False or TimerDiff($lTimerStart) >= $maxTime
	Do
		Sleep(10)
	Until GetMapLoading() <> 2 or TimerDiff($lTimerStart) >= $maxTime
	if TimerDiff($lTimerStart) >= $maxTime Then
		return False
	Else
		return True
	EndIf

	EndFunc


Func WaitForLoad($aTravel = False , $aMaxTime = 120000)

	Local $lTimerStart
	Local $lTimerLoad

	If Not $aTravel Then

		$lTimerStart = TimerInit()

		While GetMapLoading() <> 2 And TimerDiff($lTimerStart) < $aMaxTime
			Sleep(5)
		WEnd

		If TimerDiff($lTimerStart) > $aMaxTime And TimerDiff($lTimerStart) < $aMaxTime + 1000 Then
			Return False
		EndIf
	EndIf

	$lTimerLoad = TimerInit()


	While GetMapLoading() == 2 And TimerDiff($lTimerLoad) < $aMaxTime
		Sleep(5)
	WEnd


	If TimerDiff($lTimerLoad) > $aMaxTime And TimerDiff($lTimerLoad) < $aMaxTime + 1000 Then
		Return False
	EndIf

	Return True

EndFunc

Func WaitForEnergy($aEnergy, $aMaxTime = 60000)
	local $aTimer = TimerInit()
	Do
		PingSleep(100)
		Until GetEnergy() >= $aEnergy or TimerDiff($aTimer) >= $aMaxTime
	If GetEnergy() >= $aEnergy Then
		Return True
	Else
		Return False
	EndIf
	EndFunc

Func PingSleep($time)
	Sleep($time + GetPing())
EndFunc

Func SendKey($akey)
	$GW_NAME = 'Guild Wars - ' & $atlasName
	ControlSend($GW_NAME, '', "", $aKey)
EndFunc

Func GetHealthProc($aAgent)
	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	Return DllStructGetData($aAgent,'HP')
	EndFunc

Func GetRechargeLeft($SkillNumber)
	return GetSkillbarSkillRecharge($SkillNumber,0)
EndFunc

Func GetAgentsInRangeByClass($range,$classID)
	$count = 0
	$aAgent = GetAgentByID(-2)
	For $i = 1 To GetMaxAgents()
		$cAgent = GetAgentByID($i)
		$lDistance = GetDistance($cAgent , $aAgent)
		If $lDistance > $range Then
			ContinueLoop
		EndIf
		If DllStructGetData($cAgent,'Primary') = $classID Then
			$count += 1
		EndIf
	Next
	Return $count
EndFunc

Func GetAgentsInRangeByWeaponType($range,$weaponType)
	$count = 0
	$aAgent = GetAgentByID(-2)
	For $i = 1 To GetMaxAgents()
		$cAgent = GetAgentByID($i)
		$lDistance = GetDistance($cAgent , $aAgent)
		If $lDistance > $range Then
			ContinueLoop
		EndIf
		If DllStructGetData($cAgent,'WeaponType') = $weaponType Then
			$count += 1
		EndIf
	Next
	Return $count
EndFunc

Func GetNumberOfFoesInRange($aRange = 1012)
	Local $tTarget
	Local $tID
	Local $tSelf

	$tSelf = GetAgentByID(-2)

	For $tID = 1 to GetMaxAgents()

		$tTarget = GetAgentByID($tID)

		If DllStructGetData($tTarget , "Type") <> 0xDB Then
			ContinueLoop
		EndIf

		If DllStructGetData($tTarget, 'Allegiance') <> 3 Then
			ContinueLoop
		EndIf

		If GetIsDead($tTarget) Then
			ContinueLoop
		EndIf

		If GetDistance($tTarget, $tSelf) <= $aRange Then
			Return True
		EndIf
	Next

	Return False
EndFunc

Func FindIDSetSlot()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	local $Slots[2] = [0,0]
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2989
					$slots[0] = $i
					$slots[1] = $j
					Return $slots
				Case 5899
					$slots[0] = $i
					$slots[1] = $j
					Return $slots
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return false
EndFunc

Func FindFreeChestSpace()
   local $Slot[2] = [1,1]
   For $i = 8 to 16
		if DllStructGetData(GetBag($i),'Slots') > 0 Then
			For $r = 1 to DllStructGetData(GetBag($i),'Slots')
				$item = GetitembySlot($i,$r)
				If DllStructGetData($item, 'ModelID') = 0 Then
				   $Slot[0] = $i
				   $Slot[1] = $r
					Return $Slot
				 EndIf
			Next
		EndIf
   Next
EndFunc

Func GoToChest()
	For $i = 1 To GetMaxAgents()
		$lAgentName = GetAgentName($i)
		If StringInStr($lAgentName,"Xunlai-Truhe") or StringInStr($lAgentName,"Xunlai Chest") or StringInStr($lAgentName,"Coffre Xunlai") Then
			GoToNPC(GetAgentByID($i))
			Return True
		Else
			ContinueLoop
		EndIf
	Next
	Return False
EndFunc


Func GoPickUpItem($aAgent)
	If GetDistance($aAgent) > 150 Then
		MoveTo(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
	EndIf
	PingSleep(10)
	PickUpItem($aAgent)
EndFunc

Func GetAngle($aX,$aY,$aAgent)
	$vecx = $aX - DllStructGetData($aAgent,'X')
	$vecy = $aY - DllStructGetData($aAgent,'Y')
	$alength = Sqrt($vecx^2+$vecy^2)
	$aXn = $vecx / $alength
	if $vecy >= 0 Then
		Return  -(ASin($aXn) - 3.1415 /2)
	Else
		Return (ASin($aXn) - 3.1415 /2)
	EndIf
	EndFunc

Func TurnToPos($aX,$aY, $random = .1)
	$angle = GetAngle($aX,$aY,GetAgentByID(-2))
	$rot = DllStructGetData(GetAgentByID(-2),'Rotation')

	if $rot > $angle and $rot < $angle + 3.1415 Then
		TurnRight(True)
	Else
		TurnLeft(True)
	EndIf
	Do
		Sleep(10)
		$rot = DllStructGetData(GetAgentByID(-2),'Rotation')
		Until Abs($rot - $angle ) < $random
	TurnRight(False)
	TurnLeft(False)
EndFunc

Func TurnFromPos($aX,$aY, $random = .1)
	$angle = GetAngle($aX,$aY,GetAgentByID(-2))
	if $angle >= 0 Then
		$angle = $angle - 3.1415
	Else
		$angle = $angle + 3.1415
	EndIf
	$rot = DllStructGetData(GetAgentByID(-2),'Rotation')
	if $rot > $angle and $rot < $angle + 3.1415 Then
		TurnRight(True)
	Else
		TurnLeft(True)
	EndIf
	Do
		Sleep(10)
		$rot = DllStructGetData(GetAgentByID(-2),'Rotation')
		Until Abs($rot - $angle ) < $random
	TurnRight(False)
	TurnLeft(False)
	EndFunc

Func GoBackwardsTo($aX,$aY,$aRandom = 50)
	Local $lBlocked = 0
	Local $lMe
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)
	TurnFromPos($aX,$aY,0.05)
	PingSleep(250)
	TurnLeft(True)
	Sleep(50)
	TurnLeft(False)
	TurnRight(True)
	Sleep(50)
	TurnRight(False)
	PingSleep(250)
	MoveBackward(True)
	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move($lDestX, $lDestY, 0)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 100 Or $lBlocked > 14

	MoveBackward(False)

EndFunc

;~ ################## Salvage Functions #######################

Func salvageMats($aItem,$aDelay = 400)
   StartSalvage($aItem)
   Sleep($aDelay+GetPing())
   If GetRarity($aItem) = 2626 or GetRarity($aItem) = 2624 Then
;~ 		SendKey('{ENTER}')
		SalvageMaterials()
   EndIf
EndFunc

;~ ################## Foes Identification Functions #######################

Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $fMaxDistance = 1012)
	Local $lDistance, $lCount = 0

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If GetIsDead($lAgentToCompare) <> 0 Then ContinueLoop
		If DllStructGetData($lAgentToCompare, 'Allegiance') = 0x3 Or DllStructGetData($lAgentToCompare, 'Type') = 0xDB Then
			$lDistance = GetDistance($lAgentToCompare, $aAgent)
			If $lDistance < $fMaxDistance Then
				$lCount += 1
			EndIf
		EndIf
	Next

	Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

;~ ################## Miscellanious Functions #######################

Func _StatusMsg($StringMsg)
	Local $WinCoords = WinGetPos(GetWindowHandle())
	If IsArray($WinCoords) Then
		ToolTip($StringMsg, $WinCoords[0] + 7, $WinCoords[1] + 25)
	Else
		ToolTip("")
	EndIf
EndFunc   ;==>_StatusMsg