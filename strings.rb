# encoding: ASCII-8Bit
# CHN strings encoding is UTF-8

require './stringsGBK'

$isCHN = false
$str = Str::StrEN
module Str
  TTSW10_TITLE_STR_ADDR = 0x88E74 + BASE_ADDRESS
  APP_VERSION = '1.2'
  @strlen = 0
  module StrEN
    STRINGS = [
'','','','','','','','','','','', # 10
'tswSaveLoad is running.

Use hotkeys to enhance the Load/Save function:
* Alt+0     	= Load data from any file;
* Ctrl+Alt+0	= Save data to any file;
* Alt+Bksp  	= Take back the last move;
* Ctrl+Alt+Bksp	= Quit.',
'',
'tswSaveLoad has stopped.',
'','','','','','',

'The following hotkey(s) cannot be registered properly:
%s

These hotkeys might be currently occupied by other processes
or reserved by system. Please close any conflicting program, or
as an advanced option, you can manually set `SL_MODIFIERS`
and `SL_HOTKEYS` in `tswSLdebug.txt`.

Nevertheless, tswSL will remain running, and other hotkeys
still remain fully functional.', # 20
'Load data from file: Current is %d+ %d
',
'Save data to file  : Current is %d+ %d
',
'Take back one move : Current is %d+ %d
',
'The game\'s data storage path is %s.
A settings dialog box will pop up shortly; please set a new path there. Continue?',
'too short (< 2 bytes)', # 25
'too long (> 240 bytes)',
'The game now has an active popup child window;
please close it and then try again.',

'Inf', # -2
'.' # -1
    ]
  end

  module StrCN
    STRINGS = [
'','','','','','','','','','','', # 10
'tswSaveLoad（快捷存档）已开启。

使用以下快捷键增强存档和读档的游戏体验：
* Alt+0     	＝读档自任意文件；
* Ctrl+Alt+0	＝存档至任意文件；
* Alt+退格  	＝回退到上一节点；
* Ctrl+Alt+退格	＝退出。',
'',
'tswSaveLoad（快捷存档）已退出。',
'','','','','','',

'无法设立以下快捷键：
%s

这些快捷键可能已被系统或其他进程占用。请关闭
这些进程以避免冲突。或者可利用高级设置，在
`tswSLdebug.txt` 中手动赋值给 `SL_MODIFIERS` 和
`SL_HOTKEYS`。

不过，tswSL 仍将正常运行，其他快捷键仍有效。', # 20
'读档自文件：当前设置为 %d+ %d
',
'存档至文件：当前设置为 %d+ %d
',
'回退上一步：当前设置为 %d+ %d
',
'当前游戏的存档路径%s。
请在接下来的设置对话框中选定一个合适的新路径。',
'过短（< 2 字节）', # 25
'过长（> 240 字节）',
'当前游戏界面存在活动的弹出式子窗口，
请将其关闭后再重试。',

'∞', # -2
'。' # -1
    ]
  end

  module_function
  def utf8toWChar(string)
    arr = string.unpack('U*')
    @strlen = arr.size
    arr.push 0 # end by \0\0
    return arr.pack('S*')
  end
  def strlen() # last length
    @strlen
  end
  def isCHN()
    ReadProcessMemory.call_r($hPrc, TTSW10_TITLE_STR_ADDR, $buf, 32, 0)
    title = $buf[0, 32]
    if title.include?(APP_VERSION)
      if title.include?(StrEN::APP_NAME)
        $str = Str::StrEN
        return ($isCHN = false)
      elsif title.include?(StrCN::APP_NAME)
        $str = Str::StrCN
        return ($isCHN = true)
      end
    end
    raise_r('This is not a compatible TSW game: '+title.rstrip)
  end
end
