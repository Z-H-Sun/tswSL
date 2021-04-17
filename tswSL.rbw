#encoding: ASCII-8BIT
require 'Win32API'
GET_MESSAGE = Win32API.new('user32','GetMessage','plll','l')
SEND_MESSAGE = Win32API.new('user32', 'SendMessage', 'lllp', 'l')
TRAN_MESSAGE = Win32API.new('user32','TranslateMessage','p','l')
DISP_MESSAGE = Win32API.new('user32','DispatchMessage','p','l')
REG_HOTKEY = Win32API.new('user32', 'RegisterHotKey', 'lill', 'l')
UNREG_HOTKEY = Win32API.new('user32', 'UnregisterHotKey', 'li', 'l')
WRITE_PROCESS = Win32API.new('kernel32', 'WriteProcessMemory', 'llplp', 'l')
MESSAGE_BOX = Win32API.new('user32', 'MessageBox', 'lppi', 'l')
GET_RECT = Win32API.new('user32','GetClientRect','lp','l')
FIND_WIN = Win32API.new('user32', 'FindWindowEx', 'llpl', 'l')
SHOW_WIN = Win32API.new('user32','ShowWindow','li','i')
UPDT_WIN = Win32API.new('user32','UpdateWindow','l','i')
SET_FOC = Win32API.new('user32','SetFocus','l','l')
LST_ERR = Win32API.new('kernel32', 'GetLastError', '', 'l')

WM_SETTEXT = 0xC
WM_GETTEXT = 0xD
WM_COMMAND = 0x111
PROCESS_VM_WRITE = 0x20
PROCESS_VM_READ = 0x10
PROCESS_VM_OPERATION = 0x8
MEM_COMMIT = 0x1000
MEM_RESERVE = 0x2000
PAGE_EXECUTE_READWRITE = 0x40
MB_ICONEXCLAMATION = 0x30
MB_ICONINFORMATION = 0x40
WS_CHILD = 0x40000000
WS_VSCROLL = 0x200000
CBS_DROPDOWN = 0x2
CBS_AUTOHSCROLL = 0x40
CBS_DISABLENOSCROLL = 0x800
CB_LIMITTEXT = 0x141
CB_ADDSTRING = 0x143
CB_RESETCONTENT = 0x14B
CB_SHOWDROPDOWN = 0x14F
CB_FINDSTRINGEXACT = 0x158
SW_HIDE = 0
SW_SHOW = 4

BASE_ADDRESS = 0x400000
PATH_ADDRESS = [0x7db88, 0x7dd48, 0x7df08, 0x7e0c8, 0x7e288, 0x7e448, 0x7e608, 0x7e7c8, # load
                0x7edac, 0x7eea0, 0x7ef94, 0x7f088, 0x7f17c, 0x7f270, 0x7f364, 0x7f458] # save
MENU_ID = [8, 9, 10, 11, 12, 13, 14, 15, # load
           17, 18, 19, 20, 21, 22, 23, 24] # save
DATFILE_OFFSET = [0x7dab6, 0x7ed02] # load1, save1
ORIG_FILENAME = ['\save1.dat', '\save2.dat', '\save3.dat', '\save4.dat', '\save5.dat', '\save6.dat', '\save7.dat', '\save8.dat']
FILENAME_LEN = 10
FILENAME_MAX = 256 # not really, filename+path cannot exceed 260 chars
MODIFIER = [6, 7, 7] # load = Shift+Ctrl; save = Shift+Ctrl+Alt; quit = Shift+Ctrl+Alt
KEY = [49, 50, 51, 52, 53, 54, 55, 56, 57, 48] # data 1-8 = key1-8; custom data = key9; quit = key0
TIME_STAMP = Time.now.strftime('\%m%dtmp_') # temp filename format

$hWnd = Win32API.new('user32', 'FindWindow', 'pi', 'l').call('TTSW10', 0)
$pID = '\0\0\0\0'
Win32API.new('user32', 'GetWindowThreadProcessId', 'lp', 'l').call($hWnd, $pID)
$pID = $pID.unpack('L')[0]

begin
  load('tswSLdebug.txt')
rescue Exception
end
raise("Cannot find the TSW process and/or window. Please check if\nTSW V1.2 is currently running.\n\nAs an advanced option, you can manually assign $hWnd and\n$pID in `tswSLdebug.txt'.") if $hWnd.zero? or $pID.zero?

