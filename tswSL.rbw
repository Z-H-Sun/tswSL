#!/usr/bin/env ruby
# encoding: ASCII-8Bit

require 'win32/api'
include Win32
GetMessage = API.new('GetMessage', 'PLLL', 'L', 'user32')
SendMessage = API.new('SendMessage', 'LLLP', 'L', 'user32')
SendMessageW = API.new('SendMessageW', 'LLLP', 'L', 'user32')
OpenProcess = API.new('OpenProcess', 'LLL', 'L', 'kernel32')
ReadProcessMemory = API.new('ReadProcessMemory', 'LLPLL', 'L', 'kernel32')
WriteProcessMemory = API.new('WriteProcessMemory', 'LLPLL', 'L', 'kernel32')
CloseHandle = API.new('CloseHandle', 'L', 'L', 'kernel32')
GetWindowThreadProcessId = API.new('GetWindowThreadProcessId', 'LP', 'L', 'user32')
MessageBox = API.new('MessageBox', 'LSSI', 'L', 'user32')
MessageBoxW = API.new('MessageBoxW', 'LSSI', 'L', 'user32')
IsWindow = API.new('IsWindow', 'L', 'L', 'user32')
FindWindow = API.new('FindWindow', 'SL', 'L', 'user32')
GetLastActivePopup = API.new('GetLastActivePopup', 'L', 'L', 'user32')
ShowWindow = API.new('ShowWindow', 'LI', 'L', 'user32')
EnableWindow = API.new('EnableWindow', 'LI', 'L', 'user32')
SetForegroundWindow = API.new('SetForegroundWindow', 'L', 'L', 'user32')
RegisterHotKey = API.new('RegisterHotKey', 'LILL', 'L', 'user32')
UnregisterHotKey = API.new('UnregisterHotKey', 'LI', 'L', 'user32')
SW_SHOW = 4 # SHOWNOACTIVATE
WM_SETTEXT = 0xC
WM_GETTEXT = 0xD
WM_COMMAND = 0x111
WM_HOTKEY = 0x312
MB_ICONEXCLAMATION = 0x30
MB_ICONASTERISK = 0x40
MB_SETFOREGROUND = 0x10000
PROCESS_VM_WRITE = 0x20
PROCESS_VM_READ = 0x10
PROCESS_VM_OPERATION = 0x8
case [''].pack('p').size
when 4 # 32-bit ruby
  MSG_INFO_STRUCT = 'L7'
when 8 # 64-bit
  MSG_INFO_STRUCT = 'Q4L3'
else
  raise 'Unsupported system or ruby version (neither 32-bit or 64-bit).'
end
TSW_CLS_NAME = 'TTSW10'
BASE_ADDRESS = 0x400000
OFFSET_EDIT8 = 0x1c8 # status bar textbox at bottom
OFFSET_HWND = 0xc0
OFFSET_OWNER_HWND = 0x20
TTSW_ADDR = 0x8c510 + BASE_ADDRESS
TAPPLICATION_ADDR = 0x8a6f8 + BASE_ADDRESS
STATUS_ADDR = 0xb8688 + BASE_ADDRESS
STATUS_INDEX = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 9] # floor-4; x-6; y-7
MAP_ADDR = 0xb8934 + BASE_ADDRESS
MIDSPEED_MENUID = 33 # The idea is to hijack the midspeed menu
MIDSPEED_ADDR = 0x7f46d + BASE_ADDRESS # so once click event of that menu item is triggered, arbitrary code can be executed
MIDSPEED_ORIG = 0x6F # original bytecode (call TTSW10.speedmiddle@0x47f4e0)
$buf="\0"*640
require './strings'
module Win32
  class API
    def self.focusTSW()
      ShowWindow.call($hWnd, SW_SHOW)
      hWnd = GetLastActivePopup.call($hWndTApp) # there is a popup child
      ShowWindow.call(hWnd, SW_SHOW) if hWnd != $hWnd
      SetForegroundWindow.call(hWnd) # SetForegroundWindow for $hWndTApp can also achieve similar effect, but can sometimes complicate the situation, e.g., LastActivePopup will be $hWndTApp if no mouse/keyboard input afterwards
      return hWnd
    end
    def self.msgbox(text, flag=MB_ICONASTERISK, api=MessageBox, title='tswSL')
      if IsWindow.call($hWnd || 0).zero?
        hWnd = $hWnd = 0 # if the window has gone, create a system level msgbox
      else
        hWnd = focusTSW()
      end
      return api.call(hWnd, text, title, flag | MB_SETFOREGROUND)
    end
    def call_r(*argv) # provide more info if a win32api returns null
      r = call(*argv)
      return r unless r.zero?
      err = '0x%04X' % API.last_error
      case function_name
      when 'OpenProcess', 'WriteProcessMemory', 'ReadProcessMemory', 'VirtualAllocEx'
        reason = "Cannot open / read from / write to / alloc memory for the TSW process. Please check if TSW V1.2 is running with pID=#{$pID} and if you have proper permissions."
      when 'RegisterHotKey'
        reason = "Cannot register hotkey. It might be currently occupied by other processes or another instance of tswSL. Please close them to avoid confliction. Default: Ctrl+Alt+Bksp (3+ 8); current: (#{SL_MODIFIERS[1]}+ #{SL_HOTKEYS[1]}). As an advanced option, you can manually assign `MODIFIER` and `KEY` in `tswSLdebug.txt'."
      else
        reason = "This is a fatal error. That is all we know."
      end
      raise_r("Err #{err} when calling `#{effective_function_name}'@#{dll_name}.\n#{reason} tswSL has stopped. Details are as follows:\n\nPrototype='#{prototype.join('')}', ReturnType='#{return_type}', ARGV=#{argv.inspect}")
    end
  end
