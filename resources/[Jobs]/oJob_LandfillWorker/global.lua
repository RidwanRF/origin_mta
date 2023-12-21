core = exports.oCore
interface = exports.oInterface
customM = exports.oCustomMarker
bone = exports.oBone
chat = exports.oChat
infobox = exports.oInfobox

color, r, g, b = core:getServerColor()

text_wait = 10 -- default : 75

bossPed = {
    pos = Vector3(2198.9182128906, -1973.2685546875, 13.558145523071),
    rot = 181,
    skin = 291,
}

texts = {
    ["job_start"] = {
        "Üdvözöllek! Jókor jöttél, ugyanis sok most a munka itt a telepen.",
        "Szükségünk van minnél több munkásra, mert Los Santosban csak egyre több a szemét.",
        "Jelenleg is választhatsz a három munka közül. (Szemétrakodó, Szemétválogató, Kukás)",
    },

    ["job_select_1"] = {
        "Jól választottál! Nagyon sok feldolgozott szemét van már, amit fel kell rakodni a kamionokra!", 
        "A konténer mellett fel tudod venni a tangorncádat.",
        "Ha azzal megvagy, akkor csak menj a szemétdombhoz és hord a szemetet a kamionok rakterébe.",
        "Jó munkát!",
    },

    ["job_select_2"] = {
        "Jól választottál! Nagyon sok szétválogatandó szemét van már a telepen, amit szét kellene válogatni!", 
        "A konténerben tudsz felvenni üres szemeteszsákot.",
        "Ha felvetted akkor, menj a szemétdombhoz és töltsd meg a szemeteszsákodat vegyes szeméttel.",
        "Ha teletöltötted a zsákot, akkor menj a válogatóasztalok valamelyikéhez és kezd el a válogatást!",
        "Jó munkát kívánok!",
    },

    ["job_select_3"] = {
        "Jól választottál! Nagyon sok kiürítendő kuka van Los Santosban!", 
        "A konténer mellett tudsz felvenni munkajárművet.",
        "Ha a munkajármű megvan, akkor keress teli kukákat a városban és ürítsd ki.",
        "Amikor a kocsid megtelik, akkor gyere vissza a telepre és ürítsd ki a járművet, a szemétfeldolgozó gépnél!",
        "Jó munkát és balesetmentes közlekedést kívánok!",
    },
}

jobs = {
    "Szemétrakodó",
    "Szemétválogató",
    "Kukás",
}

----/Szemétválogató/----
trashObjects = {
    -- object id, z+
    {id = 2670, Zplus = 0},
    {id = 2671, Zplus = 0},
    {id = 2672, Zplus = 0},
    {id = 2673, Zplus = 0},
    {id = 2674, Zplus = 0},
    {id = 2675, Zplus = 0},
    {id = 2676, Zplus = 0},
    {id = 2677, Zplus = 0},
    {id = 2840, Zplus = 0},
    {id = 2866, Zplus = 0},
    {id = 2860, Zplus = 0},
    {id = 2647, Zplus = 0},
    {id = 2059, Zplus = 0},
}

trashObjectPositions = {
    Vector3(2179.8190917969, -1989.8232421875, 13.549618721008),
    Vector3(2187.9377441406, -2001.5437011719, 13.546875),
    Vector3(2186.8681640625, -2000.5314941406, 13.546875),
    Vector3(2191.4995117188, -2004.4200439453, 13.546875),
    Vector3(2196.4924316406, -2007.1379394531, 13.608011245728),
    Vector3(2199.3920898438, -2011.4176025391, 13.593532562256),
    Vector3(2200.9533691406, -2016.5574951172, 13.546875),
    Vector3(2200.5927734375, -2020.8479003906, 13.650413513184),
    Vector3(2193.5202636719, -2018.5815429688, 15.734014511108),
    Vector3(2192.3869628906, -2014.7877197266, 16.185510635376),
    Vector3(2185.8330078125, -1998.6580810547, 13.546875),
    Vector3(2171.8188476563, -1987.8970947266, 15.848602294922),
    Vector3(2163.7583007813, -1988.3781738281, 14.683835983276),
    Vector3(2163.1027832031, -1985.1697998047, 15.734014511108),
    Vector3(2162.0786132813, -1983.5965576172, 15.734014511108),
    Vector3(2160.8471679688, -1982.2508544922, 13.552757263184),
    Vector3(2163.3334960938, -1980.8270263672, 13.553364753723),
    Vector3(2166.5729980469, -1980.7214355469, 13.829957962036),
    Vector3(2157.0290527344, -1988.5822753906, 14.140153884888),
    Vector3(2155.6877441406, -1993.4691162109, 13.5546875),
    Vector3(2157.396484375, -1997.0426025391, 13.547856330872),
    Vector3(2156.1064453125, -1983.3090820313, 13.551599502563),
    Vector3(2161.3874511719, -1981.2763671875, 13.552889823914),
    Vector3(2160.3564453125, -1997.9184570313, 14.819707870483),
    Vector3(2166.1787109375, -2004.4241943359, 13.546875),
    Vector3(2163.9050292969, -2003.1809082031, 13.546875),
    Vector3(2167.4108886719, -2006.9730224609, 13.546875),
    Vector3(2170.2333984375, -2009.8876953125, 13.546875),
    Vector3(2172.8532714844, -2011.2406005859, 13.546875),
    Vector3(2174.998046875, -2013.1413574219, 13.546875),
}

containerPositions = {
    {Vector3(2201.9111328125, -2035.6434326172, 13.346875), -230}
}

collectAnimationTime = 10000 -- default: 15000

toggledControls = {"fire", "jump", "sprint"}

stripes = {
    {pos = Vector3(2559.1, -1300.5, 1044.125-0.95), rot = 2562},
    {pos = Vector3(2551.1, -1300.5, 1044.125-0.95), rot = 2562},
    {pos = Vector3(2543.05, -1300.5, 1044.125-0.95), rot = 2562},

    {pos = Vector3(2559.1, -1287.8, 1044.125-0.95), rot = 2562},
    {pos = Vector3(2551.1, -1287.8, 1044.125-0.95), rot = 2562},
    {pos = Vector3(2543.05, -1287.8, 1044.125-0.95), rot = 2562},
}