$hPrc = Win32API.new('kernel32', 'OpenProcess', 'lll', 'l').call(PROCESS_VM_WRITE | PROCESS_VM_READ | PROCESS_VM_OPERATION, 0, $pID)
$baseAddress = Win32API.new('kernel32', 'VirtualAllocEx', 'lllll', 'l').call($hPrc, 0, FILENAME_MAX+10, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE) # allocate memory for filenames longer than FILENAME_LEN
raise("Cannot open the TSW process for writing. Please check if\nTSW V1.2 is running with pID=#{$pID} and if you have proper\npermissions.") if $hPrc.zero? or $baseAddress.zero?

$hWndText = 0
width = 0
wh = ' ' * 16
while width < 600 # find the status bar, whose width is always larger than 600 (to avoid mistakenly finding other textbox window)
  $hWndText = FIND_WIN.call($hWnd, $hWndText, 'TEdit', 0)
  if $hWndText.zero?
    MESSAGE_BOX.call($hWnd, "tswSL failed to find the status bar at the bottom of the TSW window. Please check whether this is really a TSW process?\n\n\tPID=#{$pID}, hWND=#{$hWnd}\n\nHowever, tswSL will continue running anyway.", 'tswSL', MB_ICONEXCLAMATION)
    break
  end
  GET_RECT.call($hWndText, wh)
  width = wh.unpack('L4')[2]
end

# create a combo box at the bottom for customizing tempdata filename
Win32API.new('user32','GetClientRect','lp','l').call($hWnd, wh)
width, height = wh[8, 8].unpack('ll')
$hWndComboBox = Win32API.new('user32','CreateWindowEx','lppliiiillll','l').call(0, 'COMBOBOX', '', WS_CHILD|WS_VSCROLL|CBS_DROPDOWN|CBS_AUTOHSCROLL|CBS_DISABLENOSCROLL, width-105, height-28, 100, 200, $hWnd, 0, 0, 0)
MESSAGE_BOX.call($hWnd, 'Failed to create a combo box window in TSW, so tswSL will be unable to customize tempdata filename. However, tswSL will remain running, and other functions still work well.', 'tswSL', MB_ICONEXCLAMATION) if $hWndComboBox.zero?
SEND_MESSAGE.call($hWndComboBox, CB_LIMITTEXT, FILENAME_MAX, 0) # limit to 256 bytes

begin
  unless defined?(SAVEDAT_PATH)
    f = open('C:/Windows/TSW12.INI')
    SAVEDAT_PATH = f.readline.chomp
    f.close
  end
  Dir.chdir(SAVEDAT_PATH) ######
rescue Exception
  Object.send(:remove_const, :SAVEDAT_PATH) if defined?(SAVEDAT_PATH) # undefine SAVEDAT_PATH
  MESSAGE_BOX.call($hWnd, "tswSL cannot find a valid SAVEDAT path for TSW. Do not panic, though; the only inconvenience is that the combo box will not list the datafiles available in that folder, but otherwise tswSL is fully functionable.\n\nAs an advanced option, you can manually assign SAVEDAT_PATH in `tswSLdebug.txt'.\n\ntswSL will continue running anyway.", 'tswSL', MB_ICONINFORMATION)
end

raise("Cannot register hotkey for quitting the program. It might be\ncurrently occupied by other processes or another instance of\ntswMP. Please close them to avoid confliction.\n\nDefault: Ctrl+Shift+Alt+0 (7+ 48); current (#{MODIFIER[2]}+ #{KEY[9]}). As an\nadvanced option, you can manually assign MODIFIER and KEY\nin `tswSLdebug.txt'.") if REG_HOTKEY.call(0, 18, MODIFIER[2], KEY[9]).zero?
failed = []
for i in 0..8
  num = i < 8 ? i+1 : 'CUSTOM'
  failed << "LoadTemp ##{num}: Current is #{MODIFIER[0]}+ #{KEY[i]}" if REG_HOTKEY.call(0, i, MODIFIER[0], KEY[i]).zero?
  failed << "SaveTemp ##{num}: Current is #{MODIFIER[1]}+ #{KEY[i]}" if REG_HOTKEY.call(0, 9+i, MODIFIER[1], KEY[i]).zero?