end
def readMemoryDWORD(address)
  ReadProcessMemory.call_r($hPrc, address, $buf, 4, 0)
  return $buf.unpack('l')[0]
end
def writeMemoryDWORD(address, dword)
  WriteProcessMemory.call_r($hPrc, address, [dword].pack('l'), 4, 0)
end
def callFunc(address) # execute the subroutine at the given address
  writeMemoryDWORD(MIDSPEED_ADDR, address-MIDSPEED_ADDR-4)
  SendMessage.call($hWnd, WM_COMMAND, MIDSPEED_MENUID, 0)
  writeMemoryDWORD(MIDSPEED_ADDR, MIDSPEED_ORIG) # restore
end
def msgboxTxtA(textIndex, flag=MB_ICONASTERISK, *argv)
  API.msgbox(Str::StrEN::STRINGS[textIndex] % argv, flag, MessageBox)
end
def msgboxTxtW(textIndex, flag=MB_ICONASTERISK, *argv)
  API.msgbox(Str.utf8toWChar(Str::StrCN::STRINGS[textIndex] % argv), flag, MessageBoxW, "t\0s\0w\0S\0L\0\0\0")
end

VK_BACK = 8
IDOK = 1
IDCANCEL = 2
MB_OKCANCEL = 0x1

VirtualAllocEx = API.new('VirtualAllocEx', 'LLLLL', 'L', 'kernel32')
VirtualFreeEx = API.new('VirtualFreeEx', 'LLLL', 'L', 'kernel32')
PostMessage = API.new('PostMessage', 'LLLP', 'L', 'user32')
PeekMessage = API.new('PeekMessage','PLLLI','L', 'user32')
SendMessageCallback = API.new('SendMessageCallback', 'LLLPKL', 'L', 'user32')
MEM_COMMIT = 0x1000
MEM_RESERVE = 0x2000
MEM_RELEASE = 0x8000
PAGE_EXECUTE_READWRITE = 0x40

MAX_PATH = 260
GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
OFN_LONGNAMES = 0x200000
OFN_NONETWORKBUTTON = 0x20000
OFN_FILEMUSTEXIST = 0x1000
OFN_PATHMUSTEXIST = 0x800
OFN_HIDEREADONLY = 0x4
OFN_TSWSL_LOAD = OFN_LONGNAMES | OFN_NONETWORKBUTTON | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY
OFN_TSWSL_SAVE = OFN_LONGNAMES | OFN_NONETWORKBUTTON | OFN_PATHMUSTEXIST

OFFSET_MEMO12 = 0x444 # savedat path
TEDIT8_MSGID_ADDR = 0x8c58c + BASE_ADDRESS
ITEM_ID_ADDR = 0x8c574 + BASE_ADDRESS
GOLD_PRICE_ADDR = 0x8c594 + BASE_ADDRESS
FILENAME_ADDR = 0x8c5d4 + BASE_ADDRESS
FILE_HANDLE_ADDR = 0x8c600 + BASE_ADDRESS
HERO_FACE_ADDR = 0xb87e8 + BASE_ADDRESS

HANDLE_FINALLY_ADDR = 0x3140 + BASE_ADDRESS
ITEM_LIVE_ADDR = 0x50880 + BASE_ADDRESS
LOAD_WORK_ADDR = 0x7e7d4 + BASE_ADDRESS
SAVE_WORK_ADDR = 0x7eadc + BASE_ADDRESS

LOAD_LIBRARY_ADDR = 0x4bfc + BASE_ADDRESS
GET_PROC_ADDR_ADDR = 0x4b84 + BASE_ADDRESS
CLOSE_HANDLE_ADDR = 0x1228 + BASE_ADDRESS
CREATE_FILE_ADDR = 0x1230 + BASE_ADDRESS
READ_FILE_ADDR = 0x1270 + BASE_ADDRESS
WRITE_FILE_ADDR = 0x1290 + BASE_ADDRESS
GET_LAST_ERROR_ADDR = 0x12A8 + BASE_ADDRESS
SET_WINDOW_TEXT_ADDR = 0x51fc + BASE_ADDRESS

EMPTY2_MSG_ID = 9
LOAD_SUCCESS_MSG_ID = 0x85
SAVE_SUCCESS_MSG_ID = 0x86
CHANGE_SAVEDIR_MENUID = 46

SL_MODIFIERS = [1, 3] # load: Alt; save: Ctrl+Alt
SL_HOTKEYS = [0x30, VK_BACK] # load/save arbitrary data: "0"; load temp data / quit: "Backspace"

$SLautosave = true # whether to enable auto saving temp data

