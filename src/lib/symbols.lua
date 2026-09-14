-- Ashgard/CCTweaked character helpers.
--
-- `glyph` keeps every byte addressable by its hexadecimal value.  The named
-- fields below are intentionally semantic aliases for the useful UI glyphs.
-- Add aliases as your launcher grows; this module does not try to assign an
-- unreliable meaning to every decorative character in the monitor font.

---@alias GlyphCode string

---@class GlyphTable
---@field [GlyphCode] string
local glyph = {
  ["00"] = "\x00", ["01"] = "\x01", ["02"] = "\x02", ["03"] = "\x03",
  ["04"] = "\x04", ["05"] = "\x05", ["06"] = "\x06", ["07"] = "\x07",
  ["08"] = "\x08", ["09"] = "\x09", ["0A"] = "\x0A", ["0B"] = "\x0B",
  ["0C"] = "\x0C", ["0D"] = "\x0D", ["0E"] = "\x0E", ["0F"] = "\x0F",
  ["10"] = "\x10", ["11"] = "\x11", ["12"] = "\x12", ["13"] = "\x13",
  ["14"] = "\x14", ["15"] = "\x15", ["16"] = "\x16", ["17"] = "\x17",
  ["18"] = "\x18", ["19"] = "\x19", ["1A"] = "\x1A", ["1B"] = "\x1B",
  ["1C"] = "\x1C", ["1D"] = "\x1D", ["1E"] = "\x1E", ["1F"] = "\x1F",

  ["20"] = "\x20", ["21"] = "\x21", ["22"] = "\x22", ["23"] = "\x23",
  ["24"] = "\x24", ["25"] = "\x25", ["26"] = "\x26", ["27"] = "\x27",
  ["28"] = "\x28", ["29"] = "\x29", ["2A"] = "\x2A", ["2B"] = "\x2B",
  ["2C"] = "\x2C", ["2D"] = "\x2D", ["2E"] = "\x2E", ["2F"] = "\x2F",
  ["30"] = "\x30", ["31"] = "\x31", ["32"] = "\x32", ["33"] = "\x33",
  ["34"] = "\x34", ["35"] = "\x35", ["36"] = "\x36", ["37"] = "\x37",
  ["38"] = "\x38", ["39"] = "\x39", ["3A"] = "\x3A", ["3B"] = "\x3B",
  ["3C"] = "\x3C", ["3D"] = "\x3D", ["3E"] = "\x3E", ["3F"] = "\x3F",

  ["40"] = "\x40", ["41"] = "\x41", ["42"] = "\x42", ["43"] = "\x43",
  ["44"] = "\x44", ["45"] = "\x45", ["46"] = "\x46", ["47"] = "\x47",
  ["48"] = "\x48", ["49"] = "\x49", ["4A"] = "\x4A", ["4B"] = "\x4B",
  ["4C"] = "\x4C", ["4D"] = "\x4D", ["4E"] = "\x4E", ["4F"] = "\x4F",
  ["50"] = "\x50", ["51"] = "\x51", ["52"] = "\x52", ["53"] = "\x53",
  ["54"] = "\x54", ["55"] = "\x55", ["56"] = "\x56", ["57"] = "\x57",
  ["58"] = "\x58", ["59"] = "\x59", ["5A"] = "\x5A", ["5B"] = "\x5B",
  ["5C"] = "\x5C", ["5D"] = "\x5D", ["5E"] = "\x5E", ["5F"] = "\x5F",

  ["60"] = "\x60", ["61"] = "\x61", ["62"] = "\x62", ["63"] = "\x63",
  ["64"] = "\x64", ["65"] = "\x65", ["66"] = "\x66", ["67"] = "\x67",
  ["68"] = "\x68", ["69"] = "\x69", ["6A"] = "\x6A", ["6B"] = "\x6B",
  ["6C"] = "\x6C", ["6D"] = "\x6D", ["6E"] = "\x6E", ["6F"] = "\x6F",
  ["70"] = "\x70", ["71"] = "\x71", ["72"] = "\x72", ["73"] = "\x73",
  ["74"] = "\x74", ["75"] = "\x75", ["76"] = "\x76", ["77"] = "\x77",
  ["78"] = "\x78", ["79"] = "\x79", ["7A"] = "\x7A", ["7B"] = "\x7B",
  ["7C"] = "\x7C", ["7D"] = "\x7D", ["7E"] = "\x7E", ["7F"] = "\x7F",

  ["80"] = "\x80", ["81"] = "\x81", ["82"] = "\x82", ["83"] = "\x83",
  ["84"] = "\x84", ["85"] = "\x85", ["86"] = "\x86", ["87"] = "\x87",
  ["88"] = "\x88", ["89"] = "\x89", ["8A"] = "\x8A", ["8B"] = "\x8B",
  ["8C"] = "\x8C", ["8D"] = "\x8D", ["8E"] = "\x8E", ["8F"] = "\x8F",
  ["90"] = "\x90", ["91"] = "\x91", ["92"] = "\x92", ["93"] = "\x93",
  ["94"] = "\x94", ["95"] = "\x95", ["96"] = "\x96", ["97"] = "\x97",
  ["98"] = "\x98", ["99"] = "\x99", ["9A"] = "\x9A", ["9B"] = "\x9B",
  ["9C"] = "\x9C", ["9D"] = "\x9D", ["9E"] = "\x9E", ["9F"] = "\x9F",

  ["A0"] = "\xA0", ["A1"] = "\xA1", ["A2"] = "\xA2", ["A3"] = "\xA3",
  ["A4"] = "\xA4", ["A5"] = "\xA5", ["A6"] = "\xA6", ["A7"] = "\xA7",
  ["A8"] = "\xA8", ["A9"] = "\xA9", ["AA"] = "\xAA", ["AB"] = "\xAB",
  ["AC"] = "\xAC", ["AD"] = "\xAD", ["AE"] = "\xAE", ["AF"] = "\xAF",
  ["B0"] = "\xB0", ["B1"] = "\xB1", ["B2"] = "\xB2", ["B3"] = "\xB3",
  ["B4"] = "\xB4", ["B5"] = "\xB5", ["B6"] = "\xB6", ["B7"] = "\xB7",
  ["B8"] = "\xB8", ["B9"] = "\xB9", ["BA"] = "\xBA", ["BB"] = "\xBB",
  ["BC"] = "\xBC", ["BD"] = "\xBD", ["BE"] = "\xBE", ["BF"] = "\xBF",

  ["C0"] = "\xC0", ["C1"] = "\xC1", ["C2"] = "\xC2", ["C3"] = "\xC3",
  ["C4"] = "\xC4", ["C5"] = "\xC5", ["C6"] = "\xC6", ["C7"] = "\xC7",
  ["C8"] = "\xC8", ["C9"] = "\xC9", ["CA"] = "\xCA", ["CB"] = "\xCB",
  ["CC"] = "\xCC", ["CD"] = "\xCD", ["CE"] = "\xCE", ["CF"] = "\xCF",
  ["D0"] = "\xD0", ["D1"] = "\xD1", ["D2"] = "\xD2", ["D3"] = "\xD3",
  ["D4"] = "\xD4", ["D5"] = "\xD5", ["D6"] = "\xD6", ["D7"] = "\xD7",
  ["D8"] = "\xD8", ["D9"] = "\xD9", ["DA"] = "\xDA", ["DB"] = "\xDB",
  ["DC"] = "\xDC", ["DD"] = "\xDD", ["DE"] = "\xDE", ["DF"] = "\xDF",

  ["E0"] = "\xE0", ["E1"] = "\xE1", ["E2"] = "\xE2", ["E3"] = "\xE3",
  ["E4"] = "\xE4", ["E5"] = "\xE5", ["E6"] = "\xE6", ["E7"] = "\xE7",
  ["E8"] = "\xE8", ["E9"] = "\xE9", ["EA"] = "\xEA", ["EB"] = "\xEB",
  ["EC"] = "\xEC", ["ED"] = "\xED", ["EE"] = "\xEE", ["EF"] = "\xEF",
  ["F0"] = "\xF0", ["F1"] = "\xF1", ["F2"] = "\xF2", ["F3"] = "\xF3",
  ["F4"] = "\xF4", ["F5"] = "\xF5", ["F6"] = "\xF6", ["F7"] = "\xF7",
  ["F8"] = "\xF8", ["F9"] = "\xF9", ["FA"] = "\xFA", ["FB"] = "\xFB",
  ["FC"] = "\xFC", ["FD"] = "\xFD", ["FE"] = "\xFE", ["FF"] = "\xFF",
}

