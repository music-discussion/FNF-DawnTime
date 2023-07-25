function onCreate()

	makeLuaSprite('Base', 'streetlmao',-410,-100)
	addLuaSprite('Base',false)
	setLuaSpriteScrollFactor('Base', 1, 1)
        scaleObject('Base', 0.9, 0.9);

	makeLuaSprite('l', 'light',0,-100)
	addLuaSprite('l',true)
	setLuaSpriteScrollFactor('l', 1, 1)
        scaleObject('l', 0.9, 0.9);

	


	makeLuaSprite('hud', 'hud',500,-135)
	addLuaSprite('hud',true)
	setLuaSpriteScrollFactor('hud', 0, 0)
        scaleObject('hud', 1, 1);

end