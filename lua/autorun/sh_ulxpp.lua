
--Not running in ULX folder because it does not being loaded using VLL
if SERVER then
	AddCSLuaFile('ulxpp/sh_init.lua')
end

timer.Simple(0, function()
	include('ulxpp/sh_init.lua')
end)
