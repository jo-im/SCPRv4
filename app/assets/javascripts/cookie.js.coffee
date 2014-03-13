class scpr.Cookie
    @set: (name, value, expireSeconds) ->
        if (expireSeconds == null)
            expiry = new Date() + expireSeconds
            expires = "; expires=" + date.toGMTString()
        else
            expires = ""

        document.cookie = "#{name}=#{value}#{expires};path=/"


    @get: (name) ->
        match = document.cookie.match(new RegExp("#{name}=([^;]+)"))
        return match[1] if (match)