module SL
  SL_PATCH_BYTES_1 = [ # address, len, original bytes, patched bytes, variable to insert into patched bytes
[0x7eb56, 33, # savework_1
 "\xE8\x32\x5A\xF8\xFF\xE8\xB0\x3B\xF8\xFF\xB8\x00\xC6\x48\x00\xE8\x4E\x57\xF8\xFF\xE8\xA1\x3B\xF8\xFF\x6A\x00\x66\x8B\x0D\xA0\xEC\x47",
 "\x50\xE8\x31\x5A\xF8\xFF\xE8\xAF\x3B\xF8\xFF\x58\xE8\x51\x57\xF8\xFF\xE8\xA4\x3B\xF8\xFF\x8B\x0D%s\x85\xC9\x74\x13\x6A",
 :@_save_overwrite_dialog_style],
[0x7ebf2, 9, # savework_2_1
 "\xC7\x05\x8C\xC5\x48\x00\x86\x00\x00",
 "\xA1%s\xA3\x8C\xC5\x48", :@_save_success_msg_tedit8_id],
[0x7ec7f, 9, # savework_2_2
 "\xC7\x05\x8C\xC5\x48\x00\x86\x00\x00",
 "\xA1%s\xA3\x8C\xC5\x48", :@_save_success_msg_tedit8_id],
[0x7e810, 40, # loadwork_1
 "\x8B\x15\xD4\xC5\x48\x00\xB8\x00\xC6\x48\x00\xE8\x2D\x59\xF8\xFF\x33\xFF\x55\x68\x42\xEA\x47\x00\x64\xFF\x37\x64\x89\x27\xBA\x01\x00\x00\x00\xB8\x00\xC6\x48\x00",
 "\xA1%s\x8B\x10\xB8\x00\xC6\x48\x00\x50\xE8\x2B\x59\xF8\xFF\x58\x33\xFF\x55\x68\x42\xEA\x47\x00\x64\xFF\x37\x64\x89\x27\xBA\x01\x00\x00\x00\x90\x90",
 :@_filename_pointer_addr],
[0x7e8c0, 49, # loadwork_2
 "\x81\xFA\xA4\x00\x00\x00\x75\xD7\x3B\x35\x18\x89\x4B\x00\x75\x27\x3B\x0D\x1C\x89\x4B\x00\x75\x1F\x8B\x45\xFC\xE8\x08\x65\xFD\xFF\xC7\x05\x8C\xC5\x48\x00\x85\x00\x00\x00\x8B\x45\xFC\xE8\x42\xE2\xFC",
 "\x80\xFA\xA4\x75\xDA\x3B\x35\x18\x89\x4B\x00\x75\x2A\x3B\x0D\x1C\x89\x4B\x00\x75\x22\x8B\x45\xFC\x50\xE8\x0A\x65\xFD\xFF\xC6\x05\x8C\xC5\x48\x00\x85\x58\xE8\x49\xE2\xFC\xFF\xC6\x05%s",
 :@_last_coordinate]]


  SL_PATCH_BYTES_2 = [ # address, len, original bytes, patched bytes, pointer to call, offset after the `call` operand
[0x4a589, 31, # taisen
 "\x12\x8B\x45\xFC\xE8\xBA\x1A\x00\x00\xC7\x05\xB8\x86\x4B\x00\x01\x00\x00\x00\xA1\xB8\xC5\x48\x00\xA3\x5C\xC5\x48\x00\xA1\xB8",
 "\x17\xE8%s\x8B\x45\xFC\xE8\xB5\x1A\x00\x00\xC7\x05\xB8\x86\x4B\x00\x01\x00\x00\x00\xA1\xB8\xC5\x48\x00\xA3\x5C",
 :@_sub_savetemp, 6],
[0x4460b, 8, # handan_yellowdoors
 "\x83\x3D\xA8\x86\x4B\x00\x00\x7E",
 "\xB0\x08\xE8%s\x7C", :@_sub_checkkey, 7],
[0x4463a, 8, # handan_yellowdoors
 "\x83\x3D\xB0\x86\x4B\x00\x00\x7E",
 "\xB0\x0A\xE8%s\x7C", :@_sub_checkkey, 7],
[0x44669, 8, # handan_yellowdoors
 "\x83\x3D\xAC\x86\x4B\x00\x00\x7E",
 "\xB0\x09\xE8%s\x7C", :@_sub_checkkey, 7],
[0x497ee, 33, # roujin_2F
 "\xC7\x05\x5C\xC5\x48\x00\x42\x00\x00\x00\x83\x3D\x10\x88\x4B\x00\x00\x0F\x85\x65\x03\x00\x00\xC7\x05\x10\x88\x4B\x00\x01\x00\x00\x00",
 "\xB0\x42\xA3\x5C\xC5\x48\x00\x83\x3D\x10\x88\x4B\x00\x00\x0F\x85\x68\x03\x00\x00\xE8%s\xC6\x05\x10\x88\x4B\x00\x01\x90",
 :@_sub_savetemp, 25],
[0x4e267, 6, # Button2Click (syounin_yes)
 "\x3B\x05\x94\xC5\x48\x00",
 "\xE8%s\x90", :@_sub_checkgold, 5],
[0x4e4f8, 8, # Button2Click (syounin_28F_yes)
 "\x83\x3D\xA8\x86\x4B\x00\x00\x75",
 "\xB0\x08\xE8%s\x7D", :@_sub_checkkey, 7],
[0x50bdf, 5, # Button38Click (item_use)
 "\xA1\x74\xC5\x48\x00",
 "\xE8%s", :@_sub_checkitem, 5],
[0x51e7e, 6, # Button39Click (altar_addHP)
 "\x3B\x05\x94\xC5\x48\x00",
 "\xE8%s\x90", :@_sub_checkgold, 5],
[0x52116, 6, # Button39Click (altar_addATK)
 "\x3B\x05\x94\xC5\x48\x00",
 "\xE8%s\x90", :@_sub_checkgold, 5],
[0x523c2, 6, # Button39Click (altar_addDEF)
 "\x3B\x05\x94\xC5\x48\x00",
 "\xE8%s\x90", :@_sub_checkgold, 5],
[0x6399b, 5, # mevent (traps)
 "\xA1\x98\x86\x4B\x00",
 "\xE8%s", :@_sub_checkfloor, 5]]


  class << self
    attr_reader :savedat_path
    attr_reader :_tmp_id
    attr_reader :_sub_load_temp
    attr_reader :_sub_loadanydat
    attr_reader :_sub_saveanydat
  end
  module_function
  def init
    memo12 = readMemoryDWORD($TTSW+OFFSET_MEMO12)
    hWndMemo12 = readMemoryDWORD(memo12+OFFSET_HWND)
    len = SendMessage.call(hWndMemo12, WM_GETTEXT, 640, $buf) # MAX_PATH is 260, but there are two lines each with a path, and also one can never be too cautious

    @savedat_path = $buf[0, len].lines.first.chomp
    return raiseInvalDir(25) if @savedat_path.size < 2 # this is unlikely
    @savedat_path = @savedat_path[0, 2] + @savedat_path[2..-1].gsub(/[\/\\]+/, "\\").sub(/\\$/, '') # normalize file path (changing / into \; reducing multiple consecutive slashes into 1; removing tailing \); the first 2 chars might be \\ which should not be reduced

    tmp_filename = @savedat_path + '\autoID.tmp' # autoID: stores current index; auto00~autoFF: 256 temp data files
    tmpsize = tmp_filename.size
    return raiseInvalDir(26) if tmpsize > MAX_PATH-4 # MAX_PATH includes the tailing \0; also, need to ensure `dat_filename` is also within this length

    @tmp_id_addr = $lpNewAddr + tmpsize - 6 # can substitute ID with 00~FF at this address
    dat_filename = tmp_filename[0...-10] + Time.now.strftime('%y%m%d_1.dat')

    # these are all pointers to the corresponding variables:
    @_tmp_filename = $lpNewAddr
    @_bytesRead = $lpNewAddr + 0x108
    @_tmp_id = $lpNewAddr + 0x10c
    @_last_coordinate = $lpNewAddr + 0x10e
    @_dat_filename = $lpNewAddr + 0x110
    @_dat_suffix = $lpNewAddr + 0x218
    @_id_str = $lpNewAddr + 0x220
    @_comdlg32_dllname = $lpNewAddr + 0x420
    @_opendialog_funcname = $lpNewAddr + 0x430
    @_savedialog_funcname = $lpNewAddr + 0x444
    @_opendialog_addr = $lpNewAddr + 0x458
    @_savedialog_addr = $lpNewAddr + 0x45c
    @_save_overwrite_dialog_style = $lpNewAddr + 0x460
    @_save_success_msg_tedit8_id = $lpNewAddr + 0x464
    @_filename_pointer_addr = $lpNewAddr + 0x468
    @_dialog_filter = $lpNewAddr + 0x46c
    @_title_load = $lpNewAddr + 0x4ac
    @_title_save = $lpNewAddr + 0x4b8
    @_dialog_struct = $lpNewAddr + 0x4c4
    @_sub_init = $lpNewAddr + 0x510
    @_sub_load_temp = $lpNewAddr + 0x574
    offset_sub_rec_tmpid = 0x5c8
    @_sub_rec_tmpid = $lpNewAddr + offset_sub_rec_tmpid
    @_sub_loadanydat = $lpNewAddr + 0x60c
    @_sub_saveanydat = $lpNewAddr + 0x65c
    offset_sub_saveas = 0x70c
    @_sub_saveas = $lpNewAddr + offset_sub_saveas
    @_sub_checkkey = $lpNewAddr + 0x7e0
    @_sub_checkgold = $lpNewAddr + 0x7f0
    offset_sub_savetemp = 0x7f8
    @_sub_savetemp = $lpNewAddr + offset_sub_savetemp
    @_sub_checkfloor = $lpNewAddr + 0x85c
    @_sub_checkitem = $lpNewAddr + 0x8d0

    injBuf = tmp_filename.ljust(MAX_PATH+10, "\0") + # 0000...0108: string tmp_filename; 0108...010C: dword bytesRead; 010C: byte tmp_id