end
MESSAGE_BOX.call($hWnd, "The following hotkey(s) cannot be registered properly:\n#{failed.join(";\n")}.\n\nThese hotkeys might be currently occupied by other processes\nor reserved by system. Please close any conflicting program,\nor as an advanced option, you can manually assign MODIFIER\nand KEY in `tswSLdebug.txt'.\n\nHowever, tswSL will remain running, and other hotkeys are\nstill fully functional.", 'tswSL', MB_ICONEXCLAMATION) unless failed.empty?
MESSAGE_BOX.call($hWnd, "tswSaveLoad is currently running.\n\nUse hotkeys to load from / save to a temp data.\nBy default:\nCtrl+Shift+1-8:        \tLoadTemp 1-8;\nCtrl+Shift+9:          \tLoadTemp CUSTOM;\nCtrl+Shift+Alt+1-8:\tSaveTemp 1-8;\nCtrl+Shift+Alt+9:    \tSaveTemp CUSTOM;\nCtrl+Shift+Alt+0:    \tQuit.", 'tswSL', MB_ICONINFORMATION)

def mkdir_p(path) # adapted from FileUtils::mkdir_p
  stack = []
  until path == stack.last
    stack.push path
    path = File.dirname(path)
  end
  stack.reverse_each do |path|
    begin
      Dir.mkdir(path) unless File.directory?(path)
    rescue SystemCallError => err
      MESSAGE_BOX.call($hWnd, "The following path cannot be created due to #{$!.inspect}:\n\n#{File.join(SAVEDAT_PATH, path)}", 'tswSL', MB_ICONEXCLAMATION)
      return
    end
  end
end

def slTEMP(save, num, filename=nil)
  address = BASE_ADDRESS+PATH_ADDRESS[8*save+num]
  err = 0
  if filename.nil?
    filename2 = TIME_STAMP+(num+1).to_s
    # Temporarily change the path to the data file
    err = LST_ERR.call if WRITE_PROCESS.call($hPrc, address, filename2, FILENAME_LEN, '    ').zero?
  else
    filename2 = filename.strip
    # first 8 bytes define the length of char array, followed by 256 bytes of char array
    err = LST_ERR.call if WRITE_PROCESS.call($hPrc, $baseAddress, [0xffffffff, FILENAME_MAX].pack('L2') + filename.ljust(FILENAME_MAX, "\0"), 8+FILENAME_MAX, '    ').zero?
    # change the pointer of the path to the allocated memory
    err = LST_ERR.call if WRITE_PROCESS.call($hPrc, BASE_ADDRESS+DATFILE_OFFSET[save], [$baseAddress+8].pack('L'), 4, '    ').zero?
    path = File.dirname(filename2[1..-1])
    if path != '.' and save == 1 # check if the saving path is existing
      if defined?(SAVEDAT_PATH)
        mkdir_p(path)
      else
        MESSAGE_BOX.call($hWnd, "As SAVEDAT_PATH is not defined, tswSL is unable to determine whether `#{path}' is a valid path. Please make sure it is an existing sub-folder of the TSW's SAVEDAT folder; otherwise, the datafile cannot be successfully created.", 'tswSL', MB_ICONEXCLAMATION)
      end
    end
  end
  if err.zero?
    # Raise the "Menu_Click" event
    SEND_MESSAGE.call($hWnd, WM_COMMAND, MENU_ID[8*save+num], 0)
    # For either English or Chinese version, if the length of tip text is long, it indicates something has gone wrong.
    tipText = ' '*256
    len = SEND_MESSAGE.call($hWndText, WM_GETTEXT, 255, tipText)
    if tipText.include?('e') then maxLen = 16 else maxLen = 8 end
    if len > maxLen then text = 'tswSL: No such' else text = "tswSL: #{@save.zero? ? 'Load':'Sav'}ed" end
    text += " tempdata - #{filename2[1..-1]}"
  else
    text = 'tswSL: Failed to write memory to the TSW process - Err 0x' + err.to_s(16)
  end
  # Show information in the bottom status bar
  SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, text)
  # Restore the path to the data file
  if filename.nil?
    WRITE_PROCESS.call($hPrc, address, ORIG_FILENAME[num], FILENAME_LEN, '    ')
  else
    WRITE_PROCESS.call($hPrc, BASE_ADDRESS+DATFILE_OFFSET[save], [address].pack('L'), 4, '    ')
  end
