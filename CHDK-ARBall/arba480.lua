--[[
arch reactor balloon script v5
Authors: Arch Reactor Hackerspace (Jamie Bilinski, Derek Sigler, Eric Geldmacher, Ryan Castanho)
Project URL: https://archreactor.org/project/weather-balloon-summer-2011
Tested on: A480 (Digic 3)

Uses propcase lib
]]
--[[
@title ArchReactor Balloon Script
@param t Min Sec Delay between images
@default t 10
@param j Number of JPEGs/cycle
@default j 10
@param d Number of Raw/cycle
@default d 1
@param e EV Bracketing delta/6
@default e 4
[[--]]
param l est low alt mins
default l 45
param h high alt time mins
default h 110
param r est reenty time min
default r 185
]]
propcase=require("propcase")
h=((t-1)*1000)+930 --adjust for write time
if h < 9000 then w=9000-h else w=1 end --process delay ms after RAW shot
play_sound(4)

function flashoff()
	set_prop(142,2) --no flash
	while not get_prop(142) == 2 do
		press("right")
		release("right")
		sleep(100)
	end
	return true
end

function setfocuslock()
	set_prop(6,3) --infinity
	while not get_prop(6) == 3 do
		press("left")
		release("left")
	end
	press("shoot_half")
	sleep(2000)
	set_aflock(1)
	release("shoot_half")
	return true
end

function snapraws()
	set_raw(1)
	for i=1,d do 
		press("shoot_half")
		repeat
			sleep(100)
		until get_shooting() == true
		press("shoot_full")
		release("shoot_full")
		release("shoot_half")
		sleep(w)
		sleep(h)
	end
	set_raw(0)
	return true
end
function snapjpgs()
	for i=1,j do 
		press("shoot_half")
		repeat
			sleep(100)
		until get_shooting() == true
		press("shoot_full")
		release("shoot_full")
		release("shoot_half")
		sleep(h)
	end
	return true
end

function snapevbrac()
	evi=get_ev()
	for i=1,e do
		if (evi-(i*32)) < 1 then set_ev(1) else set_ev(evi-(i*32)) end --may need in certain light?
		press("shoot_half")
		repeat
			sleep(100)
		until get_shooting() == true
		press("shoot_full")
		release("shoot_full")
		release("shoot_half")
		sleep(1200)
		set_ev(evi+(i*32))
		press("shoot_half")
		repeat
			sleep(100)
		until get_shooting() == true
		press("shoot_full")
		release("shoot_full")
		release("shoot_half")
		sleep(1200)
	end
	set_ev(evi)
	sleep(h)
end

--[[ Maybe next time!
function logtemp()
print get_temperature(0)
print get_temperature(1)
print get_temperature(2)
end
]]

--MAIN
click("shoot_half") --in case A480 is in play mode
flashoff()
sleep(500)
setfocuslock()
sleep(500)
repeat
	snapjpgs()
	snapraws()
	snapevbrac()
	play_sound(4) --beep each cycle so we know it's running
until false
sleep(1)
reboot() --meh catch