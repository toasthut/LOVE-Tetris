---@class AudioManager: Object
---@field sfx table<string, love.Source>
local AudioManager = Object:extend()
local AUDIO_DIR = "asset/audio/"

AudioManager.mainVolume = 0.8

local function newSource(src, vol, srcType)
	srcType = srcType or "static"
	local sound = love.audio.newSource(AUDIO_DIR .. src, srcType)
	sound:setVolume(vol)
	return sound
end

AudioManager.sfx = {
	xAxisMove = newSource("blip3.wav", 1.0),
	rotate = newSource("blip3_2.wav", 0.7),
	softDrop = newSource("blip4.wav", 0.8),
	hardDrop = newSource("clap3.wav", 0.55),
	touchGround = newSource("click2.wav", 0.8),
	holdPiece = newSource("clup2.wav", 0.8),
	lineClear = newSource("splode2.wav", 0.4),
	nextLevel = newSource("levelup1.wav", 0.8),
	twist = newSource("basket1.wav", 1.0),
}

function AudioManager.volumeUp(n)
	AudioManager.mainVolume = math.min(1, AudioManager.mainVolume + n)
	love.audio.setVolume(AudioManager.mainVolume)
end

function AudioManager.volumeDown(n)
	AudioManager.mainVolume = math.max(0, AudioManager.mainVolume - n)
	love.audio.setVolume(AudioManager.mainVolume)
end

function AudioManager.updateMainVolume(vol)
	AudioManager.mainVolume = math.max(math.min(1, vol), 0)
	for _, v in AudioManager.sfx do
		v:setVolume()
	end
end

return AudioManager