end

def getFiles(dir)
  for i in Dir.entries(dir)
    next if i == '.' or i == '..'
    j = "#{dir}\\#{i}"
    if File.directory?(j)
      getFiles(j)
    else
      SEND_MESSAGE.call($hWndComboBox, CB_ADDSTRING, 0, j)
    end
  end
end

def getDatafiles() # load a list of filenames in the savedata folder
  if defined?(SAVEDAT_PATH)
    SEND_MESSAGE.call($hWndComboBox, CB_RESETCONTENT, 0, 0)
    for i in Dir.entries('.')
      next if i == '.' or i == '..'
      next if i == 'save0.dat' # this one is not savedata
      next unless i[/^option\d{0,2}\.dat$/].nil?
      next unless i[/^\$[A-Z0-9]+.dat$/].nil?
      if File.directory?(i) # consider 1st sub-folder
        getFiles(i)
      else
        SEND_MESSAGE.call($hWndComboBox, CB_ADDSTRING, 0, i)
      end
    end
  end
end

getDatafiles
msg = ' '*44
while GET_MESSAGE.call(msg, 0, 0, 0) != 0
  # 32 bit? 64 bit? 0x100 = keydown
  if msg[4, 4] == "\0\001\0\0" then offset = 8 elsif msg[8, 4] == "\0\001\0\0" then offset = 16 else offset = -1 end
  keyDown = msg[offset, 4].unpack('l')[0]
  TRAN_MESSAGE.call(msg)
  DISP_MESSAGE.call(msg)
  if offset > 0 and keyDown == 27 or keyDown == 13 # enter/esc
    if keyDown == 13
      fName = ' '*FILENAME_MAX
      len = SEND_MESSAGE.call($hWndComboBox, WM_GETTEXT, FILENAME_MAX, fName)
      fName.strip!
      if len.zero?
        MESSAGE_BOX.call($hWnd, 'The filename cannot be empty.', 'tswSL', MB_ICONEXCLAMATION)
        SET_FOC.call($hWndComboBox); next # ask for re-entering
      end
      SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, '') # clear status bar
      SEND_MESSAGE.call($hWndComboBox, CB_ADDSTRING, 0, fName) if SEND_MESSAGE.call($hWndComboBox, CB_FINDSTRINGEXACT, -1, fName) < 0 # non-existing
      slTEMP(@save, 0, "\\"+fName)
    else
      SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, '') # clear status bar
    end
    SHOW_WIN.call($hWndComboBox, SW_HIDE)
    SET_FOC.call(0) # restore focus
    next if keyDown == 27
  end
  # 32 bit? 64 bit? 0x312 = hotkey event
  if msg[4, 4] == "\x12\x03\0\0" then offset = 8 elsif msg[8, 4] == "\x12\x03\0\0" then offset = 16 else next end
  type = msg[offset, 4].unpack('l')[0]
  @save = type / 9 # 0 = load; 1 = save; 2 = quit
  num = type % 9 # 0-8
  if @save == 2 # exit
    SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, '')
    (0..18).each{|i| UNREG_HOTKEY.call(0, i)}
    $hWnd = 0 if Win32API.new('user32', 'IsWindow', 'l', 'l').call($hWnd).zero? # TSW quited?
    MESSAGE_BOX.call($hWnd, "tswSaveLoad has stopped.", 'tswSL', MB_ICONINFORMATION)
    Win32API.new('kernel32', 'CloseHandle', 'l', 'l').call($hPrc)
    exit
  else
    if num == 8 # custom
      if $hWndComboBox.zero?
        SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, 'tswSL: Failed to create a combo box window; customizing tempdata filename no longer functionable')
        next
      end
      SEND_MESSAGE.call($hWndText, WM_SETTEXT, 0, "tswSL: Please input the filename to #{@save.zero? ? 'load' : 'save'}, and press ENTER:")
      SHOW_WIN.call($hWndComboBox, SW_SHOW)
      SET_FOC.call($hWndComboBox)
      UPDT_WIN.call($hWndComboBox)
      if @save.zero? # refresh list
        getDatafiles
        SEND_MESSAGE.call($hWndComboBox, CB_SHOWDROPDOWN, 1, 0)
      end
      next
    end
    slTEMP(@save, num)
  end
end
