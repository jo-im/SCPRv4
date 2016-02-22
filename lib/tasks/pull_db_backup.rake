namespace :pull_db_backup do
  require 'nokogiri'
  require 'net/http'
  require 'pry'

  # def cmd cmds
  #   IO.popen(cmds).each do |line|
  #     puts line
  #   end
  # end

  puts "Enter username:"
  username = STDIN.gets.chomp
  puts "Enter password:"
  password = STDIN.gets.chomp
  
  login_uri  = URI("http://login.scprdev.org/login")
  login_page_response = Net::HTTP.get_response(login_uri)
  login_page = login_page_response.body
  cookie = login_page_response['set-cookie'].split('; ')[0]
  authenticity_token = Nokogiri::HTML(login_page).css("form#login-form input[name=authenticity_token]").map{|i| i.attribute("value").to_s}.pop
  lt = Nokogiri::HTML(login_page).css("form#login-form input#lt").map{|i| i.attribute("value").to_s}.pop

  http = Net::HTTP.new(login_uri.host)

  request = Net::HTTP::Post.new(login_uri.path)

  request.set_form_data({
    utf8: "✓",
    authenticity_token: authenticity_token,
    lt: lt,
    username: username,
    password: password,
    button: ""
  })

  [
    ["Connection", "keep-alive"],
    ["Content-Length", "243"],
    ["Cache-Control", "max-age=0"],
    ["Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"],
    ["Origin", "http://login.scprdev.org"],
    ["Upgrade-Insecure-Requests", "1"],
    ["User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36"],
    ["Content-Type", "application/x-www-form-urlencoded"],
    ["DNT", "1"],
    ["Referer", "http://login.scprdev.org/login"],
    ["Accept-Encoding", "gzip, deflate"],
    ["Accept-Language", "en-US,en;q=0.8"],
    ["Cookie", cookie]
  ].each do |header|
    request[header[0]] = header[1]
  end

  authentication_response = http.request(request)





  backups_index_uri = URI("http://ops-deploybot.scprdev.org/backups/3")
  
  http = Net::HTTP.new(backups_index_uri.host)
  request = Net::HTTP::Get.new(backups_index_uri.path)

  [
    ["Connection", "keep-alive"],
    ["Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"],
    ["Origin", "http://login.scprdev.org"],
    ["Upgrade-Insecure-Requests", "1"],
    ["User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36"],
    ["DNT", "1"],
    ["Referer", "http://ops-deploybot.scprdev.org/backups"],
    ["Accept-Encoding", "gzip, deflate"],
    ["Accept-Language", "en-US,en;q=0.8"],
    ["Cookie", cookie]
  ].each do |header|
    request[header[0]] = header[1]
  end

  backups_page = http.request(request).body

  binding.pry



end
