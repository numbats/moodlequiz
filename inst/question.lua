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

local function create_dom_element(element, kv)
  local attributes = ""
  for key, value in pairs(kv) do
    attributes = attributes .. string.format(' %s="%s"', key, value)
  end

  -- Create the <answer> opening tag
  local open_element = pandoc.RawBlock("html", "<" .. element .. attributes .. ">")
  return open_element

  -- local answer_close_tag = pandoc.RawBlock("html", "</answer>")
end

local function answer_block(answers)
  -- Create the <answer> element with attributes
  local answer_open_tag = create_dom_element("answer", answers.attr.attributes)
  local answer_close_tag = pandoc.RawBlock("html", "</answer>")

  -- Wrap the content inside <text><![CDATA[]]></text>
  local text_open_tag = pandoc.RawBlock("html", "<text><cdata>")
  local text_close_tag = pandoc.RawBlock("html", "</cdata></text>")

  answer = answers.content
  print(answers)

  -- Combine all parts into a single block
  table.insert(answer, 1, answer_open_tag)
  table.insert(answer, 2, text_open_tag)
  table.insert(answer, text_close_tag)
  table.insert(answer, answer_close_tag)

  print(answer)

  return answer
end

function Div (elem)
  if elem.classes[1] == "question" then
    local before = pandoc.RawBlock('html', string.format(question_before, elem.attributes['type']))
    local after = pandoc.RawBlock('html', question_after)

    local answers = {}

    -- Walk question content for answer and subquestion divs
    local question = elem.content:walk {
      Div = function(el)
        -- Check if the div has the class "answer"
        print(el)
        if el.classes[1] == "answer" then
          -- Append the content of the answer div to the answers table
          table.insert(answers, answer_block(el))

          -- Remove the div from the question content
          return {}
        end
        -- Otherwise, return the element unchanged
        return el
      end
    }

    table.insert(question, 1, before)
    table.insert(question, after)

    -- Add answers
    if #answers > 0 then
      for _, answer in ipairs(answers) do
        for _, part in ipairs(answer) do
          table.insert(question, part)
        end
      end
    end

    -- Add question attributes
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
