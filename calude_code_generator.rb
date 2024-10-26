#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'
require 'dotenv'
Dotenv.load

class ClaudeCodeGenerator
  ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
  
  def initialize(api_key)
    @api_key = api_key
  end

  def generate_ruby_code(description)
    prompt = <<~PROMPT
      あなたはRubyプログラマーのアシスタントです。
      以下の要件に基づいて、実行可能なRubyコードを生成してください。
      コードのみを返してください。コメントや説明は不要です。
      
      要件:
      #{description}
    PROMPT

    response = call_claude_api(prompt)
    
    if response && response['content']
      # レスポンスからコードを抽出
      code = extract_code(response['content'][0]['text'])
      format_code(code)
    else
      raise "コードの生成に失敗しました"
    end
  end

  private

  def call_claude_api(prompt)
    uri = URI.parse(ANTHROPIC_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = @api_key
    request["anthropic-version"] = "2023-06-01"

    request.body = {
      model: "claude-3-sonnet-20240229",
      max_tokens: 1024,
      messages: [{
        role: "user",
        content: prompt
      }]
    }.to_json

    begin
      response = http.request(request)
      JSON.parse(response.body)
    rescue => e
      puts "API呼び出しエラー: #{e.message}"
      nil
    end
  end

  def extract_code(response_text)
    # コードブロックを抽出（```rubyと```で囲まれた部分）
    if response_text =~ /```ruby\n(.*?)```/m
      $1.strip
    else
      response_text.strip
    end
  end

  def format_code(code)
    # コードを%q{...}形式にフォーマット
    "%q{\n#{code.gsub(/\A\n|\n\z/, '').gsub(/^/, '  ')}\n}"
  end
end

# 使用例
if __FILE__ == $0
  unless ENV['ANTHROPIC_API_KEY']
    puts "環境変数 ANTHROPIC_API_KEY が設定されていません"
    exit 1
  end

  generator = ClaudeCodeGenerator.new(ENV['ANTHROPIC_API_KEY'])

  # コード生成の例
  descriptions = [
    "1から10までの数字を出力し、各数字が偶数か奇数かを表示するプログラム",
    "ユーザーから文字列を入力として受け取り、その文字列が回文かどうかをチェックするプログラム",
    "現在の日時を取得し、年、月、日、時、分、秒を別々に表示するプログラム"
  ]

  descriptions.each do |desc|
    puts "\n=== 生成するプログラムの説明 ==="
    puts desc
    puts "\n=== 生成されたコード ==="
    begin
      code = generator.generate_ruby_code(desc)
      puts code
      puts "\n=== 実行結果 ==="
      eval(eval(code))
    rescue => e
      puts "エラー: #{e.message}"
    end
    puts "\n"
  end
end
