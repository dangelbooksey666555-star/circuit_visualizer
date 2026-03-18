import xmind

hirFile = "file_exported_By_SKILL_script"
fileName = "top_92lv16.xmind"
workbook = xmind.load(fileName)
sheet1 = workbook.getPrimarySheet()

sheet1.setTitle("firstSheet")



id_node_dict = {}
templete = open(hirFile, "r")
for line in templete:
    newLine = line.strip()
    info = newLine.split("\t")
    cellMaster = info[0]
    level = int(info[1])
    id = int(info[2])
    author = info[5]
    date = info[4]
    if info[3] != "nil":
        pid = int(info[3])
        if pid  in id_node_dict:
            parentTopic = id_node_dict[pid]
        subTopic = parentTopic.addSubTopic()
        subTopic.setTitle(cellMaster)
        subTopic.addLabel(author)
        subTopic.addComment(date)
        id_node_dict[id] = subTopic
    else:
        rootTopic = sheet1.getRootTopic()
        rootTopic.setTitle(cellMaster)
        rootTopic.addLabel(author)
        rootTopic.addComment(date)
        id_node_dict[id] = rootTopic


xmind.save(workbook, fileName)
