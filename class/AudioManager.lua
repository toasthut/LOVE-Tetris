---@class AudioManager: Object
local AudioManager = Object:extend()
local AUDIO_DIR = "asset/audio/"

AudioManager.mainVolume = 0.6
AudioManager.sfx = {}
AudioManager.sfxDef = {
	xMove = { src = "blip3.wav", vol = 1.0 },
	rotate = { src = "blip3_2.wav", vol = 0.7 },
	softDrop = { src = "blip4.wav", vol = 0.8 },
	hardDrop = { src = "smash3.wav", vol = 0.55 },
	touchGround = { src = "click2.wav", vol = 0.8 },
	holdPiece = { src = "clup2.wav", vol = 0.8 },
}

for k, v in pairs(AudioManager.sfxDef) do
	AudioManager.sfx[k] = love.audio.newSource(AUDIO_DIR .. v.src, "static")
	AudioManager.sfx[k]:setVolume(v.vol)
end

return AudioManager