"\xFF\0" + # 010E: word last_coordinate = x+y*16+floor*256 (do not save temp data with the same last_coordinate; set as 255 at the start of / after loading a game, so no coordinate will be equal to this value, i.e. always save a first temp data)
dat_filename.ljust(MAX_PATH+4, "\0") + "_1.dat\0\0" + # 0110...0218: string dat_filename; 0218...0220: qword string dat_suffix
'000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF' + # 0220...0420: word string[256] id_str # covert byte to 2-digit hex string
"ComDlg32.dll\0\0\0\0GetOpenFileNameA\0\0\0\0GetSaveFileNameA\0\0\0\0" + # 0420...042E: string comdlg32_dllname; 0430...0441: string opendialog_funcname; 0444...0455: string savedialog_funcname
"\0" * 8 + # 0458...045C: dword ptr opendialog_addr; 045C...0460: dword ptr savedialog_addr
[3, SAVE_SUCCESS_MSG_ID, FILENAME_ADDR].pack('LLL') + # 0460...0464: dword save_overwrite_dialog_style (in replacement of 47eca0); 0464...0468: dword save_success_msg_tedit8_id (in replacement of const 0x86); 0468...046C: dword ptr filename_pointer_addr (pointer of pointer; in replacement of 48c5d4)
$str::DIALOG_FILTER_STR.ljust(64, "\0") + # 046C...04AC: string dialog_filter
$str::TITLE_LOAD_STR.ljust(12, "\0") + $str::TITLE_SAVE_STR.ljust(12, "\0") + # 04AC...04B8: string title_load; 4B8...4C4: string title_save
[0x4c, $hWnd, 0, @_dialog_filter, # structSize, hWndOwner, hInstance, lpFilter
 0, 0, 1, @_dat_filename, # lpCustomFilter, nMaxCusFilt, nFilterIndex [should set every time to 1], lpFileName
 MAX_PATH+4, 0, 0, 0, # nMaxLen, lpFileBaseName, nMaxFbName, lpInitDirName
 @_title_load, 0x221804,# lpTitle [should set every time], flags [should set every time]: 0x200000=LongNames; 0x20000=NoNetworkButton; 0x1000=FileMustExist; 0x800=PathMustExist; 0x4=HideReadOnly
 0, 0, # nFileOffset << 16 | nExtOffset; lpDefaultExt; lCustData; lpFnHook; lpTemplateName
 0, 0, 0].pack('L*') + # 04C4...0510: OPENFILENAME struct dialog_struct

