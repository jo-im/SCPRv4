class scpr.Cookie
    # Options:
    # * key (String) - The key for this cookie
    # * value (String) - The value of the cookie
    # * expireSeconds (Number) - The number of seconds that this cookie is valid
    @set: (options={}) ->
        if options.expireSeconds
            unixts = new Date().getTime()

            expiry = new Date(unixts + options.expireSeconds * 1000)
            expires = "; expires=" + expiry.toGMTString()
        else
            # Without an expiration date set, the cookie will
            # expire at the end of the session.
            expires = ""

        document.cookie = "#{options.key}=#{options.value}#{expires};path=/"


    @get: (name) ->
        match = document.cookie.match(new RegExp("#{name}=([^;]+)"))
        return match[1] if match
