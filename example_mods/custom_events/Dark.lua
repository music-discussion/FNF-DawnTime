function onCreate()
	makeLuaSprite('Darkness', '', 0, 0)
	makeGraphic('Darkness', 1280, 720, '000000')
	addLuaSprite('Darkness', true)
	setObjectCamera('Darkness', 'other')
	setProperty('Darkness.alpha', 0)
end

function onEvent(name, value1, value2)
    if name == "Dark" then
		if value1 == 'true' then
			doTweenAlpha('Darkish', 'Darkness', 0.5, 0.3)
		elseif value1 == 'false' then
			setProperty('Darkness.alpha', 0)
			cameraFlash('hud', 'ffffff', 1)
		end
	end
end