local function strip_code_spans(text)
  local out = {}
  local i = 1
  local n = #text

  while i <= n do
    local s, e = text:find("`%{", i)  -- find "`{"
    if not s then
      table.insert(out, text:sub(i))
      break
    end

    -- copy everything before the code span
    table.insert(out, text:sub(i, s - 1))

    -- find matching '}' with brace counting
    local j = e + 1
    local depth = 1
    while j <= n and depth > 0 do
      local c = text:sub(j, j)
      if c == "{" then
        depth = depth + 1
      elseif c == "}" then
        depth = depth - 1
      end
      j = j + 1
    end
    if depth > 0 then
      -- no matching }, bail out and copy rest
      table.insert(out, text:sub(s))
      break
    end
    local brace_end = j - 1  -- position of matching '}'

    -- now we expect "`{=html}" starting at brace_end+1
    local after = text:sub(brace_end + 1)
    local m = after:match("^`%{=html%}")
    if not m then
      -- not the pattern we want; copy as-is and continue
      table.insert(out, text:sub(s, brace_end))
      i = brace_end + 1
    else
      -- keep just the {...} (without backticks / {=html})
      table.insert(out, text:sub(s + 1, brace_end)) -- from '{' to '}'
      i = brace_end + #"`{=html}" + 1
    end
  end

  return table.concat(out)
end

function CodeBlock (block)
  block.text = strip_code_spans(block.text)
  return block
end

function RawBlock (block)
  block.text = strip_code_spans(block.text)
  return block
end
