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
* Ctrl+L    	= Load data from any file;
* Ctrl+S    	= Save data to any file;
* Bksp      	= Rewind to the prev snapshot;
* Shift+Bksp	= Fast-forward to next snapshot.
* Ctrl+Alt+Bksp	= Quit.',
'',
'tswSaveLoad has stopped.',
'','','','','','',

'-- tswKai3 --  
Waiting for   
TSW to start ', # 20
'Do you want to stop waiting for the TSW game to start?

Choose "Yes" to quit this app; "Cancel" to do nothing;
"No" to continue waiting but hide this status window,
and you can press F7 or F8 to show it again later.',

'','',
'The game\'s data storage path is %s.
A settings dialog box will pop up shortly; please set a
new path there. Continue?',
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
* Ctrl+L    	＝读档自任意文件；
* Ctrl+S    	＝存档至任意文件；
* 退格      	＝回退到上一节点；
* Shift+退格	＝快进到下一节点。
* Ctrl+Alt+退格	＝退出。',
'',
'tswSaveLoad（快捷存档）已退出。',
'','','','','','',

'-- tswKai3 --  
正在等待魔塔
主进程启动…', # 20
'是否停止等待魔塔主程序 TSW 启动？

按“是”将退出本程序；按“取消”则继续待机；
按“否”也将继续等待，但会隐藏此状态窗口，
之后可按 F7 或 F8 等快捷键重新显示。',

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
    return true if $isCHN == 1 # always use Chinese
    return false if $isCHN == nil # always use English
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
