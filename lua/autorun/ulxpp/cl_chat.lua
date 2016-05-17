
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

--Because of how ULib is made
--I can not provide anything better for autocomplete in chat
--I just CAN'T EVEN UNDERTSAND ULib!

local ENABLE = CreateConVar('ulx_autocomplete', '1', FCVAR_ARCHIVE, 'Enable chat autocomplete')

local ShouldDraw = false

local function StartChat()
	if not ENABLE:GetBool() then return end
	ShouldDraw = true
end

local function FinishChat()
	if not ENABLE:GetBool() then return end
	ShouldDraw = false
end

local Drawn = {}

local function ChatTextChanged(str)
	if not ENABLE:GetBool() then return end
	local token = str[1]
	Drawn = {}
	if token ~= '/' and token ~= '!' then return end
	
	local split = string.Explode(' ', str)
	local find = string.sub(split[1], 2)
	local len = #find
	
	local Found = {}
	
	for k, data in pairs(ulx.cmdsByCategory) do
		for i, obj in pairs(data) do
			if not obj.say_cmd then continue end
			if string.sub(ULXPP.UnpackCommand(obj.cmd), 1, len) == find then table.insert(Found, obj) end
		end
	end
	
	Drawn[1] = 'ULX Chat Commands:'
	
	local ply = LocalPlayer()
	local total = 0
	for k, v in pairs(Found) do
		local access = ULib.ucl.query(ply, v.cmd)
		if not access then continue end
		
		if total > 10 then
			table.insert(Drawn, '<...>')
			break
		end
		
		local format = token .. ULXPP.UnpackCommand(v.cmd) .. ' ' .. v:getUsage(ply)
		if table.HasValue(Drawn, format) then continue end --eh
		total = total + 1
		
		table.insert(Drawn, format)
	end
	
	if total == 0 then
		Drawn[1] = 'No ULX command match.'
	elseif total == 1 then
		Drawn[1] = 'ULX Chat Command, to paste all missed arguments press TAB.'
	end
end

surface.CreateFont('ULXPP.Autocomplete', {
	font = 'Roboto',
	size = 18,
	weight = 500,
	extended = true,
})

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not ShouldDraw then return end
	
	local x, y = chat.GetChatBoxPos()
	local w, h = chat.GetChatBoxSize()
	
	x = x + w + 3
	y = y - 20
	
	surface.SetFont('ULXPP.Autocomplete')
	
	for k, v in pairs(Drawn) do
		local w, h = surface.GetTextSize(v)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.SetTextColor(255, 255, 255)
		surface.DrawRect(x - 3, y - 2, w + 6, h + 4)
		surface.SetTextPos(x, y)
		surface.DrawText(v)
		y = y + h + 8
	end
end

local function OnChatTab(str)
	if not ENABLE:GetBool() then return end
	if not ShouldDraw then return end
	if #Drawn == 0 then return end
	if #Drawn == 1 then return end
	if #Drawn > 3 then return end
	
	local command = Drawn[2]
	local split1 = string.Explode(' ', str)
	local split2 = string.Explode(' ', command)
	
	local output = str
	
	for k, v in pairs(split2) do
		if v == '-' then break end --We hit help end
		if split1[k] then continue end
		output = output .. ' ' .. v
	end
	
	return output
end

hook.Add('StartChat', 'ULXPP.Autocomplete', StartChat)
hook.Add('FinishChat', 'ULXPP.Autocomplete', FinishChat)
hook.Add('ChatTextChanged', 'ULXPP.Autocomplete', ChatTextChanged)
hook.Add('HUDPaint', 'ULXPP.Autocomplete', HUDPaint)
hook.Add('OnChatTab', 'ULXPP.Autocomplete', OnChatTab)
