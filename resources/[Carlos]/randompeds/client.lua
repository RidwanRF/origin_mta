peds = {
    {656.83648681641,-560.95147705078,16.3359375, 351, 114, "GHANDS", "gsign4"},
    {657.27888183594,-557.71124267578,16.3359375, 87, 113, "GANGS", "leanIDLE"},


    {664.62316894531,-566.82110595703,16.3359375, 180, 306, "GHANDS", "gsign3"},
    {664.53106689453,-568.60925292969,16.3359375, 0, 7, "", ""},
    {667.79553222656,-572.427734375,16.3359375, 90, 41, "COP_AMBIENT", "Coplook_loop"},

    {1947.4696044922, 998.32263183594, 992.46875, 360, 7, "GHANDS", "gsign5"},
    {1947.41015625, 999.10095214844, 992.46875, 180, 16, "GHANDS", "gsign2"},
}

for k, v in ipairs(peds) do 
    local ped = createPed(v[5], v[1], v[2], v[3], v[4])

    setPedAnimation(ped, v[6], v[7], -1, true, false)
end