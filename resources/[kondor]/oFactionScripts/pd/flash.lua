local screenX, screenY = guiGetScreenSize()

local damageShader = false
local screenSource = false

local impactHandled = false
local impactTick = 0

local heartSound = false
local tinnitusSound = false

local effectDuration = 10000
local blurStrength = effectDuration / 45
local colorFadeValue = 1
local impactSoundVolume = 1

addEventHandler("onClientExplosion", getRootElement(),
  function (targetX, targetY, targetZ, explosionType)
    if explosionType == 0 then
      --if getElementData(source, "flashbangInUse") then
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 40 then
          if isLineOfSightClear(playerX, playerY, playerZ, targetX, targetY, targetZ, true, true, false, true, true, false, false, localPlayer) then
            if not impactHandled then
              damageShader = dxCreateShader("files/damage.fx")
              screenSource = dxCreateScreenSource(screenX, screenY)

              addEventHandler("onClientRender", getRootElement(), renderTheFlashEffect, true, "low-999999999")
            end

            impactHandled = true
            impactTick = getTickCount()

            blurStrength = effectDuration / 45
            colorFadeValue = 1
            impactSoundVolume = 1

            if isElement(heartSound) then
              destroyElement(heartSound)
            end

            if isElement(tinnitusSound) then
              destroyElement(tinnitusSound)
            end

            heartSound = playSound("files/heartbeat.ogg", true)
            tinnitusSound = playSound("files/tinnitus.ogg", false)
          end
        end

        cancelEvent()
      --end
    end

    if explosionType ~= 0 and explosionType ~= 1 and explosionType ~= 7 and explosionType ~= 2 then
      outputDebugString("cancel explosion, type: " .. tostring(explosionType))
      cancelEvent()
    end
  end
)

function renderTheFlashEffect()
  if impactTick > 0 and getTickCount() >= impactTick then
    local progress = (getTickCount() - impactTick) / effectDuration

    dxUpdateScreenSource(screenSource, true)

    blurStrength = (effectDuration / 45) * (1 - progress)

    if blurStrength <= 0 then
      blurStrength = 0
    end

    colorFadeValue = 1 - progress
    impactSoundVolume = 1 - progress

    if impactSoundVolume <= 0 then
      impactSoundVolume = 0

      if isElement(tinnitusSound) then
        stopSound(tinnitusSound)
      end
    end

    if isElement(tinnitusSound) then
      setSoundVolume(tinnitusSound, impactSoundVolume * 3)
    end

    if isElement(heartSound) then
      setSoundVolume(heartSound, impactSoundVolume)
    end

    dxSetShaderValue(damageShader, "screenSource", screenSource)
    dxSetShaderValue(damageShader, "blurStrength", blurStrength)
    dxSetShaderValue(damageShader, "colorFadeValue", colorFadeValue)

    dxDrawImage(0, 0, screenX, screenY, damageShader)
    dxDrawRectangle(0, 0, screenX, screenY, tocolor(255, 255, 255, 255 * (1 - progress)))

    if progress >= 1 then
      impactTick = 0
    end
  else
    if impactHandled then
      removeEventHandler("onClientRender", getRootElement(), renderTheFlashEffect)

      if isElement(damageShader) then
        destroyElement(damageShader)
      end

      if isElement(screenSource) then
        destroyElement(screenSource)
      end

      screenSource = nil
      damageShader = nil
    end

    impactHandled = false
    return
  end
end