# 0510: subroutine init:
[0x68, @_comdlg32_dllname, # 0510  push &comdlg32_dllname
 0xe8, LOAD_LIBRARY_ADDR-$lpNewAddr-0x51a, # 0515  call LoadLibraryA
 0x68, @_savedialog_funcname, 0x50, # 051A  push &savedialog_funcname; push eax
 0x68, @_opendialog_funcname, 0x50, # 0520  push &opendialog_funcname; push eax
 0xe8, GET_PROC_ADDR_ADDR-$lpNewAddr-0x52b, # 0526  call GetProcAddress
 0xa3, @_opendialog_addr, # 052b  mov [&opendialog_addr], eax
 0xe8, GET_PROC_ADDR_ADDR-$lpNewAddr-0x535, # 0530  call GetProcAddress
 0xa3, @_savedialog_addr, # 0535  mov [&savedialog_addr], eax

 0x006a, # 053A  push 0
 0x026a, # 053C  push 2 ;dwFlagsAndAttributes=FILE_ATTRIBUTE_HIDDEN
 0x046a, # 053E  push 4 ;dwCreationDisposition=OPEN_ALWAYS
 0x006a, # 0540  push 0
 0x076a, # 0542  push 7 ;dwShareMode=FILE_SHARE_(READ|WRITE|DELETE)
 0x68, GENERIC_READ, # 0544  push 80000000 ;dwDesiredAccess
 0x68, @_tmp_filename, # 0549  push &tmp_filename ;lpFileName
 0xe8, CREATE_FILE_ADDR-$lpNewAddr-0x553, # 054E  call CreateFileA
 0xf883, 0x74ff, 0x501a, # 0553  cmp eax, INVALID_HANDLE_VALUE; je (ret); push eax
 0x006a, # 0559  push 0
 0x68, @_bytesRead, # 055B  push &bytesRead
 0x016A, # 0560  push 1 ;nNumberOfBytesToRead=1
 0x68, @_tmp_id, # 0562  push &tmp_id ;lpBuffer
 0xe850, READ_FILE_ADDR-$lpNewAddr-0x56d, # 0567  push eax; call ReadFile
 0xe8, CLOSE_HANDLE_ADDR-$lpNewAddr-0x572, # 056D  call CloseHandle
 0x90c3 # 0572  ret; nop
].pack('CLClCLCCLCClCLClCLSSSSSCLCLClSSSSCLSCLSlClS') +

# 0574: subroutine loadtemp:
[0x3150, 0xa3c0, TEDIT8_MSGID_ADDR, 0xa0, @_tmp_id, 0xc8fe,
 0x45048b66, @_id_str, 0xa366, @tmp_id_addr,
 0xb8, FILE_HANDLE_ADDR, 0xa3, @_filename_pointer_addr, 0x00c7, @_tmp_filename,
 0x048b, 0xe824, LOAD_WORK_ADDR-$lpNewAddr-0x5a9, # 05A4...05A9  call TTSW10.loadwork
 0x05c7, @_filename_pointer_addr, FILENAME_ADDR, 0xe858, ITEM_LIVE_ADDR-$lpNewAddr-0x5b9, # 05B4...05B9  call TTSW10.itemlive
 0x3d80, TEDIT8_MSGID_ADDR, LOAD_SUCCESS_MSG_ID,
 0xb075, 0x0dfe, @_tmp_id].pack('SSLCLSLLSLCLCLSLSSlSLLSlSLCSSL') +