---@class Symbols
---@field glyph GlyphTable
---@field code GlyphTable
---@field [string] string|GlyphTable
local symbols = {
  glyph = glyph,
  code = glyph, -- Shorter spelling for: symbols.code["95"]

  -- ASCII punctuation
  space = glyph["20"], exclamation = glyph["21"], quote = glyph["22"],
  hash = glyph["23"], dollar = glyph["24"], percent = glyph["25"],
  ampersand = glyph["26"], apostrophe = glyph["27"], leftParen = glyph["28"],
  rightParen = glyph["29"], asterisk = glyph["2A"], plus = glyph["2B"],
  comma = glyph["2C"], minus = glyph["2D"], period = glyph["2E"], slash = glyph["2F"],
  colon = glyph["3A"], semicolon = glyph["3B"], lessThan = glyph["3C"],
  equals = glyph["3D"], greaterThan = glyph["3E"], question = glyph["3F"],
  at = glyph["40"], leftBracket = glyph["5B"], backslash = glyph["5C"],
  rightBracket = glyph["5D"], caret = glyph["5E"], underscore = glyph["5F"],
  backtick = glyph["60"], leftBrace = glyph["7B"], pipe = glyph["7C"],
  rightBrace = glyph["7D"], tilde = glyph["7E"],

  -- UI-friendly aliases visible in the supplied monitor character sheet.
  -- This is the divider glyph you chose for the launcher tab bar.
  separator = glyph["95"],
  solid = glyph["DB"],
  checkerboard = glyph["B0"],
  filledCircle = glyph["07"],
  filledDiamond = glyph["04"],
  leftArrow = glyph["1B"],
  rightArrow = glyph["1A"],
  upArrow = glyph["18"],
  downArrow = glyph["19"],
}

