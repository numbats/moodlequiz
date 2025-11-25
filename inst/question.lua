-- TODO: find out how to pass <![CDATA[ ... ]] through pandoc 
--       to avoid post-processing <cdata> ... </cdata> in R
local question_str = [=[
<question type="%s">
<questiontext format="html">
<text>
<![CDATA[
%s
]]
</text>
</questiontext>
</question>
]=]

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

-- Helper: convert blocks to plain text
local function blocks_to_plain(blocks)
  -- stringify: convert blocks to a Pandoc doc and then to plain text
  local doc = pandoc.Pandoc(blocks)
  return pandoc.write(doc, "plain")
end


-- Helper: convert blocks to rich html text
local function blocks_to_html(blocks)
  local doc = pandoc.Pandoc(blocks)
  return pandoc.write(doc, "html")
end

local function open_dom_elements(element, kv)
  local attributes = ""
  for key, value in pairs(kv) do
    attributes = attributes .. string.format(' %s="%s"', key, value)
  end

  -- Create the <answer> opening tag
  return "<" .. element .. attributes .. ">"
end

local function answer_block(answers, plaintext)
  plaintext = plaintext ~= false  -- default true

  -- Get the content as a single string
  local content, answer_fmt
  if plaintext then
    content = blocks_to_plain(answers.content)
    answer_fmt = [=[
<text>
%s
</text>
]=]
  else
    content = blocks_to_html(answers.content)
    answer_fmt = [=[
<text><cdata>
%s
</cdata></text>
]=]
  end

  -- New list of blocks we will return
  local out = {}

  -- Construct <answer></answer> tags with attributes
  local answer_open_tag = open_dom_elements("answer", answers.attr.attributes)
  local answer_close_tag = "</answer>"

  ans = answer_open_tag .. string.format(answer_fmt, content) .. answer_close_tag

  table.insert(out, pandoc.RawBlock("html", ans))

  return out
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
        if el.classes[1] == "answer" then
          -- Append the content of the answer div to the answers table
          table.insert(answers, answer_block(el, elem.attributes['type'] == 'truefalse'))

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
