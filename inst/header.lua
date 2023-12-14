local moodle_category = [[
<question type="category">
  <category>
    <text>$course$/%s</text>
  </category>
</question>
]]

local base_category = nil
local cloze_pattern = "{%d+:"

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
  return pandoc.Div({}, elem.attr)
end


function moodlequiz_meta(meta)
  if (meta.moodlequiz ~= nil and meta.moodlequiz.category ~= nil) then
    base_category = pandoc.utils.stringify(meta.moodlequiz.category)
  end
end

function header_questions(doc)
  local hblocks = {}
  local category_idx = 0
  local in_question = false
  local n_questions = 0

  -- Set base category if specified
  if base_category ~= nil then
    category_idx = category_idx + 1
    table.insert(hblocks, pandoc.Div({}, pandoc.Attr('', {'question'}, {type = 'category', category = base_category})))
  end

  -- Re-organise headers into questions containing following elements
  for _,el in pairs(doc.blocks) do
    if (el.t ~= "Header" or el.level > 2 or el.classes[1] == "header") then
      -- If a question div hasn't yet been opened, create one.
      if (not in_question) then
        in_question = true
        category_idx = category_idx + 1
        n_questions = n_questions + 1
        table.insert(hblocks, pandoc.Div({}, pandoc.Attr('', {'question'})))
      end
      hblocks[category_idx].content:insert(el)
    elseif (el.t == "Header") then
      category_idx = category_idx + 1

      el.classes = {'question'}
      el.attributes.name = pandoc.utils.stringify(el.content[1])

      in_question = (el.level == 2)
      if (not in_question) then
        el.attributes.type = 'category'
        if (el.attributes.category == nil) then
          if base_category ~= nil then
            el.attributes.category = base_category .. "/" .. el.identifier
          else
            el.attributes.category = el.identifier
          end
        end
      else
        n_questions = n_questions + 1
      end

      table.insert(hblocks, pandoc.Div({}, el.attr))
    end
  end

  question_name_fmt = "Q%0" .. tostring(n_questions):len() .. "i: %s"
  question_num = 0
  for i,el in pairs(hblocks) do
    -- Look for cloze tags to set default question type 'description' or 'cloze'
    if (el.attributes.type == nil) then
      has_cloze = false
      el.content:walk {
        RawInline = function(el)
          if(el.text:find(cloze_pattern) ~= nil) then has_cloze = true end
        end,
        CodeBlock = function(el)
          if(el.text:find(cloze_pattern) ~= nil) then has_cloze = true end
        end
      }
      if has_cloze then
        hblocks[i].attributes.type = 'cloze'
      else
        hblocks[i].attributes.type = 'description'
      end
    end
    -- Add question number prefix for ordering
    if (el.attributes.type ~= "category") then
      question_num = question_num + 1
      hblocks[i].attributes.name = question_name_fmt:format(question_num, el.attributes.name)
    end
  end


  return pandoc.Pandoc(hblocks, doc.meta)
end

return {
  {
    Meta = moodlequiz_meta
  },
  {
    Pandoc = header_questions
  }
}