-- CP437-derived names. These are the glyphs normally useful for terminal UI.
-- Box-drawing names describe the line direction from the cell's centre.
symbols.smile = glyph["01"]
symbols.inverseSmile = glyph["02"]
symbols.heart = glyph["03"]
symbols.diamond = glyph["04"]
symbols.club = glyph["05"]
symbols.spade = glyph["06"]
symbols.bullet = glyph["07"]
symbols.inverseBullet = glyph["08"]
symbols.circle = glyph["09"]
symbols.inverseCircle = glyph["0A"]
symbols.male = glyph["0B"]
symbols.female = glyph["0C"]
symbols.note = glyph["0D"]
symbols.beamedNotes = glyph["0E"]
symbols.sun = glyph["0F"]
symbols.rightTriangle = glyph["10"]
symbols.leftTriangle = glyph["11"]
symbols.upDownArrow = glyph["12"]
symbols.doubleExclamation = glyph["13"]
symbols.paragraph = glyph["14"]
symbols.section = glyph["15"]
symbols.thickHorizontal = glyph["16"]
symbols.upDownBaseArrow = glyph["17"]
symbols.rightAngle = glyph["1C"]
symbols.leftRightArrow = glyph["1D"]
symbols.upTriangle = glyph["1E"]
symbols.downTriangle = glyph["1F"]
symbols.home = glyph["7F"]