# 05C8: subroutine rec_tmpid:
[0x66, 0x05C7, @tmp_id_addr, 0x4449, 0x006a, 0x026a, 0x046a, 0x006a, 0x076a,
 0x68, GENERIC_WRITE, 0x68, @_tmp_filename,
 0xe8, CREATE_FILE_ADDR-$lpNewAddr-0x5ea, # 05E5...05EA  call CreateFileA
 0xf883, 0x74ff, 0x501a, 0x006a, 0x68, @_bytesRead, 0x016a, 0x68, @_tmp_id,
 0xe850, WRITE_FILE_ADDR-$lpNewAddr-0x604, # 05FF...0604  call WriteFile
 0xe8, CLOSE_HANDLE_ADDR-$lpNewAddr-0x609, # 0604...0609  call CloseHandle
 0xc3, 0x9090].pack('CSLSSSSSSCLCLClSSSSCLSCLSlClCS') +

# 060C: subroutine loadanydat:
[0xb850, @_dialog_struct, 0x40c7, 0x18, 1, 0x40c7, 0x30, @_title_load,
 0x40c7, 0x34, OFN_TSWSL_LOAD, 0x50, 0x15ff, @_opendialog_addr, 0xc085, 0x5b, 0x2874,
 0xb8, FILE_HANDLE_ADDR, 0xa3, @_filename_pointer_addr, 0x00c7, @_dat_filename,
 0xc38b, 0xe8, LOAD_WORK_ADDR-$lpNewAddr-0x64a, # 0645...064A  call TTSW10.loadwork
 0x05c7, @_filename_pointer_addr, FILENAME_ADDR,
 0xc38b, 0xe8, ITEM_LIVE_ADDR-$lpNewAddr-0x65b, # 0656...065B  call TTSW10.itemlive
 0xc3].pack('SLSCLSCLSCLCSLSCSCLCLSLSClSLLSClC') +

# 065C: subroutine saveanydat:
[0x006a, 0x006a, 0x036a, 0x006a, 0x076a, 0x006a, 0x68, @_dat_filename,
 0xe8, CREATE_FILE_ADDR-$lpNewAddr-0x672, # 066D...0672  call CreateFileA
 0xf883, 0x74ff, 0x505F, 0xe8, CLOSE_HANDLE_ADDR-$lpNewAddr-0x67d, # 0678...067D  call CloseHandle
 0xc031, 0xd231, 0xff3c, 0x2074, 0xa08a, @_dat_filename, 0xe484, 0x1674,
 0xfc80, 0x5c, 0x0974, 0xfc80, 0x2e, 0x0675, 0xc288, 0x02eb, 0xd688, 0xe430,
 0xc0fe, 0xdceb, 0xd638, 0x0273, 0xd088, 0x012c, 0x2772, 0x5657, 0xfc,
 0xb08d, @_dat_filename, 0xfe8b, 0xac, 0x302c, 0x092c, 0x0e72, 0x0a74,
 0xbe47, @_dat_suffix, 0xa5a5, 0x05eb, 0x0704, 0x3a04, 0xaa, 0x5f5e, 0x86eb,
 0xb8, @_dialog_struct, 0x40c7, 0x18, 1, 0x40c7, 0x30, @_title_save,
 0x40c7, 0x34, OFN_TSWSL_SAVE, 0x50, 0x15ff, @_savedialog_addr, 0xc085,
 0x0175, 0xc3, 0x05c7, TEDIT8_MSGID_ADDR, 9, 0xb9, @_dat_filename, 0x90
].pack('SSSSSSCLClSSSClSSSSSLSSSCSSCSSSSSSSSSSSSSCSLSCSSSSSLSSSSCSSCLSCLSCLSCLCSLSSCSLLCLC') +

# 070C: subroutine saveas:
"\x55\x8B\xEC\x6A\x00\x53\x56\x57\x31\xC0\x55\x68" +
[$lpNewAddr+0x7ac, 0xff64, 0x6430, 0x2089, 0xba, FILENAME_ADDR, 0x028b, 0xa3,
 @_filename_pointer_addr, 0x0a89, 0xa1, TTSW_ADDR, 0xe8, SAVE_WORK_ADDR-$lpNewAddr-0x73a
].pack('LSSSCLSCLSCLCl') + # 0735...073A call TTSW10.savework
"\x31\xC0\x5A\x59\x59\x64\x89\x10\x68" +
[$lpNewAddr+0x7b3, 0xba, FILENAME_ADDR, 0x0a8b, 0xbb, @_filename_pointer_addr].pack('LCLSCL') +
"\x8B\x03\x89\x02\x89\x13\x31\xC0\xB0\x03\xA3" +
[@_save_overwrite_dialog_style, 0x86b0, 0xa3, @_save_success_msg_tedit8_id, 0xba, TEDIT8_MSGID_ADDR,
 0x3a83, EMPTY2_MSG_ID, 0x3875, 0x02c6, 0xbb00, $lpNewAddr+0x7c0,
 0xd231, 0xf981, @_tmp_filename, 0x0c75, 0x20b2, 0xa166, @tmp_id_addr].pack('LSCLCLSCSSSLSSLSSSL') +
