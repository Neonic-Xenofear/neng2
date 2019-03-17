module engine.core.input.keyboard;

/**
	Special Key:
	The strategy here is similar to the one used by toolkits,
	which consists in leaving the 24 bits unicode range for printable
	characters, and use the upper 8 bits for special keys and
	modifiers. This way everything (char/keycode) can fit nicely in one 32 bits unsigned integer.
*/
enum SPK = ( 1 << 24 );

enum EKeyboard {
	/* CURSOR/FUNCTION/BROWSER/MULTIMEDIA/MISC KEYS */
	K_ESCAPE = SPK | 0x01,
	K_TAB = SPK | 0x02,
	K_BACKTAB = SPK | 0x03,
	K_BACKSPACE = SPK | 0x04,
	K_ENTER = SPK | 0x05,
	K_KP_ENTER = SPK | 0x06,
	K_INSERT = SPK | 0x07,
	K_DELETE = SPK | 0x08,
	K_PAUSE = SPK | 0x09,
	K_PRINT = SPK | 0x0A,
	K_SYSREQ = SPK | 0x0B,
	K_CLEAR = SPK | 0x0C,
	K_HOME = SPK | 0x0D,
	K_END = SPK | 0x0E,
	K_LEFT = SPK | 0x0F,
	K_UP = SPK | 0x10,
	K_RIGHT = SPK | 0x11,
	K_DOWN = SPK | 0x12,
	K_PAGEUP = SPK | 0x13,
	K_PAGEDOWN = SPK | 0x14,
	K_SHIFT = SPK | 0x15,
	K_CONTROL = SPK | 0x16,
	K_META = SPK | 0x17,
	K_ALT = SPK | 0x18,
	K_CAPSLOCK = SPK | 0x19,
	K_NUMLOCK = SPK | 0x1A,
	K_SCROLLLOCK = SPK | 0x1B,
	K_F1 = SPK | 0x1C,
	K_F2 = SPK | 0x1D,
	K_F3 = SPK | 0x1E,
	K_F4 = SPK | 0x1F,
	K_F5 = SPK | 0x20,
	K_F6 = SPK | 0x21,
	K_F7 = SPK | 0x22,
	K_F8 = SPK | 0x23,
	K_F9 = SPK | 0x24,
	K_F10 = SPK | 0x25,
	K_F11 = SPK | 0x26,
	K_F12 = SPK | 0x27,
	K_F13 = SPK | 0x28,
	K_F14 = SPK | 0x29,
	K_F15 = SPK | 0x2A,
	K_F16 = SPK | 0x2B,
	K_KP_MULTIPLY = SPK | 0x81,
	K_KP_DIVIDE = SPK | 0x82,
	K_KP_SUBTRACT = SPK | 0x83,
	K_KP_PERIOD = SPK | 0x84,
	K_KP_ADD = SPK | 0x85,
	K_KP_0 = SPK | 0x86,
	K_KP_1 = SPK | 0x87,
	K_KP_2 = SPK | 0x88,
	K_KP_3 = SPK | 0x89,
	K_KP_4 = SPK | 0x8A,
	K_KP_5 = SPK | 0x8B,
	K_KP_6 = SPK | 0x8C,
	K_KP_7 = SPK | 0x8D,
	K_KP_8 = SPK | 0x8E,
	K_KP_9 = SPK | 0x8F,
	K_SUPER_L = SPK | 0x2C,
	K_SUPER_R = SPK | 0x2D,
	K_MENU = SPK | 0x2E,
	K_HYPER_L = SPK | 0x2F,
	K_HYPER_R = SPK | 0x30,
	K_HELP = SPK | 0x31,
	K_DIRECTION_L = SPK | 0x32,
	K_DIRECTION_R = SPK | 0x33,
	K_BACK = SPK | 0x40,
	K_FORWARD = SPK | 0x41,
	K_STOP = SPK | 0x42,
	K_REFRESH = SPK | 0x43,
	K_VOLUMEDOWN = SPK | 0x44,
	K_VOLUMEMUTE = SPK | 0x45,
	K_VOLUMEUP = SPK | 0x46,
	K_BASSBOOST = SPK | 0x47,
	K_BASSUP = SPK | 0x48,
	K_BASSDOWN = SPK | 0x49,
	K_TREBLEUP = SPK | 0x4A,
	K_TREBLEDOWN = SPK | 0x4B,
	K_MEDIAPLAY = SPK | 0x4C,
	K_MEDIASTOP = SPK | 0x4D,
	K_MEDIAPREVIOUS = SPK | 0x4E,
	K_MEDIANEXT = SPK | 0x4F,
	K_MEDIARECORD = SPK | 0x50,
	K_HOMEPAGE = SPK | 0x51,
	K_FAVORITES = SPK | 0x52,
	K_SEARCH = SPK | 0x53,
	K_STANDBY = SPK | 0x54,
	K_OPENURL = SPK | 0x55,
	K_LAUNCHMAIL = SPK | 0x56,
	K_LAUNCHMEDIA = SPK | 0x57,
	K_LAUNCH0 = SPK | 0x58,
	K_LAUNCH1 = SPK | 0x59,
	K_LAUNCH2 = SPK | 0x5A,
	K_LAUNCH3 = SPK | 0x5B,
	K_LAUNCH4 = SPK | 0x5C,
	K_LAUNCH5 = SPK | 0x5D,
	K_LAUNCH6 = SPK | 0x5E,
	K_LAUNCH7 = SPK | 0x5F,
	K_LAUNCH8 = SPK | 0x60,
	K_LAUNCH9 = SPK | 0x61,
	K_LAUNCHA = SPK | 0x62,
	K_LAUNCHB = SPK | 0x63,
	K_LAUNCHC = SPK | 0x64,
	K_LAUNCHD = SPK | 0x65,
	K_LAUNCHE = SPK | 0x66,
	K_LAUNCHF = SPK | 0x67,