symbols.lightShade = glyph["B0"]
symbols.mediumShade = glyph["B1"]
symbols.darkShade = glyph["B2"]
symbols.vertical = glyph["95"]
symbols.teeLeft = glyph["B4"]
symbols.doubleTeeLeft = glyph["B5"]
symbols.doubleVerticalTeeLeft = glyph["B6"]
symbols.doubleTopRight = glyph["B7"]
symbols.topRightDouble = glyph["B8"]
symbols.doubleTeeRight = glyph["B9"]
symbols.doubleVertical = glyph["BA"]
symbols.doubleTopRightCorner = glyph["BB"]
symbols.doubleBottomRightCorner = glyph["BC"]
symbols.doubleBottomLeftCorner = glyph["BD"]
symbols.bottomLeftDouble = glyph["BE"]
symbols.topRight = glyph["94"]
symbols.bottomLeft = glyph["8A"]
symbols.teeUp = glyph["C1"]
symbols.teeDown = glyph["C2"]
symbols.teeRight = glyph["C3"]
symbols.horizontal = glyph["83"]
symbols.horizontalBottom = glyph["8F"]
symbols.cross = glyph["C5"]
symbols.doubleTeeRight = glyph["C6"]
symbols.verticalDoubleTeeRight = glyph["C7"]
symbols.doubleBottomLeftCorner = glyph["C8"]
symbols.doubleTopLeftCorner = glyph["C9"]
symbols.doubleTeeUp = glyph["CA"]
symbols.doubleTeeDown = glyph["CB"]
symbols.doubleCross = glyph["CC"]
symbols.doubleHorizontal = glyph["CD"]
symbols.doubleCrossMixed = glyph["CE"]
symbols.doubleTeeUpMixed = glyph["CF"]
symbols.doubleTeeDownMixed = glyph["D0"]
symbols.doubleTeeLeftMixed = glyph["D1"]
symbols.doubleTeeRightMixed = glyph["D2"]
symbols.bottomLeftMixed = glyph["D3"]
symbols.topLeftMixed = glyph["D4"]
symbols.topRightMixed = glyph["D5"]
symbols.bottomRightMixed = glyph["D6"]
symbols.crossMixed = glyph["D7"]
symbols.crossDoubleMixed = glyph["D8"]
symbols.bottomRight = glyph["85"]
symbols.topLeft = glyph["97"]
symbols.fullBlock = glyph["DB"]
symbols.lowerHalfBlock = glyph["DC"]
symbols.leftHalfBlock = glyph["DD"]
symbols.rightHalfBlock = glyph["DE"]
symbols.upperHalfBlock = glyph["DF"]

symbols.alpha = glyph["E0"]
symbols.beta = glyph["E1"]
symbols.gamma = glyph["E2"]
symbols.pi = glyph["E3"]
symbols.sigma = glyph["E4"]
symbols.mu = glyph["E6"]
symbols.tau = glyph["E7"]
symbols.phi = glyph["E8"]
symbols.theta = glyph["E9"]
symbols.omega = glyph["EA"]
symbols.delta = glyph["EB"]
symbols.infinity = glyph["EC"]
symbols.emptySet = glyph["ED"]
symbols.intersection = glyph["EE"]
symbols.identical = glyph["F0"]
symbols.plusMinus = glyph["F1"]
symbols.greaterOrEqual = glyph["F2"]
symbols.lessOrEqual = glyph["F3"]
symbols.topIntegral = glyph["F4"]
symbols.bottomIntegral = glyph["F5"]
symbols.divide = glyph["F6"]
symbols.approximately = glyph["F7"]
symbols.degree = glyph["F8"]
symbols.centerDot = glyph["F9"]
symbols.middleDot = glyph["FA"]
symbols.squareRoot = glyph["FB"]
symbols.superscriptN = glyph["FC"]
symbols.superscript2 = glyph["FD"]
symbols.smallSquare = glyph["FE"]
symbols.nonBreakingSpace = glyph["FF"]

-- Common casing/spelling alternatives, so UI code stays pleasant to write.
symbols.left_arrow = symbols.leftArrow
symbols.right_arrow = symbols.rightArrow
symbols.up_arrow = symbols.upArrow
symbols.down_arrow = symbols.downArrow

---@return Symbols
return symbols