"\x66\x89\x43\x15\x88\x53\x0E\x53\x68" +
[$hWndText, 0xe8, SET_WINDOW_TEXT_ADDR-$lpNewAddr-0x79f, # 079A...079F  call SetWindowTextA
 0xa1, TTSW_ADDR, 0xe8, ITEM_LIVE_ADDR-$lpNewAddr-0x7a9, # 07A4...07A9  call TTSW10.itemlive
 0xc031, 0xe9c3, HANDLE_FINALLY_ADDR-$lpNewAddr-0x7b1 # 07AC...07B1  jmp HandleFinally
].pack('LClCLClSSl') + "\xEB\x94\x5F\x5E\x5B\x59\x5D\xC3\x90\x90\x90\0\0\0\0" +

$str::MSG_SAVE_UNSUCC.ljust(0x20, "\0") + # 07C0...07E0  string msg_save_unsucc

# 07E0: subroutine checkkey
"\x83\xE0\x7F\x83\x3C\x85#{[STATUS_ADDR].pack('L')}\x01\x7D\x0B\xC3\x90\x90" +
# 07F0: subroutine checkgold:
"\x3B\x05#{[GOLD_PRICE_ADDR].pack('L')}\x7C\xF5" +

# 07F8: subroutine savetemp:
[0xba, STATUS_ADDR, 0x428b, STATUS_INDEX[4]<<2, 0xe0c1, 0x04, 0x420b, STATUS_INDEX[7]<<2,
 0xe0c1, 0x04, 0x420b, STATUS_INDEX[6]<<2, 0xba, @_last_coordinate, 0x3b66, 0x02, 0x4474,
 0x8966, 0x3102, 0xa0c0, @_tmp_id, 0x8b66, 0x4504, @_id_str, 0xa366, @tmp_id_addr,
 0xc031, 0xa3, @_save_overwrite_dialog_style, 0xa3, @_save_success_msg_tedit8_id, 0xb0, EMPTY2_MSG_ID, 0xa3,
 TEDIT8_MSGID_ADDR, 0xb9, @_tmp_filename, 0xe8, offset_sub_saveas-0x84b, # 0846...084B  call sub_saveas
 0x0d74, 0x05fe, @_tmp_id, 0xe8, offset_sub_rec_tmpid-0x858, # 0853...0858  call sub_rec_tmpid
 0xc031, 0x90c3].pack('CLSCSCSCSCSCCLSCSSSSLSSLSLSCLCLCCCLCLClSSLClSS') +

# 085C: subroutine checkfloor:
[0xba, STATUS_ADDR, 0x428b, STATUS_INDEX[4]<<2].pack('CLSC') +
"\x83\xF8\x03\x74\x64\x83\xF8\x17\x74\x5F\x83\xF8\x2A\x74\x5A\x83\xF8\x20\x74\x2E\xBA" +
[@_last_coordinate].pack('L') +
"\x66\x8B\x02\x66\x3D\x95\x14\x74\x1B\x66\x3D\xA5\x19\x74\x15\x66\x3D\x85\x28\x74\x0F\x66\x3D\x75\x31\x74\x09\x66\x3D\x95\x0A\x75\x12\x80\x2A\x30\x80\x2A\x10\xEB\x0A\xFF\x4A" +
[STATUS_INDEX[4]<<2, 0x05c6, HERO_FACE_ADDR, 0xe801, offset_sub_savetemp-0x8b5, # 08B0...08B5  call sub_saveas
 0xba, STATUS_ADDR, 0x428b, STATUS_INDEX[4]<<2].pack('CSLSlCLSC') +
"\x83\xF8\x1F\x75\x0B\x40\x89\x42" +
[STATUS_INDEX[4]<<2, 0x05c6, HERO_FACE_ADDR, 0xc304, 0x9090].pack('CSLSS') +

# 08D0: subroutine checkitem:
[0x058b, ITEM_ID_ADDR].pack('SL') +
"\x83\xF8\x0C\x74\xF2\x50\x83\xF8\x09\x74\x05\x83\xF8\x0A\x75\x37\xBA" +
[STATUS_ADDR, 0x428b, STATUS_INDEX[4]<<2].pack('LSC') +
"\x83\x3C\x24\x09\x74\x08\x83\xF8\x01\x7C\x29\x48\xEB\x06\x83\xF8\x32\x7D\x21\x40\x6B\xC8\x7B\x8B\x42" +
[STATUS_INDEX[7]<<2, 0xc06b, 0xb, 0xc101, 0x428b, STATUS_INDEX[6]<<2, 0xc083, 0x8002, 0x08bc,
 MAP_ADDR, 0x7506, 0xe805, offset_sub_savetemp-0x922, # 091D...0922  call sub_savetemp
 0xc358].pack('CSCSSCSSSLSSlS')

    WriteProcessMemory.call_r($hPrc, $lpNewAddr, injBuf, injBuf.size, 0)

    compatibilizeExtSL(true)
    enableAutoSave($SLautosave)

    callFunc(@_sub_init)
  end
  def compatibilizeExtSL(bEnable, raiseErr=true)
    call = raiseErr ? :call_r : :call
    SL_PATCH_BYTES_1.each {|i| WriteProcessMemory.send(call, $hPrc, i[0]+BASE_ADDRESS, bEnable ? (i[3] % [instance_variable_get(i[4])].pack('L')) : i[2], i[1], 0)}
  end
  def enableAutoSave(bEnable, raiseErr=true)
    call = raiseErr ? :call_r : :call
    SL_PATCH_BYTES_2.each {|i| ad = i[0]+BASE_ADDRESS; WriteProcessMemory.send(call, $hPrc, ad, bEnable ? (i[3] % [instance_variable_get(i[4])-i[5]-ad].pack('l')) : i[2], i[1], 0)}
  end
  def raiseInvalDir(reason)
    if msgboxTxt(24, MB_ICONASTERISK | MB_OKCANCEL, $str::STRINGS[reason]) == IDCANCEL
      preExit; msgboxTxt(13); exit
    end
    SendMessage.call($hWnd, WM_COMMAND, CHANGE_SAVEDIR_MENUID, 0)
    init
  end
