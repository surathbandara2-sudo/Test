local Rules={}
function Rules.validVote(index,choiceCount)
 return typeof(index)=="number" and index==index and index%1==0 and index>=1 and index<=choiceCount
end
function Rules.winnerIndices(counts)
 local best=-1; local tied={}
 for index,count in ipairs(counts) do
  if count>best then best=count; tied={index} elseif count==best then table.insert(tied,index) end
 end
 return tied
end
return Rules
