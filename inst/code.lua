function CodeBlock (block)
  block.text = string.gsub(block.text, '`([^`]+)`{=html}', '%1')
  return block
end
