Scriptname UITextEntryMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.textEntry." autoReadonly

string _internalString = ""
string _internalResult = ""
int _isSkyrimVR = -1

bool property IsSkyrimVR
	bool function get()
		if _isSkyrimVR == -1 ; We haven't checked yet!
			_isSkyrimVR = (Game.GetModByName("SkyrimVR.esm") != 255) as int
		endIf
		return _isSkyrimVR
	endFunction
endProperty

string Function GetMenuName()
	return "UITextEntryMenu"
EndFunction

string Function GetResultString()
	return _internalResult
EndFunction

Function SetPropertyString(string propertyName, string value)
	If propertyName == "text"
		_internalString = value
	Endif
EndFunction

Function ResetMenu()
	isResetting = true
	_internalString = ""
	_internalResult = ""
	isResetting = false
EndFunction

int Function OpenMenu(Form inForm = None, Form akReceiver = None)
	_internalResult = ""

	if ! IsSkyrimVR
		If !BlockUntilClosed() || !WaitForReset()
			return 0
		Endif

		RegisterForModEvent("UITextEntryMenu_LoadMenu", "OnLoadMenu")
		RegisterForModEvent("UITextEntryMenu_CloseMenu", "OnUnloadMenu")
		RegisterForModEvent("UITextEntryMenu_TextChanged", "OnTextChanged")

		Lock()
	endIf

	if IsSkyrimVR
		_internalResult = VRKeyboard.GetKeyboardInput(_internalString)
		return 0
	else
		UI.OpenCustomMenu("textentrymenu")
	endIf

	if ! IsSkyrimVR
		If !WaitLock()
			return 0
		Endif
		return 1
	endIf
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
	UpdateTextEntryString()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
	if ! IsSkyrimVR
		UnregisterForModEvent("UITextEntryMenu_LoadMenu")
		UnregisterForModEvent("UITextEntryMenu_CloseMenu")
		UnregisterForModEvent("UITextEntryMenu_TextChanged")
	endIf
EndEvent

Event OnTextChanged(string eventName, string strArg, float numArg, Form formArg)
	_internalResult = strArg
	Unlock()
EndEvent

Function UpdateTextEntryString()
	if ! IsSkyrimVR
		UI.InvokeString(ROOT_MENU, MENU_ROOT + "setTextEntryMenuText", _internalString)
	endIf
EndFunction
