# tswSL
Tower of the Sorcerer for Windows SaveLoad / 魔塔英文原版快捷临时存读档

See Also / 另请参见: [tswKai（改）](https://github.com/Z-H-Sun/tswKai); [tswMovePoint（座標移動）](https://github.com/Z-H-Sun/tswMP); [tswBGM（背景音乐）](https://github.com/Z-H-Sun/tswBGM)

***\* A visual user guide can be found here! / 用法视频详解参见此处！*** <ins>[BV1n341117tw](https://www.bilibili.com/video/BV1n341117tw)</ins>

***\* Note that there have been updates since the video was published. See the documentations for the usage of the latest version. / 请注意视频发布后有新的更新，因此最新版本的用法请参照文档***

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
* **New Feature since V2.022:** You can customize the filename of the tempdata to save or load (so you have infinite data spots to save now). / **自 2.022 版起功能**：可自定义临时存档的文件名（因此相当于拥有无限的存档空间）。

  * In the game, press <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd></kbd> or <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>9</kbd></kbd> to load or to save a filename-customizable tempdata. / 在游戏中，按 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd></kbd> 或 <kbd><kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>9</kbd></kbd> 以读取 / 保存一个可自定义文件名的存档。
  * A text-editable combo box will appear at the bottom-right corner of the TSW window (see figure above); select or type the desired filename; / 游戏窗口右下角将出现一个可编辑文字的组合框，在其中选择或键入欲设置的文件名（见上图）；
  
    * There is no more length limit on filename length since V2.022; / 自 2.022 版起解决了文件名长度上限问题（目前无上限）；
    * You can even save the file to a subfolder by including a separater `\` (since v2.022, the folder will be automatically created if it does not exist as long as `SAVEDAT_PATH` is found); / 甚至可以在文本中包含目录分隔符 `\` 来将文件存至一个子目录中（自 2.022 版起，若文件夹不存在则将自动创建，只要程序能找到 `SAVEDAT_PATH`）；
  * **Data management function since V2.023**: After selecting or typing the filename of interest in the combobox, you can press <kbd>Delete</kbd> to delete that data file. To enable this function, `SAVEDAT_PATH` must be either found or defined in the program. / **自 2.023 版起提供存档管理功能**：在组合框中选中或键入目标存档的文件名，然后按 <kbd>Delete</kbd> 键删除，前提是程序能找到或用户自己定义 `SAVEDAT_PATH`。
  * Then, press <kbd>Enter</kbd> to confirm or press <kbd>ESC</kbd> to cancel. / 随后，按 <kbd>Enter</kbd> 确定或按 <kbd>ESC</kbd> 取消。
* **New Feature since V2.023:** You can now have tsSL running in the background all the time; whenever a new TSW process is opened, the target of tswSL will be automatically switched to that process. Previously, if you quit and reopen another instance of TSW, you will have to close and reopen tswSL as well. / 现在可以在后台一直保持 tswSL 运行，即使新开另一个 TSW 进程，tswSL 也会自动切换作用对象为当前 TSW 进程。之前的版本中，如果退出 TSW 后重开，则 tswSL 也需要退出重开。
* Supplementary note: The timestamp, `MMDD`, in the filenames of temporary savedata reflects the date you start an instance of TSW: If you never quit TSW, the timestamp will not change even if days have passed; however, if you restart TSW on a different day, the timestamp will change. / 补充说明：临时存档文件名中的时间戳 `月月日日` 反映的是开启对应 TSW 进程的日期，因此，如果你一直不关 TSW，那么即使到第二天，时间戳也不会更改；反之如果到第二天关掉先前进程并重启 TSW，那么时间戳将更改。

## Troubleshooting / 疑难解答
* **Cannot find the TSW process and/or window**: Please check if TSW V1.2 is currently running. / **找不到魔塔进程或窗口**：请检查是否已经打开魔塔 1.2 版本。
* **Cannot register hotkey**: A list of unavailable hotkeys will be provided. The hotkeys might be currently occupied by other processes or another instance of tswSL. Please close them to avoid confliction. / **无法注册热键**：程序将会列出所有无法注册的快捷键。这些快捷键可能已被其他程序抢占，或另一个 tswSL 程序正在运行。尝试关闭它们以避免冲突。
* **Cannot find SAVEDAT_PATH**: If you install TSW elsewhere, though unlikely, tswSL might be unable to find the folder to save datafiles to, so the combo box cannot list the existing datafiles in that folder, and the data management function will not work. This will not, however, affect the normal operation. Another possibility is that you, as a developer, are running the source code `tswSL.rbw` directly in a Ruby environment; in such a case, please refer to the next section. / **无法找到存档路径**：如果 TSW 装在非默认位置，由极小的可能 tswSL 无法找到存档路径，因此无法在组合框中列出目录下的所有存档文件，且无法使用存档管理功能。但这并不影响其他正常使用。另一个可能是你作为开发者用了 Ruby 环境直接运行 `tswSL.rbw` 源码，那么请参考下一节中的说明。
* For the above three issues, as an advanced option, you can create a plain text file named `tswSLdebug.txt` in the current folder (*[example here](/tswSLdebug.txt)*), which will be loaded by the program, and then you can manually assign `$hWnd`, `$pID`, `SAVEDAT_PATH`, `MODIFIER`, or `KEY` there. / 针对上述三个问题的高级解决方案：可在当前目录下新建一名为 `tswSLdebug.txt` 的纯文本文档（[参考此样例](/tswSLdebug.txt)，其中内容将被程序所读取），然后在其中手动给`$hWnd`、`$pID`、`SAVEDAT_PATH`、`MODIFIER`、`KEY`赋值。
* **Cannot find the status bar**: It means just that, and thus tswSL cannot show tip texts there. However, it will not affect the normal operation. It is likely that the TSW process is still loading, so try restarting tswSL later. / **无法找到状态栏**：如字面意思所言。因此 tswSL 将无法在状态栏显示提示文本，但并不影响正常使用。有可能 TSW 进程仍在加载中，因此可尝试稍后重启 tswSL。
* **Cannot open the TSW process for writing / write to the TSW process**: C'est la vie (not likely, though). You can check if the PID of TSW you are running is indeed the one shown in the prompt. / **无法打开魔塔进程/将数据写入魔塔进程**：无解（但不太可能发生）。你可以检查下目前正在运行的魔塔程序的进程号是否匹配提示框中的数字。


## Developers / 我是开发者
* If you feel it unsafe to use the executable I provide, or you would like to modify the source code, you can run the source code ([tswSL.rbw](/tswSL.rbw)) yourself, but you have to install [Ruby](https://www.ruby-lang.org/) runtime. It is fine to use any version, from 1.8 to the latest 3.1 version. / 如果你认为此处提供的可执行文件不安全，或者你想自己改代码，你可以自己运行源码（[tswSL.rbw](/tswSL.rbw)），但你得首先安装 [Ruby](https://www.ruby-lang.org/) 环境。你可以随便挑选任何一个版本，从 1.8 到最新的 3.1 都行。
  * If you are using a relatively new Ruby interpreter, it is likely that `tswSL` cannot find `SAVEDAT_PATH`. This is because the interpreter `rubyw.exe` has a UAC manifest while TSW does not; as a result, TSW saves in `VirtualStore` (see above) while Ruby will look for the real directory. Do not panic, you can manually define `SAVEDAT_PATH` in `tswSLdebug.txt` as demonstrated in the previous section; do use the `VirtualStore` path. / 如果你使用了一个较新版本的 Ruby 解释器，那么很有可能会导致 `tswSL` 无法找到 `SAVEDAT_PATH`。这是因为 `rubyw.exe` 解释器有一个 UAC 清单 (manifest)，而 TSW 没有；这会导致 TSW 会存储在 `VirtualStore` 下（虚拟目录，见上），而 Ruby 找的却是实际目录。不要急，可用像上一节中说明的那样在 `tswSLdebug.txt` 里手动指定 `SAVEDAT_PATH`，此时务必要使用虚拟目录的路径。
* The executable can be generated by [`ExeRb`](https://osdn.net/projects/exerb/). Note that the newest version that supports ExeRB was **Ruby 1.8.7**. / 可执行文件可用 [`ExeRb`](https://osdn.net/projects/exerb/) 生成。注意与它兼容的最新版本是 **Ruby 1.8.7**。