end

CallFuncCallBack = API::Callback.new('LLLL', 'L') {|hWnd, msgID, cData, res| writeMemoryDWORD(MIDSPEED_ADDR, MIDSPEED_ORIG)} # restore
def callFuncAsync(address) # return immediately, but exec callback after the message is completed
  writeMemoryDWORD(MIDSPEED_ADDR, address-MIDSPEED_ADDR-4)
  SendMessageCallback.call_r($hWnd, WM_COMMAND, MIDSPEED_MENUID, 0, CallFuncCallBack, 0)
end
def ignoreHotkey()
  while !PeekMessage.call($buf, 0, 0, 0, 1).zero? # discard all hotkey signals during this process
  end
end
def preExit() # finalize
  SL.enableAutoSave(false, false)
  SL.compatibilizeExtSL(false, false) # restore
  VirtualFreeEx.call($hPrc || 0, $lpNewAddr, 0, MEM_RELEASE)
  CloseHandle.call($hPrc || 0)
  for i in 1..4
    UnregisterHotKey.call(0, 1)
  end
end
def raise_r(*argv)
  preExit() # ensure all resources disposed
  raise(*argv)
end
def init()
  $hWnd = FindWindow.call(TSW_CLS_NAME, 0)
  $tID = GetWindowThreadProcessId.call($hWnd, $buf)
  $pID = $buf.unpack('L')[0]
  begin
    load('tswSLdebug.txt')
  rescue Exception
  end
  raise("Cannot find the TSW process and/or window. Please check if TSW V1.2 is currently running. tswSL has stopped.\n\nAs an advanced option, you can manually assign $pID, $tID and $hWnd in `tswSLdebug.txt'.") if $hWnd.zero? or $pID.zero? or $tID.zero?
  $hPrc = OpenProcess.call_r(PROCESS_VM_WRITE | PROCESS_VM_READ | PROCESS_VM_OPERATION, 0, $pID)
  tApp = readMemoryDWORD(TAPPLICATION_ADDR)
  $hWndTApp = readMemoryDWORD(tApp+OFFSET_OWNER_HWND)
  $TTSW = readMemoryDWORD(TTSW_ADDR)
  edit8 = readMemoryDWORD($TTSW+OFFSET_EDIT8)
  $hWndText = readMemoryDWORD(edit8+OFFSET_HWND)

  if Str.isCHN()
    alias :msgboxTxt :msgboxTxtW
  else
    alias :msgboxTxt :msgboxTxtA
  end

  $lpNewAddr = VirtualAllocEx.call_r($hPrc, 0, 4096, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE) # 1 page size
  SL.init
end

init()
failedHotkeys = ''
for i in 0..2
  m = SL_MODIFIERS[i & 1]
  k = SL_HOTKEYS[i >> 1]
  failedHotkeys += $str::STRINGS[21+i] % [m, k] if RegisterHotKey.call(0, 1+i, m, k).zero?
end
RegisterHotKey.call_r(0, 4, SL_MODIFIERS[1], SL_HOTKEYS[1]) # quit
msgboxTxt(11)
msgboxTxt(20, MB_ICONASTERISK, failedHotkeys) unless failedHotkeys.empty?

while GetMessage.call($buf, 0, 0, 0) > 0
  msg = $buf.unpack(MSG_INFO_STRUCT)
  next if msg[1] != WM_HOTKEY

  break if msg[2] == 4
  init if IsWindow.call($hWnd).zero? # reinit if TSW has quitted

  hasPopup = (API.focusTSW() != $hWnd) # bring that TSW game window to front end
  if hasPopup then msgboxTxt(27, MB_ICONASTERISK); next end
  case msg[2]
  when 1
    callFuncAsync(SL._sub_loadanydat) # if SendMessage is used here, GetOpenFileName can easily cause dead lock (freeze)
  when 2
    callFuncAsync(SL._sub_saveanydat)
  when 3
    callFunc(SL._sub_load_temp)
    ignoreHotkey()
    id = (readMemoryDWORD(SL._tmp_id)-1) & 0xFF
    res = readMemoryDWORD(TEDIT8_MSGID_ADDR)
    if res.zero?
      msg = $str::MSG_LOAD_UNSUCC % id
    else
      id = (id+1) & 0xFF if res == 0x85 # success; then the id has already been subtracted by 1
      len = SendMessage.call($hWndText, WM_GETTEXT, 640, $buf)
      if $buf[len-1, 1] == '.'
        len -= 1 # remove the tailing period
      elsif $buf[len-2, 2] == "\xA1\xA3"
        len -= 2 # remove the tailing full-width period
      end
      msg = $buf[0, len] + (' - auto%02X.tmp' % id)
    end
    SendMessage.call($hWndText, WM_SETTEXT, 0, msg)
  end
end
preExit
msgboxTxt(13)
