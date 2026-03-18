0.安装XMIND whl包

1.首先在cadence的CIW加载convertTopCell2HirInfo.il：
loadi("/你的路径/convertTopCell2HirInfo.il")

2.然后在CIW运行：
flattenNetlist(topInstlibName topInstcellName outputFilePath pdkLibName)
topInstlibName是TOPcell的库名
topInstcellName是cell名
outputFilePath是导出的层次化信息文件路径
pdkLibName是工艺库的名字

3.更改ConvertHirInfo2Xmind的HirFile为层次化信息文件路径，然后运行python脚本。



