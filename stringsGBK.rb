# encoding: ASCII-8Bit
# CHN strings encoding is GBK

module Str
  module StrEN
    APP_NAME = 'Tower of the Sorcerer'
    DIALOG_FILTER_STR = "Game Data (*.dat)\0*.dat\0Temp Data (*.tmp)\0*.tmp\0All Files\0*.*\0\0"
    TITLE_LOAD_STR = 'Load Data'
    TITLE_SAVE_STR = 'Save Data'
    MSG_LOAD_UNSUCC = 'Game not loaded - auto%02X.tmp'
    MSG_SAVE_UNSUCC = 'Game not saved - autoID.tmp'
  end
  module StrCN
    APP_NAME = '魔塔'
    DIALOG_FILTER_STR = "游戏存档 (*.dat)\0*.dat\0临时存档 (*.tmp)\0*.tmp\0所有文件\0*.*\0\0"
    TITLE_LOAD_STR = '读档自文件'
    TITLE_SAVE_STR = '存档至文件'
    MSG_LOAD_UNSUCC = '无法读取存档 - auto%02X.tmp'
    MSG_SAVE_UNSUCC = '当前游戏未存档 - autoID.tmp'
  end
end