class TestApplication
  def call(env)
    env['REMOTE_USER'] = "test@example.com"
    code   = 200
    body   = "success"
    header = {
      "Content-Type" => "text/html;charset=utf-8",
      "Content-Length" => body.length
    }
    [ code, header, body ]
  end
end
