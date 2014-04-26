class scpr.Cookie
    @set: (name, value, expireSeconds) ->
        if expireSeconds
            expiry = new Date() + expireSeconds
            expires = "; expires=" + expiry.toGMTString()
        else
            expires = ""

        document.cookie = "#{name}=#{value}#{expires};path=/"


    @get: (name) ->
        match = document.cookie.match(new RegExp("#{name}=([^;]+)"))
        return match[1] if match
