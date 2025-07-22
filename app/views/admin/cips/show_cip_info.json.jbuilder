unless @cip.nil?
  json.extract! @cip, :created_at
end