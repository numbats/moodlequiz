local question_before = [[
<question type="%s">
<questiontext format="html">
<text><cdata>
]]

local question_after = [[
</cdata></text>
</questiontext>
]]

local question_end = [[
</question>
]]

function Div (elem)
  if elem.classes[1] == "question" then
    local before = pandoc.RawBlock('html', string.format(question_before, elem.attributes['type']))
    local after = pandoc.RawBlock('html', question_after)

    local question = elem.content
    table.insert(question, 1, before)
    table.insert(question, after)
    for k,v in pairs(elem.attributes) do
      if k~='type' then
        if k=='name' then v = string.format([[<text>%s</text>]], v) end
        if k=='category' then v = string.format([[<text>$course$/%s</text>]], v) end
        table.insert(question, pandoc.RawBlock('html', string.format([[<%s>%s</%s>]], k, v, k)))
      end
    end

    table.insert(question, pandoc.RawBlock('html', question_end))

    return question
  else
    return elem
  end
end
