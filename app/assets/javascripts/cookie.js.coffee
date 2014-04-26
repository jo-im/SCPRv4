class scpr.Cookie
    @set: (name, value, expireSeconds) ->
        if expireSeconds
            expiry = new Date() + expireSeconds
            expires = "; expires=" + expiry.toGMTString()
        else
            # Without an expires date set, the cookie will
            # expire at the end of the session.
            expires = ""

        document.cookie = "#{name}=#{value}#{expires};path=/"


    @get: (name) ->
        match = document.cookie.match(new RegExp("#{name}=([^;]+)"))
        return match[1] if match
