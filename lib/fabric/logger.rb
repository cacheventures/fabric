class Logger
  def json_info(str, hash)
    info [str, hash.to_json].join(' ')
  end

  def json_debug(str, hash)
    debug [str, hash.to_json].join(' ')
  end
end
