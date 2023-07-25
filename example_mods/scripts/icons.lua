local cpuplay = true

function onCreate()
	makeLuaText('bot', '', 512, 10, 650)
	addLuaText('bot')
	setTextAlignment('bot', 'left')
	if dadName == 'v-rage' then
		makeAnimatedLuaSprite('animatedicon', 'icons/icon_four', getProperty('iconP2.x'), getProperty('iconP2.y'))
		addAnimationByPrefix('animatedicon', 'normal', 'four icon0', 24, true)
		addAnimationByPrefix('animatedicon', 'losing', 'four icon losing', 24, true)
		addAnimationByPrefix('animatedicon', 'winning', 'four icon winning', 24, true)
		setScrollFactor('animatedicon', 0, 0)
		setObjectCamera('animatedicon', 'other')
		addLuaSprite('animatedicon', true)
		setObjectOrder('animatedicon', 99)
		objectPlayAnimation('animatedicon', 'normal', false)
		makeAnimatedLuaSprite('animatedicon2', 'icons/bf', getProperty('iconP1.x'), getProperty('iconP1.y'))
		addAnimationByPrefix('animatedicon2', 'normal', 'BF0000', 24, true)
		addAnimationByPrefix('animatedicon2', 'losing', 'BF Losig', 24, true)
		addAnimationByPrefix('animatedicon2', 'winning', 'BF Winig', 24, true)
		setScrollFactor('animatedicon2', 0, 0)
		setObjectCamera('animatedicon2', 'other')
		addLuaSprite('animatedicon2', true)
		setObjectOrder('animatedicon2', 99)
		objectPlayAnimation('animatedicon2', 'normal', false)
	end
end

function onUpdate(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.T') == true then
        setProperty('timeTxt.visible', false)
        setProperty('timeBar.visible', false)
        setProperty('timeBarBG.visible', false)
        setProperty('healthBar.visible', false)
        setProperty('healthBarBG.visible', false)
        setProperty('iconP1.visible', false)
        setProperty('iconP2.visible', false)
        setProperty('scoreTxt.visible', false)
	elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.Y') == true then
        setProperty('timeTxt.visible', true)
        setProperty('timeBar.visible', true)
        setProperty('timeBarBG.visible', true)
        setProperty('healthBar.visible', true)
        setProperty('healthBarBG.visible', true)
        setProperty('iconP1.visible', true)
        setProperty('iconP2.visible', true)
        setProperty('scoreTxt.visible', true)
	end
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.P') and cpuplay then
		if getProperty('cpuControlled') then
			setProperty('cpuControlled', false)
			setTextString('bot', 'BOTPLAY OFF')
		else
			setProperty('cpuControlled', true)
			setTextString('bot', 'BOTPLAY ON')
		end
	end
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.G') then
		setProperty('health', getProperty('health') - 0.1) 
	end
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.H') then
		setProperty('health', getProperty('health') + 0.1) 
	end
	if dadName == 'v-rage' then
		setProperty('iconP2.alpha', 0)
		setProperty('iconP1.alpha', 0)
		if getProperty('health') > 1.6 then
			objectPlayAnimation('animatedicon', 'losing', false)
			objectPlayAnimation('animatedicon2', 'winning', false)
		elseif getProperty('health') < 0.4 then
			objectPlayAnimation('animatedicon', 'winning', false)
			objectPlayAnimation('animatedicon2', 'losing', false)
		else
			objectPlayAnimation('animatedicon', 'normal', false)
			objectPlayAnimation('animatedicon2', 'normal', false)
		end
	end
	setProperty('camOther.zoom', getProperty('camHUD.zoom'))
	setProperty('animatedicon.x', getProperty('iconP2.x'))
	setProperty('animatedicon.angle', getProperty('iconP2.angle'))
	setProperty('animatedicon.y', getProperty('iconP2.y') + 15)
	setProperty('animatedicon.scale.x', getProperty('iconP2.scale.x'))
	setProperty('animatedicon.scale.y', getProperty('iconP2.scale.y'))
	setProperty('camOther.zoom', getProperty('camHUD.zoom'))
	setProperty('animatedicon2.x', getProperty('iconP1.x'))
	setProperty('animatedicon2.angle', getProperty('iconP1.angle'))
	setProperty('animatedicon2.y', getProperty('iconP1.y') + 15)
	setProperty('animatedicon2.scale.x', getProperty('iconP1.scale.x'))
	setProperty('animatedicon2.scale.y', getProperty('iconP1.scale.y'))
	--[[
	for i=0,4,1 do
		setPropertyFromGroup('opponentStrums', i, 'texture', 'NOTE_assets_3D')
		--setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets_3D')
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets_3D'); --Change texture
		end
	end
	]]
end