local moodle_category = [[
<question type="category">
  <category>
    <text>$course$/%s</text>
  </category>
</question>
]]

function process_header (elem)
  if (elem.classes[1] == "header" or elem.level > 2) then return elem end
  elem.classes = {'question'}
  elem.attributes.name = pandoc.utils.stringify(elem.content[1])
  if (elem.level == 1) then
    elem.attributes.type = 'category'
    if (elem.attributes.category == nil) then
      elem.attributes.category = elem.identifier
    end
  end
  if (elem.attributes.type == nil) then
    elem.attributes.type = 'cloze'
  end
  return pandoc.Div({}, elem.attr)
end

function Pandoc(doc)
  local hblocks = {}
  local category_idx = 0
  local in_question = false
  for i,el in pairs(doc.blocks) do
    if (el.t ~= "Header" or el.level > 2 or el.classes[1] == "header") then
      -- If a question div hasn't yet been opened, create one.
      if (not in_question) then
        in_question = true
        category_idx = category_idx + 1
        table.insert(hblocks, process_header(pandoc.Header(2, 'Unnamed question', pandoc.Attr())))
      end
      hblocks[category_idx].content:insert(el)
    elseif (el.t == "Header") then
      category_idx = category_idx + 1
      table.insert(hblocks, process_header(el))
    end
  end
  return pandoc.Pandoc(hblocks, doc.meta)
end
