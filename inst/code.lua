function CodeBlock (block)
  block.text = string.gsub(block.text, '`({[^`]+})`{=html}', '%1')
  return block
end

function RawBlock (block)
  block.text = string.gsub(block.text, '`({[^`]+})`{=html}', '%1')
  return block
end
