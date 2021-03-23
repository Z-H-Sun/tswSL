require 'Win32API'
GET_MESSAGE = Win32API.new('user32','GetMessage','plll','l')
SEND_MESSAGE = Win32API.new('user32', 'SendMessage', 'lllp', 'l')
REG_HOTKEY = Win32API.new('user32', 'RegisterHotKey', 'lill', 'l')
UNREG_HOTKEY = Win32API.new('user32', 'UnregisterHotKey', 'li', 'l')
# READ_PROCESS = Win32API.new('kernel32', 'ReadProcessMemory', 'llplp', 'l')
WRITE_PROCESS = Win32API.new('kernel32', 'WriteProcessMemory', 'llplp', 'l')
MESSAGE_BOX = Win32API.new('user32', 'MessageBox', 'lppi', 'l')
WM_SETTEXT = 0xC
WM_GETTEXT = 0xD
WM_COMMAND = 0x111
PROCESS_VM_WRITE = 0x20
PROCESS_VM_READ = 0x10
PROCESS_VM_OPERATION = 0x8
MB_ICONEXCLAMATION = 0x30
MB_ICONINFORMATION = 0x40

BASE_ADDRESS = 0x400000
PATH_ADDRESS = [0x7db88, 0x7dd48, 0x7df08, 0x7e0c8, 0x7e288, 0x7e448, 0x7e608, 0x7e7c8, # load
                0x7edac, 0x7eea0, 0x7ef94, 0x7f088, 0x7f17c, 0x7f270, 0x7f364, 0x7f458] # save
MENU_ID = [8, 9, 10, 11, 12, 13, 14, 15, # load
           17, 18, 19, 20, 21, 22, 23, 24] # save
ORIG_FILENAME = ['\save1.dat', '\save2.dat', '\save3.dat', '\save4.dat', '\save5.dat', '\save6.dat', '\save7.dat', '\save8.dat']
FILENAME_LEN = 10
MODIFIER = [6, 7, 7] # load = Shift+Ctrl; save = Shift+Ctrl+Alt; quit = Shift+Ctrl+Alt
KEY = [49, 50, 51, 52, 53, 54, 55, 56, 48] # data 1-8 = key1-8; quit = key0
TIME_STAMP = Time.now.strftime('\%m%dtmp_') # temp filename format

$hWnd = Win32API.new('user32', 'FindWindow', 'pi', 'l').call('TTSW10', 0)
$hWndText = Win32API.new('user32', 'FindWindowEx', 'llpi', 'l').call($hWnd, 0, 'TEdit', 0)
$pID = '\0\0\0\0'
Win32API.new('user32', 'GetWindowThreadProcessId', 'lp', 'l').call($hWnd, $pID)
$pID = $pID.unpack('L')[0]

begin
  load('tswSLdebug.txt')
rescue Exception
end
raise("Cannot find the TSW process and/or window. Please check if\nTSW V1.2 is currently running.\n\nAs an advanced option, you can manually assign $hWnd and\n$pID in `tswSLdebug.txt'.") if $hWnd.zero? or $hWndText.zero? or $pID.zero?
$hPrc = Win32API.new('kernel32', 'OpenProcess', 'lll', 'l').call(PROCESS_VM_WRITE | PROCESS_VM_READ | PROCESS_VM_OPERATION, 0, $pID)
raise("Cannot open the TSW process for writing. Please check if\nTSW V1.2 is running with pID=#{$pID} and if you have proper\npermissions.") if $hPrc.zero?


raise("Cannot register hotkey for quitting the program. It might be\ncurrently occupied by other processes or another instance of\ntswMP. Please close them to avoid confliction.\n\nDefault: Ctrl+Shift+Alt+0 (7+ 48); current (#{MODIFIER[2]}+ #{KEY[8]}). As an\nadvanced option, you can manually assign MODIFIER and KEY\nin `tswSLdebug.txt'.") if REG_HOTKEY.call(0, 16, MODIFIER[2], KEY[8]).zero?
failed = []
for i in 0..7
  failed << "LoadTemp ##{i+1}: Current is #{MODIFIER[0]}+ #{KEY[i]}" if REG_HOTKEY.call(0, i, MODIFIER[0], KEY[i]).zero?
  failed << "SaveTemp ##{i+1}: Current is #{MODIFIER[1]}+ #{KEY[i]}" if REG_HOTKEY.call(0, 8+i, MODIFIER[1], KEY[i]).zero?
end
MESSAGE_BOX.call($hWnd, "The following hotkey(s) cannot be registered properly:\n#{failed.join(";\n")}.\n\nThese hotkeys might be currently occupied by other processes\nor reserved by system. Please close any conflicting program,\nor as an advanced option, you can manually assign MODIFIER\nand KEY in `tswSLdebug.txt'.\n\nHowever, tswSL will remain running, and other hotkeys are\nstill fully functional.", 'tswSL', MB_ICONEXCLAMATION) unless failed.empty?
MESSAGE_BOX.call($hWnd, "tswSaveLoad is currently running.\n\nUse hotkeys to load from / save to a temp data.\nBy default:\nCtrl+Shift+1-8:\tLoadTemp 1-8;\nCtrl+Shift+Alt+1-8:\tSaveTemp 1-8;\nCtrl+Shift+Alt+0:\tQuit.", 'tswSL', MB_ICONINFORMATION)

while true
  msg = ' '*44
  GET_MESSAGE.call(msg, 0, 0, 0)
  # 32 bit? 64 bit? 0x312 = hotkey event
  if msg[4, 4] == "\x12\x03\0\0" then offset = 8 elsif msg[8, 4] == "\x12\x03\0\0" then offset = 16 else next end
  type = msg[offset, 4].unpack('l')[0]
  save = type >> 3 # 0 = load; 1 = save; 2 = quit
  num = type & 7 # 0-7
  if save == 2
    (0..16).each{|i| UNREG_HOTKEY.call(0, i)}
    MESSAGE_BOX.call($hWnd, "tswSaveLoad has stopped.", 'tswSL', MB_ICONINFORMATION)
    Win32API.new('kernel32', 'CloseHandle', 'l', 'l').call($hPrc)
    exit
  else
    # Temporarily change the path to the data file
    WRITE_PROCESS.call($hPrc, BASE_ADDRESS+PATH_ADDRESS[type], TIME_STAMP+(num+1).to_s, FILENAME_LEN, '    ')
    # Raise the "Menu_Click" event
    SEND_MESSAGE.call($hWnd, WM_COMMAND, MENU_ID[type], 0)
    # For either English or Chinese version, if the length of tip text is long, it indicates something has gone wrong.
    tipText = ' '*256
    len = SEND_MESSAGE.call($hWndText, WM_GETTEXT, 255, tipText)
    if tipText.include?('e') then maxLen = 16 else maxLen = 8 end
    if len > maxLen then text = 'tswSL: No such' else text = "tswSL: #{save.zero? ? 'Load':'Sav'}ed" end
    text += " tempdata ##{num+1} @ #{TIME_STAMP[1, 4]}"
    # Show information in the bottom status bar
    SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, text)
    # Restore the path to the data file
    WRITE_PROCESS.call($hPrc, BASE_ADDRESS+PATH_ADDRESS[type], ORIG_FILENAME[num], FILENAME_LEN, '    ')
  end
end
