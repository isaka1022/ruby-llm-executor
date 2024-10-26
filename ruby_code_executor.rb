#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'


class RubyCodeExecutor
  def initialize
    # 実行するサンプルのRubyプログラムを文字列として保持
    @sample_programs = {
      'hello' => %q{
        puts "Hello, World!"
        puts "Current time: #{Time.now}"
      },
      
      'calc' => %q{
        def calculate(a, b)
          puts "加算: #{a + b}"
          puts "減算: #{a - b}"
          puts "乗算: #{a * b}"
          puts "除算: #{a.to_f / b}"
        end
        
        calculate(10, 3)
      },
      
      'array' => %q{
        numbers = [1, 2, 3, 4, 5]
        puts "配列の処理:"
        puts "元の配列: #{numbers}"
        puts "2倍した配列: #{numbers.map { |n| n * 2 }}"
        puts "合計: #{numbers.sum}"
        puts "平均: #{numbers.sum.to_f / numbers.length}"
      }
    }
  end

  def list_programs
    puts "=== 実行可能なプログラム一覧 ==="
    @sample_programs.keys.each do |name|
      puts "- #{name}"
    end
  end

  def execute(program_name)
    unless @sample_programs.key?(program_name)
      raise ArgumentError, "指定されたプログラムは存在しません: #{program_name}"
    end

    code = @sample_programs[program_name]
    
    begin
      puts "=== プログラム '#{program_name}' を実行します ==="
      puts "--- 実行結果 ---"
      
      # evalを使用してRubyコードを実行
      eval(code)
      
      puts "--- 実行終了 ---"
      return true
    rescue => e
      puts "エラーが発生しました: #{e.message}"
      puts e.backtrace
      return false
    end
  end

  def add_program(name, code)
    if @sample_programs.key?(name)
      puts "警告: プログラム '#{name}' は上書きされます"
    end
    @sample_programs[name] = code
    puts "プログラム '#{name}' を追加しました"
  end
end

# 使用例
if __FILE__ == $0
  executor = RubyCodeExecutor.new

  if ARGV.empty?
    puts "使用方法: ruby #{$0} <プログラム名>"
    puts "\n利用可能なプログラム:"
    executor.list_programs
    exit 1
  end

  program_name = ARGV[0]
  success = executor.execute(program_name)
  
  exit(success ? 0 : 1)
end