	K_UNKNOWN = SPK | 0xFFFFFF,

	/* PRINTABLE LATIN 1 CODES */

	K_SPACE = 0x0020,
	K_EXCLAM = 0x0021,
	K_QUOTEDBL = 0x0022,
	K_NUMBERSIGN = 0x0023,
	K_DOLLAR = 0x0024,
	K_PERCENT = 0x0025,
	K_AMPERSAND = 0x0026,
	K_APOSTROPHE = 0x0027,
	K_PARENLEFT = 0x0028,
	K_PARENRIGHT = 0x0029,
	K_ASTERISK = 0x002A,
	K_PLUS = 0x002B,
	K_COMMA = 0x002C,
	K_MINUS = 0x002D,
	K_PERIOD = 0x002E,
	K_SLASH = 0x002F,
	K_0 = 0x0030,
	K_1 = 0x0031,
	K_2 = 0x0032,
	K_3 = 0x0033,
	K_4 = 0x0034,
	K_5 = 0x0035,
	K_6 = 0x0036,
	K_7 = 0x0037,
	K_8 = 0x0038,
	K_9 = 0x0039,
	K_COLON = 0x003A,
	K_SEMICOLON = 0x003B,
	K_LESS = 0x003C,
	K_EQUAL = 0x003D,
	K_GREATER = 0x003E,
	K_QUESTION = 0x003F,
	K_AT = 0x0040,
	K_A = 0x0041,
	K_B = 0x0042,
	K_C = 0x0043,
	K_D = 0x0044,
	K_E = 0x0045,
	K_F = 0x0046,
	K_G = 0x0047,
	K_H = 0x0048,
	K_I = 0x0049,
	K_J = 0x004A,
	K_K = 0x004B,
	K_L = 0x004C,
	K_M = 0x004D,
	K_N = 0x004E,
	K_O = 0x004F,
	K_P = 0x0050,
	K_Q = 0x0051,
	K_R = 0x0052,
	K_S = 0x0053,
	K_T = 0x0054,
	K_U = 0x0055,
	K_V = 0x0056,
	K_W = 0x0057,
	K_X = 0x0058,
	K_Y = 0x0059,
	K_Z = 0x005A,
	K_BRACKETLEFT = 0x005B,
	K_BACKSLASH = 0x005C,
	K_BRACKETRIGHT = 0x005D,
	K_ASCIICIRCUM = 0x005E,
	K_UNDERSCORE = 0x005F,
	K_QUOTELEFT = 0x0060,
	K_BRACELEFT = 0x007B,
	K_BAR = 0x007C,
	K_BRACERIGHT = 0x007D,
	K_ASCIITILDE = 0x007E,
	K_NOBREAKSPACE = 0x00A0,
	K_EXCLAMDOWN = 0x00A1,
	K_CENT = 0x00A2,
	K_STERLING = 0x00A3,
	K_CURRENCY = 0x00A4,
	K_YEN = 0x00A5,
	K_BROKENBAR = 0x00A6,
	K_SECTION = 0x00A7,
	K_DIAERESIS = 0x00A8,
	K_COPYRIGHT = 0x00A9,
	K_ORDFEMININE = 0x00AA,
	K_GUILLEMOTLEFT = 0x00AB,
	K_NOTSIGN = 0x00AC,
	K_HYPHEN = 0x00AD,
	K_REGISTERED = 0x00AE,
	K_MACRON = 0x00AF,
	K_DEGREE = 0x00B0,
	K_PLUSMINUS = 0x00B1,
	K_TWOSUPERIOR = 0x00B2,
	K_THREESUPERIOR = 0x00B3,
	K_ACUTE = 0x00B4,
	K_MU = 0x00B5,
	K_PARAGRAPH = 0x00B6,
	K_PERIODCENTERED = 0x00B7,
	K_CEDILLA = 0x00B8,
	K_ONESUPERIOR = 0x00B9,
	K_MASCULINE = 0x00BA,
	K_GUILLEMOTRIGHT = 0x00BB,
	K_ONEQUARTER = 0x00BC,
	K_ONEHALF = 0x00BD,
	K_THREEQUARTERS = 0x00BE,
	K_QUESTIONDOWN = 0x00BF,
	K_AGRAVE = 0x00C0,
	K_AACUTE = 0x00C1,
	K_ACIRCUMFLEX = 0x00C2,
	K_ATILDE = 0x00C3,
	K_ADIAERESIS = 0x00C4,
	K_ARING = 0x00C5,
	K_AE = 0x00C6,
	K_CCEDILLA = 0x00C7,
	K_EGRAVE = 0x00C8,
	K_EACUTE = 0x00C9,
	K_ECIRCUMFLEX = 0x00CA,
	K_EDIAERESIS = 0x00CB,
	K_IGRAVE = 0x00CC,
	K_IACUTE = 0x00CD,
	K_ICIRCUMFLEX = 0x00CE,
	K_IDIAERESIS = 0x00CF,
	K_ETH = 0x00D0,
	K_NTILDE = 0x00D1,
	K_OGRAVE = 0x00D2,
	K_OACUTE = 0x00D3,
	K_OCIRCUMFLEX = 0x00D4,
	K_OTILDE = 0x00D5,
	K_ODIAERESIS = 0x00D6,
	K_MULTIPLY = 0x00D7,
	K_OOBLIQUE = 0x00D8,
	K_UGRAVE = 0x00D9,
	K_UACUTE = 0x00DA,
	K_UCIRCUMFLEX = 0x00DB,
	K_UDIAERESIS = 0x00DC,
	K_YACUTE = 0x00DD,
	K_THORN = 0x00DE,
	K_SSHARP = 0x00DF,

	K_DIVISION = 0x00F7,
	K_YDIAERESIS = 0x00FF,

	K_INVALID = -1,
}