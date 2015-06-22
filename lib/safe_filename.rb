class SafeFilename
  FALLBACK_CHARS = {"À"=>"A", "Á"=>"A", "Â"=>"A", "Ã"=>"A", "Ä"=>"A", "Å"=>"A", "Æ"=>"A", "Ç"=>"C", "È"=>"E", "É"=>"E", "Ê"=>"E", "Ë"=>"E", "Ì"=>"I", "Í"=>"I", "Î"=>"I", "Ï"=>"I", "Ñ"=>"N", "Ò"=>"O", "Ó"=>"O", "Ô"=>"O", "Õ"=>"O", "Ö"=>"O", "Ø"=>"O", "Ù"=>"U", "Ú"=>"U", "Û"=>"U", "Ü"=>"U", "Ý"=>"Y", "à"=>"a", "á"=>"a", "â"=>"a", "ã"=>"a", "ä"=>"a", "å"=>"a", "æ"=>"a", "ç"=>"c", "è"=>"e", "é"=>"e", "ê"=>"e", "ë"=>"e", "ì"=>"i", "í"=>"i", "î"=>"i", "ï"=>"i", "ñ"=>"n", "ò"=>"o", "ó"=>"o", "ô"=>"o", "õ"=>"o", "ö"=>"o", "ø"=>"o", "ù"=>"u", "ú"=>"u", "û"=>"u", "ü"=>"u", "ý"=>"y", "ÿ"=>"y", "’"=>"'", "Š"=>"S", "š"=>"s", "Ð"=>"Dj", "Ž"=>"Z", "ž"=>"z", "Þ"=>"B", "ß"=>"Ss", "ð"=>"o", "þ"=>"b", "ƒ"=>"f"}
  def initialize app
    @app = app
  end
  def call env
    if (form_hash = env["rack.request.form_hash"]) && form_hash.has_key?('safe_filename')
      env["rack.request.form_hash"] = sanitize_hash(env["rack.request.form_hash"])
    end
    @app.call env
  end
  def sanitize_hash input
    if input.respond_to? :each_key
      input.each_pair do |k, v|
        input[k] = sanitize_pair k, v
      end
    end
    input
  end

  def sanitize string
    decoded_value = string.force_encoding("UTF-8")
    decoded_value.encode("US-ASCII", :fallback => self.method(:fallback)).gsub(" ", "_")
  rescue
    decoded_value.encode("US-ASCII", invalid: :replace, undef: :replace, replace: "_").gsub(" ", "_")
  end

  private

  def fallback char
    FALLBACK_CHARS[char] || "_"
  rescue
    "_" 
  end

  def sanitize_pair key, value
    if key.to_s.match(/file[_\s]*name/i) && value.is_a?(String)
      sanitize value
    elsif value.is_a? Hash
      sanitize_hash value
    else
      value
    end
  end
end