texts = {
    ["job_start"] = {
        "Azt hittem már sosem kezdesz el dolgozni...",
        "Mellesleg üdvözöllek!",
        "Itt is vannak azok a címek amikre ki kell vinned az újságokat.",
        "Jó munkát és siess az újságokkal. Ne várakoztasd meg a vásárlókat!",
    },
}

text_wait = 75

core = exports.oCore
color, r, g, b = core:getServerColor()
cmarker = exports.oCustomMarker
font = exports.oFont
interface = exports.oInterface
inventory = exports.oInventory
chat = exports.oChat

newspaperPeds = {
	--{x,y,z,rot}

    -- RÉGI LS POZÍCIÓK
    --[[{1680.0622558594, -1803.6507568359, 13.546875,272},
    {1847.546875, -1867.9010009766, 13.578125,90},
    {1704.1154785156, -1578.5863037109, 13.887386322021,265},
    {1648.5522460938, -1494.0837402344, 13.546875,271},
    {1387.708984375, -1439.5122070313, 13.5546875,269},
    {1323.7789306641, -1431.6600341797, 14.973952293396,268},
    {1347.8419189453, -1501.3662109375, 13.546875,68},
    {985.64587402344,-1094.5541992188,27.604057312012,180.41175842285},
    {1094.0174560547,-1095.2745361328,25.388429641724,92.027565002441},
    {1872.1954345703,-1911.7877197266,15.256797790527,177.27638244629},
    {1937.2568359375,-1914.9548339844,15.025835037231,167.12596130371},
    {2067.88671875,-1731.5682373047,13.87615776062,259.05709838867},
    {2064.9926757813,-1583.3614501953,13.480756759644,178.48489379883},
    {1905.8656005859,-1113.1341552734,26.6640625,178.08207702637},
    {2000.1666259766,-1114.5738525391,27.125,180.09638977051},
    {2095.3576660156,-1145.1489257813,26.592920303345,93.078346252441},
    {2220.5510253906,-1083.404296875,41.7734375,36.677867889404},
    {2233.2580566406,-1159.3651123047,29.804386138916,82.604057312012},
    {2233.1767578125,-1159.6081542969,25.890625,71.569152832031},
    {2093.5805664063,-1047.1889648438,30.105804443359,139.65267944336},
    {2091.5634765625,-1068.111328125,28.029359817505,325.37155151367},
    {1291.8017578125,-902.79705810547,46.6328125,100.57518768311},
    {1283.5418701172,-897.90728759766,42.8828125,283.87689208984},
    {1288.1535644531,-873.72271728516,43.070701599121,98.560882568359},
    {1280.0407714844,-868.59246826172,42.922660827637,279.04257202148},
    {1287.4001464844,-867.53723144531,46.836074829102,86.475082397461},
    {1187.4385986328,-1233.0646972656,18.5546875,89.294967651367},
    {1179.8127441406,-1227.2915039063,18.5546875,277.83389282227},
    {784.93792724609,-1435.9010009766,13.546875,267.20184326172},
    {771.2958984375,-1510.9644775391,13.546875,242.78500366211},
    {305.30047607422,-1770.2175292969,4.5382046699524,174.29864501953},
    {207.1622467041,-1769.8415527344,4.3547787666321,98.80167388916},
    {168.19178771973,-1768.744140625,4.4816060066223,195.24737548828},
    {227.89538574219,-1405.400390625,51.609375,329.64532470703},
    {352.10165405273,-1197.4324951172,76.515625,45.225551605225},
    {470.87335205078,-1163.7049560547,67.216842651367,187.27777099609},
    {558.99096679688,-1160.9597167969,54.4296875,17.673303604126},
    {553.41369628906,-1200.0916748047,44.831535339355,21.701940536499},
    {700.33697509766,-1060.1970214844,49.421691894531,57.959373474121},
    {827.82098388672,-857.98132324219,70.330810546875,193.7234954834},
    {1016.8851318359,-763.35925292969,112.56301879883,352.69589233398},
    {1332.6008300781,-633.33447265625,109.1349029541,22.910394668579},
    {1527.6402587891,-772.40155029297,80.578125,132.08564758301},
    {1540.4689941406,-851.42895507813,64.336059570313,88.576705932617},
    {2465.232421875,-2020.7857666016,14.124163627625,357.12719726563},
    -- Innentől Írtam én, Blöki
    {1322.0650634766, -1818.5686035156, 13.546875, 90},
    {935.34558105469, -1613.0012207031, 14.943160057068, 180},
    {928.31463623047, -1352.7717285156, 13.34375, 90},
    {1163.3065185547, -1585.1090087891, 13.546875, 45},
    {1631.6903076172, -1172.9300537109, 24.084280014038, 0},
    {1045.2463378906, -642.92364501953, 120.1171875, 0},
    {2148.6197265625, -1319.9806884766, 26.073816299438, 0},
    {773.14886474609, -1794.4554443359, 13.0234375, 0},
    {667.19232177734, -1770.1260742188, 13.6328125, 0},
    {499.39071655273, -1360.3806884766, 16.369091033936, 0},
    {462.82281494141, -1623.7492675781, 26.09375, 90},
    {2435.6921386719, -1922.7009277344, 13.546875, 180},
    {2736.6374511719, -1952.6283691406, 13.546875, 90},
    {2507.2505371094, -1724.6240234375, 13.546875, 180},
    {2353.1054199219, -1484.8943847656, 24, 90},
    {2389.7272949219, -1345.953125, 25.076972961426, 90},
    {2387.8549804688, -1328.4860107422, 25.124164581299, 90},
    {2433.6235351563, -1274.8770751953, 24.756660461426, 270},
    {2628.10546875, -1067.8083496094, 69.71558380127, 270},
    {2687.4624023438, -1435.6181640625, 30.524265289307, 90},]]


    --V2 POZÍCIÓK
    -- RED COUNTY
    {819.96276855469,-509.31942749023,18.012922286987,180},
    {745.67370605469,-589.18859863281,18.012922286987,90},
    {691.15832519531,-506.40005493164,16.3359375,90},
    {745.10272216797,-509.33447265625,18.012922286987,180},
    {742.88836669922,-556.74920654297,18.012926101685,0},
    {764.67218017578,-556.78210449219,18.012924194336,0},
    {624.88806152344,-506.31753540039,16.352542877197,90},
    {293.34130859375,-195.52935791016,1.7786192893982,90},
    {252.88710021973,-94.20783996582,3.5353941917419,90},
    {176.84576416016,-120.2325668335,1.5497300624847,360},
    {158.63507080078,-101.12567138672,1.5567119121552,270},
    {166.09280395508,-118.23192596436,4.8964710235596,360},
    {201.13702392578,-118.23218536377,4.8964710235596,360},
    {201.8794708252,-96.973678588867,4.8964710235596,180},
    {293.91973876953,-52.81343460083,2.078125,90},
    {312.72256469727,-92.166275024414,3.5353934764862,270},
    {1295.3659667969,174.4426574707,20.910556793213,65},
    {1283.2276611328,158.7494354248,20.793369293213,283},
    {1307.5411376953,153.31301879883,20.394714355469,250},
    {1306.2235107422,148.94030761719,20.353355407715,254},
    {1311.7600097656,171.34576416016,20.4609375,250},
    {1300.5262451172,192.61170959473,20.4609375,204},
    {1302.47265625,305.31158447266,19.5546875,240},
    {1301.8754882812,385.65335083008,19.562463760376,157},
    {1475.1599121094,372.80093383789,19.65625,334},
    {1469.5715332031,351.66146850586,18.930149078369,114},
    {1461.1320800781,342.48321533203,18.953125,203},
    {1415.6560058594,324.77114868164,18.84375,141},
    {1403.1704101562,333.94247436523,18.90625,118},
    {805.02307128906,358.38314819336,19.762119293213,355},
    {807.849609375,372.75573730469,19.336708068848,84},
    {788.48712158203,375.46951293945,21.196260452271,330},
    {751.86505126953,375.44790649414,23.238012313843,286},
    {746.36779785156,305.177734375,20.234375,280},
    {719.03979492188,300.7873840332,20.37656211853,91},
    {748.076171875,257.08724975586,27.0859375,9},
    {2238.4006347656,168.33731079102,28.153549194336,180},
    {2285.7224121094,161.76985168457,28.44164276123,180},
    {2323.8549804688,116.61995697021,28.44164276123,270},
    {2374.0590820312,42.434741973877,28.441644668579,270},
    {2412.2458496094,59.766231536865,27.84375,180},
    {2411.2209472656,24.892469406128,27.683460235596,90},
    {2412.7028808594,-4.4286942481995,26.984375,0},
    {2390.5942382812,-54.962474822998,28.153551101685,360},
    {2482.6979980469,-27.731689453125,28.44164276123,270},
    {2557.0122070312,88.148529052734,27.675645828247,90},
    {2551.2199707031,91.923881530762,27.675647735596,90},
    {2512.8647460938,135.99043273926,27.675645828247,90},

    -- LS GAZDAGNEGYED
    {875.47601318359,-968.63507080078,37.1875,300},
    {807.23333740234,-1033.1602783203,24.935203552246,202},
    {1245.3649902344,-902.56488037109,42.8828125,277},
    {1252.8605957031,-901.64038085938,46.593887329102,97},
    {1245.5662841797,-902.61950683594,46.593887329102,273},
    {1253.6657714844,-907.76745605469,46.6015625,101},
    {1249.5639648438,-876.93493652344,46.640625,95},
    {1280.8405761719,-874.69000244141,42.93924331665,282},
    {1283.5280761719,-897.78515625,42.875343322754,275},
    {1291.8317871094,-902.99957275391,42.8828125,90},
    {1283.5220947266,-897.75152587891,46.625137329102,276},
    {1291.8587646484,-903.21636962891,46.6328125,97},
    {1183.0347900391,-960.14691162109,42.894214630127,12},
    {1238.6911621094,-952.25201416016,42.677219390869,353},
}

bossPed = {
    pos = Vector3(2458.5856933594,-38.792484283447,26.751962661743),
}

newspapers = {
    {"The News", 5, 312},
    {"Original News", 10, 375},
    {"Los Santos Post", 6, 325},
    {"Star News", 7, 337},
    {"Global News", 10, 375},
    {"San Andreas Mirror", 15, 500},
}

ped_names = {
	[1] = {"John","James","Aron","Santiago","Edward","Jhonathan","Lucas","Sebastian","Frank","Roger","Tony","Chris","Jason","Jack","David","Steve","Trevor","Ethan","Matthew","Marshall","Gregory","Lester","Thomas","Hill","Taylor","Carlos"},
	[2] = {"Lara","Laura","Ashlay","Natasha","Linda","Stella","Lisa","Alyssa","Doris","Emilee","Hannah","Marisa"}
}

ped_skins = {
	[1] = {1,2,15,20,21,22,23,24,26,28,29,30,32,34,35,36,37,43,44,46,47,48,49,58,59,67,72,90,94,95,96,100,101,111,147,177,183}, --férfi
	[2] = {7,9,10,12,13,14,17,19,25,38,40,41,53,54,56,69,76,89,91,130,131,141,148,151,232,233}, --női
}