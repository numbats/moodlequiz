local question_before = [[
<question type="%s">
<name><text>%s</text></name>
<questiontext format="html">
<text><cdata>
]]

local question_after = [[
</cdata></text>
</questiontext>
<defaultgrade>%s</defaultgrade>
<generalfeedback>
<text></text>
</generalfeedback>
<shuffleanswers>0</shuffleanswers>
</question>
]]

function Div (elem)
  if elem.classes[1] == "question" then
    local before = pandoc.RawBlock('html', string.format(question_before, elem.attributes['type'], elem.attributes['name']))
    local after = pandoc.RawBlock('html', string.format(question_after, elem.attributes['defaultgrade']))

    local question = elem.content
    table.insert(question, 1, before)
    table.insert(question, after)

    return question
  else
    return elem
  end
end
