# tswSL
Tower of the Sorcerer for Windows SaveLoad / 魔塔英文原版快捷临时存读档

See Also / 另请参见: [tswKai（改）](https://github.com/Z-H-Sun/tswKai); [tswMovePoint（座標移動）](https://github.com/Z-H-Sun/tswMP)

![](/1.png)

## Scope of application / 适用范围
* This mod can only be applied to TSW English Ver 1.2. You can download its installer <ins>[here](https://ftp.vector.co.jp/14/65/3171/tsw12.exe)</ins> or visit [the official website](http://hp.vector.co.jp/authors/VA013374/game/egame0.html). You will have to run the executable **as administrator** to install. / 本修改器仅适用于英文原版魔塔V1.2，可于<ins>[此处](https://ftp.vector.co.jp/14/65/3171/tsw12.exe)</ins>下载其安装包，或[点此](http://hp.vector.co.jp/authors/VA013374/game/egame0.html)访问官网。必须右键**以管理员权限运行**才可成功安装。
* In addition, it is recommended to install <ins>[this patch archive file](https://github.com/Z-H-Sun/tswKai/raw/main/tsw.patch.zip)</ins> to improve game experience. For more information, please refer to [tswKai](https://github.com/Z-H-Sun/tswKai#game-experience-improvement--%E6%8F%90%E5%8D%87%E6%B8%B8%E6%88%8F%E4%BD%93%E9%AA%8C). / 此外，为提升游戏体验，推荐安装<ins>[此补丁压缩包](https://github.com/Z-H-Sun/tswKai/raw/main/tsw.patch.zip)</ins>（包括汉化版），详情请见 [tswKai](https://github.com/Z-H-Sun/tswKai#game-experience-improvement--%E6%8F%90%E5%8D%87%E6%B8%B8%E6%88%8F%E4%BD%93%E9%AA%8C)。

## Usage / 使用方法
* Download <ins>[tswSL](https://github.com/Z-H-Sun/tswSL/releases/latest/download/tswSL.exe)</ins> here. / 在此处下载 <ins>[tswSL](https://github.com/Z-H-Sun/tswSL/releases/latest/download/tswSL.exe)</ins>。
* Open tswSL followed by TSW. Otherwise, an error message will be prompted. / 先开魔塔再开 tswSL，否则报错。
* You will see a message box when you start and close tswSL. Press OK to continue. / 开启和关闭 tswSL 时会弹出提示框，点击确定继续。
* At anytime in the game: / 在游戏过程中随时：

  * To load temporary data #1, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd></kbd>, and to load temporary data #2, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>2</kbd></kbd>, and so on; / 按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd></kbd> 读取临时存档 #1，按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>2</kbd></kbd> 读取临时存档 #2，以此类推；
  * To save temporary data #1, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>1</kbd></kbd>, and to save temporary data #2, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>2</kbd></kbd>, and so on; / 按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>1</kbd></kbd> 保存临时存档 #1，按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>2</kbd></kbd> 保存临时存档 #2，以此类推；
  * To quit tswSL, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>0</kbd></kbd>. / 按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>0</kbd></kbd> 以退出 tswSL。
* Within one day, there are 8 spots in total for temporary savedata, and they are in addition to, and independent of, the 8 original savedata in TSW. / 在一天中，最多可以有 8 个临时存档，且这 8 个存档是独立于魔塔自带的存档系统运作的。
* The temporary savedata files are named `MMDDtmp_n` in the same folder as other data files of TSW, where `MMDD` is the current date, and `n` is 1-8. These temporary savedata will no longer take effect on another day, unless you manually rename the files. Therefore, you will have 8 additional spots for temporary savedata one day later. / 这些临时存档和其他魔塔数据文件存于同一文件夹下，文件名为 `月月日日tmp_n`，其中 `月月日日` 为当前日期，`n`为 1 至 8。除非手动更改文件名，这些临时存档仅当天有效。因此相当于过一天后就会重新有 8 个存档位置。

  * If you install TSW at the default location, you will find the datafiles at `C:\Program Files (x86)\Tower of the Sorcerer\Savedat`; / 如果 TSW 装在默认位置，则存档可在  `C:\Program Files (x86)\Tower of the Sorcerer\Savedat` 目录中找到；
  * If you are running WinVista and above, however, you might find your data saved at a subfolder of `%userprofile\AppData\Local\VirtualStore` instead of `C:\Program Files (x86)` (<ins>[Why?](https://answers.microsoft.com/en-us/windows/forum/windows_7-windows_programs/please-explain-virtualstore-for-non-experts/d8912f80-b275-48d7-9ff3-9e9878954227)</ins>). / 在 Vista 以后的 Windows 版本下，这些存档可能存于 `%userprofile\AppData\Local\VirtualStore` 的子目录下，而非 `C:\Program Files (x86)`（<ins>[为什么？](https://answers.microsoft.com/en-us/windows/forum/windows_7-windows_programs/please-explain-virtualstore-for-non-experts/d8912f80-b275-48d7-9ff3-9e9878954227)</ins>）。
* **New Feature in the latest release:** You can customize the filename of the tempdata to save or load (so you have infinite data spots to save now). / **新版功能**：可自定义临时存档的文件名（因此相当于拥有无限的存档空间）。

  * In the game, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd></kbd> or <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>9</kbd></kbd> to load or to save a filename-customizable tempdata. / 在游戏中，按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd></kbd> 或 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>9</kbd></kbd> 以读取 / 保存一个可自定义文件名的存档。
  * A text-editable combo box will appear at the bottom-right corner of the TSW window (see figure above); select or type the desired filename; / 游戏窗口右下角将出现一个可编辑文字的组合框，在其中选择或键入欲设置的文件名；
  
    * The upper limit of the length is 9 bytes, and note each CJK character is 2-byte; / 长度上限为 9 字节，注意每个中日韩字符占 2 字节；
    * You can even save the file to a subfolder by including a separater `\`, but this folder must exist; / 甚至可以在文本中包含目录分隔符 `\` 来将文件存至一个子目录中，但前提是该子目录存在；
  * Then, press <kbd>Enter</kbd> to confirm or press <kbd>ESC</kbd> to cancel. / 随后，按 <kbd>Enter</kbd> 确定或按 <kbd>ESC</kbd> 取消。

## Troubleshooting / 疑难解答
* **Cannot find the TSW process and/or window**: Please check if TSW V1.2 is currently running. / **找不到魔塔进程或窗口**：请检查是否已经打开魔塔 1.2 版本。
* **Cannot register hotkey**: A list of unavailable hotkeys will be provided. The hotkeys might be currently occupied by other processes or another instance of tswSL. Please close them to avoid confliction. / **无法注册热键**：程序将会列出所有无法注册的快捷键。这些快捷键可能已被其他程序抢占，或另一个 tswSL 程序正在运行。尝试关闭它们以避免冲突。
* **Cannot find SAVEDAT_PATH**: If you install TSW elsewhere, though unlikely, tswSL might be unable to find the folder to save datafiles to, so the combo box cannot list the existing datafiles in that folder. This will not, however, affect the normal operation. / **无法找到存档路径**：如果 TSW 装在非默认位置，由极小的可能 tswSL 无法找到存档路径，因此无法在组合框中列出目录下的所有存档文件。但这并不影响正常使用。
* For the above three issues, as an advanced option, you can create a plain text file named `tswSLdebug.txt` in the current folder (*[example here](/tswSLdebug.txt)*), which will be loaded by the program, and then you can manually assign `$hWnd`, `$pID`, `SAVEDAT_PATH`, `MODIFIER`, or `KEY` there. / 针对上述三个问题的高级解决方案：可在当前目录下新建一名为 `tswSLdebug.txt` 的纯文本文档（[参考此样例](/tswSLdebug.txt)，其中内容将被程序所读取），然后在其中手动给`$hWnd`、`$pID`、`SAVEDAT_PATH`、`MODIFIER`、`KEY`赋值。
* **Cannot find the status bar**: It means just that, and thus tswSL cannot show tip texts there. However, it will not affect the normal operation. It is likely that the TSW process is still loading, so try restarting tswSL later. / **无法找到状态栏**：如字面意思所言。因此 tswSL 将无法在状态栏显示提示文本，但并不影响正常使用。有可能 TSW 进程仍在加载中，因此可尝试稍后重启 tswSL。
* **Cannot open the TSW process for writing / write to the TSW process**: C'est la vie (not likely, though). You can check if the PID of TSW you are running is indeed the one shown in the prompt. / **无法打开魔塔进程/将数据写入魔塔进程**：无解（但不太可能发生）。你可以检查下目前正在运行的魔塔程序的进程号是否匹配提示框中的数字。
