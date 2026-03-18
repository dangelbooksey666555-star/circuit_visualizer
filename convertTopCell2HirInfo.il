defclass(CELL ()
    ( 
        (timeAndAuthor @initform "" @initarg timeAndAuthor)       
        (libName @initform nil @initarg libName)
        (cellName @initform nil @initarg cellName)   
        )
    ) ; defclass 


defclass(INST ()
    ( 
        (parent @initform nil @initarg parent)       
        (libName @initform nil @initarg libName)
        (cellName @initform nil @initarg cellName)
        (baseName @initform nil @initarg baseName)  
        (cell @initform nil @initarg cell) 
        (level @initform 0 @initarg level)     
        (id @initform 0 @initarg id)    
        )
    ) ; defclass 

procedure(flattenNetlist(topInstlibName topInstcellName outputFilePath pdkLibName)
let((InstName cellName)
    paramsTable = makeTable("paramsTable" nil)
    paramsTable['master_CELL_table] = makeTable("master_CELL_table" nil)
    paramsTable['id_INST_table] = makeTable("id_INST_table" nil)
    paramsTable['id] = 0
    paramsTable['port] = outfile(outputFilePath)
    paramsTable['pdkLibName] = pdkLibName
    searchHir_depthFirst(topInstlibName topInstcellName list() paramsTable)
    close(paramsTable['port])    
))


procedure(searchHir_depthFirst(topInstlibName topInstcellName l_excludedCellNameList paramsTable)
let((TOP_INSTANCE TOP_CELL researchedCellNames INSTs2search firstInst isNotExcluded isNotAnalyzed childrenOf1stobj firstInstCV)  
    DateAndAuthor = getSaveDateAndAuthor(topInstlibName topInstcellName)
    TOP_CELL = makeInstance('CELL ?libName topInstlibName ?cellName topInstcellName ?timeAndAuthor DateAndAuthor)
    masterName = buildString(list(topInstlibName topInstcellName) "|")
    paramsTable['master_CELL_table][masterName] = TOP_CELL  
    TOP_INSTANCE = makeInstance('INST ?libName topInstlibName ?cellName topInstcellName ?baseName topInstcellName ?id 0 ?cell TOP_CELL) 
    paramsTable['id_INST_table][0]=TOP_INSTANCE     
    printInfo(paramsTable['port] TOP_INSTANCE)
     
    researchedCellNames = list()
    INSTs2search = list(TOP_INSTANCE)       
    while(length(INSTs2search)!=0
            firstInst = car(INSTs2search)                                
            isNotExcluded = lindex(l_excludedCellNameList list(firstInst~>libName firstInst~>cellName))==nil
            firstInstMasterName = buildString(list(firstInst~>libName firstInst~>cellName) "|")
            if(isNotExcluded then               
               isNotAnalyzed = lindex(researchedCellNames firstInstMasterName)==nil
               if(!isNotAnalyzed then
                   childrenOf1stobj = list() 
                   else                                        
                    if(ddGetObj(firstInst~>libName firstInst~>cellName "schematic") then 
                      firstInstCV=dbOpenCellViewByType(firstInst~>libName firstInst~>cellName "schematic" "" "r")  
                      childrenOf1stobj = OPERATION(firstInst firstInstCV paramsTable);specify your operation here                                   
                      dbClose(firstInstCV)
                      else
                      childrenOf1stobj = list()                  
                  )
                 researchedCellNames = nconc(researchedCellNames list(firstInstMasterName))                                                         
              ) 
              else
              childrenOf1stobj = list()
         )             
         INSTs2search = nconc(childrenOf1stobj cdr(INSTs2search))
    );while 
);let
);procedure







procedure(OPERATION(firstInst firstInstCV paramsTable)
let((timeAndAuthor temp masterName_flag_table childrenOf1stobj masterName instance result)                                        
     temp = setof(inst firstInstCV~>instances inst~>libName!=paramsTable['pdkLibName]&&inst~>libName!="basic")                      
     masterName_flag_table = makeTable("masterName_flag_table" nil)
     childrenOf1stobj = list()
      foreach(inst temp 
          masterName = buildString(list(inst~>libName inst~>cellName) "|") 
          if(!masterName_flag_table[masterName] then
                 paramsTable['id]++  
                 if(!paramsTable['master_CELL_table][masterName] then                     
                     DateAndAuthor = getSaveDateAndAuthor(inst~>libName inst~>cellName)
                     instCell = makeInstance('CELL ?libName inst~>libName ?cellName inst~>cellName ?timeAndAuthor DateAndAuthor)
                     paramsTable['master_CELL_table][masterName] = instCell
                     else
                     instCell = paramsTable['master_CELL_table][masterName]
                 )
                 instance = makeInstance('INST ?libName inst~>libName ?cellName inst~>cellName ?baseName inst~>baseName ?parent firstInst ?level firstInst~>level+1 ?id paramsTable['id] ?cell instCell)     
                 paramsTable['id_INST_table][paramsTable['id]]=instance
                 printInfo2(paramsTable['port] instance)                                                       
                 childrenOf1stobj = nconc(childrenOf1stobj list(instance))  
                 masterName_flag_table[masterName] = t                      
             )
       ) 
    result = childrenOf1stobj
    result
))


procedure(getSaveDateAndAuthor(libName cellName)
let((cv result info infos saveDate author)
    if(ddGetObj(libName cellName "schematic") then
        cv = dbOpenCellViewByType(libName cellName "schematic" "" "r")
        info = car(setof(shape cv~>shapes shape~>objType=="label" && rexMatchp("^Info:Last save at .* BY .*" shape~>theLabel))~>theLabel)
        if(info then
            rexCompile( "Info:Last save at ")
            info = rexReplace(info "" 0)
            rexCompile( " BY ")
            info = rexReplace(info "|" 0)
        
            infos = parseString(info "|")
            saveDate = car(infos)
            rexCompile( " ")
            saveDate = rexReplace(saveDate "-" 0)
            author = cadr(infos)
            result = list(saveDate author)    
            else
            result = list("nil" "nil")
        )
        dbClose(cv)
        else
        result = list("nil" "nil")
    )
    result
))


procedure(printInfo(port Inst)
let(()
                       fprintf(port buildString(list(Inst~>libName Inst~>cellName) "|"))
                       fprintf(port "\t")
                       fprintf(port artMakeString(Inst~>level))
                       fprintf(port "\t")
                       fprintf(port artMakeString(Inst~>id))   
                       fprintf(port "\t")
                       fprintf(port artMakeString(Inst~>parent~>id))
                       fprintf(port "\t")
                       fprintf(port car(Inst~>cell~>timeAndAuthor))
                       fprintf(port "\t")
                       fprintf(port cadr(Inst~>cell~>timeAndAuthor))                                                                                                               
                       fprintf(port "\n")                       
))

procedure(printInfo2(port Inst)
let(()
    inst = Inst
    parent = Inst~>parent
    fprintf(port buildString(list(Inst~>libName Inst~>cellName) "|"))    
    while(parent
           fprintf(port " --> ")          
           inst = parent
           fprintf(port buildString(list(inst~>libName inst~>cellName inst~>baseName) "|"))
           parent = inst~>parent      
    )
    fprintf(port "\n")                     
))
