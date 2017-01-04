#!/usr/bin/ruby

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'pry'

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.app_host = 'https://50.23.224.213'
Capybara.run_server = false

class WordlyWise
  include Capybara::DSL

  SCHOOL_ID = ENV['WW_SCHOOL_ID']
  SCHOOL = ENV['WW_SCHOOL']
  USERNAME = ENV['WW_USERNAME']
  PASSWORD = ENV['WW_PASSWORD']

  def login!
    visit '/academy/ProcessMngLogin.do?database=db01'
    select(SCHOOL, from: 'schoolId')
    fill_in 'loginUsername', with: USERNAME
    fill_in 'tempLoginPassword', with: PASSWORD
    find(:css, 'div.button_login').click
  end

  def generate_report(username)
    JSON.generate(save_report(username))
  end

  def save_report(name)
    filename = name.gsub(' ', '-').gsub(',', '').downcase + '-' + Time.now.strftime('%Y-%m-%d_%H-%M-%S') + '.png'
    visit '/academy/reportui/ReportFrames.htm?startPage=STWW3000SnapshotR'
    data = []
    within_frame(find('[name=content]')) do
      select name, from: 'studentId'
      sleep 1
      level = select_last_level
      sleep 1
      lessons = page.evaluate_script("$('[name=lessonName] option').map(function(opt) { return this.value }).get()")[1..-1]
      select lessons.last, from: 'lessonName'
      sleep 1
      data << json_data(name).merge(
        lesson: lessons.last.to_i,
        level: level
      )
    end
    data
  end

  def select_last_level
    last_selectable_level = page.evaluate_script("$('[name=streamGroupName] option:last').text()")
    if last_selectable_level.empty?
      last_selectable_level = /level.\s(\d+)/i.match(page.text)[1].to_f
    else
      select last_selectable_level, from: 'streamGroupName'
      last_selectable_level = last_selectable_level.to_f
      sleep 1
    end
    last_selectable_level
  end

  def json_data(name)
    grade = /grade.\s*(\d+)/i.match(page.text)[1].to_i
    rows = all('#_sortableTable tbody tr').map do |e|
      within(e) do
        all('td').map(&:text)
      end
    end
    {
      name: name,
      grade: grade,
      columns: all('#_sortableTable thead td').map(&:text),
      rows: rows
    }
  end
end

instance = WordlyWise.new
instance.login!
puts instance.generate_report(ARGV.first)
