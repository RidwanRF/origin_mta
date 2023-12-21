local terrainData = {
    3,3,3,3,
    3,0,0,3,
    3,0,0,3,
    3,3,3,3,
  }
  local terrainShape = physicsCreateShape(physics, "heightfieldterrain", 4,4, terrainData)
  local terrain = physicsCreateStaticCollision(terrainShape)
  physicsSetProperties(terrain, "position", 0,0,5)
  physicsSetProperties(terrain, "scale", 5,5,1) -- in terrain, sets mesh density, now mesh has size 20x20units, one vertex every 5 